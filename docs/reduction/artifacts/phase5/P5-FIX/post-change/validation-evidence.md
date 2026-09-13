# P5-FIX post-change validation evidence

## Candidate

- Core remediation: `5e2685e07`
- Branch under test: `reduce/phase5-cli-core-validation`
- Local runtime: Node.js `v26.7.0`, npm `12.0.2`
- Required authoritative runtime: Node.js `v24.19.0`, npm `11.17.0`
- Evidence class: local fast-feedback only; not authoritative Ubuntu1 evidence

## TDD and SDD checks

- Core clean generated-output build: pass after removing only ignored
  `core/dist`.
- Core `npm run tsc:check -- --pretty false`: pass with generated output
  present; the original source-vs-dist `TS2322` was not reproduced.
- Supported emitted-package consumer fixture: pass. The fixture imports
  `ToolExtras` from the emitted Core package and calls only
  `codeBaseIndexer.refreshCodebaseIndexFiles`.
- Emitted boundary assertion: pass. `core/dist/index.d.ts` contains no
  `CodebaseIndexer` import.
- Strict consumer diagnostic with `skipLibCheck: false`: blocked by
  pre-existing declaration hygiene defects outside this remediation, including
  extensionless declarations and stale/missing exported names. This result is
  recorded, not waived as a product-source pass.

## Retained-closure results

| Package or check | Result |
|---|---|
| `packages/config-types` install/build/test | Pass |
| `packages/fetch` install/build/test | Pass; first sandbox attempt was retried in the approved network-capable context because its HTTPS fixture needs `0.0.0.0:3002` |
| `packages/llm-info` install/build/test | Pass |
| `packages/terminal-security` install/build/test | Pass, 224 tests |
| `packages/config-yaml` install/build/focused test | Pass, 8 passed and 1 pre-existing skipped |
| `packages/openai-adapters` install/build/focused test | Pass, 3 tests |
| Core build/typecheck | Pass |
| CLI install/typecheck/build validation/build | Pass |
| CLI smoke | Pass, 10 tests |
| CLI configuration characterization | Pass, 2 tests |
| CLI model characterization | Pass, 10 tests |
| Adapter characterization | Pass, 3 tests |
| Static boundary check | Pass |
| Emitted boundary check | Pass |
| Runtime boundary check | Blocked locally by Node.js `v26.7.0`; child workflow, mock transport, and module-resolution assertions passed |
| Root workspace `npm ls --depth=0` | Pass |
| Retained lockfile hashes | Unchanged from documented baselines |

## Fixed runner harness correction

The Phase 5 stale-reference expression originally used `(...)*core`, which
matched approved bare package imports such as `from "core"`. The expression
now requires one or more relative path segments: `(...)+core`.

- Runner commit: `ba52121cca51b7ce951320fdbee4902ebaec7ea1`
- Runner contract test: pass
- New regression test: pass
- Shell syntax check: pass
- Runner script SHA-256:
  `cf19fe5655c804df019d142df7238b62393808d5e1b26735a1243cc1362467c3`
- Runner contract SHA-256:
  `fea4e6797d308325b182890605d4035aefa0f980d11acdda16f3f7e12592f272`
- CodeGuard review: no hardcoded credential material, unsafe `eval`/`sudo`
  seam, or unvalidated shell-input path was introduced; existing structured
  SSH arguments, strict allowlists, and fail-closed behavior remain intact.

## Authority blocker

The fixed Ubuntu1 command has not been rerun because the Phase 5 branch is not
published. The Git integration agent must publish the exact tested branch tip,
then run the pinned runner revision with `--phase5-validate`. No Phase 4
retained-closure restoration is claimed from this local evidence.
