# Phase 3 — Item 4 batch 8: `messageContent` group

## Scope

- Facade: `core/messageContent.ts` → `export * from "./util/messageContent.js";`
- CLI import site migrated (1):
  - `extensions/cli/src/stream/handleToolCalls.ts` (`stripImages`)

Old deep path `core/util/messageContent.js` is untouched and still
resolves — removal deferred to a later, separately-approved batch per the
Item 4 plan.

## Pre-emptive bare-import check

`core/util/messageContent.ts` had one bare specifier: a barrel import
(`from "../index"`) pulling in `ChatMessage`, `ContextItem`,
`MessageContent`, `MessagePart`, `TextMessagePart` — all five confirmed
type-only via grep (used exclusively as function parameter/return type
annotations, never as runtime values).

## Fix applied

- Converted the entire import to `import type { ... } from "../index.js";`
  — since every binding is type-only, no split into separate value/type
  imports was needed (unlike the `chatDescriber`/`globalContext` batches,
  which had mixed imports). This is the cleanest possible outcome of the
  classification step: a single-statement, single-directive fix.

## Validation performed

1. **TypeScript typecheck** (`tsc -p ./tsconfig.npm.json --noEmit`, clean
   `dist`) — no errors.
2. **Clean core rebuild** — confirmed `dist/util/messageContent.js` has the
   `import type` fully erased (zero import statements in the compiled
   output); `dist/messageContent.js` re-exports with the explicit `.js`
   extension.
3. **Isolated external-consumer fixture** (packed tarball, `file:`
   dependency, `type: module`, outside repo):
   - JS runtime `import("@continuedev/core/dist/messageContent.js")` —
     resolves cleanly, exposes all 5 expected exports:
     `normalizeToMessageParts`, `renderChatMessage`, `renderContextItems`,
     `renderContextItemsWithStatus`, `stripImages`.
   - Strict `NodeNext` TypeScript typecheck importing `stripImages` from
     the same facade path — passes with no errors.
4. **CLI build** — unchanged, 12.69 MB bundle.
5. **Both boundary-check scripts** — `violations: []`;
   `inputCount` 4141→4142 (expected +1 for the new facade file).
6. **Targeted tests**:
   - CLI: `handleToolCalls.test.ts` — 5/5 pass.
   - Core: `util/messageContent.test.ts` (a Jest test, not vitest — Core
     uses `.test.ts` + Jest for most unit tests and `.vitest.ts` for a
     separate vitest-based subset; ran via `npm test`'s underlying Jest
     invocation rather than `npx vitest run`, which reported "No test
     files found" since it only picks up `.vitest.ts`) — 7/7 pass.

## Takeaway

This was the cleanest fix of the Item 4 batches so far: a single bare
barrel import where every named binding turned out to be type-only,
requiring only a one-line `import` → `import type` conversion with no
splitting. Also worth noting for future batches: Core has two parallel
test runners (Jest for `*.test.ts`, vitest for `*.vitest.ts`) — always
check which suffix a target module's test file uses before concluding "no
tests exist" from a `vitest run` "No test files found" result.
