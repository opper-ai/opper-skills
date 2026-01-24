---
name: opper-python-sdk
description: >
  Use the Opper Python SDK (opperai) for AI task completion, structured output with Pydantic schemas, knowledge base semantic search, and tracing/observability. Activate when building Python applications that need LLM-powered task completion, RAG pipelines, document indexing, or AI function orchestration with the Opper platform.
license: MIT
metadata:
  author: opper-ai
  version: "1.0"
  language: python
  package: opperai
---

# Opper Python SDK

Build AI-powered applications with declarative task completion, structured outputs, knowledge bases, and full observability.

## Installation

```bash
pip install opperai
```

Set your API key:

```bash
export OPPER_API_KEY="your-api-key"
```

Get your API key from [platform.opper.ai](https://platform.opper.ai).

## Core Pattern: Task Completion

The `opper.call()` method is the primary interface. Describe a task declaratively and get structured results:

```python
from opperai import Opper
from pydantic import BaseModel

opper = Opper()

# Simple string output
result, response = opper.call(
    name="summarize",
    instructions="Summarize the text in one sentence",
    input="Opper is a platform for building reliable AI integrations...",
)
print(result)  # "Opper enables reliable AI integrations with structured outputs."

# Structured output with Pydantic
class Sentiment(BaseModel):
    label: str
    confidence: float

result, response = opper.call(
    name="analyze_sentiment",
    instructions="Analyze the sentiment of the text",
    input="I love this product!",
    output_type=Sentiment,
)
print(result.label)       # "positive"
print(result.confidence)  # 0.95
```

## Structured Output with Pydantic

Define input and output schemas using Pydantic models for type-safe AI interactions:

```python
from typing import List
from pydantic import BaseModel, Field

class ExtractedEntities(BaseModel):
    people: List[str] = Field(description="Names of people mentioned")
    locations: List[str] = Field(description="Geographic locations")
    organizations: List[str] = Field(description="Company or org names")

result, _ = opper.call(
    name="extract_entities",
    instructions="Extract all named entities from the text",
    input="Tim Cook announced Apple's new office in Austin, Texas.",
    output_type=ExtractedEntities,
)
# result.people => ["Tim Cook"]
# result.locations => ["Austin", "Texas"]
# result.organizations => ["Apple"]
```

## Model Selection

Specify which LLM to use via the `model` parameter:

```python
# Use a specific model
result, _ = opper.call(
    name="generate",
    instructions="Write a haiku",
    input="autumn",
    model="anthropic/claude-4-sonnet",
)

# Use multiple models (fallback chain)
result, _ = opper.call(
    name="generate",
    instructions="Write a haiku",
    input="autumn",
    model=["anthropic/claude-4-sonnet", "openai/gpt-4o"],
)
```

Available models include providers like `openai/`, `anthropic/`, `google/`, and more. Check the Opper dashboard for the full list.

## Few-Shot Examples

Provide examples to guide the model's behavior:

```python
result, _ = opper.call(
    name="classify_ticket",
    instructions="Classify the support ticket",
    input="My payment was declined",
    output_type=str,
    examples=[
        {"input": "I can't log in", "output": "authentication"},
        {"input": "Charge me twice", "output": "billing"},
        {"input": "App crashes on start", "output": "bug"},
    ],
)
```

## Tracing and Observability

Track AI operations with spans and metrics:

```python
from opperai import Opper, trace

opper = Opper()

@trace
def answer_question(question: str) -> str:
    result, response = opper.call(
        name="answer",
        instructions="Answer the question accurately",
        input=question,
    )
    # Save a metric on the span
    response.span.save_metric("quality_score", 4.5)
    return result

# Start a trace to group operations
with opper.traces.start("qa_pipeline") as t:
    answer = answer_question("What is Opper?")
```

## Knowledge Bases

Create and query semantic search indexes:

```python
from opperai.types import DocumentIn

# Create an index
index = opper.indexes.create("support_docs")

# Add documents
index.add(DocumentIn(
    key="doc1",
    content="To reset your password, click Forgot Password on the login page.",
    metadata={"category": "auth"},
))

# Query with semantic search
results = index.query("How do I change my password?", k=3)
for result in results:
    print(result.content, result.score)
```

## Tags and Metadata

Add metadata to calls for filtering and cost tracking:

```python
result, _ = opper.call(
    name="translate",
    instructions="Translate to French",
    input="Hello world",
    tags={"project": "website", "user_id": "usr_123"},
)
```

## Common Mistakes

- **Missing `output_type`**: Without it, the result is a plain string. Use Pydantic models for structured data.
- **Not using `name`**: Every call needs a unique name for tracking in the dashboard.
- **Ignoring the response object**: The second return value contains the span for metrics and tracing.
- **Large inputs without chunking**: For large documents, split into chunks and use knowledge bases instead.

## Additional Resources

- For function CRUD operations and versioning, see [references/FUNCTIONS.md](references/FUNCTIONS.md)
- For knowledge base operations and RAG patterns, see [references/KNOWLEDGE.md](references/KNOWLEDGE.md)
- For tracing, spans, and metrics, see [references/TRACING.md](references/TRACING.md)
- For streaming responses, see [references/STREAMING.md](references/STREAMING.md)

## Related Skills

- **opper-python-agents**: Use when you need autonomous agents with tool use, reasoning loops, and multi-step task execution rather than single-shot task completion.
- **opper-node-sdk**: Use when building with TypeScript/Node.js instead of Python.

## Upstream Sources

If this skill's content is outdated, check the canonical sources:

- **Source code**: https://github.com/opper-ai/opper-python
- **Documentation**: https://docs.opper.ai
