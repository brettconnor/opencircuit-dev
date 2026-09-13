# P4-A D1 reconciliation — documentation asset duplicates

## Scope

Current `main` checkpoint: `450df8c69cfbb47c87fbd3d45f318279ca8c3074`.
Candidate surface: `docs/images/`.

The repository contained 62 documentation image files after the earlier orphan
cleanup. This batch removes only exact duplicate blobs where one canonical
path is referenced by current documentation, plus the two identical
`move-to-right-sidebar` files which have no tracked documentation reference.

## Evidence

- Duplicate identity was established from the tracked Git blob IDs.
- Canonical path selection follows exact current documentation references.
- `git grep` found no tracked source/documentation reference to any allowlisted
  deletion path.
- No package, workspace, runtime, CLI/Core, CI, release, or legal file is in
  scope.
- The docs-site copy script copies the remaining canonical image tree; it does
  not require duplicate source paths.

## Retained canonical examples

| Asset family | Retained path |
|---|---|
| MCP overview | `docs/images/customize/images/mcp-blocks-overview-c9a104f9b586779c156f9cf34da197c2.png` |
| Pre-release | `docs/images/images/prerelease-9bed93e846914165d30a3b227a680d9b.png` |
| Configure | `docs/images/customize/images/configure-continue-a5c8c79f3304c08353f3fc727aa5da7e.png` |
| Context provider | `docs/images/customize/images/context-provider-example-0c96ff77286fa970b23dddfdc1fa986a.png` |
| Continue Console | `docs/images/images/continue-console-d387a10c2918c117c6c253a3b5f18c22.png` |
| Agent response/permission | `docs/images/ide-extensions/agent/images/` |
| Intro | `docs/images/intro-0c302b9c15b890c251b1ad04586c880f.png` |
| JetBrains getting started | `docs/images/getting-started/images/jetbrains-getting-started-d62b7edee1cdd58508c5075faf285955.png` |

## Disconfirming checks

1. Every allowlisted path has no tracked reference before deletion.
2. Each duplicate family retains at least one canonical path.
3. The docs-site image-copy source tree remains buildable.
4. The CLI/Core retained closure is unchanged.
5. The committed deletion is `1acd6b5aa`; local D1 checks passed and reduced
   tracked `docs/images` from 62 to 39 files.
6. Ubuntu1 D1 runner validation is pending Git handoff because the phase
   executor does not push branches.
