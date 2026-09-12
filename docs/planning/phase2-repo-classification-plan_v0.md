# Phase 2 Repository Classification Plan v0

## Purpose

Classify repository areas as `Keep`, `Remove`, `Defer`, or `Unknown` before performing reduction work.

Phase 2 is specification-driven and test-driven:

- the classification record is the specification;
- dependency and runtime checks are the acceptance tests;
- each removal is a small, reversible experiment; and
- no deletion is accepted without post-change validation.

This phase does not authorize broad deletion or history rewriting.

## Entry Conditions

Begin only after:

- the Phase 1 dependency inventory is reviewed;
- `red-001-core-clean-install` is the source checkpoint;
- Node.js and npm versions are fixed and recorded;
- the CLI/Core retained-closure baseline passes;
- deterministic provider tests are classified;
- Puppeteer/module-resolution failures are resolved or explicitly blocked; and
- rollback is available through ordinary commits.

The validated environment must be recorded consistently. Phase 1 contains evidence from both Node.js 24/npm 11 and Node.js 26/npm 12; classification comparisons must use one selected environment.

## Product Classification

### Keep

- `extensions/cli` source, runtime assets, tests, and build configuration.
- `core` source, deliberate public exports, tests, and runtime assets.
- `packages/config-types`.
- `packages/config-yaml`.
- `packages/fetch`.
- `packages/llm-info`.
- `packages/openai-adapters`.
- `packages/terminal-security`.
- Shared utilities required by the CLI/Core dependency closure.
- TypeScript, test, build, workspace, and CI configuration required by the retained closure.
- License, attribution, minimal README, build instructions, and focused smoke coverage.

### Remove After Confirmation

- GUI/web application code and browser-only tooling.
- `packages/continue-sdk` local source if the CLI uses only the installed SDK.
- Demos, examples, prototypes, unrelated applications, and experimental packages.
- Docs-site infrastructure and marketing assets not required by retained documentation or release workflows.
- Generated output that is reproducible and not required for installation.
- Vendored models and generated assets proven unnecessary for CLI/Core.
- Tests and CI jobs serving only removed surfaces.
- Workspace and script entries proven to be surface-specific.

### Defer

- VS Code extension source and activation code.
- VS Code packaging, release configuration, tests, and documentation.
- Core-only package publishing configuration.
- Binary packaging until distribution ownership is reviewed.
- Core vendor and model assets until runtime filesystem resolution is complete.
- Product documentation and docs-site content until publication ownership is confirmed.

### Unknown

Use `Unknown` when static inspection does not establish absence of runtime, build, packaging, generated-asset, or publication dependencies.

Every `Unknown` record must include:

- an owner;
- a follow-up command;
- expected evidence;
- a due decision; and
- the condition that changes it to `Keep`, `Remove`, or `Defer`.

## Classification Specification

Create one record for every candidate with these fields:

| Field | Requirement |
| --- | --- |
| ID | Stable identifier, such as `CLASS-GUI-001` |
| Candidate | Exact repository path, package, script, asset, or CI job |
| Classification | `Keep`, `Remove`, `Defer`, or `Unknown` |
| Product surface | CLI/Core, VS Code, GUI/web, shared, docs, packaging, or unrelated |
| Hypothesis | What must remain true if the candidate is removed |
| Evidence | Manifest, import, bundle, runtime, filesystem, registry, CI, or publication evidence |
| Pre-change test | Exact command and expected result |
| Allowed change | Exact files permitted in the experiment |
| Post-change test | Exact command and expected result |
| Rollback | Ordinary commit or checkpoint to revert |
| Result | Pass, fail, blocked, or deferred |
| Reviewer | Reviewer and ISO-8601 date |
| Notes | Limitations, exceptions, and follow-up |

No item may be classified `Remove` solely because it is absent from a static import search.

## Baseline Test Contract

Before classification experiments, capture a clean baseline from the selected checkpoint.

Record:

- commit and tag;
- Node.js and npm versions;
- operating system and architecture;
- registry and cache policy;
- network policy;
- lifecycle-script policy;
- install duration;
- build and test durations;
- lockfile hashes before and after install; and
- artifact paths.

Run:

```text
npm ci --ignore-scripts --no-audit --no-fund
npm run build
npm run tsc:check
npm test
node extensions/cli/smoke-test.mjs
node tests/characterization/boundary-check.mjs
node tests/characterization/runtime-boundary-check.mjs
```

The baseline must distinguish deterministic test failures, credential-dependent failures, network failures, environment failures, and known non-gating tests.

## Test Layers

Every classification experiment must run the applicable layers.

### Static Layer

Check package manifests, workspace membership, TypeScript project references, path aliases, imports and exports, dynamic imports, registries, configuration-driven loaders, scripts and lifecycle hooks, CI and release workflows, and documentation or publication references.

### Build Layer

Run the retained package install, build, and typecheck commands. Check generated output, package entry points, declaration paths, build aliases, project references, and lockfile consistency.

### Bundle Layer

Inspect `extensions/cli/dist/meta.json` and confirm removed candidates do not appear as bundle inputs, externalized dependencies, generated assets, wrapper inputs, or runtime-loaded files.

### Runtime Layer

Run the controlled headless CLI workflow with a loopback transport. Capture the module-resolution report, runtime asset accesses, configuration paths, child processes, exit code, and stable output.

### Behavior Layer

