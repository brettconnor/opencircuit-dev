# Phase 6 Publication Corrections Ledger

## Baseline
Starting from the Phase 6 evidence branch `reduce/phase6-final-review` at tip `9c5dfc774136f8797cd85af602e8f8c5b9660694`, three unresolved findings were documented in `docs/reduction/artifacts/phase6/reconciliation/unresolved-items.md`:
1. `P6-PUB-001` (Blocked): `extensions/cli/package.json` declares `types: dist/index.d.ts`, but standard clean build did not emit that path.
2. `P6-PUB-002` (Blocked): Aggregate third-party attribution requirements were not assessed for publication.
3. `P6-DOC-001` (Unknown): `docs/reduction/cli-core-entry-points.md` was stale/internally inconsistent regarding Core's declared `types` entry.

## Hypotheses
1. **Hypothesis 1 (`P6-PUB-001`)**: Configuring `"emitDeclarationOnly": true` in `extensions/cli/tsconfig.build.json` and adding `npm run build:tsc` to `extensions/cli/package.json` `"build"` script will generate `dist/index.d.ts` cleanly during standard build without polluting bundled JavaScript or altering runtime behaviors.
2. **Hypothesis 2 (`P6-PUB-002`)**: Performing an exhaustive audit of all 376 bundled dependencies in `dist/meta.json` will demonstrate that all dependencies use permissive open-source licenses without copyleft terms, allowing publication compliance via an established root `NOTICE` file.
3. **Hypothesis 3 (`P6-DOC-001`)**: Updating `docs/reduction/cli-core-entry-points.md` to reflect that `core/package.json` declares `types: dist/index.d.ts` (populated on build) and that CLI builds emit `dist/index.d.ts` will reconcile the historical inventory with current package metadata.

## Changed Files Allowlist by Commit

### Commit 1: `f57330ae3` (`fix(cli): produce declaration entry point on build (P6-PUB-001)`)
- `extensions/cli/package.json`
- `extensions/cli/tsconfig.build.json`
- `docs/reduction/phase6-corrections/cli-declaration-validation.md`

### Commit 2: `5fa8d13ce` (`docs(legal): perform aggregate third-party attribution review (P6-PUB-002)`)
- `NOTICE`
- `docs/reduction/license-attribution-inventory.md`
- `docs/reduction/artifacts/phase6/legal/license-attribution-review.md`
- `docs/reduction/phase6-corrections/third-party-attribution-review.md`

### Commit 3: `d2a6ecb51` (`docs(reduction): reconcile CLI and Core entry-point inventory (P6-DOC-001)`)
- `docs/reduction/cli-core-entry-points.md`
- `docs/reduction/phase6-corrections/entry-points-reconciliation.md`

### Commit 4: `f00bede7c` (`docs(phase6): record publication corrections ledger and readiness`)
- `docs/reduction/artifacts/phase6/reconciliation/unresolved-items.md`
- `docs/reduction/phase6-publication-readiness.md`
- `docs/reduction/phase6-final-review.md`
- `docs/reduction/phase6-execution-ledger.md`
- `docs/reduction/phase6-corrections/correction-ledger.md`

## Validation Evidence

| Test / Check | Scope | Result | Evidence |
| --- | --- | --- | --- |
| CLI clean build | `extensions/cli` | Pass | Emitted `dist/index.js`, `dist/index.d.ts`, `dist/cn.js` |
| CLI typecheck | `extensions/cli` | Pass | `npm run typecheck` exited 0 |
| CLI smoke tests | `extensions/cli` | Pass | 10/10 tests passed in `smoke-test.mjs` |
| Packed consumer fixture | External fixture | Pass | `npm pack` + external TypeScript typecheck exited 0 |
| Retained builds | Entire closure | Pass | `config-types`, `fetch`, `llm-info`, `terminal-security`, `config-yaml`, `openai-adapters`, `core`, `cli` builds passed |
| Unit & characterization tests | Core/CLI/Adapters | Pass | `Anthropic.test.ts`, `config.test.ts`, `ModelService` direct/workflow tests, headless mock LLM tests (3/3) passed |
| Boundary checks | Characterization | Pass | Static, emitted, and runtime boundary checks passed |
| Lockfile integrity | All package-lock.json | Pass | SHA-256 hashes unchanged across all retained packages |

## Rollback Procedure
If rollback is required:
1. Discard or reset the correction branch: `git checkout reduce/phase6-final-review && git branch -D reduce/phase6-publication-corrections`.
2. No database or external release state has been modified.
3. Lockfiles and product runtime dependencies remain identical to the Phase 6 baseline.

## Residual Issues & Documented Exceptions
- **Remote Runner Re-Execution**: The authoritative Ubuntu1 runner (`open-circuit-runner.sh --phase6-final-review`) pulls from `origin` on GitHub. Because the W1 phase-executor model strictly prohibits pushing branches or creating PRs, remote execution against the local correction branch is deferred to post-push Git integration handoff.

## Git Integration Handoff
- Evidence branch baseline: `reduce/phase6-final-review` at `9c5dfc774136f8797cd85af602e8f8c5b9660694`.
- Correction branch: `reduce/phase6-publication-corrections`.
- Status: **Publication ready with documented exceptions**.
