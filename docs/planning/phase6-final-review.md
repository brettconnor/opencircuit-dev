# `docs/planning/phase6-final-review.md`

# Phase 6: Final CLI/Core Review and Publication Readiness

**Status:** Draft — autonomous reconciliation and final-review preparation.  
**Execution model:** W1 — autonomous evidence collection and reconciliation; **one and only one HITL approval step** at Phase 6 exit.  
**Primary objective:** Confirm that the reduced repository matches the approved CLI/Core product scope, retains a reproducibly validated dependency closure, and is ready for publication or handoff.  
**Starting baseline:** Current merged `main` after Phase 5 validation remediation.  
**Authoritative validation profile:** Ubuntu1 retained-closure `--phase5-validate` profile.

---

## 1. Purpose

Phase 6 is the final reconciliation phase for the CLI/Core reduction.

It does not begin a new deletion campaign, redesign Core, or reopen deferred surfaces. It verifies that the repository now contains only the approved retained product surfaces, required build/dependency closure, required legal and operational documentation, and explicitly deferred surfaces.

Phase 6 produces a publication-ready evidence package that compares the final repository state against the Phase 0 source baseline and the approved reduction decisions.

The primary supported product remains:

- CLI, including the `cn` executable;
- Continue Core;
- approved local packages:
  - `config-types`
  - `config-yaml`
  - `fetch`
  - `llm-info`
  - `openai-adapters`
  - `terminal-security`;
- required shared utilities;
- required build, test, workspace, CI, configuration, licensing, and attribution material;
- focused CLI/Core documentation and validation coverage.

---

## 2. W1 Authority Model

Phase 6 is autonomous until its single final approval step.

Copilot may autonomously:

- collect repository measurements;
- reconcile package/workspace/dependency inventories;
- run approved validation;
- inspect bundle, runtime, and static boundary reports;
- identify stale references;
- update final-review artifacts;
- make documentation-only corrections needed to accurately reflect already-merged repository state;
- create atomic evidence commits;
- prepare the final publication-readiness package.

Copilot must not autonomously:

- delete additional product code;
- change CLI/Core runtime behavior;
- change Core exports or public API;
- modify lockfiles or dependency versions;
- alter deferred product surfaces;
- rewrite history;
- publish packages, releases, or artifacts;
- merge a PR;
- make claims unsupported by recorded evidence.

## Single HITL Approval Step

There is exactly one HITL approval step in this phase:

> **Phase 6 Exit Approval:** Human review of the final reconciliation package and decision to approve or reject publication readiness.

No intermediate HITL approvals, per-batch approvals, PR approvals, or merge gates are required during Phase 6.

If Copilot finds a blocking discrepancy, it records the discrepancy and stops the affected reconciliation item. It may continue collecting evidence for unrelated review items but does not request a new approval until the final Phase 6 exit package is ready.

---

## 3. Scope

### Included

- final package, workspace, entry-point, and dependency-closure reconciliation;
- final CLI/Core build, typecheck, smoke, characterization, and boundary validation;
- final bundle and runtime dependency review;
- final stale-reference review;
- final license, attribution, README, and build-instruction review;
- final file-count and repository-size comparison;
- final comparison against Phase 0, Phase 4, and Phase 5 evidence;
- publication-readiness documentation;
- Copilot reconciliation records.

### Excluded

- new product deletion;
- new package removal;
- Core API redesign;
- CLI-to-Core boundary migration;
- VS Code reduction;
- binary packaging reduction;
- GUI/web/docs-site reduction;
- dependency upgrades;
- lockfile repair;
- external publication or release;
- history rewriting;
- changing `Defer`, `Unknown`, or `Blocked` candidates into `Remove`.

---

## 4. Required Starting References

