# Phase 3 — Item 4 batch 7: `paths` group

## Scope

- Facade: `core/paths.ts` → `export * from "./util/paths.js";`
- CLI import site migrated (1):
  - `extensions/cli/src/onboarding.ts` (`setConfigFilePermissions`)

Old deep path `core/util/paths.js` is untouched and still resolves —
removal deferred to a later, separately-approved batch per the Item 4
plan.

## Pre-emptive bare-import check

`core/util/paths.ts` had already had its own bare/extensionless imports
fixed as a side effect of the `globalContext` batch (batch 4), since
`GlobalContext.ts` transitively imports `paths.ts`. Re-confirmed at the
start of this batch that all of `paths.ts`'s own imports are already
extension-annotated (`../index.js` as `import type`, `../config/default.js`
and `../config/types.js` as values with explicit extensions) — no new
fixes were needed for this batch.

This confirms the fix applied during `globalContext` (batch 4) was durable
and correctly anticipated this later, separate promotion of `paths` to its
own dedicated subpath.

## Validation performed

1. **TypeScript typecheck** (`tsc -p ./tsconfig.npm.json --noEmit`, clean
   `dist`) — no errors.
2. **Clean core rebuild** — confirmed `dist/paths.js` re-exports
   `./util/paths.js` with the explicit extension.
3. **Isolated external-consumer fixture** (packed tarball, `file:`
   dependency, `type: module`, outside repo):
   - JS runtime `import("@continuedev/core/dist/paths.js")` — resolves
     cleanly, exposes all 44 expected exports (all the `get*Path`
     helpers, `setConfigFilePermissions`, `editConfigFile`, `migrate`,
     etc.).
   - Strict `NodeNext` TypeScript typecheck importing
     `setConfigFilePermissions` from the same facade path — passes with no
     errors.
4. **CLI build** — unchanged, 12.69 MB bundle.
5. **Both boundary-check scripts** — `violations: []`;
   `inputCount` 4141→4142 (expected +1 for the new facade file).
6. **Targeted CLI vitest** (`onboarding.test.ts`) — 9/9 pass. (No dedicated
   Core-side test file exists for `util/paths.ts`.)

## Takeaway

This batch demonstrates that the fixes applied while addressing a
transitive dependency in an earlier batch (`globalContext` → `paths.ts`)
remain valid and reusable when that same module is later promoted to its
own first-class facade — no rework was needed, only a confirmation grep.
