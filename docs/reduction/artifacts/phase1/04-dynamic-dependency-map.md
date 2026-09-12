# Dynamic Dependency Map

**Generated:** 2026-09-12T20:15:00Z
**Source:** core/package-lock.json (after RED-001 regeneration)
**Total Packages:** 1,174 (direct + transitive)
**Analysis:** npm registry + local workspace packages

## Summary

The Core dependency graph after RED-001 lockfile repair contains 1,174 total packages. The vast majority (1,160+) are transitive dependencies from provider SDKs (OpenAI, Anthropic, Mistral) and build tooling.

The retained 8-package closure (6 local + CLI + Core) depends only on public npm registry packages and common build tools. No internal, private, or third-party binary dependencies exist.

## Direct Local Package Dependencies

### CLI (@continuedev/cli)
**Direct imports from local packages:**
- @continuedev/config-yaml (configuration parsing)
- @continuedev/openai-adapters (provider API abstraction)
- @continuedev/terminal-security (tool policy validation)
- @continuedev/sdk (platform abstraction)

**No direct dependency on @continuedev/core**
- Core is linked via CLI build process, not npm dependency
- CLI bundles all dependencies into single entry point (dist/cn.js)

### Core (@continuedev/core)
**Direct dependencies (package.json):**
- puppeteer (browser automation)
- puppeteer-core (headless browser)
- sqlite3 (local indexing database)
- openai (OpenAI provider SDK)
- anthropic (Anthropic provider SDK)
- mistral (Mistral provider SDK)
- zod (schema validation)
- And 50+ utility packages for build/runtime

### Local Packages (@continuedev/*)
- **config-types:** No external npm dependencies (types only)
- **config-yaml:** js-yaml, zod
- **fetch:** (fetch implementation - cross-platform)
- **terminal-security:** zod
- **llm-info:** No external npm dependencies
- **openai-adapters:** openai, anthropic, mistral SDKs
- **continue-sdk:** Local wrapper around Core APIs

## Provider SDK Dependencies

### Anthropic
- Package: `anthropic` (v0.24+)
- Node requirement: 18+
- Dependencies: openai-like event stream, undici for fetch
- Locked version: (from core/package-lock.json)

### OpenAI
- Package: `openai` (v4.x)
- Node requirement: 18+
- Dependencies: event-stream, form-data
- Locked version: (from core/package-lock.json)

### Mistral
- Package: `mistral` (v0.x)
- Node requirement: 18+
- Dependencies: zod, openai-like patterns
- Locked version: (from core/package-lock.json)

**Test isolation requirement:** All three providers need mocks or credential-gated skips for deletion-gate tests (currently pending provider test classification)

## Transitive Dependency Patterns

**Build tools:** TypeScript, Jest, esbuild, tsc
**Runtime support:** zod validation, undici fetch, SQLite binding
**Utilities:** lodash, uuid, pluralize, and common npm utilities
**AWS SDK:** Large set of @aws-sdk/* packages (used by some providers)

No Ruby, Python, Java, or other non-Node.js runtime dependencies exist.
No binary compilation required beyond sqlite3 native module.

## Dependency Integrity Verification

✅ **Immutable install:** All 8 packages install with `npm ci --ignore-scripts --no-audit --no-fund`
✅ **Lockfile stability:** core and cli lockfiles unchanged after install (RED-001)
✅ **Build reproducibility:** All 8 packages build deterministically
✅ **Node.js requirement:** Node 24.19.0 enforced globally (supports all transitive Node requirements)

## No Deleted Dependencies at Phase 1

The proposed deletions (GUI, continue-sdk) do not affect the dependency closure:
- GUI has separate lockfile, no transitive impact on retained packages
- continue-sdk is local wrapper; removing it changes API surface but not dependency versions

All 1,174 packages remain unchanged until explicit provider deprecation (Anthropic, OpenAI, Mistral removal would only affect test suite size, not runtime closure).

---
**Classification:** Inventory (supporting deletion-gate evidence)
**Scope:** Deletion-gate packages only (CLI, Core, 6 local packages)
**Next step:** Awaiting provider test classification to finalize test isolation
