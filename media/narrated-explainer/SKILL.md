---
name: narrated-explainer
description: >
  Explainer, tutorial, how-it-works video, narrated story, presentation video,
  product walkthrough, demo or feature tour. Use when the user wants narration
  over pictures, including a walkthrough built on their own screenshots. For a
  presenter speaking on camera use creator-ad; for a story with recurring
  characters use series-episode.
category: media
metadata:
  version: "2026-11-23"
---

# Narrated explainer

A narrated explainer or product walkthrough: script, voice, matching pictures and an edit list.

**Not for:** a talking presenter (`creator-ad`), or voice alone (`voiceover`).

Uses only the Opper Media tools: no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Topic** (required): What to explain and for whom, or the product to walk through.
- **Length**: Target length, such as 30 seconds (the default) or 60 seconds.
- **Style**: The look, such as flat vector, paper cut, line art or photoreal.
- **Language**: The language of the narration.
- **Pictures**: Stills only, a mix of stills and clips (the default), or clips throughout.
- **Screens**: For a walkthrough: the user's own screenshots in order, and what happens on each.

## Steps

1. **Script first.** Write it to length, leaving half a second a shot: warm, full sentences, one line per shot, and only claims the user can stand behind (mark anything you are unsure of). Show it as a shot table: line, what is on screen, still or moving. Say which way the pictures go: stills only (quickest to make and to change), a mix (the default: held stills or slow pans carry most lines, with a clip where motion explains something), or clips throughout (slowest, and every clip is a place where the look can drift). Ask for the OK on the script and about the voice in one message, and wait.
2. **Voice before pictures.** Choose the model and the voice as the Voices rule says, and direct a line only where it needs it. Then make one audio file per line, so one line can be redone on its own, and measure each: the real line lengths set how long each picture holds.
3. **Look.** Make one hero still with `generate_image` in the chosen style and wait for the user's OK on the look. Then pass it as `reference_images` (on a model with `image_edit` in `can`) to every other still, so palette and characters hold. A still that builds on the one before it (a diagram gaining a part) is an edit of that one: the earlier still as `image`. A stylised look (flat vector, line art, paper cut) hides model artefacts better than generic realism. Check that each picture says what its line says, show the stills together and wait for the user's OK; fix single ones by editing, not regenerating.
4. **Clips, where the table says moving:** `generate_video` with the approved still as `image`, and for a diagram that must end in a set state, that state as `last_image` (a still made by editing the first). A clip runs as long as its line. Draft one clip before the rest. The clips sit under the voice, so the editor mutes their own sound.
5. **Walkthrough lane: the user's own screenshots.** The screenshots are the pictures, unchanged. Never pass a screenshot through an image or video model to improve, restyle or animate it: models redraw interface text and get it wrong. They go straight into the user's editor and need not reach these tools at all. Write one line per screen, using the interface's own labels exactly as they appear, and note where the editor should zoom or highlight. Generated media is only for the opening and closing pictures and the voice. To show the product in a scene, such as a laptop on a desk, generate the scene with a blank screen and let the editor place the real screenshot on it.
6. **Deliver the edit list** (rules: Joining), with each shot's line and audio link, and how long it holds (its line's measured length plus half a second). Say how to cut it: lay the voice down first, cut pictures to the lines, keep any music low under the voice. These tools do not join the parts, so say that the list is what the user gets.
7. **Subtitles.** The script is the text and the edit list has each line's start, so give the subtitles with those times in the chat. For exact timings, `transcribe_audio` with `format` srt on the user's finished file (an stt model whose `takes.formats` list mp4; if the answer is plain text with a note, the kind of model the note names).

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
