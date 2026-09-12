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

## Required small corrections before tagging

### 1. Narrow the RED entry authorization

The current text says:

> “RED may begin only from `phase0-cli-core-complete`.”

That is correct as a branch/control point, but ambiguous about whether arbitrary deletion is now authorized.

Replace it with:

> RED work may begin only from `phase0-cli-core-complete`. The first RED batch is limited to restoring Core immutable-install integrity. Product-surface deletion, relocation, or workspace removal may begin only after `cd core && npm ci --ignore-scripts --no-audit --no-fund` succeeds and the Phase 0 Core build, typecheck, characterization, and boundary commands remain passing.

This is important because the original reduction verification requires a clean dependency install. The Core lockfile mismatch means the dependency closure is not yet proven reproducible.

---

### 2. Record the exact completion commit and annotated tag verification

The completion reference still says:

> “Created after committing this completion record”

Before approval, replace that with the actual immutable commit reference:

| Reference                  | Commit                                     | Verification                                      |
| -------------------------- | ------------------------------------------ | ------------------------------------------------- |
| `phase0-source-baseline`   | `a96202f57d650a4e42cc747d705e4d0e0ea24bf5` | `git rev-parse phase0-source-baseline^{commit}`   |
| `phase0-cli-core-complete` | `<actual committed SHA>`                   | `git rev-parse phase0-cli-core-complete^{commit}` |

Also record:

```bash
git tag -v phase0-cli-core-complete
git show --no-patch --decorate phase0-cli-core-complete
git status --short
```

The final status should be clean, and the tag must resolve to the commit containing:

- this completion record,
- inventories,
- characterization fixtures,
- boundary scripts,
- reports or reproducible report-generation instructions.

---

### 3. Normalize artifact paths

The record uses both:

- `artifacts/phase0/`
- `docs/reduction/artifacts/phase0/`

Use one canonical repository-relative path everywhere. Based on the artifact index, the canonical path appears to be:

```text
docs/reduction/artifacts/phase0/
```

Likewise, replace the ambiguous test reference:

```text
../../tests/characterization/
```

with its repository-relative path, for example:

```text
tests/characterization/
```

This matters because Phase 6 needs to rerun or compare the same evidence without guessing relative paths.

---

### 4. Clarify artifact provenance for source measurements

The source measurement table says the source archive excludes ignored artifacts, while the CLI bundle measurement references:

```text
extensions/cli/dist/index.js
```

State whether `dist/index.js` and `dist/meta.json` are:

- tracked in `phase0-source-baseline`,
- generated after checkout using the recorded build command, or
- measured from a separate baseline build worktree.

Suggested clarification:

> CLI bundle size and bundle-input count were measured after rebuilding the CLI from a clean checkout of `phase0-source-baseline` using the recorded Node/npm environment. They are build-output measurements, not `git archive` contents.

That makes the size baseline reproducible.

---

### 5. Make the Core-lockfile repair batch explicit

The first RED remediation should have a tightly scoped hypothesis:

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

## Final approval condition

Approve and tag `phase0-cli-core-complete` only after the completion record is committed with:

1. the exact tag commit SHA,
2. canonical artifact and test paths,
3. clarified bundle-measurement provenance, and
4. the narrowed RED authorization stating that **only Core lockfile integrity remediation may occur first**.

After that, Phase 0 is a valid, reversible characterization baseline. The repository is **not yet eligible for product-surface deletion** until Core’s immutable install succeeds and the baseline validation suite remains green.
