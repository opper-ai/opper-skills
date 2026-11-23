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

A clip of a presenter talking to camera about a product, in a voice the user picks, with subtitles.

**Not for:** an ad with no one speaking (`product-ad`), or narration over pictures (`narrated-explainer`).

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): A product photo (a link or an upload), or a description of the product.
- **Line**: What the presenter says, or the point to make.
- **Presenter**: Who appears: an invented person by default; a real person only if they agreed.
- **Language**: The spoken language.
- **Length**: Length in seconds, usually 8 to 15.
- **Shape**: Vertical (9:16) by default; take it from where the clip will run.

## Steps

1. **Script.** One to three sentences said to camera, at about 2.5 words a second: the hook first, plain spoken words, and only claims the user can stand behind. Wait for the user's OK on it before making anything.
2. **Presenter still** with `generate_image`, in the clip's shape: vertical unless the user or the place it runs says otherwise. By default the presenter is invented: write one fixed sentence for them (age, look, clothes) and the place, framed like a phone video in natural light, face clear and looking at the camera, holding or beside the product. With a product photo, use a model with `image_edit` in `can` and pass the photo as `reference_images` so the product stays exact. A real person appears only if they agreed; `notes` say which models refuse real people. Wait for the user to approve the still.
3. **Voice.** Pick a speech model (`type` tts), call `list_voices` with the language, and choose the voice as the Voices rule says, on the first sentence. Then render the whole script as one file: it drives the clip. Measure it (rules: Voices): a voice may read faster or slower than the script assumed. If it misses the length asked for, change the words and render again.
4. **Talking clip** with `generate_video`: speech first, then a model that follows it. A video model that makes its own sound may also speak a line written in its prompt, but no row says whether it will, so this is the route that holds. Pick a video model whose `inputs` list both `audio` and `image`: a recommended one if there is one, otherwise search "avatar" or "lip sync" (a model with `lip_sync` in `can` is made for this, and its `needs` names what it cannot work without). Pass the presenter still as `image` and the speech result's `audio.url` as `audio`. Where the model takes a length, set `seconds` to the speech's length, rounded up. Where it takes a prompt, ask only for small natural movement: a nod, a glance at the product. Draft at the lowest resolution first, and ask the user to check that the mouth follows the words to the end.
5. **Check the line.** Call `transcribe_audio` on the clip's `url` and compare the words with the script. Use an stt model whose `takes.formats` list mp4: not every one reads a video. If the words differ, fix the speech and make the clip again from it.
6. **Subtitles.** `transcribe_audio` with `format` srt on the final clip gives a subtitle file. Not every stt model gives timings: if the answer comes back as plain text with a note, use the kind of model the note names. Where the model takes a `prompt`, pass product names in it. The words are the script's, so if the file misspells one, give the corrected subtitle text in the chat; the timings can be rough, so tell the user to nudge them in their editor.
7. **Deliver** the clip and the subtitle file, and say what the editor adds: captions burned in, logo, call to action.

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
