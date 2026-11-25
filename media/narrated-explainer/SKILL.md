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
  version: "2026-11-25"
---

# Narrated explainer

A narrated explainer or product walkthrough: a brief, a script, a voice and matching pictures, ending in the film or an edit list.

**Not for:** a talking presenter (`creator-ad`), or voice alone (`voiceover`).

Needs only the Opper Media tools: no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Topic** (required): What to explain and for whom, or the product to walk through.
- **Length**: Target length, such as 30 seconds (the default) or 60 seconds.
- **Style**: The kind of pictures, if decided: real-looking footage, illustration, a sketch, diagrams, or your own screenshots.
- **Language**: The language of the narration; the language of the request if none is given.
- **Pictures**: Stills only, a mix, or clips throughout, if decided.
- **Screens**: For a walkthrough: the user's own screenshots in order, and what happens on each.

## Steps

1. **Brief,** before any script: one message that proposes, so the user can answer in a word. Propose one way from the topic and name the others:
   - the pictures: real-looking moving footage; drawn illustration (flat vector, paper cut); a hand-drawn sketch or scribble on white; diagrams that build up; the user's own screenshots (step 6);
   - stills only (quickest to make and change), a mix (a clip where motion explains), or clips throughout (slowest, and each clip can drift from the look);
   - the length, where it runs (shape), the read and the voice (rules: Voices), and roughly how many shots.

   A real-world subject (nature, food, a place, a craft) suggests real-looking moving shots; an idea or a process, drawings or a sketch with motion only where it explains; a product, its screenshots. Say what the user will review, in order of how much is made: the script and shot table (nothing made yet), the voice, one hero still for the look, every still beside its line as a storyboard, one draft clip, and only then the other clips.
2. **Script and shot table.** Write to length, leaving half a second a shot: as a first guess two words a second, so 30 seconds in six shots is about 55 words. Warm, full sentences, one line per shot, and only claims the user can stand behind (mark anything you are unsure of). Show it as a table: line, what is on screen, still or moving. Wait for the user's OK.
3. **Voice before pictures** (rules: Voices). One audio file per line, so one line can be redone on its own; a direction, if the read has one, opens every file, so the lines match. Measure each: the real line lengths set how long each picture holds.
4. **Look, then storyboard.** Make one hero still with `generate_image` in the chosen style and wait for the user's OK on the look. Then pass it as `reference_images` (on a model with `image_edit` in `can`) to every other still, so palette and characters hold. A still that builds on the one before it (a diagram gaining a part) is an edit of that one: the earlier still as `image`. Check that each picture says what its line says, show the stills together, each beside its line, and wait for the user's OK; fix single ones by editing, not regenerating.
5. **Clips, where the table says moving,** come last and only after the storyboard is approved: `generate_video` with the approved still as `image`, and for a diagram that must end in a set state, that state as `last_image` (a still made by editing the first). A clip is as long as its line's measured length plus the half second, rounded up to a length the model takes. Real-looking shots keep their scene sound, to go low under the voice; drawn and sketch styles are made silent (no sound line, the sound switch off). Draft one clip only (it may be shorter than its line) and show it. Then say in one line how many clips, the model, the length and the resolution, and wait for a go; the rest are made as finals, with no draft each.
6. **Walkthrough lane: the user's own screenshots.** The screenshots are the pictures, unchanged. Never pass a screenshot through an image or video model to improve, restyle or animate it: models redraw interface text and get it wrong. They go straight into the edit and need not reach these tools at all. Write one line per screen, using the interface's own labels exactly as they appear, and note where to zoom or highlight. Generated media is only for the opening and closing pictures and the voice. To show the product in a scene, such as a laptop on a desk, generate the scene with a blank screen and place the real screenshot on it in the edit.
7. **Assemble** (this replaces rules: Joining). These tools do not join the parts.
   - If you can run commands and fetch the links (a coding agent), build the film yourself with ffmpeg: each voice line at the start of its shot, the pictures cut to the lines (a shot holds for its line plus half a second), scene sound about 18 dB under the voice. Check the result (its length, a sheet of frames) before handing it over.
   - If you cannot (a chat app), hand over the parts with an edit list: per shot its picture and audio links, how long it holds and its sound level; voice first, pictures cut to the lines. Promise no finished film.
8. **Subtitles** when the user asked for them; otherwise offer them in one line at the end. The script is the text and the edit list has each line's start. For exact timings, `transcribe_audio` with `format` srt on the finished file (an stt model whose `takes.formats` list mp4; if the answer is plain text with a note, the kind of model the note names).

