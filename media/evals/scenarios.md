# Scenarios

Three per skill: the plain case, a harder one, and a request that belongs to a neighbouring skill. How to run and score them is in [README.md](./README.md).

## `opper-media`

### 1. A single image

**Request:** "Make me a picture of a lighthouse at dusk, wide."

**Good:**

- Calls `list_media_models` and uses a recommended image model.
- One `generate_image` call in a wide shape, and the result shown by its link.
- Offers a next step, such as animating it.

**Bad:**

- Asks more than one question before making anything.
- Names a model id that is not in the list's answer.

### 2. A request that has a recipe

**Request:** "I need a video ad for my candle brand."

**Good:**

- Recognises the product ad and follows that recipe (brief first, then a hero still).
- Does not start a video before a still is approved.

**Bad:**

- Improvises a single clip from the words alone.

### 3. Subtitles for a clip

**Request:** "Can you make subtitles for this video? https://example.com/clip.mp4"

**Good:**

- Picks an stt model from `list_media_models` and calls `transcribe_audio` with `format` srt.
- Gives the subtitle file's link.

**Bad:**

- Says it cannot transcribe.
- Generates anything.

## `product-ad`

### 4. One shot from a photo

**Request:** "Turn this product photo into a short ad for Instagram: https://example.com/mug.jpg"

**Good:**

- One message of questions at most, with two or three directions and a recommendation.
- A hero still made with the photo as `reference_images` on a model with `image_edit`, in 9:16, shown before any video.
- A draft clip at the shortest length and lowest resolution, from the approved still as `image`.
- Says what the editor adds: logo, headline, call to action.

**Bad:**

- Starts a video before the still is approved.
- Puts a headline or logo into the generated picture.
- Talks about what anything costs without being asked.

### 5. Several shots

**Request:** "A 15 second ad for my running shoes, three or four shots."

**Good:**

- Writes a shot list with seconds, job and one camera move per shot, and shows it first.
- Fixed sentences for the product and the look, reused in every prompt.
- All first frames shown together before any clip; one draft shot before the rest.
- Ends with an edit list and says the shots are joined in the user's editor.

**Bad:**

- Promises one finished film.
- Uses a different video model for each shot without a reason.

### 6. Belongs to a neighbour

**Request:** "I want someone on camera telling people why they love my protein bar."

**Good:**

- Hands over to `creator-ad`.

**Bad:**

- Makes a product ad with no speaker.

## `product-photos`

### 7. A set from one photo

**Request:** "I need nicer photos of this lamp for my shop: https://example.com/lamp.jpg"

**Good:**

- Two or three directions offered, one still each, the lamp kept exactly as in the photo.
- Asks how many stills, or says it will make three. After the pick: that many, shown together (for three: clean, in use, detail).
- Fixes by editing the chosen still, one change at a time.

**Bad:**

- Changes the product's shape, colour or label.
- Regenerates from scratch to fix a detail.

### 8. From a description only

**Request:** "Product shots of a matte black water bottle, no photo yet."

**Good:**

- Says the stills are an illustration of the description, since there is no photo to hold to.
- Keeps one fixed sentence for the product across the set.

**Bad:**

- Asks for a photo and stops.

### 9. Belongs to a neighbour

**Request:** "A YouTube thumbnail about my trip to Norway."

**Good:**

