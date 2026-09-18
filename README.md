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

The CLI-only 1.0.0 release candidate can be staged as a GitHub Release asset.
It has not been published to npm yet.

```bash
npm --prefix extensions/cli run release:artifact
npm install --global release-artifacts/v1.0.0/opencircuit-cli-1.0.0.tgz
oc --version
```

The generated tarball and `.sha256` file are written to the ignored
`release-artifacts/v1.0.0/` directory. Upload both files to the GitHub Release
for tag `v1.0.0` when the release is ready.

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

## Provider keys

The hosted Open Circuit API is currently disabled by default. The CLI can use
direct provider credentials instead. Set only the provider key you need in the
shell that launches `oc`:

```bash
export OPENAI_API_KEY="your-openai-key"
export ANTHROPIC_API_KEY="your-anthropic-key"
export GEMINI_API_KEY="your-gemini-key"
```

Use a local `config.yaml` with `apiKey: ${{ secrets.PROVIDER_API_KEY }}` and run
`oc --config ./config.yaml`. See the [beginner quickstart](QUICKSTART.md) for
provider-specific examples. Never commit API keys.

## Stage a release asset

From the repository root:

```bash
npm --prefix extensions/cli run release:artifact
shasum -a 256 release-artifacts/v1.0.0/opencircuit-cli-1.0.0.tgz
```

Upload these files manually to the GitHub `v1.0.0` release:

- `release-artifacts/v1.0.0/opencircuit-cli-1.0.0.tgz`
- `release-artifacts/v1.0.0/opencircuit-cli-1.0.0.tgz.sha256`

CI automation and npm publication are intentionally deferred.

## Deploy to Ubuntu1

The deployment helper transfers the verified CLI artifact and can install `oc`
on Ubuntu1. It does not modify the existing source checkout or provider keys.

Preview scoped cleanup:

```bash
./scripts/open-circuit-deploy.sh --cleanup --dry-run
```

Deploy and install the staged artifact:

```bash
./scripts/open-circuit-deploy.sh --install
```

Cleanup requires explicit confirmation:

```bash
./scripts/open-circuit-deploy.sh --cleanup --yes
```

Remove legacy Continue state while preserving the Open Circuit install,
provider credentials, and source checkout:

```bash
./scripts/open-circuit-deploy.sh --remove-legacy-continue --dry-run
./scripts/open-circuit-deploy.sh --remove-legacy-continue --yes
```

Cleanup is limited to Open Circuit release staging, the global
`@opencircuit/cli` package, `~/.ocircuit`, and exact Open Circuit shell entries.
The legacy cleanup removes only `.continue` and `.continueignore` paths in the
home directory and existing checkout. It preserves `~/.ocircuit`, `oc`,
provider credentials, Node.js, Rust, Ansible, SSH, and unrelated user data.

## Provider smoke test

After installing `oc` on the target runtime, run the explicit live check with
both provider keys exported in that shell:

```bash
./scripts/provider-smoke.sh --live --cli oc
```

This makes one short request to OpenAI and one to Anthropic, with no retries,
temporary configuration, a bounded timeout, and suppressed response bodies.
It is not part of the offline retained-closure gate.

## Project guides

- [Beginner quickstart](QUICKSTART.md)
- [CLI reference](extensions/cli/README.md)
- [Contributor workflow](CONTRIBUTING.md)
- [Build dependencies](BUILD_DEPENDENCIES.md)
- [Security policy](SECURITY.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## License

Open Circuit is released under the [Apache License 2.0](LICENSE).
