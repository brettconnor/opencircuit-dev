## 1. Phase 2 v0 review: gaps and approval readiness

### Overall outcome

**NO-GO for product deletion remains appropriate.** The plan is well structured and correctly treats deletion as a reversible, evidence-backed experiment. It is ready to guide classification work after a few corrections.

### Required corrections

| Priority | Finding | Required correction |
|---|---|---|
| High | Phase 2 says `red-001-core-clean-install` is the entry checkpoint, but earlier records name the remediation batch `RED-001-core-lockfile-integrity`. | Use one canonical checkpoint/tag name and record its exact commit SHA. Recommended: `red-001-core-clean-install`. |
| High | The baseline command block assumes root scripts (`npm run build`, `npm run tsc:check`, `npm test`) represent the retained closure. Earlier evidence establishes package-specific installs and builds. | Replace the generic root command block with the approved per-package install/build/typecheck matrix. Root commands may be supplementary only. |
| High | “Every repository area has one authoritative classification” is too broad if VS Code and binary packaging are intentionally deferred. | Require an authoritative classification record for every area, but permit `Defer` and `Unknown` with named owner, evidence, and decision trigger. |
| High | Batch A proposes physically removing `packages/continue-sdk` before proving local versus installed package identity and package-manager resolution. | Require a pre-experiment identity check: manifest specifiers, `npm ls`, `require.resolve`/ESM resolution, lockfile entries, bundle metafile, and runtime resolution evidence. |
| Medium | The plan requires a “standalone Core import workflow” while Core’s declared public package export remains absent. | Treat this as a target-invariant / known baseline limitation unless `red-001` or another approved remediation adds a public export. Do not fail classification solely for the current API gap. |
| Medium | “Puppeteer/module-resolution failures are resolved or explicitly blocked” is ambiguous. | Define “blocked”: exact failing command, responsible package, relevance to CLI/Core, owner, waiver expiration/review point, and whether it prevents product deletion. |
| Medium | The classification records do not explicitly distinguish a test-only dependency from a runtime dependency. | Add `Closure role`: runtime, build, test, packaging, release, documentation/legal, or development-only. |
| Medium | The plan correctly mentions publication workflows, but lacks a package/tarball inspection step. | Add `npm pack --dry-run` or the package-equivalent inspection for retained publishable packages, when package publishing remains in scope. |
| Low | “RED” is used as the deletion stage name but could be confused with TDD red/green terminology. | Define it once: **RED = Reduction Execution and Deletion**, or rename to `Reduction Batch`. |
| Low | Node/npm normalization says Phase 1 has mixed Node 24/26 evidence, while Phase 0 previously documented Node 20. | Record the authoritative selected environment and explain why prior evidence is non-comparable or superseded. Do not compare durations/results across environments without marking them as separate baselines. |

---

## 2. Revised plan: Phase 2 Repository Classification Plan v1

Suggested file:

```text
open-circuit/docs/planning/phase2-repository-classification-plan_v1.md
```

# Phase 2 Repository Classification Plan v1

## Purpose

Classify every repository component before reduction work as:

- `Keep`
- `Remove`
- `Defer`
- `Unknown`

Phase 2 uses specification-driven development and test-driven validation:

- classification records are the specification;
- dependency, build, bundle, runtime, and behavior checks are acceptance evidence;
- each deletion is a narrow, reversible experiment;
- no deletion is accepted without post-change validation.

Phase 2 does not authorize history rewriting, broad dependency upgrades, Core API redesign, or VS Code reduction.

## Definitions

| Term | Definition |
|---|---|
| **Retained closure** | The packages, configuration, scripts, generated artifacts, and metadata needed to install, build, typecheck, test, and run the CLI/Core product. |
| **Classification experiment** | One narrow, revertible change used to test whether a candidate is outside the retained closure. |
| **RED** | Reduction Execution and Deletion: approved, reversible reduction batches following classification. |
| **Disconfirming check** | A command or inspection that would prove the removal hypothesis false. |
| **Deferred surface** | A product surface intentionally retained for later evaluation but excluded from the first CLI/Core reduction closure. |

## Entry Conditions

Classification work begins only from the approved clean-install checkpoint:

```text
red-001-core-clean-install
```

The checkpoint must meet all of the following:

