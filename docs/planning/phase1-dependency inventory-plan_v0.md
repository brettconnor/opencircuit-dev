# `open-circuit/docs/planning/phase1-dependency inventory-plan_v0.md`

# Phase 1 Dependency Inventory and Copilot Reconciliation Plan v0

## Purpose

Create an evidence-backed dependency inventory for the CLI/Core reduction and reconcile that inventory against the repository’s current implementation using GitHub Copilot as a review aid.

This phase identifies the dependency closure required by the approved primary product surface:

- CLI, including the `cn` executable
- Continue Core
- Approved local packages:
  - `config-types`
  - `config-yaml`
  - `fetch`
  - `llm-info`
  - `openai-adapters`
  - `terminal-security`

The inventory supports future Keep, Remove, and Defer decisions. It does not authorize deletion by itself.

## Status and Prerequisites

### Required starting point

All Phase 1 work begins from:

```text
phase0-cli-core-complete
```

Do not begin from:

- `phase0-source-baseline`
- an intermediate `reduce/cli-core` commit
- an unrelated feature or maintenance branch

### Current gating condition

The Phase 0 baseline records an accepted immutable-install failure:

```text
core/package-lock.json is not synchronized with core/package.json.
```

Before product-surface deletion begins, complete the narrowly scoped remediation batch:

```text
RED-001-core-lockfile-integrity
```

Phase 1 dependency inventory work may proceed while RED-001 is under review or execution, provided that:

- no repository content is deleted or relocated;
- all decisions remain provisional until clean-install validation is restored;
- inventory evidence identifies the exact commands needed to validate each proposed removal.

## Objectives

1. Map direct and transitive CLI/Core dependencies.
2. Identify runtime, build-time, test-time, packaging-time, and generated-asset dependencies.
3. Separate the current observed dependency graph from the target reduced architecture.
4. Classify each repository surface as:
   - **Keep**
   - **Remove**
   - **Defer**
   - **Unknown / requires evidence**
5. Reconcile inventory findings with Copilot-generated analysis without treating Copilot output as authoritative evidence.
6. Produce deletion hypotheses and disconfirming checks for later RED batches.
7. Preserve the ability to support a secondary VS Code product surface after the CLI/Core closure is validated.

## Non-Goals

This phase does not:

- delete packages, source files, tests, assets, or applications;
- refactor Core public exports;
- replace current CLI deep imports into Core;
- remove VS Code extension code;
- establish a Core-only publishing surface;
- rewrite Git history;
- update dependencies except as explicitly required by `RED-001-core-lockfile-integrity`;
- accept Copilot suggestions without repository evidence and human review.

## Product Scope

### Primary product surface: CLI/Core

The Phase 1 inventory focuses on the dependency closure necessary to:

1. install dependencies;
2. build approved local packages in the required order;
3. build and typecheck Core;
4. build and typecheck the CLI;
5. invoke the `cn` executable;
6. parse supported configuration;
7. initialize and run the controlled headless CLI/Core workflow;
8. resolve the selected model/provider adapter through the approved local package closure.

### Secondary product surfaces: deferred

The following are deferred unless evidence proves a CLI/Core requirement:

- VS Code extension activation and packaging
- VS Code commands, views, webviews, and editor integrations
- GUI and browser applications
- web applications and documentation sites
- unrelated tools, demos, examples, and experimental applications
- binary packaging and platform-specific installers
- custom applications not required by the CLI/Core dependency closure

### Core library boundary

Phase 1 records the current boundary as observed. It does not require the target boundary to be implemented yet.

Current baseline facts include:

- Core has no declared package `main`, `types`, or `exports` entry.
- The CLI currently includes Core deep imports.
- Existing CLI-to-Core coupling is a recorded baseline condition.

The future target invariant remains:

> Core should be consumable through a deliberate public API and should not depend on CLI, VS Code, GUI, browser, or extension-activation modules.

## Evidence Sources

Each inventory decision must cite one or more evidence sources.

### Required sources

- `package.json` manifests
- package lockfiles
- npm scripts and lifecycle hooks
- TypeScript configuration and project references
- CLI build configuration
- Core build configuration
- aliases and path mappings
- source imports and exports
- dynamic imports
- runtime registries and plugin registration
- configuration-driven module loading
- generated asset paths
- runtime filesystem access
- emitted CLI bundle metadata:
  - `extensions/cli/dist/meta.json`
- Phase 0 static boundary report
- Phase 0 runtime module-resolution report
- Phase 0 characterization test results

### Supporting sources

