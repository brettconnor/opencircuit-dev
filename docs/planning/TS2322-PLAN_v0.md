# Core TS2322 Remediation Plan v0

**Status:** Execution-ready validation plan; candidate implementation already
exists in commit `5e2685e07`
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
3. Ensure the `ToolExtras` boundary does not propagate a nominal
   `CodebaseIndexer` identity across source, generated, package, and CLI
   consumption.
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

### Approved execution paths

- directly involved Core source, declaration, TypeScript configuration, build,
  and package metadata files;
- `docs/reduction/artifacts/phase5/**`,
  `docs/reduction/phase5-execution-ledger.md`, and
  `docs/reduction/phase5-summary.md`;
- `extensions/cli/**` and `tests/characterization/**` for read-only
  validation, unless a focused regression fixture is explicitly justified;
- the pinned systems-orchestration runner, its SDD contract, and its TDD
  contract test only for an evidence-backed fixed-profile defect; no remote
  payload or unrelated runner behavior may change;
- temporary package-consumer fixtures outside the repository, such as
  `/private/tmp`, with no fixture committed unless the allowlist is updated.

## 5. Entry conditions

Before execution begins, record all of the following:

- the approved starting checkpoint and branch;
- the exact Core and CLI commits under test, including the candidate fix
  commit `5e2685e07` or a later atomic remediation commit;
- Node.js `24.19.0` and npm `11.17.0` on Ubuntu1;
- no uncommitted changes in the implementation, package, or validation paths;
  unrelated pre-existing changes must be preserved and isolated with a clean
  worktree rather than deleted;
- clean generated `core/dist`;
- the fixed Phase 5 runner revision and contract hashes. The currently pinned
  runner is systems-orchestration commit `ba52121cca51b7ce951320fdbee4902ebaec7ea1`,
  with script SHA-256
  `cf19fe5655c804df019d142df7238b62393808d5e1b26735a1243cc1362467c3` and
  contract SHA-256
  `fea4e6797d308325b182890605d4035aefa0f980d11acdda16f3f7e12592f272`;
- the current baseline failure and its artifact path;
- the change budget and approved path allowlist;
- a rollback commit or known-good starting checkpoint.

The branch must be published by the Git integration agent before authoritative
remote validation. Immediately before publication, record the exact tested
repository commit. The runner's reported `remote_commit` must equal that SHA;
otherwise the result is invalid and must not close this plan. Local validation
alone cannot close this plan.

## 6. Work plan

### Workstream A: Reproduce and freeze the baseline

1. Start from the approved checkpoint.
2. Remove only ignored/generated Core output required for a clean test.
3. Run the fixed diagnosis profile once; it performs three internal clean
   repetitions.
4. Capture:
   - exact diagnostic text and locations;
   - TypeScript version and compiler options;
   - module-resolution trace for the failing type;
   - source and generated declaration paths;
   - package self-reference and alias results;
   - `npm ls` and lockfile identity evidence.
5. Confirm the failure remains `TS2322` and is not a new `TS5055`,
   dependency-install, or environment failure.

**Exit criterion:** The fixed profile captures three matching failures with
sanitized evidence and a documented root-cause classification. The three
internal repetitions count as one diagnostic batch.

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

Before accepting the structural boundary change, record its compatibility
impact: `ToolExtras` is an exported package contract, so changing
`codeBaseIndexer` from `CodebaseIndexer` to a one-method capability narrows
what downstream TypeScript consumers can call. Scan all repository consumers
and compile a package-consumer fixture against the emitted `core/dist` types
using the supported Core/CLI compiler posture. An additional
`skipLibCheck: false` run may diagnose unrelated pre-existing declaration
hygiene defects, but it is informational and cannot be used to waive a
product-source error.
If a supported consumer requires another `CodebaseIndexer` method, stop and
return to package-resolution correction or add a compatible adapter; do not
silently treat the narrowing as an internal-only change.

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

The existing candidate combines declaration-input correction and boundary
shaping in one atomic commit. Validate that combined, evidence-backed
hypothesis first; do not add further speculative changes. If it fails, split
the next experiment into declaration-input-only and boundary-only candidates,
each with its own hypothesis, commit, and rollback.

**Exit criterion:** One minimal remediation is selected with evidence that it
addresses the identity split and remains within the approved budget.

### Workstream D: Apply the remediation only if needed

1. Treat commit `5e2685e07` as the existing implementation and do not modify
   code before its authoritative validation.
2. If a follow-up is required, modify only directly involved Core
   source/config/package files.
3. Keep public contracts as narrow as possible; document any intentional
   compatibility impact.
4. Do not expose private members or add suppressions.
5. Confirm no lockfile or unrelated generated-file mutation occurs.
6. Commit each follow-up change atomically with a message that states the
   identity problem being corrected.

**Exit criterion:** The changed-file list is within budget and the diff
contains no unrelated refactor or type-safety workaround.

### Workstream E: Validate locally and authoritatively

Run the existing targeted checks locally for fast feedback:

- the retained-closure install/build order from
  `docs/reduction/artifacts/phase1/retained-closure-install-matrix.md`;
- clean Core install with lockfile integrity after its local dependencies are
  built;
- Core build;
- Core `tsc:check`;
- `extensions/cli` typecheck;
- `extensions/cli` build and build validation;
- the fixed-profile CLI smoke and selected characterization tests;
- static and emitted boundary checks.

The post-change boundary checks must verify that the emitted `core/dist`
entrypoint exposes the structural capability without importing
`CodebaseIndexer`, and that the original source-vs-dist `TS2322` cannot be
reintroduced by the package-consumer fixture.

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
| Declaration resolution | No nominal `CodebaseIndexer` identity crosses `ToolExtras`; source-vs-dist `TS2322` absent |
| CLI typecheck/build | Pass |
| CLI smoke/characterization | Pass for the fixed-profile selected checks |
| Boundary checks | Pass for source and emitted/package paths |
| Lockfile | Unchanged unless explicitly justified |
| Ubuntu1 runtime | Node.js `24.19.0`, npm `11.17.0` |
| Fixed runner | Pass with committed branch and recorded artifacts |
| Phase 4 retained closure | Claim restored only after authoritative pass |

## 8. Change budget and stop conditions

Use the Phase 5 limits unless a separately approved plan supersedes them.
Only new work after this plan enters execution consumes the budget; the
existing diagnosis and candidate commits are recorded baseline history.

- maximum six diagnostic/fix batches;
- maximum ten atomic commits;
- maximum fifteen Core files changed per batch;
- maximum ten CLI files changed per batch;
- zero unexplained validation failures;
- zero broad dependency upgrades;
- zero type-safety suppressions or exclusions;
- zero unexpected lockfile mutations.

A batch is one diagnostic or remediation hypothesis and its validation. The
three internal diagnosis repetitions are one batch, not three batches. A
publication failure is a blocker, not permission to create an alternate
validation path.

Stop immediately and document evidence if:

- the fix requires an unapproved surface;
- the failure changes from TS2322 to an unexplained error;
- runtime, smoke, bundle, or boundary checks fail;
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

Treat commit `5e2685e07` as the selected remediation candidate pending
authoritative validation, not as a completed resolution. Publish the exact
tested commit without rebasing, using the pinned runner revision and the exact
Ubuntu1 `--phase5-validate` profile. If it passes, retain the narrow
declaration-input and structural-boundary changes and close the plan with
evidence. If it fails, preserve the artifacts, classify the failure, and split
the next experiment into the isolated options described in Workstream C.