- [ ] It descends from `phase0-cli-core-complete`.
- [ ] Core immutable installation succeeds.
- [ ] The exact Core install command is recorded and passes.
- [ ] Retained package lockfiles are unchanged after approved installs.
- [ ] CLI/Core build, typecheck, smoke, characterization, static-boundary, emitted-bundle, and runtime-boundary tests pass.
- [ ] The selected Node.js and npm versions are recorded.
- [ ] The operating system, architecture, cache policy, registry policy, lifecycle policy, and network policy are recorded.
- [ ] Any Puppeteer or module-resolution issue is either resolved or recorded as a blocking exception.

### Blocking exception schema

An unresolved failure may be classified as blocked only when it has:

| Field | Requirement |
|---|---|
| ID | Stable identifier |
| Failing command | Exact copy-and-paste command |
| Failure type | Dependency, environment, network, credential, build, module resolution, or test |
| Affected surface | CLI/Core, VS Code, GUI/web, packaging, or unrelated |
| CLI/Core relevance | Required, not required, or undetermined |
| Owner | Named reviewer or role |
| Next action | Concrete evidence-gathering or repair action |
| Expiry/review point | Next batch, milestone, or date |
| Deletion impact | Blocks all deletion, blocks a named batch, or non-gating |

## Authoritative Environment

All Phase 2 comparisons use one declared toolchain.

| Item | Required recorded value |
|---|---|
| Checkpoint tag and commit | `red-001-core-clean-install` and exact SHA |
| Operating system | Exact distribution/version |
| Architecture | Exact architecture |
| Node.js | Exact version |
| npm | Exact version |
| Registry | Exact URL or approved mirror |
| Cache | Path and warm/cold policy |
| Lifecycle policy | Enabled or `--ignore-scripts`, with exceptions |
| Network policy | Disabled, registry-only, local loopback, or approved external |
| Credentials | None, mocked, or named credential-free mechanism |

Evidence captured under other Node/npm versions remains historical evidence only. It must not be used for direct timing or pass/fail comparison with the selected Phase 2 environment.

## Product Classification

### Keep

Keep components required by the validated CLI/Core closure:

- `extensions/cli` source, executable generation, runtime assets, tests, and build configuration;
- `core` source, build configuration, runtime assets, tests, and future public API boundary work;
- `packages/config-types`;
- `packages/config-yaml`;
- `packages/fetch`;
- `packages/llm-info`;
- `packages/openai-adapters`;
- `packages/terminal-security`;
- shared utilities proven necessary to CLI/Core;
- required TypeScript, test, build, workspace, and CI configuration;
- license, attribution, minimal README, build instructions, and focused smoke coverage.

### Remove after passing a classification experiment

Potential removal candidates include:

- GUI/web application code and browser-only tooling;
- local SDK source where installed/package-resolved SDK behavior is proven sufficient;
- demos, examples, prototypes, and unrelated applications;
- docs-site tooling and marketing assets not needed for retained operational docs, legal notices, or release workflows;
- reproducible generated outputs not needed for installation or runtime;
- vendored models/assets proven unnecessary;
- tests and CI jobs exclusively serving removed surfaces;
- workspace, script, lockfile, and metadata entries proven surface-specific.

### Defer

Defer components that are intentionally preserved outside the first CLI/Core closure:

- VS Code extension source and activation code;
- VS Code packaging, release configuration, tests, and documentation;
- Core-only publication configuration;
- binary packaging;
- vendor/model assets pending runtime filesystem analysis;
- docs-site and product publication material pending ownership review.

### Unknown

Use `Unknown` where any static, dynamic, packaging, runtime, generated-asset, legal, or publication dependency remains unproven.

An `Unknown` record requires:

- owner;
- exact follow-up command;
- expected evidence;
- due decision milestone;
- condition for conversion to `Keep`, `Remove`, or `Defer`.

## Classification Record Schema

Create one record for every repository package, major directory, entry point, generated artifact category, CI job, release workflow, and publication/doc surface.

