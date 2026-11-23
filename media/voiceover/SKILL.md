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

- **Clip** (required): The script to read, or what the clip shows (or a link to it).
- **Length**: The clip's length in seconds.
- **Voice**: Tone, accent or language, such as warm British male or upbeat Spanish.

## Steps

1. **Script.** Keep the user's words if they gave a script. Otherwise write one at about 2.5 words a second with a beat of silence at each end: warm, full sentences, punctuation as the direction, numbers written as they are said. Split it into lines that each land on a moment in the clip, with start times, and wait for the user's OK on the script. If the clip already has speech to replace or translate, `transcribe_audio` (an stt model, `format` segments) gives its words with their times.
2. **Voice.** Pick a speech model (`type` tts) and call `list_voices` with the language; if it has no voice that fits, try another model. Shortlist two or three voices that fit the tone and render the same real first line in each. Wait for the user to choose by ear.
3. **Render one file per line** with `generate_speech` and the chosen voice, so one line can be redone on its own. Use a format from the model's `takes.formats` (mp3 where it is listed, unless the user's editor wants another). `generate_speech` does not say how long a line is: where a line must fit a slot, `transcribe_audio` on it reports its `duration`. If a line runs past its slot, shorten the words; change `speed` only a little, as a last resort.
4. **Deliver** the links in order with each line's start time, and say how to place them: on the clip's timeline at those times, with any music lowered under the voice.

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
