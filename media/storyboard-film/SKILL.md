---
name: storyboard-film
description: >
  Storyboard, keyframes, shot-by-shot plan with timings, first and last frame,
  start and end frame. Use when the user has or wants a storyboard turned into
  video, or a clip that passes through specific frames at specific moments.
  For a story in several shots with recurring characters use series-episode;
  to lengthen an existing clip use continue-shot.
category: media
metadata:
  version: "2026-11-23"
---

# Storyboard to film

A short film from a storyboard: ordered keyframes with timings, approved as stills, then filmed through them.

**Not for:** an episode with recurring characters across shots and episodes (`series-episode`). This recipe is one continuous piece through set keyframes.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Story** (required): What happens, start to end, or the storyboard itself.
- **Length**: Total length in seconds.
- **Style**: The look, such as watercolour, cel-shaded animation or photoreal film.
- **Shape**: 16:9, 9:16 or 1:1.

## Steps

1. **Read the video models first** (`list_media_models` with `type` video): how many keyframes fit one clip depends on what they take (step 4), and a clip has a shortest length, so a piece cut into several clips cannot be shorter than that length times the number of clips.
2. **Storyboard.** Write a numbered table and wait for the user's OK on it before anything is generated: for each keyframe its time in seconds, what the frame shows, what happens until the next keyframe, and the camera. Pick a framing in which the subject stays readable in every keyframe: something that travels away from a locked camera ends up tiny.
3. **Fixed sentences.** Write one sentence per character and prop (face, build, clothes, colours) and one style line (look, palette as hex values, light). Paste them word for word into every still and clip prompt: that holds identity better than adjectives that drift.
4. **Keyframes as stills.** Make the first keyframe with `generate_image` and show it: it sets the look, so wait for the user's OK. Make each later keyframe by editing the one before it (a model with `image_edit` in `can`, the earlier frame as `image`, "same shot, same style, a moment later: ..."). For a move closer, say "the camera has moved in close" and do not ask to keep everything else the same. For a new angle, generate it with the first keyframe as `reference_images`. Show all keyframes together, in order, and wait for the user's OK before any clip is made.
5. **Choose how the frames become film,** from the video models' rows:
   - Two keyframes: a model whose `inputs` list `last_image`. The first is `image`, the last is `last_image`.
   - Three or more in one clip: a model whose `takes.parameters` list `middle_frames`. First and last as above, and the frames between as `parameters: {"middle_frames": ["<url>", ...]}` in storyboard order; in the prompt, call them @middle_1, @middle_2.
   - Otherwise, or for a piece longer than one clip: one clip per pair of neighbouring keyframes, each clip's `last_image` being the next clip's `image`. The joins then match in position, though not in speed.
6. **Write the clip prompt** as the Clip prompts rule says, with a timeline that follows the storyboard ("0 to 2 s: ...; at 2 s the frame matches the second keyframe") and the fixed sentences as what must stay the same. Models follow timings only roughly, so prefer the shortest length that fits the action.
7. **Draft, then final.** Draft at the lowest resolution, ask the user to check that each keyframe is reached at its time, and wait for their word. Then render the final.
8. **Deliver.** When the keyframes fit one clip, that clip is the film. A longer piece is the clips in order with the storyboard times, joined in the user's editor.

## Rules for every step

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `notes`. Start from a recommended model, the first where two look alike. Never assume an id, a length or a limit.
- **Draft first:** the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A final is a new take, not the draft made sharper.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip, always in this order: the starting state (do not describe a first frame again); what happens, in order, with seconds where timing matters; one camera move, or "locked off"; what must stay the same; the sound line. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words. A sound switch, if any, is in `takes.parameters`.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, at preview size, so fine detail is for the user to check. A picture the user links, a clip, or sound, no. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a short checklist: a cut in the middle, people or things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending. `transcribe_audio` checks spoken words.
- **Voices.** Ask whether the user knows the voice they want. If not, offer three clearly different ones (say warm storyteller, bright and energetic, calm and authoritative) on the same first line, and wait for the pick. `list_voices` filters by language only: match on each voice's name, gender and accent yourself, on a speech model whose voice names describe the voice. Where a language has too few, try another model or offer fewer.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` (its `duration`; `generate_speech` gives none, and an stt model that answers in whole seconds is too coarse, so use another), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, the text to add on screen, the handover to the next shot, and what to do with sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake.
