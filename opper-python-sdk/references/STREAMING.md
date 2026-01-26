# Streaming Reference (Python SDK)

Stream responses token-by-token for real-time output in user-facing applications.

## Contents
- [Basic Streaming](#basic-streaming)
- [Streaming with Structured Output](#streaming-with-structured-output)
- [Web Server Integration (FastAPI)](#web-server-integration-fastapi)
- [Streaming with Tracing](#streaming-with-tracing)
- [Best Practices](#best-practices)

## Basic Streaming

Use `opper.stream()` (not `opper.call()`) to get a streaming response:

```python
from opperai import Opper

opper = Opper()

# Stream a response using opper.stream()
response = opper.stream(
    name="write_story",
    instructions="Write a short story about the given topic",
    input="a robot learning to cook",
)

for event in response.result:
    if hasattr(event.data, 'delta'):
        print(event.data.delta, end="", flush=True)
```

## Streaming with Structured Output

Stream while still getting validated structured output at the end:

```python
# The stream yields deltas; use output_schema for structure
response = opper.stream(
    name="write_structured_story",
    instructions="Write a story with a title and paragraphs",
    input="space exploration",
    output_schema={
        "type": "object",
        "properties": {
            "title": {"type": "string"},
            "paragraphs": {"type": "array", "items": {"type": "string"}},
        },
        "required": ["title", "paragraphs"],
    },
)

for event in response.result:
    if hasattr(event.data, 'delta'):
        print(event.data.delta, end="", flush=True)
```

## Web Server Integration (FastAPI)

Stream responses to HTTP clients:

```python
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from opperai import Opper

app = FastAPI()
opper = Opper()

@app.get("/generate")
async def generate(topic: str):
    def stream_generator():
        response = opper.stream(
            name="generate_content",
            instructions="Write content about the topic",
            input=topic,
        )
        for event in response.result:
            if hasattr(event.data, 'delta'):
                yield event.data.delta

    return StreamingResponse(
        stream_generator(),
        media_type="text/plain",
    )
```

## Streaming with Tracing

Streaming works with the tracing system using `parent_span_id`:

```python
from opperai import Opper

opper = Opper()

# Create a span for the streaming operation
span = opper.spans.create(name="streaming_qa")

response_text = ""
response = opper.stream(
    name="answer_question",
    instructions="Answer the question",
    input="What is machine learning?",
    parent_span_id=span.id,
)

for event in response.result:
    if hasattr(event.data, 'delta'):
        response_text += event.data.delta
        print(event.data.delta, end="", flush=True)

print()  # Newline after streaming
```

## Best Practices

- Use `opper.stream()` instead of `opper.call()` for streaming
- Always use `flush=True` when printing chunks to ensure immediate display
- Check for `hasattr(event.data, 'delta')` before accessing delta content
- For web servers, use `StreamingResponse` with appropriate content types
- Accumulate deltas if you need the full response for downstream processing
- Streaming works with all models that support it
- Use streaming for user-facing applications where perceived latency matters
- For batch processing without user interaction, non-streaming `opper.call()` is simpler
