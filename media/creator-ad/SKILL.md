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

1. **Script.** One to three sentences said to camera, at about 2.5 words a second: the hook first, plain spoken words, and only claims the user can stand behind. Wait for the user's OK on it before making anything.
2. **Presenter still** with `generate_image`, in 9:16. By default the presenter is invented: write one fixed sentence for them (age, look, clothes) and the place, framed like a phone video in natural light, face clear and looking at the camera, holding or beside the product. With a product photo, use a model with `image_edit` in `can` and pass the photo as `reference_images` so the product stays exact. A real person appears only if they agreed; `notes` say which models refuse real people. Wait for the user to approve the still.
3. **Voice.** Pick a speech model (`type` tts), call `list_voices` with the language, and render the first sentence with `generate_speech` in two or three voices, and wait for the user to choose by ear. Then render the whole script as one file: it drives the clip. `generate_speech` does not say how long the speech is, and a voice may read faster or slower than the script assumed: `transcribe_audio` on the speech reports its `duration`. If it misses the length asked for, change the words and render again.
4. **Talking clip** with `generate_video`: speech first, then a model that follows it. A video model that makes its own sound may also speak a line written in its prompt, but no row says whether it will, so this is the route that holds. Pick a video model whose `inputs` list both `audio` and `image`: a recommended one if there is one, otherwise search "avatar" or "lip sync" (a model with `lip_sync` in `can` is made for this, and its `needs` names what it cannot work without). Pass the presenter still as `image` and the speech result's `audio.url` as `audio`. Where the model takes a length, set `seconds` to the speech's length, rounded up. Where it takes a prompt, ask only for small natural movement: a nod, a glance at the product. Draft at the lowest resolution first, and ask the user to check that the mouth follows the words to the end.
5. **Check the line.** Call `transcribe_audio` on the clip's `url` and compare the words with the script. Use an stt model whose `takes.formats` list mp4: not every one reads a video. If the words differ, fix the speech and make the clip again from it.
6. **Subtitles.** `transcribe_audio` with `format` srt on the final clip gives a subtitle file. Not every stt model gives timings: if the answer comes back as plain text with a note, use the kind of model the note names. Where the model takes a `prompt`, pass product names in it. The words are the script's, so if the file misspells one, give the corrected subtitle text in the chat; the timings can be rough, so tell the user to nudge them in their editor.
7. **Deliver** the clip and the subtitle file, and say what the editor adds: captions burned in, logo, call to action.

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
