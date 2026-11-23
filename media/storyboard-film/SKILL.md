---
name: storyboard-film
description: >
  A short film from a storyboard: ordered keyframes with timings, approved as
  stills, then filmed through them. Use it when the user has, or wants, a
  storyboard, keyframes or a shot-by-shot plan with timings and wants it
  turned into video, or wants a clip that passes through specific frames at
  specific moments. Made in chat with the Opper Media tools: a draft first,
  and the price before anything costly.
category: media
metadata:
  version: "2026-11-23"
---

# Storyboard to film

A short film from a storyboard: ordered keyframes with timings, approved as stills, then filmed through them.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Story** (required): What happens, start to end, or the storyboard itself.
- **Length**: Total length in seconds.
- **Style**: The look, such as watercolour, cel-shaded animation or photoreal film.
- **Shape**: 16:9, 9:16 or 1:1.

## Steps

1. **Storyboard.** Write a numbered table and get it approved before anything is generated: for each keyframe its time in seconds, what the frame shows, what happens until the next keyframe, and the camera. Three to six keyframes make one clip; keep the total within a length video models take.
2. **Fixed sentences.** Write one sentence per character and prop (face, build, clothes, colours) and one style line (look, palette as hex values, light). Paste them word for word into every still and clip prompt: that holds identity better than adjectives that drift.
3. **Keyframes as stills.** Make the first keyframe with `generate_image` and get it approved: it sets the look. Make each later keyframe by editing the one before it (a model with `image_edit` in `can`, the earlier frame as `image`, "same shot, same style, a moment later: ..."). For a move closer, say "the camera has moved in close" and do not ask to keep everything else the same. For a new angle, generate it with the first keyframe as `reference_images`. Show all keyframes together, in order, and wait for approval.
4. **Choose how the frames become film,** from the video models' rows:
   - Two keyframes: a model whose `inputs` list `last_image`. The first is `image`, the last is `last_image`.
   - Three or more in one clip: a model whose `takes.parameters` list `middle_frames`. First and last as above, and the frames between as `parameters: {"middle_frames": ["<url>", ...]}` in storyboard order; in the prompt, call them @middle_1, @middle_2.
   - Otherwise, or for a piece longer than one clip: one clip per pair of neighbouring keyframes, each clip's `last_image` being the next clip's `image`. The joins then match in position, though not in speed.
5. **Write the clip prompt as a timed script:** the starting state; a timeline in seconds that follows the storyboard ("0 to 2 s: ...; at 2 s the frame matches the second keyframe"); one camera move; what must remain unchanged (the fixed sentences); "one continuous shot"; and the sound line. Models follow timings only roughly, so prefer the shortest length that fits the action.
6. **Price, draft, final.** State the price of every clip and the total, and wait for a yes. Draft at the lowest resolution, check each keyframe is reached, then render the final.
7. **Deliver** the clip links in order with the storyboard times and each cost.

## Rules for every step

- **Models come from the list.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row before using it: `can` (what it does), `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `notes` (what it refuses or always does) and `price_from`. Start from a recommended model. Never assume a model id, a length or a limit.
- **Price before any video.** Tell the user the model, length, resolution and estimated price, and wait for a yes. `price_from` is the lowest rate, at the setting it names; higher resolutions and sound cost more. Do the same before a batch of stills or voice lines.
- **Draft first.** Shortest length, lowest resolution, one or two stills. Raise quality only once the user likes the draft.
- **Show every result** by its `url` with its `usage.cost`, and keep a running total. While a job is `processing`, say so and follow it with `get_media_job`. A link works until its `expires_at`.
- **The user's own files.** A public https link works everywhere. For a file on their device, call `create_upload_link`, do what its `next` says, and pass its `upload_id` where the file goes. Where a tool has a `_file` field (such as `image_file`), a chat attachment goes there instead.
- **No words in generated pictures.** Generators garble letters: titles, logos, captions and interface text are added in the user's editor.
- **Sound.** If the model makes sound (`audio` in `can`), name only the sounds the scene makes, in order ("Diegetic sound only: ..."), with no music or instrument words. For a silent clip, look in `takes.parameters` for the model's sound switch; `notes` say when sound cannot be turned off.
- **Joining.** These tools make stills, clips, voice and subtitle files. They do not join them: for now a piece of several parts ends as an ordered list that the user puts together in their video editor.
- **People.** Anyone shown or voiced must have agreed to it. `notes` say which models refuse real people.
- **One change per retake,** and the user chooses at each step.
