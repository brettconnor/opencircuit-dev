# CLI Import Inventory

**Generated:** 2026-09-12T20:00:00Z
**Analysis:** Static source scan of extensions/cli/src/
**Tool:** grep -r "@continuedev"
**Files scanned:** 348 TypeScript/JavaScript files

## Import Sources

The CLI imports from the following @continuedev packages:

| Package | Import Path | Usage | Count |
|---------|------------|-------|-------|
| config-yaml | `@continuedev/config-yaml` | Type + runtime config parsing | 8 |
| openai-adapters | `@continuedev/openai-adapters` | BaseLlmApi interface + model adapters | 2 |
| terminal-security | `@continuedev/terminal-security` | ToolPolicy + terminal command validation | 2 |
| sdk | `@continuedev/sdk` | DefaultApiInterface + platform abstraction | 2 |

## Key Observations

1. **No direct Core imports:** The CLI does not import `@continuedev/core` directly
2. **SDK dependency:** The CLI uses `@continuedev/sdk` (located in packages/continue-sdk/)
3. **Local packages:** config-yaml, openai-adapters, terminal-security are local workspace packages
4. **Build strategy:** CLI bundles all dependencies via esbuild (see build.mjs)
   - Only `fsevents` and `xhr-sync-worker.js` are marked external
   - All other imports are bundled into the final CLI binary

## Import Dependencies Chain

```
CLI (@continuedev/cli)
├── @continuedev/config-yaml
│   └── (config-types dependency)
├── @continuedev/openai-adapters
│   └── (fetch dependency)
├── @continuedev/terminal-security
│   └── (dependency verification needed)
└── @continuedev/sdk (packages/continue-sdk)
    └── (depends on @continuedev/core per package.json)
```

## Bundle Analysis

The CLI build process bundles everything except:
- Native modules (fsevents)
- Web worker files (xhr-sync-worker.js)
- React DevTools stub

This means the CLI runtime does not require separate installation of:
- Local packages
- Core library
- Any peer dependencies

All are bundled into the single `dist/index.js` or `dist/cn.js` entry point.

---
**Scope:** Deletion-gate gating - CLI-to-local-packages import chain
**Status:** Complete
**Limitations:** Analysis does not include transitive npm dependencies (handled by package-lock.json)
