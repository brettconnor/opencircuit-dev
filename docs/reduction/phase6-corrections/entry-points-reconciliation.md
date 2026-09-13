# P6-DOC-001: CLI and Core Entry-Point Inventory Reconciliation

## Objective
Reconcile discrepancies in `docs/reduction/cli-core-entry-points.md` where Core's `types` entry was documented as "Not declared" despite `core/package.json` declaring `types: dist/index.d.ts`, and update CLI entry-point status following the P6-PUB-001 build correction.

## Evidence & Corrections
1. **Core Package Metadata & Build Process**:
   - `core/package.json` declares `"types": "dist/index.d.ts"`.
   - `core` build script is `tsc -p ./tsconfig.npm.json && node -e "require('fs').copyFileSync('index.d.ts', 'dist/index.d.ts')"`.
   - Updated `docs/reduction/cli-core-entry-points.md` Core table from "Not declared" to "Declared: `dist/index.d.ts` (build copies `core/index.d.ts` to `core/dist/index.d.ts`)".
   - Preserved accurate documentation that `main` and `exports` remain undeclared and that CLI consumes Core via TypeScript/build aliases.
2. **CLI Package Metadata & Build Process**:
   - `extensions/cli/package.json` declares `"types": "dist/index.d.ts"`.
   - Following P6-PUB-001, `npm run build` executes `build:tsc` (`tsc -p tsconfig.build.json`) with `emitDeclarationOnly: true`.
   - Updated CLI table status from "Declared, but missing after the standard build" to "Declared and emitted by standard build".

## Verification
- Confirmed accuracy against current `core/package.json`, `core/dist/index.d.ts`, `extensions/cli/package.json`, and `extensions/cli/dist/index.d.ts`.
- Documentation is now fully consistent with the actual package manifests and build outputs.
