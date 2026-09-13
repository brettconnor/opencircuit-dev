# P6-PUB-001: CLI Declaration Entry Point Correction and Validation

## Problem Description
`extensions/cli/package.json` declares `types: dist/index.d.ts`. In the baseline configuration, `npm run build` only invoked `build:validate` and `build:bundle` (which runs `esbuild` to produce `dist/index.js` and `dist/cn.js`), but did not execute TypeScript declaration emission. As a result, a standard clean build omitted `dist/index.d.ts`.

## Applied Correction
1. **`extensions/cli/tsconfig.build.json`**:
   Configured `"compilerOptions": { "emitDeclarationOnly": true }` to ensure TypeScript compilation only produces declaration files (`.d.ts`) and does not overwrite or clutter bundled JavaScript artifacts.
2. **`extensions/cli/package.json`**:
   Updated the `"build"` script to `"npm run build:validate && npm run build:bundle && npm run build:tsc"`.

## Verification Evidence
1. **Clean Build Execution**:
   - `rm -rf dist && npm run build` exited `0`.
   - Verified outputs in `dist/`:
     - `dist/index.js` (bundled ESM implementation)
     - `dist/index.d.ts` (declared type definitions)
     - `dist/cn.js` (executable CLI wrapper)
     - `dist/xhr-sync-worker.js` (JSDOM worker)
     - `dist/meta.json` (esbuild metadata)
2. **Typecheck & Smoke Tests**:
   - `npm run typecheck` exited `0`.
   - `npm run test:smoke` passed all 10 checks.
3. **External Packed Consumer Fixture**:
   - Created a clean temporary consumer workspace.
   - Built and packed `@continuedev/cli` via `npm pack`.
   - Installed the generated `continuedev-cli-0.0.0-dev.tgz` in the consumer project.
   - Tested consuming `{ runCli, setAgentId, setTUIUnmount, setExitMessageCallback, enableSigintHandler, shouldShowExitMessage }` from `@continuedev/cli`.
   - Compiled consumer TypeScript with `tsc --noEmit --target ES2022 --module NodeNext --moduleResolution NodeNext consumer.ts`.
   - Result: `CONSUMER_TYPECHECK_EXIT=0` (0 errors).
4. **Lockfile Integrity**:
   - SHA-256 for `extensions/cli/package-lock.json` remained unchanged at `dc623a31792fa0541a7a9e809a5614f94a14c005b8dd144809a986ec8b115257`.