| Field | Requirement |
|---|---|
| ID | Stable identifier, e.g. `CLASS-SDK-001` |
| Candidate | Exact repository-relative path, package name, script, asset group, or workflow |
| Type | Package, app, executable, script, asset, test, CI, docs, configuration, generated output, or metadata |
| Classification | `Keep`, `Remove`, `Defer`, or `Unknown` |
| Closure role | Runtime, build, test, packaging, release, legal/docs, development-only, or unrelated |
| Product surface | CLI/Core, VS Code, GUI/web, shared, docs, packaging, or unrelated |
| Removal hypothesis | What remains true if candidate is removed |
| Direct dependents | Exact packages, scripts, or workflows |
| Static evidence | Manifest, imports, TS references, aliases, scripts, CI, release configuration |
| Dynamic evidence | Dynamic imports, registries, config-selected modules, runtime file paths, child processes |
| Bundle evidence | `dist/meta.json` result and externalization status |
| Runtime evidence | Controlled workflow/module-resolution/filesystem report |
| Publication evidence | `npm pack --dry-run`, `files`, `.npmignore`, release workflows, or N/A |
| Pre-change check | Exact command and expected result |
| Allowed change | Exact permitted files/directories |
| Post-change check | Exact command and expected result |
| Full regression suite | Required retained-closure commands |
| Lockfile expectation | No change / expected change / prohibited |
| Rollback | Commit or tag to revert |
| Result | Pending, pass, fail, blocked, deferred |
| Reviewer | Reviewer and ISO-8601 date |
| Notes | Risks, exceptions, and follow-up |

## Mandatory Test Layers

Every classification experiment runs the applicable layers.

### Static layer

Review:

- manifests and lockfiles;
- workspace membership;
- TypeScript project references;
- path aliases;
- source imports and exports;
- dynamic imports and `require` calls;
- registries and configuration loaders;
- package lifecycle scripts;
- CI, release, and publishing workflows;
- documentation, legal, and attribution references.

### Build layer

Run the approved package-specific install/build/typecheck matrix. Check:

- generated outputs;
- entry-point resolution;
- declarations;
- aliases;
- project references;
- package metadata;
- lockfile integrity.

### Bundle layer

Inspect:

```text
extensions/cli/dist/meta.json
```

Confirm the candidate is not present as:

- a bundled source input;
- an externalized runtime dependency;
- a generated asset dependency;
- executable-wrapper input;
- package-resolved runtime file.

### Runtime layer

Run the controlled headless CLI workflow using a loopback/mock transport. Capture:

- exit code;
- stable output;
- normalized request data;
- module-resolution report;
- runtime file accesses;
- configuration paths;
- child-process invocations;
- unexpected network attempts.

### Behavior layer

Run applicable retained behavior tests:

- configuration parsing;
- Core initialization;
- model selection;
- adapter normalization;
- terminal-security coverage;
- CLI smoke test;
- controlled headless workflow;
- relevant package tests.

### Repository layer

Review:

- stale references;
- workspace entries;
- scripts;
- CI/release jobs;
- lockfiles;
- package metadata;
- legal notices and attribution;
- generated output;
- diff;
- file count;
- repository size.

## Classification Workflow

For each candidate:

1. Create the classification record.
2. State one removal hypothesis.
3. Identify direct dependents and possible dynamic/runtime loading paths.
4. Run and archive the pre-change checks.
5. Make one narrow experiment commit.
6. Run the focused post-change check.
7. Run the retained-closure regression suite.
8. Compare lockfiles, bundle metadata, runtime reports, and file accesses.
9. Inspect the diff for unrelated changes.
10. Mark the result:
   - `Pass`: removal hypothesis supported;
   - `Fail`: candidate is required or the experiment is invalid;
   - `Blocked`: missing evidence or a documented blocker;
   - `Deferred`: intentionally retained for a later product surface.
11. Retain the experiment commit only when it passes.
12. Revert failed experiments with an ordinary Git revert or reset local work to the pre-experiment commit.

## Experiment Order

1. **Batch A — Local SDK source**
   - Candidate: `packages/continue-sdk`
   - Requires identity and resolution evidence before deletion.

2. **Batch B — GUI/web surface**
   - Candidate: `gui/` and only GUI-proven scripts, CI, workspace, lockfile, and config.

3. **Batch C — unrelated applications, examples, demos, prototypes**
   - Small groups only; one classification record per independently removable area.

4. **Batch D — docs-site and marketing assets**
   - Separate legal/attribution, retained CLI operational docs, docs-site tooling, and promotional assets.

5. **Batch E — generated and vendored assets**
   - Requires generation source, clean-build evidence, runtime filesystem evidence, bundle evidence, and attribution review.

6. **Batch F — surface-specific tests and CI**
   - Only after related product surface has passed removal classification.

7. **Batch G — workspace and metadata cleanup**
   - Last; includes workspace declarations, scripts, CI matrices, release configuration, references, lockfiles, and docs links.

## Core Boundary Contract

Phase 2 preserves Core’s future reusable-library direction without requiring an API redesign.

Required baseline checks:

