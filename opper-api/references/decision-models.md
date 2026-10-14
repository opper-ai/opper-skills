# Decision models — System One and Decisions

Decision models answer typed questions about a state with **probabilities instead of text**: a choice among options you name, a yes/no, or a score on ordered levels. They are fast (typically 100–400 ms) and cheap (around $0.00001–$0.0001 a call), which makes them fit for game loops, NPCs, routing, triage and classification. Every decision model Opper serves answers both wire formats below; Opper translates between them, so one client reaches all of them by changing `model`.

For **how to design questions, what to precompute, timing, fallbacks and benchmarking**, load the guide: [`guides/decision-models`](https://skills.opper.ai/guides/decision-models/SKILL.md). This page is the wire contract only. Definitive shapes: the live spec, `EvaluationRequest` (System One) and the `/v3/compat/decisions` path in `https://api.opper.ai/v3/openapi.yaml`. Docs: [docs.opper.ai/build/gateway/evaluations](https://docs.opper.ai/build/gateway/evaluations).

## Which endpoint

| Endpoint | Format | Shape | Pick it when |
|---|---|---|---|
| `POST /v3/compat/v1/systemone` | [TypeSafe System One](https://docs.typesafe.ai/api) | `state` + **named** questions (an object); options as a `criteria` object | Games and loops: answers come back under your own question names, option text sits next to its key. What Opper's benchmarks use |
| `POST /v3/compat/decisions` | [OpenAI Decisions](https://developers.openai.com/api/docs/guides/decisions) | `input` + a **list** of questions; options as a `choices` array | You already use the OpenAI SDK (`client.decisions.create`, Python SDK ≥ 3.26.0, `base_url` `https://api.opper.ai/v3/compat`), or you send images to `gpt-6-luna` |

Both take `Authorization: Bearer $OPPER_API_KEY` (project-scoped key), both are synchronous: no streaming, no tools. Decision models answer **only** on these two endpoints; chat completions refuses them (a bare `gpt-6-luna` on chat completions is OpenAI's chat model).

## Models

```bash
curl -s "https://api.opper.ai/v3/models?type=evaluation"   # no auth
```

Read the list live; never hardcode it. In October 2026 it had 12 routes for 9 models from 8 makers (TypeSafe Jev, Cloudflare Clef and Clef Flash, Microsoft Decision 1, OpenAI GPT-6 Luna Decisions, EmpirioLabs Aplomb 1, GreenPT Metis, Kev 4B, ConvAI Laya). Each entry has a `context_window`: it ranges from 512 tokens (Laya) to 1M (Aplomb), and **a question longer than the window fails or plays badly**, so check it per model.

- **Use the full catalog id** (`typesafe/jev-1.13.0`, `opper/kev-4b`, `openai/gpt-6-luna-decisions`, `azure:global/microsoft-decision-1`). Bare names resolve only for the endpoint's native maker: `jev-1.13.0`, `jev-latest`, `jev-preview` on System One; `gpt-6-luna` on Decisions.
- Aliases follow Opper's approved mapping, not every upstream release. The response's `model` names the upstream model that answered.
- Ids move: a maker can retire a route (`opper/clef` became `sference/clef`). Keep your own stable ids in your app and map them.

## System One — `POST /v3/compat/v1/systemone`

The body allows exactly `model`, `state` and `questions` (`additionalProperties: false`): strip any bookkeeping of your own before sending.

```bash
curl --fail-with-body -sS https://api.opper.ai/v3/compat/v1/systemone \
  -H "Authorization: Bearer $OPPER_API_KEY" \
  -H "Content-Type: application/json" \
  -H "X-Opper-Name: my-game-move" \
  -d '{
  "model": "typesafe/jev-1.13.0",
  "state": { "board": ["#####", "#.A.#", "#.H.#", "#####"], "apple": "1 up of the head" },
  "questions": {
    "move": {
      "type": "choice",
      "instructions": "Pick the direction the head moves next.",
      "criteria": {
        "up": "Go up: Next cell: the apple.",
        "left": "Go left: Next cell: empty.",
        "right": "Go right: Next cell: empty."
      }
    }
  }
}'
```

```json
{
  "model": "jev-1.13.0",
  "answers": {
    "move": { "type": "choice", "choice": "up", "confidence": 0.98, "probabilities": { "up": 0.98, "left": 0.01, "right": 0.01 } }
  },
  "usage": { "input_tokens": 312, "output_tokens": 4 }
}
```

| Question `type` | `criteria` | Answer |
|---|---|---|
| `choice` | Object, 1–255 entries: `{ "<key>": "<what choosing it means>" }` | `choice` (one key), `confidence`, `probabilities` per key |
| `noul` (yes/no) | Optional: `{ "true": "...", "false": "..." }` | `noul`: the probability of yes, 0–1 |
| `score` | Ordered **array** of 2–10 levels, lowest first | `score` (probability-weighted, can be fractional), `confidence`, `probabilities` keyed `"0"`, `"1"`, ... |

- `state` is a string, an object or an array. `questions` is a non-empty object; answers come back under the same names. Several questions in one request are answered together (one request names one model).
- **Validate the answer** before you use it: a `choice` that isn't one of your keys, or a missing answer, should go to your own fallback.
- **Provider differences** (from the spec): GreenPT Metis takes 1–32 questions jointly, `state` may be null and `instructions` optional; EmpirioLabs Aplomb takes 1–128 questions and accepts media nodes anywhere in `state` (`{"type": "image" | "audio" | "video", "url": "https://..."}` or base64 `data` with `mime`). Jev 1.13 has a 64k total context, with 32k for the state plus the longest question. Other models keep their own validation.

## Decisions — `POST /v3/compat/decisions`

```json
{
  "model": "gpt-6-luna",
  "input": "I was charged twice for my October invoice.",
  "questions": [
    { "type": "predicate", "name": "refund", "instructions": "Does the customer ask for a refund?" },
    { "type": "choice", "name": "team", "instructions": "Which team should handle this?",
      "choices": [ { "value": "billing", "description": "Payments and invoices" }, { "value": "technical" } ] },
    { "type": "score", "name": "urgency", "instructions": "How urgent is this?",
      "levels": [ { "label": "Low" }, { "label": "Medium" }, { "label": "High" } ] }
  ]
}
```

- `predicate` ↔ System One `noul`; `choice` takes 2–255 `choices` (string or boolean `value`); `score` takes 2–10 `levels`. Answers come back **in question order**, each with its `name`; probabilities are a list of `{ value, probability }`.
- `input` is a string or user messages with `input_text` and inline base64 `input_image` parts. Images work on `gpt-6-luna` (and Aplomb); other models are text-only and return `400` for images.
- A declined question comes back as `{"type": "refusal", "name": "..."}` (billed as usual). On System One a decline is a `422`.
- Translated models lose message boundaries (text parts are joined) and some native metadata; use System One for the native contract.

## Headers

| Header | Direction | Use |
|---|---|---|
| `X-Opper-Name` | request | A name per call site (`my-game-move`), for traces and function-scoped rules |
| `X-Opper-Tags` | request | `key:value` usage tags (max 8), e.g. `game:snake,mode:bench`; group spend by any key |
| `X-Opper-Cost` (= `X-Generation-Cost`) | response | The call's cost in USD. Record it per decision |
| `X-Opper-Trace-Id`, `X-Generation-Id` | response | Find the call in Logs and traces |

## Errors

| Status | Meaning | Treat it as |
|---|---|---|
| `400` | Bad request: unknown or wrong-type model, images to a text-only model, an upstream bad request | A bug; fix the request |
| `401` | Missing or invalid key | Account problem: stop, don't retry |
| `402` | **No card on file** in the organization, or billing blocked | Account problem: decision endpoints need a card on file |
| `403` | A model access rule or provider entitlement blocks it | Account problem: allow the model, or pick another |
| `422` | Invalid System One request, unsupported question type or field, or a declined question | A bug or a decline |
| `429` | Upstream rate limit (`Retry-After` passed through for `gpt-6-luna`) | Back off; in a benchmark it poses as bad play, so watch the fallback rate |
| `502`, `503`, `504`, `529` | Upstream failure, unavailable, timeout, TypeSafe overloaded | Transient: fallback now, retry later |

Opper-hosted decision models scale down when idle; the first call after a pause can take many seconds. Warm a model with a tiny question before a timed session, and give that call a longer timeout (our games use 15 s) than game calls (2 s).

## A call from code, with a deadline and a fallback

```ts
// Server-side only: the key never reaches a browser.
export async function decide(
  model: string,
  state: unknown,
  question: { instructions: string; criteria: Record<string, string> },
  timeoutMs = 2000,
): Promise<{ choice: string | null; probabilities?: Record<string, number>; costUsd: number | null; latencyMs: number }> {
  const t0 = performance.now();
  const res = await fetch("https://api.opper.ai/v3/compat/v1/systemone", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.OPPER_API_KEY}`,
      "Content-Type": "application/json",
      "X-Opper-Name": "my-game-move",
    },
    body: JSON.stringify({ model, state, questions: { move: { type: "choice", ...question } } }),
    signal: AbortSignal.timeout(timeoutMs),
  });
  const latencyMs = performance.now() - t0;
  const cost = res.headers.get("x-opper-cost");
  if (!res.ok) throw new Error(`decision ${res.status}: ${(await res.text()).slice(0, 200)}`); // 401/402/403: stop; 5xx: fallback
  const { answers } = (await res.json()) as { answers: Record<string, { choice?: string; probabilities?: Record<string, number> }> };
  const a = answers.move;
  const choice = a?.choice && a.choice in question.criteria ? a.choice : null; // null -> your fallback
  return { choice, probabilities: a?.probabilities, costUsd: cost === null ? null : Number(cost), latencyMs };
}
```

A timeout throws an `AbortError` (`TimeoutError`): play your fallback and record why. A cancelled call may still be billed.