| Reference | Purpose |
|---|---|
| Current merged `main` | Final review source state |
| `phase0-source-baseline` | Original pre-reduction source baseline |
| `phase0-cli-core-complete` | Original characterization baseline |
| `red-001-core-clean-install` | Clean-install remediation checkpoint |
| Phase 4 merged state and summary | Deletion/reduction record |
| Phase 5 merge commit | Restored retained-closure validation baseline |
| `docs/reduction/phase5-summary.md` | TS2322 remediation and validation outcome |
| `docs/reduction/phase4-summary.md` | Reversible deletion summary |
| `docs/reduction/cli-core-dependency-inventory.md` | Keep/Remove/Defer decisions |
| `docs/reduction/cli-core-boundaries.md` | Core/CLI boundary status |
| `docs/reduction/cli-core-entry-points.md` | CLI/Core entry-point inventory |
| `docs/reduction/phase4-execution-ledger.md` | Accepted deletion batches |
| `docs/reduction/phase5-execution-ledger.md` | Validation/remediation history |

---

## 5. Final Reconciliation Questions

Phase 6 must answer each question with evidence.

### Product scope

1. Does the repository retain the approved CLI/Core product closure?
2. Are all retained local packages still required and documented?
3. Does the `cn` executable build and run through its intended path?
4. Does Core remain buildable and independently usable within the currently supported boundary?
5. Are removed repository surfaces absent?
6. Are deferred surfaces explicitly preserved and documented?

### Dependency closure

7. Does a clean retained-closure installation succeed?
8. Do retained package builds run in the approved dependency order?
9. Do all retained lockfiles remain coherent and unchanged after immutable install?
10. Are there no retained imports, aliases, scripts, workspace entries, bundle inputs, or runtime accesses referring to removed surfaces?

### Runtime and behavior

11. Does Core typecheck and build?
12. Does the CLI typecheck and build?
13. Does the CLI smoke test pass?
14. Does the deterministic controlled headless workflow pass?
15. Do configuration parsing, model initialization/selection, and adapter normalization tests pass?
16. Do static, emitted-bundle, and runtime boundary checks pass?

### Repository hygiene

17. Are README, build instructions, license, notices, and attribution accurate?
18. Are CI, workspace, package, release, and documentation references coherent with the final repository?
19. Is the final diff, file count, and repository size reduction recorded?
20. Are remaining `Defer`, `Unknown`, and `Blocked` items explicitly documented?

---

## 6. Final Validation Matrix

Use the validated Ubuntu1 environment and the authoritative retained-closure profile established by Phase 5.

Record:

- commit SHA;
- operating system and architecture;
- Node.js, npm, and TypeScript versions;
- registry and cache policy;
- lifecycle-script policy;
- network policy;
- command duration;
- exit code;
- artifact location;
- result: `Pass`, `Fail`, `Blocked`, or `Not Run`.

### Required validation

| Surface | Required command or approved equivalent | Required result |
|---|---|---|
| Root tooling | Immutable root install | Pass |
| `config-types` | Immutable install and build | Pass |
| `fetch` | Immutable install and build | Pass |
| `llm-info` | Immutable install and build | Pass |
| `terminal-security` | Immutable install and build | Pass |
| `config-yaml` | Immutable install and build/test | Pass |
| `openai-adapters` | Immutable install and build/test | Pass |
| Core | Immutable install, build, and `npm run tsc:check` | Pass |
| CLI | Immutable install, typecheck, and build | Pass |
| CLI smoke | Approved smoke command | Pass |
| Headless workflow | Loopback/mock transport workflow | Pass |
| Configuration parsing | Existing deterministic characterization test | Pass |
| Model initialization | Existing deterministic characterization test | Pass |
| Adapter normalization | Existing deterministic characterization test | Pass |
| Static/bundle boundaries | Boundary check and CLI metafile analysis | Pass |
| Runtime boundaries | Runtime module-resolution check | Pass |
| Lockfile integrity | Before/after SHA-256 comparison | No unexplained change |
| Repository hygiene | Stale-reference, workspace, docs, legal scan | Pass |

No aggregate root script may substitute for package-specific validation unless it demonstrably executes the required retained package matrix.

---

## 7. Copilot Reconciliation Procedure

Copilot is advisory. Repository commands, artifacts, and human-reviewed records are authoritative.

### Required Copilot reconciliation tasks