- CLI/Core source boundary checks pass;
- emitted-bundle checks pass;
- runtime module-resolution checks pass;
- Core does not load CLI, VS Code, GUI, browser, or extension activation code;
- existing CLI deep imports remain inventoried as known baseline coupling;
- missing declared public Core export metadata remains documented until a separately approved API remediation.

## Batch Acceptance Gate

A removal experiment passes only when:

- [ ] The classification record is complete.
- [ ] The removal hypothesis is supported.
- [ ] Focused behavior tests pass.
- [ ] Retained closure installation, build, and typecheck pass.
- [ ] CLI smoke and headless workflow pass.
- [ ] Static, emitted-bundle, and runtime boundary checks pass.
- [ ] No stale references remain.
- [ ] Lockfile changes are absent or explicitly justified.
- [ ] Licensing and attribution remain intact.
- [ ] Package publication inspection passes where relevant.
- [ ] The diff is focused and independently revertible.
- [ ] No unexplained failure remains.

## Phase 2 Exit Criteria

Phase 2 is complete when:

- every in-scope repository area has an authoritative classification record;
- every `Remove` candidate passed a reversible experiment;
- every `Defer` record identifies its preserved product surface;
- every `Unknown` record has an owner, action, and decision trigger;
- retained closure installation, build, and typecheck pass;
- deterministic CLI/Core behavior tests pass;
- provider tests are deterministic or explicitly non-gating;
- source, bundle, and runtime boundaries pass;
- legal, license, and attribution requirements remain satisfied;
- independent rollback commits exist;
- final package graph, workspace list, file count, and repository size are recorded.

## Approval Gate

**NO-GO for product deletion** remains in effect until:

1. the environment is normalized;
2. `red-001-core-clean-install` is validated; and
3. Batch A passes its classification experiment.

Every later deletion batch needs explicit approval based on its classification record, evidence artifacts, diff review, and revertible commit.

---

## 3. Copilot reconciliation checklist and prompt set

Suggested file:

```text
open-circuit/docs/planning/phase2-copilot-reconciliation-checklist_v0.md
```

# Phase 2 Copilot Reconciliation Checklist v0

## Operating rule

Copilot may identify candidates and summarize evidence. It does **not** approve classifications and does **not** establish that a component is safe to remove.

Repository evidence takes precedence over Copilot analysis.

## Required reconciliation record

| Field | Required value |
|---|---|
| Reconciliation ID | Example: `COP-CLASS-SDK-001` |
| Candidate | Exact repository path/package |
| Prompt scope | Exact files or directories supplied |
| Copilot claim | Concise stated conclusion |
| Copilot-cited evidence | Exact paths, scripts, symbols, imports |
| Human verification | Exact command or inspection |
| Result | Accepted, rejected, partial, unresolved |
| Classification impact | Record IDs/status changed |
| Reviewer | Name/role |
| Date | ISO-8601 date |

## Copilot review checklist

### Package and workspace review

- [ ] Identify package name, path, `main`, `types`, `exports`, `bin`, `files`, and scripts.
- [ ] Identify package manager and lockfile location.
- [ ] Identify local `file:`, workspace, relative-path, and packed/tarball dependencies.
- [ ] Identify all direct manifest consumers.
- [ ] Identify scripts that enter, build, pack, publish, or test the candidate package.
- [ ] Distinguish production, build, test, release, and development roles.

### Static import review

- [ ] Search ESM imports.
- [ ] Search CommonJS `require`.
- [ ] Search re-exports.
- [ ] Search TypeScript aliases/project references.
- [ ] Search string-based module names.
- [ ] Search path references in scripts and configuration.

### Dynamic/runtime review

- [ ] Identify `import(...)`.
- [ ] Identify dynamic `require`.
- [ ] Identify registries, plugin systems, provider selection, and config-selected loaders.
- [ ] Identify `fs` path reads that may target the candidate.
- [ ] Identify spawned processes or shell wrappers.
- [ ] Identify environment variables that alter candidate loading.

### Bundle review

- [ ] Compare candidate against `extensions/cli/dist/meta.json`.
- [ ] Check whether it is bundled, externalized, copied, generated, or loaded at runtime.
- [ ] Identify whether the candidate affects `cn.js`, `index.js`, package `bin`, or wrapper generation.

### Publication/legal review

- [ ] Check `files`, `.npmignore`, `.gitignore`, `prepack`, `prepare`, `postpack`, and publish scripts.
- [ ] Check license, copyright, NOTICE, attribution, and vendored dependency obligations.
- [ ] Check docs and release workflows for published references.

### Decision discipline

