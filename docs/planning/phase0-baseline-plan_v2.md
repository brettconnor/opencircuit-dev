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

## Immutable References and Rollback

Create two separate immutable references:

| Reference | Purpose | When created |
| --- | --- | --- |
| `phase0-source-baseline` | Original repository state before Phase 0 artifacts | Before Phase 0 changes |
| `phase0-cli-core-complete` | Reviewed Phase 0 evidence, contracts, inventories, tests, and results | After all Phase 0 exit criteria pass |

Phase 1 begins only from `phase0-cli-core-complete`. Revert individual reduction commits or reset a local worktree to that tag. Use `phase0-source-baseline` to recover the original unmodified repository. Do not rewrite history during Phase 0 or Phase 1.

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

A clean dependency install is package-specific because the current repository has separate lockfiles and an existing local dependency build sequence:

- Start from a clean checkout.
- Remove repository-local dependency artifacts such as `node_modules` and package-manager install state.
- Do not modify the lockfile during validation.
- Record exact Node.js and npm versions, working directory, install command, lifecycle-script policy, build order, and lockfile path for Core, CLI, and each retained local package.
- Use the current package-specific install command where immutable installation is unsupported, and record that limitation rather than calling it immutable.
- Capture before-and-after SHA-256 hashes for every relevant lockfile.
- Fail validation if tracked dependency metadata changes unexpectedly.

An install that changes a lockfile, requires credentials, fails because of missing local build artifacts, or depends on undocumented ordering is a documented baseline failure, not a silent pass. Record the exact output, affected package, recovery action, and Phase 1 remediation decision.

Distinguish clean-checkout validation from clean-install validation. An optional offline or cache-free run may provide stronger evidence, but it is not required if the repository's package-manager constraints make it impractical.

## SDD Specification

### Observed Baseline Contract

Record the repository as found, without requiring future architecture. At minimum, record:

- CLI source entry: `extensions/cli/src/index.ts`.
- CLI build output: `extensions/cli/dist/index.js`.
- CLI executable output: `extensions/cli/dist/cn.js`.
- Executable mapping: `extensions/cli/package.json` `bin.cn`.
- Bundle and wrapper generation: `extensions/cli/build.mjs`.
- Existing smoke test: `extensions/cli/smoke-test.mjs`.
- Actual CLI-to-Core deep imports and their resolved paths.
- Core package export state, including whether `main` or `exports` is declared.

The current Core boundary may be undeclared or coupled to implementation paths. That is observed evidence and does not fail Phase 0 by itself.

### Target Architecture Invariant

After the CLI/Core reduction, the CLI must consume Core through a documented, deliberately exported API. Core must not depend on CLI, VS Code, GUI, webview, browser, or extension-activation modules except through approved adapter interfaces. This is a Phase 1/Phase 6 target, not a Phase 0 baseline requirement.

### Product Contract

The target product is a buildable CLI that uses Continue Core for a non-editor workflow. The CLI remains the user-facing entry point, and Core is intended to become independently consumable through deliberate public exports.

### Build Contract

- A clean checkout can install the declared dependencies.
- The retained local packages can be built in dependency order.
- Core can be built through its intended package configuration.
- The CLI can be typechecked and bundled through its intended scripts.

### Entry-Point Contract

Inventory all executable and public package paths before deletion:

| Entry point | Source package or path | Intended role | CLI/Core scope | Validation |
| --- | --- | --- | --- | --- |
| CLI source entry | `extensions/cli/src/index.ts` | Source-level launch path | Keep | Import and build evidence |
| CLI package main | `extensions/cli/package.json` `main`, if present | Programmatic package entry | Keep or investigate | Package metadata and runtime check |
| Main bundle | `extensions/cli/dist/index.js` | Built package entry | Keep | Build artifact check |
| `cn` executable | `extensions/cli/dist/cn.js` and `bin.cn` | Primary CLI executable | Keep | CLI invocation test |
| Core public export | `core/package.json` and actual exports | Reusable library API | Target; baseline may be unavailable | Standalone fixture or documented gap |
| `config-yaml` executable | Actual package manifest and `bin` path | User-facing or internal executable | Investigate | Dependency evidence |
| Other executable or launcher | Actual manifest or script path | Unknown or deferred | Investigate | Dependency evidence |

