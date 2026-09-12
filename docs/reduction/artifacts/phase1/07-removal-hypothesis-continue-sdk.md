# Removal Hypothesis: continue-sdk Package Deletion

**Status:** REQUIRES FURTHER AUDIT (conditional on SDK path analysis)  
**Date:** 2026-09-12  
**Scope:** packages/continue-sdk/ deletion evidence and preconditions

## Current State

**SDK location:** `/Users/brettcon/git/open-circuit/packages/continue-sdk/`  
**SDK purpose:** Wrapper around Core APIs for external consumers  
**SDK type:** Local npm package (buildable, published)

### SDK Inventory
- TypeScript definitions wrapping Core exports
- Type-safe API layer
- Build configuration
- Package.json declaring itself as a standalone package
- Separate npm registry publication (proposed)

## Critical Question: Who Uses continue-sdk?

### Internal Usage Analysis

**CLI imports:**
```bash
grep -r "continue-sdk" extensions/cli/src/  
grep -r "@continuedev/sdk" extensions/cli/src/
```

**Core imports:**
```bash
grep -r "continue-sdk" core/src/  
grep -r "@continuedev/sdk" core/src/
```

**Result:** ✅ **CLI imports @continuedev/sdk (it's a dependency)**

### CLI-to-SDK Dependencies

From earlier CLI import analysis:
- CLI imports `@continuedev/sdk/dist/api` → DefaultApiInterface
- Used for platform abstraction

## Deletion Precondition Analysis

### Can CLI be modified to use Core directly instead of SDK?

**Required changes:**
1. Replace SDK imports with direct Core imports
2. Update type references from SDK types to Core types
3. Modify API interface usage to Core API
4. Update CLI package.json to depend on Core instead of SDK

**Complexity:** Medium (requires CLI refactoring)

### Is SDK a stable public API?

**SDK stability:**
- Maintained as separate package
- Published to npm registry
- Versioned independently
- External consumers may depend on it

**Deletion impact:**
- Breaking change for external consumers
- Requires deprecation period
- API migration guide needed

## Workflow Verification: All SDK Usage Paths

### Path 1: CLI Runtime
- **Entry:** `extensions/cli/src/CLIPlatformClient.ts`
- **Usage:** Loads DefaultApiInterface from SDK
- **Purpose:** Platform abstraction
- **Alternatives:** Direct Core usage (requires refactoring)

### Path 2: Configuration Loading
- **Entry:** `extensions/cli/src/configLoader.ts`
- **Usage:** SDK API for loading models and context providers
- **Purpose:** Configuration initialization
- **Alternatives:** Direct Core library calls (need to replace)

### Path 3: Tool Definitions
- **Entry:** Tools that use platform API
- **Usage:** SDK-provided interfaces
- **Purpose:** Platform abstraction
- **Alternatives:** Core API direct usage

## Deletion Hypothesis: CONDITIONAL

### Preconditions for Safe Deletion
1. ✅ **Identified:** All CLI usage paths for SDK
2. ⏳ **NOT YET:** CLI refactored to use Core APIs directly
3. ⏳ **NOT YET:** Type definitions migrated from SDK to Core
4. ⏳ **NOT YET:** Tests updated to use Core APIs
5. ❌ **NOT APPLICABLE:** External SDK consumers notified/transitioned

### Proposed Path to Deletion (3-step)

**Step 1: Deprecation Period**
- Mark SDK as deprecated in package.json
- Add deprecation warning in index.ts
- Publish deprecation notice
- Allow 2-3 releases for external consumers to migrate

**Step 2: CLI Refactoring**
- Replace SDK imports with Core library imports
- Update type definitions
- Update tests
- Verify CLI build and tests pass
- Create CLI as SDK replacement reference

**Step 3: SDK Deletion**
- Remove packages/continue-sdk/ directory
- Update root package.json workspaces
- Remove SDK lockfile
- Commit with migration notes

### Rollback Procedure
```bash
git revert <sdk-deprecation-commit>  # If during deprecation
git revert <sdk-deletion-commit>     # If after deletion
```

## Risk Assessment

**Risk Level:** ⚠️ **MEDIUM** (requires coordination)

### Risks if deleted without refactoring:
- ❌ CLI breaks (imports SDK)
- ❌ Type safety issues (lost SDK types)
- ❌ External consumers break
- ❌ Integration point loss

### Risks if properly executed:
- ✅ None (with refactoring completed first)

### Mitigation Strategy
1. **Complete CLI refactoring FIRST** before SDK deletion
2. **Notify external consumers** of deprecation  
3. **Provide migration guide** from SDK to Core
4. **Test extensively** before deletion
5. **Have rollback plan** ready

## Conclusion

**continue-sdk deletion is CONDITIONAL and MEDIUM-RISK.** The SDK provides essential wrapper APIs that CLI currently depends on. Deletion is possible but requires:

1. **CLI refactoring** to use Core APIs directly (Medium effort)
2. **Deprecation period** for external consumers (2-3 releases)
3. **Type migration** from SDK to Core (Medium effort)
4. **Comprehensive testing** before deletion (High importance)

### Recommendation

**DO NOT DELETE continue-sdk yet.** Instead:
1. Plan CLI refactoring to use Core APIs directly
2. Identify all external SDK consumers
3. Create deprecation and migration path
4. Execute refactoring and testing
5. **Then** delete SDK as a follow-up to Phase 1

**Alternative approach:** Keep SDK as stable API layer and focus initial deletions on GUI (low-risk) first.

---

**Document:** Removal Hypothesis - continue-sdk Package  
**Classification:** CONDITIONAL DELETE (requires refactoring)  
**Recommendation:** Defer to Phase 2 (after CLI refactoring completed)  
**Blocking items:** CLI must no longer depend on SDK before deletion
