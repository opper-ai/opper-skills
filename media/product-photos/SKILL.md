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

1. **Brief.** Ask only what is missing: where the pictures go (that sets the shape: a store listing is usually square, a site banner wide, a story or reel vertical), how many stills (three unless the user says otherwise) and the look. Offer two or three directions, such as clean studio, in use at home, or bold graphic colour, and recommend one.
2. **One still per direction** with `generate_image`. From product photos, pick an image model with `image_edit` in `can` and pass them all as `reference_images`; say the product stays exactly as in the photos: same shape and colours, and its label and logo if it has any. Describe the surface, background, light and camera plainly, with colours as hex values or as light. Wait for the user to pick a direction.
3. **Fix by editing,** at any point, one change at a time: pass the chosen still as `image` ("same image, identical product; the only change: ...") instead of generating a new one.
4. **The set,** in the chosen look and in the number asked for. Three is a clean shot on a plain background, the product in use, and a close detail; for more, add angles, settings or uses, and say which before making them. Make each with the product photos and the chosen still as `reference_images`, so product and look hold across the set. The clean shot takes the look's light and colour, not its setting. An angle the photos do not show (the inside, the back) is invented: say so before making it. Show them together.
5. **Finals.** For the ones the user keeps, pass the still as `image` at a higher `quality` or size ("same image, nothing changed"), so the final is the same picture.
6. **Offer a next step:** animate one of them, or turn the set into an ad.

## Rules for every step

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `quality`, `notes`. Start from a recommended model, the first where two look alike. Never assume an id, a length or a limit.
- **Draft first,** unless the recipe says otherwise: the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A draft shows the idea, not the finish, and a final is a new take, not the draft made sharper: say both.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip unless the recipe puts several in one, always in this order: the starting state (do not describe a first frame again); what happens, in order, with seconds where timing matters; one camera move, or "locked off"; what must stay the same; the sound line. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words unless the recipe or the user asks for music. A sound switch, if any, is in `takes.parameters`: turn it on.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, at preview size, so fine detail is for the user to check. A picture the user links, a clip, or sound, no. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a short checklist: a cut in the middle, people or things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending. `transcribe_audio` checks spoken words.
- **Voices.** Ask whether the user knows the voice they want. If not, offer three clearly different ones (say warm storyteller, bright and energetic, calm and authoritative) on the same first line, and wait for the pick. `list_voices` filters by language only: match on each voice's name, gender and accent yourself, on a speech model whose voice names describe the voice. Where a language has too few, try another model or offer fewer.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` (its `duration`; `generate_speech` gives none, and an stt model that answers in whole seconds is too coarse, so use another), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, the text to add on screen, the handover to the next shot, and what to do with sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake. After a finished piece, offer in one line what more can be made from it.
