# Post-Change Verification Commands

**Purpose:** Verify product integrity after component deletion  
**Date:** 2026-09-12  
**Authority:** Phase 1 deletion approval

---

## Post-GUI-Deletion Verification

### When to Run
**After:** GUI deletion experiment completes  
**Timeline:** 30 minutes after deletion, then 1 hour, then 24 hours  
**Purpose:** Confirm CLI and Core remain fully functional

### Verification Suite

```bash
#!/bin/bash
set -e

echo "=== POST-GUI-DELETION VERIFICATION ==="
echo "Date: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
echo "Node: $(node -v), npm: $(npm -v)"
echo ""

# 1. Verify GUI is gone
echo "1. Confirming GUI directory deleted..."
if [ -d "gui" ]; then
  echo "❌ FAIL: GUI directory still exists"
  exit 1
else
  echo "✅ PASS: GUI directory deleted"
fi
echo ""

# 2. Clean install all packages
echo "2. Running clean install..."
npm ci --ignore-scripts --no-audit --no-fund > /dev/null 2>&1
echo "✅ PASS: Clean install succeeded"
echo ""

# 3. Build CLI
echo "3. Building CLI..."
cd extensions/cli
npm run build > /dev/null 2>&1
echo "✅ PASS: CLI build succeeded"

# 4. Test CLI basic functionality
echo "4. Testing CLI basic functionality..."
./dist/cn.js --version > /dev/null 2>&1
echo "✅ PASS: CLI --version works"

# 5. Test CLI help
./dist/cn.js --help | grep -q "Continue" > /dev/null 2>&1
echo "✅ PASS: CLI help works"

# 6. Test CLI plugin list
./dist/cn.js list-plugins > /dev/null 2>&1
echo "✅ PASS: CLI list-plugins works"
cd ../..
echo ""

# 7. Build Core
echo "5. Building Core..."
cd core
npm run build > /dev/null 2>&1
echo "✅ PASS: Core build succeeded"

# 8. Run Core tests
echo "6. Running Core tests..."
npm test > /dev/null 2>&1
echo "✅ PASS: Core tests pass"
cd ..
echo ""

# 9. Test individual packages
echo "7. Testing individual packages..."
for pkg in packages/config-types packages/fetch packages/llm-info \
           packages/terminal-security packages/config-yaml packages/openai-adapters; do
  cd "$pkg"
  npm run build > /dev/null 2>&1
  cd ../..
  echo "  ✅ $pkg"
done
echo ""

# 10. Verify no broken imports
echo "8. Verifying no broken imports..."
grep -r "gui" extensions/cli/src/ > /dev/null 2>&1 && \
  echo "⚠️  WARNING: Found 'gui' in CLI source" || \
  echo "✅ PASS: No GUI references in CLI"

grep -r "gui" core/src/ > /dev/null 2>&1 && \
  echo "⚠️  WARNING: Found 'gui' in Core source" || \
  echo "✅ PASS: No GUI references in Core"
echo ""

echo "=== VERIFICATION COMPLETE ==="
echo "All checks passed. GUI deletion is stable."
echo ""
```

### Expected Results
- ✅ GUI directory deleted
- ✅ Clean install succeeds
- ✅ CLI builds and runs
- ✅ CLI --version, --help, list-plugins work
- ✅ Core builds and tests pass
- ✅ All 6 local packages build
- ✅ No broken imports

### Success Criteria
If all 10 verification steps pass, GUI deletion is **PERMANENT**.

---

## Post-continue-sdk-Deletion Verification (Phase 2)

### When to Run
**After:** continue-sdk deletion with CLI refactoring complete  
**Timeline:** Same as GUI (30 min, 1 hr, 24 hrs)  
**Purpose:** Confirm CLI uses Core APIs directly

### Verification Suite

