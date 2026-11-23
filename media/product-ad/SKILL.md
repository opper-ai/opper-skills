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
3. **Voice,** if the ad has one: now, before the pictures (rules: Voices), one file per line, so the shots are timed to the lines.
4. **Fixed sentences** (several shots): one sentence for the product (shape, colours, label), one per person, and one style line (look, palette as hex values, light). Paste them word for word into every prompt.
5. **Hero still** with `generate_image`. To work from a product photo, pick an image model with `image_edit` in `can` and pass the photo as `reference_images`. Say that the product stays exactly as in the photo: same shape, colours, label and logo. Describe the set, light and camera plainly. Make it in the platform's shape with clean space for copy, in two versions (the same call with `variant` 1 and 2), and wait for the user to pick one. Change it by editing: pass it as `image` ("same image, identical product; the only change: ...").
6. **The other shots' stills** (several shots): each shot's first frame with the product photo and the hero still as `reference_images`, so product and look hold. Show all the frames together and wait for the user's OK before any clip is made.
7. **Film** with `generate_video`: each approved still as `image`, on a video model whose `inputs` list `image`. Let the hardest shot decide the model (the one with the most motion, or a person), and use another for a shot only where it does that shot better. Each prompt is one shot (rules: Clip prompts): one camera move (slow push-in, orbit, or locked off) and one motion in the scene (a light sweep, steam, fabric, a splash). The product stays rigid and unchanged, and no new objects appear. Where a shot must end on a set frame, make that frame by editing the first ("same shot, a moment later: ...") and pass it as `last_image`.
8. **Draft, then final.** Draft one shot at the shortest length and lowest resolution, show it, and wait for the user's word. Once they like it, make the rest, then the finals at a higher resolution.
9. **Deliver.** One shot: the clip, and what the editor adds (logo, headline, call to action). Several shots: the edit list (rules: Joining), with the voice lines and their start times. Say plainly that the shots are joined in the user's editor.
10. **From a product page link:** a video model whose `inputs` list `web_url` can work from the page itself; otherwise ask for a photo. Some video models cut several shots inside one clip (`multi_shot` in `takes.parameters`), but from a prompt alone a real product will not stay exact.

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
