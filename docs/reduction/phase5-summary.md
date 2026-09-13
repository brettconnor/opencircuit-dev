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
commit `f463d28e824b612d5eea762e7b106b22aca1308a` changes the stale-reference
matcher to require one or more relative path segments, so approved bare
`core` package imports are not reported as stale filesystem references, and
cleans ignored `core/dist` before validation. Its SDD contract, TDD
regressions, shell syntax, and dry-run checks pass. The authoritative runner
is pinned to that commit with script SHA-256
`8c11c176761f58f7429915c5320232e6c3cc26cc72010c94a075456ee3a9042f` and
contract SHA-256
`841801d0721f27dee9cf5e60608ce9993bed46c67bbd8bdd538d80334bcfd4c9`.

The fixed post-change Ubuntu1 invocation has not completed because GitHub has
no published ref for the local Phase 5 branch. Evidence is in
`docs/reduction/artifacts/phase5/P5-DIAG/post-change/validation-blocker.md`.

## Commits and rollback

- Runner: `6c3b95c`, rollback:
  `git -C /Users/brettcon/git/systems-orchestration revert 6c3b95c`
- Runner evidence output: `6d18794`, rollback:
  `git -C /Users/brettcon/git/systems-orchestration revert 6d18794`
- Runner stale-reference and clean-output correction: `f463d28e824b612d5eea762e7b106b22aca1308a`,
  rollback:
  `git -C /Users/brettcon/git/systems-orchestration revert f463d28e824b612d5eea762e7b106b22aca1308a`
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
