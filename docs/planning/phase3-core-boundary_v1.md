# Phase 3: Core Boundary Plan v1

**Status:** Draft revision — evidence-first classification and package-boundary experiment design. No source changes are authorized by this document before the preflight package-identity and resolution checks complete.
**Supersedes:** `phase3-core-boundary_v0.md`
**Review basis:** `phase3-core-boundary-review.md`

## Purpose

Phase 3 continues the same architectural goal as the earlier plans: formalize the CLI/Core boundary without deleting or redesigning the project in a single pass. The purpose of this revision is to make the plan evidence-based before any `main`, `types`, or `exports` metadata is added to `core/package.json`.

The earlier draft correctly identified the underlying issue — the CLI depends on internal Core modules without a declared package contract. However, it assumed that the existing import style already represented a Node package boundary. That is not yet proven. This revision corrects the sequence: first prove how Core is currently resolved, then classify imports, then expose the minimal intentional contract, then enforce it.

## Core principle

The plan does not authorize a metadata-only declaration as a no-op. Any package-boundary change is a controlled resolution experiment and must be accepted only if the package, TypeScript, esbuild, runtime, and packed-consumer behavior all remain compatible.

## Required preflight: package identity and artifact mapping

Before any `main`, `types`, or `exports` fields are added, complete the following evidence set.

### 1. Identify the actual package boundary

Record the following for `core`:

- declared package name in `core/package.json`
- whether `core` is a package name, a TypeScript alias, an esbuild alias, or all three
- whether the CLI resolves `core` via path aliasing rather than package resolution
- whether the Node resolver sees the same path as the TypeScript and esbuild resolvers

### 2. Verify artifact layout

For the current Core build, record:

- the runtime output the build emits
- the declaration output the build emits
- whether `core/index.d.ts` is source-only or packable output
- whether the emitted files exist after a clean build
- whether the package tarball includes the intended runtime and type entry points

### 3. Verify repository-wide consumer use

Before narrowing or removing any compatibility path, search the repository for both the current alias and the actual package name:

```bash
git grep -nE 'from ["\'\'']core(/|["\'\''])|require\(["\'\'']core(/|["\'\''])' -- ':!node_modules' ':!docs/reduction/artifacts'
```

Also classify any deferred or non-CLI consumer as:

- no consumer found
- consumer found and deferred
- consumer found and blocking a narrowing decision

### 4. Required evidence table

| Question | Required evidence |
| --- | --- |
| What is the Core package name? | `core/package.json` |
| Is `core` a package name or alias? | CLI tsconfig + esbuild config |
| Does `node` resolve `core` from a consumer context? | Node resolution fixture |
| Does `node` resolve each candidate subpath? | Node resolution fixture |
| Does TypeScript resolve the same path? | `tsc --traceResolution` |
| Does esbuild resolve the same path? | esbuild metafile / resolver output |
| Do all three resolve to equivalent targets? | Recorded comparison |

**Exit condition:** the team can state exactly what package specifier, artifact path, and resolver each retained consumer uses today.

## Candidate classification

The CLI-to-Core surface is still treated as the same underlying problem statement, but it is now classified in a deliberately safer order.

### Population A — root `core` / `core/index.js` imports

These are the closest thing to a nominal package root boundary. However, they still require proof that the package root is an actual package contract and not just a monorepo alias.

### Population B — deep internal-path imports

Deep imports still require review, but they are not to be promoted into a public API merely because they are currently used. Each must be classified as one of:

- `RootPublicCandidate`
- `PublicSubpathCandidate`
- `CompatibilityOnlyCandidate`
- `RelocateToCLI`
- `MoveToSharedPackage`
- `Investigate`
- `Blocked`

For each item, record:

- importer
- imported symbol
- runtime/build/type-only role
- test coverage
- Core dependency ownership
- editor/browser side effects
- external or deferred consumers
- proposed stable package path
- migration priority

**Exit condition:** all retained CLI→Core imports have a reviewed classification.

## Revised experiment order

The experiment order below replaces the earlier declaration-first approach.

### Item 0 — package identity, resolution, and artifact mapping

No source changes.

Determine:

- Core package name
- current CLI TypeScript alias
- current esbuild alias
- Node runtime behavior
- generated JS artifact layout
- generated declaration artifact layout
- current package tarball contents
- repository-wide deep-subpath consumers
- runtime resolution behavior for CLI and standalone package-consumer fixtures

**Exit condition:** the team can state exactly what package specifier, artifact path, and resolver each consumer uses today.

### Item 1 — import classification

No source changes.

Classify every CLI→Core import as one of the categories above. This stage produces a classification table, not code changes.

**Exit condition:** all imports have reviewed ownership and migration intent.

### Item 2 — define the minimum public API proposal

No source moves yet.

Create a proposed API matrix that lists:

