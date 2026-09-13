# Top-level documentation review

## Review scope

Reviewed every tracked documentation file at the repository root:

- `BUILD_DEPENDENCIES.md`
- `CLA.md`
- `CODE_OF_CONDUCT.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `TESTING.md`

## Actions

- **Kept `CLA.md`**: required contributor legal agreement referenced by
  `.github/workflows/cla.yaml`.
- **Kept `CODE_OF_CONDUCT.md`**: required community policy.
- **Kept `SECURITY.md`**: required vulnerability-reporting policy.
- **Updated `BUILD_DEPENDENCIES.md`**: clarified that it covers CI secrets and
  the retained CLI/Core repository plus deferred VS Code workflows.
- **Replaced `CONTRIBUTING.md`**: removed stale GUI, JetBrains, theme-color,
  Hub-era, and upstream-only instructions; retained current CLI/Core,
  Mintlify, package validation, contribution, and CLA guidance.
- **Deleted `TESTING.md`**: it was a historical PR #2 checklist describing
  completed Hub/Mission Control removal work, IntelliJ startup, and obsolete
  UI/telemetry checks rather than a maintained test guide.

The documentation issue template link was updated to the new contribution-guide
anchor, and the contributor guide now names the pinned Node.js `24.19.0`
runtime from `.nvmrc` and `.node-version`.

## Retained operational references

The top-level policy and contributor documents remain referenced by GitHub
workflow/templates where applicable. No legal, security, CI, package, or
runtime file was removed.
