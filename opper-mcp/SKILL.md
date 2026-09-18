---
name: opper-mcp
description: >
  Use the Opper MCP server to connect a coding agent to Opper, discover models,
  set up projects and runtime keys, manage Control Plane rules, inspect usage
  and traces, or test models with real inference through MCP. Prefer this
  skill for agent-assisted Opper setup and platform operations. Use opper-cli
  for explicit CLI or shell workflows and launching an agent's own inference
  through Opper; use opper-api or opper-sdks for application integration.
metadata:
  category: sub-skill
  parent: opper
---

> Sub-skill of [`opper`](https://skills.opper.ai/) — start there for discovery and setup guidance.
> Source: https://github.com/opper-ai/opper-skills/blob/main/opper-mcp/SKILL.md

# Opper MCP

The Opper MCP server gives your coding agent tools to operate Opper on your behalf. **Start with the live [connection instructions](https://opper.ai/mcp)** and your client's native MCP configuration. The connected server's instructions, tool descriptions, and input schemas are the source of truth; discover them rather than inventing tool names or arguments.

Use **`https://api.opper.ai/mcp`** for the remote HTTP account server with native OAuth. Default client setup needs only this URL, without a pasted API key or explicit scope list; the user selects permissions in Opper. **`https://docs.opper.ai/mcp`** is a separate documentation-only server and does not manage an account or run inference.

Connecting MCP gives an agent Opper tools. Routing the agent's own model traffic through Opper is a separate workflow: load `opper-cli` for `opper launch` or `opper-api` for provider-compatible endpoints.

## Connect and select context

1. Reuse an existing connection. Otherwise follow the live connection page using native client OAuth. The user handles browser login, organization selection, and consent; never request pasted tokens.
2. Read the available tools and server instructions. Public `list_models` and `get_guide` help before signup. After authorization, start with `get_context`, verify the authorized organization, and select the intended project. A different organization requires a new OAuth organization selection. Reuse a suitable project rather than creating duplicates.
3. Request only permissions needed for the user's task through native OAuth and fresh browser consent. Read-only is selected initially and excludes inference. **Build and manage** enables `call_model`, which requires `runtime:call`. Missing tools may reflect missing permissions; do not treat that as unsupported functionality. Stop if the user denies or cancels consent.

Use `get_guide` for current workflows: `getting_started`, `connect_app`, `structured_output`, `rules`, and `debugging`. Before changing rules, inspect `get_rule_vocabulary` and inherited policy. Use a stable `idempotency_key` for each `create_api_key` or `create_rule` operation and reuse identical arguments after uncertain results.

## Test a model through MCP

`call_model` performs real, billed, non-streaming inference with text messages and optional structured output. It does not require exposing a runtime secret to the agent.

1. Discover an exact catalog model ID with `list_models`. Call `check_model_access` for that catalog model and project before creating credentials or calling it. This preflight supports catalog IDs, not dynamic routes or BYOK models. An existing deployed `dynamic/<route-name>` can be used with `call_model`; inspect its project policy and handle the actual call result rather than passing the route name to `check_model_access`. This reports known access checks, **not guaranteed provider availability or inference success**. Effective policy needs `controls:read`; if it reports `policy.requires_authorization`, follow `get_allowed_models` to request the missing consent.
2. Reuse a suitable runtime key or create one with `create_api_key`, keeping `return_secret: false` (the default). Keep the returned integer key ID and project UUID.
3. Follow the live `call_model` schema. Its required arguments are `uuid` (project UUID), `id` (runtime key ID), `model`, and `messages` (text entries with `role` and `content`). Optional arguments include `max_tokens`, `temperature`, and `response_format`. For the first test, use a short prompt and a small token limit.
4. Confirm the actual response. For typed output, fetch `get_guide` with topic `structured_output`, use `json_object` or `json_schema` as documented, and validate the returned content against the intended shape. Compare models by repeating the same prompt with selected catalog IDs, bounded by the requested test scope and budget; do not start an open-ended benchmark.
5. Inspect costs with `get_usage`. Use `list_traces` / `get_trace` when the project retains traces; zero-retention calls still appear in usage. Read errors before retrying and distinguish policy denial from provider or inference failure.

For streaming, advanced tool calling, multimodal generation, or realtime, load `opper-api`, `opper-sdks`, or `opper-multimodal` and use their actual application integration path.

## Deliver a key to a local application privately

MCP key creation omits runtime secrets by default and returns an ID suitable for `call_model`. For a local app that needs `OPPER_API_KEY`, use the CLI's private file delivery rather than returning a raw secret in a tool result:

```bash
opper keys create --project <uuid> --name <name> --output <env-file>
```

Load `opper-cli` for installation and run `opper keys create --help` for current options, including `--mcp-url` when using a configured server. This command requests its own browser consent and writes the key privately. Preserve existing environment files; do not read the resulting file or print the key in the conversation. Do not set `return_secret: true` unless the user explicitly needs a raw secret and the client can deliver it privately.

Disconnecting OAuth does not revoke runtime keys. Delete disposable test keys separately when no longer needed. After the user disconnects, reconnect only on a new request.
