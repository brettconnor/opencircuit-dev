# Phase 4 Candidate Manifest

**Status:** Ratified empty manifest; no executable Phase 4 deletion candidate remains.
**Manifest source commit:** `450df8c69cfbb47c87fbd3d45f318279ca8c3074`
**Retained-closure checkpoint:** `red-001-core-clean-install`  
**Validation host:** Ubuntu1 (`10.1.141.9`)  
**Runtime:** Node.js `24.19.0`, npm `11.17.0`

## Current executable scope

There are currently **no executable Phase 4 deletion candidates** on the
manifest source commit.

The previously proposed low-risk candidates were reconciled against current
`main`:

| Candidate | Historical path | Current-main result | Phase 4 disposition |
|---|---|---|---|
| GUI surface | `gui/` | Path is absent; the inventory records it as already closed. | Exclude: no deletion remains |
| Local SDK generator | `packages/continue-sdk/` | Path is absent after the prior `CLASS-SDKGEN-001` experiment. | Exclude: prior deletion already executed |

These are not Phase 4 deletion batches and must not be re-added to a Phase 4
branch.

## Explicit exclusions

The following remain outside executable scope until a separate approved
reconciliation and classification decision:

| Surface | Reason |
|---|---|
| `extensions/vscode/` | Deferred editor surface; the inventory records unresolved packaging coupling |
| `binary/` | Deferred packaging/distribution ownership |
| `docs-site/` | Active publication pipeline |
| `media/` | Retained references exist |
| `core/vendor/` and model assets | Load-bearing runtime dependency |
| `sync/` | Required by deferred VS Code build |
| Any `Unknown` or `Defer` candidate | Phase 4 policy prohibits autonomous deletion |

## Scope allowlist

```text
<empty until a human-approved candidate is added>
```

No deletion, stale-reference cleanup, package metadata change, lockfile change,
or documentation cleanup is authorized by this manifest.

## Ratification

The operator ratified the Phase 4 plan and authorized RED preparation on
2026-09-13. The current-main reconciliation remains authoritative: previously
identified GUI and local SDK-generator candidates are already absent and are
not recreated as deletion work.

## Required approval fields

- Human reviewer: `Operator ratification`
- Approval date: `2026-09-13`
- Approved candidate IDs: `<none — empty after current-main reconciliation>`
- Approved batch order: `<none — no executable candidate remains>`
- Approved change budget: Phase 4 defaults in the plan
