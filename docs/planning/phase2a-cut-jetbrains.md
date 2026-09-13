# Phase 2a: Cut JetBrains Plugin Plan v1

**Status:** Ready for classification work; product deletion remains **NO-GO**
until the applicable batch approval gate passes.
**Supersedes:** N/A — this is a new, narrower follow-on to
`phase2-repository-classification-plan_v1.md`, opened after that plan's full
Experiment order (items 1-7) was executed and merged.
**Owner decision:** The repository owner has stated there are no plans to
support the JetBrains plugin. This plan authorizes classifying the entire
JetBrains surface as `Remove` and executing its removal as a sequence of
narrow, reversible RED batches, following the same workflow used in
`phase2-repository-classification-plan_v1.md`.

## Purpose

Classify and remove every repository surface whose sole purpose is building,
testing, releasing, or documenting the JetBrains (IntelliJ) plugin. Unlike
`phase2-repository-classification-plan_v1.md`, the removal hypothesis here is
given up front by the owner rather than derived from usage evidence — but
every candidate must still be verified as JetBrains-specific (not shared with
the retained CLI/Core/VS Code closure) before removal, and every experiment
must still be narrow, reversible, and independently verified.

`RED` means **Reduction Execution and Deletion**. It is not a TDD red/green
status.

## Relationship to prior work

This plan is opened after all 7 items in
`phase2-repository-classification-plan_v1.md`'s Experiment order were
executed and merged (Batches A-G). That plan's `docs/reduction/cli-core-dependency-inventory.md`
already flagged one JetBrains-adjacent item as `Unknown`:

> `.github/actions/build-vscode-extension/action.yml`,
> `.github/actions/run-jetbrains-tests/action.yml`,
> `.github/workflows/jetbrains-release.yaml`, and
> `extensions/vscode/scripts/prepackage.js` all still depend on `gui/` or
> `gui/dist` as part of the deferred VS Code/JetBrains packaging pipeline...
> recorded as `Unknown` pending a dedicated packaging-pipeline experiment.

