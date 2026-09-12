# Rollback Plan: Deletion Experiment Recovery

**Purpose:** Procedures to restore deleted components if deletion experiment fails  
**Date:** 2026-09-12  
**Authority:** Phase 1 deletion approval

## Approved Deletions

| Component | Risk | Status | Rollback |
|-----------|------|--------|----------|
| GUI (gui/) | LOW | Approved for experiment | Simple git revert |
| continue-sdk | MEDIUM | Deferred to Phase 2 | Requires refactoring reversal |

---

## Deletion 1: GUI Component Deletion

### Pre-Deletion Checkpoint
**Command:**
```bash
git tag -a phase1-gui-deletion-pre -m "Pre-GUI deletion checkpoint"
git log --oneline -1  # Record commit hash
```

**Record:** `<commit-hash>`

### Deletion Procedure
**Command:**
```bash
rm -rf gui/
git add -A
git commit -m "DELETE: Remove GUI component (Phase 1 deletion experiment)

Justification:
- GUI has zero dependencies from CLI/Core
- Completely separate build system and lockfile
- Not bundled into CLI binary
- CLI functionality unchanged

Rollback: git revert <commit-hash>"
```

### Immediate Post-Deletion Verification
**Command:**
```bash
# Should all succeed
npm ci --ignore-scripts --no-audit --no-fund
npm run build
./dist/cn.js --version
npm test
```

**Expected:** All commands pass identically to pre-deletion

### Rollback Procedure (if needed)

**Option 1: Simple Git Revert**
```bash
git revert <deletion-commit-hash>
# GUI directory restored, history preserved
```

**Time to restore:** ~30 seconds  
**Verification:**
```bash
test -d gui && echo "✅ GUI restored" || echo "❌ Restore failed"
npm run build  # Should succeed
```

**Option 2: Restore from Tag**
```bash
git checkout phase1-gui-deletion-pre -- gui/
git add gui/
git commit -m "RESTORE: GUI deletion experiment reverted"
```

**Time to restore:** ~1 minute

---

## Deletion 2: continue-sdk (Deferred to Phase 2)

### Why Deferred
- CLI currently depends on SDK
- Requires refactoring CLI to use Core APIs directly
- Medium effort and medium risk
- Better handled in Phase 2 with full refactoring plan

### If SDK Deletion Attempted Without Refactoring

**Symptoms:**
```
CLI build fails:
  "Cannot find module '@continuedev/sdk'"
  
Import errors in:
  - extensions/cli/src/CLIPlatformClient.ts
  - extensions/cli/src/configLoader.ts
  - Tool definition files
```

### Rollback for Premature SDK Deletion

**Immediate restore:**
```bash
git revert <deletion-commit-hash>
# SDK package and all references restored
npm ci --ignore-scripts --no-audit --no-fund
npm run build  # Should succeed
```

**Time to restore:** ~1 minute

---

## Post-Rollback Recovery Plan

### If GUI Deletion Rollback Occurs
1. ✅ GUI files restored
2. ✅ No code changes required
3. ✅ Tests and builds work identically
4. ✅ No data loss or configuration needed
5. **Next:** Schedule follow-up deletion with more investigation

### If SDK Deletion Rollback Occurs
1. ✅ SDK files restored
2. ✅ CLI dependencies restored
3. ✅ CLI builds succeed
4. **Next:** Execute Phase 2 CLI refactoring plan
5. **Then:** Retry SDK deletion after CLI uses Core directly

---

## Verification After Rollback

### Comprehensive Verification Suite
```bash
# Should all pass identically to original state
set -e

# Install all packages
npm ci --ignore-scripts --no-audit --no-fund

# Build all products
npm run build

# Run CLI smoke test
./dist/cn.js --version

# Run Core tests
cd core && npm test

# Run individual package tests
cd packages/config-types && npm test
cd ../fetch && npm test
cd ../llm-info && npm test
cd ../terminal-security && npm test
cd ../config-yaml && npm test
cd ../openai-adapters && npm test

echo "✅ All rollback verifications passed"
```

---

## Risk Mitigation Timeline

### Pre-Deletion (1 hour before)
- ✅ Tag pre-deletion checkpoint
- ✅ Record commit hashes
- ✅ Document rollback commands
- ✅ Notify team of deletion plan
- ✅ Ensure everyone knows rollback procedure

