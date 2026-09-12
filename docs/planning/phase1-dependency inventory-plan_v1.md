# Phase 1 Dependency Inventory and Copilot Reconciliation Plan v1

## Purpose

Create an evidence-backed dependency inventory for the CLI/Core reduction. This phase reconciles repository manifests, imports, build outputs, runtime behavior, and Copilot-assisted findings. It does not authorize deletion.

## Scope

The primary closure is the CLI, the `cn` executable, Continue Core, and these local packages:

- `packages/config-types`
- `packages/config-yaml`
- `packages/fetch`
- `packages/llm-info`
- `packages/openai-adapters`
- `packages/terminal-security`
- `core`
- `extensions/cli`

VS Code, GUI/web, binary packaging, documentation sites, demos, and unrelated applications remain deferred or unknown until evidence is complete.

## Status and Prerequisites

All inventory work must begin from `phase0-cli-core-complete` or an approved remediation branch created from that reference. Do not begin from `phase0-source-baseline`, an untagged intermediate commit, or an unrelated branch.

`RED-001-core-lockfile-integrity` is a separate, narrowly scoped dependency-integrity remediation. Inventory work may proceed while it is reviewed or executed, but:

- no repository content may be deleted or relocated;
- inventory decisions remain provisional until remediation validation passes;
- remediation changes must be committed separately;
- the post-remediation inventory must record any changed dependency evidence.

`RED-001` is not a product-surface deletion batch.

## Objectives and Non-Goals

### Objectives

1. Map direct and transitive CLI/Core dependencies.
2. Identify runtime, build, test, packaging, generated-asset, and dynamic-loading dependencies.
3. Classify every surface as Keep, Remove, Defer, or Unknown.
4. Record deletion hypotheses and disconfirming checks for later RED batches.
5. Reconcile Copilot findings with repository evidence and human review.
6. Preserve a future path for a secondary VS Code product surface.

### Non-goals

This phase does not delete or relocate content, refactor Core exports, replace CLI deep imports, remove VS Code code, rewrite history, or modify dependencies except through the approved RED-001 remediation.

## Observed Baseline and Target

Phase 1 records the current implementation separately from the future architecture.

### Observed baseline

Record exact paths, specifiers, resolved files, and purposes for:

- `extensions/cli/src/index.ts`;
- `extensions/cli/dist/index.js`;
- `extensions/cli/dist/cn.js`;
- `extensions/cli/package.json` `main`, `types`, and `bin.cn` fields;
- `extensions/cli/build.mjs` bundle and wrapper generation;
- `extensions/cli/smoke-test.mjs`;
- every CLI-to-Core deep import;
- Core's actual `main`, `types`, and `exports` state.

Current deep imports or missing Core package exports are baseline findings, not Phase 1 failures.

### Target invariant

After reduction, the CLI should consume Core through a documented public API, and Core should not depend on CLI, VS Code, GUI, webview, browser, or extension-activation modules except through approved adapters. This is a later RED/Phase 6 target.

## Evidence Sources and Provenance

Use manifests, all relevant lockfiles, scripts, TypeScript configuration, aliases, imports/exports, dynamic loaders, registries, runtime filesystem access, generated assets, CI/release configuration, `extensions/cli/dist/meta.json`, Phase 0 reports, and characterization results.

Every artifact must record its path, generation command, working directory, source commit/tag, generation date, tool versions, result, and limitations. A missing artifact must be marked unavailable with a reason; it must not be treated as evidence of absence.

## Inventory Schema

Each record must contain:

| Field                   | Requirement                                                                                                         |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------- |
| ID and name             | Stable identifier and human-readable name                                                                           |
| Path and type           | Repository path/specifier and package, app, entry point, asset, script, test, config, generated output, docs, or CI |
| Decision                | Keep, Remove, Defer, or Unknown                                                                                     |
| Product relevance       | CLI/Core, VS Code, GUI/web, shared, or unrelated                                                                    |
| Dependents and role     | Direct dependents plus runtime, build, test, packaging, development, asset, or documentation role                   |
| Static/dynamic evidence | Manifest, import/export, registry, config, plugin, filesystem, or loader evidence                                   |
| Bundle/test evidence    | Metafile membership and characterization coverage                                                                   |
| Copilot/human review    | Finding, confidence, verification, reviewer, date, and outcome                                                      |
| Hypothesis/check        | Removal hypothesis and focused disconfirming command                                                                |
| Proposed batch/notes    | Future RED batch, exceptions, risks, and follow-up                                                                  |

