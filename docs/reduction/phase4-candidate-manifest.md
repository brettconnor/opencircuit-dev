# Phase 4 Candidate Manifest

**Status:** Ratified; P4-A D1 static-asset batch approved for execution.
**Manifest source commit:** `450df8c69cfbb47c87fbd3d45f318279ca8c3074`
**Retained-closure checkpoint:** `red-001-core-clean-install`  
**Validation host:** Ubuntu1 (`10.1.141.9`)  
**Runtime:** Node.js `24.19.0`, npm `11.17.0`

## Current executable scope

The current reconciliation identified one executable D1 batch of duplicate or
unreferenced documentation assets. The retained canonical paths are referenced
by current documentation; only the exact paths listed below are authorized
for deletion.

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

### P4-A — Duplicate and unreferenced documentation assets (D1)

Classification record: `docs/reduction/artifacts/phase1/README.md`,
`docs/reduction/cli-core-dependency-inventory.md`, and the current-main
reconciliation artifact
`docs/reduction/artifacts/phase4/P4-A/reconciliation.md`.

Allowed deletion paths:

```text
docs/images/customize/assets/images/mcp-blocks-overview-c9a104f9b586779c156f9cf34da197c2.png
docs/images/hub/blocks/images/mcp-blocks-overview-c9a104f9b586779c156f9cf34da197c2.png
docs/images/mcp-blocks-overview-c9a104f9b586779c156f9cf34da197c2.png
docs/images/assets/images/prerelease-9bed93e846914165d30a3b227a680d9b.png
docs/images/prerelease-9bed93e846914165d30a3b227a680d9b.png
docs/images/customize/model-roles/assets/images/settings-model-roles-5e5f8a6bd9137b70cf94178a7e45847c.png
docs/images/customize/assets/images/configure-continue-a5c8c79f3304c08353f3fc727aa5da7e.png
docs/images/configure-continue.png
docs/images/customize/assets/images/context-provider-example-0c96ff77286fa970b23dddfdc1fa986a.png
docs/images/context-provider-example-0c96ff77286fa970b23dddfdc1fa986a.png
docs/images/assets/images/continue-console-d387a10c2918c117c6c253a3b5f18c22.png
docs/images/continue-console-d387a10c2918c117c6c253a3b5f18c22.png
docs/images/ide-extensions/agent/assets/images/agent-permission-c150919a5c43eb4f55d9d4a46ef8b2d6.png
docs/images/ide-extensions/agent/assets/images/agent-response-c7287c82aac93fb4376f9d85b352b2d7.png
docs/images/assets/images/intro-0c302b9c15b890c251b1ad04586c880f.png
docs/images/getting-started/assets/images/jetbrains-getting-started-d62b7edee1cdd58508c5075faf285955.png
docs/images/jetbrains-getting-started-d62b7edee1cdd58508c5075faf285955.png
docs/images/jetbrains-getting-started.png
docs/images/autocomplete-9d4e3f7658d3e65b8e8b20f2de939675.gif
docs/images/agent-9ef792cfc196a3b5faa984fb072c4400.gif
docs/images/chat-489b68d156be2aafe09ee7cedf233fba.gif
docs/images/move-to-right-sidebar-b2d315296198e41046fc174d8178f30a.gif
docs/images/move-to-right-sidebar.gif
```

Validation profile: D1. Exclusions: all canonical referenced paths, all
non-duplicate documentation assets, deferred surfaces, and all runtime/build
files.

## Ratification

The operator ratified the Phase 4 plan and authorized RED execution on
2026-09-13. The current-main reconciliation remains authoritative: previously
identified GUI and local SDK-generator candidates are already absent and are
not recreated as deletion work.

## Required approval fields

- Human reviewer: `Operator ratification`
- Approval date: `2026-09-13`
- Approved candidate IDs: `P4-A`
- Approved batch order: `P4-A`
- Approved change budget: Phase 4 defaults in the plan