- Treats it as a cover (the start-here skill's lane), not as product photos.

**Bad:**

- Asks which product it is for.

## `animate-photo`

### 10. Plain animation

**Request:** "Animate this photo of a lake, gentle wind: https://example.com/lake.jpg"

**Good:**

- A video model whose `inputs` list `image`; the photo passed as `image`.
- A prompt that describes only motion and camera, one move, one shot.
- A draft at the shortest length and lowest resolution first.

**Bad:**

- Describes the whole picture again in the prompt.
- Adds new people or objects.

### 11. A set ending

**Request:** "Make my portrait turn and smile at the camera at the end."

**Good:**

- Asks once whether the person agreed, if a real person is shown and the user has not said the photo is cleared.
- Makes the last frame by editing the photo, shows it, then passes it as `last_image` on a model whose `inputs` list `last_image`.
- Reads the model's `notes` about real people.

**Bad:**

- Uses a model whose notes say it refuses real people.

### 12. Belongs to a neighbour

**Request:** "Make this clip ten seconds longer: https://example.com/clip.mp4"

**Good:**

- Hands over to `continue-shot`.

**Bad:**

- Treats the clip as a still.

## `voiceover`

### 13. A script to read

**Request:** "Read this in a calm voice: Welcome to the harbour tour. We leave in five minutes."

**Good:**

- Keeps the user's words.
- Asks whether the user knows the voice they want; if not, offers three clearly different voices on the first sentence and waits for the pick.
- Delivers the audio by its link.

**Bad:**

- Rewrites the script unasked.
- Picks a voice without an audition.

### 14. Narration timed to a clip

**Request:** "I need a voiceover for a 20 second clip of our new office, in Swedish."

**Good:**

- Writes about 50 words with start times per line and shows the script first.
- Calls `list_voices` with the language; switches model if none fits.
- One file per line, in a format the model lists.

**Bad:**

- Writes far more words than 20 seconds hold.
- Renders the whole script as one take without lines.

### 15. Belongs to a neighbour

**Request:** "Make a video of a woman saying this line to the camera."

**Good:**

- Hands over to `creator-ad`.

**Bad:**

- Makes audio only.

## `creator-ad`

### 16. An invented presenter

**Request:** "A creator-style clip recommending my reusable water bottle, 10 seconds, vertical."

**Good:**

- A script of one to three spoken sentences, shown first.
- A presenter still with an invented person, vertical unless told otherwise, approved before anything else.
- Speech made first, as one file, in a voice the user chose by ear.
- A video model whose `inputs` list `audio` and `image`; the still as `image` and the speech link as `audio`.
- The result transcribed and compared with the script; a subtitle file delivered.

**Bad:**

- Relies on a video model to speak a line written in its prompt.
- Uses a real person's face without asking about consent.

### 17. A real person

**Request:** "Use my own photo as the presenter: https://example.com/me.jpg"

**Good:**

- Asks that the person agreed.
- Reads `notes` and avoids a model that refuses real people.

**Bad:**

- Goes ahead on a model whose notes say it refuses real people.

### 18. Belongs to a neighbour

**Request:** "A 15 second ad of my watch on a rotating stand, no people."

**Good:**

- Hands over to `product-ad`.

**Bad:**

- Invents a presenter.

## `narrated-explainer`

### 19. A topic

**Request:** "A 30 second explainer on how tides work, flat vector look."

**Good:**

- A script of about 75 words as a shot table, shown first.
- Voice before pictures: an audition, then one file per line.
- A hero still shown, then the other stills made with it as `reference_images` and shown together.
- Says whether the pictures are stills, a mix or clips (a mix unless told otherwise), with one draft clip first.
- Ends with an edit list and says plainly that the parts are joined in the user's editor.

**Bad:**

- Promises a finished video file.
- Generates clips for every shot by default.
- Puts labels or numbers into generated pictures.

### 20. A walkthrough of screenshots

**Request:** "Make a walkthrough of my app from these five screenshots."

**Good:**

- Never sends a screenshot to an image or video model.
- One line per screen using the labels on the screen.
- Generated media only for the voice and the opening and closing pictures.

**Bad:**

- Restyles or animates a screenshot.
- Describes a feature the screens do not show.

### 21. Belongs to a neighbour

**Request:** "Episode two of my cartoon about the two robots."

**Good:**

- Hands over to `series-episode` and asks for the bible from episode one.

**Bad:**

- Writes a narrated explainer about robots.

## `series-episode`

### 22. A first episode

**Request:** "Episode one of a claymation series about two rival bakers, four shots."

**Good:**

- A series bible with a fixed sentence per character, shown first.
- A character sheet per character, shown and fixed by editing.
- A shot list, then first frames made with the sheets as `reference_images`, shown together before any clip.
- One draft clip before the rest.
- Ends with the shots in order, the bible and the sheet links to keep.

**Bad:**

- Describes a character in different words from one prompt to the next.
- Promises one joined film.

### 23. A next episode

**Request:** "Here is my series bible and the sheet links. Make episode two."

**Good:**

- Uses the given bible word for word and the given sheets as references.
- Says so if a sheet link has stopped working, and asks for the saved file.

**Bad:**

- Writes a new bible.

### 24. Belongs to a neighbour

**Request:** "One 6 second clip that goes from this first frame to this last frame."

**Good:**

- Hands over to `storyboard-film`.

**Bad:**

- Writes a series bible for it.

## `storyboard-film`

### 25. Three keyframes

**Request:** "A 6 second film: a paper boat is set on a stream, drifts under a bridge, comes out into sunlight. Watercolour, 16:9."

**Good:**

- A storyboard table with a time per keyframe, shown first.
- Keyframes made as stills, each later one by editing the one before, shown together in order.
- Reads the video rows for `last_image` in `inputs` and `middle_frames` in `takes.parameters`, and picks the path that fits.
- A prompt written as a timed script, and a draft at the lowest resolution.

**Bad:**

- Goes straight to video from the words.
- Assumes a model takes middle frames without reading its row.

### 26. Two keyframes

**Request:** "From this first frame to this last frame in 4 seconds."

**Good:**

- A model whose `inputs` list `last_image`; first as `image`, last as `last_image`.

**Bad:**

- Regenerates the frames the user gave.

### 27. Belongs to a neighbour

**Request:** "Keep going with that clip, I want to see what happens next."

**Good:**

- Hands over to `continue-shot`.

**Bad:**

- Starts a new storyboard.

## `continue-shot`

### 28. A clip made earlier in the chat

**Request:** "Continue that clip a few more seconds: the kite dips, loops and climbs again."

**Good:**

- Finds which model made the clip.
- Picks a model with `video_extension` in `can`, preferring the one that made it, and reads its `notes` and `takes`.
- Passes the clip's link as `video`, with `task` set to extend where the row lists `task`.
- Checks the join and says whether the result is the whole clip or only the new part.

**Bad:**

- Starts a new clip from a still of the last frame without saying why.
- Repeats the same model after it restarted the scene.

### 29. Nothing can extend it

**Request:** "Extend this clip from my phone: https://example.com/phone.mp4"

**Good:**

- Reads `notes` about uploaded clips and regions.
- If no model can extend it, says so and offers the two fallbacks.

**Bad:**

- Claims the motion will carry over when the clip was used only as a reference.

### 30. Belongs to a neighbour

**Request:** "Make this photo move."

**Good:**

- Hands over to `animate-photo`.

**Bad:**

- Looks for a model with `video_extension`.

## Round record

Copy this for each round.

```text
Date:
Commit:
Agent and host:
Scenario | Pass or fail | What the agent made | What the skill got wrong
```
