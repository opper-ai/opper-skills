---
name: voiceover
description: >
  Narration that fits a clip's length: script, a voice audition, and one audio
  file per line. Use it when the user wants narration, a voiceover, a voice
  track or spoken audio for a video or clip. Made in chat with the Opper Media
  tools: a draft first, and the price before anything costly.
category: media
metadata:
  version: "2026-11-23"
---

# Voiceover for a clip

Narration that fits a clip's length: script, a voice audition, and one audio file per line.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Clip** (required): What the clip shows (or a link to it), or the script to read.
- **Length**: The clip's length in seconds.
- **Voice**: Tone, accent or language, such as warm British male or upbeat Spanish.

## Steps

1. **Script.** Keep the user's words if they gave a script. Otherwise write one at about 2.5 words a second with a beat of silence at each end: warm, full sentences, punctuation as the direction, numbers written as they are said. Split it into lines that each land on a moment in the clip, with start times, and get approval. If the clip already has speech to replace or translate, `transcribe_audio` (an stt model, `format` segments) gives its words with their times.
2. **Voice.** Pick a speech model (`type` tts) and call `list_voices` with the language; if it has no voice that fits, try another model. Shortlist two or three voices that fit the tone and render the same real first line in each, so the user chooses by ear.
3. **Price the whole script** on that model (its `price_from` against the script's length) before rendering the rest.
4. **Render one file per line** with `generate_speech` and the chosen voice, in a format from the model's `takes.formats` (mp3 where it is listed, unless the user's editor wants another). If a line runs past its slot, shorten the words; change `speed` only a little, as a last resort.
5. **Deliver** the links in order with each line's start time and cost, and say how to place them: on the clip's timeline at those times, with any music lowered under the voice.

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
