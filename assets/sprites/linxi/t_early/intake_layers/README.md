# Intake Outfit Layers

These are transparent visual layers drawn over Linxi's existing animation. They do not alter movement, attacks, collision, hitboxes, capacity, digestion, or animation timing.

Active region for the current demo: `belly`.

Deferred regions: `chest`, `lower_belly`, `groin`.

Each region has `tier_1` through `tier_4`. Tier 4 is used for four or more contained prey. Counts above four scale the tier-4 layer by 8% per additional prey.

Each tier may contain these 256x256 transparent PNG files:

- `idle_00.png` through `idle_03.png`
- `walk_left_00.png` through `walk_left_03.png`
- `walk_right_00.png` through `walk_right_03.png`

Keep the canvas, anchor, frame order, and pose aligned exactly with the matching base animation frame. Missing files use the graybox region indicator automatically.

Source references are archived in:

`source_assets/characters/linxi_vore_expansion_references/`

Do not place raw reference images directly in this runtime folder. Runtime files here must be approved transparent overlays aligned to the current T-form gameplay canvas.
