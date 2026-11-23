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

1. **Brief.** Ask only what is missing, in one message: the one thing a viewer should remember, where it runs (shape and length), the look, and whether it has a voice. For a product given as a photo, ask for one line on what must stay exact. Offer two or three concrete directions and recommend one.
2. **Pick the lane by length.** Read the video models first: a clip has a shortest and a longest length, and that decides which shot lengths can be made. Up to the length of one clip: one shot. Longer, or when the user asks for scenes: three to five shots. For several shots, write the shot list first: per shot its seconds, what we see, its job (hook, the product, in use, payoff with room for the logo), one camera move and its sound. One idea per shot. Wait for the user's OK on it.
3. **Voice,** if the ad has one: now, before the pictures (rules: Voices), one file per line, so the shots are timed to the lines.
4. **Fixed sentences** (several shots): one sentence for the product (shape, colours, label), one per person, and one style line (look, palette as hex values, light). Paste them word for word into every prompt.
5. **Hero still** with `generate_image`: it is also the first frame of the shot it suits, usually the payoff. To work from a product photo, pick an image model with `image_edit` in `can` and pass the photo as `reference_images`. Say that the product stays exactly as in the photo: same shape, colours, label and logo. Describe the set, light and camera plainly. Make it in the platform's shape with clean space for copy, in two versions (the same call with `variant` 1 and 2), and wait for the user to pick one and to check the product against the real thing. Change it by editing: pass it as `image` ("same image, identical product; the only change: ...").
6. **The other shots' stills** (several shots): each shot's first frame with the product photo and the hero still as `reference_images`, so product and look hold. Show all the frames together and wait for the user's OK before any clip is made.
7. **Film** with `generate_video`: each approved still as `image`, on a video model whose `inputs` list `image` and whose lengths fit the shots. Draft the hardest shot first (the most motion, or a person); if it comes out wrong, try another model for that shot rather than holding every shot to one. Each prompt is one shot (rules: Clip prompts): one camera move (slow push-in, orbit, or locked off) and one motion in the scene (a light sweep, steam, fabric, a splash). The product stays rigid and unchanged, and no new objects appear. Where a shot must end on a set frame, make that frame by editing the first ("same shot, a moment later: ...") and pass it as `last_image`.
8. **Draft, then final.** Draft one shot at the shortest length and lowest resolution, show it, and wait for the user's word. Once they like it, make the rest, then the finals at a higher resolution.
9. **Deliver.** One shot: the clip, and what the editor adds (logo, headline, call to action). Several shots: the edit list (rules: Joining), with the voice lines and their start times. Say plainly that the shots are joined in the user's editor.
10. **From a product page link:** a video model whose `inputs` list `web_url` can work from the page itself; otherwise ask for a photo.

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
