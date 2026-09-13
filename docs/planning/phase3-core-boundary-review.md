## Review outcome: **NO-GO for Experiment Order Item 1 until key boundary and package-resolution assumptions are evidenced**

The plan is strong in intent and correctly treats the Core boundary as an architectural repair rather than a deletion pass. It also preserves the right discipline:

- classify before changing import contracts;
- retain reversible, one-batch-at-a-time work;
- preserve Phase 0/2 boundary regression checks;
- distinguish the known baseline from the target architecture.

However, Item 1 currently assumes that adding `main`, `types`, and `exports` to `core/package.json` is a zero-behavior-change declaration of existing behavior. That is not yet established and is technically risky.

The plan should be revised before approval.

---

# High-priority findings

## 1. `core` may be an alias, not a Node package specifier

The plan states that CLI imports such as:

```ts
import ... from "core";
import ... from "core/util/paths.js";
```

will become governed by `core/package.json` exports.

That only holds if `core` is a real Node package name that resolves through standard package resolution.

Your own evidence says the CLI currently resolves Core through:

- `extensions/cli/tsconfig.json` path aliases; and
- `extensions/cli/build.mjs` esbuild aliases.

That means `core` may be a source-tree alias rather than a resolvable package identity.

If so:

- Node does not necessarily consult `core/package.json`;
- TypeScript may resolve directly to source paths;
- esbuild may resolve directly to source paths;
- adding an `exports` map may have no effect on current CLI resolution;
- the proposed positive boundary check could incorrectly report compliance while the build still bypasses the package contract.

### Required correction

Add an explicit package-resolution discovery step before Item 1.

Record:

| Question | Required evidence |
|---|---|
| What is the Core package’s declared `name`? | `core/package.json` |
| Is `core` a package name, TypeScript alias, esbuild alias, or all three? | CLI tsconfig and build configuration |
| Does `node` resolve `core` from a consumer context? | Node resolution fixture |
| Does `node` resolve each candidate Core subpath? | Node resolution fixture |
| Does TypeScript resolve the same path? | `tsc --traceResolution` or equivalent |
| Does esbuild resolve the same path? | esbuild metafile or resolver evidence |
| Do all three resolve to equivalent intended artifacts? | Recorded comparison |

The correct target may require migration from `core` to the actual Core package name, for example:

```ts
@continuedev/core
```

or whatever `core/package.json.name` declares.

Do not assume the existing alias is a package-level API boundary merely because the import spelling looks package-like.

---

## 2. Item 1 prematurely promotes all 34 deep imports into a public API

The proposal says to explicitly export every currently used deep Core subpath first, then classify each one as `Promote`, `Relocate`, or `Investigate`.

That sequence formalizes all deep imports as public before deciding whether they belong in the public contract.

Even if intended as a temporary compatibility layer, explicit `exports` entries communicate:

- these paths are supported;
- their names are stable;
- consumers may depend on them;
- they are part of the declared Core package contract.

That conflicts with the plan’s stated goal of reducing undeclared coupling.

### Required correction

Reverse Items 1 and 2.

Recommended sequence:

1. **Item 0 — Resolve package identity and artifact mapping.**
2. **Item 1 — Classify all existing Core imports.**
3. **Item 2 — Define the minimum supported Core API surface.**
4. **Item 3 — Add package entry points and exports only for approved public paths.**
5. **Item 4 — Migrate CLI imports from deep paths to approved root/subpath exports or relocate CLI-owned functionality.**
6. **Item 5 — Add positive conformance enforcement.**
7. **Item 6 — Retire or split BND-001/BND-002 based on the actual remaining state.**

If a temporary compatibility export is necessary, name and document it as such:

```text
Compatibility-only exports
- Not recommended for new consumers
- Explicit owner
- Removal milestone
- Migration target
- Test coverage
```

Do not call those exports the final public Core surface.

---

## 3. The plan assumes `core/index.d.ts` is a valid declared package type entry

The plan says `main`, `types`, and `exports` can point at:

```text
core/dist/core.js
core/index.d.ts
```

But the plan also says:

> `core/index.d.ts` exists in source but has no corresponding build output or package entry point.

This needs proof before it becomes the declared `types` entry.

Potential problems include:

