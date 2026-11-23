---
name: narrated-explainer
description: >
  A short explainer video: script, voiceover, matching stills and a few
  animated shots, ready to edit together. Use it when the user wants an
  explainer, tutorial, story or presentation video with narration. Made in
  chat with the Opper Media tools: a draft first, and the price before
  anything costly.
category: media
metadata:
  version: "2026-11-23"
---

# Narrated explainer

A short explainer video: script, voiceover, matching stills and a few animated shots, ready to edit together.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Topic** (required): What to explain, and for whom.
- **Length**: Target length, such as 30 seconds (the default) or 60 seconds.
- **Style**: The look, such as flat vector, paper cut, line art or photoreal.

## Steps

1. **Script first.** Write it to length at about 2.5 spoken words a second: warm, full sentences, one line per shot, and only claims the user can stand behind (mark anything you are unsure of). Show it as a shot table (line, what is on screen, still or moving) and get approval before anything is generated.
2. **Voice.** Pick a speech model (`type` tts) and get its voices with `list_voices`. Render the first line with `generate_speech` in two or three voices so the user chooses by ear, then make one audio file per line, so a bad line is a cheap retake.
3. **Look.** Make one hero still with `generate_image` in the chosen style and get it approved. Then pass it as `reference_images` (on a model with `image_edit` in `can`) to every other still, so palette and characters hold. A stylised look (flat vector, line art, paper cut) hides model artefacts better than generic realism. Show the stills together and fix single ones by editing, not regenerating.
4. **Motion only where it helps.** Recommend held stills or slow pans for most shots, and generated clips (`generate_video`, the approved still as `image`) only where real motion matters. Total the clips' price, wait for a yes, and draft one clip first.
5. **Deliver an ordered list:** per shot, its line, its audio link, its still or clip link and roughly how long it runs. Say how to cut it: lay the voice down first, cut pictures to the lines, keep any music low under the voice.
6. **Subtitles.** The script is the text. Once the user has cut the film, `transcribe_audio` with an stt model and `format` srt on the finished file gives the timings; correct its spellings from the script.

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
