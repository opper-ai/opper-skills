# Music videos from a few stills, animated in code

A full song can be animated from 8–15 generated stills, with every movement done in code: no video model, and every motion lands on the beat. This was measured on a 4:07 lyric video (2026-11): 9 stills, $0.59 in images plus $0.015 for transcription, a 2.5 min render on an M4 Max. An 8 s chorus test in two other styles followed the same method.

## Pipeline

1. **Get the stems.** Most music generators export them.
   - **Drums:** the beats come from the drum stem.
   - **Vocals:** send the vocal stem to `elevenlabs/scribe_v2` (`POST /v3/audio/transcriptions`) with `diarize: true` and `parameters.timestamps_granularity: "word"`. That returns a time for every word, and a speaker label that splits a duet. It took 4 minutes of audio for $0.017.
2. **Write one cue file.** It holds sections, beats, bar lines, kicks and every lyric word with its time and singer.
   - **Use the detected beats, not a fitted grid.** Generated songs drift (115→116 BPM in one song).
   - **Find the bar phase** from the chorus hit.
   - **Look for drum drop-outs.** A drop that slams back in on a key word (here "ZOO") is the moment the whole edit should be built around.
3. **Align the written lyrics to the transcript.**
   - Re-anchor each line to the first exact match after the previous line. A plain diff locks onto backing-vocal echoes.
   - Write the lyrics as sung ("wanna", five "oh"s), not as on the lyric sheet.
4. **Build a full-length animatic before any art.** Use grey placeholder panels on the real cue times, the final lyric design, a beat light and a section bar. It renders in about 1 min and settles the pacing before you spend anything.
5. **Choose a style with a bake-off.** Generate one frame per style, then the same three moments in the top two or three styles (comedy, energy, the darkest beat). Then animate the key 8 s in the top two. Motion decides it more often than stills do.

## Stills that animate

- **Generate a plate and its actors separately.** Edit the approved frame twice:
  - "remove the character, fill the background" gives the plate
  - "keep only the character, same pose and position, flat #00B140 background" gives the actor

  Key the actor with `chromakey=0x00B140:0.12:0.04`. Skip `despill` when the palette has yellow, or it turns the yellow orange.
- **Make two poses per character.** Swapping poses on beats is the cheapest convincing animation (the classic rubber-hose bounce). Add squash and stretch with `scaleX`/`scaleY` from the feet.
- **Trace line art to vectors.** Flat black-and-white ink traced with `potrace` stays sharp through a 9× camera push into a phone screen. Add colour in code with `mix-blend-mode: multiply` tints.
- **Remove things with an image edit** ("remove the rain"), so masks and coordinates still register to the original.
- **Use a character reference for consistency, but not for empty sets.** A character reference image keeps faces stable, and the style's sample frame as the reference keeps the look. But the reference leaks people into scenes meant to be empty, so drop it there.

## Motion on the music

- **The cut rule:** a shot starts on the beat before its first sung word; the big hit lands on the next bar line.
- **Tie motion to words, not just beats.** A light step per word during a drum drop-out, the flash and camera punch on the word where the drums return, one pose swap per beat after it.
- **Let lyrics carry the story.** Give each singer a side (his left, hers right, duets centred). Each word is outlined until sung, flashes the accent colour, then stays filled. Quoted machine speech gets its own colour and a small tag.
- **Give lyrics their own band and margins.** Art never enters the band (a stage apron or rail works), and the side padding is at least 160 px.

## Text and reading time

Lyrics already use the viewer's reading channel. While a lyric is on screen:
- keep in-scene text to 3–4 words, or hold it for 0.5 s + 0.3 s per word
- never change two text blocks at once
- prefer icons and stamps to sentences

HyperFrames' `line_unread` warning is noise for sung lyrics, but real for in-scene text, so triage it per element.

## Building with several agents

Parallel scene agents are 5–6× faster but drift. One film came back with three versions of the same two main characters. Before fanning out:
1. Build one shared kit module: characters and props, colour and type tokens, and the motion vocabulary (pop easing, flash style, how beats pulse).
2. Finish one reference section.

Agents import the kit and never redraw it. Give every scene its own id and class prefix, and every agent its own HyperFrames work dir with the assets symlinked. Then compare all sections at matching moments in one contact sheet.

## HyperFrames traps that cost a render

- **Partial builds:** when building one section of a long film, lyric tweens carried over from the previous section get negative positions, and GSAP shifts the whole timeline later. Clamp tween positions at 0.
- **Lyric gaps:** don't show a lyric line before `t0 - 0.25`, or it hangs through instrumental breaks.
- **Hidden elements:** an element that starts at `opacity: 0` must put its final opacity in the tween's *to* values too, or cold render workers keep it hidden (`gsap_cold_seek_hidden_fromto_missing_reveal`).
- **Full-frame overlays:** start them at `opacity: 0` in CSS, not only via a later `set`.
- **Iris wipes:** a circle `clip-path` wipe needs the outgoing shot to run past the cut, or it opens onto black.
- **Black frames:** scan the final file with `ffmpeg -vf blackdetect=d=0.02:pix_th=0.06`. Then look at every hit: some are scene design, some are capture faults.
