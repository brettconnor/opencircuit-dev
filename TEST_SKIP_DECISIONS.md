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

- `core/util/index.test.ts` — re-enabled the 2 remaining skipped
  `dedent` edge-case tests (`it.skip` for CRLF line endings and tabs).
  `dedent`'s behavior is fully deterministic (pure string transformation,
  no network, no external infra). Both were stale test-expectation
  issues, not production defects — no changes were made to
  `core/util/index.ts`'s `dedent` implementation:

  - CRLF test: the implementation only strips the common _leading_
    indentation shared by all lines; it never trims trailing whitespace
    from an individual content line. The test's fixture ends its last
    content line with a literal `\r`, and the implementation correctly
    leaves that `\r` attached to the line (`"Hello\r\n  World\r"`), since
    trimming trailing per-line whitespace is out of scope for this
    function and no other passing test in this file expects it. Verified
    the actual output directly (temporary probe test, removed after use)
    before concluding the expected value (which omitted the trailing
    `\r`) was simply wrong. Corrected the expectation to match verified,
    correct current behavior.
  - Tabs test: verified by direct calculation that all three fixture
    lines (`"      \tHello"`, `"      \t\tWorld"`, `"      \t\t\t!"`)
    share an identical first 7 characters (6 spaces + 1 tab — line 1's
    only tab, line 2's first tab, and line 3's first tab all fall at the
    same position), making 7 the true common-indentation-prefix length,
    not merely a byte-count coincidence. The implementation's
    length-based `minIndent` calculation therefore strips exactly the
    correct common prefix, including the shared tab, and correctly
    preserves each line's non-common extra tabs
    (`"Hello\n\tWorld\n\t\t!"`). The original test expected the tabs to
    be left completely untouched (`"\tHello\n\t\tWorld\n\t\t\t!"`), which
    does not match correct common-prefix dedent semantics. Corrected the
    expectation to match verified, correct current behavior.
  - No production callers of `dedent` (`core/llm/templates/edit/gpt.ts`,
    `core/llm/templates/edit/codestral.ts`, `core/edit/lazy/replace.ts`,
    `core/edit/lazy/prompts.ts`, `core/autocomplete/filtering/test/testCases.ts`)
    use tabs or CRLF content — all are plain space-indented prompt
    templates — so there was no evidenced production defect to justify
    changing the shared `dedent` implementation (unlike the round 3
    `ranges.ts` fixes, which had concrete real-caller evidence).
    Validation: `npx cross-env IGNORE_API_KEY_TESTS=true NODE_OPTIONS=--experimental-vm-modules jest util/index.test.ts`
    — 64/64 passed. Full-suite regression check: `npm run test` in `core/`
    — 51/59 suites passed (899/973 tests passed, 74 skipped in the
    remaining un-migrated families), zero failures. `npm run tsc:check`
    passed with no errors.

