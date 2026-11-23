# Evals for the media skills

Written scenarios that say what a good run of each skill looks like. There is no automated runner: a scenario is run by hand, by a fresh agent that has only the Opper Media tools, the skill under test and the user's one line.

## Why

A skill is text an assistant follows, so the only real test is to watch one follow it. The scenarios pin down what must happen (the stops, the order, what gets asked) and what must not (a model id from memory, a screenshot sent through a model, a promise of a finished film where the result is an edit list).

## How to run a round

1. Start a fresh agent with the Opper Media connection and the one skill installed. Give it nothing else: no shell, no other files.
2. Send the scenario's request as the user's only message.
3. Answer its questions the way a user in a hurry would: "go with what you recommend".
4. Score it against the scenario's "Good" and "Bad" lists. A run passes when every "Good" line holds and no "Bad" line does.
5. Write down the date, the commit of this repo, what the agent made, and where the skill's text was wrong, unclear or missing something. Fix the skill, not the scenario, unless the scenario was wrong.

Generations in a round are real. Keep to drafts: the shortest length and the lowest resolution.

## When to add a scenario

- A skill is added, or one of its steps changes.
- A run goes wrong in a way no scenario would have caught.
- A model's behaviour changes what a step should say.

Each skill keeps at least three: the plain case, a harder one, and one request that belongs to a neighbouring skill.
