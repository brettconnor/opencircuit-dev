# Phase 1: Authoritative Keep/Remove/Defer/Unknown Decision Table

**Date:** 2026-09-12
**Authority:** RED Phase 1 Checkpoint
**Approval Status:** Pending deletion-gate completion

## Decisions

| Component | Category | Decision | Rationale | Evidence | Approved | Notes |
|-----------|----------|----------|-----------|----------|----------|-------|
| CLI (extensions/cli) | Product | **KEEP** | Entry point; required for product function | Phase 0 retained-closure matrix; build/test passing | ✅ RED-001 | No deletion |
| Core (@continuedev/core) | Library | **KEEP** | Primary reusable library; linked by CLI | Phase 0 retained-closure matrix; Node 24.19.0 locked | ✅ RED-001 | No deletion |
| config-types | Package | **KEEP** | Core dependency; zero external refs | Phase 1 retained-closure matrix pending | ⏳ Phase 1 | Deletion-gate blocking |
| fetch | Package | **KEEP** | Core dependency; 97 tests passing | Phase 1 retained-closure matrix pending | ⏳ Phase 1 | Deletion-gate blocking |
| llm-info | Package | **KEEP** | Core dependency; no external refs | Phase 1 retained-closure matrix pending | ⏳ Phase 1 | Deletion-gate blocking |
| terminal-security | Package | **KEEP** | Core dependency; 224 tests passing | Phase 1 retained-closure matrix pending | ⏳ Phase 1 | Deletion-gate blocking |
| config-yaml | Package | **KEEP** | Core dependency; 8 tests passing | Phase 1 retained-closure matrix pending | ⏳ Phase 1 | Deletion-gate blocking |
| openai-adapters | Package | **KEEP** | Core dependency; provider tests need isolation | Phase 1 provider classification pending | ⏳ Phase 1 | Provider tests gate |
| VS Code (extensions/vscode) | Product | **DEFER** | UI-only; separate product surface | Phase 0 boundary check | ✅ RED-001 | Future review |
| GUI (gui/) | UI | **PROPOSED REMOVE** | Feature duplication with CLI; requires deletion experiment | Phase 0 boundary scan | ⏳ Phase 1 | Experiment required |
| continue-sdk (packages/continue-sdk) | Package | **PROPOSED REMOVE** | Redundant local wrapper; verify no external deps | Phase 0 boundary scan | ⏳ Phase 1 | Import audit needed |
| Binary packaging (binary/) | Distribution | **DEFER** | Distribution mechanism; product-neutral | Phase 0 architecture review | ✅ RED-001 | Future review |
| Docs (docs/) | Content | **DEFER** | Repository docs; publication review pending | Phase 0 boundary scan | ⏳ Phase 1 | Publication gate |
| Docs-site (docs-site/) | Content | **DEFER** | Published docs; publication review pending | Phase 0 boundary scan | ⏳ Phase 1 | Publication gate |
| Vendor assets (core/vendor) | Metadata | **DEFER** | Runtime asset tracing needed | RED-001 lockfile repair | ⏳ Phase 1 | Asset audit needed |

## Summary

- **KEEP:** 8 (CLI, Core, 6 packages)
- **PROPOSED REMOVE:** 2 (GUI, continue-sdk) 
- **DEFER:** 5 (VS Code, binary, docs, docs-site, vendor)
- **UNKNOWN:** 0

---
**Next step:** Complete Phase 1 evidence for KEEP/PROPOSED REMOVE categories
**Blocking gates:** Provider test classification, CLI-to-Core import audit
