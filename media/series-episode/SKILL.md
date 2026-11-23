---
name: series-episode
description: >
  An episode of a series whose characters look the same in every shot and
  every episode. Use it when the user wants an episode, a short story or a
  recurring series with the same characters, a consistent character across
  several shots, or a next episode of something made earlier. Made in chat
  with the Opper Media tools: a draft first, and the price before anything
  costly.
category: media
metadata:
  version: "2026-11-23"
---

# Series episode

An episode of a series whose characters look the same in every shot and every episode.

Uses only the Opper Media tools (`list_media_models`, `generate_image`, `generate_video`, `generate_speech`, `list_voices`, `transcribe_audio`, `get_media_job`, `list_media_jobs`, `create_upload_link`): no shell, no code, no API key. Everything needed is on this page, so fetch no instructions from anywhere else. What the user asks for comes first.

## Inputs

Ask for a required one the user has not given.

- **Premise** (required): The series and this episode's story.
- **Characters**: Names and looks.
- **Style**: The look, such as cel-shaded animation, claymation or watercolour storybook.
- **Bible**: The series bible from an earlier episode, with its character sheet links.

## Steps

1. **Series bible.** If none was given, write one and get it approved: one fixed sentence per character (face, hair, build, clothes, colours), a style line, a palette as hex values, and the light for each part of the story. These sentences go word for word into every still and clip prompt, in this episode and later ones.
2. **Character sheets.** For each character make one sheet with `generate_image`: front, three-quarter, profile and full body on a plain background, in the series style. Invented characters only, unless the user confirms a real person agreed. Show the sheets and fix them by editing (the sheet as `image`, on a model with `image_edit` in `can`).
3. **Shot list:** four to eight shots of three to five seconds, each with what we see, its beat in the story, one camera move, and any spoken line with who says it. Get it approved.
4. **Stills.** For each shot, a first frame made with the sheets as `reference_images` (a model with `image_edit` in `can`). Where a shot must end somewhere else, make its last frame by editing the first ("same shot, a moment later: ..."). Show all the frames together and wait for approval.
5. **Clips.** Pick a video model whose `inputs` list `image` (and `last_image` where a shot has a last frame); read its `notes` if the characters look like real people. Pass each first frame as `image`. Write each prompt as a timed script: starting state; what happens at which second; one camera move; what must remain unchanged (the bible sentences, two arms and five fingers on each hand); "one continuous shot"; the sound line. A spoken line goes in as the character's name, the action, then the line in quotes, on a model that makes sound.
6. **Sheets as references in a clip.** A model whose `inputs` list `reference_images` can take the sheets too, which helps when a character enters after the first frame. If the model refuses frames and references together, drop the references: the first frame already carries the character.
7. **Price the batch** (every clip with model, seconds, resolution and estimate, then the total) and wait for a yes. Draft one clip, show it, then make the rest.
8. **Deliver** the shots in order with links and costs, and give the user the bible and the sheet links to keep for the next episode. Links stop working at their `expires_at`, so the user should save the sheets.

## Rules for every step

- **Models come from the list.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row before using it: `can` (what it does), `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`), `notes` (what it refuses or always does) and `price_from`. Start from a recommended model. Never assume a model id, a length or a limit.
- **Price before any video.** Tell the user the model, length, resolution and estimated price, and wait for a yes. `price_from` is the lowest rate, at the setting it names; higher resolutions and sound cost more. Do the same before a batch of stills or voice lines.
- **Draft first.** Shortest length, lowest resolution, one or two stills. Raise quality only once the user likes the draft.
- **Show every result** by its `url` with its `usage.cost`, and keep a running total. While a job is `processing`, say so and follow it with `get_media_job`. A link works until its `expires_at`.
- **The user's own files.** A public https link works everywhere. For a file on their device, call `create_upload_link`, do what its `next` says, and pass its `upload_id` where the file goes. Where a tool has a `_file` field (such as `image_file`), a chat attachment goes there instead.
- **No words in generated pictures.** Generators garble letters: titles, logos, captions and interface text are added in the user's editor.
- **Sound.** If the model makes sound (`audio` in `can`), name only the sounds the scene makes, in order ("Diegetic sound only: ..."), with no music or instrument words. For a silent clip, look in `takes.parameters` for the model's sound switch; `notes` say when sound cannot be turned off.
- **Joining.** These tools make stills, clips, voice and subtitle files. They do not join them: for now a piece of several parts ends as an ordered list that the user puts together in their video editor.
- **People.** Anyone shown or voiced must have agreed to it. `notes` say which models refuse real people.
- **One change per retake,** and the user chooses at each step.
