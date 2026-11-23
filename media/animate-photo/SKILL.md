---
name: animate-photo
description: >
  Bring a still photo to life as a short clip, keeping the picture as it is.
  Use it when the user wants a photo or image to move: animate it, bring it to
  life, make it a video or a living photo. Made in chat with the Opper Media
  tools: a draft first, and the price before anything costly.
category: media
metadata:
  version: "2026-11-23"
---

# Animate my photo

Bring a still photo to life as a short clip, keeping the picture as it is.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Photo** (required): The photo: a link, an upload, or an image made earlier in the chat.
- **Motion**: What should move, such as hair in the wind, a slow zoom, or the person smiles and waves.

## Steps

1. **Look first.** Say in one line what the photo shows (ask, if you cannot see it) and agree the motion with the user; suggest one if they gave none. If real people are in it, check that they agreed to being animated.
2. **Pick a video model** whose `inputs` list `image`. Read its `notes` for what it refuses (some refuse real people) and its `takes` for lengths and resolutions.
3. **Prompt only the motion and the camera:** the photo is the first frame, passed as `image`. One continuous shot, with one camera move or "locked off, the camera does not move". Write motion as physics: wind-up, movement, settle; hair and cloth lag a moment behind. Say what stays: the same people, faces, clothes and art style, and no new people.
4. **For an exact ending** (eyes closed, turned to camera), make the last frame first: edit the photo with `generate_image` on a model with `image_edit` in `can` (the photo as `image`, "same photo, a moment later: ..."), get it approved, and pass it as `last_image` to a video model whose `inputs` list `last_image`.
5. **Price it and draft** at the shortest length and lowest resolution. The first one to two and a half seconds are usually the best part, so keep clips short; a longer piece is several short clips.
6. **Final.** Once the user likes the draft, render it at a higher resolution and give the link and its cost.

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
