---
name: opper-api
description: >
  Use the Opper REST API directly (HTTP / curl / fetch) and as the source of
  truth for Opper platform concepts: the gateway, the control plane, available
  models, the OpenAI / Anthropic / Google / OpenResponses-compatible endpoints
  under /v3/compat, structured output, server-side tools (web search),
  roundtable, streaming via SSE, tracing, and migration from other LLM
  gateways. Use this skill whenever the user asks about Opper concepts, what
  models Opper supports, API endpoints or signatures, raw HTTP integration,
  gateway behaviour, integrating Opper with a coding assistant, or
  compatibility / migration from OpenAI / OpenRouter / Anthropic, or migrating
  off Opper's own legacy /v3/call (opper.call) — even if they only say "Opper"
  without "API". For media generation (images, audio, video,
  OCR), files, and realtime voice, use the `opper-multimodal` skill instead.
  For any endpoint signature or payload question always recommend fetching the
  live OpenAPI spec at https://api.opper.ai/v3/openapi.yaml first.
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
- **Still on Opper's own `/call`** (`POST /v3/call`, or the legacy v2 Python SDK's `opper.call`)? It's **being sunset** — migrate to a compat chat endpoint with `response_format`. The field-by-field mapping is in [references/migration.md](references/migration.md).
- **Media generation** (images, audio / TTS / STT, video, OCR), **files**, and **realtime voice**: a separate surface — switch to the **`opper-multimodal` skill**. Quick map: images `POST /v3/images`, audio `POST /v3/audio/{speech,transcriptions}`, video `POST /v3/videos` (async), OCR `POST /v3/ocr`, files `/v3/files`, realtime `wss://api.opper.ai/v3/realtime`.
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
curl -s https://api.opper.ai/v3/openapi.yaml | grep -i -n zdr
# → reveals compliance.zdr on every GET /v3/models item — no include, no API key

# 2. Call the endpoint and derive the answer from the facts.
curl -s https://api.opper.ai/v3/models \
  | jq -r '.models[] | select(.compliance.zdr.logging == false and .compliance.zdr.moderation != true) | .id'

