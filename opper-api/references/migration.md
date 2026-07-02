# Migrating to Opper's compat endpoints

Most migrations are a **base URL + API key swap**. The compat tree at `/v3/compat/...` is shaped so that pointing a stock provider SDK at `https://api.opper.ai/v3/compat` works without changing your call sites.

For exact provider-side payload shapes, follow each provider's own spec. This file documents only what differs at the Opper boundary — plus the one migration that isn't a base-URL swap: moving off Opper's own legacy `/call`.

## From Opper's own `/call` — `POST /v3/call` or the legacy v2 Python SDK

`/call` (Opper's task-completion endpoint, also what the legacy v2 Python SDK's `opper.call(...)` hits) is **being sunset**. The replacement is a compat chat endpoint with structured output as a parameter — same models, same tracing and control plane, standard OpenAI shape. Don't point new integrations at `/call`; migrate existing ones.

Before — a typical structured `/v3/call`:

```bash
curl -s -X POST https://api.opper.ai/v3/call \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{
    "name": "extract_room_details",
    "instructions": "Extract details about the room described in the text.",
    "model": "openai/gpt-5-mini",
    "input": {"text": "The corner office on floor 3 fits 8 people and has a projector."},
    "output_schema": {"type": "object", "properties": {
      "floor": {"type": "integer"},
      "capacity": {"type": "integer"},
      "equipment": {"type": "array", "items": {"type": "string"}}
    }, "required": ["floor", "capacity", "equipment"]}
  }'
```

After — the same task on `/v3/compat/chat/completions`:

```bash
curl -s -X POST https://api.opper.ai/v3/compat/chat/completions \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -H "X-Opper-Name: extract_room_details" \
  -d '{
    "model": "openai/gpt-5-mini",
    "messages": [
      {"role": "system", "content": "Extract details about the room described in the text."},
      {"role": "user", "content": "The corner office on floor 3 fits 8 people and has a projector."}
    ],
    "response_format": {"type": "json_schema", "json_schema": {
      "name": "room_details",
      "schema": {"type": "object", "properties": {
        "floor": {"type": "integer"},
        "capacity": {"type": "integer"},
        "equipment": {"type": "array", "items": {"type": "string"}}
      }, "required": ["floor", "capacity", "equipment"]}
    }}
  }'
```

Field-by-field:

| `/v3/call` | Compat chat completions |
|---|---|
| `name` | `X-Opper-Name` request header — keeps named-function tracing and guardrail function-scope filtering |
| `instructions` | `system` message |
| `input` | `user` message — JSON-encode structured input into the message content |
| `output_schema` | `response_format: {type: "json_schema", json_schema: {name, schema}}` |
| `model` (string or fallback array) | `model` — same `provider/model` form; for fallback chains, define a Route alias in the platform |
| response `data` | `choices[0].message.content` — a JSON **string**; parse it |
| `meta.cost` | `usage.opper.cost.total` in the body, and the `X-Opper-Cost` response header |
| `meta.trace_uuid` | `meta.trace_uuid` — traces work identically, visible at [platform.opper.ai](https://platform.opper.ai) |

In Python, the legacy SDK call maps onto the stock OpenAI SDK:

```python
# Before (legacy opper.call)
result = opper.call(
    "extract_room_details",
    instructions="Extract details about the room described in the text.",
    input={"text": "..."},
    output_schema=RoomDetails,   # Pydantic model or JSON Schema
)
room = result.data

# After (OpenAI SDK against /v3/compat)
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://api.opper.ai/v3/compat",
    api_key=os.environ["OPPER_API_KEY"],
    default_headers={"X-Opper-Name": "extract_room_details"},
)
resp = client.chat.completions.parse(   # .parse() takes the Pydantic model directly
    model="openai/gpt-5-mini",
    messages=[
        {"role": "system", "content": "Extract details about the room described in the text."},
        {"role": "user", "content": "..."},
    ],
    response_format=RoomDetails,
)
room = resp.choices[0].message.parsed
```

Notes:

- **`.parse()` vs `.create()`** — the OpenAI SDK's `parse()` accepts a Pydantic model and returns `message.parsed`, the closest ergonomic match to `result.data`. With plain `create()` + a raw `json_schema`, parse `choices[0].message.content` yourself.
- **`strict: true`** on `json_schema` follows OpenAI's rules: every property must be listed in `required` and objects need `additionalProperties: false`. Leave `strict` off to keep a `/call`-style loose schema.
- **Any compat surface works** — Anthropic Messages with a forced tool schema, OpenAI Responses with `text.format`, etc. Chat completions is the shortest hop from `/call`.

## From OpenRouter (OpenAI-compatible)

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://api.opper.ai/v3/compat",
    api_key=os.environ["OPPER_API_KEY"],
)

resp = client.chat.completions.create(
    model="anthropic/claude-sonnet-4.6",
    messages=[{"role": "user", "content": "Hello"}],
)
```

That's it. Verify the model identifier with `curl -s https://api.opper.ai/v3/models` — provider-side names sometimes differ between gateways.

## From OpenAI

Same code change as OpenRouter — point `base_url` at `https://api.opper.ai/v3/compat`. The OpenAI SDK appends `/chat/completions`, `/responses`, `/embeddings`, all of which exist on the compat tree. Use Opper's `provider/model` identifier form.

For schema-constrained output, add `response_format: {type: "json_schema"}` to the compat call — no separate endpoint. For multi-model fall-back, define a Route alias in the platform that maps one name to an ordered backup chain.

## From Anthropic

Anthropic SDK users can point at the compat tree, but the Anthropic SDK sends `x-api-key` by default and Opper only accepts `Authorization: Bearer`. Override default headers:

```ts
import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic({
  baseURL: "https://api.opper.ai/v3/compat",
  apiKey: process.env.OPPER_API_KEY,
  defaultHeaders: { Authorization: `Bearer ${process.env.OPPER_API_KEY}` },
});
```

The Anthropic SDK appends `/v1/messages`, which resolves to `/v3/compat/v1/messages` — a real endpoint on the spec.

## From other gateways (LiteLLM, Vercel AI SDK, custom)

Same pattern: base URL → `https://api.opper.ai/v3/compat`, key → Opper key. For LiteLLM, the `provider/model` identifier shape already lines up.

## Why migrate at all

- One bill, one key, one trace surface across providers.
- Multi-model fall-back via a Route alias (one name → an ordered backup chain).
- Multimodality (images, audio, video) and realtime voice behind the same key.
- Knowledge bases (on the v2 surface — `/v2/knowledge/...`) and tracing in the same control plane.

## Validation checklist

1. `curl -s https://api.opper.ai/v3/models` returns a list (no auth needed) — network and routing work.
2. A single chat / message round-trip succeeds against the compat endpoint with your Opper key.
3. Streaming works (SSE format is provider-compliant; events use `data: ...` and the stream ends with `[DONE]`).
4. Spans appear in the platform UI for those calls.

## Where to look next

| For | Look at |
|---|---|
| Compat endpoints, deeper | [compatibility.md](compatibility.md) |
| Live spec (v3) | `https://api.opper.ai/v3/openapi.yaml` |
| Media, realtime, roundtable endpoints | the `opper-api` SKILL.md |
| Coding assistant integrations | [docs.opper.ai/overview/integrations](https://docs.opper.ai/overview/integrations) |
