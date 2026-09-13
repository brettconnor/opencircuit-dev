# Phase 6 Publication Readiness

## Result

**Not publication ready**

The authoritative Ubuntu1 fixed profile passed at
`308c540b735b4860504dadf281311c329420612e`, including immutable retained
closure, Core/CLI builds and typechecks, CLI smoke, controlled headless
workflow, characterization, boundaries, stale active references, docs/legal
presence checks, and measurements.

Publication is nevertheless blocked by:

1. `P6-PUB-001`: the CLI manifest's declared type entry point is not generated
   by its standard build.
2. `P6-PUB-002`: aggregate third-party attribution requirements have not been
   assessed for publication.
3. `P6-DOC-001`: the retained entry-point inventory conflicts with current
   Core metadata.

These items require package/product, legal, or out-of-allowlist historical
documentation changes. They were recorded, not corrected.

## Validation matrix

| Surface | Required validation | Result |
| --- | --- | --- |
| Root tooling | Immutable root install | Pass |
| `config-types` | Immutable install and build | Pass |
| `fetch` | Immutable install and build/test | Pass |
| `llm-info` | Immutable install and build | Pass |
| `terminal-security` | Immutable install and build | Pass |
| `config-yaml` | Immutable install and build/test | Pass |
| `openai-adapters` | Immutable install and build/test | Pass |
| Core | Immutable install, build, typecheck | Pass |
| CLI | Immutable install, typecheck, build | Pass |
| CLI smoke | Fixed smoke command | Pass |
| Headless workflow | Fixed loopback mock workflow | Pass |
| Characterization | Config, model, adapter checks | Pass |
| Static/bundle boundaries | Fixed checks | Pass |
| Runtime boundaries | Fixed check | Pass |
| Lockfile integrity | Before/after SHA-256 | Pass |
| Repository hygiene | Fixed stale/workspace/docs/legal scan | Pass |

See `docs/reduction/artifacts/phase6/` for the sanitized evidence package.
