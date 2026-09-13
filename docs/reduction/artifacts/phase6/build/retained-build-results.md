# Retained Build Results

The Ubuntu1 Phase 6 profile passed the inherited fixed Phase 5 build and
typecheck steps at `308c540b735b4860504dadf281311c329420612e`.

| Surface | Build | Distinct typecheck |
| --- | --- | --- |
| `config-types` | Pass | Included in build |
| `fetch` | Pass | Included in build |
| `llm-info` | Pass | Included in build |
| `terminal-security` | Pass | Included in build |
| `config-yaml` | Pass | Included in build |
| `openai-adapters` | Pass | Included in build |
| Core | Pass | `npm run tsc:check`: Pass |
| CLI | `build:validate`: Pass; `build`: Pass | `npm run typecheck`: Pass |

This is curated fixed-profile evidence, not a raw remote build log.
