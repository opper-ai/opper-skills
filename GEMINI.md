# Opper skills

This extension bundles Opper's Agent Skills. When a task involves Opper (https://opper.ai), read the matching skill before acting. Each skill is a `SKILL.md` in this extension's folder, and the same file is served as plain markdown at `https://skills.opper.ai/<skill>/SKILL.md`.

| Skill | Use it for |
|---|---|
| `opper` | Entry point. Start here when the user mentions Opper without choosing a surface; it routes to the others. |
| `opper-mcp` | Connecting an agent to Opper over MCP, project setup, rules, usage, traces and model tests. |
| `opper-cli` | The `opper` command: sign-in, traces, usage, config and launching coding agents through Opper. |
| `opper-api` | Application code on the OpenAI, Anthropic and Google SDKs through `https://api.opper.ai/v3/compat`, raw HTTP, models and platform concepts. |
| `opper-multimodal` | Images, audio, video, OCR, the files API, vision input and realtime voice. |

For any endpoint signature, fetch the live spec at `https://api.opper.ai/v3/openapi.yaml`.
