# Building agents on Opper

> **The Opper Agent SDK is discontinued (October 2026).** `Agent`, `tool`, `Conversation`, `Hooks` and `mcp` in `opperai`, and the older standalone `opperai-agents` (PyPI) and `@opperai/agents` (npm) packages, are no longer maintained and are being removed. Don't write new code against them and don't suggest them. Existing code: migrate with the table at the bottom.

An agent on Opper is any tool-calling loop whose model calls go through Opper's gateway. Two ways to build one:

1. **The agent framework the user already uses, pointed at Opper.** Their code stays; Opper adds the model catalog, fallbacks, EU routes and tracing. This is the default.
2. **No framework:** a short tool-calling loop on the compat chat endpoint (seed below).

## Frameworks

| Framework | How it connects | Reference |
|---|---|---|
| Vercel AI SDK (TS) | Official provider: `npm install @opperai/ai-sdk-provider ai`, then `model: opper("openai/gpt-5.5")` | [docs.opper.ai/integrations/frameworks/vercel-ai-sdk](https://docs.opper.ai/integrations/frameworks/vercel-ai-sdk) |
| Mastra (TS) | First-class provider in Mastra's model router: set `OPPER_API_KEY`, then `model: "opper/anthropic/claude-sonnet-5"`. No client, no base URL | [docs.opper.ai/integrations/frameworks/mastra](https://docs.opper.ai/integrations/frameworks/mastra) |
| OpenAI Agents SDK (Python / TS) | Wrap the model in `OpenAIChatCompletionsModel` bound to an OpenAI client on `https://api.opper.ai/v3/compat` (seed below) | this file |
| LangChain, LlamaIndex, CrewAI and anything else with an OpenAI-compatible client | Base URL `https://api.opper.ai/v3/compat`, the Opper key, model `provider/name` (e.g. LangChain `ChatOpenAI(base_url=..., model="anthropic/claude-sonnet-5")`) | `opper-api` skill, `references/compatibility.md` |
| Code built on the Anthropic SDK | Same base URL (`/v3/compat/v1/messages`); send `Authorization: Bearer`, not `x-api-key` | `opper-api` skill, `references/migration.md` |

Every app and framework that runs on Opper is listed at [opper.ai/apps](https://opper.ai/apps).

## Seed: tool-calling loop, no framework (Python)

```python
import json, os
from openai import OpenAI

client = OpenAI(
    base_url="https://api.opper.ai/v3/compat",
    api_key=os.environ["OPPER_API_KEY"],
    default_headers={"X-Opper-Name": "trip-planner"},  # groups the calls under one name
)

def get_weather(city: str) -> str:
    return f"{city}: 4°C and raining"

tools = [{
    "type": "function",
    "function": {
        "name": "get_weather",
        "description": "Return current weather for a city.",
        "parameters": {"type": "object", "properties": {"city": {"type": "string"}}, "required": ["city"]},
    },
}]
messages = [
    {"role": "system", "content": "You help people pack for trips."},
    {"role": "user", "content": "What should I pack for Stockholm tomorrow?"},
]

while True:
    msg = client.chat.completions.create(model="openai/gpt-5-mini", messages=messages, tools=tools).choices[0].message
    if not msg.tool_calls:
        print(msg.content)
        break
    messages.append(msg)
    for call in msg.tool_calls:
        args = json.loads(call.function.arguments)
        messages.append({"role": "tool", "tool_call_id": call.id, "content": get_weather(**args)})
```

The same request shape works from TypeScript with the `openai` package. Add a step limit in real code.

## Seed: OpenAI Agents SDK (Python)

```python
import os
from openai import AsyncOpenAI
from agents import Agent, OpenAIChatCompletionsModel, Runner, function_tool, set_tracing_disabled

set_tracing_disabled(True)  # its tracing exports to OpenAI; Opper traces the calls
client = AsyncOpenAI(base_url="https://api.opper.ai/v3/compat", api_key=os.environ["OPPER_API_KEY"])

@function_tool
def get_weather(city: str) -> str:
    """Return current weather for a city."""
    return f"{city}: 4°C and raining"

agent = Agent(
    name="trip-planner",
    instructions="You help people pack for trips.",
    model=OpenAIChatCompletionsModel(model="anthropic/claude-haiku-4-5", openai_client=client),
    tools=[get_weather],
)
result = await Runner.run(agent, "What should I pack for Stockholm tomorrow?")
print(result.final_output)
```

Both seeds were run against the live API in October 2026 (`openai-agents` 0.23.1).

## Gotchas

- **OpenAI Agents SDK: never pass a bare `provider/model` string.** `Agent(model="anthropic/claude-haiku-4-5")` raises `UserError: Unknown prefix: anthropic`. Wrap it in `OpenAIChatCompletionsModel(model=..., openai_client=<client on /v3/compat>)` as above.
- **Model ids are Opper's `provider/name`** on the compat endpoint. Mastra adds an `opper/` prefix (`opper/openai/gpt-5.5`). Discover ids with `GET https://api.opper.ai/v3/models`; never hardcode lists.
- **Name your calls** with the `X-Opper-Name` header so an agent's steps group together in Opper's logs and traces.

## Migrating off the discontinued Agent SDK

| Opper Agent SDK | Instead |
|---|---|
| `Agent(name, instructions, tools, model)` | the framework's agent, or the loop above with `instructions` as the system message |
| `@tool` (Python) / `tool({...})` (TS) | the framework's tool helper (`@function_tool`, AI SDK `tool()`, Mastra `createTool`), or a JSON Schema entry in `tools` |
| `agent.run(...)` / `agent.stream(...)` | the framework's runner, or the loop (`stream: true` for streaming) |
| `output_schema` | `response_format: {"type": "json_schema", ...}` on the final call (see the `opper-api` skill) |
| `Hooks` | the framework's callbacks; `X-Opper-Name` for grouping in Opper |
| `mcp(...)` | the framework's MCP client (the OpenAI Agents SDK, Mastra and the Vercel AI SDK each ship one) |
| `Conversation` | keep the `messages` array between runs |
| Agent as a tool, multi-agent | the framework's handoffs or sub-agents, or run another loop inside a tool |
