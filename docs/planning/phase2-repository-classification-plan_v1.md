# Phase 2 Repository Classification Plan v1

**Status:** Ready for classification work; product deletion remains **NO-GO** until the applicable batch approval gate passes.  
**Supersedes:** `phase2-repo-classification-plan_v0.md` as the executable plan.  
**Review source:** `phase2-repo-classification-plan-review.md`

## Purpose

Classify every repository area as `Keep`, `Remove`, `Defer`, or `Unknown` before
performing reduction work. Each `Remove` decision must be supported by a narrow,
reversible experiment and post-change validation.

`RED` means **Reduction Execution and Deletion**. It is not a TDD red/green
status.

## Authoritative entry checkpoint

The canonical local tags have been restored at the immutable commit references
recorded by the evidence:

| Reference | Commit | Evidence |
|---|---|---|
| Phase 0 source checkpoint | `4d23fa08f4416b3ac81ef6fb9d8cb7b6a58339c9` | `docs/reduction/phase0-cli-core-complet.md` |
| RED-001 clean-install checkpoint | `d3afd7522d0462fdfe2d15f5d9ae8701923a1556` | `docs/reduction/red-001-core-lockfile-integrity.md` |

Do not use an untagged working tree or an unrelated branch as the Phase 2
baseline. The tags are local readiness references and must be included in the
review/approval record if they are published or shared.

The RED-001 baseline is Node.js `24.19.0`, npm `11.17.0`, Linux x86_64,
registry `https://registry.npmjs.org/`, and
`npm ci --ignore-scripts --no-audit --no-fund`. Evidence from other toolchains
is historical and must not be used for direct pass/fail or timing comparisons.

## Baseline acceptance and known limitation

The retained closure is the package-specific matrix in
`docs/reduction/artifacts/phase1/retained-closure-install-matrix.md`, not root
scripts. Run the six retained packages, Core, and CLI using their recorded
install/build/typecheck/smoke commands.

The broader Core Jest suite is not a clean baseline: RED-001 recorded 10 failing
suites and 19 failing tests, including credential-dependent provider failures
and the Puppeteer CommonJS/ESM issue. These are accepted only as explicitly
documented exceptions. A classification batch must not report the broader suite
as passing.

The existing Core public-import gap is a known baseline limitation. It remains
documented unless a separately approved API remediation changes it; it is not,
by itself, a reason to fail an otherwise valid classification experiment.

## Current readiness blockers

The plan is structurally ready, but RED execution is not yet approved in this
checkout:

- The pinned RED-001 runtime is Node.js `24.19.0`; the current host is running
  Node.js `26.7.0`, and the runtime boundary check correctly fails the version
  assertion even though the mock workflow and denied-boundary checks pass.
- `packages/continue-sdk/package.json` and
  `packages/continue-sdk/typescript/package.json` both lack a `version`, so
  `npm pack --dry-run` cannot inspect either local package. This is a packaging
  evidence blocker, not evidence that the source is removable.
- The retained-closure matrix remains the RED-001 evidence baseline until it is
  rerun under the pinned Node.js 24.19.0 environment.

Do not classify Batch A as `Remove` until these blockers have either been
resolved or explicitly waived with an owner, review point, and deletion impact.

## Classification record

Create one record for every package, major directory, entry point, generated
artifact category, CI/release job, and publication or legal surface.

Required fields:

| Field | Requirement |
|---|---|
| ID | Stable identifier |
| Candidate | Exact path, package, script, workflow, or asset group |
| Type | Package, app, executable, script, asset, test, CI, docs, config, generated output, or metadata |
| Classification | `Keep`, `Remove`, `Defer`, or `Unknown` |
| Closure role | Runtime, build, test, packaging, release, legal/docs, development-only, or unrelated |
| Product surface | CLI/Core, VS Code, GUI/web, shared, docs, packaging, or unrelated |
| Owner and decision trigger | Required for `Defer` and `Unknown` |
| Hypothesis | What remains true if the candidate is removed |
| Static/dynamic/bundle/runtime evidence | Exact paths and findings |
| Publication/legal evidence | `npm pack --dry-run`, workflows, license, attribution, or N/A |
| Pre/post commands | Copy-and-paste commands with expected results |
| Full regression suite | Applicable retained-closure commands |
| Lockfile expectation | Unchanged, approved change, or prohibited |
| Result and reviewer | Pass/fail/blocked/deferred, reviewer, and ISO-8601 date |

