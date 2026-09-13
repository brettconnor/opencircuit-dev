# Phase 4 Execution Ledger

**Status:** Initialized for ratified RED preparation; no executable batch remains.
**Manifest:** `docs/reduction/phase4-candidate-manifest.md`  
**Plan:** `docs/planning/phase4_reversible_deletion_v1.md`  
**Starting checkpoint:** `red-001-core-clean-install`

## Phase-entry decision

| Field | Value |
|---|---|
| Phase entry | **FULL GO — ratified; ready when an executable candidate exists** |
| Source `main` commit | `450df8c69cfbb47c87fbd3d45f318279ca8c3074` |
| Phase branch | `reduce/phase4-reversible-deletion` |
| Candidate manifest | Ratified empty; no executable candidate remains |
| Path allowlist | Empty |
| Ubuntu1 validation mode | `--phase4-validate` available and tested |
| RED-001 broader Core Jest limitation | Recorded limitation; no current candidate touches the affected closure |
| Reviewer | `Operator ratification` |
| Approval date | `2026-09-13` |

## Batch ledger

No Phase 4 deletion batches exist because the ratified manifest is empty. Do
not create a deletion commit until a concrete candidate is reconciled and
added to the manifest.

| Batch | Deletion commit | Evidence commit | Candidate IDs | Scope | Profile | Result | Continuation | Exceptions |
|---|---|---|---|---|---|---|---|---|
| — | — | — | — | — | — | Ready / no candidate | Stop | Empty ratified manifest |

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
