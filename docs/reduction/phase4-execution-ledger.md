# Phase 4 Execution Ledger

**Status:** Initialized; execution not authorized.  
**Manifest:** `docs/reduction/phase4-candidate-manifest.md`  
**Plan:** `docs/planning/phase4_reversible_deletion_v1.md`  
**Starting checkpoint:** `red-001-core-clean-install`

## Phase-entry decision

| Field | Value |
|---|---|
| Phase entry | **NO-GO — pending HITL approval and entry-gate completion** |
| Source `main` commit | `1d664cc87525aa17c3fe04c44406527f2e773068` |
| Phase branch | Not created |
| Candidate manifest | Prepared; no executable candidates |
| Path allowlist | Empty |
| Ubuntu1 validation mode | `--phase4-validate` available and tested |
| RED-001 broader Core Jest limitation | Requires explicit non-gating approval or remediation |
| Reviewer | `<pending>` |
| Approval date | `<pending>` |

## Batch ledger

No Phase 4 deletion batches exist. Do not create a deletion commit from this
ledger until the manifest, path allowlist, candidate scope, and entry gate are
approved.

| Batch | Deletion commit | Evidence commit | Candidate IDs | Scope | Profile | Result | Continuation | Exceptions |
|---|---|---|---|---|---|---|---|---|
| — | — | — | — | — | — | Not started | Stop | No approved executable candidate |

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

