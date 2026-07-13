# ComfyUI Needed Art

This is the current production checklist. Do not generate every prompt yet.

## Generate Now

Generate these assets in this order. Use the full prompts in `linxi-sprite-prompts.md`.

### 1. Early T-Form Linxi Identity Turnaround

- Prompt section: `Sheet 1: Identity Turnaround`
- Purpose: establish Linxi's definitive face, body proportions, clothes, colors, and silhouette.
- Generate 4 candidate images.
- Keep the solid `#FF00FF` background.
- Do not continue until one candidate is approved as the identity reference.

### 2. Early T-Form Linxi Weak Idle

- Prompt section: `Sheet 4: Weak Idle`
- Generate only after the identity turnaround is approved.
- Required layout: `2x2`, four animation frames.
- Keep Linxi centered, at one consistent scale, with her feet on the same anchor line.
- Keep the solid `#FF00FF` background.

### 3. Early T-Form Linxi Slow Walk

- Prompt section: `Sheet 5: Slow Walk`
- Generate only after the identity turnaround and weak idle are approved.
- Required layout: `4x4`, sixteen frames for four-direction movement.
- Preserve the approved identity, clothing, proportions, and sprite scale.
- Keep the solid `#FF00FF` background.

## Do Not Generate Yet

- Lying pose
- Stand-up animation
- Dialogue portrait
- Combat, dodge, hurt, jump, digestion, vore, or G-mode animations
- Enemies, weapons, props, and effects
- Opening cinematic shots
- Courtyard background and ground layers

These will be generated after the three initial assets pass visual and technical review.

## Save The Raw Images Here

Save the original ComfyUI PNG files without removing the magenta background:

`E:\Linxi's evaluation adventure\source_assets\characters\linxi_t_early\raw`

Recommended filenames:

- `linxi_t_identity_candidate_01.png`
- `linxi_t_identity_candidate_02.png`
- `linxi_t_identity_candidate_03.png`
- `linxi_t_identity_candidate_04.png`
- `linxi_t_weak_idle_raw.png`
- `linxi_t_slow_walk_raw.png`

## After Generation

Tell Codex which identity candidate you prefer. Codex will then use Sprite Forge to:

- remove the magenta background;
- split and align the animation frames;
- check scale consistency and cropped edges;
- export transparent PNG sheets and preview GIFs;
- integrate approved sprites into Godot.

## Detailed Prompt Files

- Character prompts: `linxi-sprite-prompts.md`
- Opening prompts for later: `opening-cinematic-prompts.md`
