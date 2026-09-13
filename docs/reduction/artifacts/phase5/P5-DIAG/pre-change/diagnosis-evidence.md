# P5-DIAG pre-change evidence

## Fixed runner invocation

```text
/Users/brettcon/git/systems-orchestration/scripts/open-circuit-runner.sh \
  --hosts-file /Users/brettcon/git/hosts/ubuntu1-hosts.sh \
  --branch reduce/phase4-reversible-deletion \
  --phase5-diagnose
```

- Host: Ubuntu1 (`10.1.141.9`)
- Remote commit: `9f69a3206` (`docs(phase4): publish final closeout`)
- Runtime: Node.js `v24.19.0`, npm `11.17.0`
- Core TypeScript: `5.9.3`
- Core lockfile SHA-256: `f58106181d204060082a4d41f19665856c2debc46fac4677dec7f9251e611398`
- Runner exit: `0`
- Diagnostic result: `reproduced`

## Determinism

The fixed runner removed `core/dist` and ran `npm run build` followed by
`npm run tsc:check -- --traceResolution` three times:

| Run | Build | `tsc:check` | Signature |
|---:|---:|---:|---|
| 1 | 0 | 2 | TS2322 / source-vs-dist CodebaseIndexer |
| 2 | 0 | 2 | TS2322 / source-vs-dist CodebaseIndexer |
| 3 | 0 | 2 | TS2322 / source-vs-dist CodebaseIndexer |

## Failure signature

```text
core.ts(1185,7): error TS2322:
Type 'import("<remote>/open-circuit-dev/core/indexing/CodebaseIndexer").CodebaseIndexer'
is not assignable to type
'import("<remote>/open-circuit-dev/core/dist/indexing/CodebaseIndexer").CodebaseIndexer'.
Types have separate declarations of a private property 'configHandler'.
```

Resolution tracing showed both paths in the same check:

```text
core/index.d.ts -> ./indexing/CodebaseIndexer -> core/indexing/CodebaseIndexer.ts
core/dist/index.d.ts -> ./indexing/CodebaseIndexer -> core/dist/indexing/CodebaseIndexer.d.ts
core/core.ts -> ./indexing/CodebaseIndexer -> core/indexing/CodebaseIndexer.ts
```

The build succeeds, then the typecheck fails with the nominal private-member
identity mismatch. The diagnostic command also captured the expected linked
local package identities from `npm ls`; no unexpected package or lockfile
mutation was observed.

## Root-cause classification

`stale generated declarations` plus a `source-versus-dist resolution split`,
caused by the broad `./**/*.d.ts` include in both Core TypeScript configs.

## Rejected hypotheses

- Genuine source incompatibility: rejected; build succeeds and both
  declarations expose the same private member name.
- Node environment mismatch: rejected; Ubuntu1 reported the required runtime.
- Missing local package identity: rejected; `npm ls` showed the expected local
  package links and the lockfile hash matched the retained baseline.
- Deferred-surface or public-API issue: rejected; the failure is confined to
  Core type resolution.
