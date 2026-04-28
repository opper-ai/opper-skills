# Building agents with the Opper SDKs

Agents are part of `opperai`. There is no separate `opperai-agents` package.

```python
from opperai import Agent, tool, Conversation, Hooks
```

```ts
import { Agent, tool, Conversation, Hooks, mcp } from "opperai";
```

The upstream READMEs both cover the Agent SDK end-to-end (structured output, multi-agent, MCP, conversation). Numbered runnable examples in `python/examples/agents/` and `typescript/examples/agents/` are the highest-bandwidth reference. Read in order.

## Numbered examples — concept → file map

| Concept | Python | TypeScript |
|---|---|---|
| First agent | `00_first_agent.py` | `00-your-first-agent.ts` |
| Output schema | `01_agent_with_schema.py` | `01-agent-with-schema.ts` |
| Tools | `02_agent_with_tools.py` | `02-agent-with-tools.ts` |
| Streaming | `03_streaming.py` | `03-streaming.ts` |
| Hooks: logging / timing / with streaming | `04_…`, `05_…`, `06_streaming_hooks.py` | `04-…`, `05-…`, `06-streaming-with-hooks.ts` |
| Agent as a tool | `07_agent_as_tool.py` | `07-agent-as-tool.ts` |
| Multi-agent composition | `08_multi_agent.py` | `08-multi-agent.ts` |
| MCP (stdio) | `09_mcp_stdio.py` | `09-mcp-stdio.ts` |
| Conversation (multi-turn state) | `10_conversation.py` | `10-conversation.ts` |

Longer end-to-end agents live under `examples/agents/applied_agents/` in both languages.

## Defining tools

**Python — `@tool` decorator** (the parameter schema is inferred from type hints + docstring):

```python
from opperai import Agent, tool

@tool
def get_weather(city: str) -> str:
    """Return current weather for a city."""
    return ...

agent = Agent(name="trip-planner", tools=[get_weather])
result = await agent.run("What should I pack for Stockholm tomorrow?")
```

**TypeScript — `tool({ … })` function** (no decorator; pass a Zod schema or any Standard Schema for `parameters`):

```ts
import { Agent, tool } from "opperai";
import { z } from "zod";

const getWeather = tool({
  name: "get_weather",
  description: "Return current weather for a city.",
  parameters: z.object({ city: z.string() }),
  execute: async ({ city }) => { return ...; },
});

const agent = new Agent({ name: "trip-planner", tools: [getWeather] });
const result = await agent.run("What should I pack for Stockholm tomorrow?");
```

(There is no `createFunctionTool` and no TS `@tool` decorator — just the `tool({ ... })` function. The handler field is `execute`, not `handler`.)

Worked example: `02_agent_with_tools.{py,ts}`.

## Hooks, multi-agent, MCP, conversation

Use the numbered example files above as starting points. Headlines:

- **Hooks** are lifecycle callbacks (`on_agent_start`, `on_agent_end`, `on_tool_*`, etc.) — see `04`/`05`/`06`.
- **Agent as a tool** lets one agent call another (`07`); **multi-agent** composes specialists (`08`).
- **MCP** integration (`09`): Python `from opperai.agent import mcp` (or top-level), TS `import { mcp } from "opperai"` — both accept stdio / HTTP / SSE servers.
- **`Conversation`** holds multi-turn state across agent runs (`10_conversation`). The Python `_conversation` and TS `conversation` modules are the source.

## Where to look next

| For | Look at |
|---|---|
| Agent SDK overview prose | the "Agent SDK" section in `python/README.md` and `typescript/README.md` |
| Numbered, runnable examples | `python/examples/agents/`, `typescript/examples/agents/` |
| Agent module source | `python/src/opperai/agent/`, `typescript/src/agent/` |
| Repo-wide design notes | `docs/AGENT_SDK_PATTERNS.md` in opper-sdks |
| Live API spec | `https://api.opper.ai/v3/openapi.yaml` |
