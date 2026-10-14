---
name: decision-models
description: >
  A guide to designing games, bots and apps around decision models (System One
  models such as Jev, Clef, Microsoft Decision 1 and GPT-6 Luna Decisions,
  which answer typed questions about a state with a choice and probabilities
  instead of prose). Distilled from Opper's decision benchmarks (JevMan, Snake,
  Jev Fighter). Covers how to think, not how to build a game: when a decision
  model is the right tool and when a script or chat model is, how to write the
  state, instructions and options, what to precompute, real-time timing,
  ask-ahead and fallbacks, warm-up, testing every model, and measuring fairly
  with seeds, baselines and error margins. Use it whenever the user wants a
  model to pick moves, actions or options in a game, NPC, bot, simulation or
  agent loop, wants to benchmark models on their game, or asks about decision
  models or System One, even if they only say "make the AI play my game".
category: guide
metadata:
  version: "2026-10-14"
---

<!-- version-check: removed from the copy served at skills.opper.ai -->
> **Skill version 2026-10-14.** This is a locally installed copy and may be out of date. Once per session, fetch https://skills.opper.ai/versions.json and compare its `"guides/decision-models"` entry with 2026-10-14. If they differ, read https://skills.opper.ai/guides/decision-models/SKILL.md and follow that instead of this copy for the rest of the session, and tell the user once that their installed Opper skills are out of date (update with `npx skills update`, or `git pull` in a manual clone). Do not edit the installed files. If the fetch fails, continue with this copy.
<!-- /version-check -->

