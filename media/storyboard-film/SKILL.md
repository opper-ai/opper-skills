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
6. **Write the clip prompt as a timed script:** the starting state; a timeline in seconds that follows the storyboard ("0 to 2 s: ...; at 2 s the frame matches the second keyframe"); one camera move; what must remain unchanged (the fixed sentences); "one continuous shot"; and the sound line. Models follow timings only roughly, so prefer the shortest length that fits the action.
7. **Draft, then final.** Draft at the lowest resolution, ask the user to check that each keyframe is reached at its time, and wait for their word. Then render the final.
8. **Deliver.** When the keyframes fit one clip, that clip is the film. A longer piece is the clips in order with the storyboard times, joined in the user's editor.

## Rules for every step

- **Models come from the list.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row before using it: `can` (what it does), `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`) and `notes` (what it refuses or always does). Start from a recommended model. Never assume a model id, a length or a limit.
- **Draft first.** Shortest length, lowest resolution, one or two stills, so the user sees the idea sooner. Raise quality once they like it.
- **Before a long or high-resolution video,** say in one line which model, length and resolution you are about to use, and wait for the user's go. A short draft needs no such stop.
- **Shape.** Pass `aspect_ratio` where the model lists `aspect_ratios`, or a `size` of that shape where it lists `sizes` (its `size_constraints` say which other sizes it takes). A clip made from an image takes the image's shape: make the still in the final shape and leave `aspect_ratio` out of the video call.
- **Show every result** by its `url` as soon as it lands. While a job is `processing`, say so and follow it with `get_media_job`. If a call times out with no answer, look in `list_media_jobs` before trying again: the job may have run. A link works until its `expires_at`.
- **You cannot watch a clip.** You see stills, not video or sound, so ask the user to check what matters in each clip and say what to look for.
- **The user's own files.** A public https link works everywhere. For a file on their device, call `create_upload_link`, do what its `next` says, and pass its `upload_id` where the file goes. Where a tool has a `_file` field (such as `image_file`), a chat attachment goes there instead.
- **No words in generated pictures.** Generators garble letters: titles, logos, captions and interface text are added in the user's editor.
- **Sound.** If the model makes sound (`audio` in `can`), name only the sounds the scene makes, in order ("Diegetic sound only: ..."), with no music or instrument words. For a silent clip, look in `takes.parameters` for the model's sound switch; `notes` say when sound cannot be turned off.
- **Joining.** These tools make stills, clips, voice and subtitle files. They do not join them. A piece of several parts ends as an ordered edit list for the user's video editor, so promise no finished film. An assistant that can run commands on the user's computer can assemble the file there.
- **People.** Anyone shown or voiced must have agreed to it. `notes` say which models refuse real people.
- **The user decides.** Where a step says to wait, stop until the user answers. A render that worked is not approval. Change one thing per retake.
