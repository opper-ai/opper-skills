# Opper TypeScript SDK — orientation

The upstream [`typescript/README.md`](https://github.com/opper-ai/opper-sdks/tree/main/typescript) is the source of truth for install, quick start, schemas, observability, configuration, and error handling. Read it first (skip its "Agent SDK" section: discontinued, see [agents.md](agents.md)). This file only covers what the README doesn't.

> **Legacy note:** `opper.call(...)` / `opper.stream(...)` ride Opper's `/call` surface, which is being sunset, and the `opperai` SDK is being reworked to no longer use `/call` — a future release drops it. Use this file to maintain or migrate existing code, not to start new `opper.call` work — new one-shot tasks go through a compat chat endpoint with `response_format` (mapping in the `opper-api` skill's `references/migration.md`). `opper.knowledge.*` is unaffected. The Agent SDK is discontinued: see [agents.md](agents.md).

## Numbered examples — concept → file map

All under `typescript/examples/getting-started/`:

| For | File |
|---|---|
| First call | `00-your-first-call.ts` |
| Zod schemas | `01a-using-schemas.ts` |
| Standard Schema / raw JSON Schema | `01b-using-other-schemas.ts` |
| Streaming | `02-stream.ts` |
| Client-side tools (call / stream) | `03a-tools-call.ts`, `03b-tools-stream.ts` |
| Server-side tools (TS-only) | `03c-server-side-tools.ts` |
| Image / audio / video | `04a/04b/04c`, `05`, `06` |
| Embeddings | `07-embeddings.ts` |
| Function management | `08-function-management.ts` |
| Observability — auto, manual, querying back | `09`, `09b`, `09c` |
| Models | `10-models.ts` |
| Real-time (TS-only) | `11-real-time.ts` |
| Knowledge base | `12-knowledge-base.ts` |
| Web tools | `13-web-tools.ts` |

## Tracing API — `opper.traced(name, fn)` callback wrapper

Auto-wires nested calls under one trace. The convenience entry point is `opper.traced(...)`; `opper.spans.*` is the low-level client.

```ts
const result = await opper.traced("pipeline", async (span) => {
  const a = await opper.call("step_one", { input: { ... } });
  const b = await opper.call("step_two", { input: a.data });
  return b;
});
```

The callback receives a `SpanHandle` for `traceId` / `spanId`. Nested `traced()` calls form parent/child spans automatically. See `09-observability.ts`, `09b-manual-tracing.ts`, `09c-traces.ts`.

## Streaming — six chunk types

`opper.stream(...)` returns an async iterable; each chunk has a `type` discriminator:

| Type | When |
|---|---|
| `content` | Incremental text delta — `chunk.delta` |
| `tool_call_start` | A tool call is starting |
| `tool_call_delta` | Tool-call argument delta |
| `done` | Stream finished — `chunk.usage` available |
| `error` | Stream error — `chunk.error` |
| `complete` | Final structured result — `chunk.data`, `chunk.meta` |

Full discriminated union `StreamChunk<T>` is exported from `opperai`; source at `typescript/src/types.ts`.

## Non-obvious

- **Zero runtime dependencies.** `zod ^4.0.0` is an *optional peer dependency*; install it only if you use Zod. (The other optional peer, `@modelcontextprotocol/sdk`, is only for the discontinued Agent SDK's `mcp()`.)
- **Zod v4 only** if you use Zod. The `zod@3.25.x` dual-mode package is not supported.
- **`Agent`, `tool`, `Conversation`, `mcp` are the discontinued Opper Agent SDK.** They still import from `"opperai"` but are no longer maintained and are being removed; build agents as in [agents.md](agents.md).
- **Native `fetch`** is used for HTTP, so Node ≥ 18 (or any modern fetch-capable runtime) is required.

## Where to look next

| For | Look at |
|---|---|
| Public API surface, error classes, configuration | `typescript/README.md` |
| Type definitions | `typescript/src/types.ts` |
| Migration from earlier versions | `typescript/MIGRATION.md` |
| Live API spec (definitive for endpoint shapes) | `https://api.opper.ai/v3/openapi.yaml` |
