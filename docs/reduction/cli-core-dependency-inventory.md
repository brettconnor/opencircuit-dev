# CLI/Core Dependency Inventory

## Retained Product Closure

| Surface                      | Direct evidence                                                         | Role                                 | Decision                       | Disconfirming check                                          |
| ---------------------------- | ----------------------------------------------------------------------- | ------------------------------------ | ------------------------------ | ------------------------------------------------------------ |
| `extensions/cli`             | Product `bin.cn`, build, smoke, and headless workflow                   | User-facing product                  | Keep                           | CLI build and invocation must pass                           |
| `core`                       | CLI aliases and 63 production imports                                   | Shared implementation and types      | Keep                           | Remove only after imports are replaced                       |
| `packages/config-types`      | Core, Config YAML, Fetch, and OpenAI adapter manifests; CLI build alias | Shared configuration types           | Keep for Phase 0               | Remove alias/build locally and rerun all retained checks     |
| `packages/config-yaml`       | Core and CLI manifest references; 135 bundle inputs                     | Configuration loading and parsing    | Keep                           | Remove locally and rerun config plus CLI workflow tests      |
| `packages/fetch`             | Core manifest and CLI build alias; 42 bundle inputs                     | Node-aware HTTP implementation       | Keep                           | Remove locally and rerun Core/CLI build and workflow         |
| `packages/llm-info`          | Core manifest and CLI build alias                                       | Declared model metadata dependency   | Keep for Phase 0               | Remove alias/dependency locally and rerun Core/CLI checks    |
| `packages/openai-adapters`   | Core and CLI manifest references; 784 bundle inputs                     | Provider normalization and transport | Keep                           | Remove locally and rerun adapter and headless workflow tests |
| `packages/terminal-security` | Core and CLI manifest references; 5 bundle inputs                       | Terminal command policy              | Keep                           | Remove locally and rerun CLI tools and workflow tests        |
| Root package metadata        | Root TypeScript and formatting commands                                 | Repository tooling                   | Keep until scripts are reduced | Remove unrelated scripts locally and run retained validation |

The Config Types and LLM Info local source trees contribute no files to the current CLI esbuild metadata. They remain in the approved Phase 0 scope because they are declared or aliased dependencies. Their necessity must be tested rather than inferred.

## Non-Retained or Deferred Surfaces