> **A guide, not an Opper API skill.** It shares how we think about decision models, learned the hard way on three benchmarks; the numbers are from October 2026 runs and will move. For the wire format (endpoints, question types, errors, model discovery) load [`opper-api` → references/decision-models.md](https://skills.opper.ai/opper-api/references/decision-models.md). For Opper itself, start at [`opper`](https://skills.opper.ai/).

# Designing with decision models

**Code what is certain. Ask the model what is a judgment. Believe it only after it beats a script.**

A decision model takes a `state` and one or more named questions, and answers each with one of the options you offered, a probability per option and a confidence. No prose, no parsing, typically 100 to 400 ms and around $0.00001 to $0.0001 a decision. One endpoint reaches every decision model Opper serves (nine models from eight makers in October 2026; list them live with `GET https://api.opper.ai/v3/models?type=evaluation`), so the same question runs on all of them by changing one string.

A tiny board for illustration (the real one is 16 by 16; full requests in [references/worked-examples.md](references/worked-examples.md)):

```json
{
  "model": "typesafe/jev-1.13.0",
  "state": { "board": ["######", "#..A.#", "#.tnH#", "######"], "length": 3, "apple": "1 up and 1 left of the head" },
  "questions": {
    "snake": {
      "type": "choice",
      "instructions": "You steer a snake... Pick the direction the head moves next.",
      "criteria": {
        "up":    "Go up: Next cell: empty. Distance to the apple after the move: 1. Cells reachable from there: 5.",
        "right": "Go right: Next cell: the wall. The game ends.",
        "down":  "Go down: Next cell: the wall. The game ends."
      }
    }
  }
}
```

The answer is `{"snake": {"type": "choice", "choice": "up", "probabilities": {...}, "confidence": 0.97}}`. Everything below is about what goes into `state`, `instructions` and `criteria`, when to ask, and how to know whether the answers are any good.

## 1. Should a model make this decision at all?

**Write the scripted player first.** It is your fallback, your baseline and your honesty check, and it is often as good as the best model:

- Snake: a flood-fill script that reads only the facts in the options scores 48.85 apples a game; the best decision model (GPT-6 Luna) scores 48.8, the next (Jev) 37.9, and six of eight models score under 26.
- JevMan: a die roll (1,037 points) beats one model (Laya, 639).

If a script over your own computed facts plays as well as the models, the facts carry the decision. That is fine for a product (ship the script, keep a model for flavour), fatal for a benchmark (you are measuring your hints).

| A decision model fits | Use something else |
|---|---|
| A small set of discrete options, offered fresh at every decision | An open answer (text, a plan, a number from a big range): a chat model |
| Many decisions, each cheap and fast (game loops, NPCs, routing, triage) | One rare, high-stakes call where 3 s and $0.01 don't matter: a chat or reasoning model |
| Fuzzy trade-offs: risk vs reward, reading an opponent, style | Exact answers: shortest path, legality, arithmetic, search. Code |
| You want several distinct "players" for the price of one integration | You need the optimum every time: a solver |

Against chat models, the decision models win on the clock and the bill, not always on play. On JevMan a chat model through a forced-choice adapter (Qwen 3.8 27B) scored 2,321 at $0.065 a game against Jev's 2,750 at $0.006; Claude Haiku 5.5 averaged 0.9 s an answer and missed the 2 s deadline on two thirds of its moves. A strong chat model is a good *reference row* in a benchmark (see section 7), ranked apart.

## 2. Decide what you are building: a game, or a benchmark

This is the decision that changes everything else, and our own two games disagree on it for that reason:

- **JevMan (a game first)** marks one route `FRUIT` in the options: "Spelling out one safe, reachable fruit route works far better than per-route distances: jev weighed 'cherry 14 steps away' against pellets and mostly let the fruit expire."
- **Jev Fighter v1 (a benchmark)** put facts in the options that named the answer, and a text parser beat every model 132-0. Four independent reviews later, v2's first goal was "no option text that names the answer".

Both are right for what they were measuring.

| | Building a game (players, product) | Building a benchmark (ranking models) |
|---|---|---|
| Options | Hand the model what code already knows: mark the best route, tag dangers loudly | Facts, never the verdict. No option says "safe", "best" or "recommended" |
| Hints | As many as make it play well | Fixed, versioned, identical for every model |
| Fallback | As smart as you like, as long as you report how often it plays | Deliberately weak and deterministic, so the harness never plays well on a model's behalf |
| Overrides | A safety re-check can make it look smarter (JevMan's doubled survival) | Never. JevMan removed its override: "every move is the model's own" |
| Timing | Whatever feels alive | One clock for every model; publish latency and the late share next to the score |
| Baselines | Optional | Required (section 7) |

A middle road exists: Jev Fighter's **assisted track** shows several numbers per option (average, worst case, usual reply) so that no single one reads as the answer; its **raw track** gives only the rules and each move's static facts. Offer both if you can; label which one a score came from.

## 3. Write the question

The question is the product. Several of the biggest score swings we saw were question bugs, not model limits.

- **Offer only legal options, keyed by short stable ids** (`up`, `block_high`). The answer is a key; anything else (a key you didn't offer, no answer) goes to the fallback. Drop options code knows are impossible (Fighter drops attacks that cannot reach). Keep deadly-but-legal options in a benchmark; say plainly what happens.
- **State consequences, not adjectives.** `Go left: Next cell: the wall. The game ends.` beats `Go left (dangerous)`. One shape for every option: `Go <dir>: fact; fact; fact`.
- **Use the frame models read reliably.** Snake asked `left / straight / right` relative to the heading: "Clef answered 'left' on almost every step, Kev and Laya walked straight into walls." The question moved to absolute directions (`up / right / down / left`) with no relative wording anywhere. Prefer absolute, board-anchored wording ("3 up and 2 left of the head").
- **Shuffle the option order per question, deterministically** (seeded from what the request shows), "so a model's position bias cannot pass for a preference". Do it in a game too: position bias is a bug in play as much as in a benchmark. Record the order, so a replay rebuilds the same question.
- **Keep the option set small.** When options multiply (slot × tower type, bet sizes × actions), drop what code knows is dominated or unaffordable and merge equivalent ones, so the question still fits the smallest context window you call.
- **Rules go once, in `instructions`; each option carries only its own facts.** Instructions are fixed text per game mode (they cache well and stay comparable); swap them by mode when the goal changes (JevMan's ghosts: chase, scatter, frightened, each with its own persona sentence).
- **Name your tags in the instructions.** JevMan tags options `DANGER`, `TRAP` and `FRUIT` and says "Never pick a route marked DANGER or TRAP unless every route is". An unexplained tag is noise.
- **Put rewards in one currency.** "A cherry worth 100 points (as much as 10 pellets)." Models compare like with like far better than mixed units.
- **State priorities as an order**: "Hunt a frightened ghost you can reach first; otherwise take the FRUIT route." Tell it when to ignore something: "cannot be reached safely in time; ignore it."
- **Say what the probabilities mean** if you use them: "how likely each move is to be your best choice."
- **A different decision is a different named question.** JevMan asks `pacman` (which way at the next junction) and, only when a ghost blocks the corridor ahead, `pacman_escape` (keep going or turn back now), once per situation.
- **Budget tokens per model.** Snake stays under about 600 tokens, Fighter's raw track about 350. Context windows range from 512 tokens (Laya) to a million (Aplomb): Laya's window was shorter than one JevMan question and it scored below a die roll while looking healthy (fast, almost no fallbacks). Degrade in a fixed order: compact rules, then drop the least useful columns, then history, then the weakest options. Check `GET /v3/models?type=evaluation` for each model's window.

Worked requests from all three games, with what each wording change did: [references/worked-examples.md](references/worked-examples.md).

## 4. Write the state

- **Grids as text rows with a legend** in the instructions; letters for entities, lowercase for a changed status ("lowercase = frightened, edible"); walls drawn in.
- **Add the numbers the grid can't show**: length, time left, steps since the last reward, lives, score.
- **Spell out the key relation in board terms**: "the apple is 9 down and 2 left of the head". Don't make the model count cells.
- **Remove fields models anchor on.** With a `heading` field in Snake's state, Aplomb "answered the current heading ('straight' on) on 46 of 51 and 53 of 60 steps and ran into the wall". Without the field Aplomb scored 15 to 18 apples and Kev's straight-on bias dropped too; the board shows a neck marker (`n`, the body cell behind the head) instead. If a model's answers copy a state field, that field is a bug.
- **For entities, short labelled lines**: `you: 100 HP, standing, free to act, 0.7 from your wall`; `recent`: the last few events; the opponent's habit if it matters.
- **Show what a player could perceive, when fairness matters**: Fighter shows the opponent as it was 10 ticks (167 ms) ago, about human reaction time.
- **Round numbers** (one decimal), cap text lengths (Fighter: 240 characters a state line, 160 an option), and keep the shape fixed so the server can check it.

## 5. Precompute what code does exactly

Models are bad at search and arithmetic and good at weighing. Give them the results, not the work:

- Distances, reachable area (flood fill), who reaches a junction first, whether a threat is approaching, the outcome of an exchange simulated a few frames ahead.
- **Compute for the moment the actor acts, not the moment it asks.** JevMan counts Pac-Man's walk to the junction into every distance and uses a conservative speed "so a fruit... is still there on arrival".
- **Several numbers per option, not one score**: average, worst case (and what causes it), usual case. One number is a verdict in disguise; a set is a trade-off.
- **Compute every fact in code and test it; never write one by hand.** In our own test of this guide, a design written by a coding agent got its hand-computed pot odds and equities wrong in every worked number. A wrong fact in an option is worse than none: the model trusts it.
- **Compute and hide** what would give the answer away (Fighter computes the `stand` column and doesn't show it).
- **Your baselines read only what the question shows.** Then a baseline's score measures how much the question gives away, which is exactly what you need to know (section 7).

## 6. Real-time loops: timing, ask-ahead, fallbacks

Choose **paused** (the game waits for every answer; measures decision quality only: "a slow model lost nothing for being slow") or **real time** (the game never waits; the score mixes quality and speed). A real-time game feels alive; a real-time benchmark must publish latency and the late share next to the score, or it mostly measures latency (Fighter v1's review).

- **Warm the model up before the first timed decision** (section 7). A cold model can take many seconds, which at a game's tick is a lost game.
- **Ask ahead, about the predicted state.** Ask as soon as the next decision point is known (the next junction, the next step's board), not when the actor gets there. Fighter asks `ceil(latency / tick) + 8` ticks ahead, clamped to 40..120, with latency smoothed (`0.8 * old + 0.2 * new`). Snake asks about step n+1 the moment step n's answer is in, never more than one step ahead. If the actor arrives first, it waits ("thinking...") or the fallback plays.
- **One request in flight per actor; cancel it at the deadline** with an `AbortController`. Without that, Snake's score "depended on how close to the tick it sat more than on its speed". A cancelled call may still be billed.
- **Don't drop an answer that is on its way because the state moved.** Fighter refreshed stale questions on every hit, and "GPT-6 Luna got 1 answer played in a whole match against greedy". Apply the answer when it arrives if it is still legal, else the fallback. Drop in-flight questions only on a real reset (a new round).
- **Key each question by exactly what changes its answer**, and discard an answer only when that key changes (JevMan's key leaves out the ghost mode, and a fruit appearing discards Pac-Man's answer).
- **Batch**: one request per model carries every open question as named questions (a request names one model). Our games cap a request at five questions; providers differ (Metis takes up to 32, Aplomb up to 128).
- **Tail latency decides, not the mean.** Haiku's 0.9 s mean still missed a 2 s deadline two thirds of the time: queueing and slow outliers.
- **Nested timeouts**: the server's call limit (2 s in our games) below the client's (2.5 s), the warm-up longer (15 s).
- **Always have a fallback, record why it played** (timeout, error, invalid answer, no longer legal), and count deaths or losses that happened while waiting separately. In a benchmark keep it weak: Snake's fallback goes straight unless that's deadly and never steers toward the apple; Fighter's blocks.

## 7. Test every model, and measure before you claim

**Warm up first.** Opper-hosted decision models scale down when idle and "the first calls can take many seconds". Send a tiny fixed question (`state: {"note": "warm-up"}`, options `a`/`b`) until one answers well inside your deadline; start it while the player is still picking; treat a model as awake for about five minutes; stand in an awake model if the chosen one won't wake. Retry warm-up only on timeouts: 401, 402 and 403 mean a key, wallet or access problem, not a cold model.

**Run every model on your question.** They differ more than you expect, and rankings don't transfer between games:

- Snake: 0.34 to 48.8 apples on the same questions. Kev and Laya end 94 to 97% of games in the wall; Jev and Aplomb 95 to 99% in their own body. Different failures need different question fixes.
- Microsoft Decision 1 is fifth on JevMan but late on 41% of Snake's 275 ms steps.
- Model ids retire upstream (Clef moved routes mid-project): read the live list, keep your own stable ids and map them.
- Rate limits look like bad play: Aplomb's first run fell back on 85% of moves (rerun: 3.2%); Metis was skipped when over 5% of calls failed in 52 of 100 games. **Read the fallback rate before you read the score**, and run real-time games one at a time.

**Measure like a benchmark, even for a game** (details and formulas: [references/benchmarking.md](references/benchmarking.md)):

1. **Fixed seeds**: every model plays the same games (`seedFor(i)`); both sides if the game is asymmetric; cycle the opponents.
2. **A baseline ladder** under the same clock as the models: random (the floor: "a model that cannot beat random is not deciding anything"), greedy, then your best script. Timing changes baseline rankings too: with instant bots Fighter ranked maximin 71.2, greedy 54.2, payoff 24.5; thinking 250 ms like a model, payoff 76.6, greedy 67.3, maximin 40.4.
3. **Enough games**: report mean ± 2 standard errors; models within the margin tie. Going from 24 to 100 games roughly halves the margin. Size the run by the margin you need, not a habit: a high-variance game (cards, dice) needs thousands of hands where Snake needed 100 games. Never rank by best game (Kev's best JevMan game is 5,280 on a 1,506 mean).
4. **Re-run before you trust a small gap.** Two 24-game runs of Jev on unchanged questions gave 3,181 and 2,558.
5. **Version the question.** Hash the questions a scripted game produces in a test; any change to wording, rules or clock bumps a version, and older results stop counting.
6. **Record every decision** (asked, arrived, applied, latency, cost, model or fallback and why, probabilities). With a deterministic engine a recording replays exactly, which is how CI can check a self-reported score.
7. **Rank decision models apart** from chat models and scripts; show those as reference rows.

## 8. Keys, cost and who pays

- **Never put a key in the browser.** The page sends the game state to your server; the server rebuilds the question with its own wording (or checks it exactly) and calls only models you list. Without that check "a script could ask the shared key anything".
- **Who pays**: your key in development; the player's own wallet with [Login with Opper](https://opper.ai/ai-wallet) in a hosted game; or a funded pool key for anonymous visitors, with a per-visitor rate limit, a request size cap and an hourly budget (our games: 8 requests a second, 16 KB, five questions, $20 an hour).
- **Read cost from the response**, the `X-Opper-Cost` header, and the trace id from `X-Opper-Trace-Id`. Record an unknown cost as null, never 0; count a cancelled call at the mean cost.
- **What it costs**: $0.0007 to $0.035 a game in our runs; a full JevMan benchmark, eight models by 100 games, cost about $5. Decision endpoints need a card on file in the Opper organization (`402` otherwise).
- **Sponsored credits**: Opper sponsors projects built on decision models. Email hello@opper.ai with the email of your Opper account and a link to the project.

## 9. Debug from failures, not from the score

- Classify every loss or death (wall, body, starved, cut off at a junction, ran into a threat) per model; the mix tells you which fact the question is missing.
- Print the last few decisions before each failure **as the model saw them**: the options' text, the odds, and what the fallback rule would have picked (JevMan's `deaths` script).
- Check the answer distribution against option position (position bias) and against each state field (anchoring).
- Show the odds on screen while developing. Players love it too: JevMan draws each model's odds at every junction.

## 10. Getting a game onto Opper's hub

Opper hosts games at [opper.ai/decision-benchmarks](https://opper.ai/decision-benchmarks), runs every decision model on them and ranks them. We port and review every game ourselves (only our own code runs there), so build in any stack and make it portable: a deterministic engine with seeds, a score, the question built in one module, a weak fallback, baselines, and a permissive license. Then [suggest the game](https://github.com/opper-ai/decision-benchmarks/issues/new?template=suggest-a-game.yml). The harness there ([opper-ai/decision-benchmarks](https://github.com/opper-ai/decision-benchmarks)) is AGPL-3.0: borrow its ideas freely, but copying its code into your own game carries AGPL's obligations.

## Before you ship

- [ ] A scripted player exists, and you know how the models compare to it.
- [ ] You decided game or benchmark, and the options, fallback and timing follow from it.
- [ ] Options are legal, keyed, shuffled, few, and factual; every fact is computed in code and tested; tags and priorities are named in the instructions.
- [ ] The question fits the smallest context window you call.
- [ ] Models warm up before play; one request in flight per actor; deadline and fallback in place, with reasons recorded.
- [ ] Every model ran on fixed seeds against baselines; you read fallback rate and latency before the score.
- [ ] No key in the browser; the server rebuilds or checks every request.
