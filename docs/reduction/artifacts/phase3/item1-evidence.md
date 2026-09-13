# Phase 3 — Item 1 Evidence: Import Classification

**Status:** Complete (classification only; no source changes made)
**Produced for:** `docs/planning/phase3-core-boundary_v1.md`, "Item 1 — import classification"
**Depends on:** `docs/reduction/artifacts/phase3/item0-evidence.md` (Item 0)

Per the plan, this stage produces a classification table only — no code or config changes. Every CLI→Core import (29 root/declaration + 34 deep, 16 unique deep specifiers) is classified below using the plan's taxonomy: `RootPublicCandidate`, `PublicSubpathCandidate`, `CompatibilityOnlyCandidate`, `RelocateToCLI`, `MoveToSharedPackage`, `Investigate`, `Blocked`.

## Population A — root `core` / `core/index.js` imports (29 import sites, 27 files)

| Property | Value |
|---|---|
| Symbols imported | `ChatHistoryItem`, `Session`, `ToolStatus`, `Usage`, `SessionUsage`, `BaseSessionMetadata`, `ContextItem`, `ToolCallState` |
| Runtime/build/type-only role | **Type-only** in all 27 files (confirmed Item 0 §4) |
| Test coverage | N/A — types are erased before test execution; no runtime behavior to cover |
| Core ownership | These are Core-domain data-shape types (chat history, session, tool status) — legitimately Core-owned |
| Editor/browser side effects | None (types only) |
| External/deferred consumers | `binary`, `extensions/vscode` also reference these type names via their own imports of `core`, using standard resolution |
| Proposed stable package path | Root export surface, e.g. `@continuedev/core` main `types` entry (`core/index.d.ts`, once wired to a real build artifact) |
| Migration priority | High — cheapest, lowest-risk fix; purely a `types`/`declaration` wiring problem, not a runtime dependency problem |
| **Classification** | **`RootPublicCandidate`** — legitimate root-level public type surface, contingent on Item 2/3 producing a real buildable `types` entry point (fixing the `dist/index.d.ts` gap found in Item 0). |

## Population B — deep internal-path imports (34 import sites, 16 unique specifiers)