- repository documentation
- CI workflows
- release and package-publishing scripts
- test fixtures
- generated code configuration
- package tarball contents, where relevant
- public upstream Continue documentation, where useful for context

## Inventory Model

Each inventory record must identify a package, directory, executable, asset group, configuration component, script, or product surface.

### Required fields

| Field                     | Requirement                                                                                                   |
| ------------------------- | ------------------------------------------------------------------------------------------------------------- |
| ID                        | Stable identifier, such as `PKG-CORE`, `APP-VSCODE`, or `ASSET-MODELS`                                        |
| Name                      | Human-readable component name                                                                                 |
| Path                      | Repository-relative path or exact package specifier                                                           |
| Type                      | Package, application, entry point, asset, script, test, configuration, generated output, documentation, or CI |
| Current decision          | Keep, Remove, Defer, or Unknown                                                                               |
| Product-surface relevance | CLI/Core, VS Code, GUI/web, shared, or unrelated                                                              |
| Direct dependents         | Components that directly require it                                                                           |
| Dependency role           | Runtime, build, test, packaging, development, generated asset, or documentation                               |
| Static evidence           | Manifest/import/export/build-reference evidence                                                               |
| Dynamic evidence          | Registry, configuration, plugin, runtime-load, or filesystem evidence                                         |
| Bundle evidence           | Whether it appears in the CLI emitted-bundle metafile                                                         |
| Test evidence             | Characterization or smoke-test coverage                                                                       |
| Copilot assessment        | Summary of Copilot’s finding and confidence, if used                                                          |
| Human reconciliation      | Accepted, rejected, or needs investigation                                                                    |
| Disconfirming check       | Command or test that would prove the decision wrong                                                           |
| Proposed RED batch        | Future removal or remediation batch, if applicable                                                            |
| Notes                     | Known exceptions, risks, and follow-up work                                                                   |

### Decision definitions

| Decision | Meaning                                                                                            |
| -------- | -------------------------------------------------------------------------------------------------- |
| Keep     | Required by the validated CLI/Core dependency closure or required build/metadata/licensing support |
| Remove   | Not required by CLI/Core and not intentionally preserved as a deferred product surface             |
| Defer    | Not included in first reduction, but retained pending evaluation of a secondary product surface    |
| Unknown  | Evidence is incomplete; no deletion decision may be made                                           |

No item may be classified as **Remove** solely because it does not appear in a static source import search.

## Initial Inventory Seed

The following initial classifications are hypotheses, not final decisions.

| ID                      | Surface                                   | Initial decision               | Rationale                                                                        | Required disconfirming check                                                   |
| ----------------------- | ----------------------------------------- | ------------------------------ | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `CLI-CN`                | `extensions/cli` and `cn` executable path | Keep                           | Primary user-facing product entry point                                          | Build and run controlled `cn -p` workflow                                      |
| `PKG-CORE`              | `core`                                    | Keep                           | CLI runtime dependency and reusable future library boundary                      | Core typecheck/build and controlled workflow                                   |
| `PKG-CONFIG-TYPES`      | `packages/config-types`                   | Keep                           | Approved configuration contract package                                          | Build and import/dependency evidence                                           |
| `PKG-CONFIG-YAML`       | `packages/config-yaml`                    | Keep pending executable review | Approved configuration parsing package; executable classification still required | Confirm CLI/Core uses package and determine whether its executable is required |
| `PKG-FETCH`             | `packages/fetch`                          | Keep                           | Approved network abstraction package                                             | Trace Core/adapter usage and controlled mock transport                         |
| `PKG-LLM-INFO`          | `packages/llm-info`                       | Keep                           | Approved model metadata package                                                  | Trace model selection and initialization path                                  |
| `PKG-OPENAI-ADAPTERS`   | `packages/openai-adapters`                | Keep                           | Approved provider adapter package                                                | Adapter normalization and model-resolution tests                               |
| `PKG-TERMINAL-SECURITY` | `packages/terminal-security`              | Keep                           | Approved terminal safety package                                                 | Trace CLI/Core runtime or command-execution usage                              |
| `APP-VSCODE`            | VS Code extension surface                 | Defer                          | Secondary product surface                                                        | Confirm CLI/Core build, bundle, and runtime do not load it                     |
| `APP-GUI`               | GUI/browser product surface               | Unknown                        | Presumed outside CLI/Core scope but must be evidenced                            | Search build, runtime, asset, and workspace references                         |
| `APP-WEB`               | Web application surface                   | Unknown                        | Presumed outside CLI/Core scope but must be evidenced                            | Search build, runtime, asset, and workspace references                         |
| `DOCS-SITE`             | Documentation site tooling                | Unknown                        | May be unrelated to CLI/Core; licensing/docs retention must be separated         | Confirm no CLI build/test/runtime dependency                                   |
| `ASSET-MODELS`          | Vendored models or model binaries         | Unknown                        | May be runtime-loaded or packaging-only                                          | Trace filesystem and configuration-based asset loading                         |
| `PKG-CORE-LOCKFILE`     | `core/package-lock.json`                  | Keep / remediate               | Required for reproducible clean installation                                     | `npm ci` succeeds after RED-001                                                |

