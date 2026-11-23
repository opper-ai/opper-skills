---
name: continue-shot
description: >
  Make a clip longer by extending it, so its motion carries over the join. Use
  it when the user wants to extend, lengthen or continue a video clip, or asks
  what happens next in a shot they already have. Made in chat with the Opper
  Media tools: a draft first, and the price before anything costly.
category: media
metadata:
  version: "2026-11-23"
---

# Continue a shot

Make a clip longer by extending it, so its motion carries over the join.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Clip** (required): The clip to continue: a link, an upload, or a clip made earlier in the chat.
- **Next** (required): What happens next in the shot.
- **Length**: How many seconds to add.

## Steps

1. **Know the clip.** Find out which model made it (`list_media_jobs` has the newest results) and how it ends: what is moving in the last second, how fast, and what the camera is doing. Ask the user if you cannot tell.
2. **Extend, do not restart.** A new clip started from the old one's last frame begins from a standstill: the position matches, but speed and camera move do not, and the join pops. Passing the clip itself lets the model carry the motion over.
3. **Pick a video model with `video_extension` in `can`** (its `inputs` list `video`). Prefer the model that made the clip when it has it: some continue only their own clips. Read its `notes` (some refuse uploaded clips or certain regions) and its `takes`: an extension can add a fixed number of seconds whatever `seconds` says. If its `takes.parameters` list `task`, send `parameters: {"task": "extend"}`, or the clip is treated as one to edit.
4. **Call `generate_video`** with the clip's url as `video`. Prompt only what happens next, starting from the motion already under way: the same camera move at the same speed, then the change. Say what stays: the same people, clothes, place, light and style.
5. **Price first.** The clip passed in may be charged as well as the seconds added: say so, give the estimate and wait for a yes.
6. **Check the join** when the result lands. It should start where the old clip ended and at the same speed. If the scene restarts or changes, the model used the clip as a loose reference: say so and try another model with `video_extension` rather than paying for retakes on the same one. Tell the user whether the result is the whole clip or only the new part (compare the lengths).
7. **If nothing can extend it,** offer the two fallbacks plainly: remake the whole action as one longer clip, or start a new clip from the old one's last frame (the user exports that frame from their editor) and hide the join under a cut to another angle or on a moment of stillness.

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
