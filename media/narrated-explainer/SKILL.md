---
name: narrated-explainer
description: >
  Explainer, tutorial, how-it-works video, narrated story, presentation video,
  product walkthrough, demo or feature tour. Use when the user wants narration
  over pictures, including a walkthrough built on their own screenshots. For a
  presenter speaking on camera use creator-ad; for a story with recurring
  characters use series-episode.
category: media
metadata:
  version: "2026-11-23"
---

# Narrated explainer

A narrated explainer or product walkthrough: script, voice, matching pictures and an edit list.

**Not for:** a talking presenter (`creator-ad`), or voice alone (`voiceover`).

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Topic** (required): What to explain and for whom, or the product to walk through.
- **Length**: Target length, such as 30 seconds (the default) or 60 seconds.
- **Style**: The look, such as flat vector, paper cut, line art or photoreal.
- **Language**: The language of the narration.
- **Pictures**: Stills only, a mix of stills and clips (the default), or clips throughout.
- **Screens**: For a walkthrough: the user's own screenshots in order, and what happens on each.

## Steps

1. **Script first.** Write it to length, leaving half a second a shot: warm, full sentences, one line per shot, and only claims the user can stand behind (mark anything you are unsure of). Show it as a shot table: line, what is on screen, still or moving. Say which way the pictures go: stills only (quickest to make and to change), a mix (the default: held stills or slow pans carry most lines, with a clip where motion explains something), or clips throughout (slowest, and every clip is a place where the look can drift). Ask for the OK on the script and about the voice in one message, and wait.
2. **Voice before pictures.** Pick a speech model (`type` tts), get its voices with `list_voices`, and choose the voice as the Voices rule says. Then make one audio file per line, so one line can be redone on its own, and measure each: the real line lengths set how long each picture holds.
3. **Look.** Make one hero still with `generate_image` in the chosen style and wait for the user's OK on the look. Then pass it as `reference_images` (on a model with `image_edit` in `can`) to every other still, so palette and characters hold. A still that builds on the one before it (a diagram gaining a part) is an edit of that one: the earlier still as `image`. A stylised look (flat vector, line art, paper cut) hides model artefacts better than generic realism. Check that each picture says what its line says, show the stills together and wait for the user's OK; fix single ones by editing, not regenerating.
4. **Clips, where the table says moving:** `generate_video` with the approved still as `image`, and for a diagram that must end in a set state, that state as `last_image` (a still made by editing the first). A clip runs as long as its line. Draft one clip before the rest. The clips sit under the voice, so the editor mutes their own sound.
5. **Walkthrough lane: the user's own screenshots.** The screenshots are the pictures, unchanged. Never pass a screenshot through an image or video model to improve, restyle or animate it: models redraw interface text and get it wrong. They go straight into the user's editor and need not reach these tools at all. Write one line per screen, using the interface's own labels exactly as they appear, and note where the editor should zoom or highlight. Generated media is only for the opening and closing pictures and the voice. To show the product in a scene, such as a laptop on a desk, generate the scene with a blank screen and let the editor place the real screenshot on it.
6. **Deliver the edit list** (rules: Joining), with each shot's line and audio link, and how long it holds (its line's measured length plus half a second). Say how to cut it: lay the voice down first, cut pictures to the lines, keep any music low under the voice. These tools do not join the parts, so say that the list is what the user gets.
7. **Subtitles.** The script is the text and the edit list has each line's start, so give the subtitles with those times in the chat. For exact timings, `transcribe_audio` with `format` srt on the user's finished file (an stt model whose `takes.formats` list mp4; if the answer is plain text with a note, the kind of model the note names).

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
