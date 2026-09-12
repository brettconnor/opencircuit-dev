# CLI/Core Entry-Point Inventory

## CLI

| Surface                      | Source or declaration                  | Generated path                 | Status                                         |
| ---------------------------- | -------------------------------------- | ------------------------------ | ---------------------------------------------- |
| CLI implementation           | `extensions/cli/src/index.ts`          | `extensions/cli/dist/index.js` | Keep                                           |
| Programmatic package entry   | `extensions/cli/package.json` `main`   | `dist/index.js`                | Keep and document                              |
| Type declarations            | `extensions/cli/package.json` `types`  | `dist/index.d.ts`              | Declared, but missing after the standard build |
| `cn` executable              | `extensions/cli/package.json` `bin.cn` | `dist/cn.js`                   | Keep                                           |
| Executable wrapper generator | `extensions/cli/build.mjs`             | Writes `dist/cn.js`            | Keep                                           |
| Development launch path      | `npm run dev`                          | `tsx src/index.ts`             | Keep for development                           |
| Supported built launch path  | `npm start`                            | `node dist/cn.js`              | Keep                                           |
| Shell installer              | `extensions/cli/scripts/install.sh`    | Installs the CLI               | Defer with packaging                           |
| PowerShell installer         | `extensions/cli/scripts/install.ps1`   | Installs the CLI               | Defer with packaging                           |

The build starts from `src/index.ts`, bundles to `dist/index.js`, and generates `dist/cn.js`. The wrapper imports `runCli` from the bundle and invokes it. Running `dist/index.js` directly imports the implementation but does not provide the package's supported executable path.

`npm run build` does not invoke `build:tsc`, so a clean standard build does not create the declared `dist/index.d.ts`. Running `npm run build:tsc` separately succeeds but emits `dist/extensions/cli/src/index.d.ts`. Wiring declaration generation to the declared package path is RED work.

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
| `types`                  | Not declared                               | `core/package.json`               |
| `exports`                | Not declared                               | `core/package.json`               |
| Root declarations        | `core/index.d.ts` exists                   | Source tree                       |
| Built runtime root       | `core/dist/core.js`                        | `npm run build`                   |
| Public standalone import | Unavailable as a declared package contract | Package metadata and build output |

The CLI resolves `core` through build and TypeScript aliases rather than a declared Core package export:

- `extensions/cli/tsconfig.json` maps `core` and `core/*` to `core/dist`.
- `extensions/cli/build.mjs` aliases `core` to the repository's `core` directory.
- Production code imports both `core`/`core/index.js` and internal `core/*` paths.

The public Core fixture is therefore recorded as a target-architecture gap rather than a passing baseline test.

## Config YAML Executable

| Surface       | Source                            | Generated path                     | Decision               |
| ------------- | --------------------------------- | ---------------------------------- | ---------------------- |
| `config-yaml` | `packages/config-yaml/src/cli.ts` | `packages/config-yaml/dist/cli.js` | Investigate during RED |

The executable accepts a configuration file path and is separate from the `cn` product entry point. Removal requires a repository and publication search plus package tests.
