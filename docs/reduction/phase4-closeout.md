**Phase 4 is not fully complete under the stated plan; P4-A is accepted, while P4-B is conditionally accepted only if the waiver is formalized and bounded.**

The ledger and manifest are generally well structured, with explicit allowlists, narrow scope, and clear exclusion of deferred surfaces. The main issue is that the status language overstates completion relative to the Phase 4 validation rules.

---

## Accepted: P4-A

P4-A appears consistent with the D1 profile:

- Exact allowlist of 23 documentation image paths.
- Candidate set is limited to duplicate or unreferenced assets.
- Canonical referenced assets were retained.
- D1 checks passed locally and on Ubuntu1.
- Ubuntu1 validation explicitly reports 23/23 allowlisted paths passed.
- No source, package, lockfile, runtime, or deferred-surface changes are claimed.
- The 62-to-39 tracked `docs/images` measurement is useful, though the exact measurement command/artifact should remain linked.

### P4-A recommended final status

```text
Accepted — D1 validation passed locally and on Ubuntu1.
```

---

## Conditional: P4-B

P4-B is a low-risk candidate in substance: stale root `.idea` metadata referring to absent JetBrains modules is plausibly outside the CLI/Core closure.

However, the plan’s D2/D4 acceptance rules require retained-closure validation. The ledger says:

> `core npm run tsc:check` TS2322 waived for this batch

and:

> 0/20 passed because the retained matrix failed at Core `npm run tsc:check`

That means P4-B cannot be recorded as an unqualified validation pass. It is an accepted deletion under an explicit waiver, provided the waiver establishes that the failure is genuinely baseline-equivalent and unrelated to the `.idea` deletion.

### Required waiver evidence

The waiver should include all of the following:

| Requirement | Needed evidence |
|---|---|
| Baseline equivalence | The same `core npm run tsc:check` TS2322 failure occurs at the P4-B parent commit before deleting `.idea` files. |
| Exact failure identity | Same source location, error code, message, and relevant type names before and after deletion. |
| Scope proof | `.idea` is not read by Core build/typecheck scripts, TypeScript project references, or Node/npm lifecycle paths. |
| Remaining validation | All applicable checks after the waived step pass: CLI build/smoke, headless workflow, boundary checks, stale-reference check, and lockfile integrity. |
| Waiver ownership | Explicit reviewer/owner, date, scope, and expiry condition. |
| Non-precedent rule | The waiver applies only to `P4-B`, does not relax D2/D4 generally, and does not authorize later deletions under a failing closure. |

The current wording says the failure is “pre-existing” and “unrelated,” but the ledger should link the exact pre-change and post-change artifacts proving those claims.

### P4-B recommended final status

```text
Conditionally accepted under bounded validation waiver — retained-Core typecheck remains failing and must be resolved or re-baselined before any future D2/D3/D4 deletion batch.
```

Do not label P4-B simply as `Pass`.

---

# Required status corrections

## 1. “Phase 4 complete at continuation gate” is ambiguous

The phase did stop at the continuation gate because there were no additional eligible candidates. That is valid.

But “Phase 4 complete” should distinguish:

- **execution completion**: all approved candidates were processed;
- **validation completion**: P4-B has a waived retained-closure failure;
- **phase exit completion**: final artifacts, review, and merge-ready branch are prepared.

Recommended status:

```text
Status: Phase 4 execution complete. P4-A is fully validated.
P4-B is conditionally accepted under a batch-specific validation waiver.
Phase 4 is ready for HITL exit review, not yet unconditionally closed.
```

---

## 2. Correct the D2/D4 taxonomy inconsistency

The P4-B row says:

```text
Profile: D2 (workspace metadata; D4 by plan taxonomy)
```

This must be one defined profile.

Based on the Phase 4 plan, stale root `.idea` metadata is most naturally:

```text
D4 — Workspace, script, or metadata cleanup
```

Use D4 consistently in:

- the candidate manifest;
- batch ledger;
- reconciliation artifact;
- waiver;
- phase summary.

