# Phase 4 Execution Ledger

**Status:** P4-A D1 batch executing.
**Manifest:** `docs/reduction/phase4-candidate-manifest.md`  
**Plan:** `docs/planning/phase4_reversible_deletion_v1.md`  
**Starting checkpoint:** `red-001-core-clean-install`

## Phase-entry decision

| Field | Value |
|---|---|
| Phase entry | **FULL GO — ratified** |
| Source `main` commit | `450df8c69cfbb47c87fbd3d45f318279ca8c3074` |
| Phase branch | `reduce/phase4-reversible-deletion` |
| Candidate manifest | Ratified with P4-A D1 |
| Path allowlist | 22 exact `docs/images` paths |
| Ubuntu1 validation mode | `--phase4-validate` available and tested |
| RED-001 broader Core Jest limitation | Recorded limitation; no current candidate touches the affected closure |
| Reviewer | `Operator ratification` |
| Approval date | `2026-09-13` |

## Batch ledger

P4-A is the first executable D1 batch after bounded reconciliation. The
previously removed `gui/` and `packages/continue-sdk/` candidates remain
excluded as already absent; deferred and unknown surfaces remain excluded.

| Batch | Deletion commit | Evidence commit | Candidate IDs | Scope | Profile | Result | Continuation | Exceptions |
|---|---|---|---|---|---|---|---|---|
| P4-A | `<pending>` | `<pending>` | `P4-A` | 22 duplicate/unreferenced `docs/images` assets | D1 | Pending | Stop until Ubuntu1 validation | None |

## RED execution result

RED was invoked on 2026-09-13. P4-A is limited to exact duplicate or
unreferenced documentation assets; all canonical referenced assets remain.

## Entry-gate evidence index

- Retained-closure matrix:
  `docs/reduction/artifacts/phase1/retained-closure-install-matrix.md`
- RED-001 report:
  `docs/reduction/red-001-core-lockfile-integrity.md`
- RED-001 artifacts:
  `docs/reduction/artifacts/red-001/`
- Phase 3 boundary status:
  `docs/reduction/cli-core-boundaries.md`
- Candidate manifest:
  `docs/reduction/phase4-candidate-manifest.md`
