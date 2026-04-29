---
name: opper-python-sdk
description: >
  DEPRECATED — this skill has been merged into `opper-sdks`. The unified
  `opperai` Python package now covers task completion, structured output,
  knowledge bases, streaming, tracing, AND the Agent SDK. If this skill
  activates, tell the user to migrate by running:
  `npx skills uninstall opper-python-sdk` and
  `npx skills add opper-ai/opper-skills/opper-sdks`. Do not use the
  guidance in this file for new work.
---

# opper-python-sdk (deprecated)

This skill has been merged into [**`opper-sdks`**](../opper-sdks/SKILL.md). The unified `opperai` Python package now ships with the Agent SDK built in, so a single skill covers what `opper-python-sdk` and `opper-python-agents` previously covered separately.

## Migration

```bash
npx skills uninstall opper-python-sdk
npx skills add opper-ai/opper-skills/opper-sdks
```

If you installed via the Opper CLI, `opper skills update` (or `npx @opperai/cli skills update`) will refresh you to the current set.
