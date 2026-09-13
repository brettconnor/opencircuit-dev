# Phase 5 CLI/Core Validation Execution Ledger

## Entry checkpoint

- Plan: `docs/planning/phase5-cli-core-validation_v2.md`
- Phase branch: `reduce/phase5-cli-core-validation`
- Starting checkpoint: `8a6a2ebd1` (`docs(phase5): define single HITL entry gate`)
- Legacy plan preserved untouched: `docs/planning/phase5-cli-core-validation.md`
- Runner commits: `6c3b95c` (`feat(phase5): add fixed CLI core validation modes`),
  `6d18794` (`docs(phase5): expose diagnosis evidence fields`)
- Authoritative host: Ubuntu1 (`10.1.141.9`)
- Required runtime: Node.js `24.19.0`, npm `11.17.0`
- Remote validation branch used before publication: `reduce/phase4-reversible-deletion`

## Batch ledger

| Batch | Commit | Scope | Hypothesis/result | Runner evidence | Artifacts | Validation | Rollback | Continuation | Exception |
|---|---|---|---|---|---|---|---|---|---|
| P5-DIAG | `6c3b95c`, `6d18794` (runner repo) | Fixed runner diagnosis mode; Phase 5 pre-change evidence | Deterministic Core `TS2322` reproduced in all three runs. Root cause is a source-vs-dist declaration split: `core/index.d.ts` resolves `CodebaseIndexer.ts`, while `core/dist/index.d.ts` resolves `CodebaseIndexer.d.ts`; private `configHandler` identity differs. | Ubuntu1 (`10.1.141.9`), Node `v24.19.0`, npm `11.17.0`; fixed mode `--phase5-diagnose`; remote commit `9f69a3206`; runner exit `0`; each build exit `0`, each `tsc:check` exit `2` | `docs/reduction/artifacts/phase5/P5-DIAG/pre-change/diagnosis-evidence.md`; raw runner log is gitignored; sanitized: yes | Diagnosis passed; remediation authorized by evidence | `git -C /Users/brettcon/git/systems-orchestration revert 6c3b95c` and `6d18794` | Continue to narrow Core config fix | None |
| P5-FIX | `5e2685e07` | `core/index.d.ts`, `core/tsconfig.json`, `core/tsconfig.npm.json` | Narrow structural boundary plus declaration-input cleanup removes the nominal source-vs-dist identity conflict without suppressing type safety or changing a lockfile | Local clean Core build/typecheck passed; authoritative post-change runner was attempted but branch publication blocked before remote validation | `docs/reduction/artifacts/phase5/P5-DIAG/post-change/validation-blocker.md`; sanitized: yes | Local Core/CLI retained checks passed; Ubuntu1 profile pending publication | `git revert 5e2685e07` | Stop and hand off for Git publication | `P5-PUBLISH-001` |

## Budget

- Diagnostic/fix batches used: `2 / 6` (diagnosis, fix)
- Atomic commits in Phase 5 work: `5 / 10` (including two runner-repository commits)
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
CLI/Core runtime, smoke, headless, bundle, or boundary failure.
