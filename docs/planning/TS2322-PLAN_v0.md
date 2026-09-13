# Core TS2322 Remediation Plan v0

**Status:** Planning only; no implementation authorized by this document  
**Related phase:** Phase 5 CLI/Core validation  
**Primary objective:** Resolve the deterministic Core `TS2322` failure caused by
duplicate TypeScript declaration identities, then restore authoritative
CLI/Core retained-closure validation.

## 1. Problem statement

Core's retained typecheck fails after a successful build with an error
equivalent to:

```text
core.ts(1185,7): error TS2322:
Type '.../core/indexing/CodebaseIndexer'.CodebaseIndexer
is not assignable to type
'.../core/dist/indexing/CodebaseIndexer'.CodebaseIndexer.
Types have separate declarations of a private property 'configHandler'.
```

The failure is deterministic on Ubuntu1 (`10.1.141.9`) with Node.js
`24.19.0` and npm `11.17.0`. Three clean reproductions produced the same
failure. Core's build succeeds, but `npm run tsc:check` fails when source and
generated declarations are resolved as separate nominal type identities.

## 2. Evidence and current understanding

Authoritative evidence is recorded in:

- `docs/reduction/artifacts/phase5/P5-DIAG/pre-change/diagnosis-evidence.md`
- `docs/reduction/artifacts/phase5/P5-DIAG/post-change/validation-blocker.md`
- `docs/reduction/phase5-execution-ledger.md`
- `docs/reduction/phase5-summary.md`

The observed resolution split is:

- one path resolves `CodebaseIndexer` through the source declaration tree;
- another resolves it through `core/dist`;
- the class contains the private member `configHandler`;
- TypeScript therefore treats the two class declarations as incompatible,
  even though their visible structure is otherwise equivalent.

The leading contributing conditions are broad declaration-file inputs in:

- `core/tsconfig.json`;
- `core/tsconfig.npm.json`;
- package self-reference or alias resolution that permits source and
  generated declarations to participate in the same check.

Rejected or currently unsupported explanations include:

- a lockfile dependency drift;
- a broad third-party version mismatch;
- a genuine behavioral incompatibility in `CodebaseIndexer`;
- a failure caused by the Phase 4 deletion batches;
- a macOS-only runtime issue.

The local checkout has a candidate narrow fix in commit `5e2685e07`:

- remove the broad declaration-file inputs that admit duplicate generated
  declarations;
- expose only the consumed `ToolExtras.codeBaseIndexer` capability at the
  relevant boundary instead of propagating a private-class identity.

That candidate has passed local targeted checks, but it is not considered
authoritatively validated until the published branch passes the fixed Ubuntu1
profile.

## 3. Goals

1. Make Core `npm run tsc:check` pass from a clean generated-output state.
2. Preserve type safety and meaningful private-member encapsulation.
3. Ensure each logical Core type has one stable declaration identity during
   source, build, package, and CLI consumption.
4. Preserve the existing Core and CLI runtime behavior.
5. Restore the retained CLI/Core validation profile on Ubuntu1.
6. Produce reproducible evidence, rollback points, and a clear closeout.

## 4. Non-goals and constraints

This plan does not authorize:

- deletion or reduction batches;
- changes to VS Code, GUI, binary, docs-site, sync, or other deferred
  surfaces;
- broad dependency or TypeScript upgrades;
- public API redesign unrelated to the failing boundary;
- type assertions, `any`, `skipLibCheck`, exclusion of failing files, or
  other type-safety suppressions;
- arbitrary remote commands in place of the fixed runner profile;
- lockfile mutation unless a diagnosis proves it necessary and the exact
  graph change is documented first;
- push, pull request creation, merge, force-push, or history rewriting by the
  phase executor.

## 5. Entry conditions

Before implementation begins, record all of the following:

- the approved starting checkpoint and branch;
- the exact Core and CLI commits under test;
- Node.js `24.19.0` and npm `11.17.0` on Ubuntu1;
- clean working trees and clean generated `core/dist`;
- the fixed Phase 5 runner mode and contract version;
- the current baseline failure and its artifact path;
- the change budget and approved path allowlist;
- a rollback commit or known-good starting checkpoint.

The branch must be published by the Git integration agent before authoritative
remote validation. Local validation alone cannot close this plan.

## 6. Work plan

### Workstream A: Reproduce and freeze the baseline

1. Start from the approved checkpoint.
2. Remove only ignored/generated Core output required for a clean test.
3. Run the fixed diagnosis profile three times.
4. Capture:
   - exact diagnostic text and locations;
   - TypeScript version and compiler options;
   - module-resolution trace for the failing type;
   - source and generated declaration paths;
   - package self-reference and alias results;
   - `npm ls` and lockfile identity evidence.
5. Confirm the failure remains `TS2322` and is not a new `TS5055`,
   dependency-install, or environment failure.

**Exit criterion:** Three matching failures with sanitized evidence and a
documented root-cause classification.

### Workstream B: Map the declaration identity boundary

Inspect, without broad refactoring:

- `core/tsconfig.json`;
- `core/tsconfig.npm.json`;
- related build and package metadata;
- `core/index.d.ts` and generated declarations;
- aliases, project references, and package self-reference;
- the `CodebaseIndexer` declaration and its consumers;
- the `ToolExtras` contract and CLI/tool implementations.

Produce a small resolution map showing which import edges resolve to source,
which resolve to `dist`, and where the duplicate nominal identity enters the
program.

