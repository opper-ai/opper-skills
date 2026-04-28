---
name: opper-api
description: >
  Use the Opper REST API directly (HTTP / curl / fetch) and as the source of
  truth for Opper platform concepts: the gateway, the control plane,
  available models, task completion (/v3/call), streaming via SSE, tracing,
  OpenAI / Anthropic / OpenResponses-compatible endpoints under /v3/compat,
  and migration from other LLM gateways. Use this skill whenever the user
  asks about Opper concepts, what models Opper supports, API endpoints or
  signatures, raw HTTP integration, gateway behaviour, integrating Opper
  with a coding assistant, or compatibility / migration from OpenAI /
  OpenRouter / Anthropic — even if they only say "Opper" without "API". For
  any endpoint signature or payload question always recommend fetching the
  live OpenAPI spec at https://api.opper.ai/v3/openapi.yaml first.
---

# Opper API

Opper is a **gateway** in front of LLM providers plus a **control plane** for the things you build on top. The gateway is one connection to 200+ models across all major providers (OpenAI, Anthropic, Google, Mistral, …). The control plane covers five capabilities:

- **Route** — call any supported model through one key, no provider-specific SDKs or credentials.
- **Observe** — every call yields a trace with input, output, latency, cost, and model used; attach metrics and evaluations to track quality over time.
- **Steer** — improve quality through feedback loops; save good outputs as examples and build evaluation datasets.
- **Guard** — guardrails at the infrastructure level (PII removal, content filtering, budget limits) before data reaches the model.
- **Comply** — follows European data protection directives and security standards, including GDPR.

The HTTP API at `https://api.opper.ai` is the foundation — every SDK and the CLI talk to it. The v3 surface self-identifies as **"Task API"** (v3.0.0).

