# Phase 5 CLI/Core Validation Execution Ledger

## Entry checkpoint

- Plan: `docs/planning/TS2322-PLAN_v0.md`
- Phase branch: `reduce/phase5-cli-core-validation`
- Starting checkpoint: `8a6a2ebd1` (`docs(phase5): define single HITL entry gate`)
- Legacy plan preserved untouched: `docs/planning/phase5-cli-core-validation.md`
- Runner commits: `6c3b95c` (`feat(phase5): add fixed CLI core validation modes`),
  `6d18794` (`docs(phase5): expose diagnosis evidence fields`),
  `ba52121cca51b7ce951320fdbee4902ebaec7ea1`
- Authoritative host: Ubuntu1 (`10.1.141.9`)
- Required runtime: Node.js `24.19.0`, npm `11.17.0`
- Remote validation branch used before publication: `reduce/phase4-reversible-deletion`

## Batch ledger

| Batch | Commit | Scope | Hypothesis/result | Runner evidence | Artifacts | Validation | Rollback | Continuation | Exception |
|---|---|---|---|---|---|---|---|---|---|
| P5-DIAG | `6c3b95c`, `6d18794` (runner repo) | Fixed runner diagnosis mode; Phase 5 pre-change evidence | Deterministic Core `TS2322` reproduced in all three runs. Root cause is a source-vs-dist declaration split: `core/index.d.ts` resolves `CodebaseIndexer.ts`, while `core/dist/index.d.ts` resolves `CodebaseIndexer.d.ts`; private `configHandler` identity differs. | Ubuntu1 (`10.1.141.9`), Node `v24.19.0`, npm `11.17.0`; fixed mode `--phase5-diagnose`; remote commit `9f69a3206`; runner exit `0`; each build exit `0`, each `tsc:check` exit `2` | `docs/reduction/artifacts/phase5/P5-DIAG/pre-change/diagnosis-evidence.md`; raw runner log is gitignored; sanitized: yes | Diagnosis passed; remediation authorized by evidence | `git -C /Users/brettcon/git/systems-orchestration revert 6c3b95c` and `6d18794` | Continue to narrow Core config fix | None |
| P5-FIX | `5e2685e07` | `core/index.d.ts`, `core/tsconfig.json`, `core/tsconfig.npm.json` | Narrow structural boundary plus declaration-input cleanup removes the nominal source-vs-dist identity conflict without suppressing type safety or changing a lockfile | Full local retained-closure matrix, Core/CLI checks, focused characterization, supported package-consumer fixture, and static/emitted boundary checks passed; local runtime boundary is limited by Node.js `v26.7.0` | `docs/reduction/artifacts/phase5/P5-FIX/post-change/validation-evidence.md`; sanitized: yes | Ubuntu1 profile pending publication | `git revert 5e2685e07` | Continue to authoritative publication | `P5-PUBLISH-001` |
| P5-HARNESS | `ba52121cca51b7ce951320fdbee4902ebaec7ea1` (runner repo) | `scripts/open-circuit-runner.sh`, its SDD contract, and TDD contract test | Correct the Phase 5 stale-reference scan so approved bare `core` package imports are not treated as relative filesystem references | Runner contract suite, new regression test, shell syntax, and dry-run checks passed; matcher changed from `(...)*core` to `(...)+core` | `docs/reduction/artifacts/phase5/P5-FIX/post-change/validation-evidence.md`; sanitized: yes | Fixed profile is ready for rerun after publication | `git -C /Users/brettcon/git/systems-orchestration revert ba52121cca51b7ce951320fdbee4902ebaec7ea1` | Continue to authoritative publication | None |

## Budget

- Diagnostic/fix batches used: `3 / 6` (diagnosis, fix, validation-harness correction)
- Atomic commits in Phase 5 work: `6 / 10` (including three runner-repository commits)
- Core source/config files changed in the fix batch: `3 / 15`
- CLI files changed per batch: `0 / 10`
- Lockfiles changed without explicit approval: `0`
- Broad dependency upgrades: `0`
- Type-safety suppressions or exclusions: `0`
- Unexplained validation failures: `0`

## Stop-condition policy

The phase executor will stop with evidence if Ubuntu1 validation requires the
unpublished Phase 5 branch, a deferred surface, a broad dependency change,
an unsafe type workaround, an unexpected lockfile mutation, or any retained
CLI/Core runtime, smoke, bundle, or boundary failure.
