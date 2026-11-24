---
name: creator-ad
description: >
  Creator-style ad, UGC ad, testimonial, talking-head or presenter clip. Use
  when the user wants a person speaking to camera about a product, or any
  short clip of someone saying a written line. For a product ad with no
  presenter use product-ad; for a voice with no face use voiceover.
category: media
metadata:
  version: "2026-11-23"
---

# Creator-style ad

A clip of a presenter talking to camera about a product, in a voice the user picks, with subtitles.

**Not for:** an ad with no one speaking (`product-ad`), or narration over pictures (`narrated-explainer`).

Uses only the Opper Media tools: no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): A product photo (a link or an upload), or a description of the product.
- **Line**: What the presenter says, or the point to make.
- **Presenter**: Who appears: an invented person by default; a real person only if they agreed.
- **Language**: The spoken language.
- **Length**: Length in seconds, usually 8 to 15.
- **Shape**: Vertical (9:16) by default; take it from where the clip will run, and ask where that place takes both.

## Steps

1. **Script.** One to three sentences said to camera: the hook first, plain spoken words, and only claims the user can stand behind. Ask for the OK on it and about the voice in one message, and wait.
2. **Voice.** Choose the model and the voice as the Voices rule says, and direct the read where the script needs it. Then render the whole script as one file: it drives the clip and sets its length. Measure it (rules: Voice first); if it misses the length asked for, change the words, render again and show the user the script as it now is.
3. **Presenter still** with `generate_image`, in the clip's shape: vertical unless the user or the place it runs says otherwise. By default the presenter is invented, and fits the voice: write one fixed sentence for them (age, look, clothes) and the place, framed like a phone video in natural light, face clear and looking at the camera, holding or beside the product. With a product photo, use a model with `image_edit` in `can` and pass the photo as `reference_images` so the product stays exact. A real person appears only if they agreed. Wait for the user to approve the still and to check the product in it.
4. **Talking clip** with `generate_video`: speech first, then a model that follows it. A video model that makes its own sound may also speak a line written in its prompt, but no row says whether it will, so this is the route that holds. Pick a video model whose `inputs` list both `audio` and `image`: a recommended one if there is one, otherwise search "avatar" or "lip sync" (a model with `lip_sync` in `can` is made for this, and its `needs` names what it cannot work without). Pass the still as `image` and the speech result's `audio.url` as `audio`. The clip is as long as the speech: where the model takes a length, set `seconds` to the speech's length, rounded up, and no longer. Where it takes a prompt, ask only for small natural movement (a nod, a glance at the product) and give the supplied speech as the only sound. Draft at the lowest resolution first, and ask the user to check that the mouth follows the words to the end.
5. **Check the line and make subtitles** in one call: `transcribe_audio` on the clip's `url` with `format` srt, on an stt model whose `takes.formats` list mp4. Not every one gives timings: if the answer comes back as plain text with a note, use the kind of model the note names. Compare the words with the script; if they differ, fix the speech and make the clip again. If a caption holds more than about seven words, or a word is misspelled, give a corrected, split version in the chat.
6. **Deliver** the clip and the subtitle file, and say what the editor adds: captions burned in, logo, call to action.

## Rules for every step

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `quality`, `notes`. Start from a recommended model (speech: see Voices), the first where two look alike. Never assume an id, a length or a limit.
- **Draft first,** unless the recipe says otherwise: the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A draft shows the idea, not the finish, and a final is a new take, not the draft made sharper: say both.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip unless the recipe puts several in one, always in this order: the starting state (do not describe a first frame again); what happens, in order, with seconds where timing matters; one camera move, or "locked off"; what must stay the same; the sound line. Check that the first frame allows the action (a cap still on, a busy hand, a shut door): if not, edit the frame or add the step and its seconds, and say which. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words unless the recipe or the user asks for music. A sound switch, if any, is in `takes.parameters`: turn it on.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, at preview size, so fine detail is for the user to check. A picture the user links, a clip, or sound, no. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a checklist: a cut in the middle, things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending, a direction that did not land. `transcribe_audio` checks spoken words.
- **Voices.** Speech, acted reads too, goes on `fish/drama-3` unless the user names a model; not `fish/s2.1-pro`. `list_voices` is empty for it, but a voice id works as `voice`: pick from its cast by role, Adrian `bf322df2096a46f18c579d0baa36f41d` (man, deep, measured narrator), Delia `c70cfb98867a4bfb9ae20d2401257b92` (woman, confident), Sheila `f3a2b90078d54a65af4b95f63bc7798e` (woman, young). Search no public voice library: it holds clones of real people. Use `elevenlabs/eleven_v4` when the user spells out a detailed emotion or an exact delivery (crying, a whisper at one moment, a shout), when the user wants to choose from a described list (`list_voices` has one for it, by language), for a language the cast does not suit, or when the first take does not please. Before the first take, one short question: the kind of read (plain, warm, dramatic, upbeat ad) and the voice (man or woman, younger or older), unless the request says. After it, offer a second take: another voice, a stronger or lighter read, or the same line on the other model.
- **Directing a read.** Only when the read calls for it: a plain read gets none. On `fish/drama-3`: a plain-language direction in square brackets before the words it covers, like a brief to a voice actor (`[barely holding it together, forcing a smile] I'm fine.`); sounds and pauses in brackets where they happen (`[shaky breath]`, `[small laugh]`); for single words, paired tags (`<whisper>...</whisper>`, also `<emphasis>`, `<soft>`, `<fast>`, `<slow>`, `<stress>`, `<forceful>`). No fixed list; a one-word tag like `[sad]` is the wrong way. On `elevenlabs/eleven_v4`: tags in square brackets (`[whispers]`, `[sighs]`, `[laughs]`, `[crying]`, `[excited]`, or a voice quality such as `[low, gravelly voice]`), ellipses for pauses, capitals for stress, no SSML, no speed or style setting, and a voice that fits the tag (a calm one will not shout). On both: one main direction a sentence, none stacked in a short line. Directions are never spoken: keep them out of on-screen script and subtitles.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` (its `duration`; `generate_speech` gives none, and an stt model answering in whole seconds is too coarse), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, on-screen text, the handover to the next shot, and the sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people. Where one takes only people made on a named image model, make an invented actor's still there; a photo of a real person goes to a model that takes real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake. After a finished piece, offer in one line what more can be made from it.
