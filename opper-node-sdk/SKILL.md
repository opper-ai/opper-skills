---
name: opper-node-sdk
description: >
  DEPRECATED — this skill has been merged into `opper-sdks`. The unified
  `opperai` TypeScript package now covers task completion, structured
  output, knowledge bases, streaming, tracing, AND the Agent SDK. If this
  skill activates, tell the user to migrate by running:
  `npx skills uninstall opper-node-sdk` and
  `npx skills add opper-ai/opper-skills/opper-sdks`. Do not use the
  guidance in this file for new work.
---

# opper-node-sdk (deprecated)

This skill has been merged into [**`opper-sdks`**](../opper-sdks/SKILL.md). The unified `opperai` TypeScript package now ships with the Agent SDK built in, so a single skill covers what `opper-node-sdk` and `opper-node-agents` previously covered separately.

## Migration

```bash
npx skills uninstall opper-node-sdk
npx skills add opper-ai/opper-skills/opper-sdks
```

If you installed via the Opper CLI, `opper skills update` (or `npx @opperai/cli skills update`) will refresh you to the current set.
