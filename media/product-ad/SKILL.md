---
name: product-ad
description: >
  Product ad, promo, commercial, launch teaser or showcase video. Use when the
  user wants a video ad for a product, with several shots, action and sound,
  from a product photo, a description or a product page link. For still photos
  of the product use product-photos; for a person talking to camera about it
  use creator-ad.
category: media
metadata:
  version: "2026-11-23"
---

# Product ad

A product video ad from a photo, a description or a product page: several shots in one clip, with action and sound.

**Not for:** stills only (`product-photos`), or a presenter speaking to camera (`creator-ad`).

Uses only the Opper Media tools: no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): A product photo (a link or an upload), a description, or a product page link.
- **Platform**: Where the ad runs and its shape, such as an Instagram reel (9:16) or a website banner (16:9).
- **Length**: Total length in seconds.
- **Sound**: Music, a voice, or only the sounds of the scene.
- **Style**: The look and mood, such as clean studio, warm lifestyle or bold colour.

## Steps

1. **Brief.** Ask what is missing, in one message: the one thing a viewer should remember, where it runs (shape), the length (eight to ten seconds if they have no wish), the sound (music, a voice, or only scene sound), and the look. For a product given as a photo, ask for one line on what must stay exact. Offer two or three concrete directions and recommend one.
2. **Shot list.** An ad needs something to happen: three or four shots, one idea each. A hook (an action: a pour, an unboxing, a splash), the product close (its telling detail), in use (hands or a person), the payoff (the product at rest, with room for the logo). Per shot: its seconds, what happens, one camera move, its sound. Hands and action are welcome; the product itself never changes. Add one sentence for the product (shape, colours, label) and one style line (look, palette, light). Wait for the user's OK.
3. **Pick the lane.** The main way is the whole ad as one clip. A video model fits when its `inputs` list `reference_images` (or `web_url`, for a product page link with no photo), it makes sound (`audio` in `can`) and its longest length covers the ad. Go clip by clip (step 8) only when a shot must start or end on an exact frame, or the ad is longer than one clip.
4. **Voice,** if the ad has one: now (rules: Voices), so the shots are timed to the lines. It goes on in the user's editor.
5. **Hero still** with `generate_image`: the payoff frame, in the platform's shape. From a product photo: an image model with `image_edit` in `can`, the photo as `reference_images`, and a prompt saying the product stays exactly as in the photo: shape, colours, and a label or logo only if it has one. Make two versions (`variant` 1 and 2) and wait for the user to pick one and check the product against the real thing. Change it by an edit: the still as `image`.
6. **The ad as one clip** with `generate_video`: the product photo and the approved hero still as `reference_images`, no `image`, the platform's `aspect_ratio`, the full length. The prompt: the style line and the product sentence; every shot in order with its seconds ("Shot 1, 0 to 2.5 seconds: ..."), what happens and one camera move, hard cuts between shots; that the product in every shot is the one in the references; the sound line: the scene's sounds in order and, if the user wants music, a short music line (mood and instrument).
7. **Draft, then final.** A draft of the whole ad on the final's model, at a resolution below 720p (it has none: no draft), shows order, action and timing, not what the ad will look like: say so. Make the final at 720p (more only if the user asks) on a model that fits, and say in one line which model it is; `quality` alone does not decide between models that fit. Add to the checklist: every shot there and in order, hands that look right.
8. **Clip by clip:** each shot's first frame as a still, made with the photo and the hero still as `reference_images`, all shown for the user's OK. Then each still as `image` with that shot's prompt; a frame a shot must end on is `last_image`. It ends as an edit list (rules: Joining).
9. **Deliver.** The clip, and what the editor adds (logo, headline, call to action, the voice). Then offer next steps in one line: a take on another model, a voice, another music mood, a longer cut, another shape, shop stills with `product-photos`.

## Rules for every step

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `quality`, `notes`. Start from a recommended model, the first where two look alike. Never assume an id, a length or a limit.
- **Draft first,** unless the recipe says otherwise: the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A draft shows the idea, not the finish, and a final is a new take, not the draft made sharper: say both.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip unless the recipe puts several in one, always in this order: the starting state (do not describe a first frame again); what happens, in order, with seconds where timing matters; one camera move, or "locked off"; what must stay the same; the sound line. Check that the first frame allows the action (a cap still on, a busy hand, a shut door): if not, edit the frame or add the step and its seconds, and say which. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words unless the recipe or the user asks for music. A sound switch, if any, is in `takes.parameters`: turn it on.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, at preview size, so fine detail is for the user to check. A picture the user links, a clip, or sound, no. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a checklist: a cut in the middle, things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending. `transcribe_audio` checks spoken words.
- **Voices.** Ask whether the user knows the voice they want. If not, offer three clearly different ones (say warm storyteller, bright and energetic, calm and authoritative) on the same first line, and wait for the pick. `list_voices` filters by language only: match name, gender and accent yourself, on a speech model whose voice names describe the voice; where a language has too few, try another model or offer fewer.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` (its `duration`; `generate_speech` gives none, and an stt model answering in whole seconds is too coarse), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, on-screen text, the handover to the next shot, and the sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people. Where one takes only people made on a named image model, make an invented actor's still there; a photo of a real person goes to a model that takes real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake. After a finished piece, offer in one line what more can be made from it.
