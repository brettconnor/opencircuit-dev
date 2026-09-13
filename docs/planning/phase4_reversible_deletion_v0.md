# `docs/planning/phase4_reversible_deletion_v0.md`

# Phase 4: Reversible Deletion Plan v0

**Status:** Draft — planning and Copilot reconciliation only.  
**Execution model:** W1 — autonomous execution within an approved phase envelope; HITL at phase entry, exceptions, and phase exit.  
**Product deletion status:** NO-GO until this plan is reviewed, approved, and the Phase 4 entry gate passes.  
**Builds on:**

- `docs/planning/phase2-repository-classification-plan_v1.md`
- Phase 2 and Phase 2a completed classification and experiment evidence
- `docs/planning/phase3-core-boundary-plan_v0.md`, if Core boundary work affects removal candidates
- `docs/reduction/cli-core-boundaries.md`
- `docs/reduction/cli-core-entry-points.md`
- Phase 0 retained-closure characterization and boundary artifacts
- The approved clean-install checkpoint that succeeds Phase 0 retained-closure validation

## Purpose

Phase 4 performs approved, reversible deletion of repository content already classified as `Remove`.

This phase is not a new discovery or broad cleanup effort. It executes only against candidates whose removal has already been supported by:

- manifest and workspace evidence;
- static import and reference analysis;
- dynamic-loading and runtime evidence;
- bundle/metafile evidence;
- package, CI, release, documentation, legal, and attribution review;
- a written removal hypothesis;
- a focused disconfirming check; and
- an approved classification record.

Copilot may assist with reconciliation, evidence summarization, stale-reference discovery, and candidate grouping. Copilot output is advisory. It is never sufficient evidence by itself to authorize deletion.

## W1 Operating Model

Phase 4 uses the approved W1 execution model.

> After HITL approval of this Phase 4 plan, the agent may execute pre-authorized, reversible deletion batches on a dedicated phase branch without an intermediate GitHub PR or merge for every successful batch.

Each batch must:

1. remain inside the approved scope and path allowlist;
2. create one or more atomic, reversible Git commits;
3. pass the required validation profile;
4. update the Phase 4 execution ledger;
5. preserve required licensing and attribution;
6. remain within the Phase 4 change budget; and
7. pass the continuation gate.

HITL remains mandatory for:

- Phase 4 approval;
- scope exceptions;
- validation failures;
- unresolved `Unknown` findings;
- deferred-surface coupling;
- unplanned package, lockfile, public API, or distribution changes;
- legal, attribution, or licensing uncertainty;
- change-budget exceedance; and
- Phase 4 final review and GitHub merge.

## Phase Objective

Reduce repository size and maintenance burden by deleting pre-classified, unsupported, and non-required repository surfaces while preserving a buildable and functionally validated CLI/Core retained closure.

The retained product remains:

- the CLI, including the `cn` executable;
- Continue Core;
- approved local packages:
  - `config-types`
  - `config-yaml`
  - `fetch`
  - `llm-info`
  - `openai-adapters`
  - `terminal-security`;
- required shared utilities;
- required build, test, TypeScript, workspace, and CI configuration;
- licensing, attribution, focused build instructions, and smoke coverage.

## Non-Goals

Phase 4 does not authorize:

- Core API redesign;
- replacement of CLI-to-Core deep imports unless separately approved under Phase 3;
- VS Code source, packaging, or activation-code deletion;
- binary packaging deletion before ownership and distribution requirements are confirmed;
- history rewriting, force-pushing, or branch-protection bypass;
- broad dependency upgrades;
- provider behavior changes unrelated to deterministic validation;
- deleting code solely because Copilot reports no static imports;
- changing a `Defer` or `Unknown` classification to `Remove` without new evidence and approval;
- removal of any package or path required by the validated CLI/Core retained closure.

## Entry Gate

Phase 4 may begin only when all conditions below are true.

