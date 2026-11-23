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
- **Screens**: For a walkthrough: the user's own screenshots in order, and what happens on each.

## Steps

1. **Script first.** Write it to length at about 2.5 spoken words a second: warm, full sentences, one line per shot, and only claims the user can stand behind (mark anything you are unsure of). Show it as a shot table (line, what is on screen, still or moving) before anything is generated.
2. **Voice before pictures.** Pick a speech model (`type` tts) and get its voices with `list_voices`. Render the first line with `generate_speech` in two or three voices so the user chooses by ear, then make one audio file per line, so one line can be redone on its own. The voice sets the timing the pictures are cut to.
3. **Look.** Make one hero still with `generate_image` in the chosen style and show it. Then pass it as `reference_images` (on a model with `image_edit` in `can`) to every other still, so palette and characters hold. A stylised look (flat vector, line art, paper cut) hides model artefacts better than generic realism. Show the stills together and fix single ones by editing, not regenerating.
4. **Motion only where it helps.** Held stills or slow pans carry most shots. Use generated clips (`generate_video`, the approved still as `image`) only where real motion matters, and draft one clip first.
5. **Walkthrough lane: the user's own screenshots.** The screenshots are the pictures, unchanged. Never pass a screenshot through an image or video model to improve, restyle or animate it: models redraw interface text and get it wrong. They go straight into the user's editor and need not reach these tools at all. Write one line per screen, using the interface's own labels exactly as they appear, and note where the editor should zoom or highlight. Generated media is only for the opening and closing pictures and the voice. To show the product in a scene, such as a laptop on a desk, generate the scene with a blank screen and let the editor place the real screenshot on it.
6. **Deliver an edit list:** per shot, its line, its audio link, its still, clip or screenshot, and roughly how long it runs (its line's length plus half a second). Say how to cut it: lay the voice down first, cut pictures to the lines, keep any music low under the voice. These tools do not join the parts, so say that the list is what the user gets.
7. **Subtitles.** The script is the text. Once the user has cut the film, `transcribe_audio` with an stt model and `format` srt on the finished file gives the timings; correct its spellings from the script.

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
