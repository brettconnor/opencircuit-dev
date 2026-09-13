# Unresolved Items

## P6-PUB-001: CLI declaration entry point is not produced

- **Classification:** Blocked
- **Evidence:** `extensions/cli/package.json` declares `types:
  dist/index.d.ts`; the existing entry-point inventory records that the
  standard build emits declarations elsewhere and the Phase 6 fixed build
  profile does not establish the declared path.
- **Impact:** Published TypeScript consumers cannot rely on the declared CLI
  type entry point.
- **Required correction:** Change the CLI declaration build/output or package
  metadata and validate a packed consumer.
- **Phase 6 action:** No correction made; package/source metadata is outside
  the evidence-only allowlist.

## P6-PUB-002: Aggregate third-party attribution is not assessed

- **Classification:** Blocked
- **Evidence:** `docs/reduction/license-attribution-inventory.md` records
  that no root aggregate notice exists and requires publication-time
  verification of bundled third-party attribution requirements.
- **Impact:** Publication cannot claim complete legal/attribution readiness.
- **Required correction:** Perform a dedicated distribution/notice review and
  add any required legal material through its own authorized scope.
- **Phase 6 action:** No legal file was changed.

## P6-DOC-001: Historical entry-point inventory is stale

- **Classification:** Unknown
- **Evidence:** `docs/reduction/cli-core-entry-points.md` still states that
  Core has no declared `types` entry, while reviewed `core/package.json`
  declares `types: dist/index.d.ts` and its build copies that file.
- **Impact:** The retained documentation set is internally inconsistent.
- **Required correction:** Reconcile the historical inventory under an
  authorized documentation-maintenance scope.
- **Phase 6 action:** Preserved the historical document and recorded the
  discrepancy; it is outside the Phase 6 allowlist.
