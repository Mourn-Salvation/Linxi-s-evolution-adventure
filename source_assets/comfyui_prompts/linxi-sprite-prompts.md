# Early T-Form Linxi ComfyUI / Sprite Forge Prompt Pack

## Workflow

Generate and approve the identity sheet first. Use the approved identity image as an IPAdapter, character reference, or other identity-conditioning input for every later sheet. Do not use the opening reference MP4s as character inputs.

## Shared Character Lock

- Linxi, adult Chinese woman, age 18
- slim build, approximately 165 cm
- short slightly uneven black hair
- small round glasses
- recognizable restrained face
- cool pale-gray Early T-zombie skin
- faint desaturated red-brown under-eye tone
- dim dark-red irises
- original dark navy zip jacket with muted pale piping
- charcoal knee-length skirt
- opaque dark leggings
- worn black shoes
- small hexagonal bone plate near right wrist
- no large mutation, no gore, no sexualization

## Shared Sheet Negative Prompt

```text
minor, child, underage, young-looking child, sexualized schoolgirl, cleavage, exposed underwear, fetish clothing, glamour pose, pinup, high heels, copied franchise character, copied uniform, logo, symbol, text, label, UI, border, panel divider, scenery, floor, cast shadow, gradient background, extra character, duplicate body, missing glasses, long hair, blonde hair, bright colors, cheerful anime, chibi, smooth painterly rendering, 3D render, photorealism, open wound, gore, exposed organ, huge mutation, weapon, muzzle flash, slash effect, detached particles, cropped feet, cropped hair, frame edge touch
```

## Sheet 1: Identity Turnaround

Use the full prompt already saved at:

`source_assets/characters/linxi_t_early/identity/identity-brief.md`

Recommended canvas: `1536x1536` or `2048x2048`, exact 2x2 grid.

## Sheet 2: Lying Pose

```text
Original low-resolution retro survival-horror 2D game sprite of Early T-form Linxi, adult Chinese woman age 18, using the approved identity reference. Single full-body pose in 3/4 fake-3D brawler view from slightly above. Linxi lies on one side on the ground after regaining consciousness, body curled slightly, one arm bracing weakly, legs extended unevenly, glasses still present, short black hair disordered, dark navy jacket, charcoal skirt, opaque leggings, black shoes, cool pale infected skin, tiny right-wrist bone plate. Non-graphic, no visible wound, no blood, no impact imagery. Crisp readable silhouette, restricted cold blue-black palette, severe directional light. Perfectly flat #FF00FF background, no floor, no cast shadow, no text, no scenery, generous padding, entire body visible.
```

Recommended canvas: `1024x1024`.

## Sheet 3: Stand-Up Animation

Exact `2x3` grid, six frames read left-to-right across rows:

1. Lying still
2. Head and shoulder lift
3. Push to one elbow and knee
4. Unstable crouch
5. Half-standing with bent posture
6. Weak standing pose

```text
Create exactly one 2x3 grid sheet containing six sequential body-only frames of Early T-form Linxi standing up from the ground. Use the approved identity reference and preserve the same adult face, short black hair, round glasses, outfit, pale skin, wrist bone plate, body scale, and lighting in every frame. 3/4 fake-3D brawler view from slightly above. Motion is slow, stiff, physically uncertain, and unsettling rather than athletic. Full body remains in the central 60% of each equal invisible cell. Stable final feet anchor and consistent body proportions. No effects, dust, blood, wounds, text, labels, borders, scenery, or floor. Perfect flat #FF00FF background. No body part crosses a cell edge.
```

Recommended canvas: `1536x1024` or another exact 3:2 sheet suitable for 2 rows and 3 columns.

## Sheet 4: Weak Idle

Exact `2x2` grid:

1. Bent neutral stance
2. Shallow breath and slight sway
3. Head adjusts as if listening
4. Return to bent neutral stance

```text
Create exactly one 2x2 grid sheet containing four sequential body-only idle frames for Early T-form Linxi. Use the approved identity reference. 3/4 fake-3D brawler view from slightly above, full body, feet planted, shoulders slightly forward, stiff balance, subtle shallow breathing and tiny head movement, weak and disoriented rather than combat-ready. Preserve identical face, glasses, hair, costume, pale skin, wrist plate, body height, feet line, palette, and lighting. No weapon, effects, particles, text, borders, scenery, floor, or shadow. Perfectly flat #FF00FF background, generous padding, no edge crossing.
```

Recommended canvas: `1536x1536`.

## Sheet 5: Slow Walk

Canonical exact `4x4` directional locomotion sheet:

- row 1: down/front
- row 2: left
- row 3: right
- row 4: up/back
- columns: neutral, left step, neutral, right step

```text
Create exactly one canonical 4x4 four-direction slow-walk sheet for Early T-form Linxi using the approved identity reference. Rows: front/down, left, right, back/up. Columns: neutral, left foot step, neutral, right foot step. The walk is slow, stiff, unstable, and recently revived, with short stride and guarded arms. Same adult identity, short black hair, round glasses, dark navy jacket, charcoal skirt, opaque leggings, worn shoes, pale infected skin, and tiny right-wrist bone plate in all sixteen frames. Preserve identical body height and stable feet anchor within each directional row. Full body in the central safe area of every equal invisible cell. No weapon, FX, text, labels, borders, scenery, floor, or cast shadow. Perfectly flat #FF00FF background. Nothing crosses a cell edge.
```

Recommended canvas: `2048x2048`.

## Sheet 6: Dialogue Portrait

```text
Original shoulders-up dialogue portrait of Early T-form Linxi, adult Chinese woman age 18, matching the approved identity reference. Short uneven black hair, small round glasses, cool pale-gray infected skin, faint red-brown under-eye tone, dim dark-red irises, restrained frightened concentration rather than exaggerated fear. Dark navy jacket collar visible. Severe side light, one large shadow mass, tiny cyan reflection in glasses, tiny danger-red eye accent, low-resolution retro survival-horror portrait, contemporary school-biochemical identity, no gore, no text, no UI, no copied symbols. Flat #FF00FF background for extraction, no cast shadow.
```

Recommended canvas: `1024x1024`.

## ComfyUI Continuity Advice

- Approve one identity output before animation generation.
- Crop the approved 3/4 view and face portrait into separate reference images.
- Use the same checkpoint, VAE, LoRA stack, palette conditioning, and identity adapter strength across all sheets.
- Keep denoise lower when using the approved identity reference.
- Reuse a stable seed family, but do not force one seed if it damages pose accuracy.
- Generate four candidates per sheet and reject identity drift before postprocessing.
- Do not interpolate animation frames until the hand-authored keyframe sheet is approved.

## Postprocessing

After generation, place raw files under:

```text
source_assets/characters/linxi_t_early/identity/
source_assets/characters/linxi_t_early/lying/
source_assets/characters/linxi_t_early/stand_up/
source_assets/characters/linxi_t_early/idle_weak/
source_assets/characters/linxi_t_early/walk_slow/
source_assets/characters/linxi_t_early/portrait/
```

Then use Sprite Forge processing for magenta removal, grid splitting, protected character cleanup, bottom-most-pixel anchor alignment, shared scale checks, transparent exports, animation previews, and edge-touch QC. For grounded locomotion, preserve a full-cell preview, run `tools/align_sprite_bottom_anchor.py`, and reject or repair any candidate whose aligned preview leaves detached shoe/body fragments at the top of the strip.
