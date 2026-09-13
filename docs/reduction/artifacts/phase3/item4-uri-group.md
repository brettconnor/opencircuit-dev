# Phase 3 — Item 4 batch 9: `uri` group

## Scope

- Facade: `core/uri.ts` → `export * from "./util/uri.js";`
- CLI import site migrated (1):
  - `extensions/cli/src/ui/hooks/useChat.helpers.ts` (`getLastNPathParts`)

Old deep path `core/util/uri.js` is untouched and still resolves —
removal deferred to a later, separately-approved batch per the Item 4
plan.

## Pre-emptive bare-import check

`core/util/uri.ts` has exactly one import — `import * as URI from
"uri-js"` — an external npm package specifier, not a relative/bare
in-repo specifier. No fix needed; this module has zero transitive
in-repo import issues.

## Validation performed

1. **TypeScript typecheck** (`tsc -p ./tsconfig.npm.json --noEmit`, clean
   `dist`) — no errors.
2. **Clean core rebuild** — confirmed `dist/uri.js` re-exports
   `./util/uri.js` with the explicit extension.
3. **Isolated external-consumer fixture** (packed tarball, `file:`
   dependency, `type: module`, outside repo):
   - JS runtime `import("@continuedev/core/dist/uri.js")` — resolves
     cleanly, exposes all 12 expected exports (`findUriInDirs`,
     `getCleanUriPath`, `getFileExtensionFromBasename`,
     `getLastNPathParts`, `getLastNUriRelativePathParts`,
     `getShortestUniqueRelativeUriPaths`, `getUriDescription`,
     `getUriFileExtension`, `getUriPathBasename`,
     `joinEncodedUriPathSegmentToUri`, `joinPathsToUri`,
     `pathToUriPathSegment`).
   - Strict `NodeNext` TypeScript typecheck importing `getLastNPathParts`
     from the same facade path — passes with no errors.
4. **CLI build** — unchanged, 12.69 MB bundle.
5. **Both boundary-check scripts** — `violations: []`;
   `inputCount` 4142→4143 (expected +1 for the new facade file).
6. **Targeted tests**:
   - CLI: `useChat.test.ts`, `useChat.stream.test.ts`,
     `useChat.shellMode.test.ts` — 12/12 pass.
   - Core: `util/uri.test.ts` (Jest) — 16/16 pass.

## Takeaway

Simplest batch to date alongside `security` — the target module had zero
relative/in-repo bare imports to fix, only an external package import
which is unaffected by the extensionless-relative-import problem this
Item 4 workflow has been guarding against. Confirms not every group hits
that failure mode; the grep-first step still correctly identified "nothing
to fix here" quickly.
