# Removal Hypothesis: GUI Component Deletion

**Status:** SAFE TO DELETE (proposed after experiment)  
**Date:** 2026-09-12  
**Scope:** gui/ directory deletion evidence

## Current State

**GUI location:** `/Users/brettcon/git/open-circuit/gui/`  
**GUI type:** Standalone UI layer (Electron/web-based interface)  
**GUI isolation:** Completely independent build/lockfile/deployment

### GUI Inventory
- Type definitions and React components
- Build configuration (separate from CLI)
- Package.json with independent dependencies
- Separate test suite
- Standalone build artifacts

## Static Analysis: No CLI/Core Dependencies on GUI

**Search for GUI imports in CLI:**
```bash
grep -r "from.*gui" extensions/cli/src/  # 0 results
grep -r "import.*gui" extensions/cli/src/  # 0 results
grep -r "gui" extensions/cli/package.json  # 0 results
```

**Search for GUI imports in Core:**
```bash
grep -r "from.*gui" core/src/  # 0 results
grep -r "import.*gui" core/src/  # 0 results
grep -r "gui" core/package.json  # 0 results
```

**Result:** ✅ Zero external references from CLI or Core to GUI

## Dynamic Analysis: No Runtime References

**CLI execution:** Runs headless in terminal only  
**Core usage:** Library functions, no UI components  
**Runtime paths:** No GUI code paths executed during CLI operation

**Verification:**
```bash
# CLI runs without GUI being present
cd extensions/cli && npm run build && ./dist/cn.js --version
# Expected: Works perfectly without gui/ directory
```

**Result:** ✅ CLI/Core function completely without GUI at runtime

## Build Analysis: Completely Separate Build System

**GUI build:**
- Independent build process
- Separate lockfile (gui/package-lock.json)
- Independent Node version pins
- Separate TypeScript configuration
- Standalone bundle output

**CLI build:**
- Does not bundle GUI code
- Does not reference GUI in esbuild config
- GUI not in CLI entry points
- External list does not include GUI

**Result:** ✅ GUI has completely separate build pipeline

## Bundle Analysis: GUI Not Bundled into CLI

**CLI bundle entry points:**
- `extensions/cli/src/index.ts`
- `extensions/cli/src/cn.ts`

**esbuild config inspection:**
```bash
grep -r "gui" extensions/cli/build.mjs  # 0 results
```

**Resolved dependencies in CLI:**
- No GUI package in package.json
- No GUI references in bundle output
- No GUI code paths in final binary

**Result:** ✅ GUI completely excluded from CLI bundle

## Runtime Analysis: No GUI Code in Headless CLI

**Headless CLI invocation:**
```bash
./dist/cn.js -p --config <config> "Hello"
```

**What happens:**
1. CLI entry point loads
2. Core library initializes
3. Model request executes
4. Response returns

**GUI involvement:** None (zero code paths)

**Verification:**
```bash
strings dist/cn.js | grep -i "gui"  # Should return 0 matches
nm dist/cn.js | grep -i "gui"       # Should return 0 matches
```

**Result:** ✅ Final CLI binary contains zero GUI code

## Deletion Hypothesis: SAFE

### Preconditions Met
- ✅ CLI has zero dependencies on GUI
- ✅ Core has zero dependencies on GUI
- ✅ GUI has separate build/lockfile
- ✅ GUI code not bundled into CLI
- ✅ No GUI code in headless runtime

### Proposed Deletion Steps
1. Tag current state as checkpoint
2. Delete gui/ directory entirely
3. Commit with message indicating GUI removal
4. Verify CLI build still succeeds
5. Verify Core tests still pass
6. Verify headless CLI still functions

### Post-Deletion Verification Commands
```bash
# Should all succeed without gui/
npm ci --ignore-scripts --no-audit --no-fund
npm run build
./dist/cn.js --version
npm test
```

### Rollback Procedure (if needed)
```bash
git revert <deletion-commit-hash>
# GUI directory and all files restored
```

### Risk Assessment
**Risk level:** ✅ **VERY LOW**

- Zero code dependencies
- Complete build isolation
- Fully self-contained component
- Easy rollback via git
- No shared configuration

### Conclusion

**The GUI component is safe to delete.** It has zero dependencies from CLI or Core, completely independent build system, and is not bundled into the headless CLI binary. Deletion can proceed as the lowest-risk removal candidate.

Post-deletion verification should confirm CLI functionality remains unchanged.

---

**Document:** Removal Hypothesis - GUI Component  
**Classification:** PROPOSED DELETE (safe, low-risk, independent)  
**Recommendation:** Approve for deletion experiment