If D2 was intentionally used as the stricter profile, state that explicitly:

```text
Validation profile: D4, validated using the stricter D2 retained-closure matrix.
```

That is preferable to recording two conflicting classifications.

---

## 3. Reconcile commit references

The ledger identifies several commits:

| Item | Commit |
|---|---|
| Source `main` at phase entry | `450df8c69cfbb47c87fbd3d45f318279ca8c3074` |
| P4-A deletion | `1acd6b5aa` |
| P4-A evidence | `e5f6e6358` |
| Git handoff remote branch | `2bbb5ed53` |
| P4-B deletion | `ceb6624f9` |
| P4-B evidence | `d0636908f` |

The final ledger needs one authoritative final phase commit, for example:

```text
Phase branch final commit: <full SHA>
Remote branch commit validated by Ubuntu1: <full SHA>
```

Also record whether Ubuntu1 validated:

- P4-A only at `2bbb5ed53`, or
- the final P4-A + P4-B branch state.

At present, the text clearly describes Ubuntu1 D1 validation for P4-A, but P4-B’s remote validated commit is not stated.

---

## 4. “0/20 passed” should not be used as a candidate result

The phrase:

> “0/20 passed because the retained matrix failed at Core…”

can be misread to mean all 20 `.idea` files individually failed validation.

More precise wording:

```text
The P4-B D4 validation run was blocked before candidate-specific completion because the retained Core typecheck failed with baseline-equivalent TS2322. The candidate-specific stale-reference and scope checks passed; retained-closure acceptance was granted only through the documented operator waiver.
```

This separates:

- candidate-specific evidence;
- global retained-closure failure;
- waiver decision.

---

# Required final evidence additions

Before Phase 4 exit review, add or verify these artifacts.

## P4-B waiver record

Suggested path:

```text
docs/reduction/artifacts/phase4/P4-B/validation-waiver.md
```

Suggested contents:

```markdown
# P4-B Validation Waiver

## Batch
P4-B — stale root `.idea` metadata deletion

## Waived command
cd core && npm run tsc:check

## Failure
TS2322: <exact message, source location, and type identity details>

## Baseline comparison
- Parent commit: <full SHA>
- Deletion commit: <full SHA>
- Baseline artifact: <path>
- Post-change artifact: <path>
- Result: identical / materially equivalent failure

## Scope proof
- `.idea` is absent from TypeScript configuration references.
- `.idea` is absent from Core package scripts and lifecycle scripts.
- `.idea` is absent from retained workspace configuration.
- `.idea` is ignored or non-input to the Core build/typecheck process.

## Remaining validation
- Candidate stale-reference check: pass
- Core build: pass
- CLI build/typecheck: pass
- CLI smoke: pass
- Headless workflow: pass
- Static/bundle boundary: pass
- Runtime boundary: pass
- Lockfile integrity: pass

## Waiver decision
- Scope: P4-B only
- Does not apply to subsequent deletion batches
- Does not modify candidate classification policy
- Requires Core TS2322 remediation or approved re-baseline before later D2/D3/D4 work

## Approved by
Operator ratification, 2026-09-13
```

## Final Phase 4 summary

Create or complete:

```text
docs/reduction/phase4-summary.md
```

Include:

- start checkpoint and exact SHA;
- final phase branch SHA;
- P4-A accepted removal;
- P4-B conditional acceptance and waiver;
- files removed by batch;
- tracked-file and repository-size deltas;
- final retained closure validation status;
- unresolved Core TS2322 limitation;
- deferred/unknown surfaces;
- explicit recommendation for the next phase.

---

# Recommended final ledger wording

Replace the opening status with:

```markdown
**Status:** Phase 4 execution is complete. P4-A passed the D1 validation
profile locally and on Ubuntu1. P4-B is conditionally accepted under a
batch-specific operator waiver for a baseline-equivalent Core TS2322 failure.
No further approved Phase 4 candidate remains. Phase 4 is ready for HITL exit
review after waiver evidence, final commit reconciliation, and phase-summary
completion.
```

