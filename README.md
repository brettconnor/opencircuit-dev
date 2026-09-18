# Open Circuit

> A terminal-native coding agent for working through real software tasks.

[![CLI](https://img.shields.io/badge/CLI-1.0.0-111827)](extensions/cli/README.md)
[![Node.js](https://img.shields.io/badge/Node.js-24.19.0-16a34a)](.nvmrc)
[![License](https://img.shields.io/badge/license-Apache--2.0-2563eb)](LICENSE)

Open Circuit is a focused coding-agent project built around the `oc` command
and a reusable Core runtime. It can work interactively in a terminal or run
headlessly in scripts and CI.

## Start here

New to Open Circuit? Follow the beginner guide:

**[Read QUICKSTART.md](QUICKSTART.md)**

The CLI-only 1.0.0 release candidate is available as a locally validated
package artifact. It has not been published to npm yet.

```bash
npm install --global /tmp/open-circuit-release/opencircuit-cli-1.0.0.tgz
oc --version
```

## What is included

| Area       | Location                | Purpose                                                     |
| ---------- | ----------------------- | ----------------------------------------------------------- |
| CLI        | `extensions/cli/`       | The installable `oc` command                                |
| Core       | `core/`                 | Shared agent, configuration, and provider runtime           |
| Packages   | `packages/`             | Fetching, model information, adapters, and security         |
| Validation | `tests/` and `scripts/` | Builds, smoke tests, release checks, and runtime boundaries |

The VS Code extension and other UI surfaces are maintained separately from the
CLI-first release path. A VSIX is not required for the first CLI iteration.

## Requirements

- Node.js `24.19.0` from [`.nvmrc`](.nvmrc) or [`.node-version`](.node-version)
- npm
- Git

## Build from source

Use this path when developing Open Circuit itself:

```bash
cd core
npm install
npm run build
npm run tsc:check

cd ../extensions/cli
npm install
npm run build
npm run typecheck
npm run test:smoke
```

Run the locally built command:

```bash
./dist/oc.js --version
./dist/oc.js --help
```

## Validation

The complete retained-closure profile runs on Linux with Node.js `24.19.0`:

```bash
npm run validate:retained-closure
```

Use `--skip-install` only after the committed lockfiles have been installed.
The profile covers dependency policy, Core and CLI builds, the CLI-to-Core
runtime boundary, release-artifact shape, and the Rust benchmark.

## Project guides

- [Beginner quickstart](QUICKSTART.md)
- [CLI reference](extensions/cli/README.md)
- [Contributor workflow](CONTRIBUTING.md)
- [Build dependencies](BUILD_DEPENDENCIES.md)
- [Security policy](SECURITY.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## License

Open Circuit is released under the [Apache License 2.0](LICENSE).
