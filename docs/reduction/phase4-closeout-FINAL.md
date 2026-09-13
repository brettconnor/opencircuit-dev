# Phase 4 Reversible Deletion — Final Closeout

**Date:** 2026-09-13  
**Status:** Execution complete; ready for HITL exit review  
**Plan:** `docs/planning/phase4_reversible_deletion_v1.md`  
**Branch:** `reduce/phase4-reversible-deletion`  
**Merged product commit:** `d1e559779aadd669de00416b686a4bc21090016a`  
**Closeout evidence commit:** `39046bb9b4bfb319a23a9d496549a845cd651c73`

## Final decision

Phase 4 execution is complete. The approved deletion batches were executed
within their exact allowlists, validated with the documented limitations, and
merged into `main` through PR #35.

- **P4-A:** Fully accepted. D1 validation passed locally and on Ubuntu1.
- **P4-B:** Conditionally accepted under the P4-B-only operator validation
  waiver. The deletion is safe within its evidence boundary, but the
  retained-Core typecheck limitation remains unresolved.
- **Continuation:** Stop. The bounded reconciliation found no additional
  eligible candidate.
- **HITL:** Phase exit review remains the final human gate.

## Executed batches

| Batch | Surface | Profile | Files removed | Deletion commit | Result |
|---|---|---:|---:|---|---|
| P4-A | Duplicate/unreferenced `docs/images` assets | D1 | 23 | `1acd6b5aa52c39c4c82b15da843e8089dbd82288` | Accepted; Ubuntu1 23/23 passed |
| P4-B | Stale root `.idea` JetBrains metadata | D4, validated with stricter D2 checks | 20 | `ceb6624f9dd44430bf38a474f47ec2617ce34adb` | Conditionally accepted under waiver |

## Measured reduction

- Tracked documentation images: **62 → 39**.
- Tracked root `.idea` files: **20 → 0**.
- Tracked repository files on the Phase 4 branch:
  **2,252 before P4-B → 2,233 after the Phase 4 branch state**,
  accounting for evidence files added during execution.
- Git object storage is not treated as a source-size reduction because Git
  history intentionally retains deleted content.

## Validation record

### P4-A

- Local stale-reference, canonical-path, scope, and `git diff --check`
  checks passed.
- Ubuntu1 fixed D1 validation passed for all 23 allowlisted paths.
- Host: `10.1.141.9`.
- Runtime: Node.js `24.19.0`.
- Validated remote commit:
  `2bbb5ed533a55af091b8571334325ffdb7971353`.

### P4-B

- Candidate-specific absence, exact-scope, stale-reference, and local hygiene
  checks passed.
- Core build passed on Ubuntu1.
- The stricter D2 retained-closure matrix then reproduced the known
  baseline-equivalent Core `TS2322` type-identity failure during
  `npm run tsc:check`.
- The failure occurs after a successful build, reproduces from a fresh
  `core/dist`, and is unrelated to root `.idea` metadata.
- The fixed runner stopped before later matrix and boundary steps; those
  unexecuted checks are not represented as passes.
- The operator waiver is limited to P4-B and does not weaken future D2, D3,
  or D4 acceptance criteria.

Waiver evidence:

`docs/reduction/artifacts/phase4/P4-B/validation-waiver.md`

Baseline and post-delete evidence:

- `docs/reduction/artifacts/phase4/P4-B/baseline-core-ts2322.log`
- `docs/reduction/artifacts/phase4/P4-B/post-delete-core-ts2322.log`

## Protected and deferred surfaces

The following were explicitly retained and were not autonomous deletion
targets:

- `extensions/vscode/`
- `binary/`
- `docs-site/`
- `media/` where referenced
- `sync/`
- `core/vendor/` and model assets
- retained CLI, Core, package source, manifests, lockfiles, CI, legal,
  publication, and runtime files
- root `.vscode/`, because active scripts and deferred VS Code workflows
  reference its tasks, launch configurations, and settings

Previously identified `gui/` and `packages/continue-sdk/` candidates were
already absent and were not recreated as Phase 4 deletion work.

## Provenance

| Evidence | Full SHA or location |
|---|---|
| Phase entry checkpoint | `450df8c69cfbb47c87fbd3d45f318279ca8c3074` |
| P4-A evidence | `e5f6e63583b61ad88653b12203bea2c605bbfb00` |
| P4-B evidence | `d0636908f4619710b09aa4856ac5d0069a2a6c05` |
| Final closeout evidence | `39046bb9b4bfb319a23a9d496549a845cd651c73` |
| Final bounded reconciliation | `docs/reduction/artifacts/phase4/reconciliation-final-2026-09-13.md` |
| Execution ledger | `docs/reduction/phase4-execution-ledger.md` |
| Candidate manifest | `docs/reduction/phase4-candidate-manifest.md` |
| Phase summary | `docs/reduction/phase4-summary.md` |
| Post-merge validation | `docs/reduction/artifacts/phase4/post-merge-validation-2026-09-13.md` |

## Rollback

The deletion batches are ordinary Git history and can be reversed with
targeted `git revert` operations. The merged product change is PR #35; any
rollback should preserve the evidence artifacts and be reviewed as a normal
revert.

## Next prerequisite

Resolve or formally re-baseline the Core `TS2322` type-identity failure before
any later D2, D3, or D4 deletion batch relies on the full retained-closure
matrix. Any new reduction candidate requires a fresh classification,
removal hypothesis, disconfirming evidence, exact allowlist, and approval.
