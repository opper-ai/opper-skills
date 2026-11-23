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
- **Shape**: Vertical (9:16) by default; take it from where the clip will run, and ask where that place takes both.

## Steps

1. **Script.** One to three sentences said to camera: the hook first, plain spoken words, and only claims the user can stand behind. Ask for the OK on it and about the voice in one message, and wait.
2. **Voice.** Pick a speech model (`type` tts), call `list_voices` with the language, and choose the voice as the Voices rule says, on the first sentence. Then render the whole script as one file: it drives the clip and sets its length. Measure it (rules: Voice first); if it misses the length asked for, change the words, render again and show the user the script as it now is.
3. **Presenter still** with `generate_image`, in the clip's shape: vertical unless the user or the place it runs says otherwise. By default the presenter is invented, and fits the voice: write one fixed sentence for them (age, look, clothes) and the place, framed like a phone video in natural light, face clear and looking at the camera, holding or beside the product. With a product photo, use a model with `image_edit` in `can` and pass the photo as `reference_images` so the product stays exact. A real person appears only if they agreed. Wait for the user to approve the still and to check the product in it.
4. **Talking clip** with `generate_video`: speech first, then a model that follows it. A video model that makes its own sound may also speak a line written in its prompt, but no row says whether it will, so this is the route that holds. Pick a video model whose `inputs` list both `audio` and `image`: a recommended one if there is one, otherwise search "avatar" or "lip sync" (a model with `lip_sync` in `can` is made for this, and its `needs` names what it cannot work without). Pass the still as `image` and the speech result's `audio.url` as `audio`. The clip is as long as the speech: where the model takes a length, set `seconds` to the speech's length, rounded up, and no longer. Where it takes a prompt, ask only for small natural movement (a nod, a glance at the product) and give the supplied speech as the only sound. Draft at the lowest resolution first, and ask the user to check that the mouth follows the words to the end.
5. **Check the line and make subtitles** in one call: `transcribe_audio` on the clip's `url` with `format` srt, on an stt model whose `takes.formats` list mp4. Not every one gives timings: if the answer comes back as plain text with a note, use the kind of model the note names. Compare the words with the script; if they differ, fix the speech and make the clip again. If a caption holds more than about seven words, or a word is misspelled, give a corrected, split version in the chat.
6. **Deliver** the clip and the subtitle file, and say what the editor adds: captions burned in, logo, call to action.

## Rules for every step

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `notes`. Start from a recommended model, the first where two look alike. Never assume an id, a length or a limit.
- **Draft first:** the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A final is a new take, not the draft made sharper.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip, always in this order: the starting state (do not describe a first frame again); what happens, in order, with seconds where timing matters; one camera move, or "locked off"; what must stay the same; the sound line. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words. A sound switch, if any, is in `takes.parameters`.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, at preview size, so fine detail is for the user to check. A picture the user links, a clip, or sound, no. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a short checklist: a cut in the middle, people or things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending. `transcribe_audio` checks spoken words.
- **Voices.** Ask whether the user knows the voice they want. If not, offer three clearly different ones (say warm storyteller, bright and energetic, calm and authoritative) on the same first line, and wait for the pick. `list_voices` filters by language only: match on each voice's name, gender and accent yourself, on a speech model whose voice names describe the voice. Where a language has too few, try another model or offer fewer.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` (its `duration`; `generate_speech` gives none, and an stt model that answers in whole seconds is too coarse, so use another), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, the text to add on screen, the handover to the next shot, and what to do with sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake.
