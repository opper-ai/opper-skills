---
name: continue-shot
description: >
  Extend a video, make a clip longer, continue the shot, what happens next.
  Use when the user has a clip and wants more of the same shot. To start from
  a still photo use animate-photo; for a new shot in a longer piece use
  storyboard-film.
category: media
metadata:
  version: "2026-11-23"
---

# Continue a shot

Make a clip longer by extending it, so its motion carries over the join.

**Not for:** animating a still (`animate-photo`), or a new shot from a new angle (`storyboard-film`).

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Clip** (required): The clip to continue: a link, an upload, or a clip made earlier in the chat.
- **Next** (required): What happens next in the shot.
- **Length**: How many seconds to add.

## Steps

1. **Know the clip.** For a clip made in this chat you have its job id and the model that made it. For any other clip, ask the user which model made it: the job list does not say. How it ends (what is moving in the last second, how fast, what the camera is doing) comes from your own prompt, or from the user. If you are making the first clip too, make it on a video model with `video_extension` in `can`, and end its prompt with the motion still under way, so that it can be continued.
2. **Extend, do not restart.** A new clip started from the old one's last frame begins from a standstill: the position matches, but speed and camera move do not, and the join pops. Continuing the clip itself lets the model carry the motion over.
3. **Agree what happens next.** Say back in a sentence or two how the shot will go on and for how long, and wait for the user's OK.
4. **First way, for a clip made in this chat:** call `generate_video` on the same model with a prompt, `seconds` set to the length to add, and `parameters: {"continue_from": "<the clip's job id>"}`. Send no `image` or `video`, and no shape or resolution: they carry over from the clip. Without `seconds` a model may add far more than a few seconds. `continue_from` is not a key a model's row lists: where the model can continue its own clip, the result is the whole clip, old part and new; where it cannot, the answer says so and nothing is made, and you go on to the second way.
5. **Second way, for any clip:** a video model with `video_extension` in `can` (its `inputs` list `video`), with the clip's url as `video`. Read its `notes` first (some refuse a clip they did not make, or refuse from certain regions) and its `takes`: an extension can add a fixed number of seconds whatever `seconds` says. If its `takes.parameters` list `task`, send `parameters: {"task": "extend"}`, or the clip is treated as one to edit. This way is the less dependable of the two, so say that before trying it.
6. **The prompt** says only what happens next, starting from the motion already under way: the same camera move at the same speed, then the change. Say what stays: the same people, clothes, place, light and style.
7. **Check the join.** Ask the user to play the old clip and then the new one: it should carry on from where the old one ended, at the same speed. If the new clip starts the scene again, the model used the old clip as a loose reference: say so, and try another way rather than the same model again. Ask too whether the result holds the whole clip or only the new part.
8. **If nothing can extend it,** offer the two fallbacks plainly: remake the whole action as one longer clip, or start a new clip from the old one's last frame (the user exports that frame from their editor) and hide the join under a cut to another angle or on a moment of stillness.

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
