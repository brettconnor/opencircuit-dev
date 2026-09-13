# Phase 3 Item 5 — Relocate CLI-owned functionality

## Scope

Per the plan (`docs/planning/phase3-core-boundary_v1.md`, Item 5): move only items
classified `RelocateToCLI` or `MoveToSharedPackage` in Item 1's classification table.

## Finding

Item 1's evidence (`docs/reduction/artifacts/phase3/item1-evidence.md`) classified
all 34 deep CLI→Core imports (16 unique specifiers). The classification counts:

| Classification | Count |
|---|---|
| `RelocateToCLI` | 0 |
| `MoveToSharedPackage` | 0 |

Zero imports were classified as CLI-owned or shared-package-owned functionality
that had drifted into Core. Every deep import was either already cross-consumer
shared, independently tested inside Core, or part of a cohesive functional group
that legitimately belongs in Core (e.g. the `edit/searchAndReplace/*` trio).

This conclusion held throughout Item 4's execution as well: all 10 subpath groups
migrated (`errors`, `messageConversion`, `chatDescriber`, `globalContext`, `editing`,
`security`, `paths`, `messageContent`, `uri`, `llm/calculateRequestCost` +
`llm/getAdjustedTokenCount`) were promoted to declared public Core API surface —
none were extracted out of Core into the CLI or a shared package, because none
were misplaced.

## Outcome

**Item 5 is a no-op.** No code was moved. This is the correct, evidence-driven
result per the plan's own exit condition: *"CLI-only or shared-package ownership
is proven and the import surface is reduced without accidental API expansion."*
Ownership was proven to be Core's in every case; no relocation is applicable.

No commits, branches, or PRs were required for this item since there is no code
change to validate.

## Exit condition status

Met — by inspection, not by relocation. Item 1's classification table is the
narrow ownership hypothesis + source evidence required by the plan; there is no
further batch to execute.
