# Streaming Reference (Node SDK)

Stream responses token-by-token using server-sent events for real-time output.

## Contents
- [Basic Streaming](#basic-streaming)
- [Streaming with Schemas](#streaming-with-schemas)
- [Streaming with Input/Output Schemas](#streaming-with-inputoutput-schemas)
- [Streaming with Tracing](#streaming-with-tracing)
- [Streaming Functions](#streaming-functions)
- [Web Server Integration (Express)](#web-server-integration-express)
- [Event Structure](#event-structure)
- [Best Practices](#best-practices)

## Basic Streaming

Use `opper.stream()` to get an async iterable of events:

```typescript
import { Opper } from "opperai";

const opper = new Opper({
  httpBearer: process.env["OPPER_HTTP_BEARER"] ?? "",
});

const stream = await opper.stream({
  name: "write_story",
  instructions: "Write a short story about the given topic",
  input: "a robot learning to cook",
});

for await (const event of stream) {
  process.stdout.write(event.delta ?? "");
}
```

## Streaming with Schemas

Stream while still defining structured output:

```typescript
const stream = await opper.stream({
  name: "analyze",
  instructions: "Analyze the given text",
  input: "Opper is an AI platform...",
  outputSchema: {
    type: "object",
    properties: {
      summary: { type: "string" },
      topics: { type: "array", items: { type: "string" } },
      sentiment: { type: "string", enum: ["positive", "negative", "neutral"] },
    },
    required: ["summary", "topics", "sentiment"],
  },
});

let fullResponse = "";
for await (const event of stream) {
  fullResponse += event.delta ?? "";
  process.stdout.write(event.delta ?? "");
}
```

## Streaming with Input/Output Schemas

Full schema definitions work with streaming:

```typescript
const stream = await opper.stream({
  name: "translate",
  instructions: "Translate the text to the target language",
  inputSchema: {
    type: "object",
    properties: {
      text: { type: "string" },
      targetLanguage: { type: "string" },
    },
    required: ["text", "targetLanguage"],
  },
  outputSchema: {
    type: "object",
    properties: {
      translation: { type: "string" },
      confidence: { type: "number" },
    },
    required: ["translation"],
  },
  input: { text: "Hello world", targetLanguage: "French" },
});

for await (const event of stream) {
  process.stdout.write(event.delta ?? "");
}
```

## Streaming with Tracing

Add trace context to streamed calls:

```typescript
const stream = await opper.stream({
  name: "generate_response",
  instructions: "Generate a detailed response",
  input: "Explain quantum computing",
  parentSpanId: "parent-span-uuid",
  tags: { user: "usr_123" },
});

for await (const event of stream) {
  process.stdout.write(event.delta ?? "");
}
```

## Streaming Functions

Stream from managed functions:

```typescript
const stream = await opper.functions.stream({
  id: "fn_123",
  input: { text: "Generate content" },
});

for await (const event of stream) {
  process.stdout.write(event.delta ?? "");
}

// Stream a specific revision
const stream = await opper.functions.streamRevision({
  id: "fn_123",
  revisionId: "rev_456",
  input: { text: "Generate content" },
});
```

## Web Server Integration (Express)

Stream to HTTP clients:

```typescript
import express from "express";
import { Opper } from "opperai";

const app = express();
const opper = new Opper({ httpBearer: process.env["OPPER_HTTP_BEARER"] ?? "" });

app.get("/generate", async (req, res) => {
  const { topic } = req.query;

  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");

  const stream = await opper.stream({
    name: "generate_content",
    instructions: "Write content about the topic",
    input: topic as string,
  });

  for await (const event of stream) {
    res.write(`data: ${JSON.stringify({ delta: event.delta })}\n\n`);
  }

  res.write("data: [DONE]\n\n");
  res.end();
});
```

## Event Structure

Each event in the stream contains:

```typescript
interface StreamEvent {
  delta?: string;      // The new text chunk
  // Additional metadata may be included
}
```

## Best Practices

- Always handle the stream completely — don't abandon it mid-stream
- Use `process.stdout.write` (not `console.log`) to avoid extra newlines
- For web servers, use SSE format (`text/event-stream`)
- Accumulate chunks if you need the full response for post-processing
- Streaming works with all models that support it
- Use streaming for user-facing apps; use regular calls for batch processing
- Always set appropriate headers for SSE in web responses
