# Cut the Fat Plan

## Goal

Reduce the repository to a focused, functional CLI backed by Continue Core while preserving a buildable dependency closure. Keep Core as the reusable library boundary so a secondary VS Code surface remains possible.

## Product Surface Scope

### Primary: CLI/Core

The first reduction targets the CLI and its Core runtime. Retain the local packages required to build and run that product:

- `config-types`
- `config-yaml`
- `fetch`
- `llm-info`
- `openai-adapters`
- `terminal-security`

### Secondary: VS Code and Core-Only

After the CLI/Core product passes clean-install, build, and smoke-test validation:

- Evaluate the VS Code extension as a follow-on product surface.
- Preserve Core's public API as the reusable library-only boundary.
- Do not retain GUI, VS Code-specific, or extension packaging code in the first deletion pass unless the dependency review proves it is required by CLI/Core.

## High-Level Steps

1. Establish a rollback point and capture baseline measurements.
2. Map the CLI/Core direct and transitive dependencies using manifests, lockfiles, project references, imports, dynamic loading, registries, and runtime asset paths.
3. Classify repository areas as Keep, Remove, or Defer.
4. Confirm the CLI/Core dependency closure and Core library boundary.
5. Remove non-required surfaces in small, reversible batches.
6. Update workspace configuration, scripts, lockfiles, and CI for the retained closure.
7. Reinstall dependencies and run CLI/Core type checks, builds, and a focused functional smoke test from a clean checkout.
8. Review the CLI/Core result before evaluating the secondary VS Code or core-only surfaces.
9. Review the resulting tree, file count, repository size, and final diff before publishing.

## Phase 0: Baseline

Before deleting anything:

- Create a dedicated reduction branch, such as `reduce/cli-core`.
- Record the current commit SHA as the rollback point.
- Capture repository file count and size excluding `.git`.
- Record clean-install duration, CLI build/typecheck results, and the current smoke-test command and result.
- Confirm the package manager and workspace topology from the root manifest and lockfile.

Keep Git history intact. Use ordinary commits for each removal batch so individual decisions can be reverted without affecting unrelated work.

## Phase 1: Dependency Inventory

The initial retained closure is:

| Package or surface | Role | Status |
| --- | --- | --- |
| CLI | User entry point and primary product | Keep |
| Core | CLI runtime and reusable library boundary | Keep |
| `config-types` | Shared configuration contracts | Keep |
| `config-yaml` | YAML configuration loading | Keep |
| `fetch` | Network abstraction | Keep |
| `llm-info` | Model capability metadata | Keep |
| `openai-adapters` | Provider compatibility | Keep |
| `terminal-security` | Terminal and command safety boundary | Keep |
| VS Code extension | Secondary product surface | Defer |
| GUI/web application | Out of scope for the first pass | Remove after confirmation |

For each retained package, record what requires it, whether it is runtime or build-time, why it is required, and its current status. Use the workspace package graph rather than directory names alone. Confirm configuration-based loading, plugin registries, dynamic imports, generated paths, and runtime assets before removing anything.

## Phase 2: Repository Classification

### Keep

- CLI source, runtime assets, tests, and build configuration required for validation.
- Core source and deliberate public exports.
- The six approved local packages.
- Shared utilities in the actual CLI/Core dependency closure.
- TypeScript, lint, test, build, workspace, and CI configuration required by the retained closure.
- License, attribution notices, a minimal README, and one focused smoke test.

### Remove After Confirmation

- GUI/web application code and browser-only tooling.
- Demos, examples, prototypes, unrelated applications, and experimental packages.
- Docs-site infrastructure, screenshots, and marketing assets not needed by the retained product.
- VS Code-only commands, views, webviews, activation logic, and marketplace packaging assets.
- Vendored local models, model binaries, and generated assets not required by CLI/Core.
- Generated output that can be rebuilt and is not required for installation.
- Tests and CI jobs serving only removed surfaces.

