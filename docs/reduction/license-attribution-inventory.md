# License and Attribution Inventory

## Repository License

The repository root contains `LICENSE`, which is the Apache License 2.0. It must remain in every retained source distribution unless a separately approved licensing change applies.

The root `package.json` has no `license` field. This is a baseline metadata gap; the package is repository tooling rather than a published retained product package.

## Retained Package Metadata

| Package                          | Manifest license |
| -------------------------------- | ---------------- |
| `@continuedev/core`              | Apache-2.0       |
| `@continuedev/cli`               | Apache-2.0       |
| `@continuedev/config-types`      | Apache-2.0       |
| `@continuedev/config-yaml`       | Apache-2.0       |
| `@continuedev/fetch`             | Apache-2.0       |
| `@continuedev/llm-info`          | Apache-2.0       |
| `@continuedev/openai-adapters`   | Apache-2.0       |
| `@continuedev/terminal-security` | Apache-2.0       |

Retained package manifests must keep their license fields consistent with the repository license and release contents.

## Vendored Content

| Vendored surface                           | Declared license | Required retained evidence            |
| ------------------------------------------ | ---------------- | ------------------------------------- |
| `core/vendor`                              | Apache-2.0       | `core/vendor/package.json`            |
| `core/vendor/modules/@xenova/transformers` | Apache-2.0       | Vendored `package.json` and `LICENSE` |

The vendored Transformers license is a separate copy of the Apache License 2.0 and must remain with that vendored source while the source is retained.

## Other License Files Outside the Initial Closure

- `extensions/vscode/LICENSE.txt`
- `gui/public/fonts/Inter/LICENSE.txt`

These files belong to deferred or proposed-removal surfaces. They must be removed only with their corresponding content, not independently.

## Attribution State

Root `NOTICE` is established documenting the root Apache-2.0 license and third-party software attribution. The publication-time third-party attribution review audited all 376 bundled dependencies extracted from build metadata (`dist/meta.json`):
- 100% of bundled packages are permissively licensed (234 MIT, 100 Apache-2.0, 15 BSD-3-Clause, 14 ISC, 11 BSD-2-Clause, 1 0BSD, 1 MIT-0).
- 0 copyleft or reciprocal licenses are bundled.
- 0 custom upstream NOTICE requirements are triggered.
See `docs/reduction/phase6-corrections/third-party-attribution-review.md` for complete evidence.

## Reduction Requirements

1. Preserve the root Apache-2.0 `LICENSE`.
2. Preserve each retained package's `license` field.
3. Preserve vendored license files with retained vendored code or assets.
4. Remove a surface-specific license only with the corresponding removed surface.
5. Retain root `NOTICE` and verify bundled third-party notice requirements before publication.
6. Compare this inventory against the Phase 6 retained tree and package artifact.
