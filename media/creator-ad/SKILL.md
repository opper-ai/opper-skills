---
name: creator-ad
description: >
  Creator-style ad, UGC ad, testimonial, talking-head or presenter clip. Use
  when the user wants a person speaking to camera about a product, or any
  short clip of someone saying a written line. For a product ad with no
  presenter use product-ad; for a voice with no face use voiceover.
category: media
metadata:
  version: "2026-11-26.2"
---

# Creator-style ad

An ad of a presenter talking to camera about a product: one clip with action, sound and speech, or an avatar take that keeps an exact voice file.

**Not for:** an ad with no one speaking (`product-ad`), or narration over pictures (`narrated-explainer`).

Needs only the Opper Media tools: no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Product** (required): A product photo (a link or an upload), or a description of the product.
- **Line**: What the presenter says, or the point to make.
- **Presenter**: Who appears: an invented person by default; a real person only if they agreed.
- **Voice**: A voice that sounds like the one chosen (the default), or an exact voice file that must be heard: a clone, a recording, a chosen voice word for word.
- **Language**: The spoken language.
- **Length**: Length in seconds, usually 15 to 30.
- **Shape**: Vertical (9:16) by default; take it from where the ad will run.
- **Extras**: Captions, on-screen text (a hook title, a call to action) and music: yes or no to each.

## Steps

1. **Brief.** A voice recording the user brings comes first: `transcribe_audio` it, since its words are the script and its length the ad's, show the words, and ask who it sounds like (you cannot hear it). Then one short message, asking only what the request leaves open: the length; where it runs (shape); the voice (rules: Voices), and whether one that sounds like it is fine or the exact voice file must be heard; yes or no to captions, to on-screen text (a hook title, a call to action) and to music; and for a product given only in words, a photo if there is one and what it does.
2. **Pick the recipe.** *One clip* (steps 4 to 6) is the default: the video model speaks the lines itself, in a voice like the one chosen, with action, sound and music. *Avatar* (steps 7 to 10) when the exact voice file must be heard, or the presenter is a given photo of a real person who agreed. Never give a speech file to a video model without `lip_sync` in `can`: it does not follow the words. Never ask an avatar model to walk, change scene or handle props.
3. **Script,** in the shape of an ad: a hook in the first seconds, the problem, the product, proof, a call to action. Plain spoken words, about 2.5 a second (30 seconds hold about 70), and only claims the user can stand behind. Wait for the user's OK.

**One clip,** on `bytedance:ap/seedance-2.5`:

4. **Voice sample and presenter still.** The sample: 5 to 10 seconds of the script in the chosen voice, with `generate_speech`. Tell the user the model speaks the words anew in that voice; it never plays the sample. The still: `generate_image` on `bytedance:ap/seedream-5-pro` (rules: People), in the ad's shape, with `parameters: {"watermark": false}` (or it stamps a corner): one fixed sentence for the presenter (age, look, clothes), with the product, set where the script's first shot is; a product photo goes in as `reference_images`. Wait for the user to approve the still and check the product in it.
5. **The ad** with `generate_video`: the still (and a product photo) in `reference_images`, the sample in `reference_audios`, no `image` (a first frame is refused next to a reference), the shape as `aspect_ratio`, up to 30 seconds, sound on. The prompt, in this order:
   - the presenter is the woman or man in @Image 1; the lines use "the voice timbre of @Audio 1, lips in sync with every word", and the audio is a voice reference, not the soundtrack;
   - timed shots in whole seconds ("Shot 1, 0-10s: ..."), each with its place, an action (she does something with the product, walks, pours, points), her line in double quotes with one delivery word, and that shot's sounds;
   - one music line for the whole clip, or "no music";
   - what stays the same in every shot (face, hair, clothes, product, voice), and "No on-screen text" unless the user wants text.
6. **Draft, then final.** A draft of the whole ad at the lowest resolution shows the order, the actions and the words: check the words on it with `transcribe_audio`, on an stt model whose `takes.formats` list mp4 (not `xai/stt`: speech files only). The final is a new take at 720p; check its words the same way.

**Avatar,** on `veed/fabric-1.0`, or `heygen/avatar-iv` as the second choice:

7. **Speech first:** the whole script as one take (rules: Voices, Directing a read) with an energetic direction, since the avatar mirrors the voice and a flat read gives a flat avatar. Voice only, no music in the file. Measure it. A recording the user brings is used as it is.
8. **Still** with `generate_image`, in the ad's shape; an invented presenter is made as in step 4, so the still can also be a reference for the cutaways. Chest-up or half body, facing the camera, well lit, a subtle expression with the mouth closed, hands resting, the product held low and away from the face. Nothing touches or covers the face; no arm's-length selfie, no mid-step pose, no small face in a wide shot. Wait for the user's OK. A real person's photo is used as given.
9. **One talking take** for the whole speech on that one still, with `generate_video`: the still as `image`, the speech as `audio`, 720p. On `veed/fabric-1.0` no `seconds` and no prompt (a clip runs up to a minute). On `heygen/avatar-iv` add `parameters: {"expressiveness": "high"}`; a prompt there is for one small gesture at most.
10. **Cutaways** give the variety, not new backgrounds: one clip on the one-clip model, made once at 720p, of two or three timed shots of about three seconds, showing the product ("the bottle from @Image 1", the product photo or the still in `reference_images`), hands only, no speech, no music, natural sound. They show while her voice goes on, over the words they illustrate. The talking clip has no background sound: sound comes from the cutaways, and music (these tools make none: it comes from the user's editor) goes on last, low, dipping under the voice. Add no generated room tone.

**Both:**

11. **Subtitle file,** if the user wants captions: `transcribe_audio` with `format` srt on the speech, or on the one clip (a model that reads video and gives timings; a note names the kind if it gave none). It gives about one caption a sentence; shorter phrases are split in the editor.
12. **Assemble** (this replaces rules: Joining). These tools do not join, caption or mix; a one-clip ad with no captions or titles is finished as it is.
    - If you can run commands and fetch the links (a coding agent), build it yourself with ffmpeg: keep the voice track unbroken and cut only the picture; captions in phrases of 2 to 4 words from the transcript's timings; the hook title in the first 2 to 3 seconds, the call to action in the last 2 to 3; music about 19 dB under the voice and dipping under it; cutaway sound about 10 dB under. Check the result (its length, a sheet of frames) before handing it over.
    - If you cannot (a chat app), hand over the parts with an edit list: each clip's link and the seconds to keep, where each cutaway goes by the words spoken, the subtitle file, the suggested title and call to action, and the levels above. Promise no finished film.
13. **Deliver,** then offer next steps in one line: another take, another voice, a shorter cut, another shape. For real movement with an exact voice file, a clip from a video model can be given the voice by `veed/lipsync-2.0` or `heygen/lipsync-precision`: the picture stays, the clip becomes as long as the voice file, and every other sound is replaced by the voice. Offer it; do not start with it.

## Rules for every step

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `quality`, `notes`. Start from a recommended model (speech: see Voices), the first where two look alike. Never assume an id, a length or a limit.
- **Draft first,** for a video, unless the recipe says otherwise: the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A draft shows the idea, not the finish, and a final is a new take, not the draft made sharper: say both.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip unless the recipe puts several in one, always in this order: the starting state, in one clause when a first frame shows it; what happens, in order, with seconds where timing matters; one camera move, or "locked off"; what must stay the same; the sound line. Check that the first frame allows the action (a cap still on, a busy hand, a shut door): if not, edit the frame or add the step and its seconds, and say which. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words unless the recipe or the user asks for music. A sound switch, if any, is in `takes.parameters`: turn it on, unless the recipe wants a silent clip.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, at preview size, so fine detail is for the user to check. A picture the user links, a clip, or sound, no. If you can run commands, pull a strip of frames from each clip as it lands and check it against its prompt before going on. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a checklist: a cut in the middle, things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending, a direction that did not land. `transcribe_audio` checks spoken words.
- **Voices.** Speech, acted reads too, goes on `fish/drama-3` unless the user names a model; not `fish/s2.1-pro`. Pick from its cast by role and pass the id as `voice`: Adrian `bf322df2096a46f18c579d0baa36f41d` (man, deep, measured narrator), Delia `c70cfb98867a4bfb9ae20d2401257b92` (woman, confident), Sheila `f3a2b90078d54a65af4b95f63bc7798e` (woman, young). Search no public voice library: it holds clones of real people. Use `elevenlabs/eleven_v4` when the user spells out a detailed emotion or an exact delivery (crying, a whisper at one moment, a shout), when the user wants more voices, for a language or accent the cast does not suit, or when the first take does not please. Before the first take, one short question: the kind of read (plain, warm, dramatic, upbeat ad) and the voice (man or woman, younger or older), unless the request says. After it, offer a second take: another voice, a stronger or lighter read, or the same line on another model. A third option, for a brisker read, another language or accent, or more voices: `bytedance-voice:sg/seed-tts-3.0` with `parameters: {"language_code": "en"}`. In English pick Sunny `multi_female_myra_cmb_v3_uranus_bigtts` (lively young woman), Marcus `multi_male_marcus_v3_uranus_bigtts` (deep storyteller), Skye `multi_female_skye_v3_uranus_bigtts` (earnest), Ryan `multi_male_ryan_v3_uranus_bigtts` (composed) or Mason `multi_male_livesteve_v3_uranus_bigtts` (bright, for ads). For more, `list_voices` describes any model's voices and takes `search` (warm british narrator), `language` and `gender`; never use one whose name or id is a real person's.
- **Directing a read.** Only when the read calls for it: a plain read gets none. On `fish/drama-3`: a plain-language direction in square brackets before the words it covers, like a brief to a voice actor (`[barely holding it together, forcing a smile] I'm fine.`); sounds and pauses in brackets where they happen (`[shaky breath]`, `[small laugh]`); for single words, paired tags (`<whisper>...</whisper>`, also `<emphasis>`, `<soft>`, `<fast>`, `<slow>`, `<stress>`, `<forceful>`). No fixed list; a one-word tag like `[sad]` is the wrong way. On `elevenlabs/eleven_v4`: tags in square brackets (`[whispers]`, `[sighs]`, `[laughs]`, `[crying]`, `[excited]`, or a voice quality such as `[low, gravelly voice]`), ellipses for pauses, capitals for stress, no SSML, no speed or style setting, and a voice that fits the tag (a calm one will not shout). On `bytedance-voice:sg/seed-tts-3.0`: only its fixed tags, each holding until the next: `[happy]`, `[excited]`, `[sad]`, `[serious]`, `[confident]`, `[commanding]`, `[surprised]`; `[slow]`, `[fast]`, `[low pitch]`, `[quiet]`, `[loud]`, `[whispering]`, `[shouting]`, `[trembling]`; `[laughs]`, `[chuckles]`, `[sighs]`, `[sniffs]`, `[sobs]`, `[gasps]`. On all: one main direction a sentence, none stacked in a short line. Directions are never spoken: keep them out of on-screen script and subtitles.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` on `xai/stt` (its `duration`; `generate_speech` gives none, and some stt models answer in whole seconds), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, on-screen text, the handover to the next shot, and the sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people. Where one takes only people made on a named image model, make an invented actor's still there; a photo of a real person goes to a model that takes real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake. After a finished piece, offer in one line what more can be made from it.
