---
name: product-photos
description: >
  Product photo, product shot, packshot, lifestyle shot or listing image. Use
  when the user wants still pictures of a product for a store listing, a site,
  a post or a catalogue, from one or more product photos or a description. For
  a video ad use product-ad; to make one of the stills move use animate-photo.
category: media
metadata:
  version: "2026-11-26.5"
---

# Product photos

A set of product stills from one photo, several photos or a description: three by default (clean, in use, detail).

**Not for:** a video (`product-ad`), or a cover or thumbnail with no product in it (`opper-media`).

Uses only the Opper Media tools: no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

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

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `quality`, `notes`. Start from a recommended model (speech: see Voices), the first where two look alike. Never assume an id, a length or a limit.
- **Draft first,** for a video, unless the recipe says otherwise: the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A draft shows the idea, not the finish, and a final is a new take, not the draft made sharper: say both.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip unless the recipe puts several in one, always in this order: the starting state, in one clause when a first frame shows it; what happens, in order, with seconds where timing matters; one camera move, or "locked off"; what must stay the same; the sound line. Check that the first frame allows the action (a cap still on, a busy hand, a shut door): if not, edit the frame or add the step and its seconds, and say which. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words unless the recipe or the user asks for music. A sound switch, if any, is in `takes.parameters`: turn it on, unless the recipe wants a silent clip.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, at preview size, so fine detail is for the user to check. A picture the user links, a clip, or sound, no. If you can run commands, look at a still whose detail matters at full size, and pull a strip of frames from each clip as it lands, checking it against its prompt before going on. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a checklist: a cut in the middle, things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending, a direction that did not land. `transcribe_audio` checks spoken words.
- **Voices.** The user picks the voice by ear. Unless they named a voice or say to pick: choose three that fit the read and what they said (man or woman, age, accent, the kind of piece), make the same short sample on each (the script's first line, or one sentence of the piece if there is no script yet), and send the three links in one message, each with one line on the voice, in its maker's words where `list_voices` gives them. Wait for the pick; one more round at most ("more like the second", "a woman instead"). Told to pick: take the first of your three, on `fish/drama-3` when nothing else decides the model, and say which voice and model it is and that another can be tried later. The kind of read (plain, warm, dramatic, upbeat) is asked or proposed once. Find the three in the notes below and with `list_voices`, which takes `search` (warm british narrator), `language` and `gender`, across models where more than one has a fitting voice. Never a voice whose name or id is a real person's, and search no public voice library: it holds clones of real people. A named maker means its first recommended speech model, and one the user turned down is not sampled again; never `fish/s2.1-pro`. Notes on voices heard to be good, none a default:
  - `fish/drama-3` (`list_voices` shows only its first three; the other ids work): Adrian `bf322df2096a46f18c579d0baa36f41d` (man, deep, measured narrator), Delia `c70cfb98867a4bfb9ae20d2401257b92` (woman, confident), Sheila `f3a2b90078d54a65af4b95f63bc7798e` (woman, young); for explainer narration Ethan `536d3a5e000945adb7038665781a4aca` (a curious explainer) and Gregory `2680da81de8348a68e1f4dbaa79272f1` (teacher, clear, energetic).
  - `elevenlabs/eleven_v4`, also the one for a detailed emotion or an exact delivery the user spells out (crying, a whisper at one moment, a shout) and for a language or accent the others do not suit: Brian `nPczCjzI2devNBz1zQrb` (man, deep; very good for explainer narration), Matilda `XrExE9yKIg1WjnnlVkGX` (woman, professional), Lily `pFZP5JQG7iQjIQuC4Bku` (British woman, warm), Liam `TX3LPaxmHKxFdv7VOQHJ` (young man, energetic).
  - `bytedance-voice:sg/seed-tts-3.0` with `parameters: {"language_code": "en"}`, very good voices, better for lively, ad and character reads than for explainer narration: Sunny `multi_female_myra_cmb_v3_uranus_bigtts` (lively young woman), Marcus `multi_male_marcus_v3_uranus_bigtts` (deep storyteller), Skye `multi_female_skye_v3_uranus_bigtts` (earnest), Ryan `multi_male_ryan_v3_uranus_bigtts` (composed), Mason `multi_male_livesteve_v3_uranus_bigtts` (bright, for ads).
- **Directing a read.** Only when the read calls for it: a plain read gets none. On `fish/drama-3`: a plain-language direction in square brackets before the words it covers, like a brief to a voice actor (`[barely holding it together, forcing a smile] I'm fine.`); sounds and pauses in brackets where they happen (`[shaky breath]`, `[small laugh]`); for single words, paired tags (`<whisper>...</whisper>`, also `<emphasis>`, `<soft>`, `<fast>`, `<slow>`, `<stress>`, `<forceful>`). No fixed list; a one-word tag like `[sad]` is the wrong way. On `elevenlabs/eleven_v4`: tags in square brackets (`[whispers]`, `[sighs]`, `[laughs]`, `[crying]`, `[excited]`, or a voice quality such as `[low, gravelly voice]`), ellipses for pauses, capitals for stress, no SSML, no speed or style setting, and a voice that fits the tag (a calm one will not shout). On `bytedance-voice:sg/seed-tts-3.0`: only its fixed tags, each holding until the next: `[happy]`, `[excited]`, `[sad]`, `[serious]`, `[confident]`, `[commanding]`, `[surprised]`; `[slow]`, `[fast]`, `[low pitch]`, `[quiet]`, `[loud]`, `[whispering]`, `[shouting]`, `[trembling]`; `[laughs]`, `[chuckles]`, `[sighs]`, `[sniffs]`, `[sobs]`, `[gasps]`. On all: one main direction a sentence, none stacked in a short line. Directions are never spoken: keep them out of on-screen script and subtitles.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` on `xai/stt` (its `duration`; `generate_speech` gives none, and some stt models answer in whole seconds), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, on-screen text, the handover to the next shot, and the sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people. Where one takes only people made on a named image model, make an invented actor's still there; a photo of a real person goes to a model that takes real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake. After a finished piece, offer in one line what more can be made from it.
