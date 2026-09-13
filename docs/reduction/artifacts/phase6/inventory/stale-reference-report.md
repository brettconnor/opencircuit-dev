# Active Stale-Reference Report

**Result:** Pass for the fixed active-reference scan on Ubuntu1.

The runner searched `.github`, package manifests, and TypeScript
configuration for references to removed `extensions/intellij/`,
`manual-testing-sandbox/`, and `eval/` surfaces. No active matches were
found. It intentionally does not treat strings in source tests, historical
reduction evidence, or deferred-surface records as active references.

Known deferred references (for example, VS Code packaging references to the
already-absent GUI) remain `Unknown` rather than being represented as a pass
for that deferred product surface.
