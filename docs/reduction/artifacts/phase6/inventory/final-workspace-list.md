# Final Workspace List

The reviewed root is intentionally a non-workspace npm tooling project. The
fixed Phase 6 `workspace` review verifies that posture and the existence of
each retained standalone package manifest.

| Retained surface | Manifest | Classification |
| --- | --- | --- |
| Root tooling | `package.json` | Keep |
| Core | `core/package.json` | Keep |
| CLI | `extensions/cli/package.json` | Keep |
| Config Types | `packages/config-types/package.json` | Keep |
| Config YAML | `packages/config-yaml/package.json` | Keep |
| Fetch | `packages/fetch/package.json` | Keep |
| LLM Info | `packages/llm-info/package.json` | Keep |
| OpenAI Adapters | `packages/openai-adapters/package.json` | Keep |
| Terminal Security | `packages/terminal-security/package.json` | Keep |

`npm ls --depth=0` passed in the inherited profile. There is no root
`workspaces` declaration to reconcile.
