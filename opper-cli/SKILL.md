---
name: opper-cli
description: >
  Use the Opper CLI (`opper` command) for terminal-based work with Opper:
  calling functions, managing knowledge bases (indexes), inspecting traces,
  configuring custom models, tracking usage and costs, and shell completion.
  Use this skill whenever the user mentions the `opper` command, the Opper
  CLI, opper-ai/cli, or wants to do anything Opper-related from a terminal —
  even if they don't explicitly say "CLI". For exact arguments, always run
  `opper <subcommand> --help`; the help output is the authoritative reference.
---

# Opper CLI

Single-binary CLI for the Opper platform. Source and install instructions live at [github.com/opper-ai/cli](https://github.com/opper-ai/cli).

## Install

The repo README is authoritative — install methods (Homebrew tap, binary download, source build) change there first. Verify the install with `opper version`.

## Authenticate

The CLI reads, in order:

1. **`OPPER_API_KEY`** environment variable (and optionally `OPPER_BASE_URL` for non-default hosts) — wins unconditionally if set.
2. **Config file** at `~/.oppercli`, profile selected by `--key <profile>` (default `default`):
   ```bash
   opper config add default <your-api-key>
   opper config add staging  <staging-key> --base-url https://...
   ```
3. **Interactive prompt** if neither is found.

Get a key from [platform.opper.ai](https://platform.opper.ai).

## Always use `--help` — it is the source of truth

Subcommand surface area changes faster than this skill. Before guessing flags or argument order:

```bash
opper --help              # top-level command list
opper <command> --help    # subcommands and flags
```

Common top-level commands: `call`, `functions`, `indexes`, `models`, `traces`, `usage`, `config`, `completion`, `version`. Don't memorise their flags — ask `--help`.

## Canonical example

```bash
opper call myfunction "respond in kind" "what is 2+2?"

# Pipe stdin as the input
echo "what is 2+2?" | opper call myfunction "respond in kind"

# Pin a specific model (use a real identifier from `curl -s https://api.opper.ai/v3/models`)
opper call --model anthropic/claude-haiku-4-5 myfunction "summarise this" "long text..."
```

Argument order is `opper call <function> <instructions> <input>`. The third arg is optional — if omitted, the CLI reads stdin.

## Non-obvious gotchas

- **`OPPER_API_KEY` env var beats `--key`.** When the env var is set, the `--key <profile>` flag is silently ignored. To use a config profile, unset the env var (or run via a wrapper that does).
- **`opper call` argument order is `<function> <instructions> <input>`** — easy to flip.
- **Model identifiers use `provider/model` form** (`anthropic/claude-haiku-4-5`, `openai/gpt-4o`, `azure/<deployment>`); custom models registered with `opper models create` are LiteLLM-backed. List the live set with `curl -s https://api.opper.ai/v3/models`.
- **`indexes` is the CLI name for knowledge bases** — same concept, different word in `opper`.

## Where to look next

| For | Look at |
|---|---|
| Install, releases, license | [github.com/opper-ai/cli](https://github.com/opper-ai/cli) |
| Live argument and flag reference | `opper <command> --help` |
| Worked example using the CLI | `examples/osh` in the source repo |
| The platform behind the CLI | the `opper-api` skill, or [docs.opper.ai](https://docs.opper.ai) |
| Building Opper into application code | the `opper-sdks` skill |
