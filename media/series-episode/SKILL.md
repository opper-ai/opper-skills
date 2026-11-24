---
name: series-episode
description: >
  Series episode, recurring characters, consistent character, short drama,
  animated short, next episode. Use when the user wants a story told in
  several shots with the same characters, or another episode of something made
  earlier. For one continuous piece that passes through set keyframes use
  storyboard-film.
category: media
metadata:
  version: "2026-11-23"
---

# Series episode

An episode of a series whose characters look the same in every shot and every episode.

**Not for:** a single clip through set keyframes (`storyboard-film`), or narration over pictures (`narrated-explainer`).

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Premise** (required): The series and this episode's story.
- **Characters**: Names and looks.
- **Style**: The look, such as cel-shaded animation, claymation or watercolour storybook.
- **Bible**: The series bible from an earlier episode, with its character sheet links.

## Steps

1. **Series bible and shot list,** shown together. The bible, if none was given: a title; one fixed sentence per character (face, hair, build, clothes, colours, size against the others), one for the place and one for the props that come back; a style line; a palette as hex values; the light for this episode; and, for a character who speaks, a line on their voice. The character, place and style sentences go word for word into every still and clip prompt, in this episode and later ones. The shot list: four to eight shots unless the user gives a number, each with what we see, its beat in the story, one camera move, and any spoken line with who says it. Read the video models first and pick one (its `inputs` list `image`, and `last_image` if a shot will need a last frame), so shot lengths and the shape are ones it can make. Wait for the user's OK on both.
2. **Character sheets.** For each character make one wide sheet with `generate_image`: full body from the front, three-quarter and side, and a close view of the face, on a plain background, in the series style. Invented characters only, unless the user confirms a real person agreed. Show the sheets, fix them by editing (the sheet as `image`, on a model with `image_edit` in `can`), and wait for the user's OK. Then correct the bible to what the approved sheets show: the sheets are what every later picture copies.
3. **Stills.** For each shot, a first frame in the clip's shape, with the sheets of the characters in it as `reference_images` (a model with `image_edit` in `can`); say in the prompt which reference is who. From the second shot on, add the first approved frame as a reference too, so the place and props hold. Where a shot ends in another framing or place, or a character comes in after the first frame, make its last frame by editing the first ("same shot, a moment later: ...", with the newcomer's sheet as a reference). Show all the frames together and wait for the user's OK before any clip is made.
4. **Clips,** on the video model picked in step 1; read its `notes` if the characters look like real people. Pass each first frame as `image` and each last frame as `last_image`. Write each prompt as the Clip prompts rule says; what must stay the same is the bible sentences, and for characters with hands, two arms and five fingers on each. A spoken line goes in as the character's name, the action, then the line in quotes, on a model that makes sound; such a line needs no voice audition (the Voices rule is for narration).
5. **Keep the sheets out of the clips.** A model whose `inputs` list `reference_images` can take a sheet in a clip call too, but the sheet can then turn up as a picture inside the clip. Prefer a last frame that shows the character. If you do pass a sheet, tell the user to look for it in the clip.
6. **Draft the hardest clip first,** show it and wait for the user's word, then make the rest. Ask the user to check each clip against the sheets.
7. **Deliver** the edit list (rules: Joining): these tools do not join the shots. Give the user the bible and the sheet links to keep for the next episode; links stop working at their `expires_at`, so the user should save the sheets and give them back by upload then.

## Rules for every step

- **Models.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row first: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `quality`, `notes`. Start from a recommended model, the first where two look alike. Never assume an id, a length or a limit.
- **Draft first,** unless the recipe says otherwise: the shortest length that fits the action, the lowest resolution. Before a long or high-resolution video, say the model, length and resolution in one line and wait for a go. A draft shows the idea, not the finish, and a final is a new take, not the draft made sharper: say both.
- **Shape.** `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (`size_constraints` say which it takes); on an edit, the picture's own size. A clip from an image takes its shape: leave `aspect_ratio` out. Ask where a place takes two shapes.
- **Clip prompts.** One continuous shot per clip unless the recipe puts several in one, always in this order: the starting state (do not describe a first frame again); what happens, in order, with seconds where timing matters; one camera move, or "locked off"; what must stay the same; the sound line. For several clips, show all the prompts once before the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds of the scene, in order ("Diegetic sound only: ..."), with no music words unless the recipe or the user asks for music. A sound switch, if any, is in `takes.parameters`: turn it on.
- **Results.** Show each by its `url` as it lands; it works until `expires_at`. A job that is `processing`: say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **What you can see.** Stills you make, at preview size, so fine detail is for the user to check. A picture the user links, a clip, or sound, no. So ask what a given picture shows and what must stay exact, and have the user check stills against it. With each clip give a short checklist: a cut in the middle, people or things nobody asked for, a product or prop that changes, whether it does what was asked. With a voice: a name said wrong, an odd pause, a clipped ending. `transcribe_audio` checks spoken words.
- **Voices.** Ask whether the user knows the voice they want. If not, offer three clearly different ones (say warm storyteller, bright and energetic, calm and authoritative) on the same first line, and wait for the pick. `list_voices` filters by language only: match on each voice's name, gender and accent yourself, on a speech model whose voice names describe the voice. Where a language has too few, try another model or offer fewer.
- **Voice first.** In a piece with a voice, make it before the pictures and time everything to it. Reading speed varies by voice and language: render, then measure with `transcribe_audio` (its `duration`; `generate_speech` gives none, and an stt model that answers in whole seconds is too coarse, so use another), adjust the words, and tell the user what changed.
- **The user's own files.** A public https link works. For a file on their device: `create_upload_link`, do what its `next` says, pass its `upload_id`. Where a tool has a `_file` field, a chat attachment goes there.
- **No words added to pictures:** titles, logos, captions and interface text go on in the user's editor. A product's own label stays.
- **Joining.** These tools do not join clips. Several parts end as an edit list for the user's video editor: per shot its link, the seconds to keep, the text to add on screen, the handover to the next shot, and what to do with sound across the cuts. Promise no finished film.
- **People.** Anyone real who is shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made in this work. `notes` say which models refuse real people.
- **The user decides.** Where a step says wait, stop until they answer; a render that worked is not approval. Two questions that come together go in one message. One change per retake. After a finished piece, offer in one line what more can be made from it.