## Rules for every step

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `quality`, `notes`. Start from a recommended model (speech: see Voices), the first where two look alike. Never assume an id, a length or a limit.
- **Draft first,** unless the recipe says otherwise: the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A draft shows the idea, not the finish, and a final is a new take, not the draft made sharper: say both.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip unless the recipe puts several in one, always in this order: the starting state, in one clause when a first frame shows it; what happens, in order, with seconds where timing matters; one camera move, or "locked off"; what must stay the same; the sound line. Check that the first frame allows the action (a cap still on, a busy hand, a shut door): if not, edit the frame or add the step and its seconds, and say which. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words unless the recipe or the user asks for music. A sound switch, if any, is in `takes.parameters`: turn it on.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, at preview size, so fine detail is for the user to check. A picture the user links, a clip, or sound, no. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a checklist: a cut in the middle, things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending, a direction that did not land. `transcribe_audio` checks spoken words.
- **Voices.** Speech, acted reads too, goes on `fish/drama-3` unless the user names a model; not `fish/s2.1-pro`. `list_voices` is empty for it, but a voice id works as `voice`: pick from its cast by role, Adrian `bf322df2096a46f18c579d0baa36f41d` (man, deep, measured narrator), Delia `c70cfb98867a4bfb9ae20d2401257b92` (woman, confident), Sheila `f3a2b90078d54a65af4b95f63bc7798e` (woman, young). Search no public voice library: it holds clones of real people. Use `elevenlabs/eleven_v4` when the user spells out a detailed emotion or an exact delivery (crying, a whisper at one moment, a shout), when the user wants to choose from a described list (`list_voices` has one for it, by language), for a language the cast does not suit, or when the first take does not please. Before the first take, one short question: the kind of read (plain, warm, dramatic, upbeat ad) and the voice (man or woman, younger or older), unless the request says. After it, offer a second take: another voice, a stronger or lighter read, or the same line on another model. A third option, for a brisker read, another language or accent, or more voices: `bytedance-voice:sg/seed-tts-3.0` with `parameters: {"language_code": "en"}`. `list_voices` gives ids only: in English pick Sunny `multi_female_myra_cmb_v3_uranus_bigtts` (lively young woman), Marcus `multi_male_marcus_v3_uranus_bigtts` (deep storyteller), Skye `multi_female_skye_v3_uranus_bigtts` (earnest), Ryan `multi_male_ryan_v3_uranus_bigtts` (composed) or Mason `multi_male_livesteve_v3_uranus_bigtts` (bright, for ads), and never a voice named after a real person.
- **Directing a read.** Only when the read calls for it: a plain read gets none. On `fish/drama-3`: a plain-language direction in square brackets before the words it covers, like a brief to a voice actor (`[barely holding it together, forcing a smile] I'm fine.`); sounds and pauses in brackets where they happen (`[shaky breath]`, `[small laugh]`); for single words, paired tags (`<whisper>...</whisper>`, also `<emphasis>`, `<soft>`, `<fast>`, `<slow>`, `<stress>`, `<forceful>`). No fixed list; a one-word tag like `[sad]` is the wrong way. On `elevenlabs/eleven_v4`: tags in square brackets (`[whispers]`, `[sighs]`, `[laughs]`, `[crying]`, `[excited]`, or a voice quality such as `[low, gravelly voice]`), ellipses for pauses, capitals for stress, no SSML, no speed or style setting, and a voice that fits the tag (a calm one will not shout). On `bytedance-voice:sg/seed-tts-3.0`: only its fixed tags, each holding until the next: `[happy]`, `[excited]`, `[sad]`, `[serious]`, `[confident]`, `[commanding]`, `[surprised]`; `[slow]`, `[fast]`, `[low pitch]`, `[quiet]`, `[loud]`, `[whispering]`, `[shouting]`, `[trembling]`; `[laughs]`, `[chuckles]`, `[sighs]`, `[sniffs]`, `[sobs]`, `[gasps]`. On all: one main direction a sentence, none stacked in a short line. Directions are never spoken: keep them out of on-screen script and subtitles.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` on `xai/stt` (its `duration`; `generate_speech` gives none, and some stt models answer in whole seconds), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, on-screen text, the handover to the next shot, and the sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people. Where one takes only people made on a named image model, make an invented actor's still there; a photo of a real person goes to a model that takes real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake. After a finished piece, offer in one line what more can be made from it.
