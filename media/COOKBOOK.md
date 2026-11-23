# Opper Media cookbook

Worked examples that chain the media skills. Each one starts from what a person says in a chat and names the skills that carry it. Nothing here is needed to use a skill: every skill stands on its own.

## 1. A product launch from one photo

**Say:** "Here is a photo of my new backpack. I need pictures for the shop and a short ad for Instagram."

1. `product-photos`: two or three directions, a pick, then the set of three (clean, in use, detail).
2. `product-ad`: the chosen still becomes the hero frame; one shot for a reel, or a shot list for a longer ad.
3. `voiceover`: one line over the ad, in a voice picked by ear.

**You end with:** three stills, one clip (or an edit list for several shots) and the voice files.

## 2. A creator-style clip with subtitles

**Say:** "Make a clip of someone recommending my tea, ten seconds, vertical."

1. `creator-ad`: the script, an invented presenter holding the product, a voice, then the talking clip.
2. The same skill transcribes the result, checks the line and gives a subtitle file.

**You end with:** one vertical clip with speech, and its subtitles.

## 3. An explainer for a feature

**Say:** "Explain how our booking flow works in 45 seconds. I have five screenshots."

1. `narrated-explainer`, walkthrough lane: one line per screen, in the words on the screen. The screenshots are never sent through a model.
2. The voice is made first, one file per line. An opening picture is generated; the screens stay as they are.

**You end with:** an edit list (screens, lines, voice files, how long each holds). The parts are joined in your video editor.

## 4. A story, then the next episode

**Say:** "A claymation series about two rival bakers. Make episode one."

1. `series-episode`: the series bible, a sheet per character, the shot list, frames, then clips.
2. Keep the bible and the sheets. For episode two, paste the bible and the sheet links into a new chat and ask for the next episode.
3. `continue-shot` when one shot should run longer.

**You end with:** the shots in order as an edit list, and a bible that makes the next episode match.

## 5. A film that hits set moments

**Say:** "Six seconds: a paper boat is set on a stream, drifts under a bridge, comes out into sunlight. Watercolour."

1. `storyboard-film`: a storyboard with a time per keyframe, the keyframes as stills, then one clip that passes through them.

**You end with:** one clip when the keyframes fit one clip; ordered clips for a longer piece.

## Which skill for what

| You have | You want | Skill |
|---|---|---|
| A product photo | Shop pictures | `product-photos` |
| A product photo or page | A video ad | `product-ad` |
| A product and a line | A person saying it to camera | `creator-ad` |
| A photo | The photo, moving | `animate-photo` |
| A topic, or your screenshots | Narration over pictures | `narrated-explainer` |
| Characters and a story | An episode, and more episodes | `series-episode` |
| A storyboard or keyframes | A clip through them | `storyboard-film` |
| A clip | A longer clip | `continue-shot` |
| A script or a clip | A voice track | `voiceover` |
| Anything else | One image, clip, voice line or transcript | `opper-media` |

## What the examples share

- A plan in words comes first, then stills, then clips. Stills are quick to change; clips are not.
- A draft is short and low resolution, so you see the idea sooner.
- The same sentence describes a product or a character in every prompt.
- Words, logos and interface text are added in your editor, never generated.
- A piece of several clips ends as an edit list. These tools do not join clips yet.
