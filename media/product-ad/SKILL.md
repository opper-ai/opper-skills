---
name: product-ad
description: >
  Product ad, promo, commercial, launch teaser or showcase video. Use when the
  user wants a video ad for a product, as one clip or as several shots, from a
  product photo, a description or a product page link. For still photos of the
  product use product-photos; for a person talking to camera about it use
  creator-ad.
category: media
metadata:
  version: "2026-11-23"
---

# Product ad

A product video ad from a photo, a description or a product page: one shot, or several shots with an edit list.

**Not for:** stills only (`product-photos`), or a presenter speaking to camera (`creator-ad`).

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): A product photo (a link or an upload), a description, or a product page link.
- **Platform**: Where the ad runs and its shape, such as an Instagram reel (9:16) or a website banner (16:9).
- **Length**: Total length in seconds.
- **Style**: The look and mood, such as clean studio, warm lifestyle or bold colour.

## Steps

1. **Brief.** Ask only what is missing, in one message: the one thing a viewer should remember, where it runs (shape and length), and the look. Offer two or three concrete directions and recommend one.
2. **Pick the lane by length.** Up to the length of one clip: one shot. Longer, or when the user asks for scenes: three to five shots of two to five seconds. For several shots, write the shot list first: per shot its seconds, what we see, its job (hook, the product, in use, payoff with room for the logo), one camera move and its sound. One idea per shot. Wait for the user's OK on it.
3. **Fixed sentences** (several shots): one sentence for the product (shape, colours, label), one per person, and one style line (look, palette as hex values, light). Paste them word for word into every prompt.
4. **Hero still** with `generate_image`. To work from a product photo, pick an image model with `image_edit` in `can` and pass the photo as `reference_images`. Say that the product stays exactly as in the photo: same shape, colours, label and logo. Describe the set, light and camera plainly. Make it in the platform's shape with clean space for copy, in two versions (the same call with `variant` 1 and 2), and wait for the user to pick one. Change it by editing: pass it as `image` ("same image, identical product; the only change: ...").
5. **The other shots' stills** (several shots): each shot's first frame with the product photo and the hero still as `reference_images`, so product and look hold. Show all the frames together and wait for the user's OK before any clip is made.
6. **Film** with `generate_video`: each approved still as `image`, on a video model whose `inputs` list `image`, the same model for every shot. Leave `aspect_ratio` out: the clip takes the still's shape. Each prompt is one shot: what the camera sees, one camera move (slow push-in, orbit, or locked off) and one motion in the scene (a light sweep, steam, fabric, a splash). The product stays rigid and unchanged, and no new objects appear. Where a shot must end on a set frame, make that frame by editing the first ("same shot, a moment later: ...") and pass it as `last_image`.
7. **Draft, then final.** Draft one shot at the shortest length and lowest resolution, show it, and wait for the user's word. Once they like it, make the rest, then the finals at a higher resolution.
8. **Voice,** if wanted: write the lines against the shot times, audition two or three voices from `list_voices` on the first line with `generate_speech`, then render one file per line.
9. **Deliver.** One shot: the clip, and what the editor adds (logo, headline, call to action). Several shots: an edit list with the shots in order, their links, the seconds of each to keep, and the voice lines with start times. Say plainly that the shots are joined in the user's editor.
10. **Two shortcuts,** each with a limit. Some video models cut several shots inside one clip (`multi_shot` in `takes.parameters`: set it to true and describe the shots in order), but a model whose `inputs` list no `image` works from the prompt alone, so a real product will not stay exact. From a product page link, a video model whose `inputs` list `web_url` can work from the page itself; otherwise ask for a photo.

## Rules for every step

- **Models come from the list.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row before using it: `can` (what it does), `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`) and `notes` (what it refuses or always does). Start from a recommended model. Never assume a model id, a length or a limit.
- **Draft first.** Shortest length, lowest resolution, one or two stills, so the user sees the idea sooner. Raise quality once they like it.
- **Before a long or high-resolution video,** say in one line which model, length and resolution you are about to use, and wait for the user's go. A short draft needs no such stop.
- **Shape.** Pass `aspect_ratio` where the model lists `aspect_ratios`, or a `size` of that shape where it lists `sizes`. A clip made from an image takes the image's shape: make the still in the final shape and leave `aspect_ratio` out of the video call.
- **Show every result** by its `url` as soon as it lands. While a job is `processing`, say so and follow it with `get_media_job`. If a call times out with no answer, look in `list_media_jobs` before trying again: the job may have run. A link works until its `expires_at`.
- **You cannot watch a clip.** You see stills, not video or sound, so ask the user to check what matters in each clip and say what to look for.
- **The user's own files.** A public https link works everywhere. For a file on their device, call `create_upload_link`, do what its `next` says, and pass its `upload_id` where the file goes. Where a tool has a `_file` field (such as `image_file`), a chat attachment goes there instead.
- **No words in generated pictures.** Generators garble letters: titles, logos, captions and interface text are added in the user's editor.
- **Sound.** If the model makes sound (`audio` in `can`), name only the sounds the scene makes, in order ("Diegetic sound only: ..."), with no music or instrument words. For a silent clip, look in `takes.parameters` for the model's sound switch; `notes` say when sound cannot be turned off.
- **Joining.** These tools make stills, clips, voice and subtitle files. They do not join them. A piece of several parts ends as an ordered edit list for the user's video editor, so promise no finished film. An assistant that can run commands on the user's computer can assemble the file there.
- **People.** Anyone shown or voiced must have agreed to it. `notes` say which models refuse real people.
- **The user decides.** Where a step says to wait, stop until the user answers. A render that worked is not approval. Change one thing per retake.
