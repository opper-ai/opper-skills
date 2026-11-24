---
name: voiceover
description: >
  Voiceover, narration, voice track, read this aloud, radio ad, podcast intro.
  Use when the user wants spoken audio from a script, or narration timed to a
  clip. For a presenter who speaks on camera use creator-ad; for narration
  with pictures use narrated-explainer.
category: media
metadata:
  version: "2026-11-23"
---

# Voiceover

Narration that fits a clip or a script: a voice chosen by ear, and one audio file per line.

**Not for:** a talking person on screen (`creator-ad`), or a whole explainer with pictures (`narrated-explainer`).

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Script** (required): The script to read, what the piece should say, or what the clip shows (or a link to it).
- **Length**: Length in seconds.
- **Voice**: Tone, accent or language, such as warm British male or upbeat Spanish.

## Steps

1. **Script.** Keep the user's words if they gave a script. Otherwise write one to length: warm, full sentences, punctuation as the direction, numbers written as they are said. Ask for the names and facts it needs, or mark them as placeholders. Split it into lines, each landing on a moment in the clip if there is one, with start times. Ask for the OK on the script and about the voice in one message, and wait. If the clip already has speech to replace or translate, `transcribe_audio` (an stt model, `format` segments) gives its words with their times.
2. **Voice.** Pick a speech model (`type` tts) and call `list_voices` with the language; if it has no voice that fits, try another model. Then choose the voice as the Voices rule says: ask whether the user knows the one they want, or offer three different ones on the real first line, and wait for the pick.
3. **Render one file per line** with `generate_speech` and the chosen voice, so one line can be redone on its own; the audition take of the first line can stay. Use a format from the model's `takes.formats` (mp3 where it is listed, unless the user's editor wants another). Measure each line (rules: Voice first). If the piece runs long, move the start times first, then shorten words; if it runs short, add words; change `speed` only a little, as a last resort.
4. **A piece that is sound only** (a radio ad, a podcast intro) also gets the whole script as one file: that is the finished piece, and its measured length is the one that must fit. Render it first. These tools make no music: say so if the piece wants some.
5. **Deliver** the links in order with each line's start time, and say how to place them: on the clip's timeline at those times, with any music lowered under the voice.

## Rules for every step

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `quality`, `notes`. Start from a recommended model, the first where two look alike. Never assume an id, a length or a limit.
- **Draft first,** unless the recipe says otherwise: the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A draft shows the idea, not the finish, and a final is a new take, not the draft made sharper: say both.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip unless the recipe puts several in one, always in this order: the starting state (do not describe a first frame again); what happens, in order, with seconds where timing matters; one camera move, or "locked off"; what must stay the same; the sound line. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words unless the recipe or the user asks for music. A sound switch, if any, is in `takes.parameters`: turn it on.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, at preview size, so fine detail is for the user to check. A picture the user links, a clip, or sound, no. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a short checklist: a cut in the middle, people or things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending. `transcribe_audio` checks spoken words.
- **Voices.** Ask whether the user knows the voice they want. If not, offer three clearly different ones (say warm storyteller, bright and energetic, calm and authoritative) on the same first line, and wait for the pick. `list_voices` filters by language only: match on each voice's name, gender and accent yourself, on a speech model whose voice names describe the voice. Where a language has too few, try another model or offer fewer.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` (its `duration`; `generate_speech` gives none, and an stt model that answers in whole seconds is too coarse, so use another), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, the text to add on screen, the handover to the next shot, and what to do with sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake. After a finished piece, offer in one line what more can be made from it.
