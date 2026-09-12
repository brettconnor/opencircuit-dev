# RED-001 Core Lockfile Integrity

## Outcome

RED-001 repaired the Core manifest/lock mismatch without deleting product code.
`npm ci --ignore-scripts --no-audit --no-fund` now succeeds from an absent
`core/node_modules`, and all Phase 0 gating builds, typechecks,
characterization tests, and boundary checks pass.

The broader Core Jest suite is not green. Its failures are recorded below and
remain a deletion-gate limitation pending explicit approval or remediation.

## Source and Environment

| Field               | Value                                          |
| ------------------- | ---------------------------------------------- |
| Branch              | `red/001-core-lockfile-integrity`              |
| Base commit         | `766a00bd15dd2f021a9aa835aa9e4f0151e27b3e`     |
| Source checkpoint   | `phase0-cli-core-complete`                     |
| Evidence checkpoint | `red-001-core-clean-install`                   |
| Date                | 2026-09-12                                     |
| Operating system    | Linux 6.14.0-37-generic, x86_64                |
| Node.js             | 24.19.0                                        |
| npm                 | 11.17.0                                        |
| Registry            | `https://registry.npmjs.org/`                  |
| Install policy      | `npm ci --ignore-scripts --no-audit --no-fund` |

The repository Node pins, Core and CLI engine declarations, CLI installers,
CLI bundle target, and retained Core vendor metadata changed to Node 24.19.0.
Regenerating the lockfile resolved `puppeteer` and `puppeteer-core` 25.10.0 plus
`@puppeteer/browsers` 3.2.2. Those packages require Node.js 22.12.0 or newer,
so retaining any advertised Node 18 or Node 20 path would leave the corrected
dependency graph outside its supported engine range. Node 24.19.0 is the
single tested runtime for this checkpoint.

## Lockfile Repair

The Phase 0 Core manifest requested `puppeteer ^25.0.2` and
`puppeteer-chromium-resolver ^25.0.0`, while the lockfile retained Puppeteer
24.43.1 and resolver 23.0.0. The lockfile was regenerated from the unchanged
dependency manifest. The CLI lockfile was then regenerated so its linked Core
snapshot carries the same dependency graph and Node.js engine requirement.

Resolved Puppeteer closure:

| Package                       | Resolved version | Node.js requirement |
| ----------------------------- | ---------------: | ------------------- |
| `puppeteer`                   |          25.10.0 | `>=22.12.0`         |
| `puppeteer-core`              |          25.10.0 | `>=22.12.0`         |
| `puppeteer-chromium-resolver` |           25.0.0 | Not declared        |
| `@puppeteer/browsers`         |            3.2.2 | `>=22.12.0`         |

The repaired `core/package-lock.json` SHA-256 is
`f58106181d204060082a4d41f19665856c2debc46fac4677dec7f9251e611398`.
The synchronized `extensions/cli/package-lock.json` SHA-256 is
`dc623a31792fa0541a7a9e809a5614f94a14c005b8dd144809a986ec8b115257`.
Both hashes were unchanged by their subsequent immutable installs.
The retained `core/vendor/package.json` and its lockfile now also declare
Node.js 24.19.0 or newer; the vendor lockfile SHA-256 is
`3f686c9288d0390ceca84a4ca1efce929b815588803be371f5e6b5e11318c15b`.

## Gating Results

| Check                                                   | Result              |
| ------------------------------------------------------- | ------------------- |
| Immutable installs for all eight retained package roots | Pass                |
| Builds for all eight retained package roots             | Pass                |
| Core and CLI typechecks                                 | Pass                |
| Fetch tests                                             | 97 passed           |
| Terminal Security tests                                 | 224 passed          |
| Config YAML characterization                            | 8 passed, 1 skipped |
| OpenAI adapter characterization                         | 3 passed            |
| CLI ModelService characterization                       | 21 passed           |
| CLI smoke                                               | 10 passed           |
| CLI headless workflow                                   | 3 passed            |
| Static and emitted-bundle boundary check                | Pass                |
| Headless runtime boundary check                         | Pass                |

The runtime boundary check now exercises the actual headless CLI path rather
than `--version`. It runs `dist/cn.js -p --config <temporary-config> Hi`
against a loopback OpenAI-compatible fixture, asserts `Hello World!`, and
records every ESM resolution through the boundary loader. It also fails when
the executing Node.js version differs from `.node-version`.

## Broader Core Test Limitation

The Core install uses `--ignore-scripts`, so the broader Jest suite requires
`npm rebuild sqlite3` before execution. After that rebuild:

- 45 suites passed and 10 failed.
- 780 tests passed, 19 failed, and 76 were skipped.
- Credential-dependent live-provider tests failed for Anthropic, OpenAI, and
  Mistral models because valid external credentials were unavailable.
- Nine suites failed before execution because CommonJS
  `puppeteer-chromium-resolver` requires the ESM-only `puppeteer-core`.

These failures are not Phase 0 characterization regressions, but they must not
be represented as a passing full Core suite.

## Gate Decision

RED-001 itself is complete: Core immutable installation and every Phase 0
gating check pass. Product deletion remains prohibited until the broader Core
Jest failures are either remediated or explicitly approved as non-gating in
the Phase 1 deletion review.

Evidence is stored in `docs/reduction/artifacts/red-001/`.
