# Phase 3: Core Boundary Plan v0

**Status:** Draft — classification and experiment design only. No source
changes are authorized by this document. Product deletion/refactor remains
**NO-GO** until each batch's approval gate passes.
**Supersedes:** N/A — this is a new phase, opened after
`phase2-repository-classification-plan_v1.md` (Batches A-G, merged) and
`phase2a-cut-jetbrains.md` (3 batches, merged) both completed their full
Experiment orders.
**Builds on:** `docs/reduction/cli-core-boundaries.md`,
`docs/reduction/cli-core-entry-points.md`, and
`docs/planning/phase0-baseline-plan_v2.md`'s target-architecture invariant:

> After the CLI/Core reduction, the CLI must consume Core through a
> documented, deliberately exported API. Core must not depend on CLI, VS
> Code, GUI, webview, browser, or extension-activation modules except
> through approved adapter interfaces. This is a Phase 1/Phase 6 target,
> not a Phase 0 baseline requirement.

## Purpose

Phases 1, 2, and 2a removed *unused or unsupported* repository surfaces
(dead packages, orphaned assets, stale CI, the JetBrains plugin). None of
that work touched the CLI/Core relationship itself. Phase 0 characterized
that relationship and recorded it as a known, unresolved architectural gap
via two standing boundary exceptions:

- **BND-001** — the production CLI imports 63 Core specifiers (29 through
  `core`/`core/index.js`, 34 as deep internal paths such as
  `core/util/paths.js` or `core/edit/searchAndReplace/performReplace.js`)
  with no declared public Core API contract governing them.
- **BND-002** — `core/package.json` declares no `main`, `types`, or
  `exports` field. The only pointer to a public surface is a source-tree
  `core/index.d.ts` with no corresponding build output or package
  entry point.

Phase 3 does not yet fix these. Its purpose is to **classify** the 63
CLI-to-Core imports (which are genuinely part of a supported public
surface vs. which are incidental/reducible internal reachthroughs) and
propose a narrow, reversible experiment order for closing the gap —
mirroring the classify-before-you-cut discipline used in Phase 2.

`RED` still means **Reduction Execution and Deletion**, not TDD red/green
status, but this phase's "reduction" target is *import-surface area and
undeclared coupling*, not files. A successful outcome may add a small
amount of code (an `exports` map, a barrel file) in exchange for removing
a much larger amount of undeclared, ad hoc coupling.

## Relationship to prior work

| Prior artifact | What it recorded | What Phase 3 does with it |
| --- | --- | --- |
| `docs/reduction/cli-core-boundaries.md` | BND-001 (63 imports, no declared API) and BND-002 (no `main`/`types`/`exports`) as accepted Phase 0 baseline exceptions | Treats both as the Phase 3 removal/repair candidates |
| `docs/reduction/cli-core-entry-points.md` | CLI resolves `core` via `tsconfig.json` path aliases and `build.mjs` esbuild aliases, not a package export; `core/dist/core.js` is built but nothing consumes it as a package root | Confirms the alias mechanism to be replaced |
| `docs/reduction/artifacts/phase0/boundaries/static-and-bundle.json` | Full 63-entry specifier inventory (importer file, specifier, classification) | Source data for this plan's candidate classification below |
| `tests/characterization/boundary-check.mjs` / `runtime-boundary-check.mjs` | Existing denylist checks (VS Code/GUI/binary/docs-site/electron/vscode-package prohibitions) | Reused unchanged as the retained-closure regression gate for every batch in this plan; a new check is proposed (see Experiment order item 3) to positively assert the *new* boundary once it exists |

## Candidate identity

The 63 CLI→Core imports split into two populations that must be handled
differently:

### Population A — top-level `core`/`core/index.js` imports (29)

These already import through the *nominal* package root, not an internal
path. They are the closest thing to "already using a public API" — the
gap is that `core/index.d.ts` exists in source but is never built or
declared as a package entry, so the import only works because of the
CLI's TypeScript path alias and esbuild alias, not because Core declares
it.

### Population B — deep internal-path imports (34)

Representative specifiers (full list in
`docs/reduction/artifacts/phase0/boundaries/static-and-bundle.json`):

| Specifier | Apparent purpose |
| --- | --- |
| `core/util/paths.js` | Path/workspace utilities |
| `core/util/uri.js` | URI normalization |
| `core/util/errors.js` | Shared error types |
| `core/util/history.js` | Session/chat history helpers |
| `core/util/messageContent.js`, `core/util/messageConversion.js` | Message-shape helpers |
| `core/util/chatDescriber.js` | Chat summarization helper |
| `core/util/GlobalContext.js` | Persisted global settings/context |
| `core/llm/getAdjustedTokenCount.js`, `core/llm/utils/calculateRequestCost.js` | Token/cost accounting |
| `core/indexing/ignore.js` | Ignore-file handling for indexing |
| `core/config/markdown/utils.js` | Config markdown parsing helpers |
| `core/edit/searchAndReplace/{findAndReplaceUtils,multiEditValidation,performReplace}.js` | Edit-tool search/replace implementation |
| `core/tools/implementations/fetchUrlContent.js` | A single tool implementation |

