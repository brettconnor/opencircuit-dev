# Phase 3 Item 7 — Update and close findings accurately

## Scope

Per the plan (`docs/planning/phase3-core-boundary_v1.md`, Item 7): "Close only
the portions actually resolved. Keep compatibility, relocation, and
deferred-surface findings open until their explicit exit conditions are met."

## What was updated

`docs/reduction/cli-core-boundaries.md` — the authoritative Phase 0 findings
document containing exceptions BND-001 and BND-002 — was updated to reflect
what Phase 3 (Items 1–6) actually resolved, without closing either finding
outright, since neither is fully resolved.

### BND-001 (CLI imports of undeclared Core implementation paths)

Marked **partially resolved**:
- **Resolved**: 12 of 16 deep specifiers (grouped into 10 declared public
  subpaths) plus the root type population are now declared, CLI-migrated
  (Item 4), and enforced against regrowth (Item 6).
- **Still open**: the 3 `Investigate`-classified specifiers from Item 1
  (`core/util/history.js`, `core/tools/implementations/fetchUrlContent.js`,
  `core/config/markdown/utils.js`) remain undeclared and unresolved. The old
  (pre-facade) deep-import file paths inside Core were also never removed —
  their removal is an explicitly separate, not-yet-approved future batch per
  the plan's own Item 4 text.

### BND-002 (missing declared public Core runtime export)

Marked **partially resolved**:
- **Resolved**: Item 3 made the root `types` entry point real and buildable;
  Item 4 added and tested 10 concrete runtime subpath facades against an
  isolated external-consumer fixture (packed tarball + strict typecheck),
  satisfying the "test an intentional Core package export" half of the
  removal condition.
- **Still open**: `core/package.json` has no `"exports"` map — a deliberate
  scope decision (documented in Item 4) to avoid breaking other consumers'
  unlisted deep imports, not an oversight, but it means the guarantee is
  currently enforced by the Item 6 script rather than the package manifest
  itself. The 3 `Investigate` specifiers also have no declared export.

Both exceptions explicitly remain **open** in the document (not deleted),
consistent with Item 7's instruction. Stale counts elsewhere in the document
(observed import counts, bundle input count) were also refreshed to match the
current baseline (67 CLI-to-Core imports [33 deep + 34 root], 4,145 bundle
inputs), and a new section documenting the Item 6 positive boundary check was
added alongside the existing Phase 0 static/bundle/runtime checks.

## Why neither exception was closed outright

Item 7 is explicit that only genuinely-resolved portions should be closed.
Both BND-001 and BND-002 have concrete, real residual scope (3 unresolved
`Investigate` specifiers; no manifest-level `exports` map; old compatibility
paths not yet removed) — closing them fully would misrepresent the state of
the repository. Recording them as "partially resolved" with an itemized
"still open" list is the accurate representation and gives a future
workstream (or a future Phase 3 follow-up) a precise, evidence-backed
starting point rather than requiring re-investigation from scratch.

## Validation

- No code changes in this item — documentation only. Re-verified the current
  baseline before and after editing to ensure the figures cited are accurate:
  - `node tests/characterization/boundary-check.mjs`: pass, `inputCount: 4145`,
    `violations: []`, 67 CLI-to-Core imports (33 deep + 34 root).
  - `node tests/characterization/positive-boundary-check.mjs`: pass,
    `violationCount: 0`, `deferredImportCount: 4` (matching the 3 tracked
    `Investigate` specifiers, now spanning 4 import sites since
    `core/util/history.js` is imported from 2 files).

## Exit condition status (Phase 3 as a whole)

With Item 7 complete, all 8 items (0–7) of `docs/planning/phase3-core-boundary_v1.md`
have been executed:
- Item 0: baseline re-verification — done (prior session).
- Item 1: import classification — done.
- Item 2: minimum public API proposal — done.
- Item 3: package root + packed-consumer validation — done.
- Item 4: migrate CLI imports to public subpaths — done (10 batches).
- Item 5: relocate CLI-owned functionality — done (no-op; nothing to relocate).
- Item 6: positive boundary conformance enforcement — done.
- Item 7: update and close findings accurately — done (this document).

Phase 3's overall exit condition — "the CLI↔Core boundary is either a real
package contract or an accurately documented, still-open exception, and the
boundary cannot silently regrow" — is met: the declared subset of the
boundary is now a real, tested, enforced package contract; the remaining
undeclared subset (3 specifiers, the missing `exports` map, and the
undeleted old compatibility paths) is accurately documented as open, not
misrepresented as closed.
