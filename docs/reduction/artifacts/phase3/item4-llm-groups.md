# Phase 3 — Item 4 batch 10 (final): `llm/calculateRequestCost` +
`llm/getAdjustedTokenCount` groups

## Scope

This batch completes Item 4 by covering the last 2 entries in Item 2's API
matrix. Both are handled together since they're small, independent,
single-file, single-import-site groups under the shared `llm/` namespace.

### `llm/calculateRequestCost`

- Facade: `core/llm/calculateRequestCost.ts` →
  `export * from "./utils/calculateRequestCost.js";`
  (needed because the underlying module actually lives at
  `core/llm/utils/calculateRequestCost.ts` — one directory deeper than the
  proposed public subpath `@continuedev/core/llm/calculateRequestCost`.)
- CLI import site migrated (1):
  - `extensions/cli/src/stream/streamChatResponse.helpers.ts`
    (`calculateRequestCost`), from
    `core/llm/utils/calculateRequestCost.js` → `core/llm/calculateRequestCost.js`.

### `llm/getAdjustedTokenCount`

- **No facade needed.** The underlying module already lives at
  `core/llm/getAdjustedTokenCount.ts`, which compiles to
  `dist/llm/getAdjustedTokenCount.js` — exactly matching the proposed
  public subpath `@continuedev/core/llm/getAdjustedTokenCount`. The CLI's
  existing import (`extensions/cli/src/util/tokenizer.ts`,
  `getAdjustedTokenCountFromModel`) was already pointing at this exact
  path and required **no change**.
  This is the first Item 4 group where "promote to a public subpath" is
  a pure documentation/declaration act with zero code changes required —
  a useful confirmation that the facade pattern is a means to an end
  (aligning source layout with the declared public surface), not a
  mandatory step for every group.

Old deep path `core/llm/utils/calculateRequestCost.js` is untouched and
still resolves — removal deferred to a later, separately-approved batch
per the Item 4 plan.

## Pre-emptive bare-import check

- `core/llm/utils/calculateRequestCost.ts` had one bare specifier: `Usage`
  from `../..` (barrel), confirmed type-only via grep (used only as a
  parameter type annotation in three function signatures). Converted to
  `import type { Usage } from "../../index.js";`.
- `core/llm/getAdjustedTokenCount.ts` has **zero imports** — nothing to
  check or fix.

## Validation performed

1. **TypeScript typecheck** (`tsc -p ./tsconfig.npm.json --noEmit`, clean
   `dist`) — no errors.
2. **Clean core rebuild** — confirmed `dist/llm/calculateRequestCost.js`
   re-exports `./utils/calculateRequestCost.js` with the explicit
   extension; confirmed `dist/llm/getAdjustedTokenCount.js` already exists
   unchanged at the target path.
3. **Isolated external-consumer fixture** (packed tarball, `file:`
   dependency, `type: module`, outside repo):
   - JS runtime `import("@continuedev/core/dist/llm/calculateRequestCost.js")`
     — resolves cleanly, exposes `{ calculateRequestCost }`.
   - JS runtime `import("@continuedev/core/dist/llm/getAdjustedTokenCount.js")`
     — resolves cleanly, exposes `{ getAdjustedTokenCountFromModel }`.
   - Strict `NodeNext` TypeScript typecheck importing both functions from
     their respective facade/direct paths — passes with no errors.
4. **CLI build** — unchanged, 12.69 MB bundle.
5. **Both boundary-check scripts** — `violations: []`;
   `inputCount` 4144→4145 (expected +1, since only `calculateRequestCost.ts`
   is a genuinely new file — `getAdjustedTokenCount.ts` was already present
   and already counted in the baseline).
6. **Targeted tests**:
   - CLI: `tokenizer.test.ts`, `streamChatResponse.test.ts`,
     `streamChatResponse.autoContinuation.test.ts`,
     `streamChatResponse.getAllTools.test.ts`,
     `streamChatResponse.autoCompaction.test.ts`,
     `streamChatResponse.systemMessage.test.ts`,
     `streamChatResponse.modeSwitch.test.ts` — 65/65 pass (6 intentionally
     skipped).
   - Core: `llm/getAdjustedTokenCount.test.ts` (Jest) — 7/7 pass;
     `llm/utils/calculateRequestCost.vitest.ts` (vitest) — 22/22 pass.

## Item 4 completion summary

This batch closes out Item 4 of the Phase 3 experiment order. All 10
proposed runtime subpaths from Item 2's API matrix have now been exposed
and CLI-migrated across 10 separate, independently-reviewed batches:
`errors`, `messageConversion`, `chatDescriber`, `globalContext`, `editing`
(3-module group), `security`, `paths`, `messageContent`, `uri`,
`llm/calculateRequestCost` + `llm/getAdjustedTokenCount`. The recurring
theme across all batches: CLI's existing deep imports were never wrong or
broken, only *undeclared* — this work makes the already-real API surface
explicit and durable without moving or renaming any behavior. Old deep
import paths are left valid everywhere; their removal is deliberately
deferred to a future, separately-approved batch, consistent with the Item
4 plan's compatibility-preserving migration strategy.
