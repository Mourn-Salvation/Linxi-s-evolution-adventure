# Opening Cinematic ComfyUI Prompt Pack

## Purpose

Generate original visual material for the game's opening. The MP4 clips in `E:\Chrome down` are timing and mood references only. Do not use their frames as img2img inputs, ControlNet sources, face references, or direct composition templates. The final output must be visually original.

## Shared Continuity Lock

Use the same character identity across shots 1-3:

- Linxi, adult Chinese woman, age 18
- slim build, approximately 165 cm
- short, slightly uneven black hair
- small round glasses
- restrained, tired expression
- original dark navy residential-school jacket with muted pale piping
- charcoal knee-length skirt, opaque dark leggings, simple black shoes
- no logos, insignia, copied uniforms, or franchise symbols

## Shared Visual Direction

- original low-resolution retro survival-horror cinematography
- contemporary Chinese school and covert biochemical research setting
- late-1990s console-era image grammar without copying an existing game
- severe directional lighting and large shadow masses
- cold blue-black school palette
- danger-red pin lights used sparingly
- clinical cyan and desaturated green-gray laboratory palette
- restrained pixel structure, subtle dithering, mild chromatic separation
- sparse composition and strong negative space
- 16:9 landscape
- no text baked into the image; title and subtitles are added in Godot

## Recommended Generation Settings

These are starting points, not mandatory node names:

- Final canvas: `1280x720`
- Generation canvas: `1024x576`, `1152x648`, or another native 16:9 size
- Final downsample target for texture pass: `640x360`, then nearest-neighbor upscale to `1280x720`
- Sampler: DPM++ 2M Karras or your preferred stable cinematic sampler
- Steps: 24-36
- CFG: 4.5-7 depending on model
- Batch: 4 candidates per shot
- Seed policy: choose one approved identity seed for Linxi, then retain it or use an identity reference/IPAdapter for shots 1-3
- Do not use the existing reference MP4 frames as generation inputs

## Global Negative Prompt

```text
minor, child, young-looking child, underage, sexualized schoolgirl, cleavage, exposed underwear, fetish pose, glamorous fashion pose, cheerful anime, colorful fantasy, cute chibi, glossy mobile game, heroic action poster, copied game character, copied franchise uniform, copied logo, copied UI, watermark, text, subtitle, title, signature, extra person, crowd, daylight, warm sunshine, bright saturated colors, smooth plastic skin, excessive film grain, gore, open wound, explicit injury, visible impact, rooftop edge focus, jumping pose
```

## Shot 1: Title Silhouette

### Function

Black fades into a quiet rooftop access area. Linxi is seen from behind. The title and `PRESS ANY KEY` are overlaid later in Godot.

### Positive Prompt

```text
Original cinematic establishing plate for a low-resolution retro survival-horror game. Nighttime rooftop access platform at a contemporary Chinese residential school, adult Linxi age 18 standing with her back to the camera in the middle of the safe rooftop platform, well away from all edges, slim silhouette, short uneven black hair moving slightly in cold wind, small round glasses barely visible in profile, original dark navy school jacket, charcoal knee-length skirt, opaque leggings, black shoes. Locked rooftop access door, concrete utility walls, vents, railings in the far background, distant W City skyline with only a few dim windows and tiny red warning lights. Very dark blue-black palette, severe rim light from distant city glow, large negative space, quiet melancholy, restrained pixel-inspired texture, subtle analog noise and scanline-friendly gradients, cinematic 16:9 composition, empty central-lower area reserved for game title overlay, no text.
```

### Composition

- Linxi occupies roughly 22-28% of frame height.
- Camera is behind and slightly below shoulder height.
- Keep the center and lower third readable for title UI.
- Do not frame a ledge as the subject.

### Animation Guidance

- Duration: 5-7 seconds.
- Slow 2% camera push-in.
- Hair and jacket move subtly in wind.
- Distant warning light blinks once.
- Avoid full-body movement before player input.

## Shot 2: Linxi Turns Toward Camera

### Function

After input, Linxi turns. The camera closes in and reveals her face.

### Positive Prompt

```text
Original close cinematic portrait of Linxi, the same adult Chinese woman age 18 from the previous shot, turning from a back-facing rooftop pose toward the camera. Short uneven black hair, small round glasses catching one narrow cyan reflection, tired eyes, restrained and emotionally distant expression, natural adult facial proportions, cool pale night lighting, dark navy residential-school jacket with muted pale piping. Contemporary school rooftop architecture blurred behind her, distant city lights reduced to sparse soft blocks. Severe side light, most of the face in shadow, one subtle danger-red reflection from a warning lamp, low-resolution retro survival-horror presentation, controlled pixel structure, slight chromatic separation at the edges, intimate 16:9 close-up, no text, no tears, no glamour pose.
```

