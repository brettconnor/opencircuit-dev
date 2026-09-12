# Phase 0 Baseline Plan v1 Review

## Review Outcome

Phase 0 is not ready for approval. The plan is materially stronger than v0, but it still needs executable evidence requirements for rollback, installation, entry points, characterization tests, and dependency boundaries.

## Findings

### High: The rollback reference is ambiguous

The procedure records the baseline SHA before characterization tests and evidence are added (`phase0-baseline-plan_v1.md:190-198`). A rollback to that SHA would therefore omit the completed Phase 0 safety net required by the exit criteria (`phase0-baseline-plan_v1.md:226`).

Record two immutable references:

1. The original source baseline before Phase 0 changes.
2. A Phase-0-complete rollback tag containing the reviewed contracts, tests, inventories, measurements, and results.

Phase 1 should begin from the Phase-0-complete reference.

### High: Current behavior and the target architecture are conflated

The plan requires the CLI to import Core only through documented public exports and makes that boundary an exit condition (`phase0-baseline-plan_v1.md:101-106`, `phase0-baseline-plan_v1.md:233-236`).

The current CLI deep-imports Core internals, including:

- `extensions/cli/src/commands/chat.ts:4-5`
- `extensions/cli/src/tools/edit.ts:4-7`

In addition, `core/package.json` does not declare a `main` or `exports` entry. A public-only Core boundary is therefore a target architecture, not an accurate description of the current baseline.

Split the contract into:

- **Observed baseline:** current imports, entry points, coupling, and known failures.
- **Target invariant:** the public Core boundary expected after reduction.

Phase 0 should preserve and document existing violations rather than require product refactoring.

### High: The clean-install contract is not executable

The plan assumes one lockfile-enforced repository workflow (`phase0-baseline-plan_v1.md:54-64`, `phase0-baseline-plan_v1.md:194`). The repository instead has separate lockfiles for Core, CLI, and the local packages, with no root `packageManager` declaration.

The existing local dependency script also uses repeated `npm i` commands (`extensions/cli/package.json:19`), which do not satisfy the immutable-install requirement and may update dependency metadata.

The Phase 0 evidence must specify:

- The exact npm and Node.js versions.
- Every package included in the retained dependency closure.
- The install and build order.
- The exact command run in each package.
- Whether lifecycle scripts are enabled.
- The cache and network policy.
- Before-and-after hashes for every relevant lockfile.
- The expected handling of installation failures.

### Medium: Entry-point evidence needs concrete paths

The entry-point table remains generic (`phase0-baseline-plan_v1.md:83-89`), but the CLI has a multi-stage launch path:

```text
extensions/cli/src/index.ts
  -> extensions/cli/dist/index.js
  -> extensions/cli/dist/cn.js
  -> package.json bin.cn
```

The bundle entry and output are configured in `extensions/cli/build.mjs:37-42`. The executable wrapper is generated in `extensions/cli/build.mjs:91-96`, and the package mapping is declared in `extensions/cli/package.json:5-9`.

The inventory should also:

- Distinguish the CLI package `main` entry from the `cn` executable.
- Classify the `config-yaml` executable.
- Record installation scripts, shell wrappers, and development launch paths.
- Identify the actual Core import paths used by the CLI.

### Medium: Characterization tests lack auditable pass criteria

The required tests are appropriate, but the plan does not define a result schema (`phase0-baseline-plan_v1.md:119-143`). Each test needs:

| Evidence field | Required value |
| --- | --- |
| Test or fixture | Exact repository path |
| Command | Copy-and-paste command |
| Expected result | Exit code and meaningful output |
| Environment | Relevant variables and temporary home/config paths |
| Network | Disabled, mocked, or local transport |
| Duration | Recorded elapsed time |
| Result | Pass or documented baseline failure |
| Artifact | Log or report path |

The existing smoke test verifies bundle presence, version output, and help output (`extensions/cli/smoke-test.mjs:45-90`). It does not satisfy the deterministic Core initialization and controlled non-editor workflow requirements by itself.

The CLI invocation contract should define an exact expected exit code and output. “Deterministic result or documented error” is too broad because an unrelated startup failure could satisfy it.

### Medium: Boundary enforcement is underspecified

The plan says runtime enforcement is required “where practical” (`phase0-baseline-plan_v1.md:105-106`) but later makes static and runtime checks mandatory (`phase0-baseline-plan_v1.md:236`).

Define:

- The exact prohibited module and path denylist.
- The source-level static import command.
- The emitted or bundled dependency check.
- The runtime module-resolution check.
- Expected exceptions and their approval process.
- The command, output, and artifact proving each result.

The CLI build already produces `dist/meta.json` from the esbuild metafile (`extensions/cli/build.mjs:46`, `extensions/cli/build.mjs:88-89`), which should be included in the static dependency evidence.

## Required Evidence Before Approval

- Dedicated reduction branch.
- Original source baseline SHA or tag.
- Phase-0-complete rollback tag.
- Recorded Node.js, npm, operating-system, architecture, cache, and network conditions.
- Exact clean-install matrix for Core, CLI, and retained local packages.
- Complete CLI/Core entry-point inventory.
- Dependency inventory with Keep, Remove, or Defer decisions and disconfirming checks.
- Characterization test matrix with commands, fixtures, expected results, and artifacts.
- Named static and runtime boundary checks.
- Baseline install, typecheck, build, smoke-test, and characterization-test results.

## Repository State at Review

- Branch: `snyk-fix-16e608d0614787ae9564f8adb7d3c79a`
- HEAD: `a96202f57d650a4e42cc747d705e4d0e0ea24bf5`
- Tags at HEAD: none
- `docs/planning/`: untracked

The baseline branch and clean rollback point had not been established at the time of review.
