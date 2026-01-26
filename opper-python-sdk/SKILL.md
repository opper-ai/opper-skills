---
name: opper-python-sdk
description: >
  Use the Opper Python SDK (opperai) for AI task completion, structured output with JSON Schema, knowledge base semantic search, and tracing/observability. Activate when building Python applications that need LLM-powered task completion, RAG pipelines, document indexing, or AI function orchestration with the Opper platform.
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

opper = Opper()

# Simple string output
result, response = opper.call(
    name="summarize",
    instructions="Summarize the text in one sentence",
    input="Opper is a platform for building reliable AI integrations...",
)
print(result)  # "Opper enables reliable AI integrations with structured outputs."

# Structured output with schema dict
result, response = opper.call(
    name="analyze_sentiment",
    instructions="Analyze the sentiment of the text",
    input="I love this product!",
    output_schema={
        "type": "object",
        "properties": {
            "label": {"type": "string"},
            "confidence": {"type": "number"},
        },
        "required": ["label", "confidence"],
    },
)
print(result["label"])       # "positive"
print(result["confidence"])  # 0.95
```

## Structured Output with Schema

Define output schemas using JSON Schema dictionaries:

```python
result, _ = opper.call(
    name="extract_entities",
    instructions="Extract all named entities from the text",
    input="Tim Cook announced Apple's new office in Austin, Texas.",
    output_schema={
        "type": "object",
        "properties": {
            "people": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Names of people mentioned",
            },
            "locations": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Geographic locations",
            },
            "organizations": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Company or org names",
            },
        },
        "required": ["people", "locations", "organizations"],
    },
)
# result["people"] => ["Tim Cook"]
# result["locations"] => ["Austin", "Texas"]
# result["organizations"] => ["Apple"]
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
from opperai import Opper

opper = Opper()

# Create a span to group operations
span = opper.spans.create(name="qa_pipeline")

# Call with parent span for hierarchy
result, response = opper.call(
    name="answer",
    instructions="Answer the question accurately",
    input="What is Opper?",
    parent_span_id=span.id,
)

# Save a metric on the span
opper.span_metrics.create_metric(
    span_id=response.span_id,
    dimension="quality_score",
    value=4.5,
)

# List traces
traces = opper.traces.list()
```

## Knowledge Bases

Create and query semantic search indexes:

```python
from opperai import Opper

opper = Opper()

# Create a knowledge base
kb = opper.knowledge.create(name="support_docs")

# Add a document
opper.knowledge.add(
    index_id=kb.id,
    content="To reset your password, click Forgot Password on the login page.",
    metadata={"category": "auth"},
)

# Query with semantic search
results = opper.knowledge.query(
    index_id=kb.id,
    query="How do I change my password?",
    k=3,
)
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

- **Missing `output_schema`**: Without it, the result is a plain string. Use schema dicts for structured data.
- **Not using `name`**: Every call needs a unique name for tracking in the dashboard.
- **Ignoring the response object**: The second return value contains `span_id` for metrics and tracing.
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
