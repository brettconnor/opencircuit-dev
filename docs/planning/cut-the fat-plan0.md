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

1. Map the CLI/Core direct and transitive dependencies.
2. Classify repository areas as required, removable, or deferred, including documentation, tests, demos, packaging, generated assets, vendored models, GUI code, VS Code code, and unrelated applications.
3. Record the approved CLI/Core scope, exclusions, dependency rules, and rollback approach.
4. Remove non-required surfaces in small batches, keeping the CLI, Core, required local packages, configuration, licensing, and build metadata.
5. Reinstall dependencies and run CLI/Core type checks, builds, and a focused functional smoke test.
6. Review the CLI/Core result before evaluating the secondary VS Code or core-only surfaces.
7. Review the resulting tree, file count, and repository size before publishing.

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