These are not obviously wrong to depend on — several (edit search/replace,
token accounting, ignore-file handling) look like genuine shared
implementation the CLI needs. The problem is that the dependency is
*undeclared*: nothing in `core/package.json` says these paths are public,
versioned, or stable, so Core is free to move, rename, or break them
without any contract violation being visible except a broken CLI build.

### Pre-experiment identity checks (already performed for this plan)

```bash
# Confirm the 63-import baseline is unchanged since Phase 0
node tests/characterization/boundary-check.mjs
python3 -c "import json; d=json.load(open('docs/reduction/artifacts/phase0/boundaries/static-and-bundle.json')); \
  imports=d['staticSource']['cliCoreImports']; \
  print(len(imports), len([i for i in imports if i['classification']=='deep-import']))"
# -> 63 total, 34 deep-import

# Confirm Core's package.json still declares no public entry points
node -e "const p=require('./core/package.json'); console.log(p.main, p.types, p.exports)"
# -> undefined undefined undefined

# Confirm core/index.d.ts exists in source but has no build counterpart
ls core/index.d.ts core/dist/core.js
```

## Removal/repair hypothesis

The 63-import, no-declared-API state can be closed without breaking the
CLI, VS Code, or any retained package, because:

- Every one of the 63 specifiers already resolves successfully today
  through `extensions/cli`'s existing `tsconfig.json` path alias and
  `build.mjs` esbuild alias — declaring them as real `exports` entries
  changes *how* they resolve, not *whether* they resolve.
- `core/dist/core.js` is already built by the existing `npm run build` in
  `core/`; wiring `core/package.json`'s `exports`/`main`/`types` to point
  at the already-produced build output requires no new build step.
- The CLI is the *only* declared consumer of these deep paths (per
  `docs/reduction/cli-core-boundaries.md`'s BND-001 evidence and Phase 2's
  confirmation that VS Code's `gui/dist` packaging path is independent of
  Core's JS/TS export surface) — so narrowing/renaming the exposed surface
  cannot silently break a second, undiscovered consumer.
- `tests/characterization/boundary-check.mjs` and
  `runtime-boundary-check.mjs` already assert the CLI's bundle/runtime
  boundaries; they provide a ready-made regression gate for every batch in
  this plan without new tooling.

### Disconfirming conditions (would block or reverse a batch)

- Declaring `exports` on `core/package.json` breaks CLI TypeScript
  resolution or the esbuild alias (e.g. subpath-exports enforcement
  rejecting a path the CLI still needs) in a way not resolved by updating
  the `exports` map itself.
- A deep import turns out to be resolved differently at build time than
  at runtime (e.g. an esbuild alias masks a path that `node`'s own
  resolver would reject), which would mean the current baseline is more
  fragile than recorded and needs its own characterization fix first.
- Any of the 34 deep-import specifiers turns out to be reachable only
  through a subpath that legitimately cannot be a stable public API
  (e.g. it reaches into a module with editor-only side effects at import
  time) — such a specifier must be re-implemented or relocated rather than
  exported as-is, and is flagged for its own follow-up decision rather than
  silently included in a barrel export.
- The owner decides the CLI/Core split should be collapsed (e.g. Core
  folded into the CLI package) instead of formalized — in which case this
  plan's premise (declare and narrow a boundary) no longer applies and a
  different plan is needed.

## Experiment order

Following the same one-candidate-per-experiment, narrowest-first
convention as Phase 2/2a:

1. **Declare the existing surface as-is (no code moves).** Add
   `main`, `types`, and an `exports` map to `core/package.json` that
   points at the already-built `core/dist/core.js` / `core/index.d.ts`
   output and explicitly lists every one of the 34 deep-import subpaths
   already in use, so the *declared* contract matches the *actual*
   baseline usage exactly — zero behavior change, purely making the
   existing coupling visible and versioned. Update `extensions/cli`'s
   `tsconfig.json` path alias and `build.mjs` esbuild alias only if needed
   to prefer the new package entry over the raw directory alias.
2. **Classify each of the 34 deep-import subpaths individually** as
   `Promote` (genuinely general-purpose shared logic that belongs in a
   stable public surface — e.g. token accounting, search/replace edit
   logic), `Relocate` (CLI-specific enough that it should move into
   `extensions/cli` or a shared `packages/*` instead of living in Core),
   or `Investigate` (unclear ownership, needs a follow-up spike). Record
   each decision with the same evidence rigor as Phase 2's per-surface
   table — this experiment produces a classification table, not code
   changes.
3. **Add a positive boundary-conformance check** alongside the existing
   negative denylist checks: assert that every CLI import of `core`
   resolves through a subpath declared in `core/package.json`'s `exports`,
   failing the build if a new undeclared deep import is introduced after
   this plan lands. This closes the gap so BND-001 cannot silently regrow.
4. **Execute `Relocate` decisions from item 2**, one specifier (or tightly
   related group) per batch, each on its own branch with its own
   retained-closure re-verification — mirroring Phase 2's per-batch
   discipline exactly.
5. **Retire BND-001 and BND-002** in
   `docs/reduction/cli-core-boundaries.md` once items 1-3 are merged,
   replacing the "accepted baseline exception" language with a record of
   the declared contract and a link to this plan; leave a note pointing at
   any still-open `Relocate`/`Investigate` items from item 2 that are
   tracked as follow-up work rather than blocking this phase's close-out.

Each item gets its own branch, its own narrow commit, its own
retained-closure re-verification, and is pushed for manual merge approval
— no batch under this plan merges itself, exactly as in Phase 2/2a.

## Retained-closure verification per batch

Every batch re-runs, at minimum:

- `extensions/cli`'s `npm run build` (must still produce a working
  `dist/cn.js` of comparable bundle size; a large unexplained size change
  is itself a finding to investigate before proceeding).
