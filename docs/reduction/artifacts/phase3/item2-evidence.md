# Phase 3 — Item 2 Evidence: Minimum Public API Proposal

**Status:** Complete (proposal only; no source moves made)
**Produced for:** `docs/planning/phase3-core-boundary_v1.md`, "Item 2 — define the minimum public API proposal"
**Depends on:** `docs/reduction/artifacts/phase3/item1-evidence.md` (Item 1)

Per the plan, this stage proposes stable public API paths for every import classified `RootPublicCandidate` or `PublicSubpathCandidate` in Item 1. Imports classified `Investigate` are intentionally **excluded** from this proposal — they are not approved for permanent public export until their open questions are resolved. No import is classified `RelocateToCLI`, `MoveToSharedPackage`, `CompatibilityOnlyCandidate`, or `Blocked` (see Item 1), so those categories have no rows here.

`<actual-core-package-name>` = `@continuedev/core` (confirmed Item 0 §1).

## Proposed API matrix

| Current import | Proposed API path | Status | Reason |
| --- | --- | --- | --- |
| `core` (types: `ChatHistoryItem`, `Session`, `ToolStatus`, `Usage`, `SessionUsage`, `BaseSessionMetadata`, `ContextItem`, `ToolCallState`) | `@continuedev/core` (root, `types` condition only) | Promote | Type-only root surface (Item 1); requires Item 3 to produce a real buildable `.d.ts` entry point before this is more than a proposal |
| `core/util/errors.js` | `@continuedev/core/errors` | Promote | Shared error-shape contract, reused by nearly every CLI tool |
| `core/util/messageConversion.js` | `@continuedev/core/messageConversion` | Promote | Central chat-history conversion contract, heavily reused within CLI |
| `core/util/chatDescriber.js` | `@continuedev/core/chatDescriber` | Promote | Has first-party Core test coverage; general-purpose |
| `core/util/GlobalContext.js` | `@continuedev/core/globalContext` | Promote | Already cross-consumer shared (binary/vscode) |
| `core/edit/searchAndReplace/performReplace.js` | `@continuedev/core/editing` | Promote | Grouped with `findAndReplaceUtils.js` + `multiEditValidation.js` under one `editing` subpath (see grouping note below) |
| `core/edit/searchAndReplace/findAndReplaceUtils.js` | `@continuedev/core/editing` | Promote | Same `editing` subpath group as `performReplace.js` |
| `core/edit/searchAndReplace/multiEditValidation.js` | `@continuedev/core/editing` | Promote | Same `editing` subpath group |
| `core/indexing/ignore.js` | `@continuedev/core/security` | Promote | Security-boundary check, already shared with vscode/binary — must stay centrally owned |
| `core/util/paths.js` | `@continuedev/core/paths` | Promote | Heavily reused across all three consumers (7 refs outside CLI) |
| `core/util/messageContent.js` | `@continuedev/core/messageContent` | Promote | Shared + tested |
| `core/util/uri.js` | `@continuedev/core/uri` | Promote | Shared across consumers; simple pure utility |
| `core/llm/utils/calculateRequestCost.js` | `@continuedev/core/llm/calculateRequestCost` | Promote | Tested, self-contained LLM-cost utility |
| `core/llm/getAdjustedTokenCount.js` | `@continuedev/core/llm/getAdjustedTokenCount` | Promote | Tested, general tokenizer utility |

### Excluded from this proposal (pending Item 1's `Investigate` resolution)

| Current import | Status | Reason |
| --- | --- | --- |
| `core/util/history.js` | Deferred — not proposed | Default-export module; ownership/duplication question unresolved (Item 1) |
| `core/tools/implementations/fetchUrlContent.js` | Deferred — not proposed | Unclear whether this is a sanctioned integration point or an internal implementation detail of Core's own agent loop |
| `core/config/markdown/utils.js` | Deferred — not proposed | Unclear whether this is config-loading internals shared only by directory proximity |

These three must either resolve to a classification change (via a short, targeted follow-up) or be explicitly re-scoped as `CompatibilityOnlyCandidate`/`RelocateToCLI` before Item 4 migrates them. Until resolved, the CLI's existing deep imports for these three remain as-is (no regression — nothing is broken by leaving them unclassified for now, since Item 3/4 do not touch unapproved paths).

## Grouping rationale: `editing` subpath

`performReplace.js`, `findAndReplaceUtils.js`, and `multiEditValidation.js` are proposed as **one** subpath (`@continuedev/core/editing`) rather than three, because:
- All three are consumed together by the same two CLI tools (`edit.ts`, `multiEdit.ts`).
- They form one cohesive "search-and-replace edit engine" concept, not three independent utilities.
- A single subpath reduces the number of `exports` map entries Core must maintain and avoids leaking internal file-splitting decisions into the public contract.

## Root `types`-only export note

The root `core` import is proposed as a `types`-only condition (not a runtime `main`/`import` condition) because Item 0/1 established that **no root import is live at runtime today** — all 29 sites are type-only. Proposing a runtime root export would exceed "minimum" and reintroduce the same undeclared-surface risk the plan is trying to eliminate. If a future runtime need for the root emerges, it should go through this same classification process rather than being bundled into Item 3's initial wiring.

## Summary

- **13 stable subpaths proposed** (1 root `types`-only + 12 distinct runtime subpaths, with 3 of the 12 runtime specifiers grouped into 1 `editing` subpath, yielding 10 runtime subpath exports total): `errors`, `messageConversion`, `chatDescriber`, `globalContext`, `editing`, `security`, `paths`, `messageContent`, `uri`, `llm/calculateRequestCost`, `llm/getAdjustedTokenCount`, plus the root `types` condition.
- **3 specifiers excluded pending further investigation.**
- **0 relocations or new shared packages proposed** — confirms Item 1's finding that this is a "declare what's already legitimately used" problem, not a "move misplaced code" problem.

## Exit condition (per v1)

Only the paths listed in "Proposed API matrix" above are proposed for permanent public export; everything else (the 3 deferred specifiers, and any CLI-internal import not in the 63-import inventory) remains unapproved. Per the plan's approval gate, this proposal document does not itself change `core/package.json`, add an `exports` map, or move any file — it is input to **Item 3** (establish package root and packed-consumer behavior), which is the next authorized step and the first item permitted to touch `core/package.json`.