- [ ] Copilot did not infer “unused” from no static imports alone.
- [ ] Human verified every removal claim.
- [ ] Any contradiction is recorded as `Unknown` or `Blocked`.
- [ ] No secrets, tokens, internal endpoints, or proprietary config were supplied in prompts.
- [ ] Copilot did not generate a deletion command that was executed without an approved experiment record.

## File-scoped Copilot prompts

### A. Candidate classification

> Review only the listed files for candidate `<CANDIDATE>`. Determine its possible role in the CLI/Core closure: runtime, build, test, packaging, release, legal/docs, or unrelated. Cite exact paths, scripts, imports, export fields, and configuration references. Identify uncertainty explicitly. Do not conclude it is removable merely because static imports are absent. Return a table matching the Phase 2 classification schema.

### B. Package identity and resolution

> Analyze the manifests, lockfiles, build configuration, and import sites for `<PACKAGE_NAME>`. Determine whether CLI/Core resolves a local source package, an installed registry package, a workspace link, a file dependency, an alias, or a bundle-inlined copy. Cite every exact resolution mechanism. Do not suggest code changes.

### C. Dynamic-loading analysis

> Review the listed source files, build scripts, configuration loaders, registries, and filesystem operations. Identify all dynamic imports, dynamic require calls, module registries, config-selected modules, runtime file reads, child-process calls, and generated assets relevant to `<CANDIDATE>`. For each, state the trigger and the required human verification command.

### D. Bundle reconciliation

> Compare the supplied `extensions/cli/dist/meta.json` paths with the current classification inventory. Group paths by CLI, Core, approved local packages, VS Code, GUI/web, docs, generated assets, and unknown. Flag only findings supported by cited paths. Do not infer that an absent bundle input proves absence from build, packaging, or runtime dependencies.

### E. CI and publication review

> Review the supplied workflows, package scripts, and publication metadata for `<CANDIDATE>`. Identify whether it is referenced by CI, release, docs publication, package packing, or attribution obligations. Return cited evidence and unresolved questions; do not recommend deletion.

---

## 4. Classification-record template

Suggested location:

```text
open-circuit/docs/planning/templates/phase2-classification-record.md
```

# Classification Record: `<CLASS-ID>`

## Candidate

| Field | Value |
|---|---|
| ID | `<CLASS-ID>` |
| Candidate | `<repository-relative path / package / script / workflow>` |
| Type | `<package / app / executable / script / asset / test / CI / docs / config / generated output>` |
| Current classification | `<Keep / Remove / Defer / Unknown>` |
| Closure role | `<runtime / build / test / packaging / release / legal-docs / development-only / unrelated>` |
| Product surface | `<CLI/Core / VS Code / GUI-web / shared / docs / packaging / unrelated>` |
| Owner | `<name or role>` |
| Decision due | `<ISO-8601 date or milestone>` |

## Hypothesis

> Removing `<CANDIDATE>` will not affect the retained CLI/Core dependency closure, including approved installation, build, typecheck, package resolution, CLI smoke behavior, controlled headless workflow, bundle composition, runtime module resolution, legal notices, or publication requirements.

## Current evidence

### Direct dependents

| Dependent | Relationship | Evidence |
|---|---|---|
| `<path/package>` | `<runtime/build/test/etc.>` | `<manifest/import/script/CI evidence>` |

### Static evidence

| Source | Finding | Result |
|---|---|---|
| `<path>` | `<import, manifest field, script, TS reference, alias>` | `<supports / contradicts / unknown>` |

### Dynamic and runtime evidence

| Source | Trigger | Finding | Result |
|---|---|---|---|
| `<path>` | `<config/runtime action>` | `<dynamic loader/file access/process>` | `<supports / contradicts / unknown>` |

### Bundle evidence

| Artifact | Candidate present? | Details |
|---|---|---|
| `extensions/cli/dist/meta.json` | `<yes/no/unknown>` | `<input/externalized/generated path>` |

### Publication and legal evidence

| Source | Finding | Result |
|---|---|---|
| `<package.json / workflow / NOTICE>` | `<packing/publishing/license relation>` | `<supports / contradicts / unknown>` |

## Copilot reconciliation

| Field | Value |
|---|---|
| Reconciliation ID | `<COP-...>` |
| Prompt scope | `<exact files/directories>` |
| Copilot claim | `<summary>` |
| Copilot cited evidence | `<paths>` |
| Human verification command | `<copy-and-paste command>` |
| Human result | `<accepted / rejected / partial / unresolved>` |

