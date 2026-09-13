# Final Entry-Point Inventory

| Surface | Declared entry | Observed review result | Classification |
| --- | --- | --- | --- |
| CLI executable | `bin.cn` -> `dist/cn.js` | Build and smoke passed | Keep |
| CLI programmatic | `main` -> `dist/index.js` | Build passed | Keep |
| CLI declarations | `types` -> `dist/index.d.ts` | Standard build does not generate the declared path | Blocked |
| Core declarations | `types` -> `dist/index.d.ts` | Core build copies the declaration and typecheck passed | Keep |
| Core runtime root | No `main`/`exports` declaration | Existing boundary exception remains open | Defer |
| Config YAML executable | `dist/cli.js` | Separate from `cn`; no removal authority | Unknown |

The CLI declaration-path discrepancy is a material publication item and is
listed in `../reconciliation/unresolved-items.md`. This artifact does not
change package metadata or generated output.
