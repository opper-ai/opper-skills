---
name: continue-shot
description: >
  Extend a video, make a clip longer, continue the shot, what happens next.
  Use when the user has a clip and wants more of the same shot. To start from
  a still photo use animate-photo; for a new shot in a longer piece use
  storyboard-film.
category: media
metadata:
  version: "2026-11-26.2"
---

# Continue a shot

Make a clip longer by extending it, so its motion carries over the join.

**Not for:** animating a still (`animate-photo`), or a new shot from a new angle (`storyboard-film`).

Uses only the Opper Media tools: no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Clip** (required): The clip to continue: a link, an upload, or a clip made earlier in the chat.
- **Next** (required): What happens next in the shot.
- **Length**: How many seconds to add.

## Steps

1. **Know the clip.** For a clip made in this chat you have its job id and the model that made it. For any other clip, ask the user which model made it: the job list does not say. How it ends (what is moving in the last second, how fast, what the camera is doing) comes from your own prompt, or from the user. If you are making the first clip too, make it on a video model with `video_extension` in `can`, and end its prompt with the motion still under way, so that it can be continued.
2. **Extend, do not restart.** A new clip started from the old one's last frame begins from a standstill: the position matches, but speed and camera move do not, and the join pops. Continuing the clip itself lets the model carry the motion over.
3. **Agree what happens next.** Say back in a sentence or two how the shot will go on and for how long, and wait for the user's OK.
4. **First way, for a clip made in this chat:** call `generate_video` on the same model with a prompt, `seconds` set to the length to add, and `parameters: {"continue_from": "<the clip's job id>"}`. Send no `image` or `video`, and no shape or resolution: they carry over from the clip. Without `seconds` a model may add far more than a few seconds. `continue_from` is not a key a model's row lists: where the model can continue its own clip, the result is the whole clip, old part and new; where it cannot, the answer says so and nothing is made, and you go on to the second way.
5. **Second way, for any clip:** a video model with `video_extension` in `can` (its `inputs` list `video`), with the clip's url as `video`. Read its `notes` first (some refuse a clip they did not make, or refuse from certain regions) and its `takes`: an extension can add a fixed number of seconds whatever `seconds` says. If its `takes.parameters` list `task`, send `parameters: {"task": "extend"}`, or the clip is treated as one to edit. This way is the less dependable of the two, so say that before trying it.
6. **The prompt** says only what happens next, starting from the motion already under way: the same camera move at the same speed, then the change. Say what stays: the same people, clothes, place, light and style.
7. **Check the join.** Ask the user to play the old clip and then the new one: it should carry on from where the old one ended, at the same speed. If the new clip starts the scene again, the model used the old clip as a loose reference: say so, and try another way rather than the same model again. Ask too whether the result holds the whole clip or only the new part.
8. **If nothing can extend it,** offer the two fallbacks plainly: remake the whole action as one longer clip, or start a new clip from the old one's last frame (the user exports that frame from their editor) and hide the join under a cut to another angle or on a moment of stillness.

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
