# Model pooling — bare names vs pinned provider ids

Most Opper models are served by **more than one provider**. Opper groups those
rows together and lets you address either the whole group or one specific row.
That grouping is called a **pool**.

This is the single most useful thing to understand about `model` strings on
Opper, and it is invisible if you only ever copy ids out of the catalog.

## Two ways to name a model

| Form | Example | What it does |
|---|---|---|
| **Bare model name** (pooled) | `"model": "kimi-k3"` | Opper picks one of the providers serving that model |
| **Provider-qualified id** (pinned) | `"model": "tensorx/moonshotai/kimi-k3"` | Always that exact provider row |

Both are valid on every compat endpoint. Neither needs special headers or flags.

```bash
# Pooled — Opper routes it
curl -s https://api.opper.ai/v3/compat/chat/completions \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"gpt-oss-120b","messages":[{"role":"user","content":"hi"}]}'

# Pinned — this provider, every time
curl -s https://api.opper.ai/v3/compat/chat/completions \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"groq/gpt-oss-120b","messages":[{"role":"user","content":"hi"}]}'
```

**Default to the bare name.** You get provider redundancy and load spreading for
free. Pin only when you have a reason — see "When to pin" below.

## Finding the pool

`GET /v3/models` (no auth) returns one row per **provider**, not per model. Two
fields tie the rows together:

- **`model`** — the group key. Every row serving the same underlying model
  shares it. This is also the bare name you call.
- **`pooled`** — whether this row is in the routing set for that bare name.

```bash
# Who actually serves kimi-k3?
curl -s "https://api.opper.ai/v3/models?limit=1000" | python3 -c '
import json, sys
for m in json.load(sys.stdin)["models"]:
    if m.get("model") == "kimi-k3":
        print(m["id"], "|", "pooled" if m.get("pooled") else "PINNED-ONLY", "|", m.get("region"))
'
```

Roughly two thirds of model groups have a single provider, so for many models
the bare name and the pinned id behave identically. The difference matters on
the popular open-weight models, where a pool can be ten or more providers deep.

## How Opper picks a member

In order:

1. **Session affinity.** If the request carries an `X-Opper-Trace-Id`, that
   trace sticks to whichever provider it first landed on. If you *don't* send
   one, Opper derives an affinity key from your API key plus a **30-minute
   window** — so an untraced burst deliberately pins to a single provider for
   prompt-cache locality.
2. **Round-robin.** With no affinity hit, a per-(org, project, model) counter
   advances and picks the next member.
3. **Fallback chain.** The members that weren't picked stay behind the chosen
   one in order, and a retriable error falls through to the next one. Pooling
   is failover, not just load balancing.

**This trips people up:** firing N identical requests with no trace id and
seeing them all hit the same provider is step 1 working as designed, not broken
round-robin. Send a unique `X-Opper-Trace-Id` per request to see the spread.

Observed live on `gpt-oss-120b` (13 providers), reading the `x-opper-cost`
response header — different providers price differently, so cost is a cheap
proxy for "which one served me":

```
unique X-Opper-Trace-Id per call:   1.65e-5, 1.65e-5, 2.45e-5, 7.7e-6, 1.08e-5, 7.7e-6   <- spreading
no trace id at all (same 30m):      1.08e-5, 1.08e-5, 1.08e-5, 1.08e-5                   <- pinned by affinity
```

## Which member actually served the request?

**Not the response body.** The `model` field echoes the string you sent — send
`gpt-oss-120b` and you get `gpt-oss-120b` back, whichever provider ran it.

Read the **trace** instead. `span.meta.model` carries the resolved
`provider/provider_model_id`:

```bash
TID=$(uuidgen)
curl -s -o /dev/null https://api.opper.ai/v3/compat/chat/completions \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -H "X-Opper-Trace-Id: $TID" \
  -d '{"model":"gpt-oss-120b","messages":[{"role":"user","content":"hi"}],"max_tokens":1}'

curl -s -H "Authorization: Bearer $OPPER_API_KEY" "https://api.opper.ai/v3/traces/$TID" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["data"]["spans"][0]["meta"]["model"])'
# -> fireworks/accounts/fireworks/models/gpt-oss-120b
```

The `x-opper-cost` response header is the quick-and-dirty version when you only
need to tell members apart rather than name them.

## Why some rows are `pooled: false`

A row is held out of the pool when landing there unexpectedly would surprise
the caller. Common reasons:

- **Smaller context window.** A provider serving 320K when the rest serve 1M
  can't take bare-name traffic — a long prompt that works everywhere else would
  fail there. Opper enforces a floor on this, so pooled members are always
  within reach of the pool's full window.
- **A pricier latency-tuned variant** of the same weights, where a plain
  request should keep landing on the cheaper one.
- **Reduced capabilities** versus its siblings.

`pooled: false` rows are **not** deprecated and **not** hidden — they are fully
callable by their explicit id. They just never answer to the bare name.

## When to pin instead of pool

Pin a provider-qualified id when you need:

- **Reproducibility** — same provider on every call, e.g. for evals or A/B runs.
- **A specific jurisdiction** — pools mix regions. If the request must stay in
  the EU, pin an EU row (or filter with `?include=route` and read
  `gdpr.residency`) rather than trusting the bare name.
- **A specific price** — members of a pool can differ several-fold per Mtok.
- **A capability only one member has.** Providers serving identical weights
  still differ at the edges: whether remote `image_url`s are fetched or only
  inline base64 is accepted, whether `reasoning_effort` genuinely grades or is
  accepted-and-ignored, whether strict `json_schema` is enforced by guided
  decoding. Check the row's `capabilities` and description.

The cost of pinning is that you opt out of the fallback chain — if that one
provider is down, your call fails.

## Behaviours worth knowing

- **No route-all fallback.** Routing uses the declared pooled set only. A model
  group with zero pooled members does not route at all rather than quietly
  fanning out to every provider.
- **Retired rows are excluded.** A retired provider stops taking bare-name
  traffic immediately. If *every* member of a group is retired, the error names
  the successor model.
- **Allowlists filter the pool.** An org/project model allowlist narrows the
  members before selection, so a pool can be effectively smaller than
  `/v3/models` suggests.
- **Explicit fallback chains are a different feature.** `/v3/call`'s `model`
  parameter also accepts an *array* — models tried in order on retriable errors
  (see `CallRequest` in the spec). That's across *different models*; pooling is
  across *providers of the same model*. The compat endpoints don't take the
  array form — use a Route alias in the platform for cross-model backup chains.

## Checking your assumptions

The catalog moves weekly. Never hardcode a pool's membership — re-read
`GET /v3/models` and group by the `model` field. And grep the live spec for
anything this page doesn't answer:

```bash
curl -s https://api.opper.ai/v3/openapi.yaml | grep -n -i pooled
```