| Surface                        | Decision                           | Removal hypothesis                                                   | Disconfirming check                                                                            | Phase 0 result                                             |
| ------------------------------ | ---------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `extensions/intellij` CI (JetBrains) | Remove (Phase 2a, Batch 1 of 3) | Owner has confirmed no plans to support the JetBrains plugin (see `docs/planning/phase2a-cut-jetbrains.md`) | Removed `.github/workflows/jetbrains-release.yaml`, `.github/actions/run-jetbrains-tests/action.yml`, and `.github/workflows/submit-github-dependency-graph.yml` (Gradle/IntelliJ dependency graph submission, 100% JetBrains-specific); removed the `jetbrains-tests` job from `pr-checks.yaml` and its entry in `require-all-checks-to-pass`; removed the `create-jetbrains-release` job from `auto-release.yml`. Confirmed zero remaining `jetbrains`/`intellij` references anywhere under `.github/` after the change. CLI build and both boundary checks re-verified clean (4135 bundle inputs, unchanged, `violations: []`) | CI-only change, no retained-closure impact; plugin source removal (item 2) and metadata/docs cleanup (item 3) remain to be executed under the Phase 2a plan |
| `gui`                          | Closed — already absent            | N/A: 0 files tracked under `gui/`; directory does not exist in this checkout | Confirmed via `git ls-files \| grep '^gui/'` (0 results) and filesystem search; root `package.json` `tsc:watch`/`tsc:watch:gui` referenced the nonexistent path and has been removed. Batch F additionally removed the standalone `gui-checks` CI job from `.github/workflows/pr-checks.yaml` (typecheck/lint/test against the nonexistent `gui/`, which would fail if ever run) and its entry in `require-all-checks-to-pass`. **Not removed:** `.github/actions/build-vscode-extension/action.yml` and `extensions/vscode/scripts/prepackage.js` still reference `gui/`/`gui/dist` as part of the deferred VS Code packaging pipeline (the JetBrains half of this — `run-jetbrains-tests` and `jetbrains-release.yaml` — was removed under Phase 2a) — this is a pre-existing break in an already-`Defer`red VS Code surface, not caused by RED work, and remains flagged as `Unknown` pending a dedicated VS-Code-only packaging-pipeline experiment | Stale script reference and stale standalone CI test job removed; deferred VS Code packaging-pipeline gui/dist dependency flagged as `Unknown`, requires its own experiment |
| `extensions/vscode`            | Defer                              | Editor product is outside the primary CLI closure                    | Keep until separate product decision; boundary checks must remain clean                        | No closure references found                                |
| `binary`                       | Defer                              | Packaging is outside the initial runtime closure                     | Trace release/install workflows before removal                                                 | No bundle/runtime references found                         |
| `packages/continue-sdk`        | Remove from local retained closure | CLI uses the installed `@continuedev/sdk`, not the local source tree | Remove local tree in a trial branch; rerun CLI install/build/workflow                          | No local bundle inputs or retained config references found |
| `docs-site`                    | Defer (confirmed)                  | Not required by CLI runtime but is a live, CI-deployed publication surface | `.github/workflows/docs-gh-pages.yml` builds and deploys `docs-site/**` (and `docs/**`) to GitHub Pages on every push to `main`; removal would break an active publication pipeline, not just an inert asset | Real, active reference found; excluded from any removal experiment |
| `media`                         | Defer (confirmed); `media/readme.png` and `media/run-continue-intellij.png` removed | Root README embeds the one remaining image directly | `README.md` embeds `media/github-readme.png`; `media/readme.png` was unreferenced anywhere in tracked `.md`/`.json`/`.ts`/`.tsx`/`.yml` files (distinct from the separately tracked `extensions/vscode/media/readme.png`, which is referenced by `extensions/vscode/README.md`) and was removed; `media/run-continue-intellij.png`'s sole referrer, `extensions/intellij/CONTRIBUTING.md`, was deleted under Phase 2a batch 2 (JetBrains plugin source removal), leaving it with 0 references, so it was removed in the same batch | Directory kept for its 1 remaining real reference; the 2 unreferenced files removed with no retained-closure impact |
| `extensions/intellij`          | Remove (Phase 2a, Batch 2 of 3)    | Owner has confirmed no plans to support the JetBrains plugin (see `docs/planning/phase2a-cut-jetbrains.md`); zero functional cross-references from the retained CLI/Core/VS Code closure into `extensions/intellij/` | Removed all 124 tracked files under `extensions/intellij/`. Cleaned up 2 stale doc comments referencing now-deleted Kotlin file paths in `core/protocol/passThrough.ts` and `core/rules.md`. Discovered and fixed 3 genuine functional breaks directly caused by the deletion, in the VS Code build/packaging scripts that previously copied build artifacts into `extensions/intellij/`: `extensions/vscode/scripts/utils.js`'s `buildGui()` (removed the JetBrains webview-copy block, which read `extensions/intellij/src/main/resources/webview/index.html` — a hard runtime break since that path no longer exists), `extensions/vscode/scripts/generate-copy-config.js`'s `copyConfigSchema()` (removed the block copying `config_schema.json`/`continue_rc_schema.json` into `extensions/intellij/src/main/resources/`), and `extensions/vscode/scripts/prepackage.js` (removed a duplicate inline JetBrains webview-copy block). Removed the now-orphaned `media/run-continue-intellij.png` (see `media` row above). Left the shared `core/config/types.ts` `IdeType = "vscode" \| "jetbrains"` enum and `GlobalContext.hasDismissedConfigTsNoticeJetBrains` untouched — these are core-level, IDE-agnostic infrastructure tied to persisted user config/migration state, explicitly out of Phase 2a's scope (plugin source removal only, not a broader core IDE-type refactor). Left 2 generic illustrative comments (`binary/build.js`, `core/indexing/chunk/ChunkCodebaseIndex.ts`) that mention "intellij" conceptually but don't reference the deleted directory. Re-verified: `core` typechecks clean; CLI build clean (12.69 MB bundle); both `boundary-check.mjs` and `runtime-boundary-check.mjs` pass with `violations: []` (4135 bundle inputs, unchanged) | Plugin source and its 3 dependent VS-Code-build-script breakages fully removed; core `IdeType` enum and 2 generic comments intentionally deferred as out-of-scope; metadata/contributor-docs cleanup (item 3) remains |
| `docs`                         | Defer                              | Contains product, legal, and reduction evidence                      | Separate generated/product docs from required notices and plans                                | Not a runtime dependency                                   |
| `core/vendor` and model assets | Defer (confirmed load-bearing)     | Vendored `@xenova/transformers` avoids the native `sharp` dependency  | `core/llm/llms/TransformersJsEmbeddingsProvider.ts` directly imports `../../vendor/modules/@xenova/transformers/src/transformers.js`; wired into `core/config/load.ts`, `core/config/yaml/loadYaml.ts`, and `core/indexing/docs/DocsService.ts` | Real, load-bearing runtime reference found; not a removal candidate |
| `docs/images` (orphaned subset) | Removed (Batch E, 182 of 244 files) | Legacy generated docs images left over from a prior docs build/migration, no longer linked from any current `.mdx`/`.md` content | Basename-matched every tracked `docs/images/*` file against the full text of every tracked `.mdx`/`.md`/`.ts`/`.tsx`/`.js`/`.jsx`/`.json` file; 182 files (141.3 MB) had zero matches anywhere; `docs-site/scripts/copy-doc-images.ts` bulk-copies the whole directory at build time regardless of linkage, so their presence was pure build bloat, not a functional dependency; the remaining 62 files are genuinely referenced via `docs-site/lib/docs.ts`'s `/images/...` path rewrite and were kept | Removed with no retained-closure impact; `docs/images` reduced from 244 files/212 MB to 62 files/71 MB |
| `sync`                          | Defer                               | Rust crate is a real, load-bearing dependency of the VS Code extension, not an unrelated demo/prototype | `extensions/vscode/package.json`'s `build:rust` script invokes `cargo build --manifest-path ../../sync/Cargo.toml`; removal would break the deferred `extensions/vscode` build | Real reference found; excluded from Batch C removal, deferred with `extensions/vscode` |
| `eval`                          | Removed (Batch C)                  | Placeholder scaffold: only `eval/.gitignore` (ignoring `repos`) was tracked; no runtime, build, or CI references | Repo-wide grep for `eval/` matched only unrelated `eval(`-named functions (e.g. `evaluateTerminalCommandSecurity.ts`); no path references found | Removed with no retained-closure impact |
| `skills`                        | Removed (Batch C)                  | Distributable example skill package (`cn-check`), not consumed by the CLI's runtime skills loader | `extensions/cli/src/util/loadMarkdownSkills.ts` only reads from `.continue/skills`, `.claude/skills`, or `env.continueHome/skills` — never the repo-root `skills/` directory | Removed with no retained-closure impact |
| `manual-testing-sandbox`        | Removed (Batch C)                  | Multi-language manual/scratch testing directory (49 files, own `readme.md`) unrelated to automated retained closure | Vitest references in `core/llm/rules/nestedDirectoryRules.vitest.ts` and `core/autocomplete/filtering/streamTransforms/filterCodeBlock.vitest.ts` use the path only as in-memory string fixtures, not real file reads; `.vscode/launch.json` debug configs reference it only as an optional local dev scratch cwd | Removed with no retained-closure impact; `.gitignore` entries for developer-recreated local content left intact |
| `docs-search-dark-mode-fix.png` | Removed (Batch C)                  | Stray root-level image asset with no functional purpose                | Repo-wide grep found zero references anywhere in tracked files                                | Removed with no retained-closure impact |

