# Provider-compatible endpoints

Opper exposes drop-in replacements for several popular LLM APIs under `/v3/compat/...`. They are **fully compliant** with each provider's spec — same request bodies, same response shapes — but every call goes through the Opper gateway, which means unified billing, model fall-backs, tracing, and the rest of the control plane without changing client code.

For exact request and response shapes, fetch:

- The upstream provider's own spec (the canonical truth for the payload).
- `https://api.opper.ai/v3/openapi.yaml` for any Opper-specific request headers and the response wrapper.

## Quick rule

If the user already has working OpenAI / Anthropic / etc. code, **do not rewrite it for `/v3/call`**. Rebase the SDK onto `https://api.opper.ai/v3/compat` and swap the API key. Two lines.

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

Opper accepts only `Authorization: Bearer ...`. The Anthropic SDK sends `x-api-key` by default — when migrating, override default headers to send `Authorization`. See [migration.md](migration.md).

## Opper-specific request and response headers

Compat endpoints accept several `X-Opper-*` request headers (function name for tracing, parent span ID, guardrail config) and return `X-Opper-Cost` on the response. The exact list is in the spec at the parameters block of each compat operation — consult `https://api.opper.ai/v3/openapi.yaml`.

## Model identifiers

Compat endpoints use Opper's `provider/model` form: `openai/gpt-4o`, `anthropic/claude-sonnet-4.6`, etc. List the live set with `curl -s https://api.opper.ai/v3/models` (no auth required).

## When to prefer `/v3/call` over a compat endpoint

- **Schema-constrained output** — `/v3/call` has `output_schema` as a first-class field.
- **Named functions** with version history, evaluations, and the platform UI.
- **Multi-model fall-backs** in a single request: `"model": ["a", "b", "c"]`.

Compat endpoints stay closer to the upstream provider's behaviour and are best when migrating existing code.

## Where to look next

| For | Look at |
|---|---|
| Exact request and response shapes | upstream provider's spec, plus `https://api.opper.ai/v3/openapi.yaml` |
| Migrating from a specific gateway | [migration.md](migration.md) |
| The native `/v3/call` surface | the `opper-api` SKILL.md |