No candidate may be classified `Remove` solely because it is absent from a
static import search.

## Required evidence layers

Every experiment must cover the applicable layers:

1. **Static:** manifests, lockfiles, workspace membership, TypeScript
   references and aliases, imports, dynamic loaders, scripts, CI, release,
   documentation, legal, and publication references.
2. **Build:** package-specific install, build, typecheck, declarations, entry
   points, generated output, and lockfile integrity.
3. **Bundle:** `extensions/cli/dist/meta.json` inputs, externalized runtime
   dependencies, generated assets, and wrapper inputs.
4. **Runtime:** controlled headless workflow, module resolution, runtime file
   accesses, child processes, configuration paths, exit code, and stable output.
5. **Behavior:** configuration parsing, Core initialization, adapter/provider
   behavior, terminal security, CLI smoke, headless characterization, and
   relevant package tests.
6. **Repository:** stale references, workspace/scripts/CI/release entries,
   package metadata, licenses, attribution, diff, file count, and repository size.

For publishable packages, include `npm pack --dry-run` or the package-equivalent
inspection whenever publication remains in scope.

## Experiment workflow

For each candidate:

1. Create the classification record.
2. State one removal hypothesis and its disconfirming conditions.
3. Capture the pre-change evidence and baseline artifacts.
4. Make one narrow experiment commit.
5. Run the focused post-change check.
6. Run the full applicable retained-closure matrix.
7. Compare lockfiles, bundle metadata, runtime reports, package identity, and
   repository references.
8. Review the diff for unrelated changes.
9. Mark `Pass`, `Fail`, `Blocked`, or `Deferred`.
10. Keep only a passing experiment; revert failed experiments with ordinary Git.

## Experiment order

1. Local SDK-generator source.
2. GUI/web surface.
3. Unrelated applications, demos, examples, and prototypes.
4. Docs-site and marketing assets.
5. Generated and vendored assets.
6. Surface-specific tests and CI.
7. Workspace and metadata cleanup.

VS Code, binary packaging, publication configuration, and vendor/model assets
must receive authoritative `Defer` or `Unknown` records even when they are not
part of the first CLI/Core removal closure.

## Batch A: local SDK-generator classification

### Candidate identity

The local directory is **not** a package named `@continuedev/continue-sdk`.

| Item | Actual identity |
|---|---|
| Local directory | `packages/continue-sdk` |
| Local package manifest | `@continuedev/sdk-generator` |
| Installed CLI dependency | `@continuedev/sdk@^0.0.13` |
| Installed package lock entry | `extensions/cli/package-lock.json` → registry `@continuedev/sdk` |
| Local generated client | `packages/continue-sdk/typescript` → `@continuedev/sdk` |

The Batch A candidate is therefore:

```text
CLASS-SDKGEN-001
RED-002-local-sdk-generator-source
packages/continue-sdk
Initial classification: Unknown
```

The experiment concerns removal of the **local SDK-generator source tree**, not
removal of the installed `@continuedev/sdk` dependency. The CLI currently
imports `@continuedev/sdk` in runtime and type positions, including
`extensions/cli/src/continueSDK.ts`, `ConfigService.ts`, `configLoader.ts`,
`CLIPlatformClient.ts`, and UI/service types.

### Removal hypothesis

Removing `packages/continue-sdk` will not affect the retained CLI/Core closure
because the CLI resolves `@continuedev/sdk` from its installed registry package,
not from the local generator directory, and no retained build, runtime,
packaging, release, legal, or attribution path requires the local generator.

### Pre-experiment identity checks

Run from the repository root without deleting files:

```bash
git status --short
cat packages/continue-sdk/package.json
cat packages/continue-sdk/typescript/package.json
git grep -nE \
  '(@continuedev/sdk|@continuedev/sdk-generator|packages/continue-sdk|continue-sdk)' \
  -- ':!**/node_modules/**' ':!docs/reduction/artifacts/**'
```