- `core/index.d.ts` may describe source-only paths not present in `dist`;
- it may reference undeclared deep source modules;
- it may not match the exports from `dist/core.js`;
- it may not be included in package output or package tarball;
- declaration maps or referenced declarations may not exist after a clean build;
- package consumers may get types from source while JavaScript comes from build output.

### Required correction

Add a generated-artifact compatibility check.

For every intended export, record:

| Export | Runtime target | Types target | Exists after clean build | Included in package tarball | Consumer import test |
|---|---|---|---:|---:|---:|
| package root | `<path>` | `<path>` | Yes/No | Yes/No | Pass/Fail |
| approved subpath | `<path>` | `<path>` | Yes/No | Yes/No | Pass/Fail |

Before declaring package metadata, verify:

```bash
cd core
rm -rf dist
npm run build

test -f dist/core.js
test -f <intended-types-path>
npm pack --dry-run
```

The exact declaration output should come from the current Core build, not an assumed source-tree declaration file.

---

## 4. `exports` can be breaking even when current aliases appear to work

The plan describes Item 1 as:

> “zero behavior change, purely making the existing coupling visible and versioned.”

That is not guaranteed.

Adding `exports` can change behavior for:

- Node consumers;
- package self-references;
- ESM/CommonJS resolution;
- TypeScript `node16`, `nodenext`, or `bundler` module resolution;
- subpath imports;
- package packing;
- consumers that use undeclared paths;
- runtime code that resolves files through `require.resolve`;
- tests that import Core directly rather than through CLI aliases.

Also, an `exports` map can block previously reachable package files even when those files exist.

### Required correction

Reword the hypothesis:

> Adding package entry metadata is a controlled resolution-change experiment, not a presumed no-op. The experiment is accepted only if package, TypeScript, esbuild, emitted bundle, and runtime resolution remain compatible for approved retained consumers.

Treat a failure as meaningful evidence, not merely an implementation inconvenience.

---

## 5. “CLI is the only consumer” is not proven by a CLI-only import inventory

The plan says:

> “The CLI is the only declared consumer of these deep paths.”

The evidence cited appears to be a CLI import inventory. That proves the CLI uses the paths; it does not prove that:

- VS Code does not use them;
- scripts do not use them;
- Core self-references do not use them;
- tests do not use them;
- generated code does not use them;
- package consumers in examples or tools do not use them;
- external consumers do not exist if Core has ever been distributed.

The plan also explicitly excludes VS Code from this phase. That exclusion is reasonable, but it means the “only consumer” claim must be narrowed.

### Required correction

Replace the claim with:

> Within the validated retained CLI/Core closure, the CLI is the only currently identified external consumer of the listed deep Core subpaths. Repository-wide and deferred-surface consumers must be searched before narrowing or removing any export.

Add a repository-wide consumer scan before removing a path from any compatibility map:

```bash
git grep -nE \
  'from ["'\'']core(/|["'\''])|require\(["'\'']core(/|["'\''])' \
  -- ':!node_modules' ':!docs/reduction/artifacts'
```

Also search the actual Core package name once identified.

VS Code does not need to be migrated in this phase, but it must be classified as:

- no consumer found;
- consumer found and deferred;
- consumer found and blocking a narrowing decision.

---

# Medium-priority findings

## 6. Retained-closure verification is incomplete

The per-batch verification list currently includes:

- CLI build;
- Core build/typecheck;
- boundary checks;
- runtime check;
- basic CLI smoke.

That is weaker than prior retained-closure validation because it omits:

- approved local package build/install verification;
- immutable package installation;
- controlled headless workflow;
- configuration parsing;
- adapter normalization;
- model selection/initialization;
- package-specific tests that prove Core behavior;
- lockfile integrity review.

A Core exports change can break dependency installation, type resolution, headless behavior, or local package build order without breaking `cn --version`.

### Required correction

Reuse the approved retained-closure matrix from the clean-install checkpoint.

At minimum, every boundary-changing batch should run:

- clean immutable installs for retained packages;
- approved local package builds;
- Core typecheck and build;
- CLI typecheck and build;
- CLI smoke test;
- controlled `cn -p` loopback workflow;
- config YAML parsing characterization;
- model initialization/selection characterization;
- adapter normalization characterization;
- static, bundle, and runtime boundary checks;
- lockfile hash comparison.

