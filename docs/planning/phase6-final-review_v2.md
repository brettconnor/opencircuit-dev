# Phase 6: Final CLI/Core Review and Publication Readiness

**Status:** Draft; reconciled v2 plan, not execution approval  
**Supersedes for execution:** `docs/planning/phase6-final-review.md`  
**Execution model:** W1 autonomous evidence collection and reconciliation
within one authorized phase envelope, followed by one and only one Phase 6
Exit Approval decision  
**Primary objective:** Confirm that the reduced repository matches the
approved CLI/Core product scope, retains a reproducibly validated dependency
closure, and is ready for publication or handoff.

## 1. Reconciliation outcome

This v2 plan reconciles the original Phase 6 draft with the current repository
state after Phase 5:

- the merged Phase 5 baseline is `main` at
  `308c540b735b4860504dadf281311c329420612e`;
- the authoritative tested Phase 5 commit was
  `36c7bff60a5ebca16eb0be38729a7530754c241d`;
- the Core `TS2322` failure is resolved;
- the fixed Ubuntu1 retained-closure profile passed with no blockers;
- the runner workspace-install correction is `dba6c7d2777660b9c941b25b827b8a99fbee32b6`;
- Phase 6 must validate and document the final merged state, not reopen Phase 5
  diagnosis or perform another reduction campaign.

The original `phase6-final-review.md` remains the historical draft. This v2
document is the canonical execution plan once its authorized phase envelope is
approved.

## 2. Purpose and final outcome

Phase 6 is the final reconciliation phase for the CLI/Core reduction. It
produces a publication-readiness package that compares the final repository
against the Phase 0 source baseline and accepted Phase 4/5 decisions.

Phase 6 must end with exactly one of:

```text
Publication ready
Publication ready with documented exceptions
Not publication ready
```

Phase 6 does not begin a new deletion campaign, redesign Core, reopen deferred
surfaces, or change the retained product. It verifies and documents the state
that already exists.

The supported retained product remains:

- CLI, including the `cn` executable;
- Continue Core;
- approved local packages:
  `config-types`, `config-yaml`, `fetch`, `llm-info`, `openai-adapters`,
  and `terminal-security`;
- required shared utilities;
- required build, test, workspace, CI, configuration, licensing, attribution,
  and focused CLI/Core documentation.

## 3. W1 authority model

Within the authorized phase envelope, the phase executor may autonomously:

- collect repository measurements;
- reconcile package, workspace, dependency, entry-point, and boundary
  inventories;
- run the approved fixed validation profile;
- inspect bundle, runtime, static, stale-reference, legal, and publication
  reports;
- update final-review artifacts and documentation-only evidence records;
- create atomic evidence commits;
- prepare the final publication-readiness package.

The phase executor must not:

- delete product code or remove packages;
- change CLI/Core runtime behavior, exports, or public APIs;
- modify lockfiles, dependency versions, or package metadata;
- alter deferred product surfaces;
- rewrite history, force-push, publish packages, or create releases;
- merge a pull request;
- convert `Defer`, `Unknown`, or `Blocked` into `Remove`;
- make claims unsupported by recorded evidence.

## 4. Single Phase 6 Exit Approval

There is one and only one HITL decision in this phase:

> **Phase 6 Exit Approval:** Review the final reconciliation package and
> approve or reject publication readiness.

No intermediate approvals, per-item approvals, per-batch approvals, PR
approvals, or merge approvals are required inside the phase-executor
workflow. A discrepancy is recorded as evidence and handled through the
continuation rules below; it does not create a second approval point.

The exit decision may be:

| Decision | Meaning |
|---|---|
| **Approve publication readiness** | The final CLI/Core reduction is accepted as complete. |
| **Approve with documented exceptions** | Publication or handoff is acceptable with explicitly named exceptions. |
| **Reject / return for correction** | A material discrepancy must be corrected before readiness is accepted. |

## 5. Scope

### Included

- final package, workspace, entry-point, and dependency-closure reconciliation;
- final CLI/Core build, typecheck, smoke, characterization, and boundary
  validation;