- `core`'s existing build/typecheck command.
- `tests/characterization/boundary-check.mjs` (static source + emitted
  bundle) — must continue to report zero denylist violations, and, after
  item 3 lands, zero undeclared-subpath violations.
- `tests/characterization/runtime-boundary-check.mjs` — must continue to
  pass with zero prohibited runtime resolutions.
- A CLI smoke invocation (`dist/cn.js --version` at minimum; a broader
  smoke command if one is already established) to catch a resolution
  break that only manifests at runtime, not at bundle time.

Item 1 (declaring the existing surface) and item 3 (adding the positive
check) are expected to be zero-behavior-change by hypothesis; any
verification failure on those two items is a signal the baseline was
already less stable than recorded, not that the change itself is wrong,
and should be investigated as its own finding before retrying.

## Explicitly out of scope

- **Redesigning what Core's public API *should* contain.** This plan
  declares and classifies the *existing* 63-import surface; it does not
  add new capabilities or redesign Core's module layout beyond the
  `Relocate` decisions produced by item 2.
- **VS Code's consumption of Core.** `extensions/vscode` was not part of
  the BND-001 evidence collection and is not re-surveyed here; if it turns
  out to depend on the same internal paths, that is a new finding to
  triage separately rather than assumed in this plan's hypothesis.
- **Publishing Core to a registry.** `main`/`types`/`exports` are being
  declared for the CLI's internal monorepo consumption; whether Core is
  ever published externally is a separate decision.
- **Any file/package deletion in the Phase 1/2 sense.** This phase may
  relocate a handful of small modules (item 4) but is not a dead-code
  removal pass; it does not revisit any Phase 1/2/2a `Keep`/`Defer`
  classification.

## Current readiness blockers

None identified. The Node.js pin, retained-closure matrix, and
`continue-sdk` manifest-version blockers recorded in
`phase2-repository-classification-plan_v1.md` were resolved before that
plan's Experiment order began and remain resolved. No new blocker was
found while re-confirming the BND-001/BND-002 evidence for this plan.

## RED readiness

This checkout is ready to begin classification/experiment-design work
under this plan:

- Local `main` is fast-forwarded through all merged Phase 2 (Batches A-G)
  and Phase 2a (CI removal, plugin source removal, metadata/docs cleanup,
  plus the plan-doc merge) commits.
- No open `reduce/*` or `docs/*` branches remain from prior phases; all
  have been deleted locally and on the remote.
- The BND-001/BND-002 evidence in `docs/reduction/cli-core-boundaries.md`
  and `docs/reduction/cli-core-entry-points.md` has been re-confirmed
  against the current `main` (63 imports, 34 deep, no declared
  `main`/`types`/`exports`) rather than assumed stale from Phase 0.
- The same caveat carried over from Phase 2/2a applies: `gh` CLI is not
  installed locally, so PRs cannot be created or merged from this
  environment — every batch under this plan will be pushed with a
  "create PR" link and left for manual review/merge in the GitHub UI.

Proceed with Experiment order item 1 (declare the existing surface
as-is) once this plan is reviewed and approved.
