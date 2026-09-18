# How to Contribute

Thanks for contributing to Open Circuit. Please review the
[Code of Conduct](CODE_OF_CONDUCT.md) before opening an issue or pull request.

## Reporting issues

Search existing issues first. Include a clear title, affected commit or
version, reproduction steps, expected behavior, actual behavior, and a focused
test case when possible. Report security issues through
[SECURITY.md](SECURITY.md), not a public issue.

## Pull requests

Keep pull requests focused and include tests for affected behavior. Describe
the exact files and packages changed, validation performed, runtime versions,
and any known limitation. Do not commit credentials or generated production
artifacts.

## Development

Use Node.js `24.19.0` from `.nvmrc` and `.node-version`. The primary product
path is the CLI backed by Core:

```bash
cd core
npm install
npm run build
npm run tsc:check

cd ../extensions/cli
npm install
npm run typecheck
npm run build
npm run test:smoke
```

Changes affecting package boundaries, declaration output, workspace
configuration, or runtime resolution require the fixed retained-closure
validation profile.

## Scope and compatibility

The retained product is the CLI, Core, and their shared packages. The VS Code
extension and VSIX are deferred surfaces with separate validation scope.
Preserve `@opencircuit/*` package names and `OCIRCUIT_*` environment variables
when compatibility requires them.

## Contributor agreement

Contributors must accept the project's
[CLA](CLA.md) through the configured repository workflow before merge.
