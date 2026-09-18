#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
REPOSITORY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_ARTIFACT="$REPOSITORY_ROOT/release-artifacts/v1.0.0/opencircuit-cli-1.0.0.tgz"
DEFAULT_USER="sysadmin"
DEFAULT_HOST="10.1.141.9"
DEFAULT_IDENTITY_FILE="${HOME}/.ssh/id_rsa"
REMOTE_RELEASE_ROOT="/home/sysadmin/open-circuit-release"
REMOTE_HOME="/home/sysadmin"

host="$DEFAULT_HOST"
remote_user="$DEFAULT_USER"
identity_file="$DEFAULT_IDENTITY_FILE"
artifact="$DEFAULT_ARTIFACT"
cleanup=false
remove_legacy_continue=false
dry_run=false
yes=false
install=false

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Deploy the verified Open Circuit CLI artifact to Ubuntu1.

Options:
  --host HOST       SSH host or address (default: $DEFAULT_HOST)
  --user USER       SSH user (default: $DEFAULT_USER)
  --identity FILE   SSH private key (default: $DEFAULT_IDENTITY_FILE)
  --artifact FILE   CLI tarball (default: $DEFAULT_ARTIFACT)
  --install         Install the transferred tarball globally as oc
  --cleanup         Remove scoped Open Circuit state on the remote host
  --remove-legacy-continue
                    Remove legacy .continue state without removing Open Circuit state
  --dry-run         Print actions without changing the remote host
  --yes             Confirm cleanup deletion when --cleanup is used
  -h, --help        Show this help

Cleanup preserves the existing checkout, legacy .continue unless explicitly
requested, provider credentials,
Node/nvm, Rust, Ansible, SSH, and unrelated user data.
EOF
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '[open-circuit-deploy] %s\n' "$*"
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --host) [[ $# -ge 2 ]] || fail "--host requires a value"; host="$2"; shift 2 ;;
      --user) [[ $# -ge 2 ]] || fail "--user requires a value"; remote_user="$2"; shift 2 ;;
      --identity) [[ $# -ge 2 ]] || fail "--identity requires a value"; identity_file="$2"; shift 2 ;;
      --artifact) [[ $# -ge 2 ]] || fail "--artifact requires a value"; artifact="$2"; shift 2 ;;
      --install) install=true; shift ;;
      --cleanup) cleanup=true; shift ;;
      --remove-legacy-continue) remove_legacy_continue=true; shift ;;
      --dry-run) dry_run=true; shift ;;
      --yes) yes=true; shift ;;
      -h|--help) usage; exit 0 ;;
      *) fail "Unknown option: $1" ;;
    esac
  done
}

run_ssh() {
  ssh -i "$identity_file" -o BatchMode=yes -o ConnectTimeout=10 "$remote_user@$host" "$@"
}

validate_local() {
  [[ -r "$identity_file" ]] || fail "SSH identity is not readable: $identity_file"
  [[ -f "$artifact" ]] || fail "Artifact not found: $artifact"
  [[ -f "${artifact}.sha256" ]] || fail "Checksum file not found: ${artifact}.sha256"
  (cd "$(dirname "$artifact")" && shasum -a 256 -c "$(basename "${artifact}.sha256")")
}

validate_environment() {
  command -v ssh >/dev/null 2>&1 || fail "ssh is required"
  command -v scp >/dev/null 2>&1 || fail "scp is required"
  command -v shasum >/dev/null 2>&1 || fail "shasum is required"
  validate_local
}

remote_cleanup_script() {
  cat <<'REMOTE_SCRIPT'
set -euo pipefail
home="$1"
release_root="$2"
dry_run="$3"
remove_legacy_continue="$4"

remove_path() {
  local target="$1"
  if [[ -e "$target" ]]; then
    if [[ "$dry_run" == true ]]; then
      printf 'would remove: %s\n' "$target"
    else
      rm -rf -- "$target"
      printf 'removed: %s\n' "$target"
    fi
  else
    printf 'absent: %s\n' "$target"
  fi
}

remove_path "$home/.ocircuit"
remove_path "$release_root"
if [[ "$remove_legacy_continue" == true ]]; then
  remove_path "$home/.continue"
  remove_path "$home/.continueignore"
  remove_path "$home/open-circuit-dev/.continue"
  remove_path "$home/open-circuit-dev/.continueignore"
fi
if command -v npm >/dev/null 2>&1; then
  if [[ "$dry_run" == true ]]; then
    npm list --global --depth=0 @opencircuit/cli >/dev/null 2>&1 &&
      printf 'would uninstall: @opencircuit/cli\n' || printf 'package absent: @opencircuit/cli\n'
  else
    npm uninstall --global @opencircuit/cli >/dev/null 2>&1 || true
    printf 'uninstalled: @opencircuit/cli\n'
  fi
fi

for shell_file in "$home/.bashrc" "$home/.profile" "$home/.zshrc"; do
  [[ -f "$shell_file" ]] || continue
  if [[ "$dry_run" == true ]]; then
    grep -nE 'OCIRCUIT_|\.ocircuit/env|Open Circuit and provider credentials|open-circuit-release' "$shell_file" || true
  else
    tmp_file="$(mktemp)"
    sed -E '/OCIRCUIT_|\.ocircuit\/env|Open Circuit and provider credentials|open-circuit-release/d' "$shell_file" > "$tmp_file"
    cat "$tmp_file" > "$shell_file"
    rm -f -- "$tmp_file"
  fi
done

if [[ "$dry_run" != true ]]; then
  [[ -d "$home/open-circuit-dev" ]] || printf 'warning: checkout missing\n'
  [[ -d "$home/.continue" ]] || printf 'warning: legacy .continue missing\n'
  [[ -d "$home/.nvm" ]] || printf 'warning: nvm missing\n'
fi
REMOTE_SCRIPT
}

