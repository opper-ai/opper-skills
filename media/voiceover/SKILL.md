---
name: voiceover
description: >
  Voiceover, narration, voice track, read this aloud, radio ad, podcast intro.
  Use when the user wants spoken audio from a script, or narration timed to a
  clip. For a presenter who speaks on camera use creator-ad; for narration
  with pictures use narrated-explainer.
category: media
metadata:
  version: "2026-11-23"
---

# Voiceover

Narration that fits a clip or a script: a voice that suits the read, directed where it needs it, and one audio file per line.

**Not for:** a talking person on screen (`creator-ad`), or a whole explainer with pictures (`narrated-explainer`).

Uses only the Opper Media tools: no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Script** (required): The script to read, what the piece should say, or what the clip shows (or a link to it).
- **Length**: Length in seconds.
- **Voice**: The voice and the kind of read, such as a calm older man, an upbeat young woman, or a dramatic trailer read.

## Steps

1. **Script.** Keep the user's words if they gave a script. Otherwise write one to length: warm, full sentences, punctuation as the direction, numbers written as they are said. Ask for the names and facts it needs, or mark them as placeholders. Split a longer script into lines (a short piece, up to about 15 seconds, is one line and one file); where there is a clip, each line lands on a moment in it and gets a start time. Ask for the OK on a script you wrote (words the user gave need none) and, in the same message, the one question on the read and the voice (rules: Voices), and wait. If the clip already has speech to replace or translate, `transcribe_audio` (an stt model, `format` segments) gives its words with their times.
2. **Voice and model,** as the Voices rule says: the default model and a cast voice that fits the role, or the other model where the read needs it. Say in one line which model and voice you will use. A user who wants to choose by ear gets up to three different voices on the real first line, and picks.
3. **Direct the read** where the script calls for it (rules: Directing a read), in the way the chosen model takes. The directions go only into the text sent to `generate_speech`: the script the user reads stays clean, with a note of how each directed line is meant to sound.
4. **Render one file per line** with `generate_speech` and the chosen voice, so one line can be redone on its own; a first take the user liked can stay. Use a format from the model's `takes.formats` (mp3 where it is listed, unless the user's editor wants another). Measure each line (rules: Voice first). If the piece runs long, move the start times first, then shorten words; if it runs short, add words. Where the user's own words are fixed, change the pace by a direction (slower, or brisker), then by pauses, one change a take. Change `speed` only a little, as a last resort, and not on a model the rules say has no speed setting.
5. **A piece that is sound only** (a radio ad, a podcast intro) also gets the whole script as one file: that is the finished piece, and its measured length is the one that must fit. Render it first. These tools make no music: say so if the piece wants some.
6. **Deliver** the links in order, with each line's start time if there is a clip, and say how to place them: on the clip's timeline at those times, with any music lowered under the voice. Then offer the second take in one line.

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