No item may be classified Remove solely because it is absent from a static import search.

## Initial Hypotheses

The CLI, Core, six local packages, required metadata, licenses, and build configuration start as Keep hypotheses. VS Code starts as Defer. GUI/web, docs-site, vendored models, and unrelated applications start as Unknown until evidence supports a decision. `core/package-lock.json` is Keep/remediate pending RED-001.

Use this decision format:

| Surface               | Decision | Removal hypothesis                              | Disconfirming check                                             | Result   |
| --------------------- | -------- | ----------------------------------------------- | --------------------------------------------------------------- | -------- |
| GUI package           | Unknown  | No CLI/Core runtime, build, or asset dependency | Remove locally; run retained install/build/smoke/boundary suite | Pending  |
| VS Code extension     | Defer    | Secondary surface is outside the first closure  | Confirm no CLI/Core source, bundle, or runtime load             | Deferred |
| Vendored model assets | Unknown  | Not used by the retained runtime path           | Trace config/filesystem resolution and run smoke test           | Pending  |

## Retained-Closure Install Matrix

Maintain the directly runnable matrix in `docs/reduction/artifacts/phase1/retained-closure-install-matrix.md`. It must contain one row for each local package, Core, and CLI, with no placeholders:

| Package             | Working directory | Lockfile  | Install command | Lifecycle policy | Build order | Build     | Typecheck | Test/smoke                                       | Hash before | Hash after | Result  |
| ------------------- | ----------------- | --------- | --------------- | ---------------- | ----------- | --------- | --------- | ------------------------------------------------ | ----------- | ---------- | ------- |
| `config-types`      | To record         | To record | To record       | To record        | To record   | To record | To record | N/A or exact command                             | To record   | To record  | Pending |
| `fetch`             | To record         | To record | To record       | To record        | To record   | To record | To record | N/A or exact command                             | To record   | To record  | Pending |
| `llm-info`          | To record         | To record | To record       | To record        | To record   | To record | To record | N/A or exact command                             | To record   | To record  | Pending |
| `terminal-security` | To record         | To record | To record       | To record        | To record   | To record | To record | N/A or exact command                             | To record   | To record  | Pending |
| `config-yaml`       | To record         | To record | To record       | To record        | To record   | To record | To record | Exact command                                    | To record   | To record  | Pending |
| `openai-adapters`   | To record         | To record | To record       | To record        | To record   | To record | To record | Exact command                                    | To record   | To record  | Pending |
| `core`              | To record         | To record | To record       | To record        | To record   | To record | To record | Exact command                                    | To record   | To record  | Pending |
| `extensions/cli`    | To record         | To record | To record       | To record        | To record   | To record | To record | `npm run test:smoke` plus characterization tests | To record   | To record  | Pending |

Install-integrity mode and build/runtime mode must be recorded separately. A lockfile mutation, credential requirement, missing local artifact, registry failure, or undocumented ordering is a documented failure, not a pass.

## Discovery Procedure

1. Enumerate every `package.json`, `package-lock.json`, workspace reference, `main`, `module`, `types`, `exports`, `bin`, lifecycle, build, test, publish, and local-file dependency field.
2. Inventory the CLI path from `extensions/cli/src/index.ts` through `dist/index.js`, `dist/cn.js`, `bin.cn`, wrappers, and development launch scripts.
3. Classify the `config-yaml` `bin` executable and identify its consumers.
4. Build directed CLI/Core/package maps, including TypeScript aliases and build aliases.
5. Trace the controlled `cn` workflow through configuration, model selection, adapter resolution, Core, transport, and output.
6. Parse `extensions/cli/dist/meta.json` and classify every bundle input by surface; verify any recorded counts against a command and artifact.
7. Inspect dynamic imports, registries, configuration-driven loading, filesystem paths, child processes, generated assets, and installation scripts.
8. Link each Keep claim to a test or controlled workflow; otherwise classify it Unknown.

