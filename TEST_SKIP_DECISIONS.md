# Skipped-test decisions

This inventory records why skipped tests are not part of the retained CLI/Core
validation baseline. It is intentionally feature-specific; skipped tests must
not be re-enabled with live credentials or unavailable external infrastructure.

## Deferred or external-surface tests

| Tests                                                                                                                                                                                                    | Decision                                                                            | Re-enable condition                                                                                   |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `core/indexing/CodeSnippetsIndex.test.ts`, `core/indexing/FullTextSearchCodebaseIndex.test.ts`, `core/indexing/LanceDbIndex.test.skip.ts`, `core/indexing/chunk/{basic,code,ChunkCodebaseIndex}.test.ts` | Deferred indexing implementations; not required by the retained CLI/Core smoke path | Re-enable when the owning index implementation has deterministic fixtures and a maintained test owner |
| `core/indexing/docs/DocsService.skip.ts`, `core/indexing/docs/crawlers/DocsCrawler.test.ts`                                                                                                              | External crawling/browser integration; excluded from deterministic baseline         | Re-enable with local HTTP fixtures and a pinned browser fixture                                       |
| `core/context/mcp/MCPConnection.vitest.ts` filesystem connection case                                                                                                                                    | External MCP server integration                                                     | Re-enable with a loopback MCP fixture                                                                 |
| `extensions/cli/src/smoke-api/*.test.ts`, `packages/openai-adapters/src/test/*live*`, provider/API-key comparison tests                                                                                  | Credentialed provider tests; intentionally opt-in                                   | Run only in the provider integration workflow with injected CI secrets                                |
| `extensions/vscode/e2e/tests/*.test.skip.ts`, GUI and keyboard cases                                                                                                                                     | Deferred VS Code surface, outside retained CLI/Core scope                           | Re-enable in the VS Code E2E workflow when the feature and CI environment are supported               |

## Candidate deterministic coverage

The following skipped tests are retained behavior candidates and should be
handled by the owning package before the feature is considered fully covered:

- `core/llm/countTokens.test.ts`
- `core/util/ranges.test.ts`
- `core/util/index.test.ts`
- `core/util/generateRepoMap.test.ts`
- `core/diff/util.vitest.ts`
- `core/config/ConfigHandler.vitest.ts`
- `core/edit/lazy/deterministic.test.ts`
- `core/indexing/CodebaseIndexer.test.ts`
- `extensions/cli/src/e2e/headless-simple.test.ts`
- `extensions/cli/src/util/fileWatcher.test.ts`
- `extensions/cli/src/util/prompt.test.ts`
- `extensions/cli/src/commands/serve.test.ts`
- `extensions/cli/src/stream/streamChatResponse.test.ts`
- `extensions/cli/src/tools/preprocess.test.ts`
- `packages/config-yaml/src/__tests__/index.test.ts`

These are not silently treated as passing. They remain a tracked follow-up
inventory with an explicit owner boundary and are excluded from the required
retained-closure baseline until re-enabled or removed with evidence.

### Resolved

- `core/util/withExponentialBackoff.test.ts` — re-enabled
  (`describe.skip` → `describe`). The retry/backoff behavior is fully
  deterministic (no network, no external infra, fake timers only) and
  remains important supported behavior. Root cause of the original skip: two
  assertions expected a stale literal error string
  (`"Failed to make API call after max tries"`) that no longer matches the
  implementation's actual message
  (`` `Failed to make API call after ${maxTries} retries` ``). Fixed the two
  assertions to match current, correct behavior; no production code changed.
  Validation: `npx cross-env IGNORE_API_KEY_TESTS=true NODE_OPTIONS=--experimental-vm-modules jest util/withExponentialBackoff.test.ts`
  — 6/6 passed. Full-suite regression check:
  `npm run test` in `core/` — 51/59 suites passed (865/973 tests passed, 108
  skipped in the remaining un-migrated families), zero failures, zero new
  skips introduced. `npm run tsc:check` passed with no errors.