- final bundle and runtime dependency review;
- final stale-reference review;
- final license, attribution, README, and build-instruction review;
- final file-count, archive-size, and bundle-size comparison;
- comparison against Phase 0, Phase 4, and Phase 5 evidence;
- publication-readiness documentation and reconciliation records.

### Excluded

- new product deletion or package removal;
- Core API redesign or CLI-to-Core migration;
- VS Code, GUI, binary, web, docs-site, or other deferred-surface work;
- dependency upgrades, lockfile repair, or package-version changes;
- external publication, release, or artifact upload;
- history rewriting;
- changing any `Defer`, `Unknown`, or `Blocked` classification.

## 6. Authorized phase envelope

The initial documentation and evidence allowlist is:

- `docs/planning/phase6-final-review_v2.md`;
- `docs/reduction/phase6-final-review.md`;
- `docs/reduction/phase6-final-inventory.md`;
- `docs/reduction/phase6-publication-readiness.md`;
- `docs/reduction/phase6-execution-ledger.md`;
- `docs/reduction/artifacts/phase6/**`.

Validation may read the retained repository and approved historical records,
but it may not modify product, package, lockfile, CI, legal, or deferred
surfaces. If a discrepancy appears to require a change outside this
allowlist, record it under `unresolved-items.md` and stop that correction.

## 7. Required starting references

Record the exact commit and artifact location for each reference:

| Reference | Purpose |
|---|---|
| Current merged `main` at Phase 6 start | Final review source state |
| `phase0-source-baseline` | Original pre-reduction source baseline |
| `phase0-cli-core-complete` | Original characterization baseline |
| `red-001-core-clean-install` | Clean-install remediation checkpoint |
| Phase 4 merged state and final closeout | Reversible deletion record |
| Phase 5 merge commit `308c540b735b4860504dadf281311c329420612e` | Restored retained-closure baseline |
| `docs/reduction/phase4-summary.md` | Phase 4 reduction outcome |
| `docs/reduction/phase5-summary.md` | Phase 5 TS2322 resolution and validation |
| `docs/reduction/phase4-execution-ledger.md` | Accepted deletion batches |
| `docs/reduction/phase5-execution-ledger.md` | Diagnosis and remediation history |
| `docs/reduction/cli-core-dependency-inventory.md` | Keep/Remove/Defer decisions |
| `docs/reduction/cli-core-boundaries.md` | CLI/Core boundary status |
| `docs/reduction/cli-core-entry-points.md` | Entry-point inventory |

If a named reference is absent, do not fabricate its contents. Record the
missing reference and classify the affected review item as `Unknown` or
`Blocked`.

## 8. Final reconciliation questions

Answer every question with an artifact or an explicit `Not Run`, `Blocked`,
or `Unknown` result.

### Product scope

1. Does the repository retain the approved CLI/Core product closure?
2. Are all retained local packages required and documented?
3. Does the `cn` executable build and run through its intended path?
4. Does Core remain buildable and independently usable within its supported
   boundary?
5. Are accepted removed surfaces absent?
6. Are deferred surfaces explicitly preserved and documented?

### Dependency closure

7. Does a clean retained-closure installation succeed?
8. Do retained package builds run in approved dependency order?
9. Do retained lockfiles remain coherent and unchanged after immutable install?
10. Are there no active imports, aliases, scripts, workspace entries, bundle
    inputs, or runtime accesses referring to removed surfaces?

### Runtime and behavior

11. Does Core typecheck and build?
12. Does the CLI typecheck and build?
13. Does the CLI smoke test pass?
14. Does the controlled headless workflow pass?
15. Do configuration, model initialization/selection, and adapter
    normalization tests pass?
16. Do static, emitted-bundle, and runtime boundary checks pass?

### Repository hygiene

17. Are README, build instructions, licenses, notices, and attribution
    accurate?
18. Are CI, workspace, package, release, and documentation references
    coherent?
19. Are final diff, file-count, archive-size, and bundle measurements recorded?
20. Are remaining `Defer`, `Unknown`, `Blocked`, and historical items
    explicitly documented?

