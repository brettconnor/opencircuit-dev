# Phase 3 — Item 0 Evidence: Package Identity, Resolution, and Artifact Mapping

**Status:** Complete (evidence-gathering only; no source changes made)
**Produced for:** `docs/planning/phase3-core-boundary_v1.md`, Required preflight ("Item 0")
**Method:** Static config inspection, `tsc --traceResolution`, esbuild bundle-metafile inspection, isolated esbuild resolution probe, clean `core` rebuild, `npm pack --dry-run`, repo-wide consumer grep.

## 1. Package identity

- `core/package.json` declares `name: "@continuedev/core"`, `version: "1.1.0"`.
- No `main`, `types`, or `exports` field is present (confirms BND-002).
- No `files` allowlist is present. `npm pack --dry-run` on `core` produces a **4283-file, 4.0 MB tarball** (17.4 MB unpacked) containing source `.ts`, vendored `node_modules` copies (`vendor/modules/@xenova/transformers/...`), test configs, etc. — i.e., today's `core` package has no defined public surface at the packaging level either.

## 2. How each consumer actually declares the dependency

All three consumers below declare `core` as a real dependency, but **only one bypasses it**:

| Consumer | package.json | Actual dependency used at build time? |
|---|---|---|
| `extensions/cli` | `"core": "file:../../core"` | **No** — `build.mjs` esbuild `alias` overrides resolution to `resolve(__dirname, "../../core")` (the **source directory**), bypassing `node_modules` and `dist` entirely. |
| `binary` | *(uses relative fs paths to `../core`, no esbuild alias for `core`)* | Standard Node/esbuild module resolution (no alias in `binary/build.js`'s esbuild config). |
| `extensions/vscode` | `"core": "file:../../core"` | Standard Node/esbuild module resolution (no alias in `scripts/esbuild.js`; only `external: ["vscode", "esbuild", "./xhr-sync-worker.js"]`). |

**Finding:** the CLI is the *only* consumer using a custom source-directory alias. `binary` and `extensions/vscode` rely on ordinary `file:` dependency + `node_modules` resolution. This directly confirms review finding #5 ("CLI is the only consumer" was unproven) — CLI is not the only consumer, but it *is* the only one with nonstandard resolution. Any Item 1+ classification/repair must account for all three consumers, not just CLI.

(Note: `binary/node_modules` and `extensions/vscode/node_modules` are not installed in this checkout, so their live resolution could not be executed end-to-end; this is a residual gap, see "Residual gaps" below.)

## 3. TypeScript vs. esbuild resolution mismatch (CLI)

- `extensions/cli/tsconfig.json` declares `paths`: `"core": ["../../core/dist/index.js"]`, `"core/*": ["../../core/dist/*"]` — intends to resolve against `core/dist`.
- `extensions/cli/build.mjs` esbuild `alias` maps bare `core` → `../../core` (the **source directory**), inconsistent with the tsconfig target and inconsistent with how sibling packages (`@continuedev/config-yaml`, `@continuedev/fetch`) are aliased to their `dist/index.js`.
- `npx tsc --traceResolution --noEmit` on the CLI shows: the `dist/index.js` substitution is attempted, the file is missing, and TypeScript **silently falls back** to loading `core/index.d.ts` directly from the **source tree** (not `dist`).
- esbuild's bundle metafile (`extensions/cli/dist/meta.json`) confirms deep imports (e.g. `core/util/paths.js`) resolve to **source `.ts` files** (`../../core/util/paths.ts`) at bundle time — bypassing `dist` entirely, consistent with the alias.

**Conclusion:** the CLI is currently built against Core's **TypeScript source**, not its compiled `dist` output, for every import it makes (both "Population A" root imports and "Population B" deep imports).

## 4. Population A ("root/declaration" imports) are type-only in practice — critical finding

All 29 CLI files classified as `root-or-declaration-import` in `docs/reduction/artifacts/phase0/boundaries/static-and-bundle.json` were individually inspected:

- **27 of 29** use explicit `import type { ... } from "core"` / `"core/index.js"` syntax.
- The remaining **2** (`extensions/cli/src/commands/chat.ts`, and one initially mis-scanned by a single-line grep, `session.ts`, which is also `import type` once its multi-line form is read correctly) either use `import type` outright or — in `chat.ts`'s case — import `ChatHistoryItem`/`Session` with plain `import { ... }` syntax, but **every usage in that file is a type position** (return-type annotations, variable type annotations, interface fields), never a runtime value. TypeScript/esbuild's unused-import elision removes this import at build time.
- **Empirical confirmation:** `extensions/cli/dist/meta.json` contains **zero** bundle inputs matching `../../core/index.ts`, `../../core/index.js`, `../../core/core.ts`, or `../../core/core.js` — i.e., **no root/declaration import from Core ever resolves at bundle/runtime time.** They only exist for `tsc`'s type-checking pass, which (per §3) resolves them via a source-tree fallback onto `core/index.d.ts`, completely bypassing `core/dist`.
- **Isolated confirmation:** an isolated esbuild probe (`import { X } from "core"` as a *value* import, entry point outside the repo, same alias config) fails to resolve with `Could not resolve "core"` — proving that if any of these 29 imports *were* value imports, the real CLI build would already be broken. Their survival today is entirely because they are type-only and get erased before resolution is attempted.

**Implication for the plan:** v0's Item 1 (declare `exports` map covering the root import) targeted a population that has **zero live runtime dependency** on `core`'s root entry point today. Any repair to "Population A" is really about fixing `tsc`'s type resolution path (i.e., producing a real `core/dist/index.d.ts` / declaring `types` in `core/package.json`), not about runtime `exports`.

## 5. Clean-build artifact reality

- `core`'s build script is `tsc -p ./tsconfig.npm.json` (`outDir: dist`, `declaration: true`, `declarationMap: true`).
- A clean `rm -rf dist && npm run build` was executed. Result: **no `dist/index.js` and no `dist/index.d.ts` are produced.** The only root-level build artifact is `dist/core.js` / `dist/core.d.ts` (from `core/core.ts`).
- `core/index.d.ts` is a **hand-authored, source-tree-only** file with no corresponding `.ts` implementation module — it is never copied or regenerated into `dist` by the build. This is the file TypeScript's fallback resolution (§3) is silently loading — meaning today's "declared" root type surface is whatever `core/index.d.ts` happens to hand-declare, not anything derived from a real compiled entry point.

## 6. Repo-wide consumer scan

`git grep -lE 'from ["\']core(/|["\'])|require\(["\']core(/|["\'])' -- ':!node_modules' ':!docs/reduction/artifacts' ':!core'` returns matches in three trees only: `extensions/cli/**`, `binary/**`, `extensions/vscode/**` (plus one doc reference in `.continue/rules/dev-data-guide.md`, not a code consumer). No other package in the repo imports `core`.

## Summary evidence table (per v1's required format)

| Question | Evidence |
|---|---|
| What is Core's declared package identity? | `@continuedev/core`, no `main`/`types`/`exports`/`files` |
| What does CLI's `tsconfig.json` intend to resolve `core` to? | `core/dist/index.js` (missing) / `core/dist/*` |
| What does CLI's esbuild alias actually resolve `core` to? | `../../core` source directory (not `dist`) |
| Does `core/dist/index.js` exist after a clean build? | No — only `core/dist/core.js`/`core.d.ts` |
| How does `tsc` resolve bare `core` given the missing target? | Silent fallback to source-tree `core/index.d.ts` |
| How does esbuild resolve CLI's deep imports (e.g. `core/util/paths.js`)? | To source `.ts` files under `../../core`, not `dist` |
| Are CLI's 29 root/declaration imports live at runtime? | No — all are type-only; 0 appear in the bundle's inputs |
| Is CLI the only consumer of `core`? | **No** — `binary` and `extensions/vscode` also depend on it, via standard `file:` + `node_modules` resolution (no alias) |
| What would a `core` npm tarball actually contain today? | 4283 files incl. source, vendored deps, tests — no `files` allowlist |

## Residual gaps (not required for Item 0 sign-off but noted for Item 1+)

- `binary/node_modules` and `extensions/vscode/node_modules` are not installed in this checkout, so their live (as opposed to config-derived) resolution behavior was not directly executed/traced. Config inspection (no esbuild alias present in either) is strong but not a substitute for a live trace; Item 1 should confirm with a real install if feasible.
- Node's own default-resolver behavior for a fully external (outside-repo) consumer of `@continuedev/core` was not separately fixture-tested (the isolated esbuild probe covers the CLI's alias config, not a from-scratch Node `require.resolve`/ESM resolution test). Low priority given `binary`/`vscode` already demonstrate the real in-repo standard-resolution case.

## Exit condition (per v1)

For every current consumer, we can now state exactly what specifier, artifact path, and resolver is in effect:

- **CLI**: specifier `core`/`core/*` → esbuild alias → **source directory** (`../../core/**/*.ts`), bypassing `node_modules` and `dist`; `tsc` resolves the bare specifier via **source-tree fallback** to `core/index.d.ts` (also bypassing `dist`) because the `paths`-declared `dist/index.js` target doesn't exist.
- **binary / vscode**: specifier `core` → standard Node/esbuild resolution → `node_modules/core` (`file:` link) → **Core's package root**, which has no `main`, so bare-specifier value resolution would fail; observed imports from these consumers are either type-only or use explicit deep subpaths that resolve directly against real files regardless of any `main`/`exports` declaration.

Item 0 is complete. Per the plan's approval gate, no `core/package.json` metadata change, import-specifier change, alias change, or module-layout change is authorized yet — proceed to Item 1 (classify all imports, across all three consumers) next.