### Composition

- Begin chest-up and end at face close-up.
- Keep glasses, hair shape, jacket collar, and facial proportions consistent with Shot 1.
- Eyes should not stare directly at the viewer until the final second.

### Animation Guidance

- Duration: 4-5 seconds.
- Slow head and shoulder turn.
- Camera pushes from medium shot to close-up.
- Hold the completed turn for 0.5-0.8 seconds.

## Shot 3: Abstract Disorientation And Blackout

### Function

Communicate loss of balance and descent without showing an explicit act or impact.

### Positive Prompt

```text
Abstract first-person disorientation for an original low-resolution retro survival-horror game. Night sky, fragments of dark school architecture, railing shadows, city lights stretching into vertical streaks, adult Linxi's glasses briefly crossing the foreground as a dark silhouette, severe camera roll, visual signal breakup, blue-black field with thin danger-red scanline interruptions, memory-like frame tearing, restrained pixel structure, cinematic 16:9, emotionally unsettling but non-graphic, no visible body impact, no explicit injury, no person shown jumping, no text.
```

### Animation Guidance

- Duration: 2-3 seconds.
- Rotate camera 70-110 degrees while translating downward through abstract streaks.
- Insert 2-3 dropped black frames.
- End on full black before any impact.

## Shot 4: Laboratory Intercut

### Function

Establish the simultaneous biochemical incident and Subject 47 experiment.

### Positive Prompt

```text
Original wide clinical laboratory shot for a low-resolution retro survival-horror game. Covert underground biochemical research facility in W City, sterile observation room behind thick containment glass, adult experimental subject lying fully clothed in a plain gray medical garment on a restrained steel examination platform, several white articulated robotic medical arms suspended above the table, cyan heartbeat monitor, one small red warning indicator, two indistinct adult researchers behind the observation glass. Desaturated green-gray and cold cyan palette, severe fluorescent lighting, hard rectangular composition, institutional dread, sparse environment, restrained pixel-inspired texture, mild analog interference, cinematic 16:9, no gore, no nudity, no text, no copied science-fiction symbols.
```

### Composition

- Subject and table run horizontally across the lower-middle frame.
- Robotic arms form a controlled visual cage.
- Researchers remain secondary silhouettes.
- Leave upper-left negative space for a Godot location label.

### Animation Guidance

- Duration: 4-6 seconds.
- Very slow lateral camera drift.
- Heart monitor pulses.
- One robotic arm makes a small calibration movement.
- Red warning indicator activates near the end.

## Shot 5: Courtyard Transition Plate

### Function

Bridge the laboratory blackout into playable Early T-form Linxi lying in the school courtyard.

### Positive Prompt

```text
Original nighttime school courtyard background plate for a low-resolution retro survival-horror game, contemporary Chinese residential school after a biochemical incident, empty concrete courtyard, dark teaching building windows, locked doors, institutional green-gray walls, one damaged blue aerosol device emitting a faint cyan mist, sparse danger-red emergency lights, wet-looking but not reflective ground, broad empty fake-3D combat lane, cold blue-black palette, strong negative space, severe overhead lighting, restrained pixel structure, layered parallax-friendly composition, no characters, no text, no gore, no baked interactive props except the distant non-colliding architecture.
```

### Important

This plate is a visual reference only. For final gameplay, use the `$generate2dmap` layered-map workflow:

- far skyline
- school architecture midground
- repeatable ground foundation
- ground decals
- aerosol device as a separate prop
- doors, barriers, debris, and occluders as separate runtime assets

## Assembly Order

1. Black screen and wind ambience.
2. Shot 1 fades in.
3. Godot overlays game title and `PRESS ANY KEY`.
4. Input removes UI; Shot 2 plays.
5. Shot 3 disorientation.
6. Full black and short silence.
7. Shot 4 laboratory intercut.
8. Hard cut to black.
9. Fade into gameplay courtyard using the layered map.
10. Early T-form Linxi lies still, stands automatically, then receives slow player movement.

## Delivery Naming

```text
source_assets/cinematics/opening/shot01-title-silhouette.png or .mp4
source_assets/cinematics/opening/shot02-turn-closeup.png or .mp4
source_assets/cinematics/opening/shot03-disorientation.mp4
source_assets/cinematics/opening/shot04-laboratory.png or .mp4
source_assets/cinematics/opening/shot05-courtyard-reference.png
```

Do not overwrite these files with the old `ComfyUI_0000*.mp4` references.