## Pre-change baseline

| Check | Working directory | Command | Expected result | Artifact |
|---|---|---|---|---|
| Focused candidate check | `<dir>` | `<command>` | `<exit code and output>` | `<path>` |
| Retained closure baseline | `<dir>` | `<command>` | `<exit code and output>` | `<path>` |

## Allowed experiment change

Allowed:

```text
<exact candidate directories/files>
<exact scripts/config files if necessary>
```

Not allowed:

```text
Core API redesign
CLI behavior changes
VS Code reduction
Unrelated lockfile changes
Unrelated formatting/refactoring
History rewriting
```

## Post-change validation

| Layer | Command | Expected result | Artifact |
|---|---|---|---|
| Focused check | `<command>` | `<expected>` | `<path>` |
| Install | `<approved package-specific commands>` | `0; lockfiles unchanged unless approved` | `<path>` |
| Build | `<commands>` | `0` | `<path>` |
| Typecheck | `<commands>` | `0` | `<path>` |
| CLI smoke | `<command>` | `0; expected output` | `<path>` |
| Headless workflow | `<command>` | `0; deterministic output` | `<path>` |
| Static boundary | `node tests/characterization/boundary-check.mjs` | `0` | `<path>` |
| Bundle boundary | `<bundle report command>` | `0; candidate absent as required` | `<path>` |
| Runtime boundary | `node tests/characterization/runtime-boundary-check.mjs` | `0` | `<path>` |
| Repository checks | `<stale refs/license/diff commands>` | `0` | `<path>` |

## Lockfile and metadata review

| Item | Expected | Actual | Result |
|---|---|---|---|
| Root lockfile | `<unchanged/approved change>` | `<hash>` | `<pass/fail>` |
| Core lockfile | `<unchanged/approved change>` | `<hash>` | `<pass/fail>` |
| CLI lockfile | `<unchanged/approved change>` | `<hash>` | `<pass/fail>` |
| Candidate lockfile | `<unchanged/removed/approved change>` | `<hash>` | `<pass/fail>` |
| Workspace entries | `<expected>` | `<actual>` | `<pass/fail>` |
| Package metadata | `<expected>` | `<actual>` | `<pass/fail>` |

## Result

| Field | Value |
|---|---|
| Experiment commit | `<SHA>` |
| Result | `<Pass / Fail / Blocked / Deferred>` |
| Final classification | `<Keep / Remove / Defer / Unknown>` |
| Rollback | `<git revert SHA / checkpoint tag>` |
| Reviewer | `<name/role>` |
| Date | `<ISO-8601>` |
| Approval | `<approval reference>` |

## Notes and follow-up

- `<exception, known limitation, or next action>`

---

## 5. Batch A: `packages/continue-sdk` classification experiment

This draft assumes the candidate path is:

```text
packages/continue-sdk
```

Do **not** delete it until the identity/resolution evidence proves that the retained CLI/Core closure does not depend on the local source tree.

### Batch identity

```text
CLASS-SDK-001
RED-002-continue-sdk-source
```

### Initial classification

```text
Unknown
```

### Removal hypothesis

> The CLI/Core retained closure resolves and uses an installed, external, or bundled SDK implementation rather than `packages/continue-sdk` local source. Removing the local SDK source tree and only its proven surface-specific references will not change clean installation, build, bundle composition, CLI smoke behavior, or the controlled headless workflow.

### Disconfirming conditions

The hypothesis is false if any of the following is true:

- a retained manifest references `packages/continue-sdk` through `file:`, relative path, workspace, tarball, or alias;
- a retained source import resolves to local SDK source;
- a CLI/Core build script enters or builds the local SDK;
- the CLI metafile includes local SDK source;
- runtime resolution loads local SDK source;
- packaging, publishing, tests, release automation, or legal notices require the local SDK source;
- removing the candidate breaks retained closure validation.

---

### A. Pre-experiment evidence capture

Run from repository root. Adapt only where manifest/package naming differs; record any adaptation in the classification record.

#### 1. Create a dedicated branch

```bash
git switch red-001-core-clean-install
git status --short
git switch -c reduce/continue-sdk-classification
git rev-parse HEAD
```

Expected:

- clean working tree before branch creation;
- branch starts from the approved clean-install checkpoint.

#### 2. Identify SDK metadata and lockfile entries

```bash
find packages/continue-sdk -maxdepth 3 -type f \
  \( -name package.json -o -name package-lock.json -o -name tsconfig.json -o -name README.md \) \
  -print | sort

cat packages/continue-sdk/package.json
```

