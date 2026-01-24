# Tracing Reference (Python SDK)

Tracing provides full observability into your AI operations with hierarchical spans, metrics, and dashboard visibility.

## Starting a Trace

A trace groups related operations together:

```python
from opperai import Opper

opper = Opper()

# Context manager pattern (recommended)
with opper.traces.start("my_pipeline") as trace:
    # All operations inside are grouped under this trace
    result1, _ = opper.call(name="step1", instructions="...", input="...")
    result2, _ = opper.call(name="step2", instructions="...", input=result1)
```

## The @trace Decorator

Automatically create spans for functions:

```python
from opperai import Opper, trace

opper = Opper()

@trace
def process_document(doc: str) -> str:
    result, _ = opper.call(
        name="summarize",
        instructions="Summarize the document",
        input=doc,
    )
    return result

@trace
def enrich_summary(summary: str) -> dict:
    result, _ = opper.call(
        name="extract_topics",
        instructions="Extract key topics",
        input=summary,
        output_type=dict,
    )
    return result

# Nested traces create parent-child spans automatically
with opper.traces.start("document_pipeline") as t:
    summary = process_document("Long document text...")
    enriched = enrich_summary(summary)
```

## Saving Metrics on Spans

Attach custom metrics to any span:

```python
result, response = opper.call(
    name="generate_answer",
    instructions="Answer the question",
    input="What is Opper?",
)

# Save metrics on the span
response.span.save_metric("quality_score", 4.5)
response.span.save_metric("relevance", 0.92)
response.span.save_metric("latency_ms", 320)
```

## Listing Traces

```python
# List recent traces
traces = opper.traces.list()
for t in traces:
    print(f"{t.id}: {t.name} ({t.status})")
```

## Getting a Trace

```python
trace = opper.traces.get(trace_id="trace_123")
print(trace.name)
print(trace.spans)  # List of spans in this trace
```

## Span Operations

```python
# Get a specific span
span = opper.spans.get(span_id="span_456")

# Update span metadata
opper.spans.update(
    span_id="span_456",
    metadata={"reviewed": True},
)
```

## Saving Spans to Datasets

Save span inputs/outputs as training examples:

```python
# Save a span's data to a dataset for fine-tuning or evaluation
opper.spans.save_examples(
    span_id="span_456",
    dataset_name="training_data",
)
```

## Tags for Filtering

Tags on calls automatically appear on their spans:

```python
result, _ = opper.call(
    name="classify",
    instructions="Classify the text",
    input="some text",
    tags={
        "environment": "production",
        "user_id": "usr_123",
        "experiment": "v2",
    },
)
# These tags are visible in the dashboard for filtering
```

## Trace Hierarchy

Traces form a tree structure:

```
Trace: "qa_pipeline"
├── Span: "retrieve_context" (knowledge base query)
├── Span: "generate_answer" (LLM call)
│   └── Metric: quality_score = 4.5
└── Span: "validate_output" (LLM call)
```

## Dashboard Integration

All traces and spans appear in the Opper dashboard at [platform.opper.ai](https://platform.opper.ai) where you can:

- View trace timelines and span hierarchies
- Filter by tags, time range, or function name
- Inspect inputs, outputs, and metrics
- Export data for analysis
- Set up alerts on metrics

## Best Practices

- Use descriptive trace names: `"user_query_pipeline"` not `"trace1"`
- Add `@trace` to all significant functions in your pipeline
- Save metrics that matter for quality: accuracy, relevance, latency
- Use tags consistently across calls for effective filtering
- Keep trace names stable — changing them breaks dashboard filters
- Use the context manager for top-level traces to ensure proper cleanup