- [ ] A clean-install checkpoint exists and is recorded.
- [ ] The checkpoint passes the retained CLI/Core install, build, typecheck, smoke, headless workflow, and boundary checks.
- [ ] Node.js, npm, operating system, architecture, registry, cache, lifecycle-script, and network policies are fixed and recorded.
- [ ] Every Phase 4 candidate has an approved Phase 2/2a classification record with final classification `Remove`.
- [ ] Each candidate has a documented removal hypothesis and disconfirming check.
- [ ] Each candidate has been reconciled against current `main`; earlier evidence must not be assumed current.
- [ ] The Phase 4 branch begins from the approved checkpoint.
- [ ] The Phase 4 path allowlist and change budget are approved.
- [ ] All known `Unknown` or `Defer` records that intersect candidate paths are resolved or explicitly excluded.
- [ ] License, attribution, package publication, and release ownership have been reviewed for all candidates.
- [ ] The Phase 4 execution ledger exists.

## Phase Branch and Worktree Layout

Create one durable Phase 4 branch:

```text
reduce/phase4-reversible-deletion
```

Recommended worktree layout:

| Worktree | Branch | Purpose | Product changes allowed |
|---|---|---|---:|
| Phase execution | `reduce/phase4-reversible-deletion` | Approved deletion batches and evidence ledger | Yes |
| Clean validation | Detached checkpoint or validation branch | Clean installs and retained-closure regression confirmation | No |
| Copilot/reconciliation investigation | Temporary investigation branch | Read-only evidence analysis, stale-reference review, candidate comparison | No |
| Exception spike | Temporary branch | Isolated investigation of blocked or contradictory evidence | No without HITL |

The phase execution worktree is the only worktree permitted to contain accepted deletion commits.

## Candidate Eligibility

A candidate is eligible for a deletion batch only if all required evidence supports removal.

| Evidence type | Required condition |
|---|---|
| Classification | Candidate has final `Remove` classification |
| Static | No retained CLI/Core imports, TypeScript references, aliases, scripts, workspace entries, or manifest dependencies require it |
| Dynamic | No registry, configuration, plugin, runtime path, filesystem lookup, or child-process behavior requires it |
| Build | No retained install, build, typecheck, package, or generated-output workflow requires it |
| Bundle | Candidate does not appear as required CLI bundle input, externalized dependency, generated asset, or runtime file |
| Runtime | Candidate is not loaded or accessed by controlled headless CLI/Core execution |
| Test | Candidate does not provide required retained-closure coverage, or replacement coverage exists |
| CI/release | Candidate is not required by retained CI, release, package packing, publishing, or operational documentation |
| Legal | Candidate does not contain unique license, NOTICE, copyright, or attribution material needed by retained content |
| Rollback | Candidate can be restored by reverting ordinary Git commits |

A candidate must remain `Unknown`, `Defer`, or `Blocked` if any eligibility condition is not established.

## Copilot Reconciliation Policy

Copilot is used to accelerate review, not to replace evidence.

### Allowed Copilot tasks

Copilot may assist with:

- locating candidate references;
- summarizing manifests, scripts, aliases, and project references;
- grouping candidate-related CI and documentation references;
- identifying likely dynamic imports or filesystem access patterns;
- comparing candidate paths against CLI bundle metafile inputs;
- generating draft stale-reference reports;
- drafting classification-record updates;
- proposing focused validation commands;
- identifying likely legal or publication references for human verification.

### Prohibited Copilot authority

Copilot must not independently determine that:

- a path is safe to delete;
- an absent static import proves no runtime dependency;
- a lockfile or package metadata change is harmless;
- a license or attribution file is unnecessary;
- a deferred VS Code, packaging, or publishing surface is irrelevant;
- a validation failure is acceptable;
- a scope exception is authorized.

### Copilot reconciliation record

Each Copilot-assisted finding must be documented.