Then search all manifests and lockfiles:

```bash
find . \
  -path '*/node_modules/*' -prune -o \
  \( -name package.json -o -name package-lock.json \) -print0 |
  xargs -0 grep -nE \
  'continue-sdk|@continuedev/continue-sdk|file:.*continue-sdk|workspace:.*continue-sdk' \
  || true
```

Expected result:

- every retained reference is identified;
- no conclusion yet.

#### 3. Search static source, scripts, workflow, and documentation references

```bash
git grep -nE \
  '(@continuedev/continue-sdk|continue-sdk|packages/continue-sdk)' \
  -- \
  ':!**/node_modules/**' \
  ':!docs/reduction/artifacts/**' \
  || true
```

Classify each result by:

- retained CLI/Core runtime;
- retained CLI/Core build/test;
- VS Code/deferred;
- GUI/web/removable;
- docs/release/legal;
- unknown.

#### 4. Search aliases and TypeScript project references

```bash
git grep -nE \
  '(continue-sdk|paths"|references"|workspace)' \
  -- \
  tsconfig*.json \
  '**/tsconfig*.json' \
  package.json \
  '**/package.json' \
  '*.mjs' \
  '*.cjs' \
  '*.js' \
  || true
```

Also inspect actual candidate results in:

- root TypeScript configuration;
- Core TypeScript configuration;
- CLI TypeScript configuration;
- CLI build configuration;
- package build scripts.

#### 5. Inspect the CLI bundle metafile

First rebuild from the approved checkpoint:

```bash
cd extensions/cli
npm run build
cd ../..
```

Then search bundle inputs:

```bash
node - <<'NODE'
const fs = require("fs");
const meta = JSON.parse(fs.readFileSync("extensions/cli/dist/meta.json", "utf8"));
const inputs = Object.keys(meta.inputs || {});
const matches = inputs.filter((p) =>
  p.includes("packages/continue-sdk") ||
  p.includes("continue-sdk")
);
console.log(JSON.stringify({
  inputCount: inputs.length,
  matches
}, null, 2));
process.exitCode = matches.length ? 1 : 0;
NODE
```

Interpretation:

- exit `0`: no matching bundle inputs; this is supporting evidence only.
- exit `1`: candidate is bundled or represented in source inputs; do not delete.
- no result due to missing metafile: fix/record build evidence before proceeding.

#### 6. Inspect runtime resolution

Create a temporary, non-committed diagnostic only if the existing runtime-boundary harness cannot report package resolution. Prefer extending the existing report script in a committed, reviewable way.

At minimum, run:

```bash
node tests/characterization/runtime-boundary-check.mjs
```

Then inspect its report:

```bash
cat docs/reduction/artifacts/phase0/boundaries/runtime.json
```

or the current checkpoint’s equivalent artifact path.

Required evidence:

- whether any resolved module path includes `packages/continue-sdk`;
- whether the controlled `cn -p` workflow loads the SDK by package name or local path;
- whether it is externalized and resolved from `node_modules`.

#### 7. Confirm installed package identity

From each retained package that may consume the SDK—at least Core and CLI—run a resolution check.

CommonJS-compatible check:

```bash
cd core
node - <<'NODE'
try {
  console.log(require.resolve("@continuedev/continue-sdk/package.json"));
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
NODE
```

Repeat in CLI:

```bash
cd ../extensions/cli
node - <<'NODE'
try {
  console.log(require.resolve("@continuedev/continue-sdk/package.json"));
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
NODE
```

If the package is ESM-only or named differently, use the actual package specifier discovered from manifests/imports. Record:

- resolved path;
- package version;
- whether it points into `packages/continue-sdk`;
- whether it points into a package-manager install directory;
- whether it fails to resolve.

Also run package dependency views where applicable:

```bash
cd core && npm ls --all --depth=2 @continuedev/continue-sdk
cd ../extensions/cli && npm ls --all --depth=2 @continuedev/continue-sdk
```

A package resolving from `node_modules` does not alone prove that local SDK source is removable. It must agree with manifest, build, bundle, runtime, and packaging evidence.

---

### B. Pre-change validation suite

Run the approved retained-closure matrix from `red-001-core-clean-install`, not an assumed root-only script sequence.

At minimum:

