# Opper Python SDK — orientation

The upstream [`python/README.md`](https://github.com/opper-ai/opper-sdks/tree/main/python) is the source of truth for install, quick start, schema flavours, observability, agents, configuration, and error handling. Read it first. This file only covers what the README doesn't.

## Numbered examples — concept → file map

All under `python/examples/getting-started/`:

| For | File |
|---|---|
| First call | `00_your_first_call.py` |
| Pydantic schema | `01a_using_schemas.py` |
| Dataclass / TypedDict / raw JSON Schema dict | `01b_using_other_schemas.py` |
| Streaming | `02_stream.py` |
| Client-side tools (call / stream) | `03a_tools_call.py`, `03b_tools_stream.py` |
| Image / audio / video | `04a/04b/04c`, `05`, `06` |
| Embeddings | `07_embeddings.py` |
| Function management | `08_function_management.py` |
| Observability — auto, manual, querying back | `09`, `09b`, `09c` |
| Models | `10_models.py` |
| Knowledge base | `12_knowledge_base.py` |
| Web tools | `13_web_tools.py` |

## Tracing API — `opper.trace(...)` context manager

Auto-wires nested calls under one trace. **Note**: the convenience entry point is `opper.trace`, not `opper.span`. The low-level client is `opper.spans.*`.

```python
with opper.trace("pipeline") as span:
    a = opper.call("step_one", input={...})
    b = opper.call("step_two", input=a.data)
    # span.trace_id, span.id available for metadata
```

`opper.trace(name=..., meta={...}, tags={...})` accepts metadata. See `09_observability.py` for nested traces, `09b_manual_tracing.py` for explicit `opper.spans.create / update`, `09c_traces.py` for querying back.

## Streaming — six chunk types

`opper.stream(...)` yields chunks discriminated by `chunk.type`:

| Type | When |
|---|---|
| `content` | Incremental text delta — `chunk.delta` |
| `tool_call_start` | A tool call is starting |
| `tool_call_delta` | Tool-call argument delta |
| `done` | Stream finished — `chunk.usage` available |
| `error` | Stream error — `chunk.error` |
| `complete` | Final structured result — `chunk.data`, `chunk.meta` |

Worked example: `02_stream.py`. The full discriminated-union type is `StreamChunk` in `python/src/opperai/types.py`.

## Non-obvious

- **`from opperai import Opper, Agent, tool, Conversation, Hooks`** — the agent surface is re-exported from the top-level package; no need to write `opperai.agent.*` unless you prefer the longer form.
- **`opperai` requires `httpx`** at runtime. Pydantic is an *optional* extra: `pip install opperai[pydantic]`.
- **Async variants** end in `_async` (e.g. `opper.knowledge.create_async(...)`). The README's "Async Support" section has details.

## Where to look next

| For | Look at |
|---|---|
| Public API surface, error classes, async patterns | `python/README.md` |
| Type definitions | `python/src/opperai/types.py` |
| Migration from earlier versions | `python/MIGRATION.md` |
| Live API spec (definitive for endpoint shapes) | `https://api.opper.ai/v3/openapi.yaml` |
