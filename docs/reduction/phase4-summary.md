# Phase 4 Summary

## Outcome

Phase 4 execution is complete and ready for HITL exit review. P4-A is fully
accepted. P4-B is conditionally accepted under the batch-specific waiver in
`docs/reduction/artifacts/phase4/P4-B/validation-waiver.md`.

## Provenance

- Phase entry checkpoint:
  `450df8c69cfbb47c87fbd3d45f318279ca8c3074`
- Phase branch before closeout evidence:
  `5abfec7bcf62f1154831b19632e5997055519054`
- P4-A deletion:
  `1acd6b5aa52c39c4c82b15da843e8089dbd82288`
- P4-A evidence:
  `e5f6e63583b61ad88653b12203bea2c605bbfb00`
- P4-A Ubuntu1 validation commit:
  `2bbb5ed533a55af091b8571334325ffdb7971353`
- P4-B deletion:
  `ceb6624f9dd44430bf38a474f47ec2617ce34adb`
- P4-B evidence:
  `d0636908f4619710b09aa4856ac5d0069a2a6c05`

## Deletions and deltas

| Batch | Scope | Files removed | Measured result |
|---|---|---:|---|
| P4-A | Duplicate/unreferenced `docs/images` assets | 23 | Tracked docs images: 62 -> 39 |
| P4-B | Stale root `.idea` metadata | 20 | Tracked `.idea` files: 20 -> 0 |

Tracked repository files were 2,252 before P4-B and 2,233 after the merged
Phase 4 branch state, a net reduction of 19 files after accounting for
evidence additions. Git object storage is not a meaningful source-size
measure because repository history retains deleted content.

## Validation

- P4-A D1: local checks passed; Ubuntu1 fixed D1 validation passed 23/23.
- P4-B D4: candidate-specific checks passed; stricter D2 retained-closure
  validation reached Core build successfully, then reproduced the
  baseline-equivalent TS2322 type-identity failure.
- P4-B was accepted only under the operator-approved waiver. The failure is
  not represented as a green retained-closure result.
- Deferred and protected surfaces remain: `extensions/vscode`, `binary`,
  `docs-site`, `media` where referenced, `sync`, `core/vendor`, model assets,
  retained CLI/Core/package source, CI, legal, and publication files.
- No additional eligible candidate remains in the bounded reconciliation.

## Next prerequisite

Resolve or formally re-baseline Core TS2322 before any later D2, D3, or D4
deletion batch relies on the full retained-closure matrix. Any new candidate
requires a new classification, evidence, and approval.
