# Phase 3 — Item 4 Evidence: messageConversion Group Migration (Batch 2)

**Status:** Complete for the `messageConversion` group
**Produced for:** `docs/planning/phase3-core-boundary_v1.md`, "Item 4 — migrate and expose one approved subpath group at a time"
**Depends on:** Item 2's proposal, Item 4 batch 1 (`errors`, see `item4-errors-group.md`), whose facade pattern and validation process this batch reuses unchanged.

## What changed

- **New file `core/messageConversion.ts`** — a facade: `export * from "./util/messageConversion.js";`, following the same explicit-`.js`-extension convention established in batch 1 (required for strict-NodeNext external consumption; see `item4-errors-group.md` for the root-cause explanation).
- **Migrated 11 CLI import sites** from `"core/util/messageConversion.js"` to `"core/messageConversion.js"`: `compaction.infiniteLoop.test.ts`, `compaction.pruneLastMessage.test.ts`, `compaction.test.ts`, `messageConversion.test.ts`, `services/ChatHistoryService.ts`, `stream/handleToolCalls.test.ts`, `stream/handleToolCalls.ts`, `stream/streamChatResponse.autoCompaction.test.ts`, `stream/streamChatResponse.autoContinuation.test.ts`, `stream/streamChatResponse.ts`, `ui/hooks/useChat.clear.test.ts`.
- The old path (`core/util/messageConversion.js`) remains valid/untouched — no compatibility shim needed since it was never blocked; removal deferred to a separately approved batch, per the plan.

## Validation performed (same sequence as batch 1)

1. **Clean Core build**: `dist/messageConversion.js` + `dist/messageConversion.d.ts` produced.
2. **Package tarball**: `npm pack` succeeds, includes the new facade output.
3. **Isolated external fixture** (outside the repo, not committed): installed via `file:` dependency.
4. **JS runtime import**: `import("@continuedev/core/dist/messageConversion.js")` resolves; all 7 expected exports present (`convertFromUnifiedHistory`, `convertFromUnifiedHistoryWithSystemMessage`, `convertFromUnifiedMessage`, `convertToUnifiedHistory`, `convertToUnifiedMessage`, `createHistoryItem`, `extractToolCallInfo`).
5. **TypeScript typecheck** under strict `NodeNext`: resolves with zero errors.
6. **CLI build**: succeeds, unchanged bundle size (12.69 MB).
7. **Retained-closure checks**: `boundary-check.mjs` → `violations: []`, bundle input count 4136 → **4137** (one new facade file, expected). `runtime-boundary-check.mjs` → `violations: []`.
8. **Targeted CLI tests**: all 8 touched test files (`compaction.infiniteLoop.test.ts`, `compaction.pruneLastMessage.test.ts`, `compaction.test.ts`, `messageConversion.test.ts`, `stream/handleToolCalls.test.ts`, `stream/streamChatResponse.autoCompaction.test.ts`, `stream/streamChatResponse.autoContinuation.test.ts`, `ui/hooks/useChat.clear.test.ts`) → **69/69 tests pass**.

## Exit condition (per v1)

The `messageConversion` group is proven stable and consumed correctly, using the identical process validated in batch 1 (`errors`). No new issues were discovered; the explicit-`.js`-extension convention from batch 1 continues to be sufficient. Remaining groups from Item 2's proposal: `chatDescriber`, `globalContext`, `editing` (3-module group), `security`, `paths`, `messageContent`, `uri`, `llm/calculateRequestCost`, `llm/getAdjustedTokenCount`.
