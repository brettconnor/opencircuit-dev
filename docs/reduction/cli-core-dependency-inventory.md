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
| `gui`                          | Closed — already absent            | N/A: 0 files tracked under `gui/`; directory does not exist in this checkout | Confirmed via `git ls-files \| grep '^gui/'` (0 results) and filesystem search; root `package.json` `tsc:watch`/`tsc:watch:gui` referenced the nonexistent path and has been removed | Stale script reference removed; no source removal was possible or necessary |
| `extensions/vscode`            | Defer                              | Editor product is outside the primary CLI closure                    | Keep until separate product decision; boundary checks must remain clean                        | No closure references found                                |
| `binary`                       | Defer                              | Packaging is outside the initial runtime closure                     | Trace release/install workflows before removal                                                 | No bundle/runtime references found                         |
| `packages/continue-sdk`        | Remove from local retained closure | CLI uses the installed `@continuedev/sdk`, not the local source tree | Remove local tree in a trial branch; rerun CLI install/build/workflow                          | No local bundle inputs or retained config references found |
| `docs-site`                    | Defer                              | Not required by CLI runtime but may be required for publication      | Review publication ownership before removal                                                    | No closure references found                                |
| `docs`                         | Defer                              | Contains product, legal, and reduction evidence                      | Separate generated/product docs from required notices and plans                                | Not a runtime dependency                                   |
| `core/vendor` and model assets | Defer                              | Runtime asset loading has not been disproved for all Core workflows  | Trace asset paths and run the controlled workflow after removal                                | Not approved for first RED batch                           |
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
