# Streaming Reference (Python SDK)

Stream responses token-by-token for real-time output in user-facing applications.

## Contents
- [Basic Streaming](#basic-streaming)
- [Streaming with Structured Output](#streaming-with-structured-output)
- [Web Server Integration (FastAPI)](#web-server-integration-fastapi)
- [Streaming with Tracing](#streaming-with-tracing)
- [Best Practices](#best-practices)

## Basic Streaming

Use `opper.call()` with `stream=True` to get an iterator of chunks:

```python
from opperai import Opper

opper = Opper()

# Stream a response
for chunk in opper.call(
    name="write_story",
    instructions="Write a short story about the given topic",
    input="a robot learning to cook",
    stream=True,
):
    print(chunk, end="", flush=True)
```

## Streaming with Structured Output

Stream while still getting validated structured output at the end:

```python
from pydantic import BaseModel
from typing import List

class Story(BaseModel):
    title: str
    paragraphs: List[str]

# The stream yields deltas; the final result is validated against the schema
chunks = []
for chunk in opper.call(
    name="write_structured_story",
    instructions="Write a story with a title and paragraphs",
    input="space exploration",
    output_type=Story,
    stream=True,
):
    chunks.append(chunk)
    print(chunk, end="", flush=True)
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
        for chunk in opper.call(
            name="generate_content",
            instructions="Write content about the topic",
            input=topic,
            stream=True,
        ):
            yield chunk

    return StreamingResponse(
        stream_generator(),
        media_type="text/plain",
    )
```

## Streaming with Tracing

Streaming works with the tracing system:

```python
from opperai import trace

@trace
def stream_answer(question: str):
    response_text = ""
    for chunk in opper.call(
        name="answer_question",
        instructions="Answer the question",
        input=question,
        stream=True,
    ):
        response_text += chunk
        print(chunk, end="", flush=True)
    return response_text

with opper.traces.start("streaming_qa"):
    answer = stream_answer("What is machine learning?")
```

## Best Practices

- Always use `flush=True` when printing chunks to ensure immediate display
- For web servers, use `StreamingResponse` with appropriate content types
- Accumulate chunks if you need the full response for downstream processing
- Streaming works with all models that support it
- Use streaming for user-facing applications where perceived latency matters
- For batch processing without user interaction, non-streaming is simpler