```bash
#!/bin/bash
set -e

echo "=== POST-CONTINUE-SDK-DELETION VERIFICATION ==="
echo "Date: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
echo ""

# 1. Verify SDK is gone
echo "1. Confirming continue-sdk deleted..."
if [ -d "packages/continue-sdk" ]; then
  echo "❌ FAIL: continue-sdk still exists"
  exit 1
else
  echo "✅ PASS: continue-sdk deleted"
fi
echo ""

# 2. Verify no SDK in package.json
echo "2. Checking root package.json..."
grep -q "continue-sdk" package.json && \
  echo "❌ FAIL: continue-sdk reference in root package.json" || \
  echo "✅ PASS: No continue-sdk in root package.json"

grep -q '"continue-sdk"' extensions/cli/package.json && \
  echo "❌ FAIL: continue-sdk dependency in CLI" || \
  echo "✅ PASS: CLI does not depend on continue-sdk"
echo ""

# 3. Build CLI
echo "3. Building CLI..."
cd extensions/cli
npm run build > /dev/null 2>&1
echo "✅ PASS: CLI build succeeded"

# 4. Verify CLI uses Core directly
echo "4. Checking CLI imports Core directly..."
grep -r "from.*@continuedev/core" src/ > /dev/null 2>&1 && \
  echo "✅ PASS: CLI imports Core directly" || \
  echo "⚠️  WARNING: No direct Core imports found"

# 5. Test CLI functionality
./dist/cn.js --version > /dev/null 2>&1
echo "✅ PASS: CLI --version works"
cd ../..
echo ""

# 6. Run Core tests
echo "5. Running Core tests..."
cd core
npm test > /dev/null 2>&1
echo "✅ PASS: Core tests pass"
cd ..
echo ""

# 7. Verify no SDK references in build output
echo "6. Checking for SDK references in bundle..."
grep -i "sdk" extensions/cli/dist/cn.js > /dev/null 2>&1 && \
  echo "⚠️  WARNING: Found 'sdk' in CLI bundle (may be legitimate)" || \
  echo "✅ PASS: No continue-sdk references in bundle"
echo ""

echo "=== VERIFICATION COMPLETE ==="
echo "All checks passed. continue-sdk deletion is stable."
echo ""
```

### Expected Results
- ✅ continue-sdk directory deleted
- ✅ No SDK references in package.json
- ✅ CLI builds successfully
- ✅ CLI imports Core directly
- ✅ CLI functionality works
- ✅ Core tests pass
- ✅ No SDK references in bundle

### Success Criteria
If all checks pass, continue-sdk deletion is **PERMANENT**.

---

## Comparison Matrix: Before vs After Deletion

| Check | Before Deletion | After Deletion | Status |
|-------|-----------------|----------------|--------|
| CLI builds | ✅ | Should ✅ | Pass = OK |
| Core builds | ✅ | Should ✅ | Pass = OK |
| CLI tests | ✅ | Should ✅ | Pass = OK |
| Core tests | ✅ | Should ✅ | Pass = OK |
| Package 6+ | ✅ | Should ✅ | Pass = OK |
| No broken imports | ✅ | Should ✅ | Pass = OK |
| CLI functionality | ✅ | Should ✅ | Pass = OK |

---

## Failure Recovery

### If Verification Fails
1. **Stop immediately** - Do not proceed further
2. **Execute rollback** - Use commands from rollback plan
3. **Investigate** - Review failure details and update removal hypothesis
4. **Document** - Record why verification failed
5. **Retry** - Address root cause and attempt deletion again

### Common Failure Scenarios

**Scenario 1: Build fails after deletion**
```bash
# Likely cause: Unexpected import of deleted component
# Recovery:
git revert <deletion-commit>
grep -r "deleted-component" extensions/cli/src/ core/src/
# Document finding and update removal hypothesis
```

**Scenario 2: Tests fail after deletion**
```bash
# Likely cause: Test suite dependency on deleted component
# Recovery:
git revert <deletion-commit>
npm test 2>&1 | grep "deleted-component" || grep -i "fail"
# Document and update hypothesis
```

**Scenario 3: CLI hangs or crashes**
```bash
# Likely cause: Runtime path through deleted component
# Recovery:
git revert <deletion-commit>
# Profile CLI execution to identify unexpected paths
```

---

## Monitoring Period

### 30 Minutes Post-Deletion
- Run full verification suite
- Document results
- Continue monitoring

### 1 Hour Post-Deletion
- Run verification suite again
- Check for delayed failures
- Continue monitoring

### 24 Hours Post-Deletion
- Final verification suite
- If all pass: deletion is **STABLE**
- If any fail: execute immediate rollback
- Document learnings

---

## Sign-Off Criteria

**Deletion is PERMANENT when:**
1. ✅ All verification checks pass
2. ✅ 30-minute monitoring clear
3. ✅ 1-hour monitoring clear
4. ✅ 24-hour monitoring clear
5. ✅ No user-reported issues
6. ✅ Board approval documented

---

## Success Documentation

After 24+ hours with all verifications passing:

```markdown
# Deletion Experiment: SUCCESSFUL

**Component:** [GUI / continue-sdk]
**Deletion Date:** 2026-09-12
**Deletion Commit:** [hash]
**Verification:** All checks passed
**Monitoring:** 24+ hours, no issues

**Decision:** KEEP DELETION PERMANENT

Next step: [GUI→proceed to Phase 2 SDK refactoring] / [SDK→complete Phase 1]
```

---

**Document:** Post-Change Verification  
**Authority:** Phase 1 deletion process  
**Status:** Ready for implementation
**Use these commands immediately after each deletion**
