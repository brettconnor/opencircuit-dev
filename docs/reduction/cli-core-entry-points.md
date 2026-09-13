# CLI/Core Entry-Point Inventory

## CLI

| Surface                      | Source or declaration                  | Generated path                 | Status                                         |
| ---------------------------- | -------------------------------------- | ------------------------------ | ---------------------------------------------- |
| CLI implementation           | `extensions/cli/src/index.ts`          | `extensions/cli/dist/index.js` | Keep                                           |
| Programmatic package entry   | `extensions/cli/package.json` `main`   | `dist/index.js`                | Keep and document                              |
| Type declarations            | `extensions/cli/package.json` `types`  | `dist/index.d.ts`              | Declared and emitted by standard build         |
| `cn` executable              | `extensions/cli/package.json` `bin.cn` | `dist/cn.js`                   | Keep                                           |
| Executable wrapper generator | `extensions/cli/build.mjs`             | Writes `dist/cn.js`            | Keep                                           |
| Development launch path      | `npm run dev`                          | `tsx src/index.ts`             | Keep for development                           |
| Supported built launch path  | `npm start`                            | `node dist/cn.js`              | Keep                                           |
| Shell installer              | `extensions/cli/scripts/install.sh`    | Installs the CLI               | Defer with packaging                           |
| PowerShell installer         | `extensions/cli/scripts/install.ps1`   | Installs the CLI               | Defer with packaging                           |

The build starts from `src/index.ts`, bundles to `dist/index.js`, and generates `dist/cn.js`. The wrapper imports `runCli` from the bundle and invokes it. Running `dist/index.js` directly imports the implementation but does not provide the package's supported executable path.

Historically during the Phase 0 baseline, `npm run build` did not invoke `build:tsc`, so a clean build did not create the declared `dist/index.d.ts`. In Phase 6 publication corrections, `extensions/cli/package.json` wires `build:tsc` (`tsc -p tsconfig.build.json`) with `emitDeclarationOnly: true`, ensuring standard clean builds reliably produce `dist/index.d.ts` and submodule declarations.

### Registered commands

The source registers:

- Default chat command.
- `ls`.
- Hidden `serve`.
- `checks`.
- `review`.
- Internal review-worker handling.

## Core

| Surface                  | State                                      | Evidence                          |
| ------------------------ | ------------------------------------------ | --------------------------------- |
| Package name             | `@continuedev/core`                        | `core/package.json`               |
| `main`                   | Not declared                               | `core/package.json`               |
| `types`                  | `dist/index.d.ts`                          | `core/package.json`; build copies `index.d.ts` to `dist/index.d.ts` |
| `exports`                | Not declared                               | `core/package.json`               |
| Root declarations        | `core/index.d.ts` exists                   | Source tree                       |
| Built runtime root       | `core/dist/core.js`                        | `npm run build`                   |
| Public standalone import | Unavailable as a declared package contract | Package metadata and build output |

`core/package.json` declares `types: dist/index.d.ts`, which is populated when `core/index.d.ts` is copied to `core/dist/index.d.ts` by `npm run build`. However, `main` and `exports` remain undeclared. The CLI resolves `core` through build and TypeScript aliases rather than a declared Core package export:

- `extensions/cli/tsconfig.json` maps `core` and `core/*` to `core/dist`.
- `extensions/cli/build.mjs` aliases `core` to the repository's `core` directory.
- Production code imports both `core`/`core/index.js` and internal `core/*` paths.

The public Core fixture is therefore recorded as a target-architecture gap rather than a passing baseline test.

## Config YAML Executable

| Surface       | Source                            | Generated path                     | Decision               |
| ------------- | --------------------------------- | ---------------------------------- | ---------------------- |
| `config-yaml` | `packages/config-yaml/src/cli.ts` | `packages/config-yaml/dist/cli.js` | Investigate during RED |

The executable accepts a configuration file path and is separate from the `cn` product entry point. Removal requires a repository and publication search plus package tests.
