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

Local retained-closure and targeted validation passed:

- retained local-package install/build/test matrix in dependency order
- Core clean `npm run build`
- Core `npm run tsc:check`
- supported emitted-package consumer fixture for `ToolExtras`
- CLI `npm run typecheck`
- CLI `npm run build:validate`
- CLI `npm run build`
- CLI `npm run test:smoke`
- CLI config and model characterization tests (12 tests)
- Static and emitted boundary checks

All eight retained lockfile SHA-256 values remained unchanged. The first
local `packages/fetch` test attempt was blocked by the sandbox refusing its
fixture's `0.0.0.0:3002` bind; the unchanged test passed in the approved
network-capable context. A strict package-consumer diagnostic with
`skipLibCheck: false` exposed pre-existing Core declaration hygiene defects;
the supported Core/CLI consumer posture passed and no product-source error
was suppressed.

The local runtime-boundary characterization was not used as an authority
signal because the macOS checkout was running Node.js `v26.7.0` rather than
the required `v24.19.0`; its child CLI and module-resolution checks completed,
but the profile correctly reported the pinned-runtime mismatch. This is an
environment limitation, not an unexplained fix failure.

The Phase 5 validation harness required one evidence-backed correction:
commit `ba52121cca51b7ce951320fdbee4902ebaec7ea1` changes the stale-reference
matcher to require one or more relative path segments, so approved bare
`core` package imports are not reported as stale filesystem references. Its
SDD contract, TDD regression, shell syntax, and dry-run checks pass. The
authoritative runner is pinned to that commit with script SHA-256
`cf19fe5655c804df019d142df7238b62393808d5e1b26735a1243cc1362467c3` and
contract SHA-256
`fea4e6797d308325b182890605d4035aefa0f980d11acdda16f3f7e12592f272`.

The fixed post-change Ubuntu1 invocation has not completed because GitHub has
no published ref for the local Phase 5 branch. Evidence is in
`docs/reduction/artifacts/phase5/P5-DIAG/post-change/validation-blocker.md`.

## Commits and rollback

- Runner: `6c3b95c`, rollback:
  `git -C /Users/brettcon/git/systems-orchestration revert 6c3b95c`
- Runner evidence output: `6d18794`, rollback:
  `git -C /Users/brettcon/git/systems-orchestration revert 6d18794`
- Runner stale-reference correction: `ba52121cca51b7ce951320fdbee4902ebaec7ea1`,
  rollback:
  `git -C /Users/brettcon/git/systems-orchestration revert ba52121cca51b7ce951320ebaec7ea1`
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