Concepts: [docs.opper.ai/overview/about](https://docs.opper.ai/overview/about). Getting started: [docs.opper.ai/overview/getting-started](https://docs.opper.ai/overview/getting-started).

## Fetch the live v3 spec — first, always

For any question about endpoint shapes, payloads, or fields, fetch the spec. Both formats are unauthenticated and definitive:

```bash
curl -s https://api.opper.ai/v3/openapi.yaml   # YAML
curl -s https://api.opper.ai/v3/openapi.json   # JSON
```

The spec is the **definitive** answer; this skill, the docs, and the SDKs all derive from it. When in doubt, fetch it and grep for the operation. (Knowledge bases live on a separate v2 surface — see "Knowledge bases" below.)

## Authenticate

```http
Authorization: Bearer $OPPER_API_KEY
```

Server URL: `https://api.opper.ai` (the `/v3` or `/v2` prefix is part of each path). Bearer is the **only** auth scheme — there is no `x-api-key`. Get a key at [platform.opper.ai](https://platform.opper.ai).

A few endpoints have `security: []` and don't require a key: `/health`, `/v3/openapi.yaml`, `/v3/openapi.json`, `/v3/models`.

## Canonical example — task completion

`POST /v3/call` is the primary v3 endpoint. Both `name` and `input` are required.

```bash
curl -s -X POST https://api.opper.ai/v3/call \
  -H "Authorization: Bearer $OPPER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "extract_entities",
    "input": {"text": "Tim Cook announced Apple’s new office in Austin."},
    "instructions": "Extract named entities.",
    "output_schema": { "type": "object", "properties": {
      "people": {"type": "array", "items": {"type": "string"}},
      "locations": {"type": "array", "items": {"type": "string"}}
    }}
  }'
```

Response is shaped `{ "data": <result>, "meta": { ... } }` — the result is **always** in `data`, regardless of `output_schema`. `meta` carries `cost` (a number), `usage`, `trace_uuid`, `function_name`, `script_cached`, etc.; for the full `RunResponse` shape, fetch the spec. The endpoint may also return `202 Accepted` with a `PendingResponse` — poll the URL in `meta.pending_operations[*].status_url`.

Streaming: `POST /v3/call/stream` with `Accept: text/event-stream`. Each event is JSON prefixed with `data: ` and the stream ends with `[DONE]`.

## Models — `GET /v3/models` (no auth required)

One of the most common reasons to use this skill. **Always query the live endpoint**, don't hardcode model names:

```bash
curl -s https://api.opper.ai/v3/models
```

References: [docs.opper.ai/capabilities/models](https://docs.opper.ai/capabilities/models) · [list-models](https://docs.opper.ai/v3-api-reference/models/list-models). On any call, pin or fall back via `"model": "anthropic/claude-sonnet-4.6"` or `"model": ["anthropic/claude-sonnet-4.6", "openai/gpt-4o"]`. Identifiers follow the `provider/model` convention.

## Provider-compatible endpoints — under `/v3/compat/...`

Drop-in replacements for several LLM APIs. The simplest migration: **set the SDK base URL to `https://api.opper.ai/v3/compat`**, swap the API key, keep your code. Fully compliant with each upstream provider — fetch their spec for unfamiliar payloads.

| Endpoint | Compatible with | Opper docs |
|---|---|---|
| `POST /v3/compat/chat/completions` | OpenAI Chat Completions | [docs](https://docs.opper.ai/v3-api-reference/compatibility/chat-completions) |
| `POST /v3/compat/responses` | OpenAI Responses | [docs](https://docs.opper.ai/v3-api-reference/compatibility/create-response) |
| `POST /v3/compat/openresponses` | OpenResponses | [docs](https://docs.opper.ai/v3-api-reference/compatibility/openresponses) |
| `POST /v3/compat/v1/messages` | Anthropic Messages | [docs](https://docs.opper.ai/v3-api-reference/compatibility/create-message) |
| `POST /v3/compat/v1beta/interactions` | Google Interactions | [docs](https://docs.opper.ai/v3-api-reference/compatibility/create-interaction) |
| `POST /v3/compat/embeddings` | OpenAI Embeddings | (see spec) |

Curl seeds and SDK-rebasing tips: [references/compatibility.md](references/compatibility.md).

## Other v3 surfaces

The v3 spec also covers tracing (`/v3/spans`, `/v3/traces`), function management (`/v3/functions/...`), generations, built-in web tools, realtime, roundtable, and async artifacts. Fetch the spec for shapes; this skill won't enumerate them — they change.

## Knowledge bases — on the v2 surface

Knowledge bases (indexes) live at `/v2/knowledge/...`, served from the same host with the same Bearer auth. They are **not** in `/v3/openapi.yaml`. For raw HTTP, fetch `https://api.opper.ai/v2/openapi.json`. For application code, the SDKs and CLI abstract this: `opper.knowledge.*` (Python / TS) and `opper indexes ...`. Canonical SDK reference: `python/src/opperai/clients/knowledge.py` and `typescript/src/clients/knowledge.ts` in [opper-sdks](https://github.com/opper-ai/opper-sdks) — both note "proxied to v2 API".

## Migration from another LLM gateway

Moving from OpenRouter, OpenAI, Anthropic, or similar: see [references/migration.md](references/migration.md). Rule of thumb: base URL → `https://api.opper.ai/v3/compat`, key → your Opper key.

## Coding assistant integrations

For wiring Opper into Claude Code, Cursor, Copilot, Continue, etc., see the up-to-date list at [docs.opper.ai/overview/integrations](https://docs.opper.ai/overview/integrations).

## Non-obvious gotchas

- **Knowledge is v2, not v3.** Don't reach for `/v3/knowledge/...` — it does not exist.
- **Compat endpoints live under `/v3/compat/...`**, not at `/v3/...`. SDK migrations should point base URL at `https://api.opper.ai/v3/compat`.
- **Auth is `Authorization: Bearer ...` only.** Anthropic SDKs send `x-api-key` by default — override the default headers on migration.
- **`/v3/call` requires both `name` and `input`** in the body.
- **Result is always in `data`.** There is no `json_payload` field, and `output_schema` does not switch the response shape.
- **`cost` is a number**, not an object with `total / generation / platform` subfields.
- **`/v3/call` may return `202 Accepted`** with a `PendingResponse` for async work; check `meta.pending_operations`.
- **Spec first, docs second, this skill last.** This file rots; the spec doesn't.

## Where to look next

| For | Look at |
|---|---|
| Live, definitive endpoint shapes | `https://api.opper.ai/v3/openapi.yaml` |
| Conceptual overview of Opper (gateway + 5-pillar control plane) | [docs.opper.ai/overview/about](https://docs.opper.ai/overview/about) |
| Getting started end-to-end | [docs.opper.ai/overview/getting-started](https://docs.opper.ai/overview/getting-started) |
| Capability docs (models, knowledge, evals, …) | [docs.opper.ai/capabilities](https://docs.opper.ai/capabilities) |
| Worked recipes in many languages | [github.com/opper-ai/opper-cookbook](https://github.com/opper-ai/opper-cookbook) |
| Provider-compatible endpoints, deeper | [references/compatibility.md](references/compatibility.md) |
| Migrating from OpenRouter / OpenAI / Anthropic | [references/migration.md](references/migration.md) |
| Calling the API from Python or TypeScript | the `opper-sdks` skill |
| Calling the API from a terminal | the `opper-cli` skill |
