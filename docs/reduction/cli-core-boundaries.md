# CLI/Core Boundary Inventory

## Named Denylist

The Phase 0 checks prohibit Core source imports and CLI bundle/runtime resolution into these repository surfaces:

- `extensions/cli/` from Core.
- `extensions/vscode/`.
- `gui/`.
- `docs-site/`.
- `binary/`.

The package denylist is:

- `vscode`.
- `@vscode/*`.
- `electron`.

String literals, configuration values, protocol names, comments, tests, and fixtures are not treated as imports.

The package denylist is applied to Core source imports, CLI source imports, emitted `node_modules` inputs, and runtime-resolved specifiers and URLs.

## Observed CLI-to-Core Imports

The production CLI contains (updated 2026-09-13, post Phase 3 Items 1–6):

| Classification                    | Count |
| --------------------------------- | ----: |
| Deep `core/*` imports             |    33 |
| `core` or `core/index.js` imports |    34 |
| Total                             |    67 |

Counts shifted from the original Phase 0 baseline (34 deep + 29 root = 63)
because: (a) Item 4 migrated CLI import sites from old deep paths to new
declared facade paths (still counted as deep imports, since they are still
`core/<subpath>` specifiers, just now declared/public ones), and (b) Item 6's
fixes moved 5 import sites that were previously relative-path filesystem
aliases into `core/index.js` onto the root `core` bare specifier, increasing
the root count. See `docs/reduction/artifacts/phase3/item2-evidence.md` and
`item6-evidence.md` for the detailed per-file mapping.

The complete file and specifier inventory is stored in `artifacts/phase0/boundaries/static-and-bundle.json` (Phase 0 baseline; not regenerated for Phase 3 — see the live `boundary-check.mjs` output for current counts).

### Boundary exception BND-001

| Field              | Value                                                                 |
| ------------------ | --------------------------------------------------------------------- |
| Forbidden item     | CLI imports of undeclared Core implementation paths                   |
| Surface            | `extensions/cli/src`                                                  |
| Reason             | Existing baseline architecture                                        |
| Scope              | Phase 0 characterization only                                         |
| Evidence           | `artifacts/phase0/boundaries/static-and-bundle.json`                  |
| Owner              | CLI/Core reduction workstream                                         |
| Removal condition  | Declare a supported Core API and migrate CLI imports                  |
| Approval reference | `docs/planning/phase0-baseline-plan_v2.md` observed-baseline contract |
| **Status**         | **Partially resolved — Phase 3 Items 1–6.** See below.                |

**Resolution detail (Phase 3, closed 2026-09-13):**

Item 1 classified all 34 deep import sites (16 unique specifiers) plus the 29
root/`core`-import sites. Item 2 proposed stable public paths for every
specifier classified `PublicSubpathCandidate`/`RootPublicCandidate`. Item 3
made the root `types` entry point real and buildable. Item 4 executed 10
independently-reviewed batches that created public facade files (or, in one
case, confirmed the module's existing path already matched its target public
path) and migrated every corresponding CLI import site to the new declared
path — see `docs/reduction/artifacts/phase3/item2-evidence.md` for the full
mapping and the 10 `item4-*-group.md` evidence docs for per-batch validation.
Item 6 added `tests/characterization/positive-boundary-check.mjs`, an
allowlist-based enforcement check that fails on any CLI import of an
undeclared Core path — including, as discovered while building the check,
relative-path filesystem traversal into `core/` that bypasses the package
alias entirely (6 such violations were found and fixed as part of Item 6).

**Resolved:** 12 of 16 deep specifiers (10 declared subpaths after grouping)
and the root type population are now declared public API, CLI-migrated, and
enforced against regrowth.

