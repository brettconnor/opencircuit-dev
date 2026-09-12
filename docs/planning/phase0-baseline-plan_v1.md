# Phase 0 Baseline Plan

## Purpose

Establish a reproducible baseline for the CLI/Core reduction before deleting or relocating repository content. This phase uses specification-driven development (SDD) to define the intended contracts and test-driven development (TDD) to capture the current executable behavior.

Phase 0 does not remove product code. Its output is the evidence needed to make later reduction work reversible, measurable, and reviewable.

## Scope

The primary product surface is the CLI backed by Continue Core. The baseline covers:

- CLI entry points, especially the `cn` executable.
- Core public exports and one non-editor workflow.
- The six approved local packages:
  - `config-types`
  - `config-yaml`
  - `fetch`
  - `llm-info`
  - `openai-adapters`
  - `terminal-security`
- Root package, lockfile, TypeScript, build, test, and workspace configuration required by CLI/Core.

VS Code, GUI, web, binary packaging, and unrelated applications are outside the Phase 0 execution target. They remain available for later review unless dependency evidence shows that CLI/Core requires them.

## Phase 0 Deliverables

1. A dedicated reduction branch, such as `reduce/cli-core`.
2. A recorded baseline commit SHA or tag.
3. Repository size, tracked-file count, and dependency-install measurements.
4. A documented CLI/Core dependency inventory.
5. SDD contracts for the retained product surface.
6. TDD characterization tests for the current CLI/Core behavior.
7. A repeatable baseline validation command set.
8. A Phase 6 comparison checklist using the same contracts and tests.

## Baseline Environment

Record these values before validation so results do not depend on an implicit local setup:

| Item | Required value |
| --- | --- |
| Operating system and architecture | Exact recorded values |
| Node.js | Exact recorded version |
| Package manager | Exact recorded version |
| Install mode | Lockfile-enforced or immutable |
| Package-manager store/cache | Recorded policy; repository-local artifacts removed |
| Network | No external provider calls in baseline tests |
| Credentials | Not required |
| Test transport | Mock or local fixture |

Record required non-secret environment variables by name only. Never place credentials, tokens, or other secrets in baseline artifacts.

## Clean-Install Contract

A clean dependency install means:

- Start from a clean checkout.
- Remove repository-local dependency artifacts such as `node_modules` and package-manager install state.
- Do not modify the lockfile during validation.
- Install using the repository's lockfile-enforcing command.
- Fail validation if tracked dependency metadata changes unexpectedly.

Distinguish clean-checkout validation from clean-install validation. An optional offline or cache-free run may provide stronger evidence, but it is not required if the repository's package-manager constraints make it impractical.

## SDD Specification

### Product Contract

The retained product is a buildable CLI that uses Continue Core for a non-editor workflow. The CLI remains the user-facing entry point, and Core remains independently consumable through deliberate public exports.

### Build Contract

- A clean checkout can install the declared dependencies.
- The retained local packages can be built in dependency order.
- Core can be built through its intended package configuration.
- The CLI can be typechecked and bundled through its intended scripts.

### Entry-Point Contract

Inventory all executable and public package paths before deletion:

| Entry point | Source package or path | Intended role | CLI/Core scope | Validation |
| --- | --- | --- | --- | --- |
| `cn` | To record | Primary CLI executable | Keep | CLI invocation test |
| Core public export | To record | Reusable library API | Keep | Standalone fixture |
| Other executable or launcher | To record | Unknown or deferred | Investigate | Dependency evidence |

Inspect root scripts, all `bin` declarations, `exports` maps, CLI subcommand registrations, package publishing entry points, runtime build outputs, shell wrappers, and launcher scripts.

### Runtime Contract

- The `cn` entry point can be invoked through the supported CLI start path.
- A minimal configuration can be parsed without VS Code, GUI, or editor dependencies.
- Core initialization completes for the supported non-editor workflow.
- Provider or adapter resolution follows the selected configuration.
- External model calls are mocked or locally transported in validation unless a live provider is explicitly required.

