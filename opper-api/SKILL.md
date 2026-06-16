---
name: opper-api
description: >
  Use the Opper REST API directly (HTTP / curl / fetch) and as the source of
  truth for Opper platform concepts: the gateway, the control plane, available
  models, the OpenAI / Anthropic / Google / OpenResponses-compatible endpoints
  under /v3/compat, multimodal generation (images, audio, video), realtime
  voice, roundtable, streaming via SSE, tracing, and migration from other LLM
  gateways. Use this skill whenever the user asks about Opper concepts, what
  models Opper supports, API endpoints or signatures, raw HTTP integration,
  gateway behaviour, integrating Opper with a coding assistant, or
  compatibility / migration from OpenAI / OpenRouter / Anthropic — even if they
  only say "Opper" without "API". For any endpoint signature or payload
  question always recommend fetching the live OpenAPI spec at
  https://api.opper.ai/v3/openapi.yaml first.
category: sub-skill
parent: opper
---

> Sub-skill of [`opper`](https://skills.opper.ai/) — start there for discovery and setup guidance.
> Source: https://github.com/opper-ai/opper-skills/blob/main/opper-api/SKILL.md

# Opper API

Opper is a **gateway** in front of LLM providers plus a **control plane** for the things you build on top. The gateway is one connection to 300+ models across all major providers (OpenAI, Anthropic, Google, Mistral, …), EU-hosted and GDPR-compliant. The control plane covers five capabilities:

- **Route** — call any supported model through one key, no provider-specific SDKs or credentials.
- **Observe** — every call yields a trace with input, output, latency, cost, and model used; attach metrics and evaluations to track quality over time.
- **Steer** — improve quality through feedback loops; save good outputs as examples and build evaluation datasets.
- **Guard** — guardrails at the infrastructure level (PII removal, content filtering, budget limits) before data reaches the model.
- **Comply** — follows European data protection directives and security standards, including GDPR.

The HTTP API at `https://api.opper.ai` is the foundation — every SDK and the CLI talk to it.

Concepts: [docs.opper.ai/overview/about](https://docs.opper.ai/overview/about). Quickstart: [docs.opper.ai/overview/quickstart](https://docs.opper.ai/overview/quickstart).

## Pick your endpoint

One gateway, one key. Pick the endpoint by what you're building — the routing, governance, and tracing are the same underneath:

- **Text generation / chat / migrating from OpenAI, Anthropic, Google, or OpenResponses**: the compat endpoints under **`/v3/compat/...`**. Point your SDK's base URL there, keep your code, swap the key. This is the main path. See [references/compatibility.md](references/compatibility.md) and [references/migration.md](references/migration.md).
- **Structured output** (typed JSON out of a model): the standard **`response_format: {type: "json_schema"}`** on any compat chat endpoint — no separate endpoint.
- **Images** (generate / edit): **`POST /v3/images`** (synchronous).
- **Audio**: **`POST /v3/audio/speech`** (text-to-speech) and **`POST /v3/audio/transcriptions`** (speech-to-text).
- **Video** (generate): **`POST /v3/videos`** (asynchronous — returns an id + status URL to poll).
- **Realtime voice / audio over WebSocket**: **`wss://api.opper.ai/v3/realtime`** — see the [realtime quickstart](https://docs.opper.ai/build/realtime/quickstart). Bearer auth for server-side connections, or a minted ticket from `/v3/realtime-sessions` for browser clients.
- **Roundtable** (fan one prompt out to several models, then consolidate or compare): **`POST /v3/roundtable`** (beta).
- **Building an agent** (multi-step reasoning, tool use, multi-agent, MCP): switch to the **`opper-sdks` skill** and use the Agent SDK — `Agent`, `tool`, `Conversation` ship in the unified `opperai` package for both Python and TypeScript.
- **Knowledge bases / RAG**: see "Knowledge bases" below — they live on `/v2/knowledge/...`.

## The live v3 spec is the source of truth

**Default workflow for any API question — endpoint, parameter, field, capability, compliance attribute, query flag — that isn't immediately answered by this skill: grep the spec.** Don't guess, don't infer from docs pages, don't fall back to the browsable catalog. Both formats are unauthenticated and definitive:

```bash
curl -s https://api.opper.ai/v3/openapi.yaml   # YAML, easier to grep
curl -s https://api.opper.ai/v3/openapi.json   # JSON
```

Worked example — *"which Opper models have ZDR?"*:

```bash
# 1. Grep the spec for the term.
curl -s https://api.opper.ai/v3/openapi.yaml | grep -i -n -E 'zdr|retention'
# → reveals route.data_handling.zdr.status on model records
# → and the include=route query param on GET /v3/models that surfaces it

# 2. Call the endpoint with the right include.
curl -s -H "Authorization: Bearer $OPPER_API_KEY" \
  "https://api.opper.ai/v3/models?include=route" \
  | jq '.models[] | {id, zdr: .route.data_handling.zdr.status}'
```

Same pattern answers any "where is X" question — grep the spec, follow the schema to the endpoint, call it. (Knowledge bases live on a separate v2 surface — see "Knowledge bases" below.)

## Authenticate

```http
Authorization: Bearer $OPPER_API_KEY
```

Server URL: `https://api.opper.ai` (the `/v3` or `/v2` prefix is part of each path). Bearer is the **only** auth scheme — there is no `x-api-key`. Get a key at [platform.opper.ai](https://platform.opper.ai).

A few endpoints have `security: []` and don't require a key: `/health`, `/v3/openapi.yaml`, `/v3/openapi.json`, `/v3/models`.

## Canonical example — a compat chat completion

The main path is the OpenAI-compatible chat endpoint. The same shape works from any provider SDK pointed at `/v3/compat`.

```bash
curl -s -X POST https://api.opper.ai/v3/compat/chat/completions \
  -H "Authorization: Bearer $OPPER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5-mini",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

The response is the provider's native shape (here OpenAI's `chat.completion`). Models are addressed `provider/model`; you can call any model from any compat surface.

### Structured output

For typed JSON, add `response_format` — no separate endpoint:

```bash
curl -s -X POST https://api.opper.ai/v3/compat/chat/completions \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5-mini",
    "messages": [{"role": "user", "content": "Extract entities: Tim Cook announced Apple’s Austin office."}],
    "response_format": {"type": "json_schema", "json_schema": {"name": "entities", "schema": {
      "type": "object",
      "properties": {
        "people":    {"type": "array", "items": {"type": "string"}},
        "locations": {"type": "array", "items": {"type": "string"}}
      },
      "required": ["people", "locations"]
    }}}
  }'
```

The model's `content` comes back as a JSON string validated against the schema. Streaming: add `"stream": true` and read the `text/event-stream` (events prefixed `data: `, ending with `[DONE]`).

## Models — `GET /v3/models` (no auth required)

One of the most common reasons to use this skill. **The live endpoint is the most up-to-date list** — never hardcode model names:

```bash
curl -s https://api.opper.ai/v3/models
```

Two URLs, two audiences:

- **In code**: `https://api.opper.ai/v3/models` — programmatic discovery, returns JSON.
- **When talking to the user**: [opper.ai/models](https://opper.ai/models) — the browsable human catalog. Link this when recommending or discussing a model.

The default response is light. For compliance / data-handling / benchmark questions, add `?include=`:

| `include=` | Adds | What lives there |
|---|---|---|
| `route` (requires API key) | `route` object per model | `data_handling.zdr.status` (`always` / `enterprise`), `data_handling.training.default`, `data_handling.logging.retention_days`, `data_handling.third_party_access`, `gdpr.residency`, `gdpr.dpa_available`, `gdpr.transfer_mechanism`, plus `country` and `underlying_maker` |
| `maker` (public) | `maker` | Original weights creator (e.g. `meta` for Llama, `mistral` for Mistral) |
| `benchmarks` (public) | `benchmarks` | Public scores from artificialanalysis.ai |

Combine with commas, e.g. `?include=route,benchmarks`. Reach for `include=route` whenever the question is about ZDR, residency, retention, training opt-out, third-party access, or GDPR posture — **none of these fields appear in the default response.**

Filter by capability and type: `?capability=vision` / `?capability=pdf` (which chat models accept images / PDFs), `?type=image|tts|stt|video`. The modality endpoints below also have scoped discovery lists.

References: [docs.opper.ai/capabilities/models](https://docs.opper.ai/capabilities/models). On any compat call, pin `"model": "anthropic/claude-sonnet-4-6"`; for backup chains across models, set a Route alias in the platform.

## Provider-compatible endpoints — under `/v3/compat/...`

Drop-in replacements for several LLM APIs. The simplest migration: **point the SDK base URL at `https://api.opper.ai/v3/compat`**, use your Opper API key, and your existing code keeps working. Fully compliant with each upstream provider — see their spec for unfamiliar payloads.

| Endpoint | Compatible with | Opper docs |
|---|---|---|
| `POST /v3/compat/chat/completions` | OpenAI Chat Completions | [docs](https://docs.opper.ai/v3-api-reference/compatibility/chat-completions) |
| `POST /v3/compat/responses` | OpenAI Responses | [docs](https://docs.opper.ai/v3-api-reference/compatibility/create-response) |
| `POST /v3/compat/openresponses` | OpenResponses | [docs](https://docs.opper.ai/v3-api-reference/compatibility/openresponses) |
| `POST /v3/compat/v1/messages` | Anthropic Messages | [docs](https://docs.opper.ai/v3-api-reference/compatibility/create-message) |
| `POST /v3/compat/v1beta/interactions` | Google Interactions | [docs](https://docs.opper.ai/v3-api-reference/compatibility/create-interaction) |
| `POST /v3/compat/embeddings` | OpenAI Embeddings | (see spec) |

Curl seeds and SDK-rebasing tips: [references/compatibility.md](references/compatibility.md). Vision and PDF input ride on these endpoints too — send `image_url` / `file` content parts to a model whose capabilities include `vision` / `pdf`. See [docs.opper.ai/build/multimodal/vision-pdfs](https://docs.opper.ai/build/multimodal/vision-pdfs).

## Multimodal generation

Dedicated endpoints for producing media. `model` and the prompt/input are owned by Opper; a small set of high-level params is normalized; everything in `parameters` is forwarded verbatim to the provider. Generated output is saved to [Files](https://docs.opper.ai/build/multimodal/files) by default (`store: true`) and returned with a reusable `file_id` you can feed into later calls. Each has a scoped model-discovery list.

| Endpoint | Does | Discovery | Guide |
|---|---|---|---|
| `POST /v3/images` | Generate / edit images (sync) | `GET /v3/images/models` | [images](https://docs.opper.ai/build/multimodal/images) |
| `POST /v3/audio/speech` | Text-to-speech (sync) | `GET /v3/audio/models?type=tts` | [audio](https://docs.opper.ai/build/multimodal/audio) |
| `POST /v3/audio/transcriptions` | Speech-to-text (sync) | `GET /v3/audio/models?type=stt` | [audio](https://docs.opper.ai/build/multimodal/audio) |
| `POST /v3/videos` | Generate video (**async** — poll `status_url`) | `GET /v3/videos/models` | [video](https://docs.opper.ai/build/multimodal/video) |

```bash
# Image generation
curl -s -X POST https://api.opper.ai/v3/images \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "openai/gpt-image-1", "prompt": "a hot air balloon over green hills", "size": "1024x1024"}'

# Video is async: submit → poll
curl -s -X POST https://api.opper.ai/v3/videos \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "openai/sora-2", "prompt": "the balloon drifts at dawn"}'
# → 202 { "id": "...", "status_url": "https://api.opper.ai/v3/artifacts/{id}/status" }
```

Reuse media without re-uploading by passing a `file_id` (from a previous generation or an upload to `POST /v3/files`) anywhere a media source is accepted — `image`/`mask`/`reference_images` on images, `audio` on transcriptions, `image`/`video` on videos. Files: [docs.opper.ai/build/multimodal/files](https://docs.opper.ai/build/multimodal/files).

## Roundtable — `POST /v3/roundtable` (beta)

Send one `input` to several `models` in parallel and bring the answers back together. Resolution modes: `summary` (default; a consolidation model merges them), `fast` (no consolidation, read `model_results`), or `multiple_choice` (vote among `choices`). Guide: [docs.opper.ai/build/roundtable/overview](https://docs.opper.ai/build/roundtable/overview).

## Server-side web search

Run web search server-side (billed per search under `usage.opper.cost.tools`):

- **Portable** — add `{"type": "opper:web_search"}` to `tools[]` on any compat chat endpoint above. One entry that works on every model and returns that endpoint's native citation artifacts, so client code doesn't branch per provider. The `engine` field controls routing: `auto` (default; the model's native provider search where supported, else Opper's engine), `native` (require native, 400 otherwise), `opper` (always Opper's engine), or pin a backend with `jina` / `exa`. Other knobs: `max_results`, `max_uses`, `search_context_size` (`very_low` → `full`), `allowed_domains` / `excluded_domains`, `country`, `freshness`. Beta.
- **Native** — a provider's own shape (`web_search_20250305`, `{type:"web_search"}`, `{googleSearch:{}}`) forwards verbatim to the routed provider.
- **Standalone** — `POST /v3/tools/web/search` runs one search directly, no model and no agentic loop.

Authoritative field reference: the `CanonicalWebSearchTool` schema in the spec (`curl -s https://api.opper.ai/v3/openapi.yaml | grep -i -n CanonicalWebSearchTool`). Guide: [docs.opper.ai/build/gateway/web-search](https://docs.opper.ai/build/gateway/web-search).

## Other v3 surfaces

The v3 spec also covers tracing (`/v3/spans`, `/v3/traces`), generations, files (`/v3/files`), built-in web tools, and async artifacts (`/v3/artifacts/{id}/status`). Fetch the spec for shapes; this skill won't enumerate them — they change.

## Knowledge bases — on the v2 surface

Knowledge bases (indexes) live at `/v2/knowledge/...`, served from the same host with the same Bearer auth. They are **not** in `/v3/openapi.yaml`. For raw HTTP, fetch `https://api.opper.ai/v2/openapi.json`. For application code, the SDKs and CLI abstract this: `opper.knowledge.*` (Python / TS) and `opper indexes ...`.

## Migration from another LLM gateway

Moving from OpenRouter, OpenAI, Anthropic, or similar: see [references/migration.md](references/migration.md). Recap: point the base URL at `https://api.opper.ai/v3/compat` and use your Opper API key.

## Coding assistant integrations

For wiring Opper into Claude Code, Cursor, Copilot, Continue, etc., see the up-to-date list at [docs.opper.ai/overview/integrations](https://docs.opper.ai/overview/integrations).

## Non-obvious gotchas

- **One gateway, many endpoints.** Text/chat is `/v3/compat/...`; media generation has dedicated endpoints (`/v3/images`, `/v3/audio/*`, `/v3/videos`); realtime is a WebSocket. All share the same key and governance.
- **Compat endpoints live under `/v3/compat/...`**, not at `/v3/...`. SDK migrations should point base URL at `https://api.opper.ai/v3/compat`.
- **Auth is `Authorization: Bearer ...` only.** Anthropic SDKs send `x-api-key` by default — set the `Authorization` header explicitly when migrating.
- **Structured output is a parameter, not an endpoint** — use `response_format: {type: "json_schema"}` on a compat chat call.
- **Video is asynchronous.** `POST /v3/videos` returns `202` with a `status_url`; poll `GET /v3/artifacts/{id}/status` for the result. Images and audio are synchronous.
- **Generated media is stored by default** (`store: true`) and returns a reusable `file_id`; pass `store: false` to opt out.
- **Knowledge is v2, not v3.** Don't reach for `/v3/knowledge/...` — it does not exist.
- **The spec is the most up-to-date reference; the docs and this skill follow it.** This file rots; the spec doesn't.

## Where to look next

| For | Look at |
|---|---|
| Live, definitive endpoint shapes | `https://api.opper.ai/v3/openapi.yaml` |
| Concepts (Organization, Project, Call, Trace, Gateway, Control Plane) | [docs.opper.ai/overview/concepts](https://docs.opper.ai/overview/concepts) |
| Gateway behaviour (routing, compat) | [docs.opper.ai/overview/gateway](https://docs.opper.ai/overview/gateway) |
| Control Plane (Route / Observe / Steer / Guard / Comply) | [docs.opper.ai/control-plane/overview](https://docs.opper.ai/control-plane/overview) |
| Multimodality (images, audio, video, vision, files) | [docs.opper.ai/build/multimodal/overview](https://docs.opper.ai/build/multimodal/overview) |
| Realtime quickstart | [docs.opper.ai/build/realtime/quickstart](https://docs.opper.ai/build/realtime/quickstart) |
| Roundtable | [docs.opper.ai/build/roundtable/overview](https://docs.opper.ai/build/roundtable/overview) |
| Browsable model catalog (for user-facing recommendations) | [opper.ai/models](https://opper.ai/models) |
| Worked recipes in many languages | [github.com/opper-ai/opper-cookbook](https://github.com/opper-ai/opper-cookbook) |
| Provider-compatible endpoints, deeper | [references/compatibility.md](references/compatibility.md) |
| Migrating from OpenRouter / OpenAI / Anthropic | [references/migration.md](references/migration.md) |
| Calling the API from Python or TypeScript | the `opper-sdks` skill |
| Calling the API from a terminal | the `opper-cli` skill |
