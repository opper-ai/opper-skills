# Model routing — pools, pins, aliases and routes

The `model` string on any compat call can be four different things. They all go
through the same resolution pipeline, and they compose.

| Form | Example | What it addresses |
|---|---|---|
| **Bare model name** — a *pool* | `"kimi-k3"` | Every provider Opper has for that model. Opper picks one; the rest are failover |
| **Provider-qualified id** — a *pin* | `"tensorx/moonshotai/kimi-k3"` | Exactly that one provider row |
| **Org alias** — your own list | `"my-flash"` | An ordered list of targets you defined: primary first, then fallbacks |
| **Route** — a deployed graph | `"dynamic/my-route"` | A routing graph you built: classification, branching, per-node fallbacks, versioned |

None of these need special headers or flags — they're all just the `model`
field.

**There is no universally right answer.** Pin when you need determinism, pool
when you want resilience, alias when you want your own named policy, route when
the decision depends on the request. Pick per use case:

| You want | Use |
|---|---|
| Provider redundancy without thinking about it | **bare name** |
| Reproducible evals / A/B runs, one provider every time | **pin** |
| A guaranteed jurisdiction, price, or provider-specific behaviour | **pin** |
| Your own ordering across providers *or* across models, named once and reused | **alias** |
| A cheap model for easy prompts and an expensive one for hard ones | **route** |
| Versioning, rollback, and simulation of the routing decision itself | **route** |

---

## 1. Pools — the bare model name

`GET /v3/models` returns one row per **provider**, not per model. Most models
are served by several, and Opper groups them into a **pool** addressed by the
bare name.

```bash
# Pooled — Opper routes it
curl -s https://api.opper.ai/v3/compat/chat/completions \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"gpt-oss-120b","messages":[{"role":"user","content":"hi"}]}'
```

Two fields tie the rows together:

- **`model`** — the group key, and the bare name you call.
- **`pooled`** — whether this row answers to that bare name.

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

### How Opper picks a member

1. **Session affinity.** If the request carries an `X-Opper-Trace-Id`, that
   trace sticks to whichever provider it first landed on. If you *don't* send
   one, Opper derives an affinity key from your API key plus a **30-minute
   window** — so an untraced burst deliberately pins to a single provider for
   prompt-cache locality.
2. **Round-robin.** With no affinity hit, a per-(org, project, model) counter
   advances and picks the next member.
3. **Fallback chain.** The members that weren't picked stay behind the chosen
   one in order, and a retriable error falls through to the next. Pooling is
   failover, not just load balancing.

**This trips people up:** firing N identical requests with no trace id and
seeing them all hit the same provider is step 1 working as designed, not broken
round-robin. Send a unique `X-Opper-Trace-Id` per request to see the spread.

Observed on `gpt-oss-120b` (13 providers), reading the `x-opper-cost` response
header — providers price differently, so cost is a cheap proxy for "which one
served me":

```
unique X-Opper-Trace-Id per call:   1.65e-5, 1.65e-5, 2.45e-5, 7.7e-6, 1.08e-5, 7.7e-6   <- spreading
no trace id at all (same 30m):      1.08e-5, 1.08e-5, 1.08e-5, 1.08e-5                   <- pinned by affinity
```

### Why some rows are `pooled: false`

A row is held out of the pool when landing there unexpectedly would surprise
the caller — a materially smaller context window, a pricier latency-tuned
variant of the same weights, or reduced capabilities versus its siblings.

Those rows are **not** deprecated and **not** hidden. They're fully callable by
their explicit id; they just never answer to the bare name.

---

## 2. Pins — the provider-qualified id

```bash
curl -s https://api.opper.ai/v3/compat/chat/completions \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{"model":"groq/gpt-oss-120b","messages":[{"role":"user","content":"hi"}]}'
```

Use the `id` field from `/v3/models` verbatim. A pin is exact: no pool
expansion, no failover. If that provider is down, the call fails — that's the
trade you make for determinism.

Pinning is the right call more often than "always pool" suggests. Providers
serving *identical weights* still differ at the edges: whether remote
`image_url`s are fetched or only inline base64 is accepted, whether
`reasoning_effort` genuinely grades or is accepted-and-ignored, whether strict
`json_schema` is enforced by guided decoding, what the context window is, and
what it costs. Check the row's `capabilities`, `context_window` and
`description` — and `?include=route` for `gdpr.residency` when jurisdiction
matters, since **pools mix regions**.

---

## 3. Aliases — your own named list

An **org alias** is a name you define that expands to an ordered list of
targets: the first is the primary, the rest are fallbacks tried in order.
Aliases are org-scoped, so every project in the org can use them.

```bash
# List your aliases
curl -s https://api.opper.ai/v2/models/aliases \
  -H "Authorization: Bearer $OPPER_API_KEY"

# Create one
curl -s -X POST https://api.opper.ai/v2/models/aliases \
  -H "Authorization: Bearer $OPPER_API_KEY" -H "Content-Type: application/json" \
  -d '{
        "name": "my-flash",
        "fallback_models": [
          "tensorx/deepseek/deepseek-v4-flash",
          "fireworks/deepseek-v4-flash",
          "morph/morph-dsv4flash"
        ],
        "description": "EU primary, US fallbacks"
      }'
```

Then just call it:

```json
{"model": "my-flash", "messages": [...]}
```

Create validates every entry in `fallback_models` against the catalog and
rejects unknown names with a "did you mean …?" suggestion, so a typo fails at
alias-creation time rather than at call time.

