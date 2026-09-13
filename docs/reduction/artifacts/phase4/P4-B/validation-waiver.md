# P4-B Validation Waiver

## Batch

P4-B — stale root `.idea` metadata deletion.

## Validation profile

D4 — workspace/metadata cleanup, validated using the stricter D2
retained-closure matrix.

## Waived command

```text
cd core && npm run tsc:check
```

The fixed D2 matrix runs `npm run build` followed by Core
`npm run tsc:check`. Core build passed; the typecheck failed with TS2322.

## Baseline comparison

- Parent commit before deletion:
  `e1a0b720172cb3ac441a4bc6a24b37196529267c`
- Deletion commit:
  `ceb6624f9dd44430bf38a474f47ec2617ce34adb`
- Before artifact:
  `docs/reduction/artifacts/phase4/P4-B/baseline-core-ts2322.log`
- After artifact:
  `docs/reduction/artifacts/phase4/P4-B/post-delete-core-ts2322.log`
- Result: baseline-equivalent TS2322 after a successful Core build. The
  representative location is `core.ts:1185`; both reports identify the
  private `configHandler` nominal type clash between self-referenced
  `@continuedev/core` declarations from `core/dist` and relative source
  imports.

## Scope proof

- No `.idea` path is referenced by Core TypeScript configuration.
- No `.idea` path is referenced by Core package scripts or lifecycle scripts.
- No `.idea` path is part of the retained workspace package manifests or
  lockfiles.
- The deleted metadata referenced absent JetBrains modules and was not a
  retained CLI/Core input.
- The candidate-specific absence, exact-scope, stale-reference, and
  `git diff --check` checks passed locally.

## Remaining validation

- P4-A D1: passed locally and 23/23 paths passed on Ubuntu1.
- P4-B candidate absence/scope/stale-reference checks: pass.
- P4-B Core build: pass.
- P4-B retained Core typecheck: baseline-equivalent failure, waived.
- P4-B CLI build/typecheck, CLI smoke, headless workflow, static/bundle
  boundary, and runtime boundary: not reached by the fixed matrix after the
  Core failure; not represented as passes.
- Lockfile integrity: no lockfile mutation.

## Waiver decision

- Scope: P4-B only.
- Approved by: Operator ratification, 2026-09-13.
- Does not apply to subsequent D2, D3, or D4 deletion batches.
- Does not modify candidate classification policy or the validation runner.
- Expiry condition: Core TS2322 must be remediated or explicitly
  re-baselined before any later D2/D3/D4 deletion relies on retained-closure
  validation.
