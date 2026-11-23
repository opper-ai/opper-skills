---
name: product-ad
description: >
  A short product video ad: a hero still of the product, approved, then
  animated into one clip. Use it when the user wants an ad, promo or showcase
  video or image for a product, from a product photo or a description. For an
  ad of several shots, use multi-shot-ad. Made in chat with the Opper Media
  tools: a draft first, and the price before anything costly.
category: media
metadata:
  version: "2026-11-23"
---

# Product ad

A short product video ad: a hero still of the product, approved, then animated into one clip.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): A product photo (a link or an upload), or a description of the product.
- **Platform**: Where the ad runs and its shape, such as an Instagram reel (9:16) or a website banner (16:9).
- **Style**: The look and mood, such as clean studio, warm lifestyle or bold colour.

## Steps

1. **Brief.** Ask only what is missing, in one message: where it runs (shape and length), the look, and the one thing a viewer should remember. Offer two or three concrete directions and recommend one.
2. **Hero still** with `generate_image`. To work from a product photo, pick an image model with `image_edit` in `can` and pass the photo as `reference_images`. Say that the product stays exactly as in the photo: same shape, colours, label and logo. Describe the set, light and camera plainly, colours as hex values or as light. Make the still in the platform's shape and leave clean space for copy. Make two versions (the same call with `variant` 1 and 2); the user picks one.
3. **Fix by editing.** To change the chosen still, pass it as `image` to `generate_image` ("same image, identical product; the only change: ...") instead of generating a new one.
4. **Animate** with `generate_video`. Pick a video model whose `inputs` list `image` and pass the approved still as `image`. Leave `aspect_ratio` out: the clip takes the still's shape. Write one shot: what the camera sees, one camera move (slow push-in, orbit, or locked off) and one motion in the scene (a light sweep, steam, fabric, a splash). The product stays rigid and unchanged, and no new objects appear.
5. **Draft, then final.** State the price, draft at the shortest length and lowest resolution, show it, and render the final at a higher resolution once the user likes it.
6. **Deliver** the still and clip links with their costs, and say what to add in an editor: logo, headline, call to action.

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
