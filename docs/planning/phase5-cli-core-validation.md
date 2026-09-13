Agreed. The prior Phase 5 draft over-governed an evidence-gathering task.

For W1, treat this as an **autonomous diagnostic-and-remediation phase**, with normal Git commits and validation gates—not approval gates. Copilot should proceed until it either fixes the issue or produces evidence that the issue needs a materially different approach.

Replace the 19-section plan with this concise version.

---

# `docs/planning/phase5-cli-core-validation.md`

# Phase 5: CLI/Core Validation

**Status:** Execute autonomously on a dedicated phase branch.
**Purpose:** Identify and resolve the Core `TS2322` type-identity failure, then restore a passing CLI/Core retained-closure validation baseline.

## Scope

Included:

- Core `TS2322` reproduction and diagnosis
- TypeScript resolution, declaration output, aliases, package identity, and dependency analysis
- Narrow fixes to Core TypeScript/build/package-resolution configuration when evidence supports them
- Required tests and validation artifacts
- Re-baselining only if the error is proven non-remediable within the current product contract

Excluded:

- New repository deletion batches
- VS Code, GUI, binary, docs-site, or deferred-surface work
- Broad dependency upgrades
- Unrelated refactors
- History rewriting

## Working model

Use one phase branch:

```text
reduce/phase5-cli-core-validation
```

Make atomic commits for each meaningful result:

```text
test(phase5): capture TS2322 reproduction evidence
fix(core): resolve duplicate type identity
test(validation): restore retained closure matrix
docs(phase5): record validation closeout
```

No per-step PRs, approval gates, or manual checkpoints are required. Continue automatically when tests pass and the work remains in scope.

## Execution steps

1. Start from current `main`; create the Phase 5 branch.
2. Record Node, npm, TypeScript, OS, and commit SHA.
3. Reproduce the Core failure from a clean `core/dist` state:
   ```bash
   cd core
   rm -rf dist
   npm run build
   npm run tsc:check
   ```
4. Capture the exact `TS2322` error, locations, involved types, and resolved module paths.
5. Run the failure three times to determine whether it is deterministic.
6. Compare Core build and typecheck scripts, `tsconfig` files, aliases, project references, and compiler versions.
7. Run TypeScript resolution tracing for the failing path.
8. Inspect dependency identity using `npm ls`, lockfile evidence, and package resolution paths.
9. Compare source declarations with fresh generated `dist` declarations.
10. Determine the root cause:
    - duplicate package/type identity;
    - source-versus-dist resolution split;
    - alias/package self-reference split;
    - mismatched TypeScript configuration;
    - stale generated declarations;
    - genuine source incompatibility;
    - environment mismatch.
11. Apply the narrowest evidence-backed fix.
12. Re-run clean Core install, build, and typecheck.
13. Run CLI typecheck and build.
14. Run CLI smoke and controlled headless workflow.
15. Run configuration parsing, model selection, and adapter normalization characterization tests.
16. Run static/emitted-bundle and runtime boundary checks.
17. Compare lockfile hashes and ensure no unexpected dependency metadata changed.
18. Commit the fix and all reproducible evidence.
19. Write the Phase 5 closeout: root cause, fix, commands, results, rollback commit, and any remaining limitation.

## Required validation

A successful Phase 5 result requires:

```bash
# Core
cd core
npm ci --ignore-scripts --no-audit --no-fund
npm run build
npm run tsc:check

# CLI
cd ../extensions/cli
npm ci --ignore-scripts --no-audit --no-fund
npm run typecheck
npm run build
npm run test:smoke

# Characterization and boundaries
cd ../..
node tests/characterization/boundary-check.mjs
node tests/characterization/runtime-boundary-check.mjs
```

Also run the established deterministic loopback/headless workflow and the existing configuration, model-selection, and adapter-normalization tests.

## Automatic stop conditions

Stop only when one of these occurs:

- the root cause requires a broad dependency upgrade;
- the fix requires deleting or changing deferred product surfaces;
- the fix requires a Core public API redesign;
- the failure is non-deterministic across the selected environment;
- the typecheck passes only by suppressing, excluding, weakening, or bypassing meaningful type safety;
- a retained CLI/Core runtime, smoke, headless, bundle, or boundary test fails after the attempted fix.

Otherwise, continue through diagnosis, remediation, validation, and closeout autonomously.

## Completion criteria

Phase 5 is complete when either:

### Fixed

- `core npm run tsc:check` passes;
- clean install, build, and retained CLI/Core validation pass;
- no unexpected lockfile or dependency changes exist;
- the root cause and correction are documented.

### Blocked with evidence

- the failure is precisely characterized;
- attempted narrow fixes are documented;
- the required next technical action is identified;
- no unsafe suppression or unrelated workaround was introduced.

## Output

Create:

```text
docs/reduction/phase5-summary.md
docs/reduction/artifacts/phase5/
```

The summary must state:

- failure signature;
- root cause;
- selected fix or blocking condition;
- commits;
- exact commands and results;
- validation status;
- rollback command;
- whether D2/D3/D4 reduction validation is restored.
