# Migrating to Opper from another LLM gateway

Most migrations are a **base URL + API key swap**. The compat tree at `/v3/compat/...` is shaped so that pointing a stock provider SDK at `https://api.opper.ai/v3/compat` works without changing your call sites.

For exact provider-side payload shapes, follow each provider's own spec. This file documents only what differs at the Opper boundary.

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

For schema-constrained output, named functions with version history, or multi-model fall-back in a single call, prefer the native `POST /v3/call` (see the `opper-api` SKILL.md).

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
- Multi-model fall-back in a single request (native `/v3/call`).
- Functions and evaluations as platform primitives.
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
| Native `/v3/call` surface | the `opper-api` SKILL.md |
| Coding assistant integrations | [docs.opper.ai/overview/integrations](https://docs.opper.ai/overview/integrations) |
