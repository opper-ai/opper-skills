---
name: opper-sdks
description: >
  Use the unified Opper SDKs (`opperai` package for both Python and TypeScript)
  and Opper's compat endpoints from code for AI task completion, structured
  output with Pydantic / Zod / JSON Schema, knowledge base semantic search,
  streaming, tracing, and tool use. Use this skill whenever the user is writing
  Python or TypeScript code that imports `opperai`, wants to build an agent on
  Opper, needs to migrate code off the legacy `opper.call` or off the
  discontinued Opper Agent SDK, or asks how to do anything Opper-related in
  code — even if they don't explicitly name the SDK. Both languages live in one
  repo with parallel numbered examples.
category: sub-skill
parent: opper
metadata:
  version: "2026-10-09"
---

<!-- version-check: removed from the copy served at skills.opper.ai -->
> **Skill version 2026-10-09.** This is a locally installed copy and may be out of date. Once per session, fetch https://skills.opper.ai/versions.json and compare its `"opper-sdks"` entry with 2026-10-09. If they differ, read https://skills.opper.ai/opper-sdks/SKILL.md and follow that instead of this copy for the rest of the session, and tell the user once that their installed Opper skills are out of date (update with `npx skills update`, or `git pull` in a manual clone). Do not edit the installed files. If the fetch fails, continue with this copy.
<!-- /version-check -->

> Sub-skill of [`opper`](https://skills.opper.ai/) — start there for discovery and setup guidance.
> Source: https://github.com/opper-ai/opper-skills/blob/main/opper-sdks/SKILL.md

# Opper SDKs

The Python and TypeScript SDKs for Opper live in a single monorepo: [github.com/opper-ai/opper-sdks](https://github.com/opper-ai/opper-sdks). Both publish as `opperai` (PyPI / npm).

**The Opper Agent SDK is discontinued** (October 2026): `Agent`, `tool`, `Conversation`, `Hooks` and `mcp` in `opperai`, and the older standalone `opperai-agents` / `@opperai/agents` packages, are no longer maintained and are being removed. Don't write new code against them or suggest them. For agents, see [references/agents.md](references/agents.md).

The upstream READMEs (`python/README.md`, `typescript/README.md`) and the numbered example files are the source of truth, except their Agent SDK sections and `examples/agents/`, which are discontinued. This skill points at them; it does not duplicate them.

## Pick your primitive

The unified `opperai` package exposes a few different shapes. Pick by what you're building:

- **One-shot structured task** (input → typed output): the recommended path is a **compat chat endpoint with `response_format`**, called through the provider SDK you already know — point the OpenAI SDK's `base_url` at `https://api.opper.ai/v3/compat` and pass your Pydantic / Zod model via `chat.completions.parse(...)`. Seeds below; full shape in the **`opper-api` skill**.
- **Streaming**: `stream: true` on the same compat call — standard OpenAI SSE semantics.
- **Multi-turn chat or message-thread style**: the compat chat endpoints are message-native — carry the `messages` array forward.
- **Tool-using agent, multi-step reasoning, multi-agent, external MCP tools**: use the agent framework the user already has (OpenAI Agents SDK, Vercel AI SDK, Mastra, LangChain, …) pointed at Opper, or a plain tool-calling loop on the compat chat endpoint. Wiring per framework and both seeds in [references/agents.md](references/agents.md). Not the discontinued Opper Agent SDK.
- **Knowledge bases / RAG**: **`opper.knowledge.*`** — `create`, `query`, `add`, etc.
- **`opper.call(...)` / `opper.stream(...)` are legacy.** They ride Opper's `/call` surface, which is **being sunset** — don't start new work on them, and don't use them in examples. The `opperai` SDK itself is being reworked to no longer use `/call`; a future release drops it. Existing code migrates to compat + `response_format`; the field-by-field mapping (`name` → `X-Opper-Name` header, `output_schema` → `response_format`, `result.data` → parsed message content) is in the `opper-api` skill's `references/migration.md`.

To connect a coding assistant to the Opper MCP server for platform operations or model tests, use `opper-mcp`.

## Pick a path

| You are… | Read |
|---|---|
| Writing Python (calls, streaming, schemas, knowledge, tracing) | [references/python.md](references/python.md) |
| Writing TypeScript / JavaScript | [references/typescript.md](references/typescript.md) |
| Building an agent in either language | [references/agents.md](references/agents.md) |
| Calling Opper without an SDK (curl, fetch) | switch to the `opper-api` skill |

## Install

```bash
pip install opperai          # Python — has one runtime dep: httpx
npm  install opperai         # TypeScript — zero runtime deps; zod is an optional peer
```

Authentication: both SDKs read `OPPER_API_KEY` from the environment, or accept `api_key=` / `apiKey:` in the constructor.

## Canonical seed — Python

One-shot tasks go through the compat endpoint with the stock OpenAI SDK; `X-Opper-Name` keeps named-function tracing:

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://api.opper.ai/v3/compat",
    api_key=os.environ["OPPER_API_KEY"],
    default_headers={"X-Opper-Name": "summarise"},
)

resp = client.chat.completions.create(
    model="openai/gpt-5-mini",
    messages=[
        {"role": "system", "content": "Summarise the article in two sentences."},
        {"role": "user", "content": "..."},
    ],
)
print(resp.choices[0].message.content)
```

For typed output, use `client.chat.completions.parse(..., response_format=YourPydanticModel)` and read `resp.choices[0].message.parsed`.

## Canonical seed — TypeScript

```ts
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://api.opper.ai/v3/compat",
  apiKey: process.env.OPPER_API_KEY,
  defaultHeaders: { "X-Opper-Name": "summarise" },
});

