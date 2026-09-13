# Phase 5: CLI/Core Validation Plan v2

**Status:** Draft; awaiting the single Phase 5 entry approval.
**Execution model:** W1 autonomous execution within one approved phase envelope.
The only HITL entry point for this plan is the Phase 5 Entry Approval Gate
below. Exceptions and phase exit are reported handoffs, not additional entry
approval points.
**Supersedes:** `docs/planning/phase5-cli-core-validation.md`
**Purpose:** Diagnose and resolve the Core `TS2322` type-identity failure, then restore a passing CLI/Core retained-closure validation baseline.

## Scope

Included:

- deterministic reproduction and diagnosis of the Core `TS2322` failure;
- TypeScript resolution, declaration output, aliases, package identity, project references, and dependency analysis;
- narrow Core TypeScript, build, or package-resolution changes supported by evidence;
- required validation artifacts and closeout documentation.

Excluded:

- new repository deletion batches;
- VS Code, GUI, binary, docs-site, or other deferred-surface work;
- broad dependency upgrades;
- unrelated refactors;
- Core public API redesign;
- history rewriting, force-pushing, or branch-protection bypass.

## Authority and working model

Create one durable branch from the approved Phase 5 starting checkpoint:

```text
reduce/phase5-cli-core-validation
```

The phase executor may edit only the approved Phase 5 paths, run approved validation, create local commits/worktrees, and update the ledger. It must not push, create or merge PRs, or modify paths outside the approved allowlist. Phase exit is handed to the Git integration agent.

Make atomic commits for each meaningful result, for example:

```text
test(phase5): capture TS2322 reproduction evidence
fix(core): resolve duplicate type identity
test(validation): restore retained closure matrix
docs(phase5): record validation closeout
```

Continue automatically after a passing gate. Do not request per-step approval. Record state in:

```text
agents/state/phase5-cli-core-validation-state.json
```

The state file is local and gitignored. The committed ledger and artifacts are authoritative review evidence.

## Single HITL Entry Approval Gate

This is the **one and only one HITL entry point** for
`phase5-cli-core-validation_v2.md`. No Phase 5 execution, branch creation,
runner extension, diagnostic batch, remediation batch, or validation batch may
begin until the operator approves this gate in one explicit decision.

The single approval covers the complete plan envelope:

- the scope and exclusions;
- the exact approved paths;
- the W1 execution model;
- the fixed diagnostic and validation profiles;
- the change budget;
- the continuation rules and mandatory stop conditions;
- the Phase 5 branch name and starting checkpoint requirements; and
- the phase-exit handoff to the Git integration agent.

After this approval, the phase executor proceeds autonomously and does not
request per-batch, exception, or validation approvals. A mandatory stop
condition pauses execution and reports evidence to the operator; it does not
create a second entry point or authorize work outside this plan.

## Entry gate requirements

Phase 5 may begin only when all conditions are true:

- [ ] The operator approved this single HITL Entry Approval Gate, including this plan, the path allowlist, validation profiles, stop conditions, and change budget.
- [ ] The starting checkpoint tag, commit SHA, and artifact index are recorded.
- [ ] The branch is created from that checkpoint and is not silently rebased if `main` advances.
- [ ] Node.js `24.19.0` and npm `11.17.0` are installed and active on ubuntu1.
- [ ] The canonical host inventory and runner are available:
  `/Users/brettcon/git/hosts/ubuntu1-hosts.sh`,
  `/Users/brettcon/git/hosts/hosts.sh`, and
  `/Users/brettcon/git/systems-orchestration/scripts/open-circuit-runner.sh`.
- [ ] The runner has an approved fixed Phase 5 diagnostic/validation mode, or the phase is blocked pending that runner capability. No arbitrary caller-supplied remote command substitutes for it.
- [ ] The Phase 5 execution ledger exists.

## Approved paths and change budget

The initial allowlist is limited to:

- `core/**` files directly involved in the failure;
- relevant `core/package.json`, lockfile, TypeScript configuration, build configuration, and package metadata;
- `extensions/cli/**` only when required to validate the retained closure;
- `tests/characterization/**` only for focused regression coverage;
- `docs/reduction/artifacts/phase5/**`;
- `docs/reduction/phase5-execution-ledger.md`;
- `docs/reduction/phase5-summary.md`.

The phase may not modify VS Code, GUI, binary, docs-site, provider behavior, or unrelated package surfaces.

| Metric | Limit |
|---|---:|
| Autonomous diagnostic/fix batches | 6 |
| Atomic commits | 10 |
| Core source/config files changed per batch | 15 |
| CLI files changed per batch | 10 |
| Lockfiles changed without an explicitly approved fix | 0 |
| Broad dependency upgrades | 0 |
| Unexplained validation failures | 0 |
| Type-safety suppressions or exclusions | 0 |

Exceeding a limit stops the phase and reports the evidence to the operator.

## Execution workflow

For each approved batch:

1. Read and update the phase state file with the current batch and checkpoint.
2. Reproduce or inspect the failure on the authoritative ubuntu1 environment through the fixed runner mode.
3. Store sanitized pre-change evidence under:
   `docs/reduction/artifacts/phase5/<batch-id>/pre-change/`.
4. Make the narrowest evidence-backed change in the approved allowlist.
5. Create an atomic commit.
6. Run the fixed Phase 5 diagnostic or validation profile against that committed branch.
7. Store sanitized post-change evidence under:
   `docs/reduction/artifacts/phase5/<batch-id>/post-change/`.
8. Update the ledger with commit SHA, runner mode, host, runtime, commands, results, and artifact paths.
9. Continue only when the continuation gate passes.
10. Stop and report the evidence when a mandatory stop condition occurs.