| Field | Requirement |
|---|---|
| Reconciliation ID | Stable ID, such as `COP-P4-001` |
| Candidate | Exact path, package, asset, script, or workflow |
| Prompt scope | Exact files/directories analyzed |
| Copilot finding | Concise claim |
| Copilot-cited evidence | Exact paths, symbols, scripts, or manifest fields |
| Human verification command | Copy-and-paste command or inspection step |
| Human result | Accepted, rejected, partially accepted, unresolved |
| Classification impact | Candidate record and resulting decision |
| Reviewer | Human reviewer or role |
| Date | ISO-8601 date |

## Copilot Reconciliation Prompts

### Candidate removal review

> Review only the supplied files and candidate path `<CANDIDATE>`. Identify all possible relationships to the retained CLI/Core closure: runtime, build, test, workspace, package resolution, bundle, packaging, release, documentation, legal, or attribution. Cite exact repository paths and symbols. Explicitly identify uncertainty. Do not conclude that the candidate is removable merely because static imports are absent. Return results in the Phase 4 candidate evidence schema.

### Static and dynamic dependency review

> Analyze the supplied manifests, source files, build scripts, configuration loaders, registries, and filesystem operations for references to `<CANDIDATE>`. Identify static imports, dynamic imports, `require` calls, path aliases, project references, script invocations, configuration-selected loading, runtime file access, child-process use, and generated artifacts. For each finding, cite the path and recommend a human verification command.

### Bundle reconciliation review

> Compare the supplied `extensions/cli/dist/meta.json` summary with candidate `<CANDIDATE>`. Determine whether the candidate appears as a bundled input, external dependency, copied/generated asset, or indirect runtime path. Do not treat absence from the metafile as proof that the candidate is unnecessary for install, tests, packaging, or runtime filesystem access.

### CI, publishing, and legal review

> Review the supplied CI workflows, release scripts, package metadata, `files` fields, ignore files, README references, licenses, NOTICE files, and attribution material for candidate `<CANDIDATE>`. Identify whether deletion would affect retained CI, package packing, publishing, documentation, attribution, or legal requirements. Cite exact evidence and list unresolved questions.

## Phase 4 Candidate Record

Every deletion candidate must have a record using this schema.

| Field | Requirement |
|---|---|
| ID | Stable identifier, such as `P4-GUI-001` |
| Candidate | Exact repository-relative path, package, script, workflow, or asset group |
| Classification | Must be `Remove` before deletion |
| Product surface | CLI/Core, GUI/web, docs, CI, packaging, VS Code, shared, or unrelated |
| Closure role | Runtime, build, test, packaging, release, legal/docs, development-only, or unrelated |
| Source checkpoint | Exact tag and commit used for evidence |
| Removal hypothesis | What remains true after deletion |
| Static evidence | Imports, manifests, scripts, aliases, references |
| Dynamic evidence | Runtime loaders, registries, config paths, filesystem/child process evidence |
| Bundle evidence | Metafile and emitted-bundle findings |
| Runtime evidence | Headless workflow and module-resolution findings |
| CI/release evidence | Workflow, package, publishing, and release findings |
| Legal evidence | License, NOTICE, copyright, attribution findings |
| Copilot reconciliation | Linked reconciliation IDs and human outcomes |
| Allowed changes | Exact paths permitted in the batch |
| Disconfirming check | Exact command that would disprove the hypothesis |
| Validation profile | Documentation, deletion, metadata, or asset-removal profile |
| Rollback | Ordinary commit or checkpoint |
| Result | Pending, pass, fail, blocked, or deferred |
| Reviewer | Reviewer and date |

## Batch Grouping Rules

Phase 4 may combine candidate deletions into one batch only when all candidates share:

- the same product surface;
- the same classification status;
- the same dependency evidence pattern;
- the same validation profile;
- the same legal/attribution review outcome;
- the same rollback boundary;
- no dependency relationship that would obscure the result of a failed validation.

Examples of acceptable grouping:

- screenshots, static media, and obsolete docs-site assets that are all proven unreferenced;
- multiple CI workflows exclusively serving an already removed GUI product;
- adjacent demo directories with no retained imports, scripts, package references, or publication obligations.

Examples of prohibited grouping:

- GUI source plus root workspace changes plus lockfile cleanup;
- documentation deletion combined with Core package export changes;
- generated model assets combined with unrelated package deletion;
- a `Remove` candidate combined with an `Unknown` candidate;
- VS Code/deferred-surface code combined with CLI/Core reduction work.

## Phase 4 Change Budget

The default Phase 4 budget is:

| Metric | Limit |
|---|---:|
| Autonomous deletion batches | 8 |
| Atomic commits | 12 |
| Product surfaces per batch | 1 |
| Files changed in one batch | 75 |
| Directories deleted in one batch | 5 |
| Workspace/package metadata files changed in one batch | 5 |
| Lockfiles changed without explicit approval | 0 |
| New unresolved `Unknown` findings | 0 |
| Deferred-surface exceptions | 0 |
| Unexplained validation failures | 0 |

Exceeding a budget triggers a HITL checkpoint review. It does not authorize continued autonomous work.

## Validation Profiles

### Profile D1 — Documentation, examples, or static asset deletion

Use when deleting documentation, examples, screenshots, or static assets with no retained runtime/build relationship.

Required:

- stale-reference search;
- documentation/link validation, where applicable;
- legal and attribution review;
- `git diff --check`;
- file count and repository-size measurement;
- retained README and build-instruction verification.

### Profile D2 — Package, source, test, or CI deletion

Use when deleting a package, application, test suite, CI workflow, or source directory.

Required:

- candidate-focused disconfirming check;
- approved clean install matrix;
- retained local-package builds;
- Core typecheck and build;
- CLI typecheck and build;
- CLI smoke test;
- controlled headless workflow;
- static source and emitted-bundle boundary checks;
- runtime module-resolution boundary check;
- stale-reference scan;
- CI/workflow and package metadata scan;
- lockfile hash comparison;
- licensing and attribution review.

### Profile D3 — Generated, vendored, model, or runtime asset deletion

Use when deleting generated artifacts, vendored files, models, binaries, templates, prompts, or runtime assets.

Required:

- source/generation-path evidence;
- clean build from no generated output;
- runtime filesystem access check;
- CLI bundle and package output review;
- controlled headless workflow;
- package tarball inspection where relevant;
- attribution and license review;
- repository size comparison.

### Profile D4 — Workspace, script, or metadata cleanup

Use only after the related candidate deletion is accepted.

Required:

- manifest/workspace/project-reference review;
- clean install and lockfile integrity checks;
- package script and lifecycle review;
- retained build/typecheck/smoke/headless validation;
- stale-reference scan;
- package packing/publishing check where relevant;
- CI and documentation reference review.

## Retained-Closure Regression Matrix

Every D2, D3, and D4 batch must use the current approved retained-closure commands. The exact command matrix must be recorded from the clean-install checkpoint.

At minimum, the validation matrix includes:

1. Immutable install for root tooling and each retained local package.
2. Build of:
   - `packages/config-types`
   - `packages/fetch`
   - `packages/llm-info`
   - `packages/terminal-security`
   - `packages/config-yaml`
   - `packages/openai-adapters`
3. Core immutable install, typecheck, and build.
4. CLI immutable install, typecheck, and build.
5. CLI smoke test.
6. Configuration parsing characterization.
7. Model initialization and selection characterization.
8. Adapter normalization characterization.
9. Controlled headless `cn -p` workflow with loopback/mock transport.
10. Static and emitted-bundle boundary check.
11. Runtime module-resolution boundary check.
12. Lockfile hash comparison before and after installation.
13. Stale-reference, workspace, package, CI, and documentation scan.
14. Legal and attribution verification.

No root-level aggregate command may substitute for the package-specific matrix unless it has been demonstrated to run the same commands and checks.

## Phase 4 Execution Workflow

For every approved candidate or grouped candidate set:

1. Reconcile the candidate evidence against current `main`.
2. Update the candidate classification record.
3. Run the applicable pre-change validation profile.
4. Store pre-change logs and reports under:
   ```text
   docs/reduction/artifacts/phase4/<candidate-id>/pre-change/
   ```
