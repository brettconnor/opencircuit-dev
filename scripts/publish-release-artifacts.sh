#!/usr/bin/env bash
# Publish this repository's release-artifacts/ into a checkout of the public
# opencircuit-dev/opencircuit repository: sync the tarball + checksum pair,
# verify every tarball has a matching checksum, mirror the newest tarball and
# checksum to the destination repository's root as a "latest" convenience
# download, refresh the versions table in that repository's README.md, and
# (optionally) commit + push the result.
#
# Intended to run from a CI job that has already:
#   1. Built extensions/cli/release-artifacts/v<version>/... in this checkout
#      (see: npm --prefix extensions/cli run release:artifact)
#   2. Checked out opencircuit-dev/opencircuit into a separate local path
#
# Usage:
#   scripts/publish-release-artifacts.sh --dest <path> [--source <path>] [--push] [--no-commit]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_REPO="$REPO_ROOT"
DEST_REPO=""
DO_PUSH=0
DO_COMMIT=1

while [ $# -gt 0 ]; do
  case "$1" in
    --dest)
      DEST_REPO="$2"
      shift 2
      ;;
    --source)
      SOURCE_REPO="$2"
      shift 2
      ;;
    --push)
      DO_PUSH=1
      shift
      ;;
    --no-commit)
      DO_COMMIT=0
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [ -z "$DEST_REPO" ]; then
  echo "error: --dest <path to opencircuit-dev/opencircuit checkout> is required" >&2
  exit 1
fi
DEST_REPO="$(cd "$DEST_REPO" && pwd)"

SRC_ARTIFACTS="$SOURCE_REPO/release-artifacts"
DEST_ARTIFACTS="$DEST_REPO/release-artifacts"

if [ ! -d "$SRC_ARTIFACTS" ]; then
  echo "error: no release-artifacts directory found at $SRC_ARTIFACTS" >&2
  echo "       run 'npm --prefix extensions/cli run release:artifact' first" >&2
  exit 1
fi

echo "Publishing release artifacts"
echo "  from: $SRC_ARTIFACTS"
echo "  to:   $DEST_ARTIFACTS"

mkdir -p "$DEST_ARTIFACTS"
rsync -a --delete \
  --exclude ".DS_Store" \
  "$SRC_ARTIFACTS/" "$DEST_ARTIFACTS/"

# Verify every tarball has a matching sha256 checksum file before publishing.
missing=0
while IFS= read -r -d '' tarball; do
  checksum="${tarball}.sha256"
  if [ ! -f "$checksum" ]; then
    echo "error: missing checksum for $tarball" >&2
    missing=1
  fi
done < <(find "$DEST_ARTIFACTS" -type f -name '*.tgz' -print0)
if [ "$missing" -ne 0 ]; then
  exit 1
fi

# Determine the newest version directory and mirror its tarball + checksum to
# the repository root as a convenience "latest" download that does not
# require browsing into release-artifacts/<version>/.
latest_dir="$(find "$DEST_ARTIFACTS" -mindepth 1 -maxdepth 1 -type d | sort -rV | head -n1)"
if [ -z "$latest_dir" ]; then
  echo "error: no version directories found under $DEST_ARTIFACTS" >&2
  exit 1
fi
latest_version="$(basename "$latest_dir")"
latest_tgz="$(find "$latest_dir" -maxdepth 1 -name '*.tgz' | head -n1)"
if [ -z "$latest_tgz" ]; then
  echo "error: no .tgz found in $latest_dir" >&2
  exit 1
fi

# Remove any stale top-level tarball/checksum from a previous version before
# copying the current latest one into place.
find "$DEST_REPO" -maxdepth 1 -name 'opencircuit-cli-*.tgz' -delete
find "$DEST_REPO" -maxdepth 1 -name 'opencircuit-cli-*.tgz.sha256' -delete
cp "$latest_tgz" "$DEST_REPO/"
cp "$latest_tgz.sha256" "$DEST_REPO/"
echo "Mirrored latest ($latest_version) artifact to repository root: $(basename "$latest_tgz")"

# Rebuild the versions table between the README markers.
README="$DEST_REPO/README.md"
VERSIONS_TABLE=$(
  {
    echo "| Version | Artifact | Checksum |"
    echo "| ------- | -------- | -------- |"
    find "$DEST_ARTIFACTS" -mindepth 1 -maxdepth 1 -type d | sort -rV | while read -r dir; do
      version="$(basename "$dir")"
      tgz="$(find "$dir" -maxdepth 1 -name '*.tgz' | head -n1)"
      [ -n "$tgz" ] || continue
      name="$(basename "$tgz")"
      echo "| \`$version\` | [\`release-artifacts/$version/$name\`](release-artifacts/$version/$name) | [\`$name.sha256\`](release-artifacts/$version/$name.sha256) |"
    done
  }
)

python3 - "$README" "$VERSIONS_TABLE" <<'PY'
import sys

readme_path, table = sys.argv[1], sys.argv[2]
start_marker = "<!-- VERSIONS_TABLE_START -->"
end_marker = "<!-- VERSIONS_TABLE_END -->"

with open(readme_path, encoding="utf-8") as f:
    content = f.read()

start = content.index(start_marker) + len(start_marker)
end = content.index(end_marker)
content = content[:start] + "\n\n" + table + "\n\n" + content[end:]

with open(readme_path, "w", encoding="utf-8") as f:
    f.write(content)
PY

echo "Updated $README versions table."

if [ "$DO_COMMIT" -eq 1 ]; then
  cd "$DEST_REPO"
  git add -A release-artifacts README.md '*.tgz' '*.tgz.sha256'
  if ! git diff --cached --quiet; then
    git commit -m "Publish release artifacts ${latest_version:-update}"
    echo "Committed release artifact publish."
  else
    echo "No changes to commit."
  fi
fi

if [ "$DO_PUSH" -eq 1 ]; then
  cd "$DEST_REPO"
  git push origin HEAD
  echo "Pushed to origin."
fi