| Current import | Proposed API path | Status | Reason |
| --- | --- | --- | --- |
| `core` | `<actual-core-package-name>` | Root export | Existing Core API |
| `core/util/paths.js` | `<actual-core-package-name>/paths` | Promote or compatibility | Shared utility |
| `core/edit/searchAndReplace/performReplace.js` | `<actual-core-package-name>/editing` | Promote | Shared edit subsystem |
| CLI-owned internal item | `extensions/cli/...` | Relocate | CLI-only ownership |

**Exit condition:** only approved paths are proposed for permanent public export.

### Item 3 — establish package root and packed consumer behavior

This is the first metadata and code experiment.

Add package metadata only for the Core root API that has a verified build and declaration artifact. Validate:

- clean Core build
- package tarball contents
- isolated JavaScript consumer
- isolated TypeScript consumer
- existing CLI build and runtime
- retained closure regression set

Do not add all deep exports yet.

**Exit condition:** package root usage is proven for a real consumer outside the source tree.

### Item 4 — migrate and expose one approved subpath group at a time

Examples of related groups:

- path and URI utilities
- message normalization utilities
- token/cost accounting
- search/replace editing subsystem
- indexing ignore behavior

For each group:

1. expose a stable package subpath or facade
2. migrate CLI imports
3. retain the old path only as a time-limited compatibility export if needed
4. test package consumer and CLI behavior
5. remove the old compatibility path only in a separately approved batch

**Exit condition:** one approved API group is proven stable and consumed correctly.

### Item 5 — relocate CLI-owned functionality

Move only items classified `RelocateToCLI` or `MoveToSharedPackage`.

Each batch must include:

- narrow ownership hypothesis
- source and bundle evidence
- controlled CLI workflow validation
- no Core API regression
- no unapproved deferred-surface breakage

**Exit condition:** CLI-only or shared-package ownership is proven and the import surface is reduced without accidental API expansion.

### Item 6 — add positive boundary conformance enforcement

Once the actual package contract exists, add the check that rejects:

- Core filesystem aliases from production CLI code
- undeclared subpath imports
- new deep imports
- unapproved compatibility imports after their expiry

**Exit condition:** the boundary contract is enforced and cannot silently regrow.

### Item 7 — update and close findings accurately

Close only the portions actually resolved. Keep compatibility, relocation, and deferred-surface findings open until their explicit exit conditions are met.

## Required package-consumer validation

The package boundary is meant to be a reusable library boundary, not merely a monorepo alias arrangement. Therefore, validate Core as it would be consumed outside its source directory.

Required check sequence:

1. build Core
2. create a package tarball
3. install or link it into an isolated temporary fixture
4. import the package root and every approved public subpath
5. run both JavaScript runtime import and TypeScript typecheck
6. confirm undeclared subpaths fail when compatibility exports are removed

Conceptually:

```bash
cd core
npm run build
npm pack --json
```

Then install the tarball into a temporary consumer fixture outside the repo.

## Retained-closure verification

Every batch must re-run the boundary-closure workflow, at minimum:

- `extensions/cli` build
- Core build and typecheck
- boundary checks
- runtime boundary checks
- CLI smoke test
- retained package install/build verification
- config parsing characterization
- model initialization/selection characterization
- adapter normalization characterization
- bundle size metrics
- lockfile hash review

### Required reporting

| Metric | Baseline | Post-change | Required action |
| --- | ---: | ---: | --- |
| `dist/index.js` bytes | `<baseline>` | `<value>` | Explain material variance |
| `dist/cn.js` bytes | `<baseline>` | `<value>` | Explain material variance |
| metafile input count | `<baseline>` | `<value>` | Explain material variance |
| Core input count | `<baseline>` | `<value>` | Explain material variance |
| deferred-surface input count | `0` | `<value>` | Must remain `0` |

A “material variance” threshold should be defined before approval, such as >5% or a named input-set change. It is a review trigger, not a silent pass.

## Explicitly out of scope

- full redesign of Core’s public API as a greenfield library
- VS Code deep-consumer migration in this phase
- publishing Core externally
- dead-code removal as the primary objective
- any proposal that treats alias behavior as package behavior without evidence

## Approval gate

The plan may proceed only with the following gate:

> Proceed only with Item 0: package identity, resolver, artifact-layout, package-tarball, and repository-wide consumer discovery. No `main`, `types`, `exports`, import-specifier, alias, or module-layout change is authorized until Item 0 and Item 1 evidence are reviewed.

## Current readiness blockers

No new blocker is identified for preflight work itself. The remaining blocker is not a code issue; it is the missing evidence that the current alias arrangement is indeed a package boundary rather than a source-tree resolution shortcut.

## Summary

This revision keeps the original architectural direction but changes the order and wording so the work is evidence-first. The plan is no longer a request to formalize all current deep imports as public API before proving the actual contract. Instead, it intentionally proves the package boundary first, then classifies the real imports, then exposes only the verified, intentional surface.