### Defer

Do not delete these during the first pass merely because CLI does not use them:

- VS Code extension source, packaging, release configuration, tests, and documentation.
- Core-only package publishing configuration.

Mark these as deferred pending the CLI/Core validation gate.

## Phase 3: Core Boundary

Core must remain independently consumable by the CLI now and by a possible VS Code extension later.

- CLI imports Core through documented public exports only.
- Core must not import CLI, terminal UI, VS Code APIs, extension activation code, or GUI/browser code.
- Environment-specific behavior should use interfaces or adapters for filesystem access, terminal interaction, credentials, telemetry, editor integration, and command execution.
- Avoid re-exporting CLI-specific implementation details from Core.

Acceptance check: a small standalone Node/TypeScript program can import Core and execute a non-editor workflow without importing the CLI.

## Phase 4: Reversible Deletion

Perform deletion in scoped commits:

1. Documentation and non-product assets.
2. Unrelated applications and prototypes.
3. GUI/web surface and browser-only tooling.
4. Generated and vendored artifacts.
5. Surface-specific tests and CI.
6. Workspace, build, script, lockfile, and project-reference cleanup.

After each batch, validate workspace configuration, search retained code for stale references to removed paths, check build configuration for stale project references, and commit with a scoped message.

## Phase 5: CLI/Core Validation Gate

From a clean checkout:

- Remove local dependency artifacts and perform a clean install.
- Run retained typechecks and builds.
- Start or invoke the CLI through its intended entry point.
- Run a deterministic smoke test using a temporary minimal YAML configuration.
- Exercise configuration parsing, Core initialization, adapter resolution, and a mocked or local transport rather than a live provider.
- Confirm no editor, GUI, or extension dependency is loaded.
- Confirm Core remains importable through its intended public API.
- Search for stale references to removed packages, paths, assets, scripts, and workspace names.

The first reduction is complete only when this gate passes.

## Phase 6: Final Review

Before merging or publishing, review:

- Final workspace package list and dependency graph.
- File count and repository size compared with the baseline.
- Root scripts, CI workflows, and lockfile changes.
- License and attribution retention.
- Core public API exports.
- Full diff for accidental deletion of required build metadata or notices.

Document the resulting product scope in the README or an `ARCHITECTURE.md` file: CLI backed by Core is primary; the six local packages are retained; Core is reusable; VS Code is deferred; GUI, web, custom applications, and unrelated packages are excluded; rollback uses the baseline tag or reduction commits; history is not rewritten without separate approval.

## Clean-Room Reference Constraint

If `circuit-darwin-arm64-1.4.0.vsix` is used as a reference, use it only for black-box behavioral and packaging observations, such as public manifest metadata, command names, configuration behavior, activation behavior, compatibility expectations, and error handling.

Do not copy bundled source, proprietary assets, internal endpoints, credentials, organizational data, or distinctive implementation structure. Build CLI/Core behavior from independent requirements and public architecture, then validate the intended compatibility goals.

## Scope Boundaries

- Keep a minimal README, license, build instructions, and focused validation test.
- Treat CLI/Core as the first implementation and verification target.
- Preserve Core as a reusable library boundary beneath the CLI and any later VS Code surface.
- Defer VS Code support until the CLI/Core reduction is buildable and functionally validated.
- Preserve Git history by default.
- Treat any history rewrite as a separate decision requiring an explicit force-push review.
- Do not delete code until the CLI/Core dependency closure is confirmed.

## Verification

- A clean dependency install succeeds.
- The retained entry point builds or starts.
- The focused smoke test passes.
- No retained imports reference removed packages or assets.
- The final diff and size reduction are reviewed before publication.

## Approval Gate

Implementation begins with CLI/Core as the primary product surface. VS Code and core-only are secondary follow-on surfaces and should be evaluated after the first reduction passes validation. Any custom application scope requires a separate approval.