Temporary logs remain outside the repository or in a gitignored directory. Redact credentials, tokens, cookies, provider responses, user data, private hostnames, and sensitive absolute paths before committing evidence.

## Diagnosis sequence

The diagnostic batch must:

1. Reproduce the failure from a clean `core/dist` state.
2. Capture the exact `TS2322` message, source locations, involved types, and resolved module paths.
3. Repeat the reproduction three times and record determinism.
4. Compare Core build/typecheck scripts, all applicable `tsconfig` files, aliases, project references, package metadata, compiler versions, and lockfile state.
5. Run TypeScript resolution tracing for the failing import/type path.
6. Inspect dependency identity with `npm ls`, lockfile evidence, package resolution paths, and fresh declaration output.
7. Classify the root cause as one of:
   - duplicate package/type identity;
   - source-versus-dist resolution split;
   - alias/package self-reference split;
   - mismatched TypeScript configuration;
   - stale generated declarations;
   - genuine source incompatibility;
   - environment mismatch.
8. Record rejected hypotheses and the evidence that disconfirmed them.

## Remediation rules

Apply only the smallest fix supported by the diagnosis. A fix must not:

- suppress or weaken meaningful type safety;
- exclude the failing files from typecheck;
- broadly upgrade dependencies;
- redesign the Core public API;
- change deferred product surfaces;
- introduce an unreviewed lockfile or package-resolution change.

If a lockfile or package metadata change is required, name the exact files, expected dependency-graph change, and rollback commit before applying it. Unexpected metadata mutation stops the phase.

## Authoritative validation profiles

Local macOS commands may be used for authoring and quick diagnosis, but they do not establish Phase 5 success. Authoritative validation runs on ubuntu1 through the fixed runner and records the remote commit, host, runtime, profile, candidate paths, commands, exit status, and returned artifacts.

The successful profile must include:

- clean Core install with lockfile integrity verification;
- Core build and `tsc:check`;
- retained local-package install/build checks from the approved matrix;
- CLI install, typecheck, build, and smoke test;
- deterministic loopback/mock headless CLI workflow;
- configuration parsing characterization;
- model initialization/selection characterization;
- adapter normalization characterization;
- static and emitted-bundle boundary checks;
- runtime module-resolution boundary check;
- stale-reference and package/workspace scan;
- before/after lockfile hash comparison.

The exact commands must come from the approved retained-closure matrix and fixed runner contract, not from an improvised root-level aggregate command.

## Continuation gate

Continue automatically only when:

- the batch stayed within the approved allowlist;
- the failure signature or remediation hypothesis is recorded;
- the committed change is atomic and reversible;
- the fixed diagnostic/validation profile passed on ubuntu1;
- Core and CLI retained-closure checks passed where applicable;
- no unexpected lockfile, package-resolution, public API, or deferred-surface change occurred;
- no type-safety suppression or unexplained failure exists;
- artifacts are sanitized and the ledger/state files are updated;
- the change budget remains within limits.

## Mandatory stop conditions

Stop execution and report to the operator when:

- the runner lacks an approved fixed Phase 5 mode;
- the root cause requires a broad dependency upgrade or Core public API redesign;
- the fix touches deferred surfaces or an unapproved path;
- the failure is non-deterministic across the authoritative environment;
- validation passes only through suppression, exclusion, or weakened type safety;
- a retained CLI/Core runtime, smoke, headless, bundle, or boundary check fails;
- an unexpected lockfile, package-resolution, or public contract change appears;
- credentials, non-deterministic live providers, or sensitive data are required;
- the change budget is exceeded.

## Ledger and artifacts

Maintain:

```text
docs/reduction/phase5-execution-ledger.md
docs/reduction/artifacts/phase5/
```

Each ledger row must include:

| Field | Requirement |
|---|---|
| Batch | Stable `P5-*` identifier |
| Commit | Atomic commit SHA |
| Scope | Exact changed paths |
| Hypothesis/result | Diagnosis or remediation outcome |
| Runner evidence | Host, runtime, fixed mode, command IDs, exit status |
| Artifacts | Pre/post evidence paths, sanitized status |
| Validation | Matrix/profile IDs and result |
| Rollback | `git revert <commit-sha>` |
| Continuation | Continue or stop |
| Exception | Stop-condition ID or `None` |

## Completion criteria

### Fixed

- [ ] The original `TS2322` root cause is documented.
- [ ] Core clean install, build, and `tsc:check` pass on ubuntu1.
- [ ] CLI typecheck, build, smoke, and deterministic headless validation pass.
- [ ] Configuration, model-selection, and adapter characterization pass.
- [ ] Static, emitted-bundle, and runtime boundary checks pass.
- [ ] No unexpected lockfile or dependency metadata changes exist.
- [ ] All artifacts are sanitized and the ledger is complete.
- [ ] A rollback commit and Phase 5 summary exist.

### Blocked with evidence

- [ ] The failure is precisely characterized.
- [ ] Reproduction attempts and narrow fixes are recorded.
- [ ] The blocking condition and required next technical action are explicit.
- [ ] No unsafe suppression or unrelated workaround was introduced.

## Phase exit

Prepare:

```text
docs/reduction/phase5-summary.md
docs/reduction/phase5-execution-ledger.md
docs/reduction/artifacts/phase5/
```

The summary must state the failure signature, root cause, selected fix or blocker, commit SHAs, exact fixed-runner commands and results, validation status, rollback command, remaining limitations, and whether Phase 4 D2/D3/D4 validation is restored.

After exit criteria pass, hand off to the Git integration agent for one phase-level draft/ready PR workflow and human merge. Do not create or merge that PR from the phase executor.
