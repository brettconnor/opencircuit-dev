# Phase 3 Item 6 — Positive boundary conformance enforcement

## Scope

Per the plan (`docs/planning/phase3-core-boundary_v1.md`, Item 6): "Once the
actual package contract exists, add the check that rejects: Core filesystem
aliases from production CLI code; undeclared subpath imports; new deep
imports; unapproved compatibility imports after their expiry." Exit condition:
"the boundary contract is enforced and cannot silently regrow."

## What was added

`tests/characterization/positive-boundary-check.mjs` — a new, independent
script alongside the existing `boundary-check.mjs` (Phase 0's denylist/
retained-closure check). Where `boundary-check.mjs` checks "CLI doesn't import
denied packages/paths," this new script checks the opposite direction:
**CLI's Core imports must be on an explicit allowlist**, built directly from
Item 2's evidence:

- `APPROVED_ROOT_IMPORTS`: `core`, `core/index.js` (types-only root, per Item
  2's root note).
- `APPROVED_SUBPATHS`: the 11 declared runtime subpaths CLI-migrated across
  Item 4's 10 batches (`errors`, `messageConversion`, `chatDescriber`,
  `globalContext`, `editing`, `security`, `paths`, `messageContent`, `uri`,
  `llm/calculateRequestCost`, `llm/getAdjustedTokenCount`).
- `DEFERRED_SPECIFIERS`: the 3 specifiers Item 2 explicitly excluded pending
  Item 1's `Investigate` follow-up (`core/util/history.js`,
  `core/tools/implementations/fetchUrlContent.js`,
  `core/config/markdown/utils.js`). These are tracked, not silently permitted:
  they only pass because they are individually enumerated, and any change to
  this set requires updating the script alongside new evidence — they are not
  a wildcard escape hatch.

Any other Core import from CLI production source — a new deep import into an
undeclared subpath, or a relative-path filesystem alias that reaches into
`core/` bypassing the `core`/`core/*` package alias entirely — fails the
check with a non-zero exit code.

## Real violations found and fixed

Running the new check against the baseline surfaced **6 genuine violations**
that the Item 1 inventory had missed, because Item 1 only scanned bare
`"core"`-prefixed specifiers, not relative-path traversal into `core/`:

| File | Before | After |
| --- | --- | --- |
| `extensions/cli/src/telemetry/telemetryService.ts` | `from "../../../../core/util/errors.js"` | `from "core/errors.js"` |
| `extensions/cli/src/ui/EditMessageSelector.tsx` | `from "../../../../core/index.js"` | `from "core"` |
| `extensions/cli/src/ui/components/MemoizedMessage.tsx` | `import("../../../../../core/index.js").MessageContent` (inline) | `import type { ChatHistoryItem, MessageContent } from "core"` |
| `extensions/cli/src/ui/components/ScreenContent.tsx` | `from "../../../../../core/index.js"` | `from "core"` |
| `extensions/cli/src/ui/components/StaticChatContent.tsx` | `from "../../../../../core/index.js"` | `from "core"` |
| `extensions/cli/src/ui/hooks/useMessageRenderer.tsx` | `from "../../../../../core/index.js"` | `from "core"` |

All six were relative-path filesystem aliases into `core/`, bypassing the
declared `core`/`core/*` package alias — exactly the first rejection category
in Item 6's spec ("Core filesystem aliases from production CLI code"). All
six bindings (`ContinueErrorReason`, `ChatHistoryItem`, `MessageContent`) were
already available through the approved public surface (`core/errors.js` or
the types-only `core` root), so each fix was a pure import-path change with
zero logic changes — consistent with every prior Item 4 batch.

`MessageContent` specifically required care: it is only *used* (not
re-exported) by `core/util/messageContent.ts`, so `core/messageContent.js`'s
facade (`export * from "./util/messageContent.js"`) does not carry it. It is
defined and exported at Core's root (`core/index.d.ts`), so it correctly
belongs on the `core` (types-only root) import, alongside `ChatHistoryItem`.

## Validation

- New script run standalone: `pass`, `violationCount: 0`,
  `approvedImportCount: 63`, `deferredImportCount: 4` (unchanged specifiers,
  now attributed to 4 import sites instead of the pre-fix 6 violations).
- `boundary-check.mjs` (Phase 0 check): unchanged, `pass`, bundle
  `inputCount: 4145`, `violations: []` (no new Core files were added — this
  item only changed CLI import paths and added the enforcement script).
- CLI build: unchanged bundle size (12.69 MB).
- CLI `npm run lint` (`tsc --noEmit && eslint .`): clean for all 6 touched
  files (no new errors or warnings introduced; pre-existing, unrelated
  `import/order` lint debt in other files — `streamChatResponse.ts`,
  `executor.ts`, `edit.ts`, `fetch.ts`, `readFile.ts` — was confirmed present
  on `main` before this change via `git stash` and left untouched, per the
  instruction not to fix unrelated pre-existing issues).
- Targeted CLI vitest for touched files with existing test coverage:
  `telemetryService.sessionMetadata.test.ts` (8), `EditMessageSelector.test.tsx`
  (8), `MemoizedMessage.formatDisplay.test.tsx` (8) — **24/24 passed**.
  `ScreenContent.tsx`, `StaticChatContent.tsx`, and `useMessageRenderer.tsx`
  have no dedicated test files; their changes are type-only import paths,
  fully validated by the passing `tsc --noEmit` typecheck.

## Exit condition status

Met. The boundary contract (Item 2's proposed API matrix, as migrated by
Item 4) is now enforced by an executable, allowlist-based check that fails on
any new deep import, undeclared subpath, or Core filesystem alias — the
boundary cannot silently regrow. The check is not yet wired into CI (that is
an infra/CI-configuration change outside this reduction plan's scope, which
has focused on establishing evidence + the check itself); running it is a
one-line `node tests/characterization/positive-boundary-check.mjs` invocation
alongside the existing `boundary-check.mjs`.
