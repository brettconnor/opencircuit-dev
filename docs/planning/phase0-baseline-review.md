## Review outcome: conditionally complete as a characterization baseline

This record is substantially complete and provides the evidence needed to begin controlled remediation work. It clearly distinguishes:

- the original source baseline,
- the reviewed Phase 0 evidence state,
- accepted baseline defects,
- deterministic CLI/Core characterization results, and
- the future clean-install requirement.

However, it should **not** claim unconditional “clean-install parity” or full Phase 0 completion against the original build contract while Core fails `npm ci`.

### Recommended status wording

> **Phase 0 characterization baseline: complete with an accepted clean-install exception.**
>
> RED may begin from `phase0-cli-core-complete` only for a first remediation batch whose explicit purpose is to repair `core/package-lock.json` and restore immutable Core installation.
>
> No deletion batch may begin until that remediation passes the full Phase 0 install/build/test/boundary comparison.

That preserves the value of the completed baseline without treating the known Core install failure as resolved.

---

## Correction resolution

The corrections below were applied before `phase0-cli-core-complete` was created.

### 1. Narrow the RED entry authorization

The earlier text said:

> “RED may begin only from `phase0-cli-core-complete`.”

That is correct as a branch/control point, but ambiguous about whether arbitrary deletion is now authorized.

It was replaced with:

> RED work may begin only from `phase0-cli-core-complete`. The first RED batch is limited to restoring Core immutable-install integrity. Product-surface deletion, relocation, or workspace removal may begin only after `cd core && npm ci --ignore-scripts --no-audit --no-fund` succeeds and the Phase 0 Core build, typecheck, characterization, and boundary commands remain passing.

This is important because the original reduction verification requires a clean dependency install. The Core lockfile mismatch means the dependency closure is not yet proven reproducible.

---

### 2. Record and verify the completion commit

The earlier completion reference said:

> “Created after committing this completion record”

The final immutable references are:

| Reference                  | Commit                                     | Verification                                      |
| -------------------------- | ------------------------------------------ | ------------------------------------------------- |
| `phase0-source-baseline`   | `a96202f57d650a4e42cc747d705e4d0e0ea24bf5` | `git rev-parse phase0-source-baseline^{commit}`   |
| `phase0-cli-core-complete` | `4d23fa08f4416b3ac81ef6fb9d8cb7b6a58339c9` | `git rev-parse phase0-cli-core-complete^{commit}` |

Verify the annotated tag and worktree with:

```bash
git cat-file -t phase0-cli-core-complete
git rev-parse phase0-cli-core-complete^{commit}
git show --no-patch --decorate phase0-cli-core-complete
git status --short
```

`git cat-file -t` must report `tag`, the resolved commit must be `4d23fa08f4416b3ac81ef6fb9d8cb7b6a58339c9`, and the final status should be clean. The tag resolves to the commit containing:

- this completion record,
- inventories,
- characterization fixtures,
- boundary scripts,
- reports or reproducible report-generation instructions.

---

### 3. Normalize artifact paths

The earlier record used both:

- `artifacts/phase0/`
- `docs/reduction/artifacts/phase0/`

The completion record now uses this canonical repository-relative path:

```text
docs/reduction/artifacts/phase0/
```

The ambiguous test reference:

```text
../../tests/characterization/
```

was replaced with:

```text
tests/characterization/
```

This matters because Phase 6 needs to rerun or compare the same evidence without guessing relative paths.

---

### 4. Clarify artifact provenance for source measurements

The source measurement table distinguishes the source archive from the generated CLI bundle measurement:

```text
extensions/cli/dist/index.js
```

The final clarification states:

> CLI bundle size and bundle-input count were measured after rebuilding the CLI from a clean checkout of `phase0-source-baseline` using the recorded Node/npm environment. They are build-output measurements, not `git archive` contents.

That makes the size baseline reproducible.

---

### 5. Make the Core-lockfile repair batch explicit

The first RED remediation now has this tightly scoped definition:

| Item                | Required definition                                                                                                                                                                |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Batch               | `RED-001-core-lockfile-integrity`                                                                                                                                                  |
| Hypothesis          | Regenerating and committing `core/package-lock.json` from the current Core manifest will allow immutable installation without changing intended runtime dependencies unexpectedly. |
| Allowed changes     | `core/package-lock.json`; dependency metadata only if proven required; baseline evidence updates.                                                                                  |
| Disconfirming check | `cd core && npm ci --ignore-scripts --no-audit --no-fund` succeeds from no `node_modules`, with no post-install tracked-file changes.                                              |
| Regression checks   | Core typecheck/build, CLI typecheck/build, all characterization tests, static/emitted/runtime boundary checks.                                                                     |
| Prohibited changes  | Product deletion, workspace removal, Core API refactor, CLI behavior changes, VS Code changes.                                                                                     |
| Rollback            | Revert the `RED-001` commit(s) or reset a local worktree to `phase0-cli-core-complete`.                                                                                            |

After `RED-001` succeeds, create a new tag or recorded checkpoint before beginning deletion work, such as:

```text
red-001-core-clean-install
```

---

## Evidence strengths

The record has several strong properties:

- It explicitly documents the **63 CLI→Core production import declarations** instead of hiding the existing architecture.
- It correctly treats missing Core `main`, `types`, and `exports` fields as a **target-architecture gap**, not an invented baseline failure.
- It separates successful package installs from the failed Core immutable install.
- It preserves lockfile integrity evidence through before/after SHA-256 values.
- It has deterministic non-editor validation through `cn -p` with a loopback mock transport.
- It uses all three required boundary evidence layers:
  - source-level/static,
  - emitted bundle/metafile,
  - runtime module resolution.
- It identifies the Node version deviation and engine warnings rather than presenting the environment as fully pin-compliant.

---

## Final verification

The completion record was committed and tagged after:

1. recording the completion commit through the immutable tag,
2. canonical artifact and test paths,
3. clarified bundle-measurement provenance, and
4. the narrowed RED authorization stating that **only Core lockfile integrity remediation may occur first**.

Phase 0 is therefore a valid, reversible characterization baseline. The repository is **not yet eligible for product-surface deletion** until Core’s immutable install succeeds and the baseline validation suite remains green.
