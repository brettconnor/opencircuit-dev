# Phase 1: Dependency Inventory and Evidence Artifacts

**Date:** 2026-09-12  
**Status:** IN PROGRESS (Awaiting provider test classification)  
**Checkpoint:** RED-001 core-clean-install  

## Purpose

Complete the Phase 1 deletion-gate validation to authorize product-surface deletion review. This phase establishes comprehensive evidence that CLI and Core are safe to retain, and that proposed deletions (GUI, continue-sdk) have sufficient evidence.

## Artifacts in This Directory

### 1. Package Inventory (`01-package-inventory.md`)
- Complete listing of all local packages (8 packages + 3 products)
- Package purposes and retention decisions
- Phase 0 retained-closure classification
- Workspace structure documentation

### 2. Decision Table (`02-decision-table.md`)
- Authoritative Keep/Remove/Defer/Unknown decisions
- Rationale for each component
- Evidence tracking status
- Approval gates for each decision

### 3. CLI Imports (`03-cli-imports.md`)
- CLI import dependencies from local packages
- CLI-to-SDK dependency chain
- Bundle strategy and external dependencies
- Runtime vs. buildtime linking analysis

### 4. Retained-Closure Matrix (existing)
- Installation validation for all 8 retained packages
- Build and typecheck results from RED-001
- Lockfile hash verification
- Package version snapshots

## Validation Status

### ✅ Completed (Phase 0 → RED-001)

- Core lockfile integrity repair (Node 24.19.0)
- All 8 package installs passing
- All 8 package builds passing
- Core and CLI typechecks passing
- Static and runtime boundary checks passing
- Puppeteer ESM/CommonJS incompatibility resolved

### ⏳ In Progress (Phase 1)

- Provider test isolation and classification
- Phase 1 evidence artifact completion
- Dynamic dependency mapping
- Emitted bundle-input report generation
- Unresolved exception list finalization

### ⏹️ Blocked Until

1. **Provider tests classified:** Anthropic, OpenAI, Mistral tests separated into deletion-gate (mocked) and integration (credential-gated)
2. **Removal hypotheses documented:** Static/dynamic/bundle evidence for GUI and continue-sdk
3. **Runtime asset tracing:** Core vendor and model assets inventoried

## Next Steps

### Immediate (Next 1 hour)

1. ✅ Puppeteer fix validated and committed
2. ⏳ Provider test classification (background agent running)
3. Create dynamic dependency map script
4. Generate bundle-input report
5. Finalize unresolved exceptions list

### Phase 1 Final (Next 2-3 hours)

6. Run complete retained-closure matrix (all 8 packages, all commands)
7. Generate removal hypothesis evidence for GUI
8. Generate removal hypothesis evidence for continue-sdk
9. Document rollback plan
10. Create post-change comparison command set

### Verification (Final)

11. Execute 10-point verification checklist
12. Confirm all deletion-gate conditions met
13. Present deletion approval review
14. Record immutable checkpoint

## Phase 1 Readiness Checklist

| Item | Status | Notes |
|------|--------|-------|
| Puppeteer fix | ✅ Done | 9 suites pass, core suite 50/50 pass |
| Provider tests isolated | ⏳ In progress | Background agent running |
| Package inventory | ✅ Done | 8 packages + 3 products documented |
| Decision table | ✅ Draft | Awaiting provider test + artifact completion |
| CLI imports | ✅ Done | 4 package sources identified |
| Dynamic dependency map | ⏳ Pending | Next after provider tests |
| Bundle report | ⏳ Pending | Requires CLI build analysis |
| Removal hypotheses | ⏳ Pending | Awaiting all other completion |
| Unresolved exceptions | ⏳ Pending | Final review item |
| Verification checklist | ⏳ Pending | Runs after all evidence complete |

## Deletion Approval Prerequisites

Before any product deletion can proceed, ALL of these must be true:

1. ✅ RED-001 has verified immutable checkpoint
2. ✅ Puppeteer/module-resolution failures are fixed
3. ✅ Deterministic Core suite passes (50/50 suites, 841/841 tests)
4. ⏳ Provider integration tests explicitly classified and approved as non-gating
5. ⏳ Retained-closure matrix passes or each failure has written approval
6. ⏳ Required Phase 1 artifacts complete and internally consistent
7. ⏳ Every deletion candidate has static/dynamic/build/bundle/runtime evidence
8. ⏳ Each deletion candidate has focused disconfirming check
9. ⏳ Rollback plan and post-change comparison recorded
10. ⏳ No unrelated product or dependency changes included

**Current gate status:** 3/10 met → **NO-GO FOR DELETION** (expected for Phase 1 in progress)

## Evidence Files

| File | Status | SHA-256 (when available) | Location |
|------|--------|----------|----------|
| core/package-lock.json | ✅ Immutable | f58106181d204060082a4d41f19665856c2debc46fac4677dec7f9251e611398 | Version pinned |
| extensions/cli/package-lock.json | ✅ Immutable | dc623a31792fa0541a7a9e809a5614f94a14c005b8dd144809a986ec8b115257 | Version pinned |
| Core test log | ✅ Complete | - | docs/reduction/artifacts/red-001/validation/ |
| Puppeteer fix log | ✅ Complete | - | Session files |
| Provider classification | ⏳ Pending | - | TBD after completion |

## Scope Boundaries

### Included in Phase 1

- Puppeteer compatibility remediation
- Provider-test determinism and classification
- Phase 1 inventory completion
- Evidence and provenance cleanup
- Deletion-gate review

### Explicitly Excluded from Phase 1

- GUI deletion experiment
- VS Code deletion or modification
- Binary deletion or modification
- Core API refactoring
- Replacement of CLI deep imports
- History rewriting
- Unrelated dependency upgrades
- Provider behavior changes

---

**Last updated:** 2026-09-12 20:05 UTC-4  
**Next review:** Upon provider test classification completion  
**Owner:** Phase 1 readiness process  
**Audience:** Deletion approval reviewers