## First RED Batch

The first RED batch is `RED-001-core-lockfile-integrity`. It is remediation, not product deletion.

Hypothesis: regenerating `core/package-lock.json` from the current Core manifest restores `npm ci` without unintentionally changing the retained runtime dependency set.

Disconfirming check:

1. Change only `core/package-lock.json`, dependency metadata proven necessary, and corresponding evidence.
2. Remove `core/node_modules`.
3. Run `cd core && npm ci --ignore-scripts --no-audit --no-fund`.
4. Confirm the install leaves tracked files unchanged.
5. Run Core and CLI typechecks/builds, all characterization tests, and all boundary checks.
6. Revert RED-001 if dependency changes or validation results are not understood and approved.

No product-surface deletion is authorized until RED-001 passes and a new immutable checkpoint is recorded. The GUI remains the first proposed deletion experiment after that checkpoint.

## Batch G: workspace and metadata cleanup

Experiment order item 7 (final item): workspace and metadata cleanup.

Findings:

- `CONTRIBUTING.md`'s "VS Code" contributing section (`Debugging`, `Theme
  Colors`, `Adding Models`) contains multiple stale references to `gui/`
  (e.g. `gui/src/styles/theme.ts`, `gui/src/pages/AddNewModel/...`) left over
  from before `gui/` was removed from this checkout. Given the size and
  narrative nature of this content (contributor-facing instructions spanning
  several sections), a full rewrite was judged out of scope for a narrow,
  reversible RED experiment. Instead, added a single explicit disclaimer at
  the top of the VS Code section noting the local `gui/` source tree no
  longer exists and that the `gui`-specific instructions are stale pending a
  dedicated packaging-pipeline experiment (see the `gui` row's `Unknown`
  packaging-pipeline note above). No content deleted.
- `worktree-config.yaml`'s `cowCopyTargets` listed `app/node_modules`, but
  `app/` has never existed anywhere in this repository's git history (`git
  log --all -- app` returns no results) — confirmed template/boilerplate
  cruft from whatever scaffold generated this file, not a real workspace
  path. Removed the dead entry; the remaining `core/node_modules`,
  `extensions/*/node_modules`, `packages/*/node_modules`, etc. entries all
  correspond to real, still-existing paths.

No CLI/Core source touched; both changes are documentation/tooling-metadata
only.
