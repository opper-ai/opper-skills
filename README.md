# Opper Skills

Agent Skills for building AI applications with [Opper](https://opper.ai). Compatible with 25+ AI coding agents via the [Agent Skills](https://agentskills.io) standard.

## Installation

```bash
npx skills add opper-ai/opper-skills
```

Or install individual skills:

```bash
npx skills add opper-ai/opper-skills/opper-api
npx skills add opper-ai/opper-skills/opper-python-sdk
npx skills add opper-ai/opper-skills/opper-node-sdk
npx skills add opper-ai/opper-skills/opper-python-agents
npx skills add opper-ai/opper-skills/opper-node-agents
npx skills add opper-ai/opper-skills/opper-cli
```

### Alternative: Clone directly

```bash
git clone https://github.com/opper-ai/opper-skills.git
# Then point your agent's skills directory at this folder
```

Skills are just folders with a `SKILL.md` file. Any method that gets them on disk works — clone, copy, or symlink into your agent's skills directory (e.g., `.claude/skills/` for Claude Code).

## Available Skills

| Skill | Description | Language |
|-------|-------------|----------|
| [opper-api](./opper-api/) | Call the Opper REST API directly with any HTTP client | HTTP |
| [opper-python-sdk](./opper-python-sdk/) | Task completion, knowledge bases, and tracing with the Opper Python SDK | Python |
| [opper-node-sdk](./opper-node-sdk/) | Task completion, knowledge bases, and tracing with the Opper Node SDK | TypeScript |
| [opper-python-agents](./opper-python-agents/) | Build AI agents with tools, memory, and multi-agent composition in Python | Python |
| [opper-node-agents](./opper-node-agents/) | Build AI agents with tools, streaming, and multi-agent composition in TypeScript | TypeScript |
| [opper-cli](./opper-cli/) | Call functions, manage indexes, track usage, and configure models from the terminal | Bash |

## How Skills Work

Skills use **progressive disclosure** to manage agent context efficiently:

1. **Discovery**: At startup, the agent loads only the `name` and `description` from each skill's frontmatter (~100 tokens each)
2. **Activation**: When your task matches a skill's keywords (e.g., "build with Opper in Python"), the agent reads the full `SKILL.md` into context
3. **On-demand**: Reference files in `references/` are loaded only when the agent needs deeper information

There is no central manifest — each subfolder containing a `SKILL.md` is a skill. The README is for humans only.

## What is Opper?

Opper is a task completion platform for building reliable AI integrations. It provides:

- **Declarative task completion** - Describe what you want, get structured results
- **Multi-model routing** - Use any LLM provider through a single API
- **Knowledge bases** - Semantic search and retrieval with vector embeddings
- **Observability** - Full tracing and monitoring of AI operations
- **Agent framework** - Build autonomous agents with tool use and reasoning loops

## Links

- [Documentation](https://docs.opper.ai)
- [Platform](https://platform.opper.ai)
- [GitHub](https://github.com/opper-ai)

## License

MIT
