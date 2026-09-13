# Phase 5 CLI/Core Validation Summary

## Status

**Blocked with evidence pending Git integration publication.** The original
Core failure is fixed locally, but authoritative Ubuntu1 post-change
validation cannot run until the durable branch is published. No push, PR, or
merge was attempted by the phase executor.

## Failure and root cause

On Ubuntu1 (`10.1.141.9`, Node.js `v24.19.0`, npm `11.17.0`), fixed runner
mode `--phase5-diagnose` reproduced the failure three times from clean
`core/dist` state. Core build exited `0` each time; `tsc:check` exited `2`
each time with:

```text
core.ts(1185,7): error TS2322:
Type '.../core/indexing/CodebaseIndexer'.CodebaseIndexer
is not assignable to type
'.../core/dist/indexing/CodebaseIndexer'.CodebaseIndexer.
Types have separate declarations of a private property 'configHandler'.
```

Resolution tracing showed the source declaration and generated `dist`
declaration were both selected through Core's package self-reference. The
root cause is a source-versus-dist declaration identity split, amplified by
the broad `./**/*.d.ts` includes in `core/tsconfig.json` and
`core/tsconfig.npm.json`.

## Fix

Commit `5e2685e07` removes the broad declaration-file includes and changes the
public `ToolExtras.codeBaseIndexer` contract to the one public method consumed
by tool implementations. This preserves type safety at the retained boundary
without exposing a nominal private-class identity across source and generated
package declarations. No lockfile changed, no suppression or exclusion of
the failing source was added, and no deferred surface was touched.

## Validation

Local targeted validation passed:

- Core clean `npm run build`
- Core `npm run tsc:check`
- CLI `npm run typecheck`
- CLI `npm run build:validate`
- CLI `npm run build`
- CLI `npm run test:smoke`
- CLI config and model characterization tests (12 tests)
- Static and emitted boundary checks

The fixed post-change Ubuntu1 invocation was attempted with
`--phase5-validate --branch reduce/phase5-cli-core-validation` and was
blocked before validation because GitHub has no published ref for that local
branch. Evidence is in
`docs/reduction/artifacts/phase5/P5-DIAG/post-change/validation-blocker.md`.

## Commits and rollback

- Runner: `6c3b95c`, rollback:
  `git -C /Users/brettcon/git/systems-orchestration revert 6c3b95c`
- Runner evidence output: `6d18794`, rollback:
  `git -C /Users/brettcon/git/systems-orchestration revert 6d18794`
- Diagnosis evidence: `b98a77a9e`, rollback:
  `git revert b98a77a9e`
- Core fix: `5e2685e07`, rollback:
  `git revert 5e2685e07`

## Required handoff

The Git integration agent should publish branch
`reduce/phase5-cli-core-validation` without rebasing, then run the exact fixed
Ubuntu1 command:

```text
/Users/brettcon/git/systems-orchestration/scripts/open-circuit-runner.sh \
  --hosts-file /Users/brettcon/git/hosts/ubuntu1-hosts.sh \
  --branch reduce/phase5-cli-core-validation \
  --phase5-validate
```

Phase 4 D2/D3/D4 retained-closure validation is not claimed restored until
that command passes and its returned artifacts are recorded.
