# Phase 4 Candidate Manifest

**Status:** Prepared for HITL review; no Phase 4 deletion batch is authorized.  
**Manifest source commit:** `1d664cc87525aa17c3fe04c44406527f2e773068`  
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

## Required approval fields

- Human reviewer: `<pending>`
- Approval date: `<pending>`
- Approved candidate IDs: `<none>`
- Approved batch order: `<none>`
- Approved change budget: Phase 4 defaults in the plan, unless explicitly changed

