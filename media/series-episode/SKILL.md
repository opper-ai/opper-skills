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

1. **Series bible.** If none was given, write one and wait for the user's OK on it: one fixed sentence per character (face, hair, build, clothes, colours), a style line, a palette as hex values, and the light for each part of the story. These sentences go word for word into every still and clip prompt, in this episode and later ones.
2. **Character sheets.** For each character make one sheet with `generate_image`: front, three-quarter, profile and full body on a plain background, in the series style. Invented characters only, unless the user confirms a real person agreed. Show the sheets, fix them by editing (the sheet as `image`, on a model with `image_edit` in `can`), and wait for the user's OK.
3. **Shot list:** four to eight shots of three to five seconds, each with what we see, its beat in the story, one camera move, and any spoken line with who says it. Wait for the user's OK before making frames.
4. **Stills.** For each shot, a first frame made with the sheets as `reference_images` (a model with `image_edit` in `can`). Where a shot must end somewhere else, make its last frame by editing the first ("same shot, a moment later: ..."). Show all the frames together and wait for the user's OK before any clip is made.
5. **Clips.** Pick a video model whose `inputs` list `image` (and `last_image` where a shot has a last frame), letting the hardest shot decide; read its `notes` if the characters look like real people. Pass each first frame as `image`. Write each prompt as the Clip prompts rule says; what must stay the same is the bible sentences, and two arms and five fingers on each hand. A spoken line goes in as the character's name, the action, then the line in quotes, on a model that makes sound.
6. **Sheets as references in a clip.** A model whose `inputs` list `reference_images` can take the sheets too, which helps when a character enters after the first frame. If the model refuses frames and references together, drop the references: the first frame already carries the character.
7. **Draft one clip,** show it and wait for the user's word, then make the rest.
8. **Deliver** the edit list (rules: Joining): these tools do not join the shots. Give the user the bible and the sheet links to keep for the next episode; links stop working at their `expires_at`, so the user should save the sheets.

## Rules for every step

- **Models come from the list.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row before using it: `can`, `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`) and `notes` (what it refuses or always does). Start from a recommended model; never assume an id, a length or a limit.
- **Draft first:** shortest length, lowest resolution, one or two stills. Before a long or high-resolution video, say in one line which model, length and resolution you will use, and wait for the user's go.
- **Shape.** Pass `aspect_ratio` where the model lists `aspect_ratios`, else a `size` of that shape (its `size_constraints` say which sizes it takes). A clip made from an image takes the image's shape, so leave `aspect_ratio` out of that call.
- **Clip prompts.** One continuous shot per clip, written the same way every time: the starting state; what happens, second by second; one camera move, or "locked off"; what must stay the same; the sound line. For several clips, show all the prompts once before making the first.
- **Sound.** Where a model makes sound (`audio` in `can`), name only the sounds the scene makes, in order ("Diegetic sound only: ..."), with no music words. A sound switch, if the model has one, is in `takes.parameters`.
- **Results.** Show each by its `url` as it lands; a link works until its `expires_at`. While a job is `processing`, say so and follow it with `get_media_job`. After a call that times out, look in `list_media_jobs` before trying again.
- **You cannot watch a clip.** Give the user a short checklist with each one: a cut in the middle, people or things nobody asked for, a product or prop that changes, and what the shot was for. `transcribe_audio` on a clip checks its spoken words.
- **Voices.** Ask whether the user knows the voice they want. If not, offer three clearly different ones (say warm storyteller, bright and energetic, calm and authoritative), matched by you on each voice's name, gender and accent, since `list_voices` filters by language only. Render the same first line in each and wait for the pick. Make the voice before the pictures and time the shots to it: `transcribe_audio` on a take reports its `duration`, which `generate_speech` does not.
- **The user's own files.** A public https link works. For a file on their device, call `create_upload_link`, do what its `next` says and pass its `upload_id`; where a tool has a `_file` field, a chat attachment goes there.
- **No words in generated pictures:** titles, logos, captions and interface text are added in the user's editor.
- **Joining.** These tools do not join clips. A piece of several parts ends as an edit list for the user's video editor: per shot its link, the seconds to keep, the on-screen text to add, and how it hands over to the next shot. Promise no finished film.
- **People.** Anyone shown or voiced must have agreed. Ask once per piece of work, never per picture, and not when the user says the material is cleared or the person was made earlier in this work. `notes` say which models refuse real people.
- **The user decides.** Where a step says to wait, stop until they answer; a render that worked is not approval. Change one thing per retake.
