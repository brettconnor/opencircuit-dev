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

- `core/llm/countTokens.test.ts` — re-enabled all 7 remaining
  `describe.skip` blocks (`countTokens`, `pruneLinesFromTop`,
  `pruneLinesFromBottom`, `pruneRawPromptFromTop`, `pruneStringFromTop`,
  `pruneStringFromBottom`, `compileChatMessages`; `countTokensAsync` and
  `extractToolSequence` were already enabled). All behavior is fully
  deterministic (in-process tokenizer calls, no network, no external
  infra). Three distinct stale-test root causes were found and fixed, with
  no production code changes to `core/llm/countTokens.ts`:

  - `pruneRawPromptFromTop`/`pruneStringFromTop`/`pruneStringFromBottom`:
    the fixture string `"Hello world!"` tokenizes to 3 tokens under
    `gpt-4`/js-tiktoken, but the tests used `maxTokens` values (5) that
    never actually forced truncation, so the assertions
    (`result.length < original.length`) were unreachable. Adjusted the
    `maxTokens`/`contextLength`/`tokensForCompletion` fixture values so
    each call genuinely exceeds the token budget and truncation is
    exercised.
  - `compileChatMessages` "empty message list": the current
    implementation's `extractToolSequence` throws
    `"no user/tool message found"` when given zero messages — this is
    intentional (there is nothing to anchor the compiled result on), not
    a bug. Re-characterized the test to assert the throw instead of a
    graceful empty-array return.
  - `compileChatMessages` "maxTokens close to contextLength" and "filter
    empty/system messages": the function's signature changed from
    positional arguments returning a bare array to an options object
    returning `{ compiledChatMessages, didPrune, contextPercentage }`
    (see `core/llm/index.ts` for the real call site). Updated call sites
    to the object API and `.compiledChatMessages` access. Additionally,
    the system message is intentionally always preserved in the compiled
    output (extracted only for separate token accounting, then re-added),
    so the "filter" test's expected count was corrected from 1 to 2 and
    renamed to state that intent explicitly.
    Validation: `npx cross-env IGNORE_API_KEY_TESTS=true NODE_OPTIONS=--experimental-vm-modules jest llm/countTokens.test.ts`
    — 34/34 passed. Full-suite regression check: `npm run test` in `core/` —
    51/59 suites passed (886/973 tests passed, 87 skipped in the remaining
    un-migrated families), zero failures. `npm run tsc:check` passed with no
    errors.

- `core/util/ranges.test.ts` — re-enabled `describe.skip("getRangeInString")`
  (9 tests) and `test.skip("returns correct intersection for single line
overlap")` in the `intersection` block. All behavior is a pure, in-process
  string/range computation (no network, no external infra). Investigation
  found a mix of stale test fixtures **and two genuine, narrowly-scoped
  production bugs** in `core/util/ranges.ts`:
  - Stale fixtures (test-only fix): three `getRangeInString` tests used an
    `end.character` value that undercounted the target line's real length
    (each fixture line is 6 characters, e.g. `"Line 4"`, but fixtures used
    `3` or `5`), so the substring assertions were checking a truncated
    prefix instead of the full line the test's own `expected` string
    described. Corrected the `end.character` values to `6`.
  - Stale expectation (test-only fix): two "same start/end character"
    tests asserted a single-character result (`"L"`, `"n"`) for a
    zero-width range, which is inconsistent with `substring`'s semantics
    (a zero-width range must yield `""`, as already correctly exercised by
    the passing "same line, different characters" test). Corrected both
    expectations to `""` and renamed the tests to describe zero-width
    range behavior.
  - **Production bug 1** (`getRangeInString`, `core/util/ranges.ts`): the
    function had no guard for a reversed/invalid range
    (`start` after `end`). For a cross-line reversed range it returned a
    nonsense partial-line result instead of `""`; for a same-line reversed
    range it silently returned a wrong substring because JS's
    `String.prototype.substring` auto-swaps out-of-order arguments. Added
    an explicit `isReversed` guard at the top of the function returning
    `""` for any range where `start` is after `end`. The function's only
    production caller (`core/autocomplete/templating/constructPrefixSuffix.ts`)
    always constructs forward ranges, so this is purely additive
    hardening with no behavior change for any existing valid caller.
  - **Production bug 2** (`intersection`, `core/util/ranges.ts`): when two
    ranges' earliest end line coincided (`startLine === endLine` in the
    same-line branch), the function unconditionally took
    `Math.min(a.end.character, b.end.character)` — but if one range's real
    `end.line` is actually _later_ than that shared line (i.e. it doesn't
    end on this line at all), its `end.character` refers to a different
    line and must not bound the intersection here. This produced incorrect
    `null` results for ranges that genuinely overlap on a single line
    while one of them continues onto a later line. Fixed by only applying
    a range's `end.character` as a bound when that range's `end.line`
    equals the computed `endLine`. This function has a real production
    caller (`extensions/vscode/src/autocomplete/lsp.ts`, used to
    deduplicate overlapping definition ranges), so this fix corrects an
    actual duplicate-detection defect, not just a hypothetical case.
    Validation: `npx cross-env IGNORE_API_KEY_TESTS=true NODE_OPTIONS=--experimental-vm-modules jest util/ranges.test.ts`
    — 32/32 passed. Full-suite regression check: `npm run test` in `core/` —
    51/59 suites passed (897/973 tests passed, 76 skipped in the remaining
    un-migrated families), zero failures. `npm run tsc:check` in `core/`
    passed with no errors. `npm run tsc:check` in `extensions/vscode/` (the
    only other package importing `core/util/ranges.ts` production code)
    passed with no errors, confirming the `intersection`/`getRangeInString`
    signature is unchanged and the fix is safe for that caller.
