# Scenarios

At least three per skill: the plain case, a harder one, and a request that belongs to a neighbouring skill. How to run and score them is in [README.md](./README.md).

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

### 4. From a photo

**Request:** "Turn this product photo into an ad for Instagram: https://example.com/mug.jpg"

**Good:**

- One message of questions at most: what must stay exact, the length, the sound, with two or three directions and a recommendation.
- A shot list of three or four shots where something happens (an action, hands, the product in use), shown first.
- A hero still made with the photo as `reference_images` on a model with `image_edit`, in 9:16, shown before any video.
- The whole ad as one clip, with the photo and the hero still as `reference_images`, each shot with its seconds in the prompt.
- The final at 720p on a model that takes `reference_images` and makes sound, named in one line, and a line of next steps after it (a take on another model among them).

**Bad:**

- One slow push-in on a still product and nothing else.
- Starts a video before the shot list and the still are approved.
- Puts a headline or logo into the generated picture.
- Talks about what anything costs without being asked.

### 5. Longer than one clip

**Request:** "A 45 second ad for my running shoes, with a shot that ends exactly on this packshot: https://example.com/shoe.jpg"

**Good:**

- Says why it goes clip by clip: the length, and the frame a shot must end on.
- All first frames shown together before any clip; the packshot as `last_image` on its shot.
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
- Asks the length with the motion (five seconds if the user leaves it open) and makes the clip at 720p.

**Bad:**

- Describes the whole picture again in the prompt.
- Adds new people or objects.

### 11. A set ending

**Request:** "Make my portrait turn and smile at the camera at the end."

**Good:**

- Asks once whether the person agreed, if a real person is shown and the user has not said the photo is cleared.
- Because the ending must be exact, makes the last frame by editing the photo, shows it, then passes it as `last_image` on a model whose `inputs` list `last_image`.
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

- Keeps the user's words, and also gives the whole script as one file, since the piece is sound only.
- Asks one short question on the voice (man or woman, younger or older), since the read is given, then uses `fish/drama-3` with a cast voice id that fits.
- Sends the text with no direction: a calm, plain read needs none.
- After delivering, offers a second take: another voice, a stronger or lighter read, or the same line on the other model.
- Delivers the audio by its link.

**Bad:**

- Rewrites the script unasked.
- Searches a public voice library, or picks a voice whose name or id is a real person's.
- Adds one-word tags like `[calm]`.

### 14. Narration timed to a clip

**Request:** "I need a voiceover for a 20 second clip of our new office, in Swedish."

**Good:**

- Writes about 50 words with start times per line and shows the script first.
- Asks the one question on the read and the voice with the script; for a language the cast does not suit, calls `list_voices` with the language on the other model.
- One file per line, in a format the model lists.

**Bad:**

- Writes far more words than 20 seconds hold.
- Renders the whole script as one take without lines.

### 15. An acted line

**Request:** "A 10 second trailer line, dramatic, ending in a whisper: They said the lighthouse was empty. They were wrong."

**Good:**

- Asks only what is missing (man or woman, younger or older): the read is given.
- Uses `fish/drama-3` with a cast voice id that fits a trailer, and says which model and voice.
- Directs in plain language in square brackets before the words, with the whisper on the last words, and keeps the directions out of the script it shows.
- Measures the take against 10 seconds, then offers a second take, among them the same line on the other model.

**Bad:**

- Sends the bare words and hopes for drama.
- One-word tags like `[dramatic]`, or several directions stacked in one short line.
- Reads the directions back as part of the script.

### 16. Belongs to a neighbour

**Request:** "Make a video of a woman saying this line to the camera."

**Good:**

- Hands over to `creator-ad`.

**Bad:**

- Makes audio only.

## `creator-ad`

### 17. An invented presenter

**Request:** "A creator-style ad for my reusable water bottle, 15 seconds, for Reels."

**Good:**

- One short message asking only what is open: the voice, whether one that sounds like it is fine, and yes or no to captions, on-screen text and music.
- Picks the one-clip recipe, and shows a script in the shape of an ad at about 2.5 words a second.
- A short voice sample, and a presenter still made on the image model the video model's notes name; the user approves the still.
- One clip with the still in `reference_images` and the sample in `reference_audios`, no first frame; every shot in the prompt has a place, an action, a line in quotes and its sounds, and there is one music line or "no music".
- Says the model speaks the words anew in that voice, and that these tools do not add captions or titles.

**Bad:**

- Gives a speech file to a video model without `lip_sync` in `can`.
- A presenter who only stands and talks in every shot.
- Adds captions or on-screen text nobody asked for.

### 18. An exact voice file

**Request:** "A creator-style ad for my steel bottle. Our voice actor recorded the voiceover, use exactly this file: https://example.com/vo.mp3"

**Good:**

- Picks the avatar recipe; transcribes the recording to learn its words and length.
- A still framed chest-up, facing the camera, product low and away from the face, mouth closed.
- One talking take for the whole recording on one still, on a model with `lip_sync` in `can`, with no prompt asking for walking or a new scene.
- Product cutaways as one clip with natural sound, no speech and no music; placed in the edit list by the words spoken.
- Ends in an edit list (in a chat app), with levels for music and cutaway sound, and promises no finished film.

**Bad:**

- Makes a new voice, or lets a video model speak the words itself.
- A new background for every shot of the presenter.
- Adds room tone under the talking clip.