Replace the P4-B result row with:

| Batch | Deletion commit | Evidence commit | Candidate IDs | Scope | Profile | Result | Continuation | Exceptions |
|---|---|---|---|---|---|---|---|---|
| P4-B | `ceb6624f9` | `d0636908f` | `P4-B` | 20 stale root `.idea` metadata files | D4, validated with D2-equivalent retained closure checks | Conditionally accepted under batch-specific waiver | Stop — no additional eligible candidate | Baseline-equivalent Core `tsc:check` TS2322 waived for P4-B only |

---

## Final assessment

- **P4-A:** accepted.
- **P4-B:** acceptable only as a narrowly bounded, explicitly documented waiver decision.
- **Phase 4:** execution complete, but should be presented as **ready for HITL exit review**, not as unconditionally complete under the original D2/D4 validation contract.

The Core TS2322 failure should be the first named prerequisite for any later Phase 4-style source, package, workspace, generated-asset, or metadata deletion that relies on the full retained-closure matrix.

Next action is **Phase 4 exit-evidence reconciliation**, not further deletion.

## Immediate action

Create a narrow documentation/evidence commit on the existing Phase 4 branch that:

1. **Adds the P4-B bounded waiver record**
   ```text
   docs/reduction/artifacts/phase4/P4-B/validation-waiver.md
   ```
   It must prove the Core `TS2322` failure is baseline-equivalent before and after `.idea` deletion, and state:
   - waived command;
   - exact error/location;
   - parent and deletion commit SHAs;
   - artifact paths for before/after logs;
   - `.idea` scope proof;
   - remaining validations and their results;
   - waiver scope: **P4-B only**;
   - expiry: no future D2/D3/D4 deletion batch may rely on it.

2. **Normalize P4-B to one validation profile**
   - Record P4-B as:
     ```text
     D4 — workspace/metadata cleanup,
     validated using the stricter D2 retained-closure matrix
     ```
   - Remove the ambiguous `D2 (workspace metadata; D4 by plan taxonomy)` wording.

3. **Update the execution ledger status**
   Replace unconditional completion language with:
   ```text
   Phase 4 execution complete; ready for HITL exit review.
   P4-A accepted. P4-B conditionally accepted under a P4-B-only waiver.
   ```

4. **Add or complete `docs/reduction/phase4-summary.md`**
   Include:
   - phase start checkpoint and final branch SHA;
   - P4-A and P4-B commits;
   - exact deleted path counts;
   - before/after file count and repository-size values;
   - Ubuntu1 validation commit(s);
   - P4-B waiver reference;
   - deferred/unknown surfaces;
   - explicit next prerequisite: resolve or re-baseline Core `TS2322` before later D2/D3/D4 work.

5. **Reconcile commit provenance**
   Record exact full SHAs for:
   - Phase branch final HEAD;
   - P4-A deletion/evidence commits;
   - P4-B deletion/evidence commits;
   - remote commit validated on Ubuntu1 for P4-A;
   - remote commit validated on Ubuntu1 for P4-B, if applicable.

## Required validation for this action

This is a documentation/evidence-only batch, so run:

```bash
git diff --check
git status --short
```

Also verify all referenced files, commits, and artifact paths exist:

```bash
git rev-parse red-001-core-clean-install
git rev-parse 1acd6b5aa
git rev-parse e5f6e6358
git rev-parse ceb6624f9
git rev-parse d0636908f
git rev-parse 2bbb5ed53
```

Do **not**:

- perform another deletion batch;
- alter Core code;
- repair the TS2322 issue;
- change lockfiles;
- modify deferred surfaces;
- create a new Phase plan.

## Completion point

After the evidence commit is complete, stop and present the Phase 4 exit package for HITL review:

```text
- phase4 execution ledger
- P4-B waiver record
- Phase 4 summary
- final branch SHA
- final diff/stat
- artifact index
- recommended next phase: Core TS2322 remediation/re-baseline
```