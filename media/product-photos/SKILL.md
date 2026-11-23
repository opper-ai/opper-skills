---
name: product-photos
description: >
  Product photo, product shot, packshot, lifestyle shot or listing image. Use
  when the user wants still pictures of a product for a store listing, a site,
  a post or a catalogue, from a product photo or a description. For a video ad
  use product-ad; to make one of the stills move use animate-photo.
category: media
metadata:
  version: "2026-11-23"
---

# Product photos

A set of three product stills from one photo or a description: clean, in use and detail.

**Not for:** a video (`product-ad`), or a cover or thumbnail with no product in it (`opper-media`).

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): A product photo (a link or an upload), or a description of the product.
- **Use**: Where the pictures go, such as a store listing, a site hero or a social post.
- **Style**: The look, such as clean studio, natural light at home or bold colour.
- **Shape**: 1:1, 4:5, 16:9 or 9:16.

## Steps

1. **Brief.** Ask only what is missing: where the pictures go (that sets the shape) and the look. Offer two or three directions, such as clean studio, in use at home, or bold graphic colour, and recommend one.
2. **One still per direction** with `generate_image`. From a product photo, pick an image model with `image_edit` in `can` and pass the photo as `reference_images`; say the product stays exactly as in the photo: same shape, colours, label and logo. Describe the surface, background, light and camera plainly, with colours as hex values or as light. The user picks a direction.
3. **Fix by editing,** one change at a time: pass the chosen still as `image` ("same image, identical product; the only change: ...") instead of generating a new one.
4. **The set of three,** in the chosen look: a clean shot on a plain background, the product in use, and a close detail. Make each with the product photo and the chosen still as `reference_images`, so product and look hold across the set. Show the three together.
5. **Finals.** Raise `quality` or resolution for the ones the user keeps.
6. **Offer a next step:** animate one of them, or turn the set into an ad.

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
