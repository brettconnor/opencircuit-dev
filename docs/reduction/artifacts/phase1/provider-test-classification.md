# Provider Test Classification for Phase 1 Deletion Gate

## Scope

Classified provider coverage for Anthropic, OpenAI, and Mistral in `core/llm/` based on the RED-001 failure log at `docs/reduction/artifacts/red-001/validation/core-test.log`.

## Located provider test files

### Credential-dependent provider execution
- `core/llm/llm.integration.test.ts` — real-provider integration coverage for Anthropic, OpenAI, and Mistral
- `docs/reduction/artifacts/red-001/validation/core-test.log` — prior failing run showing missing-credential behavior

### Mocked / fixture-based provider coverage already present
- `core/llm/llm.test.ts` — deletion-gate provider smoke coverage using mocks/fixtures
- `core/llm/llms/Anthropic.vitest.ts` — mocked Anthropic request-shape coverage
- `core/llm/llms/OpenAI.test.ts` — OpenAI helper/model classification coverage
- `core/llm/llms/OpenAI-compatible.vitest.ts` — mocked OpenAI-compatible request coverage, including Mistral

### New fixture files
- `core/test/fixtures/providers/anthropic.ts`
- `core/test/fixtures/providers/openai.ts`
- `core/test/fixtures/providers/mistral.ts`

## RED-001 evidence

The RED-001 log showed provider tests were executing live code paths and failing only because credentials were absent:
- Anthropic: missing `ANTHROPIC_API_KEY` caused request rejection in `Anthropic._streamChat`
- OpenAI: missing `OPENAI_API_KEY` caused provider 401 failures
- Mistral: missing `MISTRAL_API_KEY` caused live-provider failures after real provider setup

That behavior classifies those cases as **integration tests**, not deletion-gate tests.

## Per-provider analysis

### Anthropic
- **Current live implementation:** `core/llm/llm.integration.test.ts` runs `streamChat`, `streamComplete`, `complete`, and forced tool-call coverage with `new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY })`
- **Credential-dependent part:** `Anthropic._streamChat` throws immediately when the API key is missing
- **Mockable part:** streamed message chunks and streamed tool-call chunks can be fully reproduced with SSE fixtures
- **Deletion-gate classification:** `core/llm/llm.test.ts` uses `core/test/fixtures/providers/anthropic.ts`

### OpenAI
- **Current live implementation:** `core/llm/llm.integration.test.ts` covers `gpt-4o`, `o3-mini`, and `o1` with streaming/non-streaming behavior plus forced tool calling
- **Credential-dependent part:** provider calls require `OPENAI_API_KEY`; `gpt-4o` normally routes through the OpenAI adapter and network
- **Mockable part:** chat streaming, non-streaming `o1` responses, and tool-call deltas can all be reproduced with fixtures
- **Deletion-gate classification:** `core/llm/llm.test.ts` uses `core/test/fixtures/providers/openai.ts` and disables the OpenAI adapter so the mock transport is authoritative

### Mistral
- **Current live implementation:** `core/llm/llm.integration.test.ts` covers `streamChat`, `streamComplete`, `complete`, FIM, and forced tool calling with `codestral-latest`
- **Credential-dependent part:** live requests require `MISTRAL_API_KEY`; when `apiBase` is omitted, the constructor may auto-detect key type using a real network call
- **Mockable part:** OpenAI-compatible chat deltas, FIM deltas, and tool-call deltas can be supplied from fixtures
- **Deletion-gate classification:** `core/llm/llm.test.ts` uses `core/test/fixtures/providers/mistral.ts` and pins `apiBase` to avoid constructor-time network autodetection

## Classification summary

| Provider | Deletion-gate file | Integration file | Credentials required for integration | Notes |
| --- | --- | --- | --- | --- |
| Anthropic | `core/llm/llm.test.ts` | `core/llm/llm.integration.test.ts` | `ANTHROPIC_API_KEY` | Mocked SSE fixture covers text and tool calls |
| OpenAI | `core/llm/llm.test.ts` | `core/llm/llm.integration.test.ts` | `OPENAI_API_KEY` | Mocked fixtures cover `gpt-4o`, `o3-mini`, and non-streaming `o1` |
| Mistral | `core/llm/llm.test.ts` | `core/llm/llm.integration.test.ts` | `MISTRAL_API_KEY` | Mocked fixtures cover chat, FIM, and tool calls |

## Integration test documentation

`core/llm/llm.integration.test.ts` now documents:
- required environment variables
- outbound network requirement
- exact run command: `npm run test:providers`
- explicit skip logging when credentials are missing
- reviewer approval that the suite is non-gating for Phase 1

## Verification

### Deletion-gate run without provider credentials
Command:
```bash
cd open-circuit/core && env -u ANTHROPIC_API_KEY -u OPENAI_API_KEY -u MISTRAL_API_KEY npm run test:providers:deletion-gate
```

Result:
- `PASS llm/llm.test.ts`
- `19 passed, 19 total`

### Integration classification run without provider credentials
Command:
```bash
cd open-circuit/core && env -u ANTHROPIC_API_KEY -u OPENAI_API_KEY -u MISTRAL_API_KEY npm run test:providers
```

Result:
- explicit `[SKIP]` log lines emitted for Anthropic, OpenAI (`gpt-4o`, `o3-mini`, `o1`), and Mistral
- `Test Suites: 1 skipped`
- `Tests: 19 skipped, 19 total`

### Type-check validation
Command:
```bash
cd open-circuit/core && npm run tsc:check -- --pretty false
```

Result:
- completed successfully

## Non-leakage note

No real credential values were added to test code, fixtures, scripts, or documentation. Only environment variable names are referenced.