| Specifier | Symbol(s) | Sites | Role | Core test coverage | Also used by binary/vscode | Classification | Rationale |
|---|---|---|---|---|---|---|---|
| `core/util/errors.js` | `ContinueError`, `ContinueErrorReason` | 11 | value | none found | no | `PublicSubpathCandidate` | Widely reused error-shape contract across nearly every CLI tool; clearly a deliberate shared contract, not incidental reach-in |
| `core/util/messageConversion.js` | `convertToUnifiedHistory`, `convertFromUnifiedHistory`, `convertFromUnifiedHistoryWithSystemMessage`, `createHistoryItem` | 10 (incl. tests) | value | none found in core | no | `PublicSubpathCandidate` | Second-most-reused module; central to CLI's chat-history model, worth a stable subpath even though CLI-only today |
| `core/util/chatDescriber.js` | `ChatDescriber` | 2 | value | `core/util/chatDescriber.test.ts` | no | `PublicSubpathCandidate` | Has first-party Core test coverage; general-purpose describer, not CLI-specific logic |
| `core/util/GlobalContext.js` | `GlobalContext` | 2 | value | `core/util/GlobalContext.test.ts` | yes (1) | `PublicSubpathCandidate` | Already a cross-consumer shared utility (binary/vscode also touch it) — strong signal for genuine Core ownership |
| `core/util/history.js` | default export (`historyManager`) | 2 | value | `core/util/history.test.ts` | no | `Investigate` | Default-export module; needs closer look at whether CLI's session/slash-command usage duplicates or diverges from Core's own history manager usage before committing to a stable path |
| `core/edit/searchAndReplace/performReplace.js` | `executeFindAndReplace`, `executeMultiFindAndReplace` | 2 | value | none found (only `findAndReplaceUtils` has a vitest) | no | `PublicSubpathCandidate` | Edit/replace engine is core editing logic reused by two CLI tools (`edit`, `multiEdit`); good subpath-export candidate |
| `core/indexing/ignore.js` | `throwIfFileIsSecurityConcern` | 2 | value | none found | yes (3) | `PublicSubpathCandidate` | Security-boundary check already shared with vscode/binary — must remain centrally owned, strong candidate |
| `core/util/paths.js` | `setConfigFilePermissions` | 1 | value | none found | yes (7) | `PublicSubpathCandidate` | Heavily reused across all three consumers (7 refs in binary/vscode alone) — clearly an intended shared utility module |
| `core/util/messageContent.js` | `stripImages` | 1 | value | `core/util/messageContent.test.ts` | yes (2) | `PublicSubpathCandidate` | Shared + tested; low-risk promotion |
| `core/util/uri.js` | `getLastNPathParts` | 1 | value | none found | yes (4) | `PublicSubpathCandidate` | Shared across consumers; simple pure utility |
| `core/llm/utils/calculateRequestCost.js` | `calculateRequestCost` | 1 | value | `core/llm/utils/calculateRequestCost.vitest.ts` | no | `PublicSubpathCandidate` | Tested, self-contained LLM-cost utility; general enough to expose |
| `core/llm/getAdjustedTokenCount.js` | `getAdjustedTokenCountFromModel` | 1 | value | `core/llm/getAdjustedTokenCount.test.ts` | no | `PublicSubpathCandidate` | Tested, general tokenizer utility |
| `core/edit/searchAndReplace/findAndReplaceUtils.js` | `validateSingleEdit` | 1 | value | `core/edit/searchAndReplace/findAndReplaceUtils.vitest.ts` | no | `PublicSubpathCandidate` | Tested; pairs with `performReplace.js` — should be exported together as one edit-engine subpath group |
| `core/edit/searchAndReplace/multiEditValidation.js` | `validateMultiEdit` | 1 | value | none found | no | `PublicSubpathCandidate` | Same edit-engine group as above two; group together in Item 4 migration |
| `core/tools/implementations/fetchUrlContent.js` | `fetchUrlContentImpl` | 1 | value | `core/tools/implementations/fetchUrlContent.vitest.ts` | no | `Investigate` | Named as a tool "implementation" — worth checking whether this is Core's own tool-calling infrastructure (shared contract) or logic that was only ever meant to run inside Core's own agent loop, which the CLI may be reaching into rather than being a sanctioned integration point |
| `core/config/markdown/utils.js` | `createRelativeRuleFilePath` | 1 | value | `core/config/markdown/utils.vitest.ts` | no | `Investigate` | Config/markdown path-rule generation — need to confirm this isn't config-loading internals the CLI happens to share by directory proximity rather than by design |

## Summary counts

| Classification | Count (unique specifiers, Population B) | Population A |
|---|---|---|
| `RootPublicCandidate` | — | 29 sites / 27 files (1 population) |
| `PublicSubpathCandidate` | 12 of 16 | — |
| `Investigate` | 3 of 16 (`util/history.js`, `tools/implementations/fetchUrlContent.js`, `config/markdown/utils.js`) | — |
| `CompatibilityOnlyCandidate` | 0 | — |
| `RelocateToCLI` | 0 | — |
| `MoveToSharedPackage` | 0 | — |
| `Blocked` | 0 | — |

**Notable finding:** no deep import was classified `RelocateToCLI` or `MoveToSharedPackage` — every deep import inspected is either already cross-consumer-shared, independently tested inside `core`, or forms a cohesive functional group (the three `edit/searchAndReplace/*` modules) that plausibly belongs in Core. This is a materially different conclusion than v0's implicit framing (which treated all 34 deep imports as boundary violations to resolve generically); most are legitimate reuse that simply lacks a declared contract, not misplaced code.

## Exit condition (per v1)

All 63 retained CLI→Core imports (29 root + 34 deep across 16 unique specifiers) now have a reviewed classification and rationale recorded above. Three specifiers (`util/history.js`, `tools/implementations/fetchUrlContent.js`, `config/markdown/utils.js`) require further investigation before Item 2's minimum-public-API proposal can include them with confidence; the remaining 13 (1 root population + 12 deep specifiers) are recommended for inclusion in Item 2's public API surface as either the root `types` export or grouped subpath exports (the three `edit/searchAndReplace/*` modules should be proposed as a single subpath group, not three separate exports).

Per the plan's approval gate, Item 1 being complete authorizes moving to **Item 2** (define the minimum public API proposal) — still no source moves, only a proposal document. No `core/package.json`, alias, or import-specifier changes are made in this artifact.
