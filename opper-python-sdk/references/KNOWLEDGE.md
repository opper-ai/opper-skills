# Knowledge Bases Reference (Python SDK)

Knowledge bases provide semantic search over your documents using vector embeddings. Use them for RAG (Retrieval-Augmented Generation) pipelines.

## Contents
- [Creating an Index](#creating-an-index)
- [Adding Documents](#adding-documents)
- [Querying (Semantic Search)](#querying-semantic-search)
- [Query with Metadata Filters](#query-with-metadata-filters)
- [RAG Pattern: Query + Call](#rag-pattern-query--call)
- [Listing Indexes](#listing-indexes)
- [Getting an Index](#getting-an-index)
- [Deleting Documents](#deleting-documents)
- [Deleting an Index](#deleting-an-index)
- [File Upload](#file-upload)
- [Document Structure](#document-structure)
- [Best Practices](#best-practices)

## Creating an Index

```python
from opperai import Opper

opper = Opper()

# Create a new knowledge base index
index = opper.indexes.create("support_docs")
```

## Adding Documents

```python
from opperai.types import DocumentIn

# Add a single document
index.add(DocumentIn(
    key="doc_001",
    content="To reset your password, click 'Forgot Password' on the login page.",
    metadata={"category": "auth", "source": "helpdesk"},
))

# Add multiple documents
documents = [
    DocumentIn(
        key="doc_002",
        content="Billing cycles run on the 1st of each month.",
        metadata={"category": "billing"},
    ),
    DocumentIn(
        key="doc_003",
        content="To upgrade your plan, go to Settings > Subscription.",
        metadata={"category": "account"},
    ),
]
for doc in documents:
    index.add(doc)
```

## Querying (Semantic Search)

```python
# Basic query - returns most relevant documents
results = index.query("How do I change my password?", k=3)

for result in results:
    print(f"Score: {result.score:.3f}")
    print(f"Content: {result.content}")
    print(f"Metadata: {result.metadata}")
    print("---")
```

## Query with Metadata Filters

```python
# Filter results by metadata
results = index.query(
    "billing question",
    k=5,
    filters={"category": "billing"},
)
```

## RAG Pattern: Query + Call

Combine knowledge base retrieval with task completion:

```python
from opperai import Opper, trace
from opperai.types import DocumentIn
from opperai.types.indexes import RetrievalResponse
from pydantic import BaseModel
from typing import List

class AnswerWithSources(BaseModel):
    answer: str
    sources: List[str]

@trace
def answer_with_context(question: str) -> AnswerWithSources:
    # 1. Retrieve relevant context
    results = index.query(question, k=3)

    # 2. Build context string
    context = "\n".join([
        f"[{r.metadata.get('source', 'unknown')}]: {r.content}"
        for r in results
    ])

    # 3. Call with context
    result, _ = opper.call(
        name="answer_with_rag",
        instructions="Answer the question using only the provided context. Cite sources.",
        input=f"Context:\n{context}\n\nQuestion: {question}",
        output_type=AnswerWithSources,
    )
    return result
```

## Listing Indexes

```python
indexes = opper.indexes.list()
for idx in indexes:
    print(f"{idx.name}: {idx.id}")
```

## Getting an Index

```python
# By name
index = opper.indexes.get_by_name("support_docs")

# By ID
index = opper.indexes.get(index_id="idx_123")
```

## Deleting Documents

```python
# Delete a specific document by key
index.delete(key="doc_001")
```

## Deleting an Index

```python
opper.indexes.delete(index_id="idx_123")
```

## File Upload

Upload files (PDF, DOCX, etc.) for automatic processing:

```python
# Get upload URL
upload_info = index.get_upload_url(filename="manual.pdf")

# Upload the file (use requests or similar)
import requests
with open("manual.pdf", "rb") as f:
    requests.put(upload_info.url, data=f)

# Register the upload
index.register_file_upload(
    upload_id=upload_info.upload_id,
    filename="manual.pdf",
)
```

## Document Structure

Each document has:
- **key**: Unique identifier within the index (used for updates/deletes)
- **content**: The text content to be indexed and searched
- **metadata**: Arbitrary key-value pairs for filtering and context

## Best Practices

- Use meaningful `key` values for document management
- Keep documents focused — one topic per document works better than large multi-topic docs
- Add relevant `metadata` for filtering (category, source, date, etc.)
- Use `k=3` to `k=5` for most queries — more results can add noise
- Combine with the `@trace` decorator for observability in RAG pipelines
- Update documents by re-adding with the same `key`