# Or print the facts per model and decide yourself.
curl -s https://api.opper.ai/v3/models | jq '.models[] | {id, zdr: .compliance.zdr}'
```

`compliance.zdr` is an object of five tri-state facts — `logging`, `moderation`, `caching`, `training`, `subprocessors` — each `true` (content is held / reaches that pipeline), `false` (it is not), or `null` (not established). There is no summary string; derive what you need. "ZDR by default" is `logging == false and moderation != true`. The same object sits on the `opper` block of `/v3/compat/models` items and, with a key, on the route object (`?include=route`, `/v3/providers?include=routes`).

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

The default response is light but every item carries a `compliance` block — `residency`, `country`, `inference_location`, `zdr` (the object above), `training`, `logging`, `moderation`, `caching`, `content_storage`, `dpa_available`, `third_party_access`, `transfer_mechanism`, `route_id`. That answers most ZDR / residency / GDPR questions without a key. For per-route evidence or benchmarks, add `?include=`:

| `include=` | Adds | What lives there |
|---|---|---|
| `route` (requires API key) | `route` object per model | The full service-route record: `data_handling.{training,logging,moderation,caching}` with `retention_days` / `storage_location` / `human_review`, `data_handling.subprocessors_read_content`, `gdpr.{residency,dpa_available,transfer_mechanism}`, `verification.status`, `sources`, `last_verified_at`, `underlying_maker` — plus the same `zdr` object as `compliance.zdr` |
| `maker` (public) | `maker` | Original weights creator (e.g. `meta` for Llama, `mistral` for Mistral) |
| `benchmarks` (public) | `benchmarks` | Public scores from artificialanalysis.ai |

Combine with commas, e.g. `?include=route,benchmarks`. Reach for `include=route` when you need retention days, storage location, verification status, or the sources behind a claim — `compliance` is the summary, `route` is the evidence.

Filter by capability and type: `?capability=vision` / `?capability=pdf` (which chat models accept images / PDFs), `?type=image|tts|stt|video`. The modality endpoints below also have scoped discovery lists.

References: [docs.opper.ai/capabilities/models](https://docs.opper.ai/capabilities/models).

### The `model` string — pools, pins, aliases and routes

`GET /v3/models` returns one row per **provider**, not per model. Four things can go in the `model` field, all without special headers or flags:

| Form | Example | What it addresses |
|---|---|---|
| **Bare model name** — a *pool* | `"kimi-k3"` | Every provider serving that model. Opper picks one; the rest are failover |
| **Provider-qualified id** — a *pin* | `"tensorx/moonshotai/kimi-k3"` | Exactly that one provider row, no failover |
| **Org alias** — your own list | `"my-flash"` | An ordered list you defined: primary first, then fallbacks. CRUD at `/v2/models/aliases` |
| **Route** — a deployed graph | `"dynamic/my-route"` | Classification, branching, per-node fallbacks, versioned. Built in the platform UI (or `/management/v1/dynamic-routes` with a Management API Key) — but **calling** one only needs your normal project key |

**None of these is the default answer — pick per use case.** Pin for determinism (evals, a guaranteed jurisdiction or price, a provider-specific behaviour); pool for redundancy without thinking about it; alias to name your own policy once and reuse it; route when the decision depends on the request.

On pools specifically: **`model`** is the group key on each row (and the bare name you call), **`pooled`** is whether that row answers to it. `pooled: false` rows are fully callable by explicit id — they're just held out of bare-name routing, usually for a smaller context window or a pricier latency-tuned variant.

Two things that surprise people:

- **The response `model` field echoes what you sent** — a bare name, an alias, or a `dynamic/` route all come back verbatim, so it never reveals which provider ran. The trace does: `span.meta.model` carries the resolved `provider/provider_model_id`. For routes, the `X-Opper-Route-Model` response header answers it directly.
- **Identical requests with no `X-Opper-Trace-Id` all land on the same provider.** That's deliberate session affinity (keyed on your API key over a 30-minute window, for prompt-cache locality), not broken round-robin. Send a unique trace id per request to spread them.

Full mechanics — how the four compose, selection order, failover, alias and route management: [references/model-routing.md](references/model-routing.md).

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

Curl seeds and SDK-rebasing tips: [references/compatibility.md](references/compatibility.md). Vision and PDF input ride on these endpoints too — send `image_url` / `file` content parts to a model whose capabilities include `vision` / `pdf` (see the `opper-multimodal` skill, and [docs.opper.ai/build/multimodal/vision-pdfs](https://docs.opper.ai/build/multimodal/vision-pdfs)).

## Media generation, files & realtime → the `opper-multimodal` skill

Producing media (images, audio TTS/STT, video, OCR), the `/v3/files` storage API, sending images/PDFs **into** a model, and realtime two-way voice are a separate surface with their own dedicated endpoints. They share this gateway's key, governance, and tracing, but the request/response contracts differ — so they live in their own skill: **`opper-multimodal`** ([SKILL.md](https://skills.opper.ai/opper-multimodal/SKILL.md)).

Quick map (fetch the spec or that skill for shapes): images `POST /v3/images` (sync, opt-in async), audio `POST /v3/audio/speech` (TTS) + `POST /v3/audio/transcriptions` (STT), video `POST /v3/videos` (**async** — poll `GET /v3/artifacts/{id}/status`), OCR `POST /v3/ocr`, files `/v3/files`, realtime `wss://api.opper.ai/v3/realtime` (browser tickets via `POST /v3/realtime-sessions`). Each media surface has a scoped discovery list (`GET /v3/images/models`, `/v3/videos/models`, `/v3/audio/models`, `/v3/ocr/models`).

**Server-side tools** (`opper:web_search` and friends) are different — they ride the compat chat endpoints and stay in this skill; see "Server-side web search" below.

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

## Migration — from another gateway, or from Opper's own `/call`

Moving from OpenRouter, OpenAI, Anthropic, or similar: see [references/migration.md](references/migration.md). Recap: point the base URL at `https://api.opper.ai/v3/compat` and use your Opper API key.

