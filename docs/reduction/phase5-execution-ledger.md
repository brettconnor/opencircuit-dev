# Phase 5 CLI/Core Validation Execution Ledger

## Entry checkpoint

- Plan: `docs/planning/TS2322-PLAN_v0.md`
- Phase branch: `reduce/phase5-cli-core-validation`
- Final tested branch tip: `36c7bff60`
- Starting checkpoint: `8a6a2ebd1` (`docs(phase5): define single HITL entry gate`)
- Legacy plan preserved untouched: `docs/planning/phase5-cli-core-validation.md`
- Runner commits: `6c3b95c` (`feat(phase5): add fixed CLI core validation modes`),
  `6d18794` (`docs(phase5): expose diagnosis evidence fields`),
  `f463d28e824b612d5eea762e7b106b22aca1308a`, `dba6c7d`
- Authoritative host: Ubuntu1 (`10.1.141.9`)
- Required runtime: Node.js `24.19.0`, npm `11.17.0`
- Remote validation directory: `~/open-circuit-dev-phase5-validation`

## Batch ledger

| Batch      | Commit                                                              | Scope                                                                     | Hypothesis/result                                                                                                                                                                                                                                                    | Runner evidence                                                                                                                                                                                                         | Artifacts                                                                                                                | Validation                                           | Rollback                                                                                                   | Continuation                                   | Exception        |
| ---------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------- | ---------------- |
| P5-DIAG    | `6c3b95c`, `6d18794` (runner repo)                                  | Fixed runner diagnosis mode; Phase 5 pre-change evidence                  | Deterministic Core `TS2322` reproduced in all three runs. Root cause is a source-vs-dist declaration split: `core/index.d.ts` resolves `CodebaseIndexer.ts`, while `core/dist/index.d.ts` resolves `CodebaseIndexer.d.ts`; private `configHandler` identity differs. | Ubuntu1 (`10.1.141.9`), Node `v24.19.0`, npm `11.17.0`; fixed mode `--phase5-diagnose`; remote commit `9f69a3206`; runner exit `0`; each build exit `0`, each `tsc:check` exit `2`                                      | `docs/reduction/artifacts/phase5/P5-DIAG/pre-change/diagnosis-evidence.md`; raw runner log is gitignored; sanitized: yes | Diagnosis passed; remediation authorized by evidence | `git -C /Users/brettcon/git/systems-orchestration revert 6c3b95c` and `6d18794`                            | Continue to narrow Core config fix             | None             |
| P5-FIX     | `5e2685e07`                                                         | `core/index.d.ts`, `core/tsconfig.json`, `core/tsconfig.npm.json`         | Narrow structural boundary plus declaration-input cleanup removes the nominal source-vs-dist identity conflict without suppressing type safety or changing a lockfile                                                                                                | Full local retained-closure matrix, Core/CLI checks, focused characterization, supported package-consumer fixture, and static/emitted boundary checks passed; local runtime boundary is limited by Node.js `v26.7.0`    | `docs/reduction/artifacts/phase5/P5-FIX/post-change/validation-evidence.md`; sanitized: yes                              | Ubuntu1 profile pending publication                  | `git revert 5e2685e07`                                                                                     | Continue to authoritative publication          | `P5-PUBLISH-001` |
| P5-HARNESS | `f463d28e824b612d5eea762e7b106b22aca1308a`, `dba6c7d` (runner repo) | `scripts/open-circuit-runner.sh`, its SDD contract, and TDD contract test | Correct the stale-reference scan, clean ignored Core output, and install root workspace dependencies before `npm ls`                                                                                                                                                 | Runner contract suite, regression tests, shell syntax, and dry-run checks passed; the matcher requires relative path segments, `clean-core-dist` precedes Core install/build, and root `npm ci` precedes workspace scan | `docs/reduction/artifacts/phase5/P5-FIX/post-change/validation-evidence.md`; sanitized: yes                              | Fixed profile passed authoritatively                 | `git -C /Users/brettcon/git/systems-orchestration revert dba6c7d f463d28e824b612d5eea762e7b106b22aca1308a` | Hand off runner publication to Git integration | None             |
| P5-AUTH    | `36c7bff60` (open-circuit-dev), runner `dba6c7d`                    | Ubuntu1 authoritative retained-closure profile                            | The Core boundary fix remains valid under the pinned production-like runtime after a clean isolated checkout                                                                                                                                                         | All fixed-profile steps passed; remote commit matched the tested branch tip                                                                                                                                             | `docs/reduction/artifacts/phase5/P5-FIX/post-change/authoritative-validation.md`; sanitized: yes                         | Ubuntu1 pass; Phase 4 retained closure restored      | `git revert 5e2685e07`                                                                                     | Hand off branch and runner to Git integration  | None             |

## Budget

- Diagnostic/fix batches used: `5 / 6` (diagnosis, fix, three validation-harness corrections)
- Atomic commits in Phase 5 work: `8 / 10` (including five runner-repository commits)
- Core source/config files changed in the fix batch: `3 / 15`
- CLI files changed per batch: `0 / 10`
- Lockfiles changed without explicit approval: `0`
- Broad dependency upgrades: `0`
- Type-safety suppressions or exclusions: `0`
- Unexplained validation failures: `0`

## Stop-condition policy

The phase executor stopped only for the observed publication and runner
setup blockers, both of which were resolved and recorded. The authoritative
profile then passed without a deferred surface, broad dependency change,
unsafe type workaround, unexpected lockfile mutation, or retained CLI/Core
runtime, smoke, bundle, or boundary failure.