---

## 7. “Comparable bundle size” is not an auditable acceptance criterion

The plan says the CLI bundle must be of:

> “comparable bundle size”

This is useful as a heuristic but not a pass/fail rule.

A small facade can change bundle composition legitimately. A large change may be valid if a build mode changes. Conversely, a stable size does not prove behavior is preserved.

### Required correction

Use explicit reporting rather than an undefined threshold:

| Metric | Baseline | Post-change | Required action |
|---|---:|---:|---|
| `dist/index.js` bytes | `<baseline>` | `<value>` | Explain material variance |
| `dist/cn.js` bytes | `<baseline>` | `<value>` | Explain material variance |
| metafile input count | `<baseline>` | `<value>` | Explain material variance |
| Core input count | `<baseline>` | `<value>` | Explain material variance |
| deferred-surface input count | `0` | `<value>` | Must remain `0` |

Define “material variance” in advance, such as greater than 5% or a named input-set change. This should be a review trigger, not an automatic failure unless it affects the closure or boundary contract.

---

## 8. The positive boundary check needs a precise contract

The proposed check says:

> “assert that every CLI import of `core` resolves through a subpath declared in `core/package.json`’s `exports`.”

That is directionally correct but underspecified.

It needs to define:

- root package imports;
- subpath imports;
- `core/index.js` compatibility imports;
- TypeScript type-only imports;
- static imports;
- dynamic imports;
- CommonJS `require`;
- re-export declarations;
- source alias imports;
- built bundle inputs;
- package conditions such as `import`, `require`, `types`, and `default`;
- permitted temporary compatibility paths;
- whether source-tree aliases are allowed after the transition.

### Required correction

Define the conformance rule as:

> Every production CLI import whose resolved target is inside Core must use either:
>
> 1. the declared Core package root; or  
> 2. an explicitly approved Core package export subpath.
>
> No production CLI import may resolve to a Core filesystem path through a TypeScript or esbuild alias that bypasses the package export contract.

The check should produce:

```json
{
  "importer": "extensions/cli/src/example.ts",
  "specifier": "@scope/core/editing",
  "importKind": "static-import",
  "resolvedTarget": "core/dist/editing.js",
  "exported": true,
  "temporaryCompatibility": false,
  "result": "pass"
}
```

---

## 9. BND-001 and BND-002 should not be fully retired after metadata is added

Item 5 proposes retiring both exceptions after Items 1–3.

That is too early if:

- deep imports remain;
- temporary compatibility exports remain;
- Core still has no generated declarations;
- aliases still bypass package resolution;
- `Relocate` and `Investigate` items remain open;
- VS Code/deferred consumer impact remains unknown.

### Required correction

Split the exceptions.

Suggested replacement records:

| ID | Condition | Closure condition |
|---|---|---|
| `BND-001A` | Core had no declared package entry point | Close after package-root runtime/types exports are generated, packed, and consumer-tested |
| `BND-001B` | CLI uses undeclared Core subpaths | Close after every retained CLI Core import resolves through an approved export |
| `BND-001C` | CLI deep implementation imports remain | Close only after all deep imports are promoted, relocated, or explicitly retained as stable compatibility API |
| `BND-002` | Core package metadata lacks usable package API | Close after clean-build and packed-consumer tests prove `main`/`exports`/types behavior |

This preserves architectural truth rather than closing a finding administratively.

---

## 10. The plan needs package-consumer testing, not only monorepo testing

Since the purpose is a reusable Core library boundary, test Core as it would be consumed outside its source directory.

A monorepo alias build does not prove the package contract works.

### Required correction

Add a temporary package-consumer fixture:

1. Build Core.
2. Create a package tarball.
3. Install or link it into an isolated temporary fixture.
4. Import the package root and every approved public subpath.
5. Run both JavaScript runtime import and TypeScript typecheck.
6. Confirm undeclared subpaths fail as intended once compatibility exports are removed.

Conceptually:

```bash
cd core
npm run build
npm pack --json
```

Then use a temporary fixture outside the Core source tree. The exact install strategy should use the repository’s package manager and avoid modifying tracked manifests.

---