const resp = await client.chat.completions.create({
  model: "openai/gpt-5-mini",
  messages: [
    { role: "system", content: "Summarise the article in two sentences." },
    { role: "user", content: "..." },
  ],
});
console.log(resp.choices[0].message.content);
```

For typed output, pass `response_format: { type: "json_schema", json_schema: { name, schema } }` (generate the schema from Zod v4 with `z.toJSONSchema(...)`) and `JSON.parse` the message content.

For agents (a tool-calling loop, or the user's framework on Opper), see [references/agents.md](references/agents.md).

### Picking a model

Pass `model: "provider/name"` on every call. On the Control Plane plan you can instead set a **default-model rule** (Management API, see [docs.opper.ai/control-plane/route](https://docs.opper.ai/control-plane/route)) and omit `model:`; without such a rule, a call with no model is refused.

- **Browse models for the user**: link them at [opper.ai/models](https://opper.ai/models) — the human catalog.
- **Discover models in code**: `GET https://api.opper.ai/v3/models` (no auth required). **Never hardcode model lists** — they change.

## The numbered examples are the highest-bandwidth reference

Both `python/examples/` and `typescript/examples/` hold parallel numbered files. Read by topic. **Caveat:** many of the getting-started examples still demonstrate the legacy `opper.call` surface — treat them as reference for existing code, not as the pattern for new work (that's compat + `response_format`, above).

**Getting started** (`examples/getting-started/`):

| Topic | File pattern |
|---|---|
| First call | `00_your_first_call.{py,ts}` |
| Schemas — Pydantic / Zod / dataclass / TypedDict / raw JSON Schema | `01a_*` and `01b_*` |
| Streaming | `02_stream.{py,ts}` |
| Tools — call & stream | `03a_*`, `03b_*` (TS-only `03c-server-side-tools.ts`) |
| Images, audio, video | `04a/04b/04c`, `05`, `06` |
| Embeddings | `07_*` |
| Function management | `08_*` |
| Observability / tracing | `09`, `09b_manual_tracing`, `09c_traces` |
| Models | `10_models.{py,ts}` |
| Real-time | TS-only: `11-real-time.ts` |
| Knowledge base | `12_knowledge_base.{py,ts}` |
| Web tools | `13_web_tools.{py,ts}` |

**Agents** (`examples/agents/`): these demonstrate the discontinued Agent SDK. Read them only to understand existing code you are migrating; [references/agents.md](references/agents.md) maps each concept to its replacement.

Type definitions: `python/src/opperai/types.py` and `typescript/src/types.ts`.

## Non-obvious gotchas

- **`opper.call` rides the legacy `/call` surface, which is being sunset — and the SDK is being reworked to drop it.** Recommend it to no one; migrate existing `opper.call` code to a compat endpoint with `response_format` (mapping in the `opper-api` skill's `references/migration.md`).
- **No required schema library.** Both SDKs accept plain JSON Schema dicts and don't need any third-party schema package. Pydantic (Python) and Zod (TS) are bundled integrations for convenience — most users will reach for them, but they are optional.
- **If you use Zod with the TS SDK, it must be v4.** `npm install zod@4`. The `zod@3.25.x` dual-mode package is *not* supported. (Zod is an *optional peer dependency*.)
- **Python depends on `httpx`** (not zero-dep at runtime); TypeScript is zero-dep at runtime.
- **The Opper Agent SDK is discontinued.** `Agent`, `tool`, `Conversation`, `Hooks` (top-level `opperai`), `mcp` (`opperai.agent.mcp` in Python, top-level in TS) and the older `opperai-agents` / `@opperai/agents` packages are no longer maintained and are being removed. Migrate existing agent code with the table in [references/agents.md](references/agents.md).
- **Migration from earlier versions** is documented at `python/MIGRATION.md` and `typescript/MIGRATION.md` upstream.
- **For API signature questions**, fetch the live OpenAPI spec at `https://api.opper.ai/v3/openapi.yaml`. The SDK shape mirrors the spec.

## Where to look next

| For | Look at |
|---|---|
| Install, quick start, full READMEs | [opper-sdks repo](https://github.com/opper-ai/opper-sdks) — `python/README.md`, `typescript/README.md` |
| Working examples (numbered, progressive) | `python/examples/`, `typescript/examples/` in the repo |
| Type definitions | `python/src/opperai/types.py`, `typescript/src/types.ts` |
| Live API spec | `https://api.opper.ai/v3/openapi.yaml` |
| Migrating from older SDK versions | `python/MIGRATION.md`, `typescript/MIGRATION.md` |
| Repo-level workflows (OpenAPI sync, beta endpoints) | `CLAUDE.md` in the opper-sdks repo |
| Models available, gateway concepts, raw HTTP, Realtime | the `opper-api` skill |
| Browsable model catalog (for user-facing recommendations) | [opper.ai/models](https://opper.ai/models) |
| Control Plane rules (spend limits, data retention, model access, checks, routing) | [docs.opper.ai/control-plane/rules/overview](https://docs.opper.ai/control-plane/rules/overview) |
| Agent-assisted setup, platform operations, and model tests | the `opper-mcp` skill |
| Calling Opper from a terminal | the `opper-cli` skill |
