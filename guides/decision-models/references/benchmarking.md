# Benchmarking a game on decision models

How Opper's decision benchmarks rank models, so a game of your own can measure them the same way. The full implementation is open source in [opper-ai/decision-benchmarks](https://github.com/opper-ai/decision-benchmarks) (`packages/kit`, AGPL-3.0); this page is the method, so you can build it in any stack.

## What a game needs before it can rank anything

| Piece | Why | How ours do it |
|---|---|---|
| A deterministic engine | The same answers give the same game, so a recording replays and a score can be checked | Seeded PRNG for everything random (apples, start positions); no wall clock inside the rules |
| Fixed seeds | Every model faces the same games | `seedFor(i) = Math.imul(i + 1, 0x9e3779b1) >>> 1` for game `i` |
| One score per game | Something to average | Apples eaten; points; share of rounds won (a draw counts half) |
| The question in one module | The bench, the page, the server's request check and the baselines must build the identical question | Snake's `questions.ts`: `viewOf`, `questionFor`, `stateFor`, `parseState` |
| A weak, deterministic fallback | Late, invalid or failed answers still move the game, without playing well for the model | Snake: straight unless deadly. Fighter: block high |
| Baselines | A floor and a yardstick | random, greedy, a real script |
| A version number | Results from different questions must never mix | `benchVersion`, bumped on any change to rules, wording or clock |

## The baseline ladder

1. **Random** over the offered moves: the floor. "A model that cannot beat random is not deciding anything." Snake's random baseline picks among non-deadly moves only, and Laya still scored below it.
2. **Greedy**: the obvious one-step rule (closest to the apple; best payoff against the opponent's likeliest reply).
3. **Your best script**: flood fill, maximin, whatever a good programmer writes in an afternoon.

Rules for baselines:

- **They read only what the question shows** (the request's state and options, parsed back), never the engine's internals. Then a baseline's score is a direct measure of how much the question gives away. If your best script equals your best model, the facts are carrying the decision.
- **They play under the models' clock.** An instant bot is a different player from one that thinks 250 ms: Fighter's ranking of its three scripts reversed when they were given model-like thinking time.
- **They answer like a model when they can** (same transport, same question), so the same harness and verifier play them.
- **They never go on the model leaderboard.** Show them in their own group, for reference.

## Running the models

- **Warm every model first**: a tiny fixed question, repeated until one answer comes back within 0.9 × the deadline (up to a few minutes). Retry only on timeouts.
- **Skip a model that won't answer** instead of aborting the run, and list it as skipped with the reason. **Write results after each model**, so a crash late in the run keeps the rest.
- **One game at a time** for a real-time game (`--parallel 1`), so a model's calls don't queue behind each other and rate limits don't pose as bad play.
- **Check the fallback rate before publishing.** A few percent is normal (2 to 5% on JevMan). A spike means rate limits or an outage (Aplomb's first run: 85%), not a bad model. We skip a model when more than 5% of calls fail in many games.
- **A chat model as a reference row.** Ask it the same question through a strict JSON schema: `choice` as an enum of the option keys and a required number per option under `probabilities`, with a system prompt like "You make one decision in a game... Answer only with JSON: your choice (one of the options) and a probability for each option." Strip code fences before parsing; anything unparsable goes to the fallback. Rank it apart from decision models.

## Statistics

- **Score** = the mean over all games. **Margin** = 2 standard errors, where SE = sample standard deviation / √n.
- **Two models tie** when `|mean_a - mean_b| < 2 · √(SE_a² + SE_b²)`. Show tied leaders as `=1`, including every row between them.
- **Game counts**: 100 games a model for official runs, at least 24 for a self-reported one. Four times the games roughly halves the margin. A 24-game run has a wider margin and can tie a leader that a narrower 100-game run would not.
- **Never rank by best game.** It is mostly luck (Kev's best JevMan game: 5,280; its mean: 1,506).
- **Re-run before trusting a gap near the margin.** Two 24-game runs of Jev on JevMan with unchanged questions gave 3,181 ± 186 and 2,558 ± 177.
- **Report beside the score**: mean latency, the late or fallback share, cost per game, and how games ended (wall, body, starved, timeout; KO, time). A score without these can't be read.
- **Pairwise games** (fighters against each other) can use Bradley-Terry ratings with bootstrap intervals; against fixed baselines, a mean share of rounds won is enough.

## Recording and replay

Record every decision so a game can be replayed and audited:

```json
{
  "format": 1, "game": "snake", "benchVersion": 3, "seed": 1327217880, "model": "typesafe/jev-1.13.0",
  "steps": [
    { "choice": "left", "source": "model", "probabilities": { "left": 0.91, "up": 0.06, "down": 0.03 }, "latencyMs": 212, "costUsd": 0.00004 },
    { "choice": "straight", "source": "fallback" }
  ],
  "result": { "score": 41, "steps": 612, "end": "body" }
}
```

- The verifier replays the steps from the seed with the game's own engine, checks each choice was an offered option, checks every `fallback` step is exactly what the fallback rule gives (so moves can't be relabelled either way), and recomputes the result. A fingerprint (a hash of the seed and the choices) catches the same game sent twice.
- **What a replay cannot check**: that a model made the moves, how fast it was, what it cost, and that the run wasn't the best of several. That is why self-reported results are labelled as such. Timing in a real-time game is self-reported too.
- **Version the question with a test**: play one scripted game, hash every question and fallback answer it produced, and compare to a stored hash. A changed hash means a new `benchVersion`.
- **Sign answers on the server** if players can submit high scores: JevMan's check once trusted the ghost moves a recording claimed, and "a bot scored ~2,000 that way". The server now signs each model answer for its decision point and model, and a high score replays only signed answers.

## Cost of a run

From our October 2026 runs, per game: $0.0007 (Laya, Snake) to $0.035 (GPT-6 Luna, Snake); JevMan's eight models by 100 games came to about $5 in total. Read the cost from each response's `X-Opper-Cost` header; a call you cancelled may still be billed, so count it at the game's mean cost per answered call, and store an unknown cost as null.

## Getting onto Opper's hub

Each game on [opper.ai/decision-benchmarks](https://opper.ai/decision-benchmarks) serves a few files the hub reads:

- `game.json`: `{ slug, name, tagline, category, author: { github, originalRepo? }, license, metric: { name, unit, higherIsBetter }, updatedAt }`.
- `leaderboard.json`: `{ generatedAt, game, benchVersion, metric, entries, skipped }`, an entry being `{ model, name, games, metric: { mean, stdError, best }, meanLatencyMs, fallbackRate, costPerGame, via }`, best first.
- `community.json`: self-reported entries, the same shape plus `by`, `url` and `selfReported: true`.
- `poster.png`: 16:9, at most 150 KB.

Opper ports and reviews every hosted game itself, with the author's agreement and credit. If your game has the pieces in the first table, [suggest it](https://github.com/opper-ai/decision-benchmarks/issues/new?template=suggest-a-game.yml).