5. Create one narrow experiment commit.
6. Delete only the approved candidate paths and directly related proven stale references.
7. Run the focused disconfirming check.
8. Run the required validation profile.
9. Store post-change logs and reports under:
   ```text
   docs/reduction/artifacts/phase4/<candidate-id>/post-change/
   ```
10. Compare:
    - lockfile hashes;
    - package/workspace metadata;
    - bundle metafile;
    - runtime-resolution report;
    - test results;
    - file count;
    - repository size;
    - legal/attribution status.
11. Update the execution ledger.
12. Evaluate the continuation gate.
13. Continue automatically only if the gate passes.
14. Stop for HITL if a stop condition occurs.

## Continuation Gate

The agent may continue to the next approved Phase 4 batch only when all conditions are true.

- [ ] The current batch stayed inside the path allowlist.
- [ ] The candidate classification remains `Remove`.
- [ ] The removal hypothesis is supported.
- [ ] The focused disconfirming check passed.
- [ ] The applicable validation profile passed.
- [ ] No retained-closure build, typecheck, smoke, headless, bundle, or runtime-boundary check failed.
- [ ] No new `Unknown` dependency, deferred-surface coupling, or public API impact was found.
- [ ] Lockfile and manifest changes are absent or explicitly expected and reviewed.
- [ ] Legal, licensing, and attribution requirements remain satisfied.
- [ ] The diff is limited to the approved batch.
- [ ] The change budget remains within limits.
- [ ] The execution ledger and artifacts are updated.
- [ ] The batch is committed and independently revertible.

## Mandatory HITL Stop Conditions

The agent must stop and request HITL review when any of the following occurs:

| Condition | Required action |
|---|---|
| Candidate is required by CLI/Core runtime, build, test, bundle, package, or filesystem path | Reclassify to `Keep`, `Defer`, or `Unknown`; do not proceed |
| Candidate is used by a deferred surface such as VS Code | Record deferred-surface dependency and request scope decision |
| A static absence conflicts with runtime, bundle, or package evidence | Mark `Unknown` or `Blocked` |
| A clean install, build, typecheck, smoke, headless, or boundary test fails unexpectedly | Revert or pause; provide artifacts |
| A lockfile, manifest, or package-resolution behavior changes unexpectedly | Pause for dependency review |
| A license, NOTICE, copyright, or attribution requirement is unclear | Pause for appropriate review |
| Package publication/packing depends on candidate | Pause for distribution decision |
| Candidate deletion exceeds batch scope or change budget | Request checkpoint review |
| A Core public API, CLI behavior, or package export change is needed | Defer to Phase 3 or separate approved plan |
| Network, credentials, or non-deterministic provider behavior is required | Pause and isolate validation strategy |
| A history rewrite or force-push is proposed | Request separate explicit approval |

## Phase 4 Execution Ledger

Maintain:

```text
docs/reduction/phase4-execution-ledger.md
```

Required fields:

| Batch | Commit | Candidate IDs | Scope | Validation profile | Result | Continuation | Exceptions |
|---|---|---|---|---|---|---|---|
| `P4-01` | `<SHA>` | `<IDs>` | `<paths>` | `D1/D2/D3/D4` | Pass/Fail/Blocked | Continue/Stop | `<none or IDs>` |

Every ledger entry must include links or paths to:

- candidate records;
- Copilot reconciliation records;
- pre-change artifacts;
- post-change artifacts;
- validation command results;
- rollback commit or parent checkpoint;
- file-count and repository-size comparison.

## Initial Candidate Batch Order

Phase 4 executes only candidates already approved as `Remove`. The final order is determined by dependency evidence, but the default order is:

1. **P4-A — Documentation, marketing, screenshots, and unreferenced static assets**
   - Use D1.
   - Preserve operational CLI/Core documentation, licensing, attribution, and README content.