## Characterization and Boundary Evidence

Every test result records the exact fixture path, working directory, copyable command, expected exit code, stable output assertion, named environment variables, network mode, duration, result, and artifact path.

The CLI invocation test must define either exit code `0` with stable output or an exact intentional validation error. Startup and module-resolution failures are not acceptable expected errors.

Boundary evidence has three parts:

1. Static source import/dependency check.
2. Emitted-bundle check using `extensions/cli/dist/meta.json`.
3. Runtime module-resolution check during the controlled headless workflow.

Maintain a named denylist derived from the repository tree. Every exception records an ID, exact item, surface, reason, evidence, owner, scope, removal condition, and approval.

The Phase 0 `cn --version` runtime report does not satisfy the controlled-workflow requirement. Phase 1 must capture a new runtime-resolution artifact while executing the loopback-backed headless characterization workflow.

## Copilot Reconciliation

Copilot output is advisory. Use targeted, file-scoped prompts to summarize manifests, imports, dynamic loading, bundle inputs, and likely tests. Human review must verify every relation, absence claim, removal candidate, runtime claim, exception, and disconfirming command. Record prompt scope, finding, cited evidence, verification command/outcome, inventory IDs changed, reviewer, and ISO-8601 date. Runtime, build, and test evidence take precedence over Copilot claims.

## Phase 1 Outputs and Exit Criteria

Produce the package/workspace inventory, entry-point inventory, CLI-to-Core import inventory, static/dynamic dependency map, bundle-input report, decision table, Copilot reconciliation log, removal hypotheses, and unresolved exception list. Store generated evidence under `docs/reduction/artifacts/phase1/`.

Phase 1 inventory is complete when:

- all packages and applications are listed;
- all retained packages have direct dependents, roles, commands, and evidence;
- all entry points and Core deep imports are classified;
- dynamic, registry, runtime-asset, build, and bundle references are reviewed;
- every Remove has a disconfirming check, every Defer names its preserved surface, and every Unknown has a follow-up action;
- artifact provenance and install-matrix results are recorded;
- Copilot findings have human verification;
- no deletion, relocation, workspace removal, or product-surface change occurred;
- RED-001 status and post-remediation inventory impact are recorded;
- the inventory is reviewed before deletion approval.

## Deletion Approval Gate

A deletion batch requires:

1. `phase0-cli-core-complete` or a later approved remediation checkpoint.
2. RED-001 passes `cd core && npm ci --ignore-scripts --no-audit --no-fund` from no `core/node_modules`, leaves tracked files unchanged, and preserves the Phase 0 build, typecheck, characterization, and boundary results. There is no exception path for deletion approval.
3. The full retained-closure install matrix passes, or every failure is explicitly approved.
4. The target is classified Remove with static, dynamic, build, bundle, and runtime evidence.
5. A written hypothesis, focused disconfirming check, ordinary-commit rollback plan, and post-change comparison command set.

## RED-001: Core Lockfile Integrity

RED-001 is a separate remediation commit. It must not delete content, remove workspace entries, refactor Core exports, remove deep imports, change CLI behavior, modify deferred surfaces, or change provider behavior except as required to restore the locked dependency state.

Use the recorded package order and commands from the install matrix. Run install-integrity mode with the recorded lifecycle policy and SHA-256 lockfile checks, then run build/runtime mode with the scripts required by each package. At minimum, validate all six local packages, Core, and CLI before and after the remediation. Record exact failures, changed metadata, recovery actions, and post-change inventory impact.

## Rollback

Keep inventory and RED commits independently revertible. Use `phase0-source-baseline` for the original source state and `phase0-cli-core-complete` for the reviewed safety-net state. History rewrite, force-push, or replacement of either reference requires separate explicit approval.
