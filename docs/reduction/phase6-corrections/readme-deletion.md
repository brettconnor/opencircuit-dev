# Root README deletion record

## Scope

The root `README.md` was a non-production repository landing page. Its only
local non-production file dependency was:

- `media/github-readme.png` — the README banner image.

Both files were removed as one bounded cleanup batch.

## Retained references

The README also linked to production or legal surfaces that were intentionally
retained:

- `extensions/vscode/` — retained product surface;
- `extensions/cli/` — retained product surface;
- `LICENSE` — required legal file;
- external documentation, release, marketplace, and npm URLs.

Those surfaces were not deleted.

## Evidence

- `git grep` found no remaining tracked reference to
  `media/github-readme.png` outside the deleted README.
- No package manifest, build script, runtime import, or retained product
  boundary referenced the root README banner.
- The deletion is reversible with the containing Git commit.

## Result

The root README and its unused banner asset are removed. Production, legal,
and retained product files linked from the README remain intact.