Full CRUD is there too — `GET /v2/models/aliases/{id}`,
`GET /v2/models/aliases/by-name/{name}`, `PATCH /v2/models/aliases/{id}`,
`DELETE /v2/models/aliases/{id}`. Grep the spec for `ModelAlias` for the exact
schemas, including the optional per-alias `options` object (routing knobs such
as a first-token timeout).

Reach for an alias when you want to **name a policy once and reuse it**: a
preferred provider order, a cross-model backup chain (`opus` → `sonnet`), or a
stable name you can repoint later without touching application code.

Two constraints:

- **Expansion is single-level.** An alias target is not re-resolved as another
  alias — nesting them surfaces "model not found" rather than walking.
- **Alias targets can be bare names.** A member that is a bare model name
  expands into its own pool, so aliases and pools stack.

---

## 4. Routes — a deployed routing graph

A **Route** is the heavyweight option: a graph you build and deploy, with
classifier nodes that inspect the request and branch, model nodes that call a
model, per-node fallback edges, and full version history.

Call it by prefixing the route name with `dynamic/`:

```json
{"model": "dynamic/my-route", "messages": [...]}
```

Responses carry headers telling you exactly what the graph did:

| Header | Means |
|---|---|
| `X-Opper-Route-Name` | Which route ran |
| `X-Opper-Route-Version` / `-Version-UUID` | Which deployed version |
| `X-Opper-Route-Model` | The model the route actually landed on |
| `X-Opper-Route-Node` | Which node produced the answer |
| `X-Opper-Route-Error` / `-Status` | Set when the route itself failed (e.g. `route_not_found`) |

Every model node in a graph is **required** to declare a fallback edge — to
another model node or to END — so a route can't be deployed with a dead end.

### Calling vs managing — two different credentials

**Calling a route needs nothing special.** `"model": "dynamic/my-route"` works
with your ordinary project API key, exactly like any other model string. This is
the part your application does, and it is not gated.

**Managing** routes — create, edit the draft, deploy, roll back — is separate,
and there are two ways in:

| Path | Credential | Who uses it |
|---|---|---|
| Platform UI → *Settings → Dynamic Routes* | your normal login session | **the usual way** — a visual graph builder; no key to mint |
| `/management/v1/dynamic-routes` | a **Management API Key** with `dynamic_routes:read` / `dynamic_routes:write` scopes | programmatic / CI management |

A project API key (`op-...`) is **not** accepted on the management endpoints —
that's a deliberate privilege split, not an oversight. Management API Keys are
minted from the platform UI behind a human approval flow, and `/management/v1/*`
is tier-gated (orgs without the control-plane entitlement get a 403).

So: no, you don't need a management key to *use* routes, and you don't need one
to *build* them in the UI either. You need one only to manage them over HTTP.

```
GET|POST   /management/v1/dynamic-routes
GET|DELETE /management/v1/dynamic-routes/{name}
PUT        /management/v1/dynamic-routes/{name}/draft
POST       /management/v1/dynamic-routes/{name}/deploy
POST       /management/v1/dynamic-routes/{name}/simulate
GET        /management/v1/dynamic-routes/{name}/versions
POST       /management/v1/dynamic-routes/{name}/versions/{n}/rollback
```

Aliases are *not* valid targets inside a route graph — model nodes resolve
canonical model names and pinned ids only. (Aliases themselves have no such
split: `/v2/models/aliases` takes an ordinary project API key.)

---

## How the four compose

One pipeline, applied in order:

1. **Auto-classify** — only when `model` is empty.
2. **Alias expansion** — one level; produces the ordered member list.
3. **Registry exact match** — a pinned `provider/model-id`.
4. **Deprecated → successor** — a retired row transparently walks to its
   replacement.
5. **Pool expansion** — a bare name becomes its pooled providers, ordered by
   affinity then round-robin.
6. **Explicit fallback** appended.
7. **Credential binding, allowlist filter, final ordering** (BYOK first).

So an alias resolving to `[kimi-k3, gpt-oss-120b]` expands each of those into
its own pool, producing one flat ordered plan with failover between every
entry. Routes are handled separately, ahead of this: `dynamic/<name>` runs the
graph, and each model node resolves through steps 3–5 with alias expansion
disabled.

Pinning short-circuits steps 2, 4 and 5 — a pin is literal by design. Explicit
fallback (step 6) is honoured even when pinned.

---

## Which model actually served the request?

**Not the response body.** The `model` field echoes the string you sent — send
`gpt-oss-120b`, an alias name, or a `dynamic/` route and you get that same
string back, whichever provider ran it.

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

For routes, the `X-Opper-Route-Model` response header answers it without a
trace lookup. The `x-opper-cost` header is the quick-and-dirty version when you
only need to tell members apart rather than name them.

---

## Behaviours worth knowing

- **No route-all fallback.** Pool routing uses the declared pooled set only. A
  model group with zero pooled members does not route at all rather than
  quietly fanning out to every provider.
- **Retired rows are excluded** from pools immediately. If *every* member of a
  group is retired, the error names the successor model.
- **Allowlists filter the pool.** An org/project model allowlist narrows the
  members before selection, so a pool can be effectively smaller than
  `/v3/models` suggests.
- **The compat endpoints take a string `model`, never an array.** Sending an
  array is a 400 (`cannot unmarshal array into ... type string`). The array
  form — a fallback chain across models — exists on `/v3/call`'s `CallRequest`,
  which is legacy. On compat, use an alias or a route instead.

## Checking your assumptions

The catalog moves weekly. Never hardcode a pool's membership — re-read
`GET /v3/models` and group by the `model` field. And grep the live spec for
anything this page doesn't answer:

```bash
curl -s https://api.opper.ai/v3/openapi.yaml | grep -n -iE "pooled|ModelAlias"
```
