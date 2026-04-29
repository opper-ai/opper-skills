---
name: opper-cli
description: >
  Use the Opper CLI (`opper` command, npm package `@opperai/cli`) for terminal
  work with Opper: signing in, calling functions, managing knowledge bases
  (indexes), inspecting traces, tracking usage and costs, generating images,
  installing bundled skills, configuring AI code editors, and launching coding
  agents (Claude Code, OpenCode, Codex, Hermes, Pi) with their inference
  routed through Opper. Use this skill whenever the user mentions the `opper`
  command, the Opper CLI, opper-ai/cli, `@opperai/cli`, `opper launch`, or
  wants to do anything Opper-related from a terminal — even if they don't
  explicitly say "CLI". For exact arguments, always run `opper <subcommand>
  --help`; the help output is the authoritative reference.
---

# Opper CLI

The official Opper CLI, distributed as the npm package **`@opperai/cli`**. Source: [github.com/opper-ai/cli](https://github.com/opper-ai/cli). Requires Node.js ≥ 20.12.

The CLI is more than a thin wrapper over `/v3/call`. It also **launches coding agents** (Claude Code, OpenCode, Codex, Hermes, Pi) with their model traffic transparently routed through Opper, **installs bundled skills**, and **wires AI code editors** to Opper.

## Install

```bash
npm i -g @opperai/cli
opper --version
```

## Authenticate

```bash
opper login    # OAuth device flow — recommended
opper whoami   # confirm the active slot
```

State lives in `~/.opper/config.json` as a list of **slots**, each holding `api_key`, `base_url`, and the user metadata returned by the device flow. Pick a slot with `--key <slot>` on any command (default: `default`).

Manual key entry (no browser):

```bash
opper config add default <your-api-key>
opper config add staging <staging-key> --base-url https://...
opper config list
```

Resolution at request time: **`OPPER_API_KEY` env var > slot named by `--key` (or `default`)**.

## Always use `--help` — it is the source of truth

Subcommand surface area changes faster than this skill. Before guessing flags or argument order:

```bash
opper --help              # top-level command list, grouped by domain
opper <command> --help    # subcommands and flags
```

Run `opper` with no args for an interactive menu (Account · Agents · Skills · Opper).

## Top-level command groups

| Group | What it does |
|---|---|
| `login` / `logout` / `whoami` | OAuth device flow + slot inspection. |
| `config add/list/get/remove` | Manual slot management. |
| `call <name> <instructions> [input]` | Run an Opper function. Stdin if `input` omitted; `--model`, `--stream`. |
| `functions list/get/delete` | Manage saved functions. |
| `indexes list/get/create/delete/add/query` | Knowledge bases (a.k.a. indexes). |
| `models list/create/get/delete` | Built-in + custom (LiteLLM-backed) models. |
| `traces list/get/delete` | Inspect execution traces. |
| `usage list` | Token/cost analytics, optional CSV export. |
| `image generate <prompt>` | Generate an image. |
| `agents list` / `launch <agent>` | List and launch coding agents through Opper. |
| `editors list/opencode/continue` | Wire AI code editors to Opper. |
| `skills list/install/update/uninstall` | Install bundled Opper SKILL.md docs to `~/.claude/skills/` and `~/.codex/skills/`. |
| `version` | Print CLI version (also `--version` / `-v`). |

## Launching agents through Opper

`opper launch <agent>` is the headline new feature. Anything after the agent name is forwarded to the agent's CLI verbatim. Each agent is wired in differently — fetch the live README at [github.com/opper-ai/cli](https://github.com/opper-ai/cli) for the current matrix.

```bash
opper agents list             # NAME / DISPLAY / KIND / STATE / CONFIG / COMMAND
opper launch claude           # Claude Code (via ANTHROPIC_BASE_URL / ANTHROPIC_AUTH_TOKEN)
opper launch opencode         # OpenCode
opper launch codex            # OpenAI Codex
opper launch hermes           # Hermes (isolated HERMES_HOME so your real ~/.hermes/ is untouched)
opper launch pi               # Pi (pi.dev)
opper launch <agent> --install  # install the upstream agent if missing
```

Under the hood these all route to `/v3/compat/...` (see the `opper-api` skill).

## Global flags

| Flag | Description |
|---|---|
| `--key <slot>` | API key slot to use (default: `default`). |
| `--debug` | Verbose diagnostic output. |
| `--no-telemetry` | Disable anonymous telemetry. |
| `--no-color` | Disable ANSI colors. |
| `-v, --version` | Print CLI version. |
| `-h, --help` | Show help (grouped by domain). |

## Non-obvious gotchas

- **`OPPER_API_KEY` env var beats `--key`.** When the env var is set, the `--key <slot>` flag is silently ignored. Unset it to use a slot.
- **`opper call` argument order is `<function> <instructions> <input>`** — easy to flip.
- **Model identifiers use `provider/<id-with-dashes>`** (e.g. `anthropic/claude-sonnet-4-6`, `anthropic/claude-opus-4-7`, `openai/gpt-4o`) — **dashes, not dots**, even for versions. Custom models registered with `opper models create` are LiteLLM-backed. List the live set with `opper models list` or `curl -s https://api.opper.ai/v3/models`.
- **`indexes` is the CLI name for knowledge bases.** `opper indexes add <name> <content>` takes content as a positional arg (use `-` to read from stdin), not a `--content` flag.
- **`opper usage list` `--fields` does not accept `count`.** `cost` and `count` are always included automatically; valid `--fields` are `total_tokens`, `prompt_tokens`, `completion_tokens`.
- **Skills installer writes to two trees**: `~/.claude/skills/` and `~/.codex/skills/`. The Codex install also wires each skill into a managed `[[skills.config]]` sentinel block in `~/.codex/config.toml`.

## Where to look next

| For | Look at |
|---|---|
| Install, agents matrix, releases, license | [github.com/opper-ai/cli](https://github.com/opper-ai/cli) |
| Live argument and flag reference | `opper <command> --help` |
| The platform behind the CLI (compat endpoints, models) | the `opper-api` skill |
| Building Opper into application code | the `opper-sdks` skill |