**Still open (not closed by this exception's removal condition):**
- 3 of 16 deep specifiers remain classified `Investigate` in Item 1
  (`core/util/history.js`, `core/tools/implementations/fetchUrlContent.js`,
  `core/config/markdown/utils.js`) and are unresolved pending a targeted
  follow-up; the positive boundary check (Item 6) tracks them as an explicit,
  enumerated deferred set rather than silently permitting them.
- The old (pre-facade) deep-import file paths inside Core were never removed
  — per the plan's own Item 4 text ("retain old path as compatibility
  export... remove old path only in a separately approved batch"), removal
  of the old paths is an explicitly separate, not-yet-approved future batch.
  CLI itself no longer imports via the old paths (migrated to facades), but
  the old paths still physically exist and are not yet deleted.

This exception should remain **open** (not deleted) until the 3 `Investigate`
specifiers are resolved and a future batch approves removing the old
compatibility paths — per Item 7's instruction to "close only the portions
actually resolved."

## Core Export State

As of Phase 0's original baseline, `core/package.json` had no `main`, `types`,
or `exports` fields. Phase 3 Item 3 (2026-09-12) declared
`"types": "dist/index.d.ts"` and added a build step to populate it — see
BND-002 resolution detail below for what changed and what remains open.
`core/package.json` still has no `"main"` or `"exports"` field.

### Boundary exception BND-002

| Field              | Value                                                                    |
| ------------------ | ------------------------------------------------------------------------ |
| Forbidden item     | Missing declared public Core runtime export                              |
| Surface            | `core/package.json` and `core/dist`                                      |
| Reason             | Existing baseline package state                                          |
| Scope              | Phase 0 characterization only                                            |
| Evidence           | `docs/reduction/cli-core-entry-points.md`                                |
| Owner              | CLI/Core reduction workstream                                            |
| Removal condition  | Add and test an intentional Core package export                          |
| Approval reference | `docs/planning/phase0-baseline-plan_v2.md` target-architecture invariant |
| **Status**         | **Partially resolved — Phase 3 Items 3–4.** See below.                   |

**Resolution detail (Phase 3, closed 2026-09-13):**

Item 3 declared `"types": "dist/index.d.ts"` in `core/package.json` and added
a build step that copies the hand-authored `core/index.d.ts` into `dist/`
(TypeScript does not emit `.d.ts` source files to `outDir` on its own — this
was the exact gap Item 0's evidence identified). No `"main"` or `"exports"`
field was added, matching Item 1's finding that the root population is
type-only in practice (0 of 29 CLI root imports are runtime value imports).

Item 4 then added 10 concrete, tested runtime subpath facades
(`core/errors.ts`, `core/messageConversion.ts`, `core/chatDescriber.ts`,
`core/globalContext.ts`, `core/editing.ts`, `core/security.ts`,
`core/paths.ts`, `core/messageContent.ts`, `core/uri.ts`,
`core/llm/calculateRequestCost.ts`, plus `core/llm/getAdjustedTokenCount.ts`
which already existed at its target path). Each was validated as an
external-package consumer would use it: packed into a tarball, installed
into an isolated fixture directory outside the monorepo, and exercised with
both a runtime `import()` and a strict NodeNext `tsc --noEmit` typecheck —
this is the "test an intentional Core package export" half of the removal
condition, performed per-batch rather than once.

**Resolved:** the root `types` entry is real, buildable, and copied
correctly; 10 runtime subpaths are declared, exist as real files, and are
validated to work for an out-of-tree consumer.

**Still open (not closed by this exception's removal condition):**
- `core/package.json` has no `"exports"` map. The facades are real files
  reachable by Node's default package resolution (no `exports` field means
  no restriction on which paths are resolvable), but there is no explicit,
  enumerated `exports` map pinning them as the *only* sanctioned public
  surface at the package-manifest level. This was a deliberate scope
  decision documented in Item 4 ("No `package.json` `exports` map added —
  would break other consumers' unlisted deep imports"), not an oversight,
  but it means the guarantee is enforced today by the Item 6 script rather
  than by the package manifest itself.
- The 3 `Investigate`-classified specifiers (see BND-001) have no declared
  export at all yet.

This exception should remain **open** (not deleted) until an `exports` map
(or an equivalent manifest-level declaration) is added, or until the
workstream explicitly decides the script-level enforcement added in Item 6
is the intended long-term mechanism instead — that decision has not yet been
made and is out of scope for this reduction plan.

## Static Source Check

Command:

```bash
node tests/characterization/boundary-check.mjs
```

Result:

- No prohibited Core source imports.
- 67 CLI-to-Core imports recorded (33 deep + 34 root; see "Observed
  CLI-to-Core Imports" above for the count-shift explanation since Phase 0).
- Deep imports for the 10 declared Item 4 subpaths are now sanctioned public
  API, tracked separately from the 3 still-open `Investigate` specifiers by
  the Item 6 positive check (see below) rather than being lumped together as
  undifferentiated BND-001 debt.

## Emitted-Bundle Check

The same command reads `extensions/cli/dist/meta.json`.

Result (updated 2026-09-13, post Phase 3 Items 1–6):

- 4,145 bundle inputs inspected (10 new facade files added by Item 4 since
  the original Phase 0 baseline of 4,135).
- No inputs from VS Code, GUI, binary, docs-site, or the local Continue SDK
  tree.

No emitted inputs were attributed to the local Config Types or LLM Info trees. Their retention is based on declared/build dependencies and remains subject to a RED removal experiment.

## Positive Boundary Conformance Check (Phase 3 Item 6)

Command:

```bash
node tests/characterization/positive-boundary-check.mjs
```

Unlike the denylist-based checks above (retained from Phase 0), this check
enforces an **allowlist** built from Item 2's proposed API matrix as
CLI-migrated by Item 4: any CLI import of Core outside the declared root
`types` surface, the 11 declared runtime subpaths, or the 3 explicitly
tracked `Investigate` specifiers fails the check. This is what makes BND-001
partially, rather than nominally, resolved — the boundary is enforced, not
just documented.

Result: pass (0 violations, 4 tracked-but-still-open deferred imports; see
`docs/reduction/artifacts/phase3/item6-evidence.md`).

## Runtime Module-Resolution Check

Command:

```bash
node tests/characterization/runtime-boundary-check.mjs
```

The check runs the generated `dist/cn.js --version` entry through a Node.js ESM loader with an isolated home directory. It records every runtime-resolved module and fails on the named repository denylist.

Result: pass, with no prohibited runtime resolutions.

The emitted-bundle check covers bundled internal modules; the runtime loader covers modules that remain externally resolved at execution.
