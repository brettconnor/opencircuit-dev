# Phase 3 — Item 4 batch 4: `globalContext` group

## Scope

- Facade: `core/globalContext.ts` → `export * from "./util/GlobalContext.js";`
- CLI import sites migrated (2):
  - `extensions/cli/src/util/modelPersistence.ts`
  - `extensions/cli/src/services/UpdateService.ts`

Both previously imported `core/util/GlobalContext.js` directly; both now
import `core/globalContext.js`. The old deep path is untouched and still
resolves — removal is deferred to a later, separately-approved batch per
the Item 4 plan.

## Pre-emptive bare-import check (per the recommendation from the
`chatDescriber` finding)

Per the recommendation at the end of the `chatDescriber` evidence doc, the
target module and its transitive dependency chain were grepped for bare
`^import` specifiers *before* building the facade, rather than discovering
failures reactively via the isolated-fixture test. This surfaced bare
imports in three files in the transitive chain:

1. **`core/util/GlobalContext.ts`** (the module the facade re-exports):
   - `from ".."` (barrel) — `SiteIndexingConfig`, type-only usage.
   - `from "../config/sharedConfig"` (bare file) — mixed: `salvageSharedConfig`,
     `sharedConfigSchema` are values; `SharedConfigSchema` is type-only.
   - `from "./paths"` (bare file) — `getGlobalContextFilePath`, a value.
2. **`core/util/paths.ts`** (transitively imported by `GlobalContext.ts`):
   - `from "../"` (barrel) — `IdeType`, `SerializedContinueConfig`, both
     type-only.
   - `from "../config/default"` (bare file) — `defaultConfig`, a value.
   - `from "../config/types"` (bare file, default import) — `Types`, a value
     (a template-string constant, not itself importing anything further).
3. **`core/config/sharedConfig.ts`** (transitively imported by
   `GlobalContext.ts`):
   - `from ".."` (barrel) — `BrowserSerializedContinueConfig`, `Config`,
     `ContinueConfig`, `SerializedContinueConfig`, all type-only.

## Fix applied (narrow, zero-behavior-change, same pattern as `chatDescriber`)

For each bare specifier, applied one of two mechanical fixes based on
whether the imported binding is a type or a value:

- **Type-only bindings** → converted to `import type ... from "<path>/index.js"`
  (or the direct file with `.js` if not a barrel). `import type` is fully
  erased by TypeScript at compile time, so it never needs to resolve to a
  real runtime path — this sidesteps the fact that `../index.js`/`../` do
  not correspond to any real `dist/index.js` file (Core's root is
  types-only per Item 3; only `dist/index.d.ts` exists).
- **Value bindings** → given an explicit `.js` extension on the existing
  relative path (barrel values resolved to `./index.js`, file-based
  specifiers just got `.js` appended). No logic changes; only specifier
  text was edited.

Where a single import statement mixed types and values (`sharedConfig.ts`'s
`salvageSharedConfig`/`sharedConfigSchema`/`SharedConfigSchema` triple), the
statement was split into a value `import { ... } from ".../sharedConfig.js"`
and a separate `import type { ... } from ".../sharedConfig.js"`.

No file in this chain had a genuine "directory value-import" case (i.e. no
file did `import { someRuntimeValue } from ".."` for a value that isn't
itself type-erasable) — every barrel import turned out to be type-only,
so this batch didn't need to introduce a value re-export through
`util/index.ts` the way `chatDescriber` did. This confirms the checklist
approach (grep first, classify each binding, then fix) generalizes cleanly.

## Validation performed

1. **TypeScript typecheck** (`tsc -p ./tsconfig.npm.json --noEmit`) — clean
   (after clearing a stale `dist/` that was causing an unrelated
   self-referential type-identity error from a previous build artifact;
   confirmed this was pre-existing/incidental, not caused by this batch's
   edits, by re-running after `rm -rf dist`).
2. **Clean core rebuild** — confirmed `dist/util/GlobalContext.js`,
   `dist/util/paths.js`, and `dist/config/sharedConfig.js` all show the
   type-only imports fully erased and the value imports carrying explicit
   `.js` extensions.
3. **Isolated external-consumer fixture** (outside repo, packed tarball,
   `file:` dependency, `type: module`):
   - JS runtime `import("@continuedev/core/dist/globalContext.js")` —
     resolves cleanly, exposes `{ GlobalContext }` as expected.
   - Strict `NodeNext` TypeScript typecheck importing `GlobalContext` from
     the same facade path — passes with no errors.
4. **CLI build** — unchanged, 12.69 MB bundle.
5. **Both boundary-check scripts** — `violations: []`;
   `inputCount` 4138→4139 (expected +1 for the new facade file).
6. **Targeted CLI vitest** (`model-persistence.test.ts`,
   `model-persistence-user-flow.test.ts`, `model-persistence-e2e.test.ts`,
   `model-persistence-unauthenticated.test.ts`) — 15/15 pass.

## Takeaway

Pre-emptively grepping the target module's transitive import chain (rather
than discovering failures reactively through the isolated fixture, as
happened with `chatDescriber`) meaningfully sped up this batch — all fixes
were applied in one pass before the first rebuild attempt, and the fixture
validation passed on the first try. Recommend continuing this "grep first"
step for all remaining Item 4 groups.