Run configuration parsing, Core initialization, adapter selection, provider normalization, terminal-security coverage, CLI smoke tests, headless characterization tests, and relevant package tests.

### Repository Layer

Check stale references, workspace membership, root scripts, CI jobs, lockfile entries, licenses and attribution, generated files, final diff, file count, and repository size.

## Classification Workflow

For each candidate:

1. Write the classification record.
2. State the removal hypothesis.
3. Identify the focused pre-change test.
4. Run the baseline test and save its artifact.
5. Create one narrow experiment commit.
6. Run the focused post-change test.
7. Run the retained-closure install, build, typecheck, smoke, and boundary checks.
8. Inspect the diff, lockfiles, bundle metadata, and runtime report.
9. Classify the result as accepted, rejected, blocked, or deferred.
10. Keep the commit only if all acceptance criteria pass.
11. Revert the ordinary commit if the hypothesis is disproved.

## Experiment Order

### Batch A: Local SDK Source

Candidate: `packages/continue-sdk`

Hypothesis:

> The retained CLI/Core closure uses the installed SDK package and does not require the local SDK source tree.

Required evidence:

- no retained manifest reference;
- no source import;
- no workspace requirement;
- no bundle input;
- no runtime resolution; and
- clean CLI/Core workflow after removal.

### Batch B: GUI/Web Surface

Candidate: `gui/` and GUI-only root configuration.

Hypothesis:

> CLI/Core does not require GUI source, scripts, dependencies, generated assets, or workspace membership.

Allowed changes are the GUI directory, GUI-only root scripts, GUI-only workspace references, GUI-only CI jobs, and GUI-only lockfile entries proven unnecessary. Do not remove shared root configuration until the experiment proves it is GUI-only.

### Batch C: Unrelated Applications and Prototypes

Candidates include demos, examples, prototypes, and unrelated applications.

Hypothesis:

> The candidate is not required by the retained package graph, build graph, CI, release workflow, documentation contract, or legal requirements.

Use small groups with separate classification records. Do not delete the entire category as one batch.

### Batch D: Docs-Site and Marketing Assets

Split documentation into legal and attribution material, CLI/Core operational documentation, docs-site infrastructure, and screenshots or marketing assets. Keep legal and operational material. Remove other material only when all references are removed and publication checks pass.

### Batch E: Generated and Vendored Assets

Hypothesis:

> The asset is reproducible or unnecessary and is not required by installation, build, startup, controlled workflow, or runtime filesystem resolution.

Required evidence includes the source or generation path, runtime filesystem search, clean-build result, headless workflow result, bundle comparison, and attribution review. Core vendor and model assets remain deferred until this evidence is complete.

### Batch F: Surface-Specific Tests and CI

A test or CI job may be removed only when it references no retained module, does not provide shared contract coverage, belongs to a surface already classified `Remove`, and has equivalent retained coverage.

### Batch G: Workspace and Metadata Cleanup

Perform this last. Review root scripts, workspace declarations, project references, lockfiles, package entry points, CI matrices, release scripts, and documentation links. Do not hand-edit dependency metadata without rerunning immutable installation and lockfile comparison.

## Core Boundary Contract

Core remains independently consumable by the CLI and future VS Code work.

Required checks:

- CLI/Core source boundaries pass;
- emitted bundle boundaries pass;
- runtime module-resolution boundaries pass;
- Core does not load CLI, VS Code, GUI, browser, or extension activation code;
- the standalone Core import workflow remains valid; and
- existing deep imports and missing public exports remain explicitly documented until separately remediated.

Core API refactoring is outside the scope of Phase 2 classification.

## Batch Acceptance Gate

A classification experiment passes only when:

- the removal hypothesis is supported;
- focused behavior tests pass;
- retained packages install and build;
- typechecks pass;
- smoke and headless workflows pass;
- static and emitted-bundle checks pass;
- runtime boundary checks pass;
- no stale references remain;
- licenses and attribution remain intact;
- lockfile changes are understood;
- the diff contains no unrelated changes; and
- rollback is independently possible.

Any unexplained failure blocks the batch.

## Phase 2 Exit Criteria

Phase 2 is complete when:

- every repository area has one authoritative classification;
- every `Remove` candidate has passed a reversible experiment;
- every `Defer` candidate names its preserved surface;
- every `Unknown` candidate has an owner and follow-up action;
- all retained packages install, build, and typecheck;
- deterministic Core and CLI tests pass;
- provider tests are deterministic or explicitly approved as non-gating;
- static, bundle, and runtime boundaries pass;
- no stale references remain;
- license and attribution requirements are preserved;
- each removal batch has an independent rollback commit; and
- the final package graph, workspace list, file count, and repository size are recorded.

## Scope Boundaries

Included:

- repository classification;
- dependency and runtime evidence;
- reversible removal experiments;
- workspace and metadata impact analysis;
- retained-closure validation; and
- classification artifacts and review.

Excluded:

- Core API redesign;
- replacement of CLI deep imports;
- VS Code reduction;
- provider behavior changes unrelated to test isolation;
- history rewriting;
- broad dependency upgrades; and
- deletion without a passing classification experiment.

## Approval Gate

The status remains **NO-GO FOR PRODUCT DELETION** until the baseline environment is normalized and Batch A has passed its classification experiment.

A later deletion batch requires explicit approval based on its completed classification record, test artifacts, diff review, and rollback commit.