## Discovery Procedure

### 1. Enumerate package and workspace topology

Identify all package manifests and lockfiles:

```bash
find . \
  -path '*/node_modules' -prune -o \
  -name package.json -print | sort

find . \
  -path '*/node_modules' -prune -o \
  \( -name package-lock.json -o -name npm-shrinkwrap.json \) -print | sort
```

For every discovered package, record:

- package name;
- path;
- lockfile location;
- package manager assumptions;
- `main`, `module`, `types`, `exports`, and `bin` fields;
- scripts;
- local file dependencies;
- workspace references;
- publish/package scripts.

### 2. Identify retained entry points

Confirm and document:

- CLI source entry:
  - `extensions/cli/src/index.ts`
- CLI build configuration:
  - `extensions/cli/build.mjs`
- CLI main bundle:
  - `extensions/cli/dist/index.js`
- CLI executable bundle:
  - `extensions/cli/dist/cn.js`
- CLI package executable mapping:
  - `extensions/cli/package.json` `bin.cn`
- Core package entry declarations or their absence
- `config-yaml` executable declaration and its consumers
- shell wrappers, development launch scripts, and generated executable wrappers

### 3. Build direct dependency maps

For the CLI and Core, collect:

- production dependencies;
- development dependencies required to build/test retained surfaces;
- local file dependencies;
- npm scripts that install, build, package, test, or launch other packages;
- TypeScript path aliases;
- build aliases;
- package-export and module-resolution settings.

Record the direction of each relation:

```text
CLI -> Core
Core -> local package
CLI -> local package
Core -> external package
CLI -> generated asset
```

Do not infer a reverse dependency from package co-location.

### 4. Identify transitive runtime closure

Trace the CLI/Core execution path exercised by the Phase 0 controlled workflow:

```text
cn
  -> CLI launcher
  -> CLI command handling
  -> configuration loading
  -> model initialization and selection
  -> adapter resolution
  -> Core workflow
  -> mock/local transport
  -> deterministic CLI output
```

For each stage, identify:

- imported modules;
- dynamically loaded modules;
- required environment assumptions;
- configuration files;
- generated assets;
- filesystem paths;
- package dependencies;
- deferred-surface references, if any.

### 5. Analyze emitted CLI bundle inputs

Use the CLI build metafile:

```text
extensions/cli/dist/meta.json
```

Record:

- total bundle input count;
- input paths by repository surface;
- input paths from Core;
- input paths from approved local packages;
- input paths from VS Code, GUI, web, extension packaging, or deferred directories;
- externalized dependencies;
- unresolved or suspicious aliases.

The Phase 0 baseline reports 4,135 CLI bundle inputs. Phase 1 should classify these inputs by surface rather than treating the count itself as dependency evidence.

### 6. Analyze dynamic and configuration-driven dependencies

Search for:

- `import(...)`
- `require(...)`
- module registries
- provider registries
- plugin discovery
- filesystem-based module resolution
- config-selected providers or tools
- template, prompt, model, or binary asset paths
- child-process invocation
- package installation scripts that produce required outputs

Dynamic-loading evidence must identify both:

1. the loader location; and
2. at least one configuration or runtime path that can trigger it.

### 7. Reconcile tests and dependency claims

For each retained dependency, identify the test or workflow that exercises it.

Examples:

| Dependency claim                | Minimum validating evidence                                                         |
| ------------------------------- | ----------------------------------------------------------------------------------- |
| `config-yaml` is required       | Minimal YAML configuration parsing test and CLI configuration workflow              |
| `llm-info` is required          | Model initialization and selection test                                             |
| `openai-adapters` is required   | Adapter normalization test                                                          |
| `fetch` is required             | Controlled transport or network abstraction path                                    |
| `terminal-security` is required | CLI/Core terminal command safety path, or documented evidence that it is build-only |
| Core is required                | Controlled headless `cn -p` workflow                                                |
| VS Code is not required         | Static, bundle, and runtime denylist checks                                         |

If no retained test or controlled workflow supports a dependency claim, classify the item as **Unknown** until additional evidence is captured.

