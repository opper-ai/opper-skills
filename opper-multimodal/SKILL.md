---
name: opper-multimodal
description: >
  Use the Opper multimodal and realtime surfaces — everything beyond text.
  Covers media generation (images, audio speech / TTS, transcription / STT,
  video, OCR), the /v3/files storage API and file_id reuse, vision / PDF input
  on chat models, and realtime two-way voice / audio over WebSocket
  (wss://api.opper.ai/v3/realtime, browser tickets via /v3/realtime-sessions,
  function-scoped /v3/realtime/{name}). Use this skill whenever the user wants
  to generate or edit an image, do text-to-speech or speech-to-text, transcribe
  audio, generate video, run OCR on a PDF / image, upload or reuse media files,
  send images / PDFs to a model, or build a voice / realtime app on Opper —
  even if they only say "Opper". For text / chat, structured output, migration,
  and server-side tools like web_search, use the `opper-api` skill instead. For
  any endpoint signature or payload question, fetch the live OpenAPI spec at
  https://api.opper.ai/v3/openapi.yaml first.
category: sub-skill
parent: opper
---

> Sub-skill of [`opper`](https://skills.opper.ai/) — start there for discovery and setup guidance.
> Source: https://github.com/opper-ai/opper-skills/blob/main/opper-multimodal/SKILL.md

# Opper Multimodal & Realtime

Everything **beyond text**: generate and edit media, run OCR, store and reuse files, send images and PDFs to a model, and run two-way voice over a WebSocket. Same gateway, same `Authorization: Bearer $OPPER_API_KEY`, same Control Plane governance and tracing as the text endpoints — just different surfaces.

For text generation, chat, structured output, migration from another gateway, and **server-side tools** (`opper:web_search` and friends), use the [`opper-api`](https://skills.opper.ai/opper-api/SKILL.md) skill — those ride the compat chat endpoints and stay there.

Concepts: [docs.opper.ai/overview/concepts](https://docs.opper.ai/overview/concepts). Multimodal overview: [docs.opper.ai/build/multimodal/overview](https://docs.opper.ai/build/multimodal/overview).

## The live v3 spec is the source of truth

**Default workflow for any question this skill doesn't immediately answer — endpoint, parameter, field, provider knob — grep the spec.** Don't guess, don't invent endpoints or model ids. The spec is unauthenticated and definitive:

```bash
curl -s https://api.opper.ai/v3/openapi.yaml   # YAML, easier to grep
curl -s https://api.opper.ai/v3/openapi.json   # JSON
```

Each surface below has its **own scoped model-discovery list** — call it to learn which models, voices, sizes, durations, and capabilities are live right now. Never hardcode model names.

## The surfaces at a glance

One key, one gateway. Pick the endpoint by what you're producing:

| Surface | Endpoint | Sync / async | Discovery | Guide |
|---|---|---|---|---|
| **Images** (generate / edit) | `POST /v3/images` | sync (opt-in async) | `GET /v3/images/models` | [images](https://docs.opper.ai/build/multimodal/images) |
| **Speech / TTS** | `POST /v3/audio/speech` | sync | `GET /v3/audio/models?type=tts` | [audio](https://docs.opper.ai/build/multimodal/audio) |
| **Transcription / STT** | `POST /v3/audio/transcriptions` | sync | `GET /v3/audio/models?type=stt` | [audio](https://docs.opper.ai/build/multimodal/audio) |
| **Video** (generate) | `POST /v3/videos` | **async** — poll `status_url` | `GET /v3/videos/models` | [video](https://docs.opper.ai/build/multimodal/video) |
| **OCR** (PDF / image → markdown) | `POST /v3/ocr` | sync | `GET /v3/ocr/models` | [docs.opper.ai/build/multimodal](https://docs.opper.ai/build/multimodal/overview) |
| **Files** (store / reuse media) | `/v3/files` | sync | — | [files](https://docs.opper.ai/build/multimodal/files) |
| **Vision / PDF input** | compat chat (`image_url` / `file` parts) | sync | `GET /v3/models?capability=vision` / `?capability=pdf` | [vision-pdfs](https://docs.opper.ai/build/multimodal/vision-pdfs) |
| **Realtime voice** | `wss://api.opper.ai/v3/realtime` | streaming | `GET /v3/models?type=realtime` | [realtime quickstart](https://docs.opper.ai/build/realtime/quickstart) |

## How the media endpoints behave

A shared contract across `/v3/images`, `/v3/audio/*`, `/v3/videos`, `/v3/ocr`:

- **`model` and the prompt/input are owned by Opper.** A small set of high-level params is normalized (e.g. `size`, `aspect_ratio`, `quality`, `voice`, `format`). Everything you put in **`parameters`** is forwarded **verbatim** to the provider — that's the escape hatch for provider-specific knobs.
- **Generated output is stored by default** (`store: true`) to [Files](https://docs.opper.ai/build/multimodal/files) and returned with a reusable **`file_id`**. Pass `store: false` to opt out.
- **Reuse media without re-uploading** by passing a `file_id` (from a previous generation or a `POST /v3/files` upload) anywhere a media source is accepted — `image` / `mask` / `reference_images` on images, `image` / `video` / `reference_images` on videos, `audio` on transcriptions, `document` on OCR.
- **Everything is traced and billed** like any other call — visible at [platform.opper.ai](https://platform.opper.ai).

### Images — `POST /v3/images`

```bash
# Generate (synchronous)
curl -s -X POST https://api.opper.ai/v3/images \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "openai/gpt-image-1", "prompt": "a hot air balloon over green hills", "size": "1024x1024"}'
# → { "data": [{ "url" | "b64_json", "file_id": "file_..." }], "usage": {...} }
```

**Edit / variations**: pass a source `image` (and optional `mask` or `reference_images`). **Slow models**: send `"async": true` to get a `202` + `status_url` instead of blocking; poll it like video below.

### Audio — speech & transcription

```bash
# Text-to-speech
curl -s -X POST https://api.opper.ai/v3/audio/speech \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "openai/tts-1", "input": "Hello from Opper", "voice": "alloy", "format": "mp3"}'
# → { "audio": "<base64>", "file_id": "file_...", "mime_type": "audio/mpeg", "usage": {...} }

# Speech-to-text — audio as file_id, URL, or data-URI
curl -s -X POST https://api.opper.ai/v3/audio/transcriptions \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "openai/whisper-1", "audio": "file_abc123", "language": "en"}'
# → { "text": "...", "language": "en", "duration": 12.3, "segments": [...], "usage": {...} }
```

`GET /v3/audio/models?type=tts` lists each speech model's `voices`, `default_voice`, and `max_length`; `?type=stt` lists each transcription model's `languages`, `formats`, and whether it supports `diarize` (speaker labels — rejected if the model can't do it).

### Video — `POST /v3/videos` (asynchronous)

Video is **always async**: submit, get a `202` with a `status_url`, then poll until it resolves to a download URL + `file_id`.

```bash
# 1. Submit
curl -s -X POST https://api.opper.ai/v3/videos \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "openai/sora-2", "prompt": "the balloon drifts at dawn"}'
# → 202 { "id": "...", "status_url": "https://api.opper.ai/v3/artifacts/{id}/status" }

# 2. Poll
curl -s -H "Authorization: Bearer $OPPER_API_KEY" \
  "https://api.opper.ai/v3/artifacts/{id}/status"
# → { "status": "completed", "url": "...", "file_id": "file_..." }   (or "processing")
```

Inspect each model's `capabilities` via `GET /v3/videos/models` to tell input modality apart: `video_generation` is text-to-video, `image_to_video` needs a source `image`, `video_editing` is video-to-video. `params.video` lists accepted `aspect_ratios`, `resolutions`, and `max_duration`.

### OCR — `POST /v3/ocr`

Turn a PDF or image into structured markdown. Billed **per page**.

```bash
curl -s -X POST https://api.opper.ai/v3/ocr \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "mistral/mistral-ocr-latest",
       "document": {"type": "document_url", "document_url": "https://example.com/report.pdf"}}'
# → { "pages": [{ "index": 0, "markdown": "...", "elements": [...] }], "usage": {"pages_processed": N} }
```

`document` accepts a URL, base64 (PDF or image), or a `file_id`. `GET /v3/ocr/models` lists OCR models and each one's `price_per_page`.

## Files — `/v3/files`

General media storage that the generation endpoints write to and read from. Upload once, reference everywhere by `file_id` — no re-uploading large media across calls.

| Call | Does |
|---|---|
| `POST /v3/files` (multipart) | Upload a file → `{ "id": "file_..." }`. `purpose`: `reference_media` (default — images/video/audio) or `ocr_input` (PDFs/images) |
| `GET /v3/files` | List files (paginated, newest first) |
| `GET /v3/files/{id}` | Metadata |
| `GET /v3/files/{id}/content` | Presigned download URL (~1 h TTL) |
| `DELETE /v3/files/{id}` | Delete |

Per-org byte and file-count quotas apply, enforced on upload and when storing generated outputs. MIME type is sniffed from bytes against a per-purpose allowlist. Guide: [docs.opper.ai/build/multimodal/files](https://docs.opper.ai/build/multimodal/files).

## Vision & PDF input (on the chat endpoints)

Sending an image or PDF **into** a model (rather than generating media) rides the normal compat chat endpoints — it isn't a separate surface. Send `image_url` / `file` content parts to a model whose capabilities include `vision` / `pdf`:

```bash
curl -s "https://api.opper.ai/v3/models?capability=vision"   # which chat models accept images
curl -s "https://api.opper.ai/v3/models?capability=pdf"      # which accept PDFs
```

Then call `POST /v3/compat/chat/completions` (or any compat surface) with multimodal content parts — see the [`opper-api`](https://skills.opper.ai/opper-api/SKILL.md) skill for the chat shape. Guide: [docs.opper.ai/build/multimodal/vision-pdfs](https://docs.opper.ai/build/multimodal/vision-pdfs).

## Realtime — two-way voice over WebSocket

Low-latency, bidirectional audio (plus text, and image / video frames on some providers) over a WebSocket. Three related endpoints:

| Endpoint | Use |
|---|---|
| `wss://api.opper.ai/v3/realtime` | Model-driven, scriptless. Open the WS, send a `session.start` event with `config.model` (e.g. `openai/gpt-realtime-2`); the server resolves the provider and connects upstream |
| `POST /v3/realtime-sessions` | Mint a short-lived, single-use **ticket** for browser clients (which can't send an `Authorization` header). Returns `{ ticket, expires_at }` |
| `wss://api.opper.ai/v3/realtime/{name}` | Function-scoped: runs a pre-generated Starlark script with lifecycle hooks (`on_session_start`, `on_speech_start`, `on_response_complete`, `on_tool_call`) |

**Auth — two ways:**

- **Server-side**: connect with a project-scoped runtime `Authorization: Bearer $OPPER_API_KEY`.
- **Browser-side**: mint a ticket from `POST /v3/realtime-sessions`, then connect passing it as `?ticket=<value>` or `Sec-WebSocket-Protocol: opper-ticket.<value>` — never ship the API key to the browser.

```bash
# Mint a browser ticket
curl -s -X POST https://api.opper.ai/v3/realtime-sessions \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"config": {"model": "openai/gpt-realtime-2", "voice": "alloy"}, "locked_fields": []}'
# → { "ticket": "...", "expires_at": "..." }
```

The first client event is `session.start`. **Turn detection**: `server_vad` (acoustic), `semantic_vad` (model-based, OpenAI only), or `none` (client-driven). **Providers** differ in capability — OpenAI (`gpt-realtime-2`, vision variant; semantic VAD, image input, tools), Gemini Live (video-frame input, tools), xAI Voice (audio/text, `server_vad` only), ElevenLabs (conversational voice). Discover live realtime models with `GET /v3/models?type=realtime`.

**Caps & billing**: sessions are bounded by per-project concurrency, max duration, and idle timeout; usage flushes every ~30 s with synchronous balance enforcement (a `402` ends the session when the balance runs out). Full event protocol, examples, and billing mechanics: [realtime quickstart](https://docs.opper.ai/build/realtime/quickstart).

## Non-obvious gotchas

- **Video is the only always-async media endpoint.** `POST /v3/videos` returns `202` + `status_url`; poll `GET /v3/artifacts/{id}/status`. Images, audio, and OCR are synchronous — though `/v3/images` accepts `"async": true` for slow models, returning the same poll shape.
- **Generated media is stored by default** (`store: true`) and returns a `file_id`. Pass `store: false` to skip storage; `file_id` then won't be reusable.
- **Pass `file_id`, don't re-upload.** Any media source field (`image`, `mask`, `reference_images`, `audio`, `video`, `document`) accepts a `file_id` from a prior generation or a `/v3/files` upload.
- **`parameters` is a verbatim passthrough.** Top-level fields are normalized across providers; anything provider-specific goes in `parameters` untouched.
- **Vision/PDF *input* is not a media endpoint** — it's content parts on a compat chat call to a `vision`/`pdf`-capable model. Media *generation* uses the dedicated endpoints here.
- **Realtime browser clients use a ticket, never the API key.** Mint it from `/v3/realtime-sessions`; the key stays server-side.
- **Server-side tools (`opper:web_search`, etc.) live in `opper-api`, not here.** They ride the compat chat endpoints.
- **The spec is the most up-to-date reference; this skill follows it.** Scoped discovery lists (`/v3/images/models`, `/v3/videos/models`, `/v3/audio/models`, `/v3/ocr/models`) tell you what's live.

## Where to look next

| For | Look at |
|---|---|
| Live, definitive endpoint shapes | `https://api.opper.ai/v3/openapi.yaml` |
| Multimodality overview | [docs.opper.ai/build/multimodal/overview](https://docs.opper.ai/build/multimodal/overview) |
| Images / audio / video / files / vision guides | [docs.opper.ai/build/multimodal](https://docs.opper.ai/build/multimodal/overview) |
| Realtime quickstart & event protocol | [docs.opper.ai/build/realtime/quickstart](https://docs.opper.ai/build/realtime/quickstart) |
| Browsable model catalog (for user-facing recommendations) | [opper.ai/models](https://opper.ai/models) |
| Text / chat, structured output, migration, server-side tools | the [`opper-api`](https://skills.opper.ai/opper-api/SKILL.md) skill |
| Doing this from Python or TypeScript | the [`opper-sdks`](https://skills.opper.ai/opper-sdks/SKILL.md) skill |
| Doing this from a terminal | the [`opper-cli`](https://skills.opper.ai/opper-cli/SKILL.md) skill |
| Worked recipes in many languages | [github.com/opper-ai/opper-cookbook](https://github.com/opper-ai/opper-cookbook) |