### During Deletion
- ✅ Perform deletion in controlled manner
- ✅ Run immediate post-deletion verification
- ✅ Record results and timing
- ✅ Document any unexpected issues

### 1-24 Hours Post-Deletion
- ✅ Monitor for delayed issues
- ✅ Maintain easy rollback access
- ✅ Have team available for emergency rollback
- ✅ Document learnings if any issues arise

### 24+ Hours Post-Deletion (If Stable)
- ✅ Tag post-deletion checkpoint
- ✅ Consider deletion successful
- ✅ Plan next deletion experiment (continue-sdk)
- ✅ Close deletion gate permanently for deleted component

---

## Contingency Scenarios

### Scenario 1: GUI Deletion Causes CLI Failure
**Symptoms:** CLI commands fail, tests break  
**Cause:** (Unlikely - no dependencies found)  
**Action:**
```bash
git revert <deletion-commit>
# Investigate unexpected dependency in code
grep -r "gui" extensions/cli/src/  # Find any references
# Document finding
# Update removal hypothesis with new information
```

### Scenario 2: GUI Deletion Causes Test Failures
**Symptoms:** Some tests fail after GUI deleted  
**Cause:** (Unlikely - GUI has separate test suite)  
**Action:**
```bash
git revert <deletion-commit>
# Identify which tests fail
npm test 2>&1 | grep -A5 "FAIL"
# Analyze dependency chain
# Update removal hypothesis
```

### Scenario 3: Accidental File Corruption During Deletion
**Symptoms:** Unexpected files modified or deleted  
**Cause:** (Very unlikely - using git)  
**Action:**
```bash
git status  # Review all changes
git diff    # Inspect differences
git restore <any-unintended-changes>
# Retry deletion carefully
```

### Scenario 4: Network/Storage Issues During Rollback
**Symptoms:** Rollback command hangs or fails  
**Cause:** Transient infrastructure issue  
**Action:**
```bash
git status  # Check current state
git reflog  # View available states
git reset --hard HEAD~1  # Force reset to previous commit
git fsck --full  # Check repository integrity
# Retry rollback if needed
```

---

## Success Criteria for Deletion Experiment

### GUI Deletion Success
- ✅ CLI builds without errors
- ✅ CLI tests pass (all suites)
- ✅ Core tests pass (all suites)
- ✅ Headless CLI runs correctly
- ✅ No broken imports or references
- ✅ No build or runtime warnings
- ✅ All 8 retained packages still install/build/test

### Keeping Deletion Permanent
If all success criteria met after 24+ hours:
1. Tag checkpoint: `phase1-gui-deleted`
2. Update decision table: GUI = "DELETED" (from "PROPOSED REMOVE")
3. Plan next deletion: continue-sdk (Phase 2, after CLI refactoring)
4. Document learnings
5. Close deletion gate for GUI permanently

---

## Rollback Timeline Estimates

| Action | Time |
|--------|------|
| Revert deletion commit | 30 sec |
| Restore from git | 1-2 min |
| npm ci after restore | 3-5 min |
| Full verification suite | 5-10 min |
| **Total time to restore** | **~15-20 min** |

---

## Documentation & Communication

### Deletion Announcement
```markdown
# GUI Deletion Experiment Starting

**Time:** 2026-09-12 20:30 UTC-4  
**Component:** GUI (gui/ directory)  
**Risk Level:** LOW  
**Rollback time:** ~15-20 minutes  

Pre-deletion checkpoint: phase1-gui-deletion-pre  
Pre-deletion commit: <hash>

Monitoring for: Build failures, test failures, import errors

Status updates: Will post results in #deletions Slack channel
```

### Post-Deletion Report
- Duration of experiment
- Verification results (pass/fail)
- Any unexpected issues
- Decision: Keep deletion or rollback
- Learnings for future deletions

---

## Summary

**Rollback is simple and fast for GUI deletion (≤20 minutes).** The CLI and Core have zero dependencies on GUI, so recovery is guaranteed to work. continue-sdk deletion is deferred to Phase 2 with proper CLI refactoring as prerequisite.

**Recommendation:** Proceed with GUI deletion experiment with confidence. Rollback plan is straightforward and well-documented.

---

**Document:** Deletion Experiment Rollback Plan  
**Authority:** Phase 1 deletion process  
**Status:** Ready for implementation
**Next step:** Execute GUI deletion → verify 24+ hours → keep permanent
