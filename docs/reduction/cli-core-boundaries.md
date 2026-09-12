# CLI/Core Boundary Inventory

## Named Denylist

The Phase 0 checks prohibit Core source imports and CLI bundle/runtime resolution into these repository surfaces:

- `extensions/cli/` from Core.
- `extensions/vscode/`.
- `gui/`.
- `docs-site/`.
- `binary/`.

The package denylist is:

- `vscode`.
- `@vscode/*`.
- `electron`.

String literals, configuration values, protocol names, comments, tests, and fixtures are not treated as imports.

The package denylist is applied to Core source imports, CLI source imports, emitted `node_modules` inputs, and runtime-resolved specifiers and URLs.

## Observed CLI-to-Core Imports

The production CLI contains:

| Classification                    | Count |
| --------------------------------- | ----: |
| Deep `core/*` imports             |    34 |
| `core` or `core/index.js` imports |    29 |
| Total                             |    63 |

The complete file and specifier inventory is stored in `artifacts/phase0/boundaries/static-and-bundle.json`.

### Boundary exception BND-001

| Field              | Value                                                                 |
| ------------------ | --------------------------------------------------------------------- |
| Forbidden item     | CLI imports of undeclared Core implementation paths                   |
| Surface            | `extensions/cli/src`                                                  |
| Reason             | Existing baseline architecture                                        |
| Scope              | Phase 0 characterization only                                         |
| Evidence           | `artifacts/phase0/boundaries/static-and-bundle.json`                  |
| Owner              | CLI/Core reduction workstream                                         |
| Removal condition  | Declare a supported Core API and migrate CLI imports                  |
| Approval reference | `docs/planning/phase0-baseline-plan_v2.md` observed-baseline contract |

## Core Export State

`core/package.json` has no `main`, `types`, or `exports` fields. The build emits `core/dist/core.js`, while the source tree contains `core/index.d.ts`. There is no matching declared public package entry that a standalone fixture can validate.

### Boundary exception BND-002

| Field              | Value                                                                    |
| ------------------ | ------------------------------------------------------------------------ |
| Forbidden item     | Missing declared public Core runtime export                              |
| Surface            | `core/package.json` and `core/dist`                                      |
| Reason             | Existing baseline package state                                          |
| Scope              | Phase 0 characterization only                                            |
| Evidence           | `docs/reduction/cli-core-entry-points.md`                                |
| Owner              | CLI/Core reduction workstream                                            |
| Removal condition  | Add and test an intentional Core package export                          |
| Approval reference | `docs/planning/phase0-baseline-plan_v2.md` target-architecture invariant |

## Static Source Check

Command:

```bash
node tests/characterization/boundary-check.mjs
```

Result:

- No prohibited Core source imports.
- All 63 CLI-to-Core imports recorded.
- Existing deep imports treated as BND-001 rather than hidden.

## Emitted-Bundle Check

The same command reads `extensions/cli/dist/meta.json`.

Result:

- 4,135 bundle inputs inspected.
- No inputs from VS Code, GUI, binary, docs-site, or the local Continue SDK tree.
- 1,095 Core inputs included.
- 135 local Config YAML inputs included.
- 42 local Fetch inputs included.
- 784 local OpenAI adapter inputs included.
- 5 local Terminal Security inputs included.

No emitted inputs were attributed to the local Config Types or LLM Info trees. Their retention is based on declared/build dependencies and remains subject to a RED removal experiment.

## Runtime Module-Resolution Check

Command:

```bash
node tests/characterization/runtime-boundary-check.mjs
```

The check runs the generated `dist/cn.js --version` entry through a Node.js ESM loader with an isolated home directory. It records every runtime-resolved module and fails on the named repository denylist.

Result: pass, with no prohibited runtime resolutions.

The emitted-bundle check covers bundled internal modules; the runtime loader covers modules that remain externally resolved at execution.
