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
4. **Prompts that work.** An image: subject, setting, light and camera, with colours as hex values or as light. A clip: one shot, only what the camera sees, one camera move. Speech: full sentences, with punctuation as the direction.
5. **A cover, thumbnail, poster or banner.** Where it goes sets the shape (9:16 reel cover, 16:9 thumbnail, 1:1 post). Compose for the job: one clear subject the eye lands on first, strong contrast, simple shapes that read when small, and clean empty space where the title will sit (say where). Make two or three versions, let the user pick, and fix details by passing the chosen one as `image` instead of generating a new one.
6. **Offer the next step** once the result is shown: animate the image, add a voice, or turn it into one of the recipes above.

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