Moving off Opper's own legacy `/call` (`POST /v3/call` or the v2 Python SDK's `opper.call`): same file — it opens with the field-by-field `/call` → chat-completions mapping (`name` → `X-Opper-Name` header, `instructions` → system message, `output_schema` → `response_format`, `data` → parsed `choices[0].message.content`).

## Coding assistant integrations

For wiring Opper into Claude Code, Cursor, Copilot, Continue, etc., see the up-to-date list at [docs.opper.ai/overview/integrations](https://docs.opper.ai/overview/integrations).

## Non-obvious gotchas

- **One gateway, many endpoints.** Text/chat is `/v3/compat/...`; media generation, files, and realtime are a separate surface (the `opper-multimodal` skill). All share the same key and governance.
- **`/v3/call` is legacy and being sunset.** Never point a new integration at it, and don't use it in examples. Existing `/call` users (including legacy v2 Python SDK `opper.call`) migrate to compat + `response_format` — see [references/migration.md](references/migration.md).
- **Compat endpoints live under `/v3/compat/...`**, not at `/v3/...`. SDK migrations should point base URL at `https://api.opper.ai/v3/compat`.
- **Auth is `Authorization: Bearer ...` only.** Anthropic SDKs send `x-api-key` by default — set the `Authorization` header explicitly when migrating.
- **Structured output is a parameter, not an endpoint** — use `response_format: {type: "json_schema"}` on a compat chat call.
- **A bare model name is a pool, not a provider.** `"model": "kimi-k3"` routes to any provider serving it; `"tensorx/moonshotai/kimi-k3"` pins one; `"my-alias"` uses your own ordered list; `"dynamic/my-route"` runs a deployed graph. The response `model` field just echoes what you sent, so only the trace (`span.meta.model`) reveals which one ran — see [references/model-routing.md](references/model-routing.md).
- **Server-side web search is portable** — one `{"type": "opper:web_search"}` tool entry works on every model; native provider shapes also forward verbatim.
- **Media / files / realtime are not in this skill** — they're dedicated endpoints documented in `opper-multimodal`. Don't improvise their shapes here.
- **Knowledge is v2, not v3.** Don't reach for `/v3/knowledge/...` — it does not exist.
- **The spec is the most up-to-date reference; the docs and this skill follow it.** This file rots; the spec doesn't.

## Where to look next

| For | Look at |
|---|---|
| Live, definitive endpoint shapes | `https://api.opper.ai/v3/openapi.yaml` |
| Concepts (Organization, Project, Call, Trace, Gateway, Control Plane) | [docs.opper.ai/overview/concepts](https://docs.opper.ai/overview/concepts) |
| Gateway behaviour (routing, compat) | [docs.opper.ai/overview/gateway](https://docs.opper.ai/overview/gateway) |
| Control Plane (Route / Observe / Steer / Guard / Comply) | [docs.opper.ai/control-plane/overview](https://docs.opper.ai/control-plane/overview) |
| Media generation, files, vision/PDF input, realtime voice | the `opper-multimodal` skill |
| Multimodality concepts (docs) | [docs.opper.ai/build/multimodal/overview](https://docs.opper.ai/build/multimodal/overview) |
| Roundtable | [docs.opper.ai/build/roundtable/overview](https://docs.opper.ai/build/roundtable/overview) |
| Browsable model catalog (for user-facing recommendations) | [opper.ai/models](https://opper.ai/models) |
| Worked recipes in many languages | [github.com/opper-ai/opper-cookbook](https://github.com/opper-ai/opper-cookbook) |
| Provider-compatible endpoints, deeper | [references/compatibility.md](references/compatibility.md) |
| Migrating from OpenRouter / OpenAI / Anthropic / Opper's legacy `/call` | [references/migration.md](references/migration.md) |
| Model routing — pools, pins, org aliases, dynamic routes, failover | [references/model-routing.md](references/model-routing.md) |
| Calling the API from Python or TypeScript | the `opper-sdks` skill |
| Calling the API from a terminal | the `opper-cli` skill |
