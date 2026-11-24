---
name: animate-photo
description: >
  Animate a photo, bring a picture to life, living photo, photo to video. Use
  when the user wants an image they have to move, with or without a set
  ending. To make a clip they already have longer use continue-shot; for a
  product ad use product-ad.
category: media
metadata:
  version: "2026-11-23"
---

# Animate my photo

Bring a still photo to life as a short clip, keeping the picture as it is.

**Not for:** extending a video (`continue-shot`), or a clip from words alone (`opper-media`).

Uses only the Opper Media tools: no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Photo** (required): The photo: a link, an upload, or an image made earlier in the chat.
- **Motion**: What should move, such as hair in the wind, a slow zoom, or the person smiles and waves.
- **Length**: Seconds.

## Steps

1. **Look first.** In one message: say what the photo shows, or ask if it came as a link you cannot see; say the motion you will make (suggest one if they gave none) and whether you will lock the ending (step 4); and ask the length, five seconds if they give none or leave it to you. Wait for the user's OK on the motion, unless they have left it to you. For real people, the People rule applies: ask once, not per photo. For a batch of photos, agree the motion once and run them all without a stop for each.
2. **Pick a video model** whose `inputs` list `image`, and `last_image` if you will lock the ending. Read its `notes` for what it refuses (some refuse real people) and its `takes` for lengths and resolutions. A photo that should speak a line is another kind of model: make the line with `generate_speech` first, then pass photo and line to one whose `inputs` list `image` and `audio` (search "lip sync"; `needs` says what it cannot work without).
3. **Do not describe the picture again:** the photo is the first frame, passed as `image`. The prompt (rules: Clip prompts) is the motion and the camera. Write motion as physics: wind-up, movement, settle; hair and cloth lag a moment behind. Say what stays: the same people, faces and clothes, or for scenery the same things in the same shapes and light, the same art style, and nothing new entering.
4. **Lock the ending only when it must be exact** (eyes closed, turned to camera, a door open). A simple action that fits in the length (a sip and a smile) needs no end frame. Make the last frame by editing the photo with `generate_image` on a model with `image_edit` in `can` (the photo as `image`, "same photo, a moment later: ..."), show it and wait for the user's OK, then pass it as `last_image` to a video model whose `inputs` list `last_image`.
5. **Make it** at 720p and the agreed length, saying the model, length and resolution in one line first. A lower draft comes first only for a long or risky motion (many seconds, several people, a big change), and then the final is a new take.
6. **Deliver** the link with the checklist. Offer what is next in one line: another motion, a longer take with `continue-shot`, another model.

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
