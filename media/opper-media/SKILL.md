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

1. **Check the connection** when something fails: `list_media_models` answers without making anything, and `list_media_jobs` shows what the user made before.
2. **A bigger piece has a recipe.** If the whole request matches a row, follow that recipe instead of improvising. One action that only resembles a row (a clip from a picture you just made) stays here:

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
3. **A single request:** pick the tool and go, with one short question only if something essential is missing. For a request of several results, say the plan in one message first and wait for the user's go.

   | The user wants | Call | Pass |
   |---|---|---|
   | A new image | `generate_image` | `prompt`, and `aspect_ratio` or `size` |
   | A change to an image, or the same scene in other light or weather | `generate_image` on a model with `image_edit` in `can` | the image as `image`; "same image; the only change: ..." |
   | An image of this product, person or style | `generate_image` on a model with `image_edit` in `can` | their picture as `reference_images`; say what must stay exact |
   | A clip from words | `generate_video` | `prompt`, `seconds`, `resolution`, `aspect_ratio` |
   | A clip from an image | `generate_video` on a model whose `inputs` list `image` | the image as `image`; the prompt as the rules' Clip prompts |
   | Words spoken aloud | `list_voices`, then `generate_speech` | `input`, a `voice` id |
   | What a recording says, or subtitles | `transcribe_audio` with an stt model (one whose `takes.formats` list mp4, for a video) | `audio`; `format` srt or vtt for subtitles |
   | Something made earlier | `list_media_jobs` | |
4. **No recipe fits? The general method.** The rules below cover choosing a model, drafting, clip prompts and the user's own files. Beyond them:
   - Plan in words first, then stills, then clips: stills are quick to change, clips are not.
   - An image prompt names subject, setting, light and camera, with colours as hex values. Speech is full sentences, with punctuation as the direction.
   - Write one fixed sentence for each subject and one for the style, and paste them word for word into every prompt.
   - For a likeness (a product, a person, a place), pass a picture as a reference before reaching for more words, and make each later picture from an earlier one so the look holds.
   - When a job fails, read the error: it names what the model would not take. Change that, or pick another model. Never send the same call again unchanged.
5. **A cover, thumbnail, poster or banner.** Where it goes sets the shape (9:16 reel cover, 16:9 thumbnail, 1:1 post). One clear subject, strong contrast, simple shapes that read when small, and empty space where the title will sit. Make two or three versions, let the user pick, and fix details by editing the chosen one.
6. **Offer the next step** once the result is shown: animate the image, add a voice, or turn it into one of the recipes above.

## Rules for every step

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `notes`. Start from a recommended model, the first where two look alike. Never assume an id, a length or a limit.
- **Draft first:** the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A final is a new take, not the draft made sharper.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip, always in this order: the starting state (do not describe a first frame again); what happens, second by second; one camera move, or "locked off"; what must stay the same; the sound line. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words. A sound switch, if any, is in `takes.parameters`.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, yes. A picture the user links, a clip, or sound, no. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a short checklist: a cut in the middle, people or things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending. `transcribe_audio` checks spoken words.
- **Voices.** Ask whether the user knows the voice they want. If not, offer three clearly different ones (say warm storyteller, bright and energetic, calm and authoritative) on the same first line, and wait for the pick. `list_voices` filters by language only: match on each voice's name, gender and accent yourself, on a speech model whose voice names describe the voice. Where a language has too few, try another model or offer fewer.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` (its `duration`; `generate_speech` gives none), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, the text to add on screen, the handover to the next shot, and what to do with sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake.
