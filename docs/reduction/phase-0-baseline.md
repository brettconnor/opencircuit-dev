# Phase 0 CLI/Core Baseline

## Status

Phase 0 evidence was captured on `reduce/cli-core`.

| Reference          | Commit                                                                              |
| ------------------ | ----------------------------------------------------------------------------------- |
| Source baseline    | `phase0-source-baseline` -> `a96202f57d650a4e42cc747d705e4d0e0ea24bf5`              |
| Phase 0 completion | `phase0-cli-core-complete` -> created after this evidence is committed and reviewed |

RED must begin from `phase0-cli-core-complete`, not from the source baseline or an intermediate branch commit.

## Environment

| Item                           | Recorded value                                                 |
| ------------------------------ | -------------------------------------------------------------- |
| Date                           | 2026-09-12                                                     |
| Operating system               | Linux 6.8.0-124-generic                                        |
| Architecture                   | x86_64                                                         |
| Git                            | 2.43.0                                                         |
| Node.js used                   | 20.20.2                                                        |
| Repository Node.js pin         | 20.20.1 in `.node-version` and `.nvmrc`                        |
| npm                            | 10.8.2                                                         |
| npm cache                      | `/home/wolfy/.npm`                                             |
| npm registry                   | `https://registry.npmjs.org/`                                  |
| Install lifecycle policy       | `--ignore-scripts`                                             |
| Install audit/funding requests | Disabled with `--no-audit --no-fund`                           |
| Test credentials               | None                                                           |
| Provider network               | Disabled; the controlled workflow used a loopback HTTP fixture |
| Test home directories          | Temporary directories created by the CLI test helpers          |

The Node.js executable was one patch release newer than the repository pin. Package installation also reported engine warnings from development dependencies that require Node.js 22 or newer. These warnings did not prevent the retained package builds or tests.

## Source Measurements

Measurements were taken from an archive of `phase0-source-baseline`, excluding `.git` and ignored local artifacts.

| Measurement                 |                                      Value | Method                                              |
| --------------------------- | -----------------------------------------: | --------------------------------------------------- |
| Source commit               | `a96202f57d650a4e42cc747d705e4d0e0ea24bf5` | `git rev-parse phase0-source-baseline^{commit}`     |
| Tracked files               |                                      3,058 | `git ls-tree -r --name-only phase0-source-baseline` |
| Archived working-tree bytes |                                283,463,693 | `git archive` followed by `du -sb`                  |
| CLI bundle bytes            |                                 13,313,558 | `stat -c %s extensions/cli/dist/index.js`           |
| CLI bundle inputs           |                                      4,135 | `extensions/cli/dist/meta.json`                     |

The CLI bundle size and input count were measured after rebuilding the CLI from the source-baseline product tree with the recorded Node.js/npm environment. They are generated build-output measurements, not contents of the `git archive`.

## Install Matrix

All lockfiles use lockfile version 3. Commands were run in the listed order from a checkout without `node_modules` or retained-package `dist` directories.

| Package           | Working directory            | Lockfile                                       | Install command                                                          | Seconds | Result                                                      |
| ----------------- | ---------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------ | ------: | ----------------------------------------------------------- |
| Root tooling      | `.`                          | `package-lock.json`                            | `npm ci --ignore-scripts --no-audit --no-fund`                           |      10 | Pass                                                        |
| Config types      | `packages/config-types`      | `packages/config-types/package-lock.json`      | Same immutable command                                                   |       2 | Pass                                                        |
| Fetch             | `packages/fetch`             | `packages/fetch/package-lock.json`             | Same immutable command                                                   |      13 | Pass with engine warnings                                   |
| LLM info          | `packages/llm-info`          | `packages/llm-info/package-lock.json`          | Same immutable command                                                   |      11 | Pass with engine warnings                                   |
| Terminal security | `packages/terminal-security` | `packages/terminal-security/package-lock.json` | Same immutable command                                                   |       3 | Pass                                                        |
| Config YAML       | `packages/config-yaml`       | `packages/config-yaml/package-lock.json`       | Same immutable command                                                   |      20 | Pass with engine warnings                                   |
| OpenAI adapters   | `packages/openai-adapters`   | `packages/openai-adapters/package-lock.json`   | Same immutable command                                                   |      22 | Pass with engine warnings                                   |
| Core              | `core`                       | `core/package-lock.json`                       | Same immutable command                                                   |       4 | **Baseline failure: manifest and lockfile are out of sync** |
| Core fallback     | `core`                       | Not modified                                   | `npm install --package-lock=false --ignore-scripts --no-audit --no-fund` |     128 | Pass, non-immutable                                         |
| CLI               | `extensions/cli`             | `extensions/cli/package-lock.json`             | Immutable command                                                        |      47 | Pass                                                        |

Core's immutable install fails because the lockfile contains older Puppeteer-related versions and lacks packages required by the current manifest resolution. The exact failure is retained in `artifacts/phase0/install/core.log`. The non-locking fallback allowed characterization to continue without modifying `core/package-lock.json`; it is not accepted as an immutable install.

### Lockfile Integrity

Hashes were identical before and after installation.