```bash
cd packages/config-types && npm ci --ignore-scripts --no-audit --no-fund && npm run build
cd ../fetch && npm ci --ignore-scripts --no-audit --no-fund && npm run build
cd ../llm-info && npm ci --ignore-scripts --no-audit --no-fund && npm run build
cd ../terminal-security && npm ci --ignore-scripts --no-audit --no-fund && npm run build
cd ../config-yaml && npm ci --ignore-scripts --no-audit --no-fund && npm run build
cd ../openai-adapters && npm ci --ignore-scripts --no-audit --no-fund && npm run build

cd ../../core && npm ci --ignore-scripts --no-audit --no-fund
npm run tsc:check
npm run build

cd ../extensions/cli && npm ci --ignore-scripts --no-audit --no-fund
npm run typecheck
npm run build
npm run test:smoke

cd ../..
node tests/characterization/boundary-check.mjs
node tests/characterization/runtime-boundary-check.mjs
```

Run the controlled headless workflow using the exact approved test command from the current checkpoint—for example, if retained:

```bash
cd extensions/cli
npx vitest run --config vitest.e2e.config.ts src/e2e/headless-mock-llm.test.ts
```

Store output in a Batch A artifact directory:

```text
docs/reduction/artifacts/phase2/class-sdk-001/pre-change/
```

---

### C. Decision point before deletion

Classify the candidate as **Keep**, **Defer**, or proceed to a deletion experiment only if all of these are true:

- [ ] No retained manifest references local SDK source.
- [ ] No retained source imports or aliases resolve to local SDK source.
- [ ] No retained TypeScript project reference requires it.
- [ ] No retained build/lifecycle script requires it.
- [ ] It is absent from emitted CLI bundle inputs.
- [ ] It is absent from controlled runtime resolution and file-access reports.
- [ ] It is not required by package packing, publishing, CI, docs, legal, or attribution.
- [ ] The installed SDK package identity is confirmed where imports use an SDK package specifier.
- [ ] A reviewer approves `CLASS-SDK-001` as `Remove`.

If any item remains uncertain, leave the classification as `Unknown` or convert it to `Defer`. Do not delete.

---

### D. Narrow deletion experiment

Only after approval:

```bash
git status --short
git switch -c reduce/remove-continue-sdk-source
git rm -r packages/continue-sdk
```

Do not modify unrelated files initially.

Run stale-reference discovery:

```bash
git grep -nE \
  '(@continuedev/continue-sdk|continue-sdk|packages/continue-sdk)' \
  -- \
  ':!**/node_modules/**' \
  ':!docs/reduction/artifacts/**' \
  || true
```

If references remain:

- classify each reference;
- remove only references proven to be specific to the removed local source;
- do not replace imports or change behavior to force the experiment through;
- do not alter Core API or VS Code code in this batch.

Commit the narrow experiment:

```bash
git add -A
git commit -m "chore(reduction): test removal of local continue-sdk source"
```

---

### E. Post-change validation

Run the same approved retained-closure suite, then compare:

- lockfile hashes;
- package manifests;
- CLI bundle input count and matching SDK paths;
- runtime-resolution report;
- smoke-test output;
- controlled workflow output;
- git diff;
- tracked file count;
- repository size.

Additional post-change package resolution checks:

```bash
cd core
node - <<'NODE'
try {
  console.log(require.resolve("@continuedev/continue-sdk/package.json"));
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
NODE

cd ../extensions/cli
node - <<'NODE'
try {
  console.log(require.resolve("@continuedev/continue-sdk/package.json"));
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
NODE
```

Expected:

- resolved package identity stays unchanged or is intentionally documented;
- no resolved path points to the deleted local directory;
- all retained validation commands pass;
- no unexpected lockfile or manifest mutation occurs.

---

### F. Batch A acceptance decision

Accept removal only if:

- [ ] All pre-change evidence supports removal.
- [ ] The experiment is restricted to the candidate and proven candidate-specific references.
- [ ] Immutable installs remain successful.
- [ ] All required packages build and typecheck.
- [ ] CLI smoke and controlled headless workflow pass.
- [ ] Static, emitted-bundle, and runtime boundary checks pass.
- [ ] No stale local SDK references remain in retained CLI/Core scope.
- [ ] Packaging, CI, documentation, legal, and attribution checks pass.
- [ ] Diff review finds no unrelated changes.
- [ ] Ordinary Git revert remains sufficient rollback.

If any check fails:

```bash
git revert <experiment-commit-sha>
```

Then update `CLASS-SDK-001` to `Keep`, `Defer`, `Unknown`, or `Blocked` based on the evidence.
