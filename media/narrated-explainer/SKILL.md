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

1. **Script first.** Write it to length at about 2.5 spoken words a second: warm, full sentences, one line per shot, and only claims the user can stand behind (mark anything you are unsure of). Show it as a shot table (line, what is on screen, still or moving) and wait for the user's OK before anything is generated.
2. **Voice before pictures.** Pick a speech model (`type` tts), get its voices with `list_voices`, and choose the voice as the Voices rule says. Then make one audio file per line, so one line can be redone on its own, and measure each: the real line lengths set how long each picture holds.
3. **Look.** Make one hero still with `generate_image` in the chosen style and wait for the user's OK on the look. Then pass it as `reference_images` (on a model with `image_edit` in `can`) to every other still, so palette and characters hold. A stylised look (flat vector, line art, paper cut) hides model artefacts better than generic realism. Show the stills together and wait for the user's OK; fix single ones by editing, not regenerating.
4. **Stills, a mix, or clips.** Ask which, or recommend one. The default is a mix: held stills or slow pans carry most lines, with a generated clip (`generate_video`, the approved still as `image`) where motion explains something. Stills only is the quickest to make and to change. Clips throughout takes longest, and every clip is a place where the look can drift. Draft one clip before the rest.
5. **Walkthrough lane: the user's own screenshots.** The screenshots are the pictures, unchanged. Never pass a screenshot through an image or video model to improve, restyle or animate it: models redraw interface text and get it wrong. They go straight into the user's editor and need not reach these tools at all. Write one line per screen, using the interface's own labels exactly as they appear, and note where the editor should zoom or highlight. Generated media is only for the opening and closing pictures and the voice. To show the product in a scene, such as a laptop on a desk, generate the scene with a blank screen and let the editor place the real screenshot on it.
6. **Deliver the edit list** (rules: Joining): per shot, its line, its audio link, its still, clip or screenshot, and how long it holds (its line's measured length plus half a second). Say how to cut it: lay the voice down first, cut pictures to the lines, keep any music low under the voice. These tools do not join the parts, so say that the list is what the user gets.
7. **Subtitles.** The script is the text. Once the user has cut the film, `transcribe_audio` with `format` srt on the finished file gives the timings. Use an stt model whose `takes.formats` list mp4, and if the answer comes back as plain text with a note, the kind of model the note names: not every one gives timings. Give corrected text in the chat where a name is misspelled.

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
