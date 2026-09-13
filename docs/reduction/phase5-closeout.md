# Phase 5 CLI/Core Validation — Closeout

**Date:** 2026-09-13  
**Status:** Complete; TS2322 resolved and retained-closure validation restored  
**Plan:** `docs/planning/phase5-cli-core-validation_v2.md`  
**TS2322 plan:** `docs/planning/TS2322-PLAN_v0.md`  
**Execution branch:** `reduce/phase5-cli-core-validation`  
**Merged PR:** #37  
**Merge commit:** `308c540b735b4860504dadf281311c329420612e`

## Final decision

Phase 5 is complete. The deterministic Core `TS2322` failure was diagnosed,
resolved with a narrow type-boundary and declaration-input correction, and
validated through the fixed Ubuntu1 retained-closure profile. The resulting
branch was merged into `main` through PR #37.

- **Diagnosis:** Accepted. The failure reproduced three times from clean
  generated output on Ubuntu1.
- **Remediation:** Accepted. The fix preserves type safety and avoids broad
  dependency or product-surface changes.
- **Authoritative validation:** Passed. Ubuntu1 reported
  `phase5_result: pass` with no blockers.
- **Phase 4 continuation:** Restored. The retained CLI/Core closure is no
  longer blocked by the known TS2322 failure.
- **HITL:** Phase 5 closeout is complete; no further TS2322 approval gate is
  required.

## Failure and root cause

Core's retained typecheck failed after a successful build with:

```text
core.ts(1185,7): error TS2322:
Type '.../core/indexing/CodebaseIndexer'.CodebaseIndexer
is not assignable to type
'.../core/dist/indexing/CodebaseIndexer'.CodebaseIndexer.
Types have separate declarations of a private property 'configHandler'.
```

On Ubuntu1 (`10.1.141.9`, Node.js `24.19.0`, npm `11.17.0`), the fixed
diagnosis profile reproduced the error three times from clean `core/dist`
state. TypeScript resolution selected source and generated `dist`
declarations as separate nominal identities through Core's package
self-reference. Broad declaration-file inputs in `core/tsconfig.json` and
`core/tsconfig.npm.json` amplified the split.

## Remediation

Core fix commit `5e2685e07`:

- removed broad declaration-file inputs that admitted competing generated
  declarations;
- narrowed the `ToolExtras.codeBaseIndexer` boundary to the public capability
  consumed by tool implementations;
- preserved private-member encapsulation and meaningful type checking;
- changed no lockfile and introduced no type suppression, exclusion, or
  broad dependency upgrade.

The change remained within the Phase 5 allowlist and did not touch deferred
surfaces, deletion candidates, or unrelated public APIs.

## Validation record

### Diagnosis

- Fixed runner mode: `--phase5-diagnose`.
- Host: Ubuntu1, `10.1.141.9`.
- Runtime: Node.js `24.19.0`, npm `11.17.0`.
- Result: three deterministic TS2322 reproductions.
- Evidence:
  `docs/reduction/artifacts/phase5/P5-DIAG/pre-change/diagnosis-evidence.md`.

### Local targeted validation

The following checks passed:

- retained local-package install/build/test matrix in dependency order;
- Core clean build and `npm run tsc:check`;
- supported emitted-package consumer fixture for `ToolExtras`;
- CLI typecheck, build validation, build, and smoke tests;
- CLI config and model characterization tests;
- static and emitted boundary checks;
- lockfile SHA-256 integrity checks.

The sandbox-blocked `packages/fetch` fixture passed unchanged in the approved
network-capable context. macOS runtime characterization was not treated as
authoritative because the local checkout used Node.js `v26.7.0`; Ubuntu1 was
the required runtime authority.

### Authoritative Ubuntu1 validation

The fixed `--phase5-validate` profile passed from isolated remote checkout
`~/open-circuit-dev-phase5-validation`:

- tested commit: `36c7bff60a5ebca16eb0be38729a7530754c241d`;
- root workspace installation and retained package installation;
- Core and CLI build/typecheck validation;
- smoke, characterization, static, emitted, and runtime boundary checks;
- stale-reference and workspace scans;
- lockfile integrity checks;
- runner result: `phase5_result: pass`;
- blockers: none.

Evidence:

`docs/reduction/artifacts/phase5/P5-FIX/post-change/authoritative-validation.md`

## Validation harness corrections

The fixed runner required evidence-backed corrections before the final
authoritative pass:

- `f463d28e824b612d5eea762e7b106b22aca1308a` corrected stale-reference
  matching and cleaned ignored `core/dist` before validation.
- `dba6c7d2777660b9c941b25b827b8a99fbee32b6` installed the root workspace
  from its lockfile before `npm ls`.

The final runner and contract hashes were recorded in the Phase 5 summary.
These corrections are validation-harness fixes, not product behavior changes.

## Provenance

| Item | SHA or location |
|---|---|
| Phase starting checkpoint | `8a6a2ebd1351113ff51e7de85175c386fa749752` |
| Diagnosis evidence commit | `b98a77a9e` |
| Core remediation commit | `5e2685e07` |
| Tested branch tip | `36c7bff60a5ebca16eb0be38729a7530754c241d` |
| Final branch tip before merge | `e79f7f60e3f04260bade84ce35c2b24da3e93013` |
| PR | #37 |
| Merge commit | `308c540b735b4860504dadf281311c329420612e` |
| Execution ledger | `docs/reduction/phase5-execution-ledger.md` |
| Phase summary | `docs/reduction/phase5-summary.md` |
| TS2322 plan | `docs/planning/TS2322-PLAN_v0.md` |
| Authoritative evidence | `docs/reduction/artifacts/phase5/P5-FIX/post-change/authoritative-validation.md` |

## Rollback

The product remediation can be reverted with:

```text
git revert 5e2685e07
```

Runner corrections can be reverted independently if required:

```text
git -C /Users/brettcon/git/systems-orchestration revert \
  f463d28e824b612d5eea762e7b106b22aca1308a
git -C /Users/brettcon/git/systems-orchestration revert \
  dba6c7d2777660b9c941b25b827b8a99fbee32b6
```

Any rollback must preserve the diagnosis and validation artifacts and must be
reviewed as a normal Git change. Reverting the product fix would restore the
known TS2322 failure and invalidate the restored retained-closure claim.

## Next handoff

Phase 5 requires no additional TS2322 remediation work. The repository is
ready for the next approved phase or maintenance task. Any future reduction
batch may rely on the restored retained-closure baseline, but must still use
its own exact scope, evidence, fixed validation profile, and approval gate.
