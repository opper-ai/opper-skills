---
name: hero-shot
description: >
  One striking still for a reel cover, thumbnail, post or banner, with room
  for a title. Use it when the user wants a cover, thumbnail, poster, banner,
  key visual or hero image. Made in chat with the Opper Media tools: a draft
  first, and the price before anything costly.
category: media
metadata:
  version: "2026-11-23"
---

# Hero shot or cover

One striking still for a reel cover, thumbnail, post or banner, with room for a title.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Subject** (required): What it shows: a product, a person, a scene, or a photo of it (a link or an upload).
- **Format**: Where it goes: reel cover (9:16), thumbnail (16:9), square post (1:1) or banner.
- **Style**: The look, such as bold studio colour, cinematic natural light or graphic flat.

## Steps

1. **Settle the shape and the look.** The format sets the aspect ratio; offer two or three directions with a recommendation.
2. **Pick an image model** for `generate_image` whose `takes` cover that shape (its `aspect_ratios` or `sizes`). For a real product or person, pick one with `image_edit` in `can`, pass their photo as `reference_images` and say what must stay exact.
3. **Compose for the job:** one clear subject the eye lands on first, strong contrast, simple shapes that read when small, and clean empty space where the title will sit (say where: top third, left half). Colours as hex values or as light, never as objects.
4. **Keep words out of the image** and add them in an editor. If the user insists on words in the image, keep them to a few, in quotes, at a high `quality`, and check every letter of the result.
5. **Make two or three versions,** let the user pick, then fix details by passing the chosen one as `image` to `generate_image` ("same image; the only change: ...") instead of generating a new one. Raise quality or resolution only for the final.
6. **Offer a next step:** animate it into a short loop for a reel.

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
