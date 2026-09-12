# Phase 0 Baseline Plan v2 Completion Review

## Outcome

The v2 plan resolves the v1 review findings by separating source and completion references, distinguishing observed imports from target architecture, defining package-specific installation evidence, and requiring three boundary layers.

The Phase 0 characterization baseline is complete with one accepted clean-install failure: `core/package-lock.json` is not synchronized with `core/package.json`, so Core cannot be installed with `npm ci`. The lockfile was not modified; a non-locking fallback was used only to continue characterization.

## Completion Checklist

| Requirement                          | Evidence                                                         | Status                                 |
| ------------------------------------ | ---------------------------------------------------------------- | -------------------------------------- |
| `reduce/cli-core` branch             | Git branch                                                       | Complete                               |
| `phase0-source-baseline` tag         | Original commit `a96202f57d650a4e42cc747d705e4d0e0ea24bf5`       | Complete                               |
| Exact environment and install matrix | `docs/reduction/phase-0-baseline.md`                             | Complete                               |
| CLI/Core entry points                | `docs/reduction/cli-core-entry-points.md`                        | Complete                               |
| Deep imports and Core export state   | `docs/reduction/cli-core-boundaries.md`                          | Complete                               |
| Characterization tests and artifacts | `tests/characterization/` and `docs/reduction/artifacts/phase0/` | Complete                               |
| Static boundary check                | `boundary-check.mjs` source report                               | Pass                                   |
| Emitted-bundle boundary check        | `boundary-check.mjs` esbuild metadata report                     | Pass                                   |
| Runtime boundary check               | `runtime-boundary-check.mjs` loader report                       | Pass                                   |
| Dependency decisions                 | `docs/reduction/cli-core-dependency-inventory.md`                | Complete                               |
| License and attribution state        | `docs/reduction/license-attribution-inventory.md`                | Complete                               |
| `phase0-cli-core-complete` tag       | Identifies the committed evidence state                          | Complete at the tagged evidence commit |

## Review Findings

### Accepted baseline failure

Core's immutable install fails before dependency installation because its package manifest and lockfile disagree. This is reproducible and captured in `docs/reduction/artifacts/phase0/install/core.log`.

The failure does not invalidate behavior characterization because:

- No lockfile was changed.
- The fallback command explicitly disabled lockfile updates.
- Core typecheck and build passed.
- CLI typecheck, build, smoke, and controlled workflow passed.
- Static, emitted-bundle, and runtime boundary checks passed.

RED must repair and commit the Core lockfile before claiming clean-install parity.

Only `RED-001-core-lockfile-integrity` is authorized immediately after the completion tag. Product deletion is blocked until RED-001 and the complete Phase 0 comparison pass.

### Accepted package-entry failure

The CLI manifest declares `dist/index.d.ts`, but `npm run build` does not invoke the available declaration build. The separate `npm run build:tsc` command emits `dist/extensions/cli/src/index.d.ts` instead of the declared path. RED must correct and wire declaration generation into the supported build before claiming package-entry parity.

### Accepted boundary exceptions

- BND-001 records the CLI's existing deep imports from Core.
- BND-002 records the missing declared public Core runtime export.

Both are target-architecture work and are not hidden Phase 0 failures.

## Approval

Create `phase0-cli-core-complete` only after this review, all evidence, and all checks are committed. RED may begin only from that tag, and the first batch is limited to Core lockfile remediation.
