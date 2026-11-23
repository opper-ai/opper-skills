---
name: product-photos
description: >
  Product photo, product shot, packshot, lifestyle shot or listing image. Use
  when the user wants still pictures of a product for a store listing, a site,
  a post or a catalogue, from one or more product photos or a description. For
  a video ad use product-ad; to make one of the stills move use animate-photo.
category: media
metadata:
  version: "2026-11-23"
---

# Product photos

A set of product stills from one photo, several photos or a description: three by default (clean, in use, detail).

**Not for:** a video (`product-ad`), or a cover or thumbnail with no product in it (`opper-media`).

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): One product photo, several (other angles, details, the packaging), or a description of the product.
- **Count**: How many stills. Three by default.
- **Use**: Where the pictures go, such as a store listing, a site hero or a social post.
- **Style**: The look, such as clean studio, natural light at home or bold colour.
- **Shape**: 1:1, 4:5, 16:9 or 9:16.

## Steps

1. **Brief.** Ask only what is missing: where the pictures go (that sets the shape), how many stills (three unless the user says otherwise) and the look. Offer two or three directions, such as clean studio, in use at home, or bold graphic colour, and recommend one.
2. **One still per direction** with `generate_image`. From product photos, pick an image model with `image_edit` in `can` and pass them all as `reference_images`; say the product stays exactly as in the photos: same shape, colours, label and logo. Describe the surface, background, light and camera plainly, with colours as hex values or as light. Wait for the user to pick a direction.
3. **Fix by editing,** one change at a time: pass the chosen still as `image` ("same image, identical product; the only change: ...") instead of generating a new one.
4. **The set,** in the chosen look and in the number asked for. Three is a clean shot on a plain background, the product in use, and a close detail; for more, add angles, settings or uses, and say which before making them. Make each with the product photos and the chosen still as `reference_images`, so product and look hold across the set. Show them together.
5. **Finals.** Raise `quality` or resolution for the ones the user keeps.
6. **Offer a next step:** animate one of them, or turn the set into an ad.

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