This plan resolves that `Unknown` for the JetBrains-only portion of that
pipeline by removing it outright, rather than repairing it. The VS Code
portion of the shared `gui/dist` dependency (`build-vscode-extension`,
`extensions/vscode/scripts/prepackage.js`'s VS Code packaging path) is out of
scope here and remains `Defer`/`Unknown` under the original plan, since VS
Code support is not being cut.

## Candidate identity

The JetBrains plugin is not a single directory. It is a cross-cutting product
surface with five kinds of footprint:

| # | Category | Primary paths |
|---|---|---|
| 1 | Plugin source | `extensions/intellij/` (124 tracked files, ~820 KB: Kotlin/Gradle plugin source, `.run/` IDE run configs, `build.gradle.kts`, `gradlew`) |
| 2 | CI workflows | `.github/workflows/jetbrains-release.yaml` (full release/signing/publish pipeline); `.github/actions/run-jetbrains-tests/action.yml` (composite test action) |
| 3 | CI job wiring | `.github/workflows/pr-checks.yaml`'s `jetbrains-tests` job and its entry in `require-all-checks-to-pass`; `.github/workflows/auto-release.yml`'s `create-jetbrains-release` job |
| 4 | Secrets/build metadata | `BUILD_DEPENDENCIES.md`'s "JetBrains Extension" section (`APPLE_CERT_DATA`, `APPLE_CERT_PASSWORD`, `APPLE_NOTARY_USER`, `APPLE_NOTARY_PASSWORD`, `JETBRAINS_PUBLISH_TOKEN`, `JETBRAINS_CERTIFICATE_CHAIN`, `JETBRAINS_PRIVATE_KEY`, `JETBRAINS_PRIVATE_KEY_PASSWORD`) and the `jetbrains-release.yaml` references in its `CI_GITHUB_TOKEN` row |
| 5 | Contributor/product docs | `README.md` (`### JetBrains` section, ToC entry, intro sentence); `CONTRIBUTING.md` (`#### JetBrains` section, ToC entries, `GetTheme.kt` theme-color guidance); `docs/` product pages that list JetBrains as a supported IDE (out of scope for source removal — see below) |

### Explicitly out of scope

- **`docs/` and `docs-site/` product-facing content** (e.g. `docs/docs.json`'s
  `/install/jetbrains` redirect, IDE-selector mentions across `docs/**/*.mdx`)
  is **not** part of this plan. Cutting user-facing product documentation is a
  separate, larger decision (it affects existing JetBrains users reading
  published docs) and does not reduce build/CI/maintenance burden the way the
  source and CI removal does. Record these as `Defer` for a future,
  explicitly-scoped docs-content decision — do not delete them as part of any
  batch under this plan.
- **`docs/images/jetbrains-getting-started*.png`** — same reasoning; these
  illustrate the (out-of-scope) docs page. Leave alone.
- **The shared `gui/dist` VS Code packaging path** in
  `build-vscode-extension` and `prepackage.js` — VS Code support is not being
  cut; only the JetBrains-specific consumption of that pipeline is in scope.

### Pre-experiment identity checks (already performed for this plan)

```bash
git ls-files extensions/intellij | wc -l              # 124
du -sh extensions/intellij                              # 820K
grep -rln "extensions/intellij" core extensions/cli \
  extensions/vscode packages binary                     # 0 functional hits
grep -n "intellij" core/protocol/passThrough.ts core/rules.md
  # comments only, pointing at the Kotlin mirror of the shared
  # webview protocol - documentation, not a functional dependency
grep -rln "intellij\|jetbrains" .github                 # workflows listed above
grep -n -i "jetbrains" BUILD_DEPENDENCIES.md README.md CONTRIBUTING.md
```

No CLI, Core, VS Code, or package source imports anything from
`extensions/intellij/`. The only Core-side references are two source
comments noting that the webview message-protocol types are mirrored in the
Kotlin plugin — these are stale-after-removal documentation, not a build or
runtime dependency, and must be updated (not left dangling) as part of the
plugin-source removal batch.

## Removal hypothesis

Removing every JetBrains-specific path listed in "Candidate identity"
categories 1-4 will not affect the retained CLI/Core/VS Code closure, because:

- No retained package, script, or CI job outside the JetBrains-specific ones
  listed above resolves, imports, builds, or tests anything under
  `extensions/intellij/`.
- The two Core-side comments referencing Kotlin file paths are documentation
  only; no Core code executes or type-checks against them.
- `jetbrains-tests` and `create-jetbrains-release` are self-contained CI jobs
  with no downstream job depending on their *output* (only
  `require-all-checks-to-pass` depends on `jetbrains-tests`'s pass/fail
  status, and that dependency is removed in the same change).
- `BUILD_DEPENDENCIES.md`'s JetBrains secrets are consumed exclusively by
  `jetbrains-release.yaml`, which is itself being removed.

### Disconfirming conditions (would block or reverse a `Remove` classification)

- Any retained CLI/Core/VS Code build, test, or CI job fails after removal in
  a way traceable to the removed paths.
- A hidden reference to `extensions/intellij/`, `jetbrains-release.yaml`, or
  `run-jetbrains-tests` is found in a script, workflow, or config not yet
  enumerated above.
- The owner indicates JetBrains support should be paused/kept dormant rather
  than fully removed (in which case the correct classification is `Defer`,
  not `Remove`, and no deletion should proceed).

## Experiment order

Following the same one-candidate-per-experiment convention as
`phase2-repository-classification-plan_v1.md`:

1. **CI removal first** (lowest risk, fully reversible, no product-source
   impact): remove `jetbrains-tests` from `pr-checks.yaml` (job + its entry in
   `require-all-checks-to-pass`), remove `create-jetbrains-release` from
   `auto-release.yml`, delete `.github/workflows/jetbrains-release.yaml` and
   `.github/actions/run-jetbrains-tests/action.yml`.
2. **Plugin source removal**: `git rm -r extensions/intellij`. Update the two
   stale Core-side comments in `core/protocol/passThrough.ts` and
   `core/rules.md` to remove the now-nonexistent Kotlin file references (or
   replace with a note that the Kotlin mirror no longer exists) rather than
   leaving dangling paths.
3. **Metadata/contributor-docs cleanup**: remove the JetBrains section from
   `BUILD_DEPENDENCIES.md`; remove the `jetbrains-release.yaml` mentions from
   its `CI_GITHUB_TOKEN` row; update `README.md`'s intro/ToC/`### JetBrains`
   section; update `CONTRIBUTING.md`'s ToC and `#### JetBrains` section
   (including the stale VS-Code-section disclaimer added in Batch G, which
   currently promises a future "packaging-pipeline experiment" for JetBrains —
   that promise is superseded by this plan's removal, not a repair).

Each item gets its own branch, its own narrow commit, its own retained-closure
re-verification, and is pushed for manual merge approval — no batch under
this plan merges itself.

## Retained-closure verification per batch

Because no JetBrains path is part of the CLI/Core JS/TS closure, the
verification bar is the same lighter one used for Batches B/D/F/G in the
prior plan (root-metadata/CI/docs-only changes): re-run
`extensions/cli`'s `npm run build`, `tests/characterization/boundary-check.mjs`,
and `tests/characterization/runtime-boundary-check.mjs`, and confirm the
edited YAML files remain syntactically valid (`js-yaml` locally, since neither
`gh` nor a Python `yaml` module were reliably available in this environment
during Phase 2 work). A full CI run is deferred to the user's PR review, since
`gh` is not available locally to trigger/observe Actions runs directly.

## Current readiness blockers

None specific to this plan. The general Phase 2 readiness blockers recorded
in `phase2-repository-classification-plan_v1.md` (Node.js pin, retained-closure
matrix, `continue-sdk` manifest versions) were all resolved before Phase 2's
Experiment order began and remain resolved; no new blocker was found while
surveying the JetBrains footprint.

## RED readiness

This checkout is ready for RED under this plan:

- Local `main` is fast-forwarded through all 7 merged Phase 2 batches
  (`d3155f500`, the last of the Batch A-G merge commits).
- No open `reduce/*` branches remain; all prior batch branches have been
  deleted locally and on the remote.
- The JetBrains footprint has been fully enumerated (source, CI workflows, CI
  job wiring, secrets/build metadata, and contributor docs) with no
  functional cross-references found from the retained closure.
- The one caveat carried over from Phase 2 is unchanged: `gh` CLI is not
  installed locally, so PRs cannot be created or merged from this
  environment — every batch under this plan will be pushed with a
  "create PR" link and left for manual review/merge in the GitHub UI, exactly
  as in Batches A-G.

Proceed with Experiment order item 1 (CI removal) first.
