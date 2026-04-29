# Opper TypeScript SDK — orientation

The upstream [`typescript/README.md`](https://github.com/opper-ai/opper-sdks/tree/main/typescript) is the source of truth for install, quick start, schemas, observability, agents, configuration, and error handling. Read it first. This file only covers what the README doesn't.

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

- **Zero runtime dependencies.** `zod ^4.0.0` and `@modelcontextprotocol/sdk` are *optional peer dependencies*; install only what you use.
- **Zod v4 only** if you use Zod. The `zod@3.25.x` dual-mode package is not supported.
- **`import { Agent, tool, Conversation, mcp } from "opperai"`** — the agent surface is re-exported from the top-level package.
- **Native `fetch`** is used for HTTP, so Node ≥ 18 (or any modern fetch-capable runtime) is required.

## Where to look next

| For | Look at |
|---|---|
| Public API surface, error classes, configuration | `typescript/README.md` |
| Type definitions | `typescript/src/types.ts` |
| Migration from earlier versions | `typescript/MIGRATION.md` |
| Live API spec (definitive for endpoint shapes) | `https://api.opper.ai/v3/openapi.yaml` |
