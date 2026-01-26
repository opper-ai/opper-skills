# Memory Reference (Python Agents)

Memory gives agents persistent state across iterations and multiple `process()` calls. Agents can remember facts, preferences, and context.

## Contents
- [Enabling Memory](#enabling-memory)
- [How Memory Works](#how-memory-works)
- [Memory Operations](#memory-operations)
- [Example: Remembering User Preferences](#example-remembering-user-preferences)
- [Memory Across Multiple Calls](#memory-across-multiple-calls)
- [Custom Memory Backends](#custom-memory-backends)
- [Memory vs. Context](#memory-vs-context)
- [Best Practices](#best-practices)

## Enabling Memory

```python
from opper_agents import Agent

agent = Agent(
    name="AssistantBot",
    instructions="Help the user. Remember their preferences.",
    tools=[my_tools],
    enable_memory=True,
)
```

## How Memory Works

1. The agent maintains a **memory catalog** — a list of available memory entries
2. Before each reasoning step, the agent decides whether to **read** existing memories
3. After processing, it decides whether to **write** new information to memory
4. Memory persists across multiple `process()` calls on the same agent instance

## Memory Operations

The agent automatically performs these operations as needed:

- **List**: See what memories are available (by key)
- **Read**: Retrieve the content of a specific memory
- **Write**: Store new information under a key
- **Delete**: Remove a memory entry

## Example: Remembering User Preferences

```python
agent = Agent(
    name="PersonalAssistant",
    instructions="Help the user. Remember their name and preferences for future interactions.",
    tools=[get_weather, search_web],
    enable_memory=True,
)

# First interaction
result = await agent.process("Hi, I'm Alice. I prefer Celsius for temperatures.")
# Agent writes: {"name": "Alice", "temp_unit": "celsius"}

# Second interaction — agent remembers
result = await agent.process("What's the weather in Paris?")
# Agent reads memory, uses Celsius without asking
```

## Memory Across Multiple Calls

Memory persists between `process()` calls:

```python
agent = Agent(
    name="TaskTracker",
    instructions="Track tasks for the user. Remember completed and pending tasks.",
    enable_memory=True,
)

await agent.process("Add 'buy groceries' to my task list")
await agent.process("Add 'call dentist' to my task list")
await agent.process("What's on my task list?")
# Agent reads from memory: ["buy groceries", "call dentist"]
```

## Custom Memory Backends

Implement a custom backend for production use (e.g., Redis, database):

```python
from typing import Optional, List

class MemoryBackend:
    """Interface for custom memory backends."""

    async def list_keys(self) -> List[str]:
        """List all memory keys."""
        ...

    async def read(self, key: str) -> Optional[str]:
        """Read a memory value by key."""
        ...

    async def write(self, key: str, value: str) -> None:
        """Write a value to memory."""
        ...

    async def delete(self, key: str) -> None:
        """Delete a memory entry."""
        ...
```

### Redis Implementation

```python
import redis.asyncio as redis
import json

class RedisMemory(MemoryBackend):
    def __init__(self, redis_url: str, prefix: str = "agent_memory"):
        self.client = redis.from_url(redis_url)
        self.prefix = prefix

    def _key(self, key: str) -> str:
        return f"{self.prefix}:{key}"

    async def list_keys(self) -> List[str]:
        keys = await self.client.keys(f"{self.prefix}:*")
        return [k.decode().removeprefix(f"{self.prefix}:") for k in keys]

    async def read(self, key: str) -> Optional[str]:
        value = await self.client.get(self._key(key))
        return value.decode() if value else None

    async def write(self, key: str, value: str) -> None:
        await self.client.set(self._key(key), value)

    async def delete(self, key: str) -> None:
        await self.client.delete(self._key(key))

# Usage — custom backends require manual integration
# The agent uses an in-memory backend by default when enable_memory=True
memory = RedisMemory("redis://localhost:6379")
```

## Memory vs. Context

| Feature | Memory | Context (instructions) |
|---------|--------|----------------------|
| Persistence | Across calls | Single call only |
| Dynamic | Agent reads/writes at runtime | Fixed at creation |
| Size | Grows over time | Limited by context window |
| Use case | User preferences, session state | Task description, rules |

## Best Practices

- **Clear instructions**: Tell the agent what to remember and when
- **Key naming**: Use descriptive keys like `"user_preferences"` not `"data1"`
- **Memory limits**: Monitor memory size — too many entries can fill the context window
- **Custom backends**: Use Redis or a database for production; default in-memory is ephemeral
- **Privacy**: Don't store sensitive information in memory without encryption
- **Cleanup**: Periodically review and prune stale memories
- **Testing**: Test memory behavior across multiple `process()` calls