## 9. Authoritative validation

Authoritative validation runs on Ubuntu1 (`10.1.141.9`) with Node.js
`24.19.0` and npm `11.17.0`, through the fixed runner and the final merged
commit under review. Local macOS commands are advisory only.

Use the Phase 5 retained-closure profile, pinned to the final runner and
contract revisions:

```text
/Users/brettcon/git/systems-orchestration/scripts/open-circuit-runner.sh \
  --hosts-file /Users/brettcon/git/hosts/ubuntu1-hosts.sh \
  --branch main \
  --remote-dir open-circuit-dev-phase6-review \
  --phase5-validate
```

Record the actual reviewed commit, runner script hash, contract hash, host,
runtime, network/cache policy, lifecycle-script policy, duration, exit code,
and returned artifact paths. No improvised aggregate root command substitutes
for the fixed retained package matrix.

## 10. Final validation matrix

Every row receives `Pass`, `Fail`, `Blocked`, or `Not Run`.

| Surface | Required validation | Required result |
|---|---|---|
| Root tooling | Immutable root install | Pass |
| `config-types` | Immutable install and build | Pass |
| `fetch` | Immutable install and build/test | Pass |
| `llm-info` | Immutable install and build | Pass |
| `terminal-security` | Immutable install and build | Pass |
| `config-yaml` | Immutable install and build/test | Pass |
| `openai-adapters` | Immutable install and build/test | Pass |
| Core | Immutable install, build, and `npm run tsc:check` | Pass |
| CLI | Immutable install, typecheck, and build | Pass |
| CLI smoke | Approved smoke command | Pass |
| Headless workflow | Loopback/mock transport workflow | Pass |
| Characterization | Configuration, model, and adapter tests | Pass |
| Static/bundle boundaries | Boundary checks and metafile analysis | Pass |
| Runtime boundaries | Runtime module-resolution check | Pass |
| Lockfile integrity | Before/after SHA-256 comparison | No unexplained change |
| Repository hygiene | Stale-reference, workspace, docs, legal scan | Pass |

## 11. Reconciliation procedure

Create stable records using IDs such as `COP-P6-001`.

1. Reconcile the final package list against the approved `Keep` inventory.
2. Reconcile removed paths against accepted Phase 4 deletion records.
3. Reconcile deferred paths against `Defer` records.
4. Search manifests, scripts, TypeScript configuration, CI, release
   workflows, docs, bundle metadata, and runtime configuration for active
   references to removed surfaces.
5. Compare bundle metafile inputs with retained, deferred, and removed
   classifications.
6. Compare runtime module-resolution results with the final boundary denylist.
7. Reconcile manifests, workspace membership, aliases, project references,
   package scripts, and package-packing fields.
8. Review README, build instructions, license, NOTICE, attribution, release,
   and publication references.
9. Prepare the final evidence table, exceptions list, and recommendation.

Each reconciliation record must include:

| Field | Requirement |
|---|---|
| Reconciliation ID | Stable identifier |
| Review area | Package, workspace, import, bundle, runtime, CI, docs, legal, or publication |
| Claim | Concise evidence-bounded claim |
| Scope analyzed | Exact files, paths, reports, or command output |
| Cited evidence | Exact artifact paths or records |
| Human-verifiable command | Copy-and-paste inspection procedure |
| Outcome | Accepted, rejected, partial, unresolved, or not run |
| Status impact | Keep, Remove, Defer, Unknown, Blocked, or no change |
| Artifact | Report path |
| Date | ISO-8601 date |

Historical references in reduction records are not stale active references
when they accurately describe past state and do not affect build, runtime,
packaging, publication, or user-facing instructions.

## 12. Required artifacts

Create or update:

```text
docs/reduction/phase6-final-review.md
docs/reduction/phase6-final-inventory.md
docs/reduction/phase6-publication-readiness.md
docs/reduction/phase6-execution-ledger.md
docs/reduction/artifacts/phase6/
```