Inspect all relevant manifests and lockfiles for:

```text
file:, workspace:, relative, tarball, alias, lifecycle, build, pack, publish,
release, CI, documentation, license, NOTICE, and attribution references.
```

From `extensions/cli`, verify the installed package identity:

```bash
cd extensions/cli
npm ls --all --depth=2 @continuedev/sdk
node --input-type=module -e \
  "console.log(await import.meta.resolve('@continuedev/sdk/package.json'))"
cd ../..
```

Record the resolved path, version, and whether it points into
`packages/continue-sdk`. Do not run resolution checks for the nonexistent
specifier `@continuedev/continue-sdk`.

Inspect the local generator package separately:

```bash
find packages/continue-sdk -maxdepth 3 -type f \
  \( -name package.json -o -name package-lock.json -o -name tsconfig.json \
     -o -name README.md -o -name openapi.yaml \) -print | sort
npm --prefix packages/continue-sdk pack --dry-run
npm --prefix packages/continue-sdk/typescript pack --dry-run
```

### Bundle and runtime checks

Build the CLI from the approved checkpoint and inspect its actual metafile:

```bash
cd extensions/cli
npm run build
cd ../..
node - <<'NODE'
const fs = require("fs");
const meta = JSON.parse(fs.readFileSync("extensions/cli/dist/meta.json", "utf8"));
const inputs = Object.keys(meta.inputs || {});
const matches = inputs.filter((p) =>
  p.includes("packages/continue-sdk") ||
  p.includes("@continuedev/sdk-generator")
);
console.log(JSON.stringify({ inputCount: inputs.length, matches }, null, 2));
NODE
```

Run the existing runtime boundary check and archive the resulting files under
the current RED-001 evidence directory. Do not assume a
`docs/reduction/artifacts/phase0/boundaries/runtime.json` path exists:

```bash
node tests/characterization/boundary-check.mjs
node tests/characterization/runtime-boundary-check.mjs
```

The runtime evidence must state whether any resolved module or filesystem path
includes `packages/continue-sdk`, and whether the CLI loads
`@continuedev/sdk` from `node_modules`.

### Decision gate before deletion

Do not delete the local directory unless all are true:

- no retained manifest, alias, workspace, or file dependency targets its source;
- `@continuedev/sdk` resolves to the installed package and not the local tree;
- the CLI bundle has no local generator inputs;
- runtime resolution and file-access evidence has no local generator path;
- package packing, release, CI, docs, license, and attribution obligations are
  classified;
- the retained-closure baseline and documented exceptions are captured; and
- a reviewer approves `CLASS-SDKGEN-001` as `Remove`.

Any unresolved item remains `Unknown` or becomes `Defer`; it is not a deletion
approval.

### Narrow experiment

Only after the decision gate passes:

```bash
git switch -c reduce/remove-local-sdk-generator
git rm -r packages/continue-sdk
git grep -nE \
  '(@continuedev/sdk-generator|packages/continue-sdk)' \
  -- ':!**/node_modules/**' ':!docs/reduction/artifacts/**' || true
git commit -m "chore(reduction): test removal of local SDK generator"
```

Do not remove or rewrite `@continuedev/sdk` imports in this batch. Removing the
installed SDK or refactoring CLI/Core API coupling is a separate experiment.

### Batch A acceptance

Accept only if the same package-specific retained-closure matrix passes, the
CLI smoke and headless workflow pass, boundary checks pass, no stale local
generator references remain, package identity remains unchanged, publication
and legal checks pass, and the diff is independently revertible.

If any check fails:

```bash
git revert <experiment-commit-sha>
```

Update the classification record to `Keep`, `Defer`, `Unknown`, or `Blocked`
with the exact failure and owner.

## Approval gate

Product deletion remains **NO-GO** until:

1. the authoritative checkpoint commit and references are established;
2. the selected environment is recorded;
3. the package identity and resolution checks for Batch A pass;
4. documented RED-001 exceptions are carried into the batch record; and
5. the Batch A classification experiment receives explicit approval.
