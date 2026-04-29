---
name: opper-sdks
description: >
  Use the unified Opper SDKs (`opperai` package for both Python and TypeScript,
  with built-in agent support) for AI task completion, structured output with
  Pydantic / Zod / JSON Schema, knowledge base semantic search, streaming,
  tracing, tool use, and multi-agent composition. Use this skill whenever the
  user is writing Python or TypeScript code that imports `opperai`, builds an
  Opper agent, or asks how to do anything Opper-related in code — even if they
  don't explicitly name the SDK. Both languages live in one repo with parallel
  numbered examples; agents are part of the SDK, not a separate package.
---

# Opper SDKs

The Python and TypeScript SDKs for Opper live in a single monorepo: [github.com/opper-ai/opper-sdks](https://github.com/opper-ai/opper-sdks). Both publish as `opperai` (PyPI / npm). **Agents are part of the SDK** — there is no separate `opperai-agents` package.

The upstream READMEs (`python/README.md`, `typescript/README.md`) and the numbered example files are the source of truth. This skill points at them; it does not duplicate them.

## Pick your primitive

The unified `opperai` package exposes a few different shapes. Pick by what you're building:

- **One-shot structured task** (input → typed output, including image / audio / video generation): **`opper.call(...)`** is recommended. Pass `output_schema=` (Python) or `outputSchema:` (TS) — Pydantic / Zod / dataclasses / TypedDict / raw JSON Schema all work.
- **Streaming any of the above**: **`opper.stream(...)`** — same shape, async-iterable of typed chunks.
- **Multi-turn chat or message-thread style**: **`Conversation`** (re-exported from `opperai`) — keeps history across `opper.call(...)` invocations.
- **Tool-using agent, multi-step reasoning, multi-agent, MCP**: the **Agent SDK** (`Agent`, `tool`, `Conversation`, `Hooks`, `mcp`) is recommended for any "model decides what to do next" flow. Use **`agent.run(...)`** for a single shot or **`agent.stream(...)`** for live progress.
- **Drop-in compatibility with OpenAI / Anthropic / Google SDKs**: not exposed through the `opperai` SDK. Recommended: call the compat endpoints directly through the provider's own SDK (point its `baseURL` / `base_url` at `https://api.opper.ai/v3/compat`), or see the **`opper-api` skill** for raw HTTP.
- **Knowledge bases / RAG**: **`opper.knowledge.*`** — `create`, `query`, `add`, etc.

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
npm  install opperai         # TypeScript — zero runtime deps; zod and @modelcontextprotocol/sdk are optional peers
```

Authentication: both SDKs read `OPPER_API_KEY` from the environment, or accept `api_key=` / `apiKey:` in the constructor.

## Canonical seed — Python

```python
from opperai import Opper

opper = Opper()  # uses OPPER_API_KEY

result = opper.call(
    "summarise",
    instructions="Summarise the article in two sentences.",
    input={"text": "..."},
)
print(result.data)
```

## Canonical seed — TypeScript

```ts
import { Opper } from "opperai";

const opper = new Opper(); // uses OPPER_API_KEY

const result = await opper.call("summarise", {
  instructions: "Summarise the article in two sentences.",
  input: { text: "..." },
});
console.log(result.data);
```

## The numbered examples are the highest-bandwidth reference

Both `python/examples/` and `typescript/examples/` hold parallel numbered files. Read by topic.

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

**Agents** (`examples/agents/`, numbered `00..10`): first agent → output schema → tools → streaming → hooks (logging / timing / streaming) → agent-as-tool → multi-agent → MCP (stdio) → conversation. See [references/agents.md](references/agents.md) for the topic↔file table.

Type definitions: `python/src/opperai/types.py` and `typescript/src/types.ts`.

## Non-obvious gotchas

- **No required schema library.** Both SDKs accept plain JSON Schema dicts and don't need any third-party schema package. Pydantic (Python) and Zod (TS) are bundled integrations for convenience — most users will reach for them, but they are optional.
- **If you use Zod with the TS SDK, it must be v4.** `npm install zod@4`. The `zod@3.25.x` dual-mode package is *not* supported. (Zod is an *optional peer dependency*.)
- **Python depends on `httpx`** (not zero-dep at runtime); TypeScript is zero-dep at runtime.
- **`opperai` is the unified package.** Old separate `opperai-agents` (PyPI) and `@opperai/agents` (npm) are deprecated; `Agent`, `tool`, `Conversation`, `Hooks`, etc. are all re-exported from the top-level `opperai`.
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
| Models available, gateway concepts, raw HTTP | the `opper-api` skill |
| Calling Opper from a terminal | the `opper-cli` skill |