2. **P4-B — Demos, examples, prototypes, and unrelated applications**
   - Use D2.
   - Split by independently validated application surface.

3. **P4-C — GUI/web source and GUI-only tooling**
   - Use D2.
   - Only if prior classification confirms no retained CLI/Core, packaging, or publication dependency.

4. **P4-D — Surface-specific tests, CI, and release workflows**
   - Use D2 or D4.
   - Delete only after corresponding product surfaces are removed and retained coverage is confirmed.

5. **P4-E — Generated and vendored assets**
   - Use D3.
   - Keep vendor/model assets deferred unless runtime filesystem, packaging, and attribution evidence supports removal.

6. **P4-F — Workspace, scripts, metadata, lockfile, and documentation cleanup**
   - Use D4.
   - Perform last, after accepted deletion batches.

## Explicit Deferred Surfaces

The following remain out of Phase 4 deletion scope unless separately approved:

- VS Code extension source and activation code;
- VS Code packaging, marketplace, release, test, and documentation paths;
- binary packaging and distribution ownership paths;
- Core-only registry publishing configuration;
- model/vendor assets without completed runtime and legal evidence;
- any candidate currently classified `Defer` or `Unknown`;
- Core boundary remediation work governed by Phase 3.

## Rollback

All Phase 4 work must be reversible using ordinary Git operations.

Rollback references:

- Phase 4 starting checkpoint;
- individual batch commit SHA;
- Phase branch commit history.

For an accepted batch:

```text
git revert <batch-commit-sha>
```

For a failed or invalid local experiment before publication:

```text
git reset --hard <pre-experiment-sha>
```

Do not rewrite published history or force-push without separate explicit approval.

## Phase 4 Exit Criteria

Phase 4 is complete only when:

- [ ] Every Phase 4 candidate has a final recorded result.
- [ ] Every accepted deletion maps to an approved `Remove` classification.
- [ ] Every rejected candidate is reclassified as `Keep`, `Defer`, `Unknown`, or `Blocked`.
- [ ] Every batch has an atomic rollback path.
- [ ] The retained CLI/Core closure installs, builds, typechecks, and passes deterministic behavior validation.
- [ ] CLI smoke and controlled headless workflows pass.
- [ ] Static, emitted-bundle, and runtime boundary checks pass.
- [ ] No stale references to deleted paths remain.
- [ ] Package/workspace metadata and lockfiles are coherent.
- [ ] Required CI, release, package, docs, license, and attribution artifacts remain.
- [ ] Final package graph and workspace list are recorded.
- [ ] Before/after tracked-file counts and repository-size measurements are recorded.
- [ ] The Phase 4 execution ledger is complete.
- [ ] Remaining `Defer`, `Unknown`, and `Blocked` records are documented with owners and follow-up conditions.
- [ ] A Phase 4 completion summary and one merge-ready PR are prepared for HITL review.

## Phase Exit Deliverables

Before requesting Phase 4 completion review, prepare:

```text
docs/reduction/phase4-summary.md
docs/reduction/phase4-execution-ledger.md
docs/reduction/phase4-final-classification.md
docs/reduction/artifacts/phase4/
```

The summary must include:

- Phase 4 starting checkpoint;
- exact branch and final commit;
- accepted and rejected deletion batches;
- files/packages/surfaces removed;
- retained closure validation results;
- lockfile and package metadata results;
- before/after file count and repository size;
- bundle and runtime-boundary comparison;
- licensing/attribution review outcome;
- deferred and blocked items;
- rollback instructions;
- recommended next phase.

## Approval Gate

Phase 4 may execute only after HITL approves:

1. this plan;
2. the Phase 4 start checkpoint;
3. the candidate path allowlist;
4. the initial batch list;
5. the validation profiles;
6. the continuation and stop conditions; and
7. the change budget.

After approval, successful batches may proceed autonomously within this plan’s W1 execution envelope.

GitHub integration remains HILT:

> One Phase 4 PR is created after Phase 4 exit criteria are met.  
> Human review and merge occur through the approved GitHub workflow.
