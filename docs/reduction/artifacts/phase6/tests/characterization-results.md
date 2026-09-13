# Characterization Results

All inherited fixed Phase 5 characterization markers passed on Ubuntu1:

| Contract | Fixed command | Result |
| --- | --- | --- |
| Configuration | `extensions/cli/src/config.test.ts` | Pass |
| Model initialization/selection | `ModelService.direct.test.ts` and `ModelService.workflow-priority.test.ts` | Pass |
| Adapter normalization | `packages/openai-adapters/src/apis/Anthropic.test.ts` | Pass |

The controlled headless workflow is recorded separately in
`headless-workflow.log`.