| Lockfile                                       | SHA-256                                                            |
| ---------------------------------------------- | ------------------------------------------------------------------ |
| `package-lock.json`                            | `54c9f8a3e35e73b02290060586495e9e007f585abe2ac8ef0db30f53df0dfa53` |
| `core/package-lock.json`                       | `35f23f37405ac815ae71ad96f37878f504f9d6852eaf1f9ff550f8175aeca66d` |
| `extensions/cli/package-lock.json`             | `64293007cb4738bdd60e91821ad27531ed71d44268069ecdf50945e9a80622dd` |
| `packages/config-types/package-lock.json`      | `4a1180ce21a7ac1a5a5603e94ff69bad3eef75a0babeb45de75f7a5fe83c2933` |
| `packages/config-yaml/package-lock.json`       | `9e192574e1d60ea805fdd9915eb941a02e617650bc4b0533905910725df75f4c` |
| `packages/fetch/package-lock.json`             | `9f01ca63267efa8352a86d4591e001e73b4e505dbae7dc208fb557a418faa156` |
| `packages/llm-info/package-lock.json`          | `1af229ec319504eec08a2779e5e3e86637e0afd5dc410fc9d3528181f876488d` |
| `packages/openai-adapters/package-lock.json`   | `9219572b4c33d040afe31d1ff6ff9cf8a45ff91a0d44bd633447fbf6228448de` |
| `packages/terminal-security/package-lock.json` | `7fe7ed97dcc6fcc1ef707fb9d9659c1ef029117061935fa330bae4bbb8aeac7b` |

## Build and Typecheck Results

| Surface           | Command                                          | Seconds | Result                                                                 |
| ----------------- | ------------------------------------------------ | ------: | ---------------------------------------------------------------------- |
| Config types      | `cd packages/config-types && npm run build`      |       4 | Pass                                                                   |
| Fetch             | `cd packages/fetch && npm run build`             |       5 | Pass                                                                   |
| LLM info          | `cd packages/llm-info && npm run build`          |       2 | Pass                                                                   |
| Terminal security | `cd packages/terminal-security && npm run build` |       3 | Pass                                                                   |
| Config YAML       | `cd packages/config-yaml && npm run build`       |      10 | Pass                                                                   |
| OpenAI adapters   | `cd packages/openai-adapters && npm run build`   |      13 | Pass                                                                   |
| Core typecheck    | `cd core && npm run tsc:check`                   |      26 | Pass                                                                   |
| Core build        | `cd core && npm run build`                       |      35 | Pass                                                                   |
| CLI typecheck     | `cd extensions/cli && npm run typecheck`         |      24 | Pass                                                                   |
| CLI build         | `cd extensions/cli && npm run build`             |      15 | Pass with unused-alias warning for `@continuedev/config-types`         |
| CLI declarations  | `cd extensions/cli && npm run build:tsc`         |      20 | Command passes, but emits declarations under `dist/extensions/cli/src` |

## Characterization Results

| Contract                                       | Command                                                                                               |     Seconds | Result              |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ----------: | ------------------- |
| Configuration parsing                          | `cd packages/config-yaml && npm test -- src/__tests__/index.test.ts --runInBand`                      |          11 | 8 passed, 1 skipped |
| Core-facing model initialization and selection | `cd extensions/cli && npx vitest run src/services/ModelService.test.ts`                               |           3 | 21 passed           |
| Adapter input normalization                    | `cd packages/openai-adapters && npx vitest run src/apis/Anthropic.test.ts`                            |           3 | 3 passed            |
| Built CLI smoke test                           | `cd extensions/cli && npm run test:smoke`                                                             |          12 | 10 passed           |
| Controlled non-editor workflow                 | `cd extensions/cli && npx vitest run --config vitest.e2e.config.ts src/e2e/headless-mock-llm.test.ts` |           9 | 3 passed            |
| Static and emitted-bundle boundary             | `node tests/characterization/boundary-check.mjs`                                                      | Less than 1 | Pass                |
| Runtime module resolution                      | `node tests/characterization/runtime-boundary-check.mjs`                                              |           2 | Pass                |

The controlled workflow runs `cn -p` against a loopback mock server, asserts stable output, records the normalized user message, uses an isolated home directory, and does not contact an external provider.

## Known Baseline Findings

1. `core/package-lock.json` does not support `npm ci` against the current `core/package.json`.
2. Node.js 20.20.2 is compatible with the repository's Core engine declaration but below the engine requested by some development dependencies.
3. Core has no declared package `main`, `types`, or `exports` entry.
4. The CLI uses 63 production import declarations targeting Core: 34 deep imports and 29 root or declaration imports.
5. The CLI build reports `@continuedev/config-types` as a potentially unnecessary alias.
6. `extensions/cli/package.json` declares `dist/index.d.ts`, but the standard `npm run build` does not generate it. The separate `npm run build:tsc` command emits `dist/extensions/cli/src/index.d.ts`, not the declared package path.

These findings do not block characterization. The first RED batch is restricted to repairing Core immutable-install integrity. Product-surface deletion may begin only after the immutable Core install and the full Phase 0 comparison pass.

## Artifact Index

- Install logs: `docs/reduction/artifacts/phase0/install/`
- Build and typecheck logs: `docs/reduction/artifacts/phase0/build/`
- Characterization logs: `docs/reduction/artifacts/phase0/tests/`
- Static and emitted-bundle report: `docs/reduction/artifacts/phase0/boundaries/static-and-bundle.json`
- Runtime module-resolution report: `docs/reduction/artifacts/phase0/boundaries/runtime.json`
- License and attribution inventory: `docs/reduction/license-attribution-inventory.md`
