---
name: opper-media
description: >
  Images, video clips, speech and transcripts made in chat with the Opper
  Media tools: the place to start. Use when the user wants to make, edit or
  animate a picture, make a clip, a voice line, subtitles or a cover image, or
  mentions Opper Media without naming a recipe. A bigger piece goes to its own
  skill: product-ad, product-photos, creator-ad, animate-photo, narrated-
  explainer, series-episode, storyboard-film, continue-shot or voiceover.
category: media
metadata:
  version: "2026-11-23"
---

# Opper Media: start here

Single requests (one image, edit, clip, voice line, transcript or cover) and which recipe fits a bigger piece.

**Not for:** a piece that has its own recipe in the table below. Use that recipe.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Request** (required): What the user wants to make.

## Steps

1. **Check the connection** when it is new or something fails: `list_media_models` answers without making anything, and `list_media_jobs` shows what the user made before.
2. **A bigger piece has a recipe.** If the request matches a row, follow that recipe instead of improvising:

   | The user wants | Recipe |
   |---|---|
   | An ad or promo video for a product, one shot or several | `product-ad` |
   | Still photos of a product for a store, site or post | `product-photos` |
   | A person talking to camera about a product | `creator-ad` |
   | A photo brought to life | `animate-photo` |
   | An explainer, tutorial or product walkthrough with narration | `narrated-explainer` |
   | An episode or story with the same characters throughout | `series-episode` |
   | A film that follows a storyboard or set keyframes | `storyboard-film` |
   | A clip made longer | `continue-shot` |
   | Narration for a clip or a script read aloud | `voiceover` |
3. **A single request:** pick the tool and go, with one short question only if something essential is missing. Before a batch of several results, say what you are about to make and wait for the user's go.

   | The user wants | Call | Pass |
   |---|---|---|
   | A new image | `generate_image` | `prompt`, and `aspect_ratio` or `size` |
   | A change to an image | `generate_image` on a model with `image_edit` in `can` | the image as `image`; "same image; the only change: ..." |
   | An image of this product, person or style | `generate_image` on a model with `image_edit` in `can` | their picture as `reference_images`; say what must stay exact |
   | A clip from words | `generate_video` | `prompt`, `seconds`, `resolution`, `aspect_ratio` |
   | A clip from an image | `generate_video` on a model whose `inputs` list `image` | the image as `image`; prompt only the motion |
   | Words spoken aloud | `list_voices`, then `generate_speech` | `input`, a `voice` id |
   | What a recording says, or subtitles | `transcribe_audio` with an stt model (one whose `takes.formats` list mp4, for a video) | `audio`; `format` srt or vtt for subtitles |
   | Something made earlier | `list_media_jobs` | |
4. **Prompts that work.** An image: subject, setting, light and camera, with colours as hex values or as light. Speech: full sentences, with punctuation as the direction. A clip: the rules' Clip prompts.
5. **No recipe fits? The general method.** The rules below cover choosing a model, drafting, clip prompts and the user's own files. Beyond them:
   - Plan in words first, then stills, then clips: stills are quick to change, clips are not.
   - Write one fixed sentence for each subject and one for the style, and paste them word for word into every prompt.
   - For a likeness (a product, a person, a place), pass a picture as a reference before reaching for more words, and make each later picture from an earlier one so the look holds.
   - When a job fails, read the error: it names what the model would not take. Change that, or pick another model. Never send the same call again unchanged.
6. **A cover, thumbnail, poster or banner.** Where it goes sets the shape (9:16 reel cover, 16:9 thumbnail, 1:1 post). Compose for the job: one clear subject the eye lands on first, strong contrast, simple shapes that read when small, and clean empty space where the title will sit (say where). Make two or three versions, let the user pick, and fix details by passing the chosen one as `image` instead of generating a new one.
7. **Offer the next step** once the result is shown: animate the image, add a voice, or turn it into one of the recipes above.

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
