---
name: animate-photo
description: >
  Animate a photo, bring a picture to life, living photo, photo to video. Use
  when the user wants an image they have to move, with or without a set
  ending. To make a clip they already have longer use continue-shot; for a
  product ad use product-ad.
category: media
metadata:
  version: "2026-11-23"
---

# Animate my photo

Bring a still photo to life as a short clip, keeping the picture as it is.

**Not for:** extending a video (`continue-shot`), or a clip from words alone (`opper-media`).

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Photo** (required): The photo: a link, an upload, or an image made earlier in the chat.
- **Motion**: What should move, such as hair in the wind, a slow zoom, or the person smiles and waves.

## Steps

1. **Look first.** Say in one line what the photo shows (ask, if you cannot see it) and say the motion you will make; suggest one if they gave none. Wait for the user's OK on the motion. For real people, the People rule applies: ask once, not per photo. For a batch of photos, agree the motion once and run them all without a stop for each.
2. **Pick a video model** whose `inputs` list `image`. Read its `notes` for what it refuses (some refuse real people) and its `takes` for lengths and resolutions.
3. **Prompt only the motion and the camera:** the photo is the first frame, passed as `image`. One continuous shot, with one camera move or "locked off, the camera does not move". Write motion as physics: wind-up, movement, settle; hair and cloth lag a moment behind. Say what stays: the same people, faces, clothes and art style, and no new people.
4. **Lock the ending when it matters** (eyes closed, turned to camera, a door open). A clip held between a first and a last frame stays on model far better than one left to wander. Make the last frame by editing the photo with `generate_image` on a model with `image_edit` in `can` (the photo as `image`, "same photo, a moment later: ..."), show it and wait for the user's OK, then pass it as `last_image` to a video model whose `inputs` list `last_image`.
5. **Draft** at the shortest length and lowest resolution. The first one to two and a half seconds are usually the best part, so keep clips short; a longer piece is several short clips.
6. **Final.** Once the user likes the draft, render it at a higher resolution and give the link.

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
