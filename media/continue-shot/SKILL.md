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

- **Models come from the list.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row before using it: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`) and `notes` (what it refuses or always does). Start from a recommended model; never assume an id, a length or a limit.
- **Draft first:** shortest length, lowest resolution, one or two stills. Before a long or high-resolution video, say in one line which model, length and resolution you will use, and wait for the user's go.
- **Shape.** Pass `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (its `size_constraints` say which sizes it takes). A clip made from an image takes the image's shape, so leave `aspect_ratio` out of that call.
- **Clip prompts.** One continuous shot per clip, written the same way every time: the starting state; what happens, second by second; one camera move, or "locked off"; what must stay the same; the sound line. For several clips, show all the prompts once before making the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds the scene makes, in order ("Diegetic sound only: ..."), with no music words. A sound switch, if the model has one, is in `takes.parameters`.
- **Results.** Show each by its `url` as it lands; a link works until its `expires_at`. While a job is `processing`, say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **You cannot watch a clip.** Give the user a short checklist with each one: a cut in the middle, people or things nobody asked for, a product or prop that changes, and what the shot was for. `transcribe_audio` on a clip checks its spoken words.
- **Voices.** Ask whether the user knows the voice they want. If not, offer three clearly different ones (say warm storyteller, bright and energetic, calm and authoritative), matched by you on each voice's name, gender and accent, since `list_voices` filters by language only. Render the same first line in each and wait for the pick. Make the voice before the pictures and time the shots to it: `transcribe_audio` on a take reports its `duration`, which `generate_speech` does not.
- **The user's own files.** A public https link works. For a file on their device, call `create_upload_link`, do what its `next` says and pass its `upload_id`; where a tool has a `_file` field, a chat attachment goes there.
- **No words in generated pictures:** titles, logos, captions and interface text are added in the user's editor.
- **Joining.** These tools do not join clips. A piece of several parts ends as an edit list for the user's video editor: per shot its link, the seconds to keep, the on-screen text to add, and how it hands over to the next shot. Promise no finished film.
- **People.** Anyone shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made earlier in this work. `notes` say which models refuse real people.
- **The user decides.** Where a step says to wait, stop until they answer; a render that worked is not approval. Change one thing per retake.
