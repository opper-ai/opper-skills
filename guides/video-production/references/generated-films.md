# Films from generated footage: cinematic and multi-style

For films whose picture is mostly **generated stills animated into clips**, held together by code transitions, a
score and type. Three kinds were made this way and are measured here:

- a **cinematic brand film** (22 s, 16:9, photoreal 35mm look, one story beat per shot, a code end card);
- a **multi-style personal montage** (46 s, 9:16, one activity per scene in a different art style each time: photoreal,
  anime, pop art, minimalist, pixel art, vector, watercolour, ink, claymation, 70s film), joined by motivated
  transitions and a sung song;
- a **paper-puppet short** (18 s, 9:16): a code-drawn set, sign and camera, with the puppet's performance generated
  and keyed over it (section 7).

The rest of the guide still applies (cue file, audio first, review loop). This file adds what is specific to
generated footage. Sources: films made with this guide in 2026-10, a published making-of of a 3-minute Seedance
music video (99 hand-written clip prompts, 189 takes), and the clip-prompt and audio findings in Scenario's public
skills (github.com/scenario-labs/skills), tested on our films before being kept.

## 1. Documents and gates

- **Separate facts from film choices.** Facts (real logo, real UI, brand colours, approved copy) are never invented; a
  missing asset is a blocker, so stop and ask. Choices (camera, light, story) are yours to propose.
- **Write a reference analysis** before any prompt: hex palette, where the eye goes first, pacing (seconds between
  meaningful changes), motion verbs (snap, glide, settle, cut, hold), texture, and a do-not-copy list.
- **Canon blocks.** A fixed sentence per character and prop, pasted verbatim into every still and clip prompt. It holds
  identity better than adjectives that drift from prompt to prompt.
- **A light arc.** Give each chapter a light state (night, pre-dawn, first light) appended to its prompts: the colour
  change tells the story.
- **One accent colour carries meaning,** so check every frame for it. In the brand film cyan meant "a live connection";
  a still with blue-lit cords before any line was live had to be corrected.
- **Gates the person commissioning the film approves:** story and style; the score; the stills (contact sheet); **the prompt book, read before
  any clip spends**; the final. Drafts and retakes happen between gates without asking.

## 2. Stills

- **Hero frame first.** Generate the one frame that sets the look, approve it, then pass it as a reference image to
  every other still. Palette, grain and set held across 10 stills this way; a separate colour-grade pass was not needed.
- **People from photos: never the originals in the film,** and only with the person's consent. Turn the photos into one identity sheet (front, three
  quarters, profile, full body, plain backdrop) and reference only the sheet. Likeness held in every style listed
  above.
