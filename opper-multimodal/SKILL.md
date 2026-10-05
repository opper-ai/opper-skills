---
name: opper-multimodal
description: >
  Use the Opper multimodal and realtime surfaces — everything beyond text.
  Covers media generation (images, audio speech / TTS, transcription / STT,
  music and sound effects, video, OCR), the /v3/files storage API and file_id reuse, vision / PDF input
  on chat models, and realtime two-way voice / audio over WebSocket
  (wss://api.opper.ai/v3/realtime, browser tickets via /v3/realtime-sessions,
  function-scoped /v3/realtime/{name}). Use this skill whenever the user wants
  to generate or edit an image, do text-to-speech or speech-to-text, transcribe
  audio, generate music or sound effects, generate video, run OCR on a PDF / image, upload or reuse media files,
  send images / PDFs to a model, or build a voice / realtime app on Opper —
  even if they only say "Opper". For text / chat, structured output, migration,
  and server-side tools like web_search, use the `opper-api` skill instead. For
  any endpoint signature or payload question, fetch the live OpenAPI spec at
  https://api.opper.ai/v3/openapi.yaml first.
category: sub-skill
parent: opper
metadata:
  version: "2026-10-05"
---

<!-- version-check: removed from the copy served at skills.opper.ai -->
> **Skill version 2026-10-05.** This is a locally installed copy and may be out of date. Once per session, fetch https://skills.opper.ai/versions.json and compare its `"opper-multimodal"` entry with 2026-10-05. If they differ, read https://skills.opper.ai/opper-multimodal/SKILL.md and follow that instead of this copy for the rest of the session, and tell the user once that their installed Opper skills are out of date (update with `npx skills update`, or `git pull` in a manual clone). Do not edit the installed files. If the fetch fails, continue with this copy.
<!-- /version-check -->

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
| **Transcription / STT** | `POST /v3/audio/transcriptions` | sync (opt-in `stream`) | `GET /v3/audio/models?type=stt` | [audio](https://docs.opper.ai/build/multimodal/audio) |
| **Music / sound effects** | `POST /v3/audio/generations` (`/v3/audio/music` is an alias) | sync (opt-in `async`) | `GET /v3/audio/models?type=music` / `?type=sound` | [audio](https://docs.opper.ai/build/multimodal/audio) |
| **Voice cloning** | `POST /v3/audio/voices` | sync | `GET /v3/audio/voices?model=` (a model's voices, yours included) | [audio](https://docs.opper.ai/build/multimodal/audio) |
| **Video** (generate) | `POST /v3/videos` | **async** — poll `status_url` | `GET /v3/videos/models` | [video](https://docs.opper.ai/build/multimodal/video) |
| **OCR** (PDF / image → markdown) | `POST /v3/ocr` | sync | `GET /v3/ocr/models` | [ocr](https://docs.opper.ai/build/multimodal/ocr) |
| **Files** (store / reuse media) | `/v3/files` | sync | — | [files](https://docs.opper.ai/build/multimodal/files) |
| **Vision / PDF input** | compat chat (`image_url` / `file` parts) | sync | `GET /v3/models?capability=vision` / `?capability=pdf` | [vision-pdfs](https://docs.opper.ai/build/multimodal/vision-pdfs) |
| **Realtime voice** | `wss://api.opper.ai/v3/realtime` | streaming | `GET /v3/models?type=realtime` | [realtime quickstart](https://docs.opper.ai/build/realtime/quickstart) |

## How the media endpoints behave

A shared contract across `/v3/images`, `/v3/audio/*`, `/v3/videos`, `/v3/ocr`:

- **`model` and the prompt/input are owned by Opper.** A small set of high-level params is normalized (e.g. `size`, `aspect_ratio`, `quality`, `voice`, `format`). Everything you put in **`parameters`** is forwarded **verbatim** to the provider — that's the escape hatch for provider-specific knobs.
- **Nothing is stored unless you ask.** Send `store: true` to save the output to [Files](https://docs.opper.ai/build/multimodal/files) and get a reusable **`file_id`** back; the default is `false`.
- **Reuse media without re-uploading** by passing a `file_id` (from a previous generation or a `POST /v3/files` upload) anywhere a media source is accepted — `image` / `mask` / `reference_images` on images, `image` / `video` / `reference_images` on videos, `audio` on transcriptions, `document` on OCR.
- **Everything is traced and billed** like any other call — visible at [platform.opper.ai](https://platform.opper.ai).

### Images — `POST /v3/images`

```bash
# Generate (synchronous)
curl -s -X POST https://api.opper.ai/v3/images \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "openai/gpt-image-2.5-sunburst", "prompt": "a hot air balloon over green hills", "size": "1024x1024"}'
# → { "data": [{ "url" | "b64_json", "file_id": "file_..." }], "usage": {...} }
```

**Which model**: start with `openai/gpt-image-2.5-sunburst` or `openai/gpt-image-2.5-flare`, then check `GET /v3/images/models` for what is live. Probe the size you get back: some models reach higher resolutions through another knob (Gemini image models give 2K with `quality: "high"` and refuse a `resolution` field).

**Edit / variations**: pass a source `image` (and optional `mask` or `reference_images`). **Slow models**: send `"async": true` to get a `202` + `status_url` instead of blocking; poll it like video below.

### Audio — speech & transcription

```bash
# Text-to-speech
curl -s -X POST https://api.opper.ai/v3/audio/speech \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "openai/tts-1", "input": "Hello from Opper", "voice": "alloy", "format": "mp3"}'
# → { "audio": { "b64_json": "...", "mime_type": "audio/mpeg", "file_id"?: "file_..." }, "usage": { "cost": ..., "characters": ... } }

# Speech-to-text — audio as file_id, URL, or data-URI
curl -s -X POST https://api.opper.ai/v3/audio/transcriptions \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "openai/whisper-1", "audio": "file_abc123", "language": "en"}'
# → { "text": "...", "language": "en", "duration": 12.3, "segments": [...], "usage": {...} }
```

`GET /v3/audio/models?type=tts` lists each speech model's `voices`, `default_voice`, and `max_length`; `?type=stt` lists each transcription model's `languages`, `formats`, whether it supports `diarize` (speaker labels — rejected if the model can't do it), and whether it supports `stream`.

**Brand and product names in transcripts**: pass them as key terms through `parameters` on models that take them (for example `"parameters": {"keyterms": ["Opper"]}` on `elevenlabs/scribe_v2`, which otherwise wrote "Opper" as "OPA").

**Finding voices**: `GET /v3/audio/voices?model=<tts model>` lists every voice that model takes as `voice`: the provider's built-in voices (`type: preset`), then your project's clones on that provider (`type: custom`). Filter with `language` (`en` matches `en-GB`), `gender` and `type`; `"default": true` marks the voice used when `voice` is left out. ElevenLabs and Mistral voices are read live from the provider, with name, accent, languages and (ElevenLabs) a `preview_url` to listen to first. Voices in a caller's own ElevenLabs account do not work through Opper (it calls ElevenLabs with its own account): clone them instead. Fish Audio voices are not listed; pass a Fish voice id.

**Streaming transcription**: send `"stream": true` to `/v3/audio/transcriptions` to get incremental `transcript.text.delta` events over SSE (final `transcript.text.done` + `[DONE]`) instead of one blocking response. Only some models support it — check `stream` in the `?type=stt` discovery list; unsupported models return a `400`.

**Custom voices (cloning)**: clone a voice from a reference sample, then use its `voice_...` id anywhere a `voice` is accepted (e.g. `/v3/audio/speech`). Voices are scoped to your org/project and provider-agnostic — `model` picks the backing provider.

```bash
# Clone a voice — audio as file_id, URL, or data-URI (reference sample is transient, never stored)
curl -s -X POST https://api.opper.ai/v3/audio/voices \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "mistral/voxtral-mini-2602", "name": "narrator", "audio": "file_abc123"}'
# → { "id": "voice_...", "object": "voice", "provider": "mistral", "expires_at": ..., ... }

# Use the cloned voice
curl -s -X POST https://api.opper.ai/v3/audio/speech \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "mistral/voxtral-mini-2602", "input": "Hello from a cloned voice", "voice": "voice_..."}'
```

`GET /v3/audio/voices` lists your voices (with `expires_at` — some providers expire clones); `GET`/`DELETE /v3/audio/voices/{id}` fetch or remove one (delete also removes it at the provider).

### Audio: music and sound effects

One endpoint for both: `POST /v3/audio/generations`. Pick the model by type: `GET /v3/audio/models?type=music` for songs and scores, `?type=sound` for sound effects and ambience.

```bash
# A sound effect: one action per request, described as the material
curl -s -X POST https://api.opper.ai/v3/audio/generations \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "elevenlabs/eleven_text_to_sound_v2", "prompt": "a single wooden block knock, close, dry", "duration_seconds": 1}'
# → { "id": "snd_...", "audio": { "b64_json": "...", "mime_type": "audio/mpeg" }, "usage": { "cost": 0.002, "duration_seconds": 1 } }

# Music with a timed plan (models with the audio_sections capability)
curl -s -X POST https://api.opper.ai/v3/audio/generations \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "elevenlabs/music_v2_5", "sections": [
        {"duration_ms": 8000, "prompt": "quiet marimba intro, 120 BPM", "styles": ["marimba", "instrumental"]},
        {"duration_ms": 8000, "prompt": "same marimba, fuller, resolves on a final chord", "negative_styles": ["vocals"]}]}'
```

- **Normalized fields**: `prompt` (required unless `sections` are sent), `duration_seconds` (not with `sections`, which set the length), `instrumental`, `format` (`mp3`, `wav`, `opus`, `pcm`; omit it for the model's native format), `seed`. A value a model cannot honor answers `400` naming its limit. On ElevenLabs, `seed` works on music only with `sections` (never with `prompt`), `instrumental` only with `prompt` (put "instrumental" in the section `styles` instead), and sound effects take no seed.
- **Capability-gated fields answer `400`, never silently drop**: `sections` needs `audio_sections`, `loop` (seamless repeat, for ambience and hums) needs `audio_loop`. Find them with `GET /v3/audio/models?capability=audio_sections` or `?capability=audio_loop`. `parameters` is never gated: it goes to the provider as is.
- **Sections**: each has `duration_ms` (required), `prompt` (what it should sound like; never sung), `styles`, `negative_styles`, and `lyrics` (words to sing; leave empty for instrumental). Boundaries tend to snap to the tempo's phrase grid (at 120 BPM, multiples of 2 or 4 s), so place them there and measure the result.
- **Long tracks**: send `"async": true` to get a `202` + `status_url` and poll it like video.
- **Response**: `audio.b64_json` (or `file_id` with `store: true`), `lyrics` when the provider writes any, and `usage.cost`.

### Video — `POST /v3/videos` (asynchronous)

Video is **always async**: submit, get a `202` with a `status_url`, then poll until it resolves to a download URL + `file_id`.

**Which model**: start with Gemini Omni (`gemini-omni-1.1-flash`), Wan 3 (`wan3.0`, `wan3.0-prime`), Seedance 2.5 (`seedance-2.5`) or Kling 3 (`kling-3.0-pro`, image-to-video `kling-3.0-pro-i2v`). Bare names are pooled across the providers that serve them; a provider-prefixed id (for example `fal/seedance-2.5`, `bytedance:ap/seedance-2.5`) pins one. Check `GET /v3/videos/models` for what is live for your key.

```bash
# 1. Submit
curl -s -X POST https://api.opper.ai/v3/videos \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model": "seedance-2.5", "prompt": "the balloon drifts at dawn"}'
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

`document` accepts a URL, base64 (PDF or image), or a `file_id`. `GET /v3/ocr/models` lists OCR models and each one's `price_per_page`. Guide: [docs.opper.ai/build/multimodal/ocr](https://docs.opper.ai/build/multimodal/ocr).

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

- **Video is the only always-async media endpoint.** `POST /v3/videos` returns `202` + `status_url`; poll `GET /v3/artifacts/{id}/status`. Images, audio, and OCR are synchronous, though `/v3/images` and `/v3/audio/generations` accept `"async": true` for slow models, returning the same poll shape.
- **Generated media is not stored by default.** Send `store: true` when you want a reusable `file_id`; without it you get the bytes (or a URL) only.
- **Pass `file_id`, don't re-upload.** Any media source field (`image`, `mask`, `reference_images`, `audio`, `video`, `document`) accepts a `file_id` from a prior generation or a `/v3/files` upload.
- **`parameters` is a verbatim passthrough.** Top-level fields are normalized across providers; anything provider-specific goes in `parameters` untouched.
- **Vision/PDF *input* is not a media endpoint** — it's content parts on a compat chat call to a `vision`/`pdf`-capable model. Media *generation* uses the dedicated endpoints here.
- **Realtime browser clients use a ticket, never the API key.** Mint it from `/v3/realtime-sessions`; the key stays server-side.
- **Server-side tools (`opper:web_search`, etc.) live in `opper-api`, not here.** They ride the compat chat endpoints.
- **Music and sound effects share one endpoint.** `type=music` versus `type=sound` in `/v3/audio/models` tells them apart; `sections` and `loop` are capability-gated and answer `400` on models without them.
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
| Agent-assisted setup, platform operations, and model tests | the `opper-mcp` skill |
| Doing this from a terminal | the [`opper-cli`](https://skills.opper.ai/opper-cli/SKILL.md) skill |
| Worked recipes in many languages | [github.com/opper-ai/opper-cookbook](https://github.com/opper-ai/opper-cookbook) |
