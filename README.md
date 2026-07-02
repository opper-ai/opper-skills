# Opper Skills

Agent Skills for working with [Opper](https://opper.ai). Compatible with any agent that follows the [Agent Skills](https://agentskills.io) standard (Claude Code, Copilot CLI, Codex, Cline, Windsurf, …).

One philosophy: **point at the live source of truth, don't duplicate it.** Each skill ships only what an agent can't infer from upstream — a tiny canonical example, the non-obvious gotchas, and a pointer table to the real docs.

## The skills

| Skill | What it covers | Source of truth |
|---|---|---|
| [`opper`](./opper/) | **Entry point.** Discovers user intent, then routes to the right sub-skill. Owns setup, testing, and follow-up. | This repo |
| [`opper-cli`](./opper-cli/) | The `opper` command-line tool: calling functions, indexes, traces, models, usage, config | [github.com/opper-ai/cli](https://github.com/opper-ai/cli) and `opper --help` |
| [`opper-sdks`](./opper-sdks/) | The unified `opperai` packages for Python and TypeScript, including agents | [github.com/opper-ai/opper-sdks](https://github.com/opper-ai/opper-sdks) |
| [`opper-api`](./opper-api/) | The Opper REST API, gateway and platform concepts, models, compat endpoints, server-side tools, migration | [docs.opper.ai](https://docs.opper.ai) and `https://api.opper.ai/v3/openapi.yaml` |
| [`opper-multimodal`](./opper-multimodal/) | Media generation (images, audio, video, OCR), the `/v3/files` storage API, vision/PDF input, and realtime voice | [docs.opper.ai/build/multimodal](https://docs.opper.ai/build/multimodal/overview) and `https://api.opper.ai/v3/openapi.yaml` |

Start with `opper`. It figures out what you're trying to do, then loads the right sub-skill — by fetching it live from `https://skills.opper.ai/` if it isn't already installed locally.

> **Coming from older skills?** The previous `opper-python-sdk`, `opper-node-sdk`, `opper-python-agents`, and `opper-node-agents` skills have been folded into `opper-sdks` — agents are now part of the unified SDK package, not a separate one.

## Agent-assisted setup (no install)

Point any AI coding assistant (Claude Code, Cursor, Codex, Copilot, …) at the live index — it will walk through discovery → setup → test → follow-up:

```
Use curl to download, read and follow: https://skills.opper.ai/
```

Or fetch a specific skill directly:

```bash
curl -sL https://skills.opper.ai/opper-cli/SKILL.md
curl -sL https://skills.opper.ai/opper-sdks/SKILL.md
curl -sL https://skills.opper.ai/opper-api/SKILL.md
curl -sL https://skills.opper.ai/opper-multimodal/SKILL.md
```

Skills are served as plain markdown so agents read the full content (not a summary). The site is a mirror of this repo, deployed on every push to `main`.

## Example prompts

Once a skill is installed, your agent will activate it automatically when you say things like:

**`opper-cli`**
- "Sign me in to Opper from the terminal."
- "Launch Claude Code through Opper so my traces show up."
- "Install all the bundled Opper skills into Claude Code."
- "Show my Opper spend this month grouped by model."
- "Create an Opper index and add this markdown file to it."

**`opper-sdks`**
- "Make this Python script return structured output through Opper."
- "Migrate this `opper.call` code to the compat chat completions endpoint."
- "Wire up streaming with the TypeScript SDK."
- "Build an Opper agent with a `get_weather` tool."
- "Wrap this pipeline in an Opper trace so I can see the steps."

**`opper-api`**
- "What models does Opper support?"
- "Migrate this OpenRouter code to Opper."
- "Show me the raw HTTP for a compat chat call with structured output."
- "Add a server-side web search to my Opper chat call."

**`opper-multimodal`**
- "Generate an image with Opper."
- "Transcribe this audio file with Opper."
- "Make a short video from this prompt."
- "Run OCR on this PDF and give me markdown."
- "Set up a realtime voice session in the browser."

## Install

### Claude Code

```bash
# All five skills (recommended — installs the opper router + sub-skills)
npx skills add opper-ai/opper-skills

# Or pick what you need
npx skills add opper-ai/opper-skills/opper
npx skills add opper-ai/opper-skills/opper-cli
npx skills add opper-ai/opper-skills/opper-sdks
npx skills add opper-ai/opper-skills/opper-api
npx skills add opper-ai/opper-skills/opper-multimodal
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

### Build the static site locally

`scripts/build-site.sh` assembles the `_site/` directory exactly as it gets deployed to `https://skills.opper.ai`:

```bash
bash scripts/build-site.sh --dry-run   # validate frontmatter, don't write
bash scripts/build-site.sh             # assemble _site/
```

Every push to `main` runs this and deploys the output to S3 via CloudFront (see `.github/workflows/deploy.yml`).

## License

MIT

## Links

- [Skills index (live)](https://skills.opper.ai) — fetch any skill as plain markdown
- [Documentation](https://docs.opper.ai)
- [Platform](https://platform.opper.ai)
- [Cookbook](https://github.com/opper-ai/opper-cookbook)
- [GitHub org](https://github.com/opper-ai)
