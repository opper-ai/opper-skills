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

1. **Series bible.** If none was given, write one and show it: one fixed sentence per character (face, hair, build, clothes, colours), a style line, a palette as hex values, and the light for each part of the story. These sentences go word for word into every still and clip prompt, in this episode and later ones.
2. **Character sheets.** For each character make one sheet with `generate_image`: front, three-quarter, profile and full body on a plain background, in the series style. Invented characters only, unless the user confirms a real person agreed. Show the sheets and fix them by editing (the sheet as `image`, on a model with `image_edit` in `can`).
3. **Shot list:** four to eight shots of three to five seconds, each with what we see, its beat in the story, one camera move, and any spoken line with who says it. Show it before making frames.
4. **Stills.** For each shot, a first frame made with the sheets as `reference_images` (a model with `image_edit` in `can`). Where a shot must end somewhere else, make its last frame by editing the first ("same shot, a moment later: ..."). Show all the frames together before any clip is made.
5. **Clips.** Pick a video model whose `inputs` list `image` (and `last_image` where a shot has a last frame); read its `notes` if the characters look like real people. Pass each first frame as `image`. Write each prompt as a timed script: starting state; what happens at which second; one camera move; what must remain unchanged (the bible sentences, two arms and five fingers on each hand); "one continuous shot"; the sound line. A spoken line goes in as the character's name, the action, then the line in quotes, on a model that makes sound.
6. **Sheets as references in a clip.** A model whose `inputs` list `reference_images` can take the sheets too, which helps when a character enters after the first frame. If the model refuses frames and references together, drop the references: the first frame already carries the character.
7. **Draft one clip,** show it, then make the rest.
8. **Deliver** the shots in order with their links as an edit list: these tools do not join them. Give the user the bible and the sheet links to keep for the next episode; links stop working at their `expires_at`, so the user should save the sheets.

## Rules for every step

- **Models come from the list.** Call `list_media_models` (with `type`, or `search` for a name, maker or task) and read a model's row before using it: `can` (what it does), `inputs` (the files a video model takes), `takes` (lengths, resolutions, shapes, `parameters`) and `notes` (what it refuses or always does). Start from a recommended model. Never assume a model id, a length or a limit.
- **Draft first.** Shortest length, lowest resolution, one or two stills, so the user sees the idea sooner. Raise quality once they like it.
- **Before a long or high-resolution video,** say in one line which model, length and resolution you are about to use, then go.
- **Shape.** Pass `aspect_ratio` where the model lists `aspect_ratios`, or a `size` of that shape where it lists `sizes`. A clip made from an image takes the image's shape: make the still in the final shape and leave `aspect_ratio` out of the video call.
- **Show every result** by its `url` as soon as it lands. While a job is `processing`, say so and follow it with `get_media_job`. If a call times out with no answer, look in `list_media_jobs` before trying again: the job may have run. A link works until its `expires_at`.
- **You cannot watch a clip.** You see stills, not video or sound, so ask the user to check what matters in each clip and say what to look for.
- **The user's own files.** A public https link works everywhere. For a file on their device, call `create_upload_link`, do what its `next` says, and pass its `upload_id` where the file goes. Where a tool has a `_file` field (such as `image_file`), a chat attachment goes there instead.
- **No words in generated pictures.** Generators garble letters: titles, logos, captions and interface text are added in the user's editor.
- **Sound.** If the model makes sound (`audio` in `can`), name only the sounds the scene makes, in order ("Diegetic sound only: ..."), with no music or instrument words. For a silent clip, look in `takes.parameters` for the model's sound switch; `notes` say when sound cannot be turned off.
- **Joining.** These tools make stills, clips, voice and subtitle files. They do not join them. A piece of several parts ends as an ordered edit list for the user's video editor, so promise no finished film. An assistant that can run commands on the user's computer can assemble the file there.
- **People.** Anyone shown or voiced must have agreed to it. `notes` say which models refuse real people.
- **One change per retake.**
