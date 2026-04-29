# Opper Skills

Agent Skills for working with [Opper](https://opper.ai). Compatible with any agent that follows the [Agent Skills](https://agentskills.io) standard (Claude Code, Copilot CLI, Codex, Cline, Windsurf, …).

Three skills, one philosophy: **point at the live source of truth, don't duplicate it.** Each skill ships only what an agent can't infer from upstream — a tiny canonical example, the non-obvious gotchas, and a pointer table to the real docs.

## The skills

| Skill | What it covers | Source of truth |
|---|---|---|
| [`opper-cli`](./opper-cli/) | The `opper` command-line tool: calling functions, indexes, traces, models, usage, config | [github.com/opper-ai/cli](https://github.com/opper-ai/cli) and `opper --help` |
| [`opper-sdks`](./opper-sdks/) | The unified `opperai` packages for Python and TypeScript, including agents | [github.com/opper-ai/opper-sdks](https://github.com/opper-ai/opper-sdks) |
| [`opper-api`](./opper-api/) | The Opper REST API, gateway and platform concepts, models, compat endpoints, migration | [docs.opper.ai](https://docs.opper.ai) and `https://api.opper.ai/v3/openapi.yaml` |

> **Coming from older skills?** The previous `opper-python-sdk`, `opper-node-sdk`, `opper-python-agents`, and `opper-node-agents` skills have been folded into `opper-sdks` — agents are now part of the unified SDK package, not a separate one.

## Example prompts

Once a skill is installed, your agent will activate it automatically when you say things like:

**`opper-cli`**
- "Sign me in to Opper from the terminal."
- "Launch Claude Code through Opper so my traces show up."
- "Install all the bundled Opper skills into Claude Code."
- "Show my Opper spend this month grouped by model."
- "Create an Opper index and add this markdown file to it."

**`opper-sdks`**
- "Add an Opper `call` to this Python script that returns structured output."
- "Wire up streaming with the TypeScript SDK."
- "Build an Opper agent with a `get_weather` tool."
- "Wrap this pipeline in an Opper trace so I can see the steps."

**`opper-api`**
- "What models does Opper support?"
- "Migrate this OpenRouter code to Opper."
- "Show me the raw HTTP for an Opper task call with an output schema."
- "What's the difference between `/v3/call` and the `/v3/compat` endpoints?"

## Install

### Claude Code

```bash
# All three skills
npx skills add opper-ai/opper-skills

# Or pick what you need
npx skills add opper-ai/opper-skills/opper-cli
npx skills add opper-ai/opper-skills/opper-sdks
npx skills add opper-ai/opper-skills/opper-api
```

### Manual install

A skill is just a folder with a `SKILL.md` placed under your agent's skills directory. Copy or symlink:

```bash
git clone https://github.com/opper-ai/opper-skills.git

# Project-local
mkdir -p .claude/skills
ln -s "$(pwd)/opper-skills/opper-sdks" .claude/skills/opper-sdks

# User-global (Claude Code)
ln -s "$(pwd)/opper-skills/opper-sdks" ~/.claude/skills/opper-sdks
```

### Other agents

The same folders work in:

- **GitHub Copilot CLI** — `.github/skills/` (project) or `~/.copilot/skills/` (global); also reads `.claude/skills/`.
- **Cline** — `.cline/skills/` (project) or `~/.cline/skills/` (global).
- **OpenAI Codex** — `.codex/skills/` (project) or `~/.codex/skills/` (global).
- **Windsurf** — `.windsurf/rules/` (copy `SKILL.md` as a rule).
- Any other agent following the [Agent Skills](https://agentskills.io) standard.

## How these skills work

Skills use **progressive disclosure** to keep the agent's context window lean:

1. **Discovery** — at startup the agent loads only the `name` and `description` from each skill's frontmatter (≈100 tokens each).
2. **Activation** — when your task matches a skill's description, the agent reads the full `SKILL.md`.
3. **On-demand** — files under `references/` are loaded only when the SKILL.md tells the agent it needs them.

That's why each `SKILL.md` here is short and points outward. Heavy detail lives in upstream docs and example files; the live OpenAPI spec is always the definitive reference for the API.

## What is Opper?

Opper is a **gateway** in front of LLM providers plus a **control plane** for the things you build on top: functions, knowledge bases, tracing, evaluations, and custom models. One key, one bill, one trace surface across providers — see [docs.opper.ai/overview/about](https://docs.opper.ai/overview/about) for the longer version.

## Updating

```bash
# Installed via npx
npx skills update

# Cloned manually
cd opper-skills && git pull
```

## Development

### Pre-push hook

```bash
git config core.hooksPath .githooks
```

The hook runs `scripts/validate-skills.sh`, which checks that each `SKILL.md`:

- has a frontmatter `name` matching its directory and a non-empty `description`
- keeps `description` under 1024 characters
- keeps the body under 500 lines

Run it manually any time:

```bash
bash scripts/validate-skills.sh
```

## License

MIT

## Links

- [Documentation](https://docs.opper.ai)
- [Platform](https://platform.opper.ai)
- [Cookbook](https://github.com/opper-ai/opper-cookbook)
- [GitHub org](https://github.com/opper-ai)