1. Reconcile the final package list against the approved `Keep` inventory.
2. Reconcile removed paths against Phase 4 accepted deletion records.
3. Reconcile deferred paths against `Defer` records.
4. Search for stale references to removed packages, directories, scripts, assets, and workspace names.
5. Compare CLI bundle metafile inputs against retained/deferred/removed surfaces.
6. Compare runtime module-resolution results against the final boundary denylist.
7. Reconcile package manifests, workspace membership, TypeScript references, aliases, and scripts.
8. Review CI/release/docs references for deleted or renamed paths.
9. Review package metadata, package-packing configuration, license, NOTICE, and attribution files.
10. Prepare the final evidence table and unresolved-item list.

### Reconciliation record schema

| Field | Requirement |
|---|---|
| Reconciliation ID | Stable identifier, e.g. `COP-P6-001` |
| Review area | Package, workspace, import, bundle, runtime, CI, docs, legal, or publication |
| Copilot claim | Concise claim |
| Scope analyzed | Exact files, paths, reports, or command output |
| Cited evidence | Exact paths, symbols, artifacts, or records |
| Human-verifiable command | Copy-and-paste command or inspection procedure |
| Outcome | Accepted, rejected, partial, unresolved |
| Final status impact | Keep, Remove, Defer, Unknown, or no change |
| Artifact | Report path |
| Date | ISO-8601 date |

### Suggested Copilot prompts

#### Final dependency closure reconciliation

> Compare the approved CLI/Core retained package list, current workspace manifests, package scripts, TypeScript references, and bundle metadata. Identify any current package, path, alias, script, or dependency that is not accounted for as Keep, Remove, Defer, or Unknown. Cite exact evidence. Do not infer removability from absence of static imports.

#### Removed-surface stale reference review

> Review the current repository for references to paths/packages removed by Phase 4. Include manifests, scripts, TypeScript config, CI, release workflows, docs, bundle metadata, and runtime configuration. Return cited findings and distinguish active references from historical documentation or evidence artifacts.

#### Deferred-surface integrity review

> Review the final repository paths classified as Defer. Confirm they remain isolated from the validated CLI/Core runtime, build, bundle, and controlled headless workflow. Cite any coupling found. Do not recommend deleting deferred surfaces.

#### Publication and legal review

> Review the root README, package metadata, license files, notices, attribution records, package packing fields, release scripts, and retained documentation. Identify inaccurate references to removed products or missing requirements for retained content. Cite exact paths and do not modify legal text without explicit human direction.

---

## 8. Required Final Artifacts

Create or update:

```text
docs/reduction/phase6-final-review.md
docs/reduction/phase6-final-inventory.md
docs/reduction/phase6-publication-readiness.md
docs/reduction/phase6-execution-ledger.md
docs/reduction/artifacts/phase6/
```

Recommended artifact layout:

```text
docs/reduction/artifacts/phase6/
  environment/
    authoritative-environment.json
  install/
    retained-closure-install-results.md
    lockfile-hashes-before.txt
    lockfile-hashes-after.txt
  build/
    retained-build-results.md
  tests/
    smoke.log
    headless-workflow.log
    characterization-results.md
  boundaries/
    static-and-bundle.json
    runtime.json
  inventory/
    final-workspace-list.md
    final-package-graph.md
    final-entry-points.md
    stale-reference-report.md
  repository/
    file-counts.md
    size-measurements.md
    final-diff-stat.md
  legal/
    license-attribution-review.md
  reconciliation/
    copilot-reconciliation-log.md
    unresolved-items.md
```

---

## 9. Final Inventory Requirements

The final inventory must classify every remaining major repository surface.

| Classification | Meaning in Phase 6 |
|---|---|
| Keep | Required by CLI/Core retained closure or required legal/operational support |
| Defer | Intentionally preserved outside CLI/Core reduction scope |
| Unknown | Evidence remains incomplete; cannot be treated as removable |
| Historical | Removed from active product scope but referenced only in historical reduction evidence |

Historical references within reduction records are not stale references if they accurately document past state and do not affect build, runtime, packaging, publishing, or user-facing instructions.

---

## 10. Final Repository Measurements

Compare final `main` against `phase0-source-baseline`.

Required measurements:

