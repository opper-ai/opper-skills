# Opper Skills

Agent Skills for building AI applications with [Opper](https://opper.ai). Compatible with 25+ AI coding agents via the [Agent Skills](https://agentskills.io) standard.

## Contents

- [Installation](#installation)
- [Available Skills](#available-skills)
- [Updating Skills](#updating-skills)
- [How Skills Work](#how-skills-work)
- [What is Opper?](#what-is-opper)
- [Links](#links)

## Installation

### Claude Code

Install all skills:

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

### Manual setup

Skills are just folders with a `SKILL.md` file placed in `.claude/skills/`. You can copy them directly:

```bash
# Clone the repo
git clone https://github.com/opper-ai/opper-skills.git

# Copy the skills you need into your project
mkdir -p .claude/skills
cp -r opper-skills/opper-python-sdk opper-skills/opper-python-agents .claude/skills/
```

Or symlink for local development (changes reflect immediately):

```bash
mkdir -p .claude/skills
ln -s /path/to/opper-skills/opper-python-sdk .claude/skills/opper-python-sdk
```

### GitHub Copilot

Copilot supports skills in `.github/skills/` (project) or `~/.copilot/skills/` (global). It also reads `.claude/skills/` for compatibility.

```bash
# Global installation
git clone https://github.com/opper-ai/opper-skills.git
ln -s $(pwd)/opper-skills/opper-python-sdk ~/.copilot/skills/opper-python-sdk

# Project installation
mkdir -p .github/skills
ln -s /path/to/opper-skills/opper-python-sdk .github/skills/opper-python-sdk
```

### Cline

Enable the experimental Skills feature in Cline settings. Skills are loaded from `.cline/skills/` (project) or `~/.cline/skills/` (global).

```bash
# Global installation
git clone https://github.com/opper-ai/opper-skills.git
ln -s $(pwd)/opper-skills/opper-python-sdk ~/.cline/skills/opper-python-sdk
```

### OpenAI Codex

Codex loads skills from `.codex/skills/` (project) or `~/.codex/skills/` (global).

```bash
# Global installation
git clone https://github.com/opper-ai/opper-skills.git
ln -s $(pwd)/opper-skills/opper-python-sdk ~/.codex/skills/opper-python-sdk

# Project installation
mkdir -p .codex/skills
ln -s /path/to/opper-skills/opper-python-sdk .codex/skills/opper-python-sdk
```

### Windsurf

Windsurf uses `.windsurf/rules/` for workspace rules or `AGENTS.md` files for directory-scoped instructions.

```bash
mkdir -p .windsurf/rules
cp /path/to/opper-skills/opper-python-sdk/SKILL.md .windsurf/rules/opper-python-sdk.md
```

### Other Agents

Any agent supporting the [Agent Skills](https://agentskills.io) standard can use these skills. Place the skill folders in the agent's configured skills directory.

Browse compatible agents at [skills.sh](https://skills.sh).

## Available Skills

| Skill | Description | Language |
|-------|-------------|----------|
| [opper-api](./opper-api/) | Call the Opper REST API directly with any HTTP client | HTTP |
| [opper-python-sdk](./opper-python-sdk/) | Task completion, knowledge bases, and tracing with the Opper Python SDK | Python |
| [opper-node-sdk](./opper-node-sdk/) | Task completion, knowledge bases, and tracing with the Opper Node SDK | TypeScript |
| [opper-python-agents](./opper-python-agents/) | Build AI agents with tools, memory, and multi-agent composition in Python | Python |
| [opper-node-agents](./opper-node-agents/) | Build AI agents with tools, streaming, and multi-agent composition in TypeScript | TypeScript |
| [opper-cli](./opper-cli/) | Call functions, manage indexes, track usage, and configure models from the terminal | Bash |

## Updating Skills

Skills don't auto-update. To get the latest versions:

```bash
# If installed via npx skills
npx skills update

# If cloned/symlinked manually
cd opper-skills && git pull
```

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

## Development

### Pre-push hook

Enable the shared pre-push hook to validate `SKILL.md` files before pushing:

```bash
git config core.hooksPath .githooks
```

You can also run the validation manually:

```bash
bash scripts/validate-skills.sh
```

## License

MIT
