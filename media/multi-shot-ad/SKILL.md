---
name: multi-shot-ad
description: >
  A product ad of three to five shots: shot list, matching stills, one clip
  per shot, and an edit list. Use it when the user wants an ad, commercial,
  promo or brand film with several shots or scenes, or a longer ad than one
  clip can hold. For a single-clip ad, use product-ad. Made in chat with the
  Opper Media tools: a draft first, and the price before anything costly.
category: media
metadata:
  version: "2026-11-23"
---

# Multi-shot ad

A product ad of three to five shots: shot list, matching stills, one clip per shot, and an edit list.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): A product photo (a link or an upload), or a description of the product.
- **Platform**: Where the ad runs and its shape, such as a 9:16 reel or a 16:9 pre-roll.
- **Style**: The look and mood.
- **Length**: Total length in seconds (15 by default).

## Steps

1. **Brief.** Ask only what is missing: the one promise the ad makes, where it runs (shape and length), and the look. Offer two or three directions and recommend one.
2. **Shot list,** approved before anything is generated: three to five shots of two to five seconds that add up to the length. For each: seconds, what we see, its job (hook, the product, in use, payoff with room for the logo), one camera move, and its sound. One idea per shot.
3. **Fixed sentences.** One sentence for the product (shape, colours, label), one per person, and one style line (look, palette as hex values, light). Paste them word for word into every prompt.
4. **Stills.** Make the hero still of the product first with `generate_image`; from a product photo, use a model with `image_edit` in `can` and pass the photo as `reference_images`, saying the product stays exactly as in the photo. Once approved, make each shot's first frame with the product photo and the hero still as `reference_images`, so product and look hold. Show all the frames together and wait for approval.
5. **Film shot by shot** with `generate_video`: each approved still as `image`, on one video model for every shot so motion and grain match (its `inputs` must list `image`). Where a shot must end on a set frame, make that frame by editing the first ("same shot, a moment later: ...") and pass it as `last_image`. Each prompt is one shot: the starting state, the action, one camera move, what stays unchanged, and the sound line.
6. **Price the batch:** list every clip with model, seconds, resolution and estimate, give the total, and wait for a yes. Draft one shot at the lowest resolution first; when the user likes it, make the rest, then the finals.
7. **Voice,** if wanted: write the lines against the shot times, audition two or three voices from `list_voices` on the first line with `generate_speech`, then render one file per line.
8. **Deliver an edit list:** the shots in order with their links, the seconds of each to keep, the voice lines with start times, every cost and the total, and what the editor adds: logo, headline, call to action, music.
9. **One clip instead?** Some video models cut several shots inside one clip (`multi_shot` in `takes.parameters`: set it to true and describe the shots in order). That is quick for a mood piece, but a model whose `inputs` list no `image` works from the prompt alone, so a real product will not stay exact.

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
