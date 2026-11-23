---
name: creator-ad
description: >
  Creator-style ad, UGC ad, testimonial, talking-head or presenter clip. Use
  when the user wants a person speaking to camera about a product, or any
  short clip of someone saying a written line. For a product ad with no
  presenter use product-ad; for a voice with no face use voiceover.
category: media
metadata:
  version: "2026-11-23"
---

# Creator-style ad

A vertical clip of a presenter talking to camera about a product, in a voice the user picks, with subtitles.

**Not for:** an ad with no one speaking (`product-ad`), or narration over pictures (`narrated-explainer`).

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): A product photo (a link or an upload), or a description of the product.
- **Line**: What the presenter says, or the point to make.
- **Presenter**: Who appears: an invented person by default; a real person only if they agreed.
- **Language**: The spoken language.
- **Length**: Length in seconds, usually 8 to 15.

## Steps

1. **Script.** One to three sentences said to camera, at about 2.5 words a second: the hook first, plain spoken words, and only claims the user can stand behind. Show it before making anything.
2. **Presenter still** with `generate_image`, in 9:16. By default the presenter is invented: write one fixed sentence for them (age, look, clothes) and the place, framed like a phone video in natural light, face clear and looking at the camera, holding or beside the product. With a product photo, use a model with `image_edit` in `can` and pass the photo as `reference_images` so the product stays exact. A real person appears only if they agreed; `notes` say which models refuse real people. The user approves the still.
3. **Voice.** Pick a speech model (`type` tts), call `list_voices` with the language, and render the first sentence with `generate_speech` in two or three voices so the user chooses by ear. Then render the whole script as one file: it drives the clip.
4. **Talking clip** with `generate_video`: speech first, then a model that follows it. Pick a video model whose `inputs` list `audio` and `image` (search "lip sync" or "avatar"; its `needs` names what it cannot work without). Pass the presenter still as `image` and the speech result's `audio.url` as `audio`. A lip-sync model takes no prompt; where a model takes one, ask only for small natural movement: a nod, a glance at the product. Draft at the lowest resolution first.
5. **Check the line.** Call `transcribe_audio` on the clip's `url` with an stt model and compare the words with the script. If they differ, fix the speech and make the clip again from it.
6. **Subtitles.** `transcribe_audio` with `format` srt on the final clip gives a subtitle file; correct its spellings from the script, and pass product names in `prompt`.
7. **Deliver** the clip and the subtitle file, and say what the editor adds: captions burned in, logo, call to action.
8. **Why speech first.** A video model that makes its own sound may also speak a line written in its prompt, but no row says whether it will. Speech first is the route that holds.

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
