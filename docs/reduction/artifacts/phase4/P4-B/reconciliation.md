# P4-B D2 reconciliation — stale JetBrains workspace metadata

## Scope

Current branch checkpoint: `e5f6e6358`.
Candidate surface: root `.idea/`.

The root `.idea/` tree contains 20 tracked JetBrains project metadata files.
The repository contains no tracked `extensions/intellij/` or
`extensions/jetbrains/` source. The metadata includes module and run
configuration references for an absent JetBrains product surface, so it is
workspace residue rather than retained CLI/Core product input.

## Evidence

- `git ls-files 'extensions/intellij/**'` and
  `git ls-files 'extensions/jetbrains/**'` return no tracked source.
- Exact-path reference scanning found no consumer of the allowlisted files
  outside the `.idea/` tree itself.
- The only remaining `.idea` references are ignore rules and runtime behavior
  that intentionally ignores user-created IDE metadata.
- The prior Batch G workspace/metadata cleanup classified workspace cruft as
  removable when it had no retained product dependency.
- No package manifest, workspace entry, lockfile, CI workflow, release job,
  legal/attribution file, CLI/Core source, or retained test requires root
  `.idea/`.

## Disconfirming checks

1. All 20 allowlisted paths exist at the source checkpoint.
2. No exact allowlisted path is referenced outside `.idea/` or reduction
   evidence.
3. The retained package matrix and CLI/Core boundary checks remain unchanged
   after deletion.
4. `git diff --check` passes and no lockfile is modified.
5. Ubuntu1 D2 validation passes for every allowlisted path.

## Rollback

Restore the reversible deletion with:

```text
git revert <P4-B deletion commit>
```

No source or dependency changes are part of this batch.

## Validation result

The deletion commit is `ceb6624f9`. Local scope and hygiene checks passed:
all 20 allowlisted paths were deleted, no lockfile changed, no exact deleted
path was referenced outside reduction evidence, and `git diff --check`
passed.

Authoritative Ubuntu1 D2 validation ran for all 20 paths on
`10.1.141.9` with Node.js `24.19.0` at remote commit `ceb6624f9`.
Result: **0/20 passed; 20/20 blocked** at the retained-closure matrix.
The failure is Core `npm run tsc:check` reporting TS2322 duplicate nominal
type identities after the Core build. It reproduces from a fresh `core/dist`
and is independent of the `.idea` deletion. No boundary check ran because the
fixed D2 runner correctly gates boundary checks on a passing matrix.

This is recorded as a pre-existing retained-Core validation blocker, not a
P4-B scope exception. Phase 4 continuation is stopped pending remediation or
an explicit approved environment/validation waiver.
