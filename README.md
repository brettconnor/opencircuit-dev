# Open Circuit

Open Circuit is a focused coding-agent repository centered on a command-line
interface backed by a reusable Core runtime.

## Product scope

The retained product includes:

- CLI (`cn`) in `extensions/cli/`;
- Core runtime in `core/`;
- shared packages for configuration, fetching, model information, provider
  adapters, and terminal security;
- focused build, test, documentation, and release tooling.

The VS Code extension and other repository surfaces remain maintained
separately from the primary CLI/Core validation path.

## Requirements

- Node.js `24.19.0` (`.nvmrc` / `.node-version`);
- npm;
- Git.

## Quick start

Install dependencies for the package you are working on, then build the
retained product in dependency order:

```bash
cd core
npm install
npm run build
npm run tsc:check

cd ../extensions/cli
npm install
npm run build
npm run test:smoke
```

Run the CLI after building:

```bash
cd extensions/cli
npm start
```

## Documentation

The Mintlify documentation site is in `docs/`. To preview it locally:

```bash
cd docs
npm install
npm run dev
```

## Development checks

Run the smallest applicable package checks for each change. Changes that cross
package boundaries, declaration output, workspace configuration, or runtime
resolution should use the fixed retained-closure validation profile.

The contributor workflow is documented in
[`CONTRIBUTING.md`](CONTRIBUTING.md). CI secrets and environment variables are
listed in [`BUILD_DEPENDENCIES.md`](BUILD_DEPENDENCIES.md).

## Project policies

- [`CLA.md`](CLA.md) — contributor license agreement;
- [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) — community standards;
- [`SECURITY.md`](SECURITY.md) — vulnerability reporting;
- [`LICENSE`](LICENSE) — Apache License 2.0;
- [`NOTICE`](NOTICE) — third-party attribution notice.

## Package compatibility

Some package and environment-variable identifiers retain their historical
`@continuedev/*` and `CONTINUE_*` names for compatibility. Those identifiers
are implementation and distribution contracts, not the project branding.