## Copilot Reconciliation Procedure

GitHub Copilot may be used to accelerate inventory review, summarize relationships, identify likely dynamic dependencies, and propose missing evidence. Copilot output is advisory only.

### Copilot responsibilities

Use Copilot to assist with:

- summarizing package manifests and dependency fields;
- identifying possible source imports and deep imports;
- locating references to package names, aliases, and paths;
- identifying dynamic import patterns;
- correlating build configuration with emitted bundle paths;
- proposing candidate Keep, Remove, Defer, or Unknown classifications;
- identifying tests likely to cover a dependency;
- generating inventory-table drafts from cited repository files.

### Human responsibilities

A reviewer must independently verify:

- every proposed dependency relation;
- every path and import specifier;
- every proposed deletion candidate;
- every claimed absence of a dependency;
- every runtime/dynamic-loading claim;
- every exception;
- every command used as a disconfirming check.

Copilot must not be used as sole proof that a component is removable.

### Reconciliation record

For each Copilot-assisted finding, record:

| Field                      | Requirement                                             |
| -------------------------- | ------------------------------------------------------- |
| Copilot prompt scope       | Files, directories, or question supplied                |
| Copilot finding            | Concise claim                                           |
| Claimed evidence           | Exact paths, symbols, scripts, or manifest fields cited |
| Human verification command | Search, build, test, or inspection command              |
| Verification outcome       | Accepted, rejected, partially accepted, or unresolved   |
| Inventory update           | Record IDs changed                                      |
| Reviewer                   | Human reviewer or role                                  |
| Date                       | ISO-8601 date                                           |

### Required reconciliation rules

1. **No unsupported certainty**
   If Copilot says a package is unused, verify static imports, dynamic imports, scripts, configuration registries, asset paths, and emitted bundle inputs before recording `Remove`.

2. **No inferred runtime behavior from names**
   Package and directory names are not dependency evidence.

3. **No repository-wide destructive edits**
   Copilot-generated deletion lists remain proposals until a human-approved RED batch exists.

4. **No secret or proprietary configuration input**
   Do not provide credentials, private endpoints, tokens, private model configuration, or unpublished internal artifacts to Copilot prompts.

5. **Use file-scoped analysis**
   Prefer targeted prompts over unconstrained repository-wide prompts. Include the relevant manifests, build scripts, and import locations.

6. **Record contradictions**
   If Copilot analysis conflicts with bundle metadata, runtime guards, or tests, runtime/build evidence takes precedence. Record the contradiction as an unresolved inventory item.

## Suggested Copilot Reconciliation Prompts

### Package role analysis

> Review the following package manifest and its direct import consumers. Identify whether the package is likely required at runtime, build time, test time, packaging time, or only for a deferred product surface. Cite exact files and import specifiers. Do not assume that an absence of static imports means the package is unused. Return findings in the dependency inventory schema.

### CLI-to-Core boundary analysis

> Analyze these CLI source files and Core package metadata. List every Core import specifier, classify it as root/package/deep/internal, identify the imported symbols, and state whether the import appears on the controlled headless CLI path. Cite exact file paths and line ranges. Do not recommend refactoring; this is an observed-baseline inventory.

### Dynamic dependency analysis

> Review these build scripts, configuration loaders, registries, and runtime filesystem calls. Identify dynamic imports, `require` calls, plugin registries, configuration-selected modules, generated assets, and runtime path resolution. For each, state the trigger condition and the evidence needed to prove whether it belongs in the CLI/Core closure.

### Emitted bundle reconciliation

> Compare this CLI bundle metafile summary with the dependency inventory. Group inputs by repository surface: CLI, Core, approved local packages, VS Code, GUI/web, tests, generated assets, and unknown. Flag any input whose classification lacks source/build/runtime evidence. Return only cited findings.

## Boundary Reconciliation

The Phase 0 boundary checks remain the baseline mechanism for identifying deferred-surface coupling.

### Required checks

| Check                           | Evidence                                                 | Expected Phase 1 use                                                    |
| ------------------------------- | -------------------------------------------------------- | ----------------------------------------------------------------------- |
| Source-level boundary check     | `tests/characterization/boundary-check.mjs`              | Identify direct prohibited imports and baseline exceptions              |
| Emitted bundle check            | `extensions/cli/dist/meta.json` and static bundle report | Identify deferred-surface paths bundled into the CLI                    |
| Runtime module-resolution check | `tests/characterization/runtime-boundary-check.mjs`      | Identify prohibited modules loaded during controlled headless execution |

### Known baseline exceptions

The following are observed architecture facts and must remain visible in the inventory:

