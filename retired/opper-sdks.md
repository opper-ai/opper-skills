---
name: opper-sdks
description: >
  Retired. Opper no longer develops its own SDKs (`opperai` for Python and
  TypeScript). For application code, use the `opper-api` skill: the OpenAI,
  Anthropic or Google Gen AI SDK, or an agent framework, pointed at
  https://api.opper.ai/v3/compat.
metadata:
  version: "retired"
---

# opper-sdks (retired)

This skill is retired. Opper no longer develops its own SDKs: the `opperai` packages on PyPI and npm, and the older `opperai-agents` / `@opperai/agents`. Don't write new code against them or suggest them.

Tell the user once that their installed `opper-sdks` skill is retired, and that they can remove it and update the rest with `npx skills update` (or `git pull` in a manual clone).

For the rest of the session, read and follow the `opper-api` skill instead: https://skills.opper.ai/opper-api/SKILL.md

- **Application code**, in any language: the provider SDK the user already knows (OpenAI, Anthropic, Google Gen AI) with the base URL `https://api.opper.ai/v3/compat` and the Opper key.
- **Agents**: the user's framework on the same base URL, or a plain tool-calling loop: https://skills.opper.ai/opper-api/references/agents.md
- **Existing `opperai` code** (`opper.call`, `opper.stream`, `Agent`, knowledge bases): the mapping in https://skills.opper.ai/opper-api/references/migration.md