Use this artifact layout where applicable:

```text
docs/reduction/artifacts/phase6/
  environment/authoritative-environment.json
  install/retained-closure-install-results.md
  install/lockfile-hashes-before.txt
  install/lockfile-hashes-after.txt
  build/retained-build-results.md
  tests/smoke.log
  tests/headless-workflow.log
  tests/characterization-results.md
  boundaries/static-and-bundle.json
  boundaries/runtime.json
  inventory/final-workspace-list.md
  inventory/final-package-graph.md
  inventory/final-entry-points.md
  inventory/stale-reference-report.md
  repository/file-counts.md
  repository/size-measurements.md
  repository/final-diff-stat.md
  legal/license-attribution-review.md
  reconciliation/copilot-reconciliation-log.md
  reconciliation/unresolved-items.md
```

Sensitive credentials, tokens, cookies, provider responses, private hostnames,
and unrelated absolute paths must not be committed into evidence.

## 13. Final inventory classifications

Classify every remaining major repository surface:

| Classification | Meaning |
|---|---|
| Keep | Required by CLI/Core closure or legal/operational support |
| Defer | Intentionally preserved outside CLI/Core reduction scope |
| Unknown | Evidence remains incomplete |
| Blocked | Review cannot proceed due to a recorded prerequisite |
| Historical | Removed from active scope but retained in accurate evidence history |

`Unknown` and `Blocked` are not removable by implication. They must remain
visible in the final inventory and publication-readiness report.

## 14. Continuation and stop rules

Continue autonomously when work remains limited to evidence gathering,
validation, reconciliation, and documentation within the authorized phase
envelope.

Stop modifying the affected review item when:

- a material discrepancy requires product, dependency, package, API, legal,
  publication, or scope changes;
- a required reference or validation profile is unavailable;
- authoritative validation fails or is blocked;
- an active stale reference to a removed surface is found;
- lockfiles, manifests, package exports, or deferred surfaces would need
  modification;
- a claim cannot be supported by an artifact.

Record each such item in:

```text
docs/reduction/artifacts/phase6/reconciliation/unresolved-items.md
```

Unrelated evidence collection may continue, but no unsupported publication
claim may be made.

## 15. Publication-readiness criteria

Phase 6 is ready for the single exit decision when:

- the final repository is reconciled against the approved CLI/Core scope;
- the retained dependency closure installs cleanly;
- retained packages build in approved order;
- Core typecheck and build pass;
- CLI typecheck, build, and smoke pass;
- the controlled headless workflow passes;
- configuration, model, and adapter tests pass;
- static, emitted-bundle, and runtime boundaries pass;
- lockfiles remain coherent with no unexplained change;
- no active stale references remain for removed surfaces;
- deferred surfaces are identified and not loaded by CLI/Core validation paths;
- README, build instructions, legal, attribution, metadata, and CI references
  are accurate;
- final measurements, package graph, workspace list, and entry-point
  inventory are recorded;
- all exceptions, `Defer`, `Unknown`, `Blocked`, and historical items are
  documented;
- the final review, inventory, publication-readiness report, artifact index,
  and execution ledger are complete.

## 16. Phase exit package

The final package must contain:

1. Final reviewed commit SHA and branch state.
2. Final CLI/Core package, workspace, and entry-point inventory.
3. Final validation matrix and returned artifacts.
4. Dependency, bundle, runtime, stale-reference, and workspace reports.
5. Before/after repository measurements.
6. Removed, retained, deferred, unknown, blocked, and historical lists.
7. Legal, attribution, documentation, and package metadata review.
8. Outstanding exceptions and operational limitations.
9. Rollback and recovery references.
10. Recommended post-Phase-6 maintenance posture.

The final review must state exactly one readiness result:

```text
Publication ready
Publication ready with documented exceptions
Not publication ready
```

After the exit decision, the final package becomes the reference baseline for
future CLI/Core maintenance. Any later reduction work must operate within its
authorized phase envelope, use an exact scope and evidence record, and pass
its applicable fixed validation profile and continuation checks.