**Exit criterion:** The failing edge and the minimum configuration or
boundary responsible for it are identified.

### Workstream C: Evaluate remediation options

Evaluate options in this order, selecting the first one that removes the
duplicate identity without weakening types:

1. **Declaration input correction.** Narrow `tsconfig` includes/references so
   generated declarations are not re-ingested as competing source inputs.
2. **Package-resolution correction.** Align package self-reference, aliases,
   and declaration entrypoints so all consumers select one declaration tree.
3. **Boundary shaping.** If a private class identity must not cross the
   package boundary, expose the smallest structural capability actually
   consumed by callers.
4. **Build-output correction.** Adjust declaration generation or package
   metadata only if the first three options cannot produce one stable
   identity.

Do not combine options speculatively. Each candidate must be tested as a
separate atomic change with a clear hypothesis and rollback.

**Exit criterion:** One minimal remediation is selected with evidence that it
addresses the identity split and remains within the approved budget.

### Workstream D: Implement the narrow fix

1. Modify only directly involved Core source/config/package files.
2. Keep public contracts as narrow as possible.
3. Do not expose private members or add suppressions.
4. Confirm no lockfile or unrelated generated-file mutation occurs.
5. Commit the change atomically with a message that states the identity
   problem being corrected.

**Exit criterion:** The changed-file list is within budget and the diff
contains no unrelated refactor or type-safety workaround.

### Workstream E: Validate locally and authoritatively

Run the existing targeted checks locally for fast feedback:

- clean Core install with lockfile integrity;
- Core build;
- Core `tsc:check`;
- CLI typecheck;
- CLI build and build validation;
- CLI smoke and focused characterization tests;
- static and emitted boundary checks.

Then publish the branch through the Git integration agent and run the fixed
Ubuntu1 validation profile:

```text
/Users/brettcon/git/systems-orchestration/scripts/open-circuit-runner.sh \
  --hosts-file /Users/brettcon/git/hosts/ubuntu1-hosts.sh \
  --branch reduce/phase5-cli-core-validation \
  --phase5-validate
```

The authoritative run must record the remote commit, host, runtime, fixed
profile, command steps, exit statuses, and returned artifacts.

**Exit criterion:** Core and CLI retained-closure checks pass on Ubuntu1,
including runtime, smoke, boundary, and package-consumer checks required by
the fixed profile.

### Workstream F: Close out or stop with evidence

If all checks pass:

1. Update the execution ledger and summary.
2. Record the final commit and rollback command.
3. State whether Phase 4 retained-closure validation is restored.
4. Hand off the branch to the Git integration agent for PR preparation.

If any mandatory check fails:

1. Preserve the exact failing artifact.
2. Classify it as the original identity issue, a regression, or an
   environment/publication problem.
3. Do not broaden the fix without a new evidence-backed plan decision.
4. Record the blocker and precise next action.

## 7. Validation matrix

| Area | Required result |
|---|---|
| Clean generated output | No stale `core/dist` contamination |
| Core build | Pass |
| Core `tsc:check` | Pass with no suppressions |
| Declaration resolution | One stable `CodebaseIndexer` identity |
| CLI typecheck/build | Pass |
| CLI smoke/characterization | Pass |
| Boundary checks | Pass for source and emitted/package paths |
| Lockfile | Unchanged unless explicitly justified |
| Ubuntu1 runtime | Node.js `24.19.0`, npm `11.17.0` |
| Fixed runner | Pass with committed branch and recorded artifacts |
| Phase 4 retained closure | Claim restored only after authoritative pass |

## 8. Change budget and stop conditions

Use the Phase 5 limits unless a separately approved plan supersedes them:

- maximum six diagnostic/fix batches;
- maximum ten atomic commits;
- maximum fifteen Core files changed per batch;
- maximum ten CLI files changed per batch;
- zero unexplained validation failures;
- zero broad dependency upgrades;
- zero type-safety suppressions or exclusions;
- zero unexpected lockfile mutations.

Stop immediately and document evidence if:

- the fix requires an unapproved surface;
- the failure changes from TS2322 to an unexplained error;
- runtime, smoke, headless, bundle, or boundary checks fail;
- the branch is not available to the fixed runner;
- package metadata or lockfiles mutate unexpectedly;
- the proposed remedy requires suppressing the type error;
- the fix would redesign unrelated public API.

## 9. Rollback and recovery

Every remediation candidate must have an atomic commit. Recovery is:

```text
git revert <remediation-commit>
```

If the branch cannot be validated, preserve the branch and artifacts rather
than rebasing, force-pushing, or deleting evidence. Restore the approved
starting checkpoint only through an explicit rollback commit or a new branch
created by the Git integration workflow.

## 10. Deliverables

The completed plan execution should produce:

- the remediation commit or a documented blocker;
- pre-change and post-change sanitized evidence;
- the updated Phase 5 execution ledger;
- `docs/reduction/phase5-summary.md`;
- fixed-runner output identifying the authoritative commit and environment;
- rollback instructions;
- a final statement on whether retained closure is restored;
- a Git-agent handoff for PR preparation.

## 11. Current recommendation

Treat commit `5e2685e07` as the leading remediation candidate, not as a
completed resolution. Publish the branch without rebasing and run the exact
Ubuntu1 `--phase5-validate` profile. If it passes, retain the narrow
declaration-input and structural-boundary changes and close the plan with
evidence. If it fails, return to Workstream B and inspect the remaining
source/package self-reference edge before considering any additional change.
