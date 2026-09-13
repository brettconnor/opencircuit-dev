# Mintlify starter README deletion record

The tracked `docs/README.md` contained only generic Mintlify Starter Kit
template instructions (`Use this template`, example navigation, and local
`mint dev` guidance). It was not referenced by `docs/docs.json`, the Mintlify
navigation, or any build script.

The template-only README was removed. The docs package description was updated
from the starter-kit text to `Mintlify documentation site for Continue`.

Retained:

- `docs/docs.json` and all configured navigation;
- documentation pages and assets;
- `docs/package.json` and `docs/package-lock.json`;
- Mintlify build and preview scripts.

No documentation content, runtime product code, or lockfile was changed.
