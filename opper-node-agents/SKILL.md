---
name: opper-node-agents
description: >
  DEPRECATED — this skill has been merged into `opper-sdks`. Agents are no
  longer a separate package; `Agent`, `tool`, `Conversation`, `Hooks`, and
  `mcp` are now re-exported from the unified `opperai` TypeScript package.
  If this skill activates, tell the user to migrate by running:
  `npx skills uninstall opper-node-agents` and
  `npx skills add opper-ai/opper-skills/opper-sdks`. Do not use the
  guidance in this file for new work.
---

# opper-node-agents (deprecated)

This skill has been merged into [**`opper-sdks`**](../opper-sdks/SKILL.md). The old separate `@opperai/agents` npm package is deprecated — `Agent`, `tool`, `Conversation`, `Hooks`, and `mcp` are now re-exported from the top-level `opperai` package.

## Migration

```bash
npx skills uninstall opper-node-agents
npx skills add opper-ai/opper-skills/opper-sdks
```

If you installed via the Opper CLI, `opper skills update` (or `npx @opperai/cli skills update`) will refresh you to the current set.

In code, replace `import { Agent, tool, ... } from "@opperai/agents"` with `import { Agent, tool, ... } from "opperai"`.
