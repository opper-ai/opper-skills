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

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `notes`. Start from a recommended model, the first where two look alike. Never assume an id, a length or a limit.
- **Draft first:** the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A final is a new take, not the draft made sharper.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip, always in this order: the starting state (do not describe a first frame again); what happens, second by second; one camera move, or "locked off"; what must stay the same; the sound line. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words. A sound switch, if any, is in `takes.parameters`.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, yes. A picture the user links, a clip, or sound, no. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a short checklist: a cut in the middle, people or things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending. `transcribe_audio` checks spoken words.
- **Voices.** Ask whether the user knows the voice they want. If not, offer three clearly different ones (say warm storyteller, bright and energetic, calm and authoritative) on the same first line, and wait for the pick. `list_voices` filters by language only: match on each voice's name, gender and accent yourself, on a speech model whose voice names describe the voice. Where a language has too few, try another model or offer fewer.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` (its `duration`; `generate_speech` gives none), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, the text to add on screen, the handover to the next shot, and what to do with sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake.
