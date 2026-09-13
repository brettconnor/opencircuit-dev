# Phase 4 post-merge validation

Date: 2026-09-13
Merged commit: `d1e559779aadd669de00416b686a4bc21090016a`
Branch: `main`
Validation host: Ubuntu1 (`10.1.141.9`)
Runtime: Node.js `v24.19.0`

## Result

The approved post-merge retained-closure matrix was run with:

```text
open-circuit-runner.sh --branch main --phase1-red
```

The result is **blocked by the approved retained-Core validation waiver**:

| Matrix row | Result |
|---|---|
| config-types | Pass |
| fetch | Pass |
| llm-info | Pass |
| terminal-security | Pass |
| config-yaml | Pass |
| openai-adapters | Pass |
| core | Fail — pre-existing TS2322 during `npm run tsc:check` |
| extensions/cli | Not reached because the fixed matrix stops at first failure |

The failure is the same Core nominal type-identity clash documented during
P4-B validation. It occurs after a successful Core build, reproduces from a
fresh `core/dist`, and is unrelated to the Phase 4 deletions. Node.js matched
the pinned target, and all six package rows preceding Core passed.

## Merge-closeout decision

The Phase 4 deletion work is present on `main` at the merged commit above.
The operator-approved waiver remains limited to this known retained-Core
baseline failure; it does not waive candidate evidence or authorize further
deletion. Phase 4 remains closed at its continuation gate.

Rollback remains ordinary Git revert of the Phase 4 merge commit if required.
