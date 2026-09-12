# Phase 0 CLI/Core Completion

## Decision

The Phase 0 characterization baseline is complete with an accepted clean-install exception when this record and its referenced evidence are committed and tagged as `phase0-cli-core-complete`.

RED may begin only from `phase0-cli-core-complete`. The first RED batch is limited to restoring Core immutable-install integrity. Product-surface deletion, relocation, or workspace removal may begin only after Core's immutable install and the full Phase 0 comparison pass.

## Immutable References

| Reference                  | Purpose                                                        | Verification                                                                                       |
| -------------------------- | -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `phase0-source-baseline`   | Original repository state before Phase 0 artifacts             | `git rev-parse phase0-source-baseline^{commit}` returns `a96202f57d650a4e42cc747d705e4d0e0ea24bf5` |
| `phase0-cli-core-complete` | Reviewed contracts, inventories, tests, results, and artifacts | `git rev-parse phase0-cli-core-complete^{commit}` returns the commit containing this record        |

## Completed Evidence

- Exact environment, measurements, package install matrix, lockfile hashes, builds, typechecks, and test results: `docs/reduction/phase-0-baseline.md`.
- CLI, executable, package, Core, and Config YAML entry points: `docs/reduction/cli-core-entry-points.md`.
- Observed CLI deep imports, Core export state, exceptions, and boundary results: `docs/reduction/cli-core-boundaries.md`.
- Keep, Remove, and Defer decisions with disconfirming checks: `docs/reduction/cli-core-dependency-inventory.md`.
- License, package metadata, and vendored attribution state: `docs/reduction/license-attribution-inventory.md`.
- Characterization definitions and executable boundary checks: `tests/characterization/`.
- Install, build, test, static, emitted-bundle, and runtime artifacts: `docs/reduction/artifacts/phase0/`.
- Independent completion-gate review: `docs/planning/phase0-baseline-review.md`.
- Plan completion review: `docs/planning/phase0-baseline-plan_v2_review.md`.

## Validation Result

The retained local packages, Core, and CLI build successfully. Core and CLI typechecks pass. Configuration parsing, model initialization and selection, adapter normalization, CLI smoke tests, and the controlled headless workflow pass.

Static source, emitted-bundle, and runtime module-resolution boundary checks pass against the named denylist. Existing CLI-to-Core deep imports and the missing declared Core runtime export are recorded baseline exceptions rather than hidden failures.

## Accepted Baseline Failure

`core/package-lock.json` is not synchronized with `core/package.json`, so `npm ci` fails for Core. The failure is captured in `artifacts/phase0/install/core.log`.

The lockfile was not modified. A non-locking install with `--package-lock=false` was used only to continue characterization. RED must repair and commit the Core lockfile before claiming clean-install parity.

The standard CLI build also omits the `dist/index.d.ts` file declared by the package. The separate declaration command passes but emits `dist/extensions/cli/src/index.d.ts`; RED must correct and wire declaration generation into the supported package build before claiming package-entry parity.

## RED Entry Gate

The first RED batch is `RED-001-core-lockfile-integrity`:

| Field               | Requirement                                                                                                                          |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Hypothesis          | Regenerating Core's lockfile from the current manifest restores immutable installation without unintended runtime dependency changes |
| Allowed changes     | `core/package-lock.json`, dependency metadata proven necessary, and baseline evidence updates                                        |
| Disconfirming check | From no `core/node_modules`, `npm ci --ignore-scripts --no-audit --no-fund` succeeds and leaves tracked files unchanged              |
| Regression checks   | Core and CLI typechecks/builds, all characterization tests, and all boundary checks                                                  |
| Prohibited changes  | Product deletion, workspace removal, Core API refactoring, CLI behavior changes, and VS Code changes                                 |
| Rollback            | Revert RED-001 or return a local worktree to `phase0-cli-core-complete`                                                              |

Before beginning RED-001:

1. Check out `phase0-cli-core-complete`.
2. Confirm the tag resolves to the committed Phase 0 evidence.
3. Create a new branch or revertible commit from that tag.
4. Use the hypothesis and disconfirming check above.
5. Reuse the Phase 0 commands and artifacts for comparison.

After RED-001 passes, record a new immutable checkpoint before product-surface deletion. Do not begin RED from `phase0-source-baseline` or an intermediate `reduce/cli-core` commit.
