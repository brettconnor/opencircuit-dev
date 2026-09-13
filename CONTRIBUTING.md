# Contributing to Continue

This fork focuses on the retained CLI, Core, shared packages, and their
validation/documentation surfaces. Keep changes narrow, reproducible, and
consistent with the existing package boundaries.

## Ways to contribute

- Report bugs through the repository issue templates with reproduction steps,
  expected behavior, and actual behavior.
- Suggest focused improvements through an issue or discussion before starting
  substantial work.
- Improve documentation in `docs/` or the package-specific documentation
  directories.
- Add tests for behavior changes and update affected documentation.

## Updating / Improving Documentation

Documentation lives in `docs/` and is built with Mintlify. From that
directory:

```bash
npm install
npm run dev
```

The navigation and site configuration are defined in `docs/docs.json`.

## Contributing Code

### Environment Setup

Use the repository's pinned Node.js `24.19.0` version:

```bash
nvm use
npm install
```

For package-specific work, install dependencies and run the scripts declared
by that package's `package.json`. Do not modify lockfiles unless the
dependency change is intentional and reviewed.

### CLI and Core workflow

The primary retained product path is CLI backed by Core. Before opening a
pull request, run the smallest applicable checks:

```bash
cd core
npm run build
npm run tsc:check

cd ../extensions/cli
npm run typecheck
npm run build
npm run test:smoke
```

When changing shared packages, build and test the affected package before
running the dependent Core/CLI checks. Use the fixed retained-closure
validation profile when a change affects package boundaries, declaration
output, workspaces, or runtime resolution.

### VS Code and deferred surfaces

The VS Code extension remains outside the primary CLI/Core reduction scope.
Changes to `extensions/vscode/`, `binary/`, or other deferred surfaces require
their own focused validation and must not be inferred from CLI/Core results.

### Git workflow

Create a focused branch from `main`, keep commits atomic, and open a pull
request against `main`. Do not rewrite shared history or combine unrelated
cleanup with product changes.

### Pull request expectations

- Explain the user-visible or repository-level effect.
- List the exact validation commands and results.
- Include or update focused tests for behavior changes.
- Update relevant documentation and package metadata.
- Keep changes within the stated scope; do not remove deferred or legal
  surfaces without a separate approved plan.

## Formatting and tests

Follow the repository's existing Prettier, ESLint, TypeScript, and package
script conventions. Prefer targeted package checks first, then the retained
CLI/Core validation profile when the change crosses package boundaries.

## Adding providers or models

Provider and model changes must update the corresponding Core implementation,
configuration or characterization coverage, and focused documentation. Verify
the affected provider/package tests before opening a pull request.

## Contributor License Agreement

Contributors must accept the CLA through the repository's configured CLA
workflow before a pull request can be merged. Follow the instructions posted
by the CLA bot on the pull request.
