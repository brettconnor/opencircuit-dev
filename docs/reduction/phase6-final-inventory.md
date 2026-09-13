# Phase 6 Final Inventory

**Reviewed product commit:** `308c540b735b4860504dadf281311c329420612e`  
**Evidence branch:** `reduce/phase6-final-review` at
`778eda62c02ceab4a876f9ba73ba7b4ea6ea8e63` before this evidence commit.

| Major surface | Classification | Final evidence |
| --- | --- | --- |
| CLI (`cn`) | Keep | Build, smoke, and headless workflow passed |
| Core and retained local packages | Keep | Immutable install/build/typecheck closure passed |
| Root tooling | Keep | Root immutable install and dependency scan passed |
| `extensions/vscode`, `binary`, `docs-site`, `sync`, `core/vendor`, model assets | Defer | Protected/deferred Phase 4 inventory |
| VS Code GUI packaging relationship | Unknown | Existing deferred-surface issue; no Phase 6 authority to alter it |
| Removed JetBrains CI/source, stale root metadata, `eval`, `skills`, manual sandbox | Historical | No active manifest/config/CI references found |
| CLI declaration entry point | Blocked | `P6-PUB-001` |
| Aggregate attribution assessment | Blocked | `P6-PUB-002` |
| Historical Core entry-point documentation | Unknown | `P6-DOC-001` |

The full package and entry-point records are under
`docs/reduction/artifacts/phase6/inventory/`.
