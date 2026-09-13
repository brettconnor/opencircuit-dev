# Phase 3 — Item 4 batch 3: `chatDescriber` group

## Scope

- Facade: `core/chatDescriber.ts` → `export * from "./util/chatDescriber.js";`
- CLI import sites migrated (2):
  - `extensions/cli/src/commands/chat.ts` (static `import`)
  - `extensions/cli/src/ui/hooks/useChat.helpers.ts` (dynamic `await import(...)`)

Both previously imported `core/util/chatDescriber.js` directly; both now import
`core/chatDescriber.js`. The old deep path is untouched and still resolves —
removal is deferred to a later, separately-approved batch per the Item 4 plan.

## New finding: transitive bare/directory imports break strict ESM consumption

The `errors` and `messageConversion` facades (batches 1–2) required only a
facade-level fix (explicit `.js` extension on the facade's own re-export
specifier). This batch surfaced a **deeper and more severe variant** of the
same underlying issue, this time inside the module the facade re-exports
(`core/util/chatDescriber.ts` itself), not the facade file.

`util/chatDescriber.ts` had four "bare" (extensionless) relative imports:

```ts
import { ILLM, LLMFullCompletionOptions } from "..";
import { removeCodeBlocksAndTrim, removeQuotesAndEscapes } from ".";
import { renderChatMessage } from "./messageContent";
import { convertFromUnifiedHistory } from "./messageConversion";
```

Under Core's own `moduleResolution: "Node"` (classic) config these all
resolve fine at compile time. But when consumed by a real external
strict-ESM consumer (raw `node --experimental-vm-modules`-style `import()`,
or `tsc --module NodeNext`), two distinct failure modes appeared as the
isolated-fixture test was iterated:

1. **`from ".."` and `from "."` (directory/barrel specifiers)** — Node's
   strict ESM resolver does not auto-append `/index.js` to a bare directory
   specifier (unlike CommonJS), so importing the compiled
   `dist/util/chatDescriber.js` threw `ERR_UNSUPPORTED_DIR_IMPORT` on `..`
   resolving to `core/dist/` and `.` resolving to `core/dist/util/`.
2. **`from "./messageContent"` and `from "./messageConversion"` (bare file
   specifiers, no extension)** — once the directory-import errors were
   fixed, the *next* bare file-specifier surfaced `ERR_MODULE_NOT_FOUND`
   for the same reason established in the `errors`-group finding: strict
   ESM requires the exact `.js` extension on relative specifiers.

This is a strictly more severe case than the ones already fixed, because it
sits inside the **re-exported module itself**, not the one-line facade —
meaning every facade that transitively touches `chatDescriber.ts` (or any
other Core module with the same bare-import pattern) would hit the same
wall regardless of how carefully the facade file itself is written.

## Fix applied (narrow, zero-behavior-change)

Edited only the import specifiers in `core/util/chatDescriber.ts` — no
logic changes:

```ts
import type { ILLM, LLMFullCompletionOptions } from "../index.js";
import { removeCodeBlocksAndTrim, removeQuotesAndEscapes } from "./index.js";
import type { FromCoreProtocol, ToCoreProtocol } from "../protocol";
import type { IMessenger } from "../protocol/messenger";
import { renderChatMessage } from "./messageContent.js";
import { convertFromUnifiedHistory } from "./messageConversion.js";
```

Two changes beyond adding extensions:

- `ILLM`/`LLMFullCompletionOptions` are used only as type annotations in
  this file (verified via grep — both usages are parameter type positions),
  so the import was additionally converted to `import type`. This is
  strictly safer than a value import with an added extension: TypeScript
  fully erases `import type` at compile time, so it never needs to resolve
  to a real runtime module path at all, sidestepping any ambiguity about
  whether `../index.js` corresponds to a real `dist/index.js` file (it does
  not — Core's root is types-only per Item 3; only `dist/index.d.ts`
  exists).
- `removeCodeBlocksAndTrim`/`removeQuotesAndEscapes` are real value imports
  (called at runtime) and are defined directly in `util/index.ts` (not
  re-exported from elsewhere), so `./index.js` is a correct, direct,
  zero-ambiguity target.

`./messageContent.js` and `./messageConversion.js` are plain file-based
specifiers (not barrels), so adding the extension is a direct, unambiguous
fix with no behavior change.

## Validation performed

1. **TypeScript typecheck** (`tsc -p ./tsconfig.npm.json --noEmit`) — no new
   errors introduced by the edited file.
2. **Clean core rebuild** — confirmed `dist/util/chatDescriber.js` now
   carries the explicit extensions verbatim; `dist/chatDescriber.js`/`.d.ts`
   (facade) unchanged in shape.
3. **Isolated external-consumer fixture** (outside repo, via packed
   tarball + `file:` dependency, `type: module`):
   - JS runtime `import("@continuedev/core/dist/chatDescriber.js")` —
     previously threw `ERR_UNSUPPORTED_DIR_IMPORT`, then
     `ERR_MODULE_NOT_FOUND` after the first fix; now resolves cleanly and
     exposes `{ ChatDescriber }` as expected.
   - Strict `NodeNext` TypeScript typecheck importing
     `ChatDescriber` from the same facade path — passes with no errors.
4. **CLI build** — unchanged, 12.69 MB bundle.
5. **Both boundary-check scripts** — `boundary-check.mjs` and
   `runtime-boundary-check.mjs` both report `violations: []`;
   `inputCount` 4137→4138 (expected +1 for the new facade file, matching
   the pattern from prior batches).
6. **Targeted CLI vitest** (`useChat.test.ts`, `useChat.stream.test.ts`,
   `useChat.shellMode.test.ts`) — 12/12 pass.

## Implication for remaining Item 4 groups

Any Core module with a bare/extensionless relative import (especially one
pointing at a directory/barrel, e.g. `.`/`..`) will hit this same class of
failure once wrapped in a facade and exercised by a genuine strict-ESM
consumer. Recommended going forward: before starting each remaining group
(`globalContext`, `editing`, `security`, `paths`, `messageContent`, `uri`,
`llm/calculateRequestCost`, `llm/getAdjustedTokenCount`), grep the target
file's own `^import` lines for bare specifiers and pre-emptively apply the
same fix pattern (explicit extension, or `import type` where usage is
type-only) as part of that batch's validation pass — do not assume the
`errors`/`messageConversion` "facade-only" pattern will always be
sufficient.