run_cleanup() {
  if [[ "$yes" != true && "$dry_run" != true ]]; then
    fail "cleanup deletion requires --yes; use --dry-run to preview"
  fi
  log "cleanup: $([[ "$dry_run" == true ]] && echo preview || echo execute)"
  remote_cleanup_script | run_ssh bash -s -- "$REMOTE_HOME" "$REMOTE_RELEASE_ROOT" "$dry_run" "$remove_legacy_continue"
}

run_legacy_cleanup() {
  if [[ "$yes" != true && "$dry_run" != true ]]; then
    fail "legacy cleanup deletion requires --yes; use --dry-run to preview"
  fi
  log "legacy Continue cleanup: $([[ "$dry_run" == true ]] && echo preview || echo execute)"
  cat <<'REMOTE_SCRIPT' | run_ssh bash -s -- "$REMOTE_HOME" "$dry_run"
set -euo pipefail
home="$1"
dry_run="$2"
remove_path() {
  local target="$1"
  if [[ -e "$target" ]]; then
    if [[ "$dry_run" == true ]]; then printf 'would remove: %s\n' "$target"; else rm -rf -- "$target"; printf 'removed: %s\n' "$target"; fi
  else
    printf 'absent: %s\n' "$target"
  fi
}
remove_path "$home/.continue"
remove_path "$home/.continueignore"
remove_path "$home/open-circuit-dev/.continue"
remove_path "$home/open-circuit-dev/.continueignore"
REMOTE_SCRIPT
}

deploy_artifact() {
  local remote_dir="$REMOTE_RELEASE_ROOT/v1.0.0"
  if [[ "$dry_run" == true ]]; then
    log "would create $remote_dir and transfer $(basename "$artifact")"
    return
  fi
  run_ssh "mkdir -p '$remote_dir'"
  scp -i "$identity_file" -o BatchMode=yes "$artifact" "${artifact}.sha256" \
    "$remote_user@$host:$remote_dir/"
  run_ssh "cd '$remote_dir' && shasum -a 256 -c '$(basename "${artifact}.sha256")'"
  if [[ "$install" == true ]]; then
    artifact_name="$(basename "$artifact")"
    run_ssh bash -s -- "$remote_dir" "$artifact_name" <<'REMOTE_INSTALL'
set -euo pipefail
remote_dir="$1"
artifact_name="$2"
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.nvm/nvm.sh"
  nvm use 24.19.0 >/dev/null
else
  node_bin="$HOME/.local/node-v24.19.0-linux-x64/bin"
  [[ -x "$node_bin/node" && -x "$node_bin/npm" ]] || {
    printf 'ERROR: pinned Node.js 24.19.0 installation not found\n' >&2
    exit 1
  }
  export PATH="$node_bin:$PATH"
fi
cd "$remote_dir"
npm install --global --force --ignore-scripts "./$artifact_name" >/dev/null
hash -r
[[ "$(oc --version)" == "1.0.0" ]] || {
  printf 'ERROR: installed oc version is not 1.0.0\n' >&2
  exit 1
}
printf 'installed oc %s\n' "$(oc --version)"
REMOTE_INSTALL
  fi
}

main() {
  parse_args "$@"
  validate_environment

  if [[ "$cleanup" == true ]]; then
    run_cleanup
  fi
  if [[ "$remove_legacy_continue" == true ]]; then
    run_legacy_cleanup
  fi
  if [[ "$install" == true || ( "$cleanup" != true && "$remove_legacy_continue" != true ) ]]; then
    deploy_artifact
  fi

  if [[ "$dry_run" == true ]]; then
    log "completed: dry-run"
  elif [[ "$cleanup" == true ]]; then
    log "completed: cleanup/deploy"
  elif [[ "$remove_legacy_continue" == true ]]; then
    log "completed: legacy Continue cleanup"
  else
    log "completed: deploy"
  fi
}

main "$@"
