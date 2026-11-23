---
name: product-walkthrough
description: >
  A narrated walkthrough of an app or site built on the user's real
  screenshots: script, voice, opening and closing pictures, and an edit list.
  Use it when the user wants a product demo, walkthrough, tutorial or feature
  tour made from screenshots or screen recordings of their app, site or tool.
  Made in chat with the Opper Media tools: a draft first, and the price before
  anything costly.
category: media
metadata:
  version: "2026-11-23"
---

# Product walkthrough from screenshots

A narrated walkthrough of an app or site built on the user's real screenshots: script, voice, opening and closing pictures, and an edit list.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): What the product is and who the walkthrough is for.
- **Screens** (required): The screens in order, and what the user does on each.
- **Length**: Target length in seconds.
- **Voice**: Tone, accent or language of the narration.

## Steps

1. **The screenshots are the film's pictures, unchanged.** Never pass a screenshot through an image or video model to improve, restyle or animate it: models redraw interface text and get it wrong. The screenshots go straight into the user's editor and need not reach these tools at all. Generated media is for what is not interface: the opening and closing pictures and the voice.
2. **Walk the screens.** Get them in order and note for each what it shows and the one action on it (look, if they are in the chat; otherwise ask). Use the interface's own labels exactly as they appear, and describe nothing the screens do not show.
3. **Script,** approved before anything is generated: one line per screen at about 2.5 spoken words a second, saying what the user does and what they get. Show a table: screen, line, seconds on screen, and where the editor should zoom or highlight.
4. **Voice.** Pick a speech model (`type` tts), call `list_voices` with the language, and render the first line with `generate_speech` in two or three voices so the user chooses by ear. State the price of the whole script, then make one audio file per line.
5. **Opening and closing,** if wanted: a background still from `generate_image` in the brand's colours (as hex values) with empty space for the product name, which the editor adds. It can be animated into a few seconds of `generate_video` (price first, draft first). For the product shown in a scene, such as a laptop on a desk, generate the scene with a blank screen and let the editor place the real screenshot on it.
6. **Deliver an edit list:** per screen, which screenshot, how long to hold it (its line's length plus half a second), its voice link and the zoom or highlight; then the opening and closing links, every cost and the total.
7. **Subtitles.** The script is the text. Once the user has cut the video, `transcribe_audio` with an stt model and `format` srt on the finished file gives the timings; pass product names in `prompt` so they are spelled right.

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