### 19. A real person

**Request:** "Use my own photo as the presenter: https://example.com/me.jpg"

**Good:**

- Asks that the person agreed.
- Picks the avatar recipe: the one-clip model's notes say it refuses photos of real people.

**Bad:**

- Goes ahead on a model whose notes say it refuses real people.

### 20. Belongs to a neighbour

**Request:** "A 15 second ad of my watch on a rotating stand, no people."

**Good:**

- Hands over to `product-ad`.

**Bad:**

- Invents a presenter.

## `narrated-explainer`

### 21. A topic

**Request:** "A 30 second explainer on how tides work, flat vector look."

**Good:**

- A brief before any script, in one message: it proposes drawings with motion only where it explains (the look is given), names the other kinds of pictures, asks stills, a mix or clips, the shape, the voice and roughly how many shots, and says what will be reviewed and in which order.
- A script of about 55 words as a shot table, shown before anything is made.
- Voice before pictures, one file per line, each measured.
- A hero still for the look, then every still beside its line as a storyboard, approved before any clip.
- One draft clip, then one line with how many final clips (the drafted shot too), the model, the length and the resolution, and a wait for the go.
- With a shell, looks at a diagram still at full size before the storyboard, and checks a strip of frames from each clip as it lands, before the join.
- Clips as long as their line plus half a second, rounded up; a drawn look is made silent.
- In a chat app, ends with an edit list and promises no finished film; subtitles only as an offer.

**Bad:**

- Writes the script before the brief, or asks open questions with nothing proposed.
- Makes clips before the storyboard is approved, or a draft for every clip.
- Asks about the voice again after the brief was accepted.
- Puts labels or numbers into generated pictures.
- Quotes what the clips will cost.

### 22. A walkthrough of screenshots

**Request:** "Make a walkthrough of my app from these five screenshots."

**Good:**

- Never sends a screenshot to an image or video model.
- One line per screen using the labels on the screen.
- Generated media only for the voice and the opening and closing pictures.

**Bad:**

- Restyles or animates a screenshot.
- Describes a feature the screens do not show.

### 23. Belongs to a neighbour

**Request:** "Episode two of my cartoon about the two robots."

**Good:**

- Hands over to `series-episode` and asks for the bible from episode one.

**Bad:**

- Writes a narrated explainer about robots.

## `series-episode`

### 24. A first episode

**Request:** "Episode one of a claymation series about two rival bakers, four shots."

**Good:**

- A series bible with a fixed sentence per character and for the place, shown with the shot list.
- A character sheet per character, shown and fixed by editing.
- First frames made with the sheets as `reference_images`, shown together before any clip; a character who comes in later gets a last frame, not a sheet passed to the clip.
- The hardest clip drafted before the rest.
- Ends with the shots in order, the bible and the sheet links to keep.

**Bad:**

- Describes a character in different words from one prompt to the next.
- Promises one joined film.

### 25. A next episode

**Request:** "Here is my series bible and the sheet links. Make episode two."

**Good:**

- Uses the given bible word for word and the given sheets as references.
- Says so if a sheet link has stopped working, and asks for the saved file.

**Bad:**

- Writes a new bible.

### 26. Belongs to a neighbour

**Request:** "One 6 second clip that goes from this first frame to this last frame."

**Good:**

- Hands over to `storyboard-film`.

**Bad:**

- Writes a series bible for it.

## `storyboard-film`

### 27. Three keyframes

**Request:** "A 6 second film: a paper boat is set on a stream, drifts under a bridge, comes out into sunlight. Watercolour, 16:9."

**Good:**

- A storyboard table with a time per keyframe, shown first.
- Keyframes made as stills, each later one by editing the one before, shown together in order.
- Reads the video rows for `last_image` in `inputs` and `middle_frames` in `takes.parameters`, and picks the path that fits.
- A prompt written as a timed script, and a draft at the lowest resolution.

**Bad:**

- Goes straight to video from the words.
- Assumes a model takes middle frames without reading its row.

### 28. Two keyframes

**Request:** "From this first frame to this last frame in 4 seconds."

**Good:**

- A model whose `inputs` list `last_image`; first as `image`, last as `last_image`.

**Bad:**

- Regenerates the frames the user gave.

### 29. Belongs to a neighbour

**Request:** "Keep going with that clip, I want to see what happens next."

**Good:**

- Hands over to `continue-shot`.

**Bad:**

- Starts a new storyboard.

## `continue-shot`

### 30. A clip made earlier in the chat

**Request:** "Continue that clip a few more seconds: the kite dips, loops and climbs again."

**Good:**

- Finds which model made the clip.
- Picks a model with `video_extension` in `can`, preferring the one that made it, and reads its `notes` and `takes`.
- Passes the clip's link as `video`, with `task` set to extend where the row lists `task`.
- Checks the join and says whether the result is the whole clip or only the new part.

**Bad:**

- Starts a new clip from a still of the last frame without saying why.
- Repeats the same model after it restarted the scene.

### 31. Nothing can extend it

**Request:** "Extend this clip from my phone: https://example.com/phone.mp4"

**Good:**

- Reads `notes` about uploaded clips and regions.
- If no model can extend it, says so and offers the two fallbacks.

**Bad:**

- Claims the motion will carry over when the clip was used only as a reference.

### 32. Belongs to a neighbour

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
