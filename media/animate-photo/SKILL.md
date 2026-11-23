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

1. **Look first.** Say in one line what the photo shows (ask, if you cannot see it) and agree the motion with the user; suggest one if they gave none. If real people are in it, check that they agreed to being animated.
2. **Pick a video model** whose `inputs` list `image`. Read its `notes` for what it refuses (some refuse real people) and its `takes` for lengths and resolutions.
3. **Prompt only the motion and the camera:** the photo is the first frame, passed as `image`. One continuous shot, with one camera move or "locked off, the camera does not move". Write motion as physics: wind-up, movement, settle; hair and cloth lag a moment behind. Say what stays: the same people, faces, clothes and art style, and no new people.
4. **Lock the ending when it matters** (eyes closed, turned to camera, a door open). A clip held between a first and a last frame stays on model far better than one left to wander. Make the last frame by editing the photo with `generate_image` on a model with `image_edit` in `can` (the photo as `image`, "same photo, a moment later: ..."), show it, and pass it as `last_image` to a video model whose `inputs` list `last_image`.
5. **Draft** at the shortest length and lowest resolution. The first one to two and a half seconds are usually the best part, so keep clips short; a longer piece is several short clips.
6. **Final.** Once the user likes the draft, render it at a higher resolution and give the link.

## Rules for every step

- **Models come from the list.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row before using it: `can` (what it does), `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`) and `notes` (what it refuses or always does). Start from a recommended model. Never assume a model id, a length or a limit.
- **Draft first.** Shortest length, lowest resolution, one or two stills, so the user sees the idea sooner. Raise quality once they like it.
- **Before a long or high-resolution video,** say in one line which model, length and resolution you are about to use, then go.
- **Shape.** Pass `aspect_ratio` where the model lists `aspect_ratios`, or a `size` of that shape where it lists `sizes`. A clip made from an image takes the image's shape: make the still in the final shape and leave `aspect_ratio` out of the video call.
- **Show every result** by its `url` as soon as it lands. While a job is `processing`, say so and follow it with `get_media_job`. If a call times out with no answer, look in `list_media_jobs` before trying again: the job may have run. A link works until its `expires_at`.
- **You cannot watch a clip.** You see stills, not video or sound, so ask the user to check what matters in each clip and say what to look for.
- **The user's own files.** A public https link works everywhere. For a file on their device, call `create_upload_link`, do what its `next` says, and pass its `upload_id` where the file goes. Where a tool has a `_file` field (such as `image_file`), a chat attachment goes there instead.
- **No words in generated pictures.** Generators garble letters: titles, logos, captions and interface text are added in the user's editor.
- **Sound.** If the model makes sound (`audio` in `can`), name only the sounds the scene makes, in order ("Diegetic sound only: ..."), with no music or instrument words. For a silent clip, look in `takes.parameters` for the model's sound switch; `notes` say when sound cannot be turned off.
- **Joining.** These tools make stills, clips, voice and subtitle files. They do not join them. A piece of several parts ends as an ordered edit list for the user's video editor, so promise no finished film. An assistant that can run commands on the user's computer can assemble the file there.
- **People.** Anyone shown or voiced must have agreed to it. `notes` say which models refuse real people.
- **One change per retake.**