Inspect root scripts, all `bin` declarations, `exports` maps, CLI subcommand registrations, package publishing entry points, runtime build outputs, shell wrappers, development launch paths, and launcher scripts. Record the exact CLI-to-Core import specifiers and resolved paths.

### Runtime Contract

- The `cn` entry point can be invoked through the supported CLI start path.
- A minimal configuration can be parsed without VS Code, GUI, or editor dependencies.
- Core initialization completes for the supported non-editor workflow.
- Provider or adapter resolution follows the selected configuration.
- External model calls are mocked or locally transported in validation unless a live provider is explicitly required.

### Boundary Contract

- The target CLI imports Core through documented public exports.
- The target Core does not import CLI modules, VS Code APIs, terminal UI modules, GUI/browser code, or extension activation code.
- Environment-specific behavior is isolated behind existing interfaces or adapters where practical.
- The CLI/Core closure does not depend on deferred product surfaces without an explicit recorded exception.
- Maintain a named denylist derived from the actual repository layout, including `vscode`, extension activation modules, webview/UI modules, browser-only modules, and CLI paths imported by Core.
- Enforce the denylist with static source checks, emitted-bundle checks, and runtime module-resolution checks. Baseline violations are recorded findings; they are not Phase 0 failures unless they prevent characterization.

Every exception must record an ID, exact forbidden item, surface, reason, evidence, owner, scope, removal condition, and approval reference.

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
   - Given the test configuration, the `cn` entry path returns either exit code `0` with stable expected output or an exact intentional validation error with a documented non-zero exit code. Startup or module-resolution failures are not acceptable expected errors.
6. **Public Core import**
   - A small standalone Node/TypeScript fixture imports Core through its public API and completes a non-editor workflow. If no public export exists at baseline, record the actual import path and mark this as a target-architecture gap.
7. **Dependency boundary**
   - Static source, emitted-bundle, and runtime checks report VS Code, GUI, webview, browser-only, extension-only, and prohibited CLI modules against a named denylist.

### TDD Rules

- Run the baseline tests before any deletion.
- Record command, environment, duration, and result for every baseline test.
- Keep test inputs deterministic and free of credentials.
- Prefer mocks or local transports over network calls.
- Preserve failing tests as known-baseline findings; do not silently remove them.
- Any intentional behavior change requires an SDD contract update and a corresponding test update.
- Every result records the exact fixture path, working directory, copyable command, expected exit code, stable output assertion, environment names, network mode, duration, result, and artifact path.

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

The install matrix must contain one directly runnable row for Core, CLI, and every retained local package, including lockfile path, install command, lifecycle policy, build command, typecheck command, test or smoke command, and lockfile hashes before and after installation.

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
- `phase0-source-baseline` identifies the original source state.
- `phase0-cli-core-complete` identifies the reviewed Phase 0 safety-net state.
- Baseline measurements are reproducible.
- The CLI/Core dependency inventory is complete enough to support Keep, Remove, or Defer decisions.
- SDD product, build, runtime, boundary, and reduction contracts are reviewed.
- TDD characterization tests pass or have documented baseline failures.
- No test depends on credentials or an uncontrolled external provider.
- The next deletion batch has a stated hypothesis and a focused disconfirming check.
- `cn` and all relevant CLI/Core entry points are identified.
- Core's current export state and CLI deep-import paths are documented; external public-import validation is recorded as unavailable until the target API exists.
- Dynamic imports, registries, plugins, generated paths, and runtime assets have been checked.
- Static source, emitted-bundle, and runtime boundary checks are defined, run, and reported against a named denylist.
- All boundary exceptions are documented and approved.
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