- **Strong styles fight a photoreal reference.** Claymation from the sheet came back photoreal twice. Two steps fix it:
  generate with the sheet for likeness, then restyle that result from itself without the sheet ("remake this exact
  image as true claymation: the man too is now a plasticine puppet...").
- **Last frames by edit.** For each clip, edit its first frame into its last ("same shot, same style, a moment later:
  ..."). The clip model then lands exactly on the state the next transition needs (eyes closed, stove off, mid-air).
  The "keep everything else exactly as it is" clause that protects small edits **blocks reframing**: for a close-up end
  frame, drop it and say "the camera has moved in close".
- **Stage the action in the still.** A re-patch to "the jack next door" read poorly because that jack already held a
  lit cord. Make the before frame show what the action needs (an empty jack).
- **Empty plates for portals.** A hole that reveals the next scene must show the place, not the person, or the viewer
  sees two of them. Edit the next scene's first frame to remove the person ("same photograph, no person in it").
- **No text in generated frames.** Type, logos and captions are always code.

## 3. Clip prompts are timed scripts

The single biggest quality lever. One-paragraph prompts ("he listens") gave lifeless takes; hand-written timed scripts
(median 164 words) were approved first time. Each prompt:

```
STARTING STATE: <place, blocking and pose at 0.0 s>. <one sentence on the story beat: why it matters, what each person wants>.
TIMELINE:
0.0-0.6 s: <action, from its entry pose>
0.63 s: <the event, counted from the clip's first frame>
0.63-1.2 s: <action, and the reaction it causes>
...  Ends exactly on the end frame.
CAMERA: <one move, or "locked off, the camera does not move">.
MUST REMAIN UNCHANGED: <the canon block: style, each person's design, props>. Two arms and five fingers on each hand in every frame.
CONSTRAINTS: One continuous shot. Only <who and what is in frame>.
AUDIO: Diegetic sound only: <the sounds, in order>.   (or clip audio off when the score carries the film)
```

- **Action and reaction** for everyone in frame; nobody idle or posing. The environment moves too (spray, cords, light).
- **Write action as physics, not adjectives:** wind-up, contact, rebound, recovery; soft things lag ("the sleeves settle a
  moment after the arms stop"). Two retakes written this way did their scripted action on the first try (a chess
  capture, a fist bump) where paragraph prompts had left the man idle.
- **Say what a thing is instead of stacking prohibitions.** "His face stays clear: the flames are small drawn comic flames
  below the pan; the salt is a few tiny specks" kept the face clear on the first take; the prohibition list ("no smoke,
  no steam, no clouds, no fireballs") took three.
- **Write all prompts in one pass, in one context that holds the story,** into a prompt book (`PROMPTS.md`) that the
  generator reads verbatim. The person commissioning the film reads it before anything spends. When quality is flagged mid-run, stop every
  process that can spend, rewrite the prompts and re-make, rather than reviewing bad takes.
- **The audio line works when it only names sounds:** Kling and Seedance produced the listed sounds in order (crackle,
  silence, pull, click, hum). With "No music" in the line, Seedance still put music in one clip; with "Diegetic sound
  only: <sounds>" and no music words at all, Kling gave clean foley, no music, no voice. Omni ignored the line. Listen
  to each clip's audio alone before mixing it, and keep it well under the score.
- **Use the shortest clip that fits the action.** Kling stretched a 1.9 s action over 4.5 s of a 5 s clip; the same
  frames and prompt at 3 s hit the timestamps within 0.25 s. All models honour timestamps only roughly: plan to retime.

## 4. Model per shot, from a shoot-out

Run the hardest shot on 3 models with the same frames and prompt (about $5) before casting the film. Measured
2026-10 through Opper; model names and per-route prices change, so read `GET /v3/videos/models` first:

| | Kling 3.0 pro i2v | Seedance 2.5 | Gemini Omni 1.1 |
|---|---|---|---|
| Acting, hand contact, exact end frame | Best; lands first and last frames | Messier props | Good timing, contradicted its own state |
| Camera travel (glides, cranes, night to dawn) | Tends to stay put | **Best** | Fine for short moves |
| Holding a style (anime, pop art, flat, pixel, vector) | Held all for 5 s | Not tested | Over-acts ("swing a few degrees" became vertical) |
| Native audio | Good | Best | Ignored the prompt |
| Price at 1080p (2026-10) | $0.112/s audio off, $0.168/s with | $0.57/s (`bytedance:ap`), $1.16/s (`fal`) | ~$0.15/s |

- **Cheap drafts first** for expensive models (Seedance 480p) to check the move, then 1080p.
- **Beat-locked motion** by passing the score as a reference audio (`@Audio1`) is reported to work on some providers;
  in one test through `fal/seedance-2.5` (`parameters.audio_urls`) it did not copy the score and the actions landed
  off the beat. Test it on one clip before relying on it; the reliable path is to measure, then cut and retime in the
  edit.
- **Retakes for one artefact are cheap.** A fireball and then a salt cloud covered a face; the third take fixed it.
  Spell out the physics of the fix: a sofa that slid back and forth and bent was fixed in one retake by "one steady
  push, only to the left; the sofa is one rigid object, all four legs on the floor".

## 5. Put every event on its beat

1. **Measure the events from pixels:** brightness or colour share inside a box over time gives "lamp on", "plug in",
   "cord lit" to the frame. Do not trust the prompt's timestamps.
2. **Retime per cue:** split one clip into cues with their own source offset and speed (0.6x on a held moment, 1.2x
   through an action) so each event lands on its beat. 0.6-1.2x stays natural.
3. **Or play each clip whole across its window** (speed = clip length / window, 0.95-1.13 in the montage), so its
   requested first and last frames land exactly on the transitions.
4. Pre-cut clips with a keyframe at least every 0.5 s; sparse keyframes freeze or stutter on seek in the renderer.

## 6. Transitions that read as an edit

**Motivate every transition with the end of the outgoing shot and land it on a matching shape in the next.** Put it on
a beat and finish it before the next sung or spoken line. Reveal the incoming scene from **its own first frame** (the
still the clip starts on), so the handoff to the clip is invisible.

| Motivation (end of shot A) | Effect | Match in shot B |
|---|---|---|
| He closes his eyes to the sun | Blink: two black lids close (0.14 s) and open (0.22 s) | Eyes open, wind in the hair in both |
| Close on a hand gripping a wheel | Freeze, halftone dots grow over the frame (a CSS mask of a repeating radial gradient whose dot radius grows) | A hand gripping a pan handle |
| He turns the stove off; the room goes dark | Hold the dark, the next lamp flickers on | Fire light off, lamp light on |
| A frozen smug pose | Pixel dissolve, pre-rendered (blocks 8 to 96 to 8 px) | The pixel-art scene |
| Frozen at the top of a jump | Brush strokes paint the next scene over it (an SVG mask of thick dashed strokes) | Colour carries over |
| A gesture toward camera | Page slides in from the side with a shadowed edge | Each card in a flip-book |
| Hands pushing a paper wall | A paper rip (below) | The place he steps into |
| End of the film | Rewind: every scene's last and first frames backwards with scanlines, about 0.18 s each | Back to the opening set |

- **A paper rip that reads as paper:** a vertical slit with jagged sides widening on the beats; a fibrous edge
  (turbulence and displacement on the stroke); a shade inside the edge; god rays; small scraps flying away from the
  face; a decaying camera jolt on each rip; a warm grade inside so the hole previews the next shot; an empty plate
  inside; a full flash to carry the character through.
- **Effects that belong to the set live in the set layer,** behind the characters, with the revealed image mapped back
  to screen space (for a frame W wide, a camera centred on world x = fx and zoomed k: image x = fx - W/2k, width = W/k;
  the same for y and height). Drawn in screen space, the rip cut through the character's head.
- **Never pop a cut-out puppet between poses:** dissolve every pose change over 0.2-0.27 s. If a pose image carries its
  own prop (a sofa), hide the standalone prop while it shows, or it doubles.
- **3D card flips flicker** when the card passes edge-on. Slide pages instead.
- **SVG filters on thin or vertical paths** are clipped to the path's bounding box: set `filterUnits="userSpaceOnUse"`
  with a region covering the frame.

## 7. A character animated over a code set

When the set, the sign, the type and the camera must be exact (code) but the character should move naturally
(generated), generate only the performance and key it over the code. This was the part of the paper short that read
best: the puppet getting up, walking and sitting as one continuous move instead of poses swapped on the beat.

1. **Compose each clip's first and last frames yourself** from the approved cut-outs, on a flat chroma green (#00B140),
   at the exact framing the film camera will have. Every clip then registers with the code layers to the pixel, and the
   character can stand in front of code-drawn things (a sign he hammers up). For a world rect seen by a camera zoomed k
   on world point (fx, fy), the clip covers x0 = fx - W/2k, y0 = fy - H/2k, width W/k, height H/k.
2. **Generate with first and last frames** (Kling 3.0 pro landed every end frame) and chain clips through shared frames:
   one clip's last frame is the next one's first, and the joins are invisible.
3. **Key it** (ffmpeg `chromakey` + `despill`) to VP9 with alpha; HyperFrames plays alpha WebM with
   `--video-frame-format png`. Green keyed cleanly even on paper texture, with no fringe on hair or beard.
4. **Measure, don't assume:**
   - contact points from the clip, not the cut-out's anchor: hands placed by the torso anchor missed the letters by 98 px;
   - events from pixels (strikes, a drop onto a seat), then retime onto the beat: the prompt's timestamps were ignored
     (strikes every 0.33 s instead of 0.5 s);
   - the foreground's bottom edge per shot, for a contact shadow (a tight dark core at the feet plus a soft ellipse);
     keyed figures without one read as floating, tiptoe poses most of all.
5. **Never describe light the camera does not see.** "He looks up at a glow above him" made the model paint a glow onto
   the green. If it happens, paint that band back to the key colour before keying.
6. **Hand over to code poses with a short crossfade** (about 0.1 s): a clip's held end frame and the code pose differ
   by a few pixels and pop.

## 8. Help the key moment in code

Generated state changes are instant and easy to miss: a cord lit up in one frame, under a hand, and a critic did not
see it in two passes. Plan a code assist for the one change the story depends on. Here: a soft dark mask over the cord
that peels upward from the plug in 0.32 s with a bright pulse head, while the music returns. Measure where the change
happens on screen (a pixel diff of two frames) to place it.

## 9. Music and lyrics

- **Score first, measured, then the shot list.** The section plan is not the structure: a requested lift at 12.5 s came
  back as one crescendo peaking at 17.6 s. Fit the cuts to the measured beats and peak.
- **Few long sections.** Four short sections were heard as "spliced together" at every boundary; two long sections
  with "one continuous piece, seamless transitions" gave one arc.
- **Silence is an edit:** mute the music bus for the dramatic beat (it keeps running underneath and returns on its own
  beat). A quiet crescendo needs level automation (+12 dB at the start tapering to 0) and effects set relative to the
  local music level, or the effects drown the opening.
- **Songs with lyrics:** one line per section in `lyrics`, and one line lands inside its window. **Transcribe every take**
  for word timings: one of three takes sang invented words. A different genre per section barely changes the
  arrangement; for true style switches, generate separate pieces.
- Some music models ignore the requested length (2-minute tracks for a 24 s cue): only usable by editing out a section.

## 10. Subtitles for muted autoplay

Social feeds autoplay muted, so sung or spoken words need on-screen text. Karaoke style read best: the **written**
lyrics (never the transcript's spellings), each word timed from the transcript by position, one line at a time,
upcoming words at about 55% and sung words at 100%, on a dark rounded backdrop so they read over snow and cream. Keep
them in the lower third but above the bottom 300 px of a 9:16 frame. Build clean and subtitled versions from one
source with a switch.

## 11. Review

- **Critic loop on frames:** a fresh agent with the render only, ranked defects with timestamps, SHIP or ONE MORE PASS.
  Resume the same agent for later rounds with FIXED / PARTLY / STILL PRESENT per item. Both films took three rounds;
  the best catches were a fade-to-black ending (not a poster), an unreadable key beat, a character duplicated through a
  portal, pose pops and a page-flip flicker.
- **Listening models are unreliable on structure:** one said "the music never drops out" three times while the measured
  music bus was silent. They were right about balance. Measure first, listen for taste only.
- **Release scan** before publishing: check a few frames of every final take for glitches, anachronisms, objects in front
  of faces and off-model details. An empty review is a failure, not a pass.

## Cost observed (2026-10)

| Film | Clips | Stills | Audio | Total |
|---|---|---|---|---|
| 22 s cinematic brand film | $16.36 (incl. a $5 shoot-out and 1080p Seedance) | $0.62 | $0.76 | about $17.75 |
| 46 s multi-style montage | $4.48 (eight Kling takes) | $1.21 | $0.43 | about $6.10 |
| 18 s paper-puppet short (section 7) | $3.25 (nine Kling takes, silent) | $0.30 | $0.15 | about $3.70 |