| Measurement | Source baseline | Final value | Method |
|---|---:|---:|---|
| Source commit | `<SHA>` | `<SHA>` | `git rev-parse` |
| Tracked file count | `<count>` | `<count>` | `git ls-tree -r --name-only` |
| Working-tree/archive bytes excluding `.git` | `<bytes>` | `<bytes>` | `git archive` and filesystem measurement |
| CLI bundle bytes | `<bytes>` | `<bytes>` | `stat` |
| CLI bundle input count | `<count>` | `<count>` | `dist/meta.json` |
| Retained workspace/package count | `<count>` | `<count>` | manifest inventory |
| Lockfile count | `<count>` | `<count>` | repository listing |
| Removed paths/packages | N/A | `<list>` | Phase 4 records |
| Deferred surfaces | N/A | `<list>` | final inventory |

Do not claim Git object storage reduction. Git history intentionally retains deleted content.

---

## 11. Continuation Rules

Copilot may continue autonomously through final reconciliation when:

- work is limited to evidence gathering, validation, and documentation;
- no product code, manifests, lockfiles, package exports, or deferred surfaces are modified;
- validation commands are deterministic and credential-free;
- results and artifacts are recorded;
- discrepancies are documented rather than hidden.

Copilot must stop modifying final-review artifacts when it reaches a material discrepancy that requires product, dependency, legal, publication, API, or scope changes. It must record the discrepancy in:

```text
docs/reduction/artifacts/phase6/reconciliation/unresolved-items.md
```

It may still complete unrelated final-review sections.

---

## 12. Final Publication Readiness Criteria

Phase 6 is ready for its single HITL approval step when:

- [ ] The final repository is reconciled against the approved CLI/Core scope.
- [ ] The retained dependency closure installs cleanly.
- [ ] Retained packages build in approved dependency order.
- [ ] Core typecheck and build pass.
- [ ] CLI typecheck, build, and smoke test pass.
- [ ] Controlled headless CLI/Core workflow passes.
- [ ] Configuration, model initialization, and adapter tests pass.
- [ ] Static, emitted-bundle, and runtime boundary checks pass.
- [ ] Lockfiles are coherent and unchanged after immutable installation.
- [ ] No active stale references remain for removed surfaces.
- [ ] Deferred surfaces are identified and not loaded by CLI/Core validation paths.
- [ ] README, build instructions, license, notices, attribution, package metadata, and CI references are accurate.
- [ ] Final file count, size, bundle metrics, package graph, and workspace list are recorded.
- [ ] Remaining `Defer`, `Unknown`, `Blocked`, and historical records are documented.
- [ ] The final review, inventory, publication-readiness report, artifact index, and execution ledger are complete.

---

## 13. The Single HITL Approval Step

When all Phase 6 readiness criteria are complete, Copilot prepares one final review package.

The human reviewer makes one decision:

| Decision | Meaning |
|---|---|
| **Approve publication readiness** | CLI/Core reduction is accepted as complete; repository may be published, handed off, or used as the baseline for future work. |
| **Approve with documented exceptions** | Publication/handoff is acceptable only with named deferred, unknown, or operational exceptions. |
| **Reject / return for correction** | A material discrepancy must be corrected before publication readiness is accepted. |

The Phase 6 final review package must contain:

1. Final commit SHA and branch state.
2. Final CLI/Core package and workspace inventory.
3. Final validation matrix and artifacts.
4. Final dependency/bundle/runtime boundary reports.
5. Before/after repository measurements.
6. Removed, retained, deferred, unknown, and historical surface lists.
7. Legal, attribution, documentation, and package metadata review.
8. Outstanding exceptions and operational limitations.
9. Rollback/recovery references.
10. Recommended post-Phase-6 maintenance posture.

No other HITL approval is required in Phase 6.

---

## 14. Completion Output

Phase 6 closes with:

```text
docs/reduction/phase6-final-review.md
docs/reduction/phase6-final-inventory.md
docs/reduction/phase6-publication-readiness.md
docs/reduction/phase6-execution-ledger.md
docs/reduction/artifacts/phase6/
```

The final review must state one of:

```text
Publication ready
Publication ready with documented exceptions
Not publication ready
```

The final result becomes the new reference baseline for future CLI/Core maintenance and any later evaluation of deferred product surfaces.