- `core/util/generateRepoMap.test.ts` — re-enabled the sole
  `describe.skip("generateRepoMap")` block (3 tests). Behavior is fully
  deterministic (in-process file generation against a real temp test
  directory, no network, no external infra). All 3 failures were caused
  by pre-existing bugs **in the test fixture itself**, not in
  `core/util/generateRepoMap.ts` — no production code was modified:
  - The mock `groupedByUri` keys were built with `path.join(TEST_DIR,
...)`, but `TEST_DIR` is itself a `file://` URI (see
    `core/test/testDir.ts`), and Node's `path.join` collapses the
    URI's double slash (`file:///...` → `file:/...`). This produced
    mock keys that never matched the real `file:///...`-format URIs
    `generateRepoMap` collects via `walkDirs`, so its
    `pathsInDirsWithSnippets` bookkeeping never recognized a uri as
    already processed, and every file incorrectly reappeared in the
    "remaining uris without snippets" section. Fixed by building the
    mock keys with `joinPathsToUri` (`core/util/uri.ts`) — the same
    URI-safe join helper `generateRepoMap`'s own callers use — instead
    of `path.join`.
  - The "file read errors" test mocked `fs.promises.readFile`, but
    `generateRepoMap` actually calls `this.ide.readFile(uri)`, and the
    concrete `FileSystemIde.readFile` (`core/util/filesystem.ts`) uses
    the callback-style `fs.readFile`, not `fs.promises.readFile` — so
    the mock never intercepted anything and the simulated read failure
    never occurred. Fixed by mocking `testIde.readFile` directly (the
    actual method invoked), falling back to the real implementation for
    files other than the intentionally-failing one.
  - The same test's expected error-log string used a stale `Path:`
    label; the current implementation logs `Uri:`
    (`core/util/generateRepoMap.ts`'s catch block). Corrected the
    expected string to `Uri:` once the mock was fixed to actually fire.
  - Two tests' expected output included a trailing `\n` after the last
    plain-uri entry, but both code paths that write plain uri lists
    (the `includeSignatures: false` branch, and the "remaining uris
    without snippets" pass) build their content via
    `uris.map(...).join("\n")`, which never appends a trailing
    terminator — unlike the `includeSignatures: true` per-file blocks,
    which each end in `"\n\n"`. Verified this against all 4 current
    production callers of `generateRepoMap`
    (`core/tools/implementations/viewRepoMap.ts`,
    `core/tools/implementations/viewSubdirectory.ts`,
    `core/context/providers/RepoMapContextProvider.ts`,
    `core/context/retrieval/repoMapRequest.ts`) — each embeds the
    returned string as prose context in a prompt, where a missing
    trailing newline has no functional effect — so this is a cosmetic,
    not correctness, difference, and the fix belongs in the test
    expectation rather than in production output. Corrected both
    expectations to drop the stale trailing newline.
    Validation: `npx cross-env IGNORE_API_KEY_TESTS=true NODE_OPTIONS=--experimental-vm-modules jest util/generateRepoMap.test.ts`
    — 3/3 passed. Full-suite regression check: `npm run test` in `core/` —
    52/59 suites passed (902/973 tests passed, 71 skipped in the remaining
    un-migrated families), zero failures. `npm run tsc:check` passed with
    no errors.
- `core/diff/util.vitest.ts` — re-enabled the sole
  `describe.skip("matchLine")` block (10 tests; `streamLines` and
  `generateLines` in the same file were already enabled and passing).
  Behavior is fully consistent with the current, correct implementation
  in `core/diff/util.ts` — no production code was modified:
  - Removing the skip produced exactly 1 failure (of 10):
    "should match lines with tolerable differences" expected
    `matchIndex: 2` for `newLine = "console.log(a);"` against
    `oldLines = ["const a = 5;", "console.log(b);", "console.log( a );"]`.
  - `matchLine` is a first-match-wins linear scan (confirmed by reading
    its sole real caller, `core/diff/streamDiff.ts`, which relies on
    scanning old lines in order and taking the first sufficiently-close
    match to build a line-by-line diff). Verified via
    `fastest-levenshtein`'s `distance()` directly (`node -e`) that index 1
    (`"console.log(b);"`, edit distance 1, ratio 0.067) is closer than
    index 2 (`"console.log( a );"`, edit distance 2, ratio 0.118) and
    both are within the matching threshold, so the implementation
    correctly returns the first (index 1) match it encounters while
    iterating in order. The test's expectation of index 2 was a stale/
    incorrect fixture expectation, not a description of real behavior —
    corrected it to `matchIndex: 1` (still a genuine "tolerable
    difference" match, just at the index the algorithm actually reaches
    first).
  - Affected files: `core/diff/util.vitest.ts` only (one expectation
    corrected, `describe.skip` → `describe`). No production code changed.
  - Validation: `npx vitest run diff/util.vitest.ts` — 14/14 passed.
    Full `core/` vitest suite (`npm run vitest`): 94/98 files passed
    (1669/1700 tests passed, 6 skipped); the 3 failing files
    (`config/loadContextProviders.vitest.ts`, `util/repoUrl.vitest.ts`,
    `config/yaml/LocalPlatformClient.vitest.ts`) and the docker-dependent
    `OpenAI-compatible.vitest.ts` uncaught-exception cases were confirmed
    via `git stash` to fail identically on the pre-change baseline —
    pre-existing, unrelated to this change. `npm run test` (jest):
    52/59 suites, 902/973 tests, zero failures (unchanged — jest does not
    run `.vitest.ts` files). `npm run tsc:check` in `core/` passed with
    no errors.