### Boundary Contract

- CLI imports Core through documented public exports.
- Core does not import CLI modules, VS Code APIs, terminal UI modules, GUI/browser code, or extension activation code.
- Environment-specific behavior is isolated behind existing interfaces or adapters where practical.
- The CLI/Core closure does not depend on deferred product surfaces without an explicit recorded exception.
- Maintain a named denylist derived from the actual repository layout, including `vscode`, extension activation modules, webview/UI modules, browser-only modules, and CLI paths imported by Core.
- Enforce the denylist with both static import/dependency checks and a runtime module-resolution check where practical.

### Reduction Contract

- Each removal is justified by dependency-closure evidence.
- Keep, Remove, and Defer decisions are recorded.
- Git history remains intact unless a separate history-rewrite decision is approved.
- Every removal batch is independently revertible.

## TDD Baseline Tests

Create or identify focused tests before reduction work begins. These are characterization tests: they document behavior that must either remain stable or be intentionally changed with an updated SDD contract.

### Required Test Cases

1. **Configuration parsing**
   - Given a minimal valid YAML configuration, the parser returns the expected typed configuration.
2. **Core initialization and adapter selection**
   - Given the minimal configuration and test doubles, Core initializes, resolves the configured provider, and creates normalized request inputs without loading editor-specific modules or making a network call.
3. **Controlled Core workflow**
   - Given a mocked or local transport, Core completes one deterministic non-editor workflow and returns the expected result.
4. **Adapter resolution**
   - Given a configured provider, the expected adapter is selected and receives normalized inputs.
5. **CLI invocation**
   - Given the test configuration, the `cn` entry path starts and returns a deterministic result or documented error.
6. **Public Core import**
   - A small standalone Node/TypeScript fixture imports Core through its public API and completes a non-editor workflow.
7. **Dependency boundary**
   - Static and runtime checks reject VS Code, GUI, webview, browser-only, extension-only, and prohibited CLI modules.

### TDD Rules

- Run the baseline tests before any deletion.
- Record command, environment, duration, and result for every baseline test.
- Keep test inputs deterministic and free of credentials.
- Prefer mocks or local transports over network calls.
- Preserve failing tests as known-baseline findings; do not silently remove them.
- Any intentional behavior change requires an SDD contract update and a corresponding test update.

## Baseline Measurements

Record the following from a clean working tree:

| Measurement | Baseline value | Phase 6 value | Method |
| --- | --- | --- | --- |
| Commit SHA or tag | To record | To record | `git rev-parse HEAD` |
| Tracked file count | To record | To record | Repository file listing |
| Working-tree size excluding `.git` | To record | To record | Filesystem measurement |
| Dependency install duration | To record | To record | Timed clean install |
| CLI typecheck result | To record | To record | Retained CLI command |
| Core typecheck/build result | To record | To record | Retained Core command |
| CLI build result | To record | To record | Retained CLI command |
| Smoke-test result | To record | To record | Focused TDD test command |

Also record the attribution and notice state for both baseline and Phase 6: license files, copyright notices, third-party attribution files, package licensing fields, and notices required by retained vendored dependencies or generated assets.

Record tool versions, operating system, Node version, package-manager version, and relevant environment assumptions alongside the measurements.

## Dependency Inventory

For each package or surface, record:

- Name and path.
- Direct dependents.
- Runtime or build-time role.
- Static and dynamic import evidence.
- Configuration, plugin, registry, or asset-loading evidence.
- Keep, Remove, or Defer decision.
- Removal hypothesis, if applicable.
- Disconfirming check.
- Validation command and result proving the decision.

Do not infer removability from directory names alone. Check root and package manifests, lockfiles, TypeScript project references, build scripts, aliases, dynamic imports, plugin registries, generated paths, and runtime asset paths.

Use this decision format:

