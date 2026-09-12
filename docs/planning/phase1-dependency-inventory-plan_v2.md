# Phase 1 Dependency Inventory and RED Readiness Plan v2

## Purpose

Complete the CLI/Core dependency inventory and establish whether product-surface deletion is safe to begin.

This phase includes:

- remediation of deterministic Core test failures;
- deterministic handling of credential-dependent provider tests;
- completion of Phase 1 dependency evidence; and
- a final deletion approval review.

This phase authorizes no deletion, relocation, workspace removal, or product-surface change.

## Current Decision

`RED-001-core-lockfile-integrity` is complete. The next deletion batch is not yet approved.

The following conditions remain:

1. Nine Core suites fail because `puppeteer-chromium-resolver` is incompatible with the installed ESM-only `puppeteer-core`.
2. Credential-dependent Anthropic, OpenAI, and Mistral tests fail without external credentials.
3. Required Phase 1 inventory artifacts are incomplete.
4. The retained-closure matrix does not yet satisfy its own schema.
5. Existing Remove, Defer, and Unknown decisions need one authoritative decision table.

## Required Remediation

### Puppeteer compatibility failures

Treat the nine Puppeteer failures as blocking product/runtime failures.

Inspect the failing path in `core/indexing/docs/crawlers/ChromiumCrawler.ts` and the resolved versions in `core/package.json` and `core/package-lock.json`.

Use the smallest justified change:

- align `puppeteer-chromium-resolver` with the installed Puppeteer packages;
- or replace the incompatible CommonJS loading path with an ESM-compatible path; or
- introduce a narrowly scoped compatibility adapter.

Do not perform unrelated dependency upgrades or modify provider behavior.

After the change:

1. Run the nine previously failing suites directly.
2. Run the full deterministic Core suite.
3. Confirm there are no CommonJS/ESM resolver failures.
4. Record changed files, lockfile hashes, logs, and the final dependency versions.

Acceptance requirement: no unresolved deterministic Puppeteer failures.

### Credential-dependent provider tests

Separate provider tests into two explicit categories.

**Deletion-gate provider tests**

These must use mocks or a local loopback fixture for Anthropic, OpenAI, and Mistral request behavior. They must be runnable without external credentials or network access.

**Provider integration tests**

Real-provider tests may remain separately named and may require credentials. Their result must be explicitly recorded as `PASS`, `SKIP`, or `FAIL`.

A skipped integration test is not a pass. The record must include:

- required environment variables;
- network requirements;
- the exact command;
- the skip reason; and
- reviewer approval if the tests are classified as non-gating.

Acceptance requirement: all deterministic provider tests pass, and any non-gating integration classification is explicitly approved.

## Phase 1 Evidence Completion

Create or complete these artifacts under `docs/reduction/artifacts/phase1/`:

- package and workspace inventory;
- CLI/Core entry-point inventory;
- CLI-to-Core import inventory;
- static and dynamic dependency map;
- emitted bundle-input report;
- authoritative Keep/Remove/Defer/Unknown decision table;
- Copilot reconciliation log;
- removal hypotheses;
- unresolved exception list; and
- corrected retained-closure install matrix.

Every artifact must record:

- source checkpoint;
- generation command;
- working directory;
- generation date;
- Node.js and npm versions;
- operating system and architecture;
- network and registry policy;
- result; and
- limitations.

## Retained-Closure Matrix

Correct `docs/reduction/artifacts/phase1/retained-closure-install-matrix.md` so every row contains:

- package;
- working directory;
- lockfile path;
- install command;
- lifecycle policy;
- build order;
- build command;
- typecheck command;
- test or smoke command;
- lockfile hash before install;
- lockfile hash after install;
- result;
- artifact path; and
- limitations.

Run the matrix for:

- `config-types`;
- `fetch`;
- `llm-info`;
- `terminal-security`;
- `config-yaml`;
- `openai-adapters`;
- `core`; and
- `extensions/cli`.

Install-integrity mode and build/runtime mode must remain separate.

## Decision Reconciliation

Use one authoritative decision table.

- CLI and Core: Keep.
- Six local packages: Keep pending retained-closure evidence.
- VS Code: Defer.
- Binary packaging: Defer.
- Docs and docs-site: Defer pending publication review.
- Core vendor and model assets: Defer pending runtime-asset tracing.
- GUI: Proposed Remove only after its deletion experiment passes all retained checks.
- Local `continue-sdk`: Proposed Remove only after the installed SDK path and all retained workflows are verified.

Every `Remove` entry must include static, dynamic, build, bundle, and runtime evidence.

Every `Defer` entry must name the preserved product surface.

Every `Unknown` entry must have a follow-up action and owner.

## Verification

Run, from the `red-001-core-clean-install` checkpoint:

1. Clean Core installation using `npm ci --ignore-scripts --no-audit --no-fund`.
2. The nine Puppeteer suites directly.
3. The full deterministic Core suite.
4. The deterministic provider suite without credentials.
5. The separately named provider integration suite with explicit credential reporting.
6. The complete retained-closure install/build/typecheck/test matrix.
7. Static source boundary checks.
8. Emitted-bundle boundary checks.
9. Headless runtime module-resolution checks.
10. Artifact completeness and provenance checks.

## Deletion Approval Gate

Product-surface deletion remains blocked until all of the following are true:

1. RED-001 has a verified immutable checkpoint.
2. Puppeteer/module-resolution failures are fixed.
3. The deterministic Core suite passes.
4. Provider integration tests are either passing or explicitly approved as non-gating.
5. The retained-closure matrix passes, or each failure has written approval.
6. Required Phase 1 artifacts are complete and internally consistent.
7. Every deletion candidate has static, dynamic, build, bundle, and runtime evidence.
8. Each deletion candidate has a focused disconfirming check.
9. A rollback plan and post-change comparison command set are recorded.
10. No unrelated product or dependency changes are included.

Until then, the status is:

**NO-GO FOR PRODUCT DELETION**

## Scope Boundaries

Included:

- Puppeteer compatibility remediation;
- provider-test determinism and classification;
- Phase 1 inventory completion;
- evidence and provenance cleanup; and
- deletion-gate review.

Excluded:

- GUI, VS Code, or binary deletion;
- Core API refactoring;
- replacement of CLI deep imports;
- history rewriting;
- unrelated dependency upgrades; and
- provider behavior changes unrelated to test isolation.