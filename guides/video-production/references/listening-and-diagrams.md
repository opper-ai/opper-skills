# Listening with earshot, and diagram layers with Manim

Two open-source tools that fill gaps in the method: an agent cannot hear its own mix, and some moments (a race of
answer times, a growing chart, an equation) are easier to write as a diagram scene than as HTML. Both were tested on
a 27 s game promo in 2026-10; the numbers below come from that film.

## earshot: ears for the agent

[earshot](https://github.com/Leonxlnx/earshot) (MIT, released 2026-10) turns audio into evidence an agent can reason
about. It runs on CPU and keeps the audio local; two open models (CLAP and an AudioSet tagger, about 1.1 GB) download
on first use.

| Command | What you get |
|---|---|
| `timeline FILM --cues cues.json` | The listening transcript: loudness, the **measured beat grid**, sections, events, and sync of sound to every cue frame ("x% have an onset within 1 frame (chance y%)") |
| `sheet FILM -o sheet.png --cues cues.json` | One annotated PNG: frames, spectrogram, labelled events, loudness, beats, cue markers coloured by sync. Open it: gaps, pile-ups and late hits show at a glance |
| `critique FILM` | A scorecard against 7 professional launch films, with timestamped fixes |
| `rank PATHS... "description"` | Candidate takes sorted by how well they fit a plain description |
| `measure FILE` | Exact meters only: LUFS, true peak, LRA, tempo, key |

Install from its README (its own venv, CPU torch). Each CLI call reloads the models (20-40 s), so run a review in one
Python process (`from earshot import api`; `api.timeline`, `api.sheet`, `api.critique`, `api.rank`) or as an MCP
server. A whole review of the 27 s film took 45 s on a laptop. The repo ships its own agent skill
(`skills/earshot/SKILL.md`) explaining how to read every number.

**Pass your own cue times** (`{"fps": 30, "events": [{"f": 69, "kind": "hit", "id": "deal0"}]}`): its cut
detector finds hard cuts, not motion inside a shot.

### What it caught

The promo's first soundtrack was timed by measuring loudness only, and a human liked it. earshot on that version,
then after the fixes:

| Finding | Before | Fix | After |
|---|---|---|---|
| Channels | mono (inputs mixed without a layout) | `aformat=channel_layouts=stereo` on every input; effects panned toward where the motion enters | stereo |
| Loudness | -12.3 LUFS for a -14 target | single-pass `loudnorm` misses on short, dynamic mixes; use two passes | -14.1 LUFS, -1.1 dBTP |
| Score tempo | prompted "128 BPM, keeps accelerating"; measured **113.2 BPM, steady** (beat regularity 0.022) | cut on the track's measured beats; build any speed-up into the edit | |
| Cues on the beat | 22% (random edits: 19%) | cuts on measured beats and half-beats | **70%** |
| Cue onsets within one frame | 54% | same | 73%, median 18 ms |
| Launch scorecard | 21 of 23 metrics in range | | 22 of 23 |

- **Measure the score you got, never the one you asked for.** `elevenlabs/music_v2_5` ignored both the tempo and the
  acceleration in the prompt.
- **The scorecard is a style profile.** The remaining flag ("harsh mids, 1-3 kHz") came from the character's voice
  lines, which carry the film; the reference films are music-and-effects led. A -3 dB EQ on the music moved it
  nowhere. Leave a flag the brief explains, and say why.
- **Rank shortlists; it does not choose between good takes.** Six laugh takes all scored "strong" (z +8.2 to +9.2).
- It does not judge taste, emotion or the words spoken (no speech recognition), and hears 50 Hz to 14 kHz only. A
  human still listens last.

## Manim: diagram layers

[Manim Community](https://www.manim.community) (MIT) renders maths and diagram animation from Python: bars, counters,
graphs, equations, arrows. Use it for a data moment inside a film; keep UI, text-heavy layouts and anything that must
match the product in HTML.

- **Install** in its own venv (`pip install manim`); it needs Cairo and Pango (Homebrew `cairo pango` on macOS).
- **Delivery size**: set `config.pixel_width`, `config.pixel_height` and `config.frame_width` to the film's aspect
  (for 1080x1350: frame height 10, frame width 8).
- **Render a transparent layer**: `manim -q h --format mov -t scene.py Scene` writes a qtrle ARGB `.mov`; FFmpeg
  `overlay` puts it over the HTML render or a generated clip. A 3.3 s layer rendered in under 3 s.
- **Brand fonts**: Manim draws text with Pango, so a web `.woff2` does nothing. Download the TTF and wrap the scene in
  `with register_font("Font.ttf"):`.
- **Timing**: scenes are timed by `run_time` and `wait`, not by a cue file. Read the times from `cues.json` in the
  scene so a retime is still one edit.
