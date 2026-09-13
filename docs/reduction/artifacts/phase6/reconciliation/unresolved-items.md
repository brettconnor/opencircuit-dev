# Unresolved Items Reconciliation

All three Phase 6 findings have been resolved under authorized publication corrections on branch `reduce/phase6-publication-corrections`.

## P6-PUB-001: CLI declaration entry point is not produced

- **Classification:** Resolved
- **Evidence:** `extensions/cli/package.json` declares `types: dist/index.d.ts`. In baseline, `npm run build` did not invoke `build:tsc`.
- **Impact:** Resolved. Clean builds now reliably emit `dist/index.d.ts` and submodule declarations.
- **Applied correction:** Added `"compilerOptions": { "emitDeclarationOnly": true }` to `extensions/cli/tsconfig.build.json` and wired `build:tsc` into `extensions/cli/package.json` `"build"` script.
- **Validation:** Clean build emitted `dist/index.d.ts`; typecheck and all 10 smoke tests passed; verified packed consumer fixture via `npm pack` and external `tsc` compilation with 0 errors.
- **Artifact:** `docs/reduction/phase6-corrections/cli-declaration-validation.md`

## P6-PUB-002: Aggregate third-party attribution is not assessed

- **Classification:** Resolved
- **Evidence:** `docs/reduction/license-attribution-inventory.md` recorded that no root aggregate notice existed.
- **Impact:** Resolved. Completed comprehensive attribution assessment of all 376 bundled dependencies from `dist/meta.json` (100% permissive licenses: MIT, Apache-2.0, BSD, ISC, 0BSD; 0 copyleft; 0 custom notice requirements).
- **Applied correction:** Established root `NOTICE` file; updated `docs/reduction/license-attribution-inventory.md` and `docs/reduction/artifacts/phase6/legal/license-attribution-review.md`.
- **Validation:** Automated inventory of bundled inputs from build metadata; zero license violations or copyleft packages detected.
- **Artifact:** `NOTICE`, `docs/reduction/phase6-corrections/third-party-attribution-review.md`

## P6-DOC-001: Historical entry-point inventory is stale

- **Classification:** Resolved
- **Evidence:** `docs/reduction/cli-core-entry-points.md` previously recorded Core `types` as "Not declared".
- **Impact:** Resolved. Corrected inventory to reflect that `core/package.json` declares `types: dist/index.d.ts` (emitted/copied on build) and updated CLI declaration entry point status.
- **Applied correction:** Updated `docs/reduction/cli-core-entry-points.md` Core and CLI tables and narratives.
- **Validation:** Cross-referenced against `core/package.json`, `core/dist/index.d.ts`, and `extensions/cli/package.json`.
- **Artifact:** `docs/reduction/cli-core-entry-points.md`, `docs/reduction/phase6-corrections/entry-points-reconciliation.md`