| Surface | Decision | Removal hypothesis | Disconfirming check | Result |
| --- | --- | --- | --- | --- |
| GUI package | Remove | No CLI/Core runtime, build, or asset dependency | Remove locally; run clean install, build, and smoke test | Pending |
| VS Code extension | Defer | Future surface is not in the first closure | Not applicable during Phase 1 | Deferred |
| Vendored model assets | Remove or Keep | Not used by the retained runtime path | Trace asset resolution and run smoke test | Pending |

## Baseline Procedure

1. Confirm the working tree and current branch are clean.
2. Create the dedicated reduction branch.
3. Record the baseline commit SHA or tag.
4. Record tool versions and repository measurements.
5. Install dependencies using the repository's current package-manager workflow.
6. Run the existing CLI/Core typechecks, builds, and focused tests.
7. Add or identify the required characterization tests.
8. Run the characterization tests and record their results.
9. Capture the dependency inventory and unresolved questions.
10. Review the Phase 0 evidence before beginning Phase 1 deletion work.

## Evidence Layout

Keep Phase 0 evidence in version-controlled, low-maintenance files. Prefer a structure such as:

```text
docs/reduction/
   phase-0-baseline.md
   cli-core-dependency-inventory.md
   cli-core-contracts.md
   phase-6-review.md
tests/characterization/
   config-parsing.test.*
   core-initialization.test.*
   adapter-resolution.test.*
   cli-invocation.test.*
   core-public-api.fixture.*
   dependency-boundary.test.*
```

Use the repository's established documentation and test locations when they differ; the layout is a recommendation, not an additional product requirement.

## Phase 0 Exit Criteria

Phase 0 is complete only when:

- The rollback point is recorded.
- Baseline measurements are reproducible.
- The CLI/Core dependency inventory is complete enough to support Keep, Remove, or Defer decisions.
- SDD product, build, runtime, boundary, and reduction contracts are reviewed.
- TDD characterization tests pass or have documented baseline failures.
- No test depends on credentials or an uncontrolled external provider.
- The next deletion batch has a stated hypothesis and a focused disconfirming check.
- `cn` and all relevant CLI/Core entry points are identified.
- Core's public import path is identified and tested externally.
- Dynamic imports, registries, plugins, generated paths, and runtime assets have been checked.
- Static and runtime boundary checks prohibit CLI/editor/UI coupling.
- License and attribution retention requirements are recorded.

## Phase 6 Final Review Contracts

Phase 6 must reuse the Phase 0 contracts and compare results rather than inventing a new standard after reduction.

### SDD Final Review Goals

- The final retained tree matches the approved CLI/Core scope.
- Every retained package has a documented reason to exist.
- Deferred VS Code/Core-only surfaces are clearly separated from the primary product.
- The Core public boundary remains usable and free of editor-specific coupling.
- README, licensing, attribution, build instructions, and product-scope documentation remain accurate.
- Any intentional behavior or feature loss is documented as a contract change.

### TDD Final Review Goals

- The Phase 0 characterization tests pass against the reduced tree, or approved contract changes have replacement tests.
- Clean installation, typechecking, building, CLI invocation, and the focused smoke test pass from a clean checkout.
- The public Core import fixture passes.
- Boundary tests confirm that removed or deferred surfaces are not loaded by CLI/Core.
- Stale imports, project references, scripts, assets, and workspace entries are absent.
- Static and runtime checks enforce the named prohibited-module denylist.
- Clean-install validation leaves the lockfile and tracked dependency metadata unchanged.
- License, copyright, third-party attribution, package licensing, and retained-asset notices are present and accurate.

### Final Review Evidence

Retain the following evidence before publication:

- Phase 0 and Phase 6 measurement tables.
- Final dependency graph and workspace package list.
- Test commands and results.
- Final diff and removal-batch commits.
- Rollback reference.
- Any approved exceptions or contract changes.

## Approval Gate

Phase 1 reduction work may begin only after the Phase 0 deliverables and exit criteria are reviewed. Phase 6 publication may proceed only when the SDD contracts and TDD tests agree on the final CLI/Core product, with any deviations explicitly approved.