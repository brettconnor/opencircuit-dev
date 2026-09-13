# Phase 3 — Item 4 Evidence: Errors Group Migration (First Subpath Group)

**Status:** Complete for the `errors` group (first of several planned groups; other groups deferred to later batches)
**Produced for:** `docs/planning/phase3-core-boundary_v1.md`, "Item 4 — migrate and expose one approved subpath group at a time"
**Depends on:** Item 2's proposal (`docs/reduction/artifacts/phase3/item2-evidence.md`), which proposed `@continuedev/core/errors` for `core/util/errors.js`

## What changed

- **New file `core/errors.ts`** — a facade: `export * from "./util/errors.js";`. This is a real source file compiled by Core's existing build (`tsc -p ./tsconfig.npm.json`), producing `dist/errors.js` and `dist/errors.d.ts`. No `package.json` `exports` map was added — deliberately, per Item 3's "do not add all deep exports yet" and to avoid the risk (discovered during this validation) that adding an `exports` field would immediately break every other currently-working deep import for `binary`/`extensions/vscode`, which rely on plain filesystem-based subpath resolution with no `exports` field present today.
- **Migrated 15 CLI import sites** (across `stream/streamChatResponse.helpers.ts` and 10 files under `tools/`, including their `.test.ts` counterparts) from `"core/util/errors.js"` to `"core/errors.js"`. This is the only source change in the CLI; no other logic touched.
- **The old path (`core/util/errors.js`) remains valid** — it was not deleted or blocked. Per the plan ("retain the old path only as a time-limited compatibility export if needed... remove the old compatibility path only in a separately approved batch"), removal is deferred to a later, separately-approved batch.

## Why `export * from "./util/errors.js"` (extensioned) and not `"./util/errors"`

The first attempt used an extensionless specifier (matching the convention already used everywhere else in `core`, e.g. `core/core.ts`'s internal imports, and `core/index.d.ts`'s internal imports). This compiled successfully under Core's own `tsconfig.npm.json` (`moduleResolution: "Node"`, classic resolution, which does not require extensions), but **failed** when validated against a strict-`NodeNext` external consumer:
- Runtime `import("@continuedev/core/dist/errors.js")` failed with `ERR_MODULE_NOT_FOUND` for `.../dist/util/errors` (no extension).
- TypeScript typecheck under `moduleResolution: "NodeNext"` failed with `TS2305: has no exported member` because it could not resolve the re-export's target.

This is a **pre-existing, repo-wide characteristic of Core's build**, not something specific to this facade — `core/dist/core.js`'s own relative imports (e.g. `import { CompletionProvider } from "./autocomplete/CompletionProvider"`) and `core/index.d.ts`'s internal imports (e.g. `from "./indexing/CodebaseIndexer"`) are equally extensionless. Core's build has never been validated against a strict-ESM external consumer before Item 3/4, so this gap was previously invisible. Fixing it repo-wide (adding `.js` extensions to every relative import across ~500+ Core source files) is out of scope for Item 4 and is **not required for the errors group** — it only matters for files whose re-export chain is directly exercised by an external strict-ESM consumer.

**Fix applied (scoped to this file only):** wrote the facade's own specifier with an explicit `.js` extension: `export * from "./util/errors.js"`. TypeScript, even under `moduleResolution: "Node"`, preserves an explicitly-written extension verbatim in its output, so this one file's compiled output is strict-ESM-correct without changing Core's tsconfig or touching any other file.

**Residual finding for later items:** the same extensionless-import gap likely affects other facades if/when they're added (Item 4's later groups) or if Item 5+ ever needs `dist/core.js`/`dist/index.d.ts` themselves to satisfy strict ESM. Recommend each subsequent facade file follow the same explicit-extension convention used here; a repo-wide fix (if ever needed) should be scoped as its own investigation, not bundled into subpath migrations.

## Validation performed (per Item 4 + the plan's required package-consumer-validation sequence)

1. **Clean Core build**: `rm -rf dist && npm run build` → `dist/errors.js` (523 B) and `dist/errors.d.ts` produced.
2. **Package tarball**: `npm pack` → tarball builds successfully, includes `dist/errors.js`/`.d.ts`.
3. **Isolated external fixture** (`/tmp/core-consumer-fixture-errors2`, outside the repo, not committed): installed the tarball via a `file:` dependency.
4. **JS runtime import**: `import("@continuedev/core/dist/errors.js")` resolves; `new ContinueError(...)` behaves correctly (`instanceof Error` true, `.reason`/`.message` correct).
5. **TypeScript typecheck** under strict `NodeNext`: `import { ContinueError, ContinueErrorReason } from "@continuedev/core/dist/errors.js"` typechecks with zero errors.
6. **Bundler-based consumption** (matching how every real consumer — CLI/binary/vscode — actually uses Core): a standalone esbuild bundle importing the same path also resolves and runs correctly.
7. **CLI build**: `npm run build` in `extensions/cli` succeeds; bundle size unchanged (12.69 MB).
8. **Retained-closure checks**: `tests/characterization/boundary-check.mjs` → `violations: []`, bundle input count 4135 → **4136** (the one new facade file, expected). `tests/characterization/runtime-boundary-check.mjs` → `violations: []`.
9. **Targeted CLI tests**: `vitest run src/tools/edit.test.ts src/tools/multiEdit.test.ts src/tools/skills.test.ts` (the three touched files with dedicated test suites) → 27/27 tests pass.

## Exit condition (per v1)

The `errors` group is proven stable and consumed correctly: it resolves for the CLI (via the existing alias mechanism, now pointed at a real facade file instead of reaching directly into `util/errors.js`), and independently for an out-of-source-tree package consumer via both plain Node ESM and a bundler, with a passing strict-TypeScript typecheck. Per the plan, `errors` is one approved API group proven stable — the process (facade file → migrate CLI imports → validate both consumer paths → retained-closure checks) is now established and repeatable for the remaining approved groups (`messageConversion`, `chatDescriber`, `globalContext`, `editing` [3-module group], `security`, `paths`, `messageContent`, `uri`, `llm/calculateRequestCost`, `llm/getAdjustedTokenCount`), which remain to be migrated in separate, individually-approved batches per Item 4's own instruction ("one approved API group... per batch").
