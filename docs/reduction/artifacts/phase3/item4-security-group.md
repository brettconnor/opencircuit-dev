# Phase 3 — Item 4 batch 6: `security` group

## Scope

- Facade: `core/security.ts` → `export * from "./indexing/ignore.js";`
- CLI import sites migrated (2):
  - `extensions/cli/src/tools/readFile.ts`
  - `extensions/cli/src/tools/edit.ts`

Both previously imported `core/indexing/ignore.js` directly (for
`throwIfFileIsSecurityConcern`); both now import `core/security.js`. The
old deep path is untouched and still resolves — removal deferred to a
later, separately-approved batch per the Item 4 plan.

## Pre-emptive bare-import check

Grepped `core/indexing/ignore.ts`'s import statements before building the
facade. Only one relative import: `ContinueError`/`ContinueErrorReason`
from bare `../util/errors`. Both bindings are used as runtime values
(`throw new ContinueError(...)`), not types — no type/value split needed
here, unlike prior batches.

## Fix applied

- `ContinueError`, `ContinueErrorReason` → explicit `.js` extension:
  `"../util/errors.js"`. No logic change, specifier text only.

This was the simplest fix of any batch so far — a single bare import, both
bindings being plain values.

## Validation performed

1. **TypeScript typecheck** (`tsc -p ./tsconfig.npm.json --noEmit`, clean
   `dist`) — no errors.
2. **Clean core rebuild** — confirmed `dist/security.js` re-exports
   `./indexing/ignore.js` with the explicit extension, and
   `dist/indexing/ignore.js` shows the `errors.js` import correctly
   extension-annotated.
3. **Isolated external-consumer fixture** (packed tarball, `file:`
   dependency, `type: module`, outside repo):
   - JS runtime `import("@continuedev/core/dist/security.js")` — resolves
     cleanly, exposes all 19 expected exports (ignore-pattern constants and
     `throwIfFileIsSecurityConcern`/`isSecurityConcern`/`gitIgArrayFromFile`).
   - Strict `NodeNext` TypeScript typecheck importing
     `throwIfFileIsSecurityConcern` from the same facade path — passes with
     no errors.
4. **CLI build** — unchanged, 12.69 MB bundle.
5. **Both boundary-check scripts** — `violations: []`;
   `inputCount` 4140→4141 (expected +1 for the new facade file).
6. **Targeted tests**:
   - CLI: `edit.test.ts` (the only file with a dedicated test suite among
     the two touched CLI files; `readFile.ts` has no dedicated test file
     in this repo) — 10/10 pass.
   - Core's own first-party test suite for the touched module:
     `indexing/ignore.vitest.ts` — 29/29 pass, confirming the
     import-specifier edit introduced no regression.

## Takeaway

This was the most straightforward batch to date — a single-module facade
with exactly one bare import to fix, both bindings being plain runtime
values. No new failure modes were discovered; the established
grep-first/classify/fix workflow continues to generalize cleanly.
