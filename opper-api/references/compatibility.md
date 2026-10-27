# Provider-compatible endpoints

Opper exposes drop-in replacements for several popular LLM APIs under `/v3/compat/...`. They are **fully compliant** with each provider's spec — same request bodies, same response shapes — but every call goes through the Opper gateway, which means unified billing, model fall-backs, tracing, and the rest of the control plane without changing client code.

For exact request and response shapes, fetch:

- The upstream provider's own spec (the canonical truth for the payload).
- `https://api.opper.ai/v3/openapi.yaml` for any Opper-specific request headers and the response wrapper.

## Quick rule

If the user already has working OpenAI / Anthropic / etc. code, **don't rewrite it**. Rebase the SDK onto `https://api.opper.ai/v3/compat` and swap the API key. Two lines.

## The endpoints

| Opper endpoint | Drop-in for | Opper docs |
|---|---|---|
| `POST /v3/compat/chat/completions` | OpenAI Chat Completions | [chat-completions](https://docs.opper.ai/v3-api-reference/compatibility/chat-completions) |
| `POST /v3/compat/responses` | OpenAI Responses | [create-response](https://docs.opper.ai/v3-api-reference/compatibility/create-response) |
| `POST /v3/compat/openresponses` | OpenResponses | [openresponses](https://docs.opper.ai/v3-api-reference/compatibility/openresponses) |
| `POST /v3/compat/v1/messages` | Anthropic Messages | [create-message](https://docs.opper.ai/v3-api-reference/compatibility/create-message) |
| `POST /v3/compat/v1beta/interactions` | Google Interactions | [create-interaction](https://docs.opper.ai/v3-api-reference/compatibility/create-interaction) |
| `POST /v3/compat/embeddings` | OpenAI Embeddings | (see spec) |

## Why `/v3/compat` is the SDK base URL

The compat tree is laid out so each SDK's natural appended path resolves to a real endpoint when the SDK's base URL is set to `https://api.opper.ai/v3/compat`:

| SDK | SDK appends | Resolves to |
|---|---|---|
| OpenAI Python / Node | `/chat/completions` | `…/v3/compat/chat/completions` |
| OpenAI Python / Node | `/responses` | `…/v3/compat/responses` |
| OpenAI Python / Node | `/embeddings` | `…/v3/compat/embeddings` |
| Anthropic Python / Node | `/v1/messages` | `…/v3/compat/v1/messages` |

A single base URL works for both OpenAI and Anthropic SDKs.

## Curl seeds

```bash
# OpenAI Chat Completions
curl -s https://api.opper.ai/v3/compat/chat/completions \
  -H "Authorization: Bearer $OPPER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "openai/gpt-4o", "messages":[{"role":"user","content":"Hello"}]}'

# Anthropic Messages
curl -s https://api.opper.ai/v3/compat/v1/messages \
  -H "Authorization: Bearer $OPPER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "anthropic/claude-sonnet-4.6", "max_tokens": 1024,
       "messages":[{"role":"user","content":"Hello"}]}'
```

## Auth header note

Opper reads the key from `Authorization: Bearer ...`, which is what the OpenAI SDK sends. The vendor-protocol routes also read that vendor's own header: `x-api-key` on the Anthropic Messages endpoints, `x-goog-api-key` on the Gemini ones. So the Anthropic and Google SDKs authenticate with just their normal API key, no header override. See [migration.md](migration.md).

## Opper-specific request and response headers

Compat endpoints accept several `X-Opper-*` request headers (function name for tracing, parent span ID, guardrail config) and return `X-Opper-Cost` on the response. The exact list is in the spec at the parameters block of each compat operation — consult `https://api.opper.ai/v3/openapi.yaml`.

## Model identifiers

Compat endpoints use Opper's `provider/model` form: `openai/gpt-4o`, `anthropic/claude-sonnet-4.6`, etc. List the live set with `curl -s https://api.opper.ai/v3/models` (no auth required).

## Structured output, media, and more

Everything is on the gateway, not a separate API:

- **Structured output** — add `response_format: {type: "json_schema", json_schema: {...}}` to a compat chat call; the model returns schema-validated JSON.
- **Vision / PDF input** — send `image_url` / `file` content parts to a model whose capabilities include `vision` / `pdf`.
- **Media generation** — dedicated endpoints: `POST /v3/images`, `POST /v3/audio/speech`, `POST /v3/audio/transcriptions`, `POST /v3/videos`.
- **Bulk, non-urgent jobs**: `POST /v3/batches` at about half price; see "Batches" below.
- **Multi-model fall-back** — define a Route alias in the platform that maps one name to an ordered backup chain.

See the `opper-api` SKILL.md for the full endpoint map.

## Batches: bulk, non-urgent work at about half price

For work nobody waits on (evals, backfills, classification), use `POST /v3/batches` instead of looping over the compat endpoints. It runs on the provider's own batch API and costs about half the synchronous price, billed once when the batch finishes. Results arrive within 24 hours.

```bash
curl -s https://api.opper.ai/v3/batches \
  -H "Authorization: Bearer $OPPER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"endpoint": "/v1/chat/completions", "model": "openai/gpt-5.4-mini",
       "completion_window": "24h", "metadata": {"job": "nightly-eval"},
       "requests": [{"custom_id": "row-1", "body": {"messages": [{"role": "user", "content": "Hello"}]}}]}'
# 202 with the batch object; poll GET /v3/batches/{id} until status is completed, expired or cancelled
```

- `endpoint`: `/v1/chat/completions`, `/v1/responses` or `/v1/embeddings` for OpenAI models; `/v1/messages` for Claude (each `body` is a normal Anthropic Messages body, minus `model`). Bodies pass through untranslated, so the body must match the model's provider. One `model` per batch; `provider.only` pins a batch endpoint.
- `custom_id`: 1 to 64 letters, digits, `-` or `_`. Limits: 50,000 requests and 100 MiB per batch (413 over either; split it).
- Spend: a batch is charged when it finishes, so it is refused at submit with 402 (`estimated_cost_usd`, `available_usd`) when its worst case (each request at its `max_tokens`, or the model's maximum output) plus the batches still running exceeds the balance or a budget. Set `max_tokens` on every request. Free-plan orgs cannot batch (402 `plan_required`). Hosted tools (web search and fetch, file search, code execution, image generation, remote MCP) are refused with 400; function and client tools work. So is any reference to state stored at the provider (`previous_response_id`, `conversation`, a stored `prompt`, `container`, `store: true`, a `file_id` in the input): send content inline.
- Not supported: `stream: true`, `callback_url` (both 400), and cancel.
- Reading: `GET /v3/batches/{id}` returns `results` inline once ended; `GET /v3/batches/{id}/results?cursor=&limit=` pages them (follow `next_cursor`); `GET /v3/batches?after=` lists the project's batches. `DELETE /v3/batches/{id}` removes a finished batch and its results (409 while running).
- **Data handling:** batches are **not zero data retention**. The provider holds the content while the batch runs (OpenAI and Anthropic keep batch data outside ZDR), and batches run in the US only for now. Opper keeps results for the project's retention period, at most 30 days (24 hours for projects with retention 0). A model with no batch endpoint gets a 404 at submit; an org whose rules exclude its batch endpoints gets a 403. Don't batch data that must stay ZDR or in the EU.
- The OpenAI SDK's files-based `client.batches` (JSONL upload, `input_file_id`) does **not** work against it; call `/v3/batches` over plain HTTP. List batchable models with `GET /v3/models?service_tier=batch`.

## Where to look next

| For | Look at |
|---|---|
| Exact request and response shapes | upstream provider's spec, plus `https://api.opper.ai/v3/openapi.yaml` |
| Migrating from a specific gateway | [migration.md](migration.md) |
| The full endpoint map (media, realtime, roundtable) | the `opper-api` SKILL.md |
