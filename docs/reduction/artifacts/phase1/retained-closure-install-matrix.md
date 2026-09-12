# Retained Closure Install Matrix

This matrix is the executable evidence record for the CLI/Core dependency
closure. RED-001 reran the complete matrix under Node.js 24.19.0 and npm
11.17.0. Detailed logs are stored in
`docs/reduction/artifacts/red-001/`.

| Package             | Working directory            | Install command                                | Build order | Build           | Typecheck                             | Test/smoke                                            | Lockfile SHA-256                                                   | RED-001 result                                                  |
| ------------------- | ---------------------------- | ---------------------------------------------- | ----------: | --------------- | ------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------ | --------------------------------------------------------------- |
| `config-types`      | `packages/config-types`      | `npm ci --ignore-scripts --no-audit --no-fund` |           1 | `npm run build` | Build performs TypeScript compilation | `npm test`                                            | `4a1180ce21a7ac1a5a5603e94ff69bad3eef75a0babeb45de75f7a5fe83c2933` | Install/build pass; no tests declared                           |
| `fetch`             | `packages/fetch`             | `npm ci --ignore-scripts --no-audit --no-fund` |           2 | `npm run build` | Build performs TypeScript compilation | `npm test`                                            | `9f01ca63267efa8352a86d4591e001e73b4e505dbae7dc208fb557a418faa156` | Install/build pass; 97 tests pass                               |
| `llm-info`          | `packages/llm-info`          | `npm ci --ignore-scripts --no-audit --no-fund` |           3 | `npm run build` | Build performs TypeScript compilation | `npm test`                                            | `1af229ec319504eec08a2779e5e3e86637e0afd5dc410fc9d3528181f876488d` | Install/build pass; no tests declared                           |
| `terminal-security` | `packages/terminal-security` | `npm ci --ignore-scripts --no-audit --no-fund` |           4 | `npm run build` | Build performs TypeScript compilation | `npm test`                                            | `7fe7ed97dcc6fcc1ef707fb9d9659c1ef029117061935fa330bae4bbb8aeac7b` | Install/build pass; 224 tests pass                              |
| `config-yaml`       | `packages/config-yaml`       | `npm ci --ignore-scripts --no-audit --no-fund` |           5 | `npm run build` | Build performs TypeScript compilation | `npm test -- src/__tests__/index.test.ts --runInBand` | `9e192574e1d60ea805fdd9915eb941a02e617650bc4b0533905910725df75f4c` | Install/build pass; 8 tests pass, 1 skipped                     |
| `openai-adapters`   | `packages/openai-adapters`   | `npm ci --ignore-scripts --no-audit --no-fund` |           6 | `npm run build` | Build performs TypeScript compilation | `npx vitest run src/apis/Anthropic.test.ts`           | `9219572b4c33d040afe31d1ff6ff9cf8a45ff91a0d44bd633447fbf6228448de` | Install/build pass; 3 tests pass                                |
| `core`              | `core`                       | `npm ci --ignore-scripts --no-audit --no-fund` |           7 | `npm run build` | `npm run tsc:check`                   | Characterization plus broader `npm test`              | `f58106181d204060082a4d41f19665856c2debc46fac4677dec7f9251e611398` | Immutable install/build/typecheck pass; broader suite not green |
| `extensions/cli`    | `extensions/cli`             | `npm ci --ignore-scripts --no-audit --no-fund` |           8 | `npm run build` | `npm run typecheck`                   | Smoke, ModelService, and headless characterization    | `dc623a31792fa0541a7a9e809a5614f94a14c005b8dd144809a986ec8b115257` | Install/build/typecheck pass; 34 characterization tests pass    |

Every listed SHA-256 value was unchanged by its RED-001 immutable install.
The Core and CLI values differ from Phase 0 because RED-001 intentionally
regenerated the Core lockfile and synchronized the CLI lockfile's linked Core
snapshot.

The broader Core suite reported 45 suites and 780 tests passing, with 10 suites
and 19 tests failing. The failures are classified in
`docs/reduction/red-001-core-lockfile-integrity.md` and require explicit
approval or remediation before deletion approval.

## Evidence Rules

- Record Node.js, npm, operating system, architecture, cache, registry, lifecycle-script, and network conditions.
- Keep install-integrity mode separate from build/runtime mode.
- Hash each relevant lockfile before and after installation.
- Do not treat changed lockfiles, credential requirements, missing local artifacts, registry failures, or undocumented ordering as passes.
- Record the source commit/tag, command, working directory, date, tool versions, output artifact, and limitations for each result.