# Recommended revised experiment order

Replace the current order with the following.

## Item 0 — Package identity, resolution, and artifact mapping

No source changes.

Determine:

- Core package name;
- current CLI TypeScript alias;
- current esbuild alias;
- Node runtime behavior;
- generated JS output layout;
- generated declaration output layout;
- current package tarball contents;
- repository-wide deep-subpath consumers;
- runtime resolution behavior for CLI and standalone package consumer fixtures.

**Exit condition:** the team can state exactly what package specifier, artifact path, and resolver each consumer uses today.

---

## Item 1 — Import classification

No source changes.

Classify every CLI→Core import as:

- `RootPublicCandidate`
- `PublicSubpathCandidate`
- `CompatibilityOnlyCandidate`
- `RelocateToCLI`
- `MoveToSharedPackage`
- `Investigate`
- `Blocked`

Also record:

- importer;
- imported symbol;
- runtime/build/type-only role;
- test coverage;
- Core dependencies;
- editor/browser side effects;
- external/deferred consumers;
- proposed stable package path;
- migration priority.

**Exit condition:** all 63 imports have a reviewed classification.

---

## Item 2 — Define the minimum public API proposal

No source moves yet.

Produce a proposed API matrix:

| Current import | Proposed API path | Status | Reason |
|---|---|---|---|
| `core` | `<actual-core-package-name>` | Root export | Existing Core API |
| `core/util/paths.js` | `<actual-core-package-name>/paths` | Promote or compatibility | Shared path utility |
| `core/edit/searchAndReplace/performReplace.js` | `<actual-core-package-name>/editing` | Promote | Shared edit engine |
| `<CLI-specific item>` | `extensions/cli/...` | Relocate | CLI-only ownership |

**Exit condition:** only approved paths are proposed for permanent public export.

---

## Item 3 — Establish package root and packed consumer behavior

This is the first code/metadata experiment.

Add package metadata only for the Core root API that has a verified build and declaration artifact.

Validate:

- clean Core build;
- package tarball contents;
- isolated JavaScript consumer;
- isolated TypeScript consumer;
- existing CLI build and runtime;
- retained closure tests.

Do not add all deep exports yet.

---

## Item 4 — Migrate and expose one approved subpath group at a time

Examples of tightly related groups:

- path and URI utilities;
- message normalization utilities;
- token/cost accounting;
- search/replace editing subsystem;
- indexing ignore behavior.

For each group:

1. expose a stable package subpath or facade;
2. migrate CLI imports;
3. retain old path only as explicitly time-limited compatibility export if needed;
4. test package consumer and CLI behavior;
5. remove old compatibility path only in a separately approved batch.

---

## Item 5 — Relocate CLI-owned functionality

Move only items classified `RelocateToCLI` or `MoveToSharedPackage`.

Each batch must have:

- narrow ownership hypothesis;
- source and bundle evidence;
- controlled CLI workflow validation;
- no Core API regression;
- no unapproved VS Code/deferred breakage.

---

## Item 6 — Add positive boundary conformance enforcement

Once the actual package contract exists, add the check that rejects:

- Core filesystem aliases from production CLI code;
- undeclared subpath imports;
- new deep imports;
- unapproved compatibility imports after their expiry.

---

## Item 7 — Update and close findings accurately

Close only the portions actually resolved.

Keep compatibility, relocation, and deferred-surface findings open until their stated exit conditions are met.

---

# Suggested approval-gate replacement

Replace:

> Proceed with Experiment order item 1 (declare the existing surface as-is) once this plan is reviewed and approved.

With:

> Proceed only with Item 0: package identity, resolver, artifact-layout, package-tarball, and repository-wide consumer discovery. No `main`, `types`, `exports`, import-specifier, alias, or module-layout change is authorized until Item 0 and Item 1 evidence are reviewed.

---

# Overall assessment

The plan’s architectural direction is sound. The main correction is sequencing:

- **first prove how Core is currently resolved;**
- **then classify which imports deserve a contract;**
- **then expose only the intentional contract;**
- **then migrate and enforce it.**

Adding an `exports` map before those facts are proven risks converting a source-tree alias arrangement into a partially working package API while accidentally formalizing 34 internal paths as permanent public surface.