1. Core lacks declared `main`, `types`, and `exports` metadata.
2. The CLI contains 63 production imports targeting Core:
   - 34 deep imports;
   - 29 root or declaration imports.
3. CLI deep imports are not automatically a CLI/Core closure violation, but they block a claim that Core is already consumed exclusively through a declared public package API.

Any new exception requires:

- exact module/path;
- affected product surface;
- reason;
- source, bundle, or runtime evidence;
- scope;
- removal condition;
- explicit approval.

## Proposed Deliverables

Phase 1 produces or updates the following:

```text
docs/planning/
  phase1-dependency inventory-plan_v0.md
  phase1-dependency-inventory.md
  phase1-copilot-reconciliation-log.md
  phase1-removal-hypotheses.md

docs/reduction/artifacts/phase1/
  manifests/
  imports/
  dynamic-loads/
  bundle/
  reconciliation/
  reports/
```

### Required inventory outputs

1. **Package and workspace inventory**
2. **CLI/Core entry-point inventory update**
3. **CLI-to-Core import inventory**
4. **Static and dynamic dependency map**
5. **Bundle-input classification report**
6. **Keep/Remove/Defer/Unknown decision table**
7. **Copilot reconciliation log**
8. **First deletion-candidate list**
9. **Removal hypotheses and disconfirming checks**
10. **Unresolved dependency and exception list**

## Phase 1 Exit Criteria

Phase 1 inventory is complete when:

- [ ] All repository packages and applications are listed.
- [ ] All approved CLI/Core packages have documented direct dependents and roles.
- [ ] CLI source, package-main, `cn`, generated wrappers, Core entry state, and `config-yaml` executable are classified.
- [ ] Static imports, dynamic imports, registry/configuration loading, runtime asset paths, and build references have been reviewed.
- [ ] CLI bundle metafile inputs are classified by product surface.
- [ ] Existing CLI-to-Core deep imports are inventoried and preserved as baseline facts.
- [ ] Every proposed `Remove` decision includes a disconfirming check.
- [ ] Every `Defer` decision identifies the deferred product surface and reason for preservation.
- [ ] Every `Unknown` decision has a specific follow-up evidence action.
- [ ] Copilot-assisted findings have human verification records.
- [ ] No deletion, relocation, workspace removal, or product-surface change occurred during inventory work.
- [ ] Core immutable-install remediation status is recorded.
- [ ] The inventory is reviewed before any product-surface deletion batch is approved.

## Approval Gate for Deletion Work

A deletion batch may begin only when all conditions below are true:

1. The batch begins from `phase0-cli-core-complete` or a later approved remediation checkpoint.
2. `RED-001-core-lockfile-integrity` has restored successful immutable Core installation.
3. The proposed deletion target is classified as `Remove`.
4. Static, dynamic, build, bundle, and runtime evidence support that classification.
5. The batch has a written hypothesis.
6. The batch has a focused disconfirming check.
7. The batch has a rollback plan using ordinary Git commits.
8. The CLI/Core install, build, typecheck, characterization, smoke, and boundary commands are identified for post-change comparison.

## First Planned Remediation Batch

```text
RED-001-core-lockfile-integrity
```

### Scope

Repair `core/package-lock.json` so that Core supports the recorded immutable install command:

```bash
cd core && npm ci --ignore-scripts --no-audit --no-fund
```

### Hypothesis

The Core manifest and lockfile can be reconciled without unintended runtime dependency changes, allowing reproducible installation while retaining the Phase 0 build, typecheck, characterization, and boundary behavior.

### Disconfirming checks

```bash
cd core && rm -rf node_modules
npm ci --ignore-scripts --no-audit --no-fund
npm run tsc:check
npm run build

cd ../extensions/cli
npm run typecheck
npm run build
npm run test:smoke

cd ../..
node tests/characterization/boundary-check.mjs
node tests/characterization/runtime-boundary-check.mjs
```

The controlled headless workflow must also pass using the existing Phase 0 fixture and loopback transport.

### Explicit exclusions

`RED-001` must not:

- delete repository content;
- remove workspace entries;
- change CLI behavior;
- refactor the Core public API;
- remove deep imports;
- modify VS Code, GUI, web, or other deferred product surfaces;
- change provider behavior except where required to restore the existing locked dependency state.

## Rollback

All Phase 1 inventory commits and future RED batches must be independently revertible.

Rollback references:

```text
phase0-source-baseline
phase0-cli-core-complete
```

Use ordinary Git revert commits for reviewed changes. History rewrite, force-push, or replacement of the source-baseline reference requires separate explicit approval.
