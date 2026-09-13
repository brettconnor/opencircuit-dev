# Phase 3 — Item 4 batch 5: `editing` group (3-module facade)

## Scope

Per Item 2's grouping rationale, `performReplace.js`, `findAndReplaceUtils.js`,
and `multiEditValidation.js` are exposed as **one** subpath
(`@continuedev/core/editing`) rather than three separate facades, since all
three are always co-consumed by the same two CLI tools and form one
cohesive "search-and-replace edit engine" concept.

- Facade: `core/editing.ts`:
  ```ts
  export * from "./edit/searchAndReplace/performReplace.js";
  export * from "./edit/searchAndReplace/findAndReplaceUtils.js";
  export * from "./edit/searchAndReplace/multiEditValidation.js";
  ```
  Verified no export-name collisions across the three re-exported modules
  before wiring up `export *` (each module's exported symbols are disjoint).
- CLI import sites migrated (4 import statements across 2 files, consolidated
  into 2 combined imports):
  - `extensions/cli/src/tools/multiEdit.ts` — `validateMultiEdit` +
    `executeMultiFindAndReplace` now imported together from `core/editing.js`.
  - `extensions/cli/src/tools/edit.ts` — `validateSingleEdit` +
    `executeFindAndReplace` now imported together from `core/editing.js`.

Old deep paths (`core/edit/searchAndReplace/*.js`) are untouched and still
resolve — removal deferred to a separately-approved future batch.

## Pre-emptive bare-import check

Grepped all three target modules' import statements before building the
facade (per the pattern established in the `globalContext` batch):

- `performReplace.ts`: `EditOperation` (type-only, from
  `../../tools/definitions/multiEdit`), `ContinueError`/`ContinueErrorReason`
  (values, from `../../util/errors`), `SearchMatchResult` (type) +
  `findSearchMatches` (value) from `./findSearchMatch`.
- `findAndReplaceUtils.ts`: `ContinueError`/`ContinueErrorReason` (values,
  same specifier as above).
- `multiEditValidation.ts`: `EditOperation` (type-only, same specifier),
  `ContinueError`/`ContinueErrorReason` (values, same specifier),
  `validateSingleEdit` (value, from `./findAndReplaceUtils`).

All were bare/extensionless. Confirmed `EditOperation` is a plain
`export interface` in `tools/definitions/multiEdit.ts` — safe to import via
`import type`, fully erased at compile time, so the fact that
`multiEdit.ts` itself has further (unexamined) imports of its own does not
matter for this chain. `findSearchMatch.ts` (the file `SearchMatchResult`/
`findSearchMatches` come from) has zero imports of its own.

## Fix applied (same pattern as prior batches)

- `EditOperation` → `import type ... from "../../tools/definitions/multiEdit.js"`.
- `ContinueError`, `ContinueErrorReason` → value import, given explicit
  `.js`: `"../../util/errors.js"`.
- `SearchMatchResult` → split into `import type ... from "./findSearchMatch.js"`.
- `findSearchMatches` → value import, explicit `.js`: `"./findSearchMatch.js"`.
- `validateSingleEdit` → value import, explicit `.js`:
  `"./findAndReplaceUtils.js"`.

No logic changes — only import specifier text was edited.

## Validation performed

1. **TypeScript typecheck** (`tsc -p ./tsconfig.npm.json --noEmit`, after a
   clean `dist` removal) — no errors.
2. **Clean core rebuild** — confirmed `dist/editing.js` contains all three
   `export *` re-exports with explicit `.js` extensions; confirmed
   `dist/edit/searchAndReplace/performReplace.js` and
   `dist/edit/searchAndReplace/multiEditValidation.js` show type-only
   imports fully erased and value imports carrying explicit extensions.
3. **Isolated external-consumer fixture** (packed tarball, `file:`
   dependency, `type: module`, outside repo):
   - JS runtime `import("@continuedev/core/dist/editing.js")` — resolves
     cleanly, exposes all 6 expected exports:
     `FOUND_MULTIPLE_FIND_STRINGS_ERROR`, `executeFindAndReplace`,
     `executeMultiFindAndReplace`, `trimEmptyLines`, `validateMultiEdit`,
     `validateSingleEdit`.
   - Strict `NodeNext` TypeScript typecheck importing all 4
     runtime-consumed functions from the same facade path — passes with no
     errors.
4. **CLI build** — unchanged, 12.69 MB bundle.
5. **Both boundary-check scripts** — `violations: []`;
   `inputCount` 4139→4140 (expected +1 for the new facade file).
6. **Targeted CLI vitest** (`edit.test.ts`, `multiEdit.test.ts`) —
   22/22 pass.
7. **Core's own test suite for the touched modules**
   (`findSearchMatch.vitest.ts`, `executeFindAndReplace.vitest.ts`,
   `multiEdit.vitest.ts`, `findAndReplaceUtils.vitest.ts`) — 125/125 pass,
   confirming the import-specifier edits inside Core itself introduced no
   regression to Core's own retained-closure test coverage.

## Takeaway

This batch confirms the "grep first, classify each binding, fix type vs.
value uniformly" workflow scales cleanly to a multi-module grouped facade
(3 modules, 1 subpath) without surprises, and that running the source
module's own first-party test suite (not just the CLI's) is a useful extra
confirmation step whenever the facade wraps more than a single leaf module.
