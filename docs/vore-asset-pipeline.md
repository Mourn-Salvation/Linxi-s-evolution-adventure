# Vore Asset Pipeline

## Current Scope

The active Vore expansion presentation is belly-only.

Enabled intake routes:

- `V` / `CORE`
- `A+V` / `LEFT`
- `D+V` / `RIGHT`

Disabled until the belly module is proven:

- `W+V` / `UPPER`
- `S+V` / `LOWER`
- `V+V` / `BURST`

Only the `BELLY` region should be authored, validated, and tuned for now.

## Runtime Contract

Runtime files live under:

`assets/sprites/linxi/t_early/intake_layers/belly/`

Required folders:

- `tier_1`
- `tier_2`
- `tier_3`
- `tier_4`

The belly mass lives in:

`assets/sprites/linxi/t_early/intake_layers/belly/`

Required files per tier:

- `idle_00.png` through `idle_03.png`
- `walk_left_00.png` through `walk_left_03.png`
- `walk_right_00.png` through `walk_right_03.png`

All runtime files must be:

- transparent PNG
- aligned to Linxi's current T-form canvas
- safe to draw over idle and walk frames
- free of background, full-body reference remnants, text, UI, or frame borders
- large enough to contain the full visible overlay without edge clipping

The old `256x256` canvas is only the baseline contract. Larger belly tiers may use larger transparent canvases when needed. When a larger canvas is used, compensate for the renderer origin by placing the visible alpha region lower inside the canvas; otherwise the overlay will render too high on Linxi.

## Tier Meaning

- Tier 1: one contained prey
- Tier 2: two contained prey
- Tier 3: three contained prey
- Tier 4: four or more contained prey

Counts above four use tier 4 with runtime overflow scaling. The current in-game belly overlay pass renders intake layers at `1.2x` of the base route scale so they remain readable at gameplay distance; source assets should still be authored to the normal anchor contract, not pre-enlarged.

Visible tier size must increase gradually, not jump wildly. Tier 3 must read clearly larger than tier 2, and tier 4 must read larger than tier 3 before runtime overflow scaling is applied. The active tuned runtime pass uses roughly `82px`, `106px`, and `118px` visible widths for tiers 2-4.

## Belly Anchor Rule

For the current T-form idle/walk sprite, the belly layer should start around the center of Linxi's white shirt.

Current target:

- Belly tier 1-3 top visible pixel: about `y=91` on a `256x256` runtime canvas.
- For `320x320`, `512x512`, or larger canvases, adjust the visible alpha top so the rendered top still lands at the shirt/skirt connection after `_route_layer_draw_origin()` and `INTAKE_LAYER_OFFSET` are applied.
- Tier 4 may sit slightly lower or larger if the silhouette needs more weight, but it must still read as attached to the torso.

Do not shrink, trim, or crop a tier just to fit the old baseline canvas. Use a larger transparent canvas and verify the visible alpha bbox does not touch any canvas edge.

## Belly Color Rule

The belly overlays should read as Linxi's pale infected skin, not blue-gray biomass armor. Keep all active belly tiers in the same skin family as tiers 1-2: pale peach/ashen skin, restrained saturation, visible volume texture, and only subtle cold highlights. If a source candidate is too dark, remap it toward the tier 1-2 palette before scaling or import.

## Belly Integration Note

The `belly_bridge` experiment is currently disabled because the derived skirt/shirt band looked visually strange in game. Do not require or render bridge frames until a new approved approach exists.

Better future options:

- generate full torso-and-belly replacement overlays per tier
- author the belly with built-in shirt hem/skirt contact pixels from the start
- use a shader/mask blend at the top edge instead of a separate body-strip overlay
- create tier-specific idle/walk body variants if the belly system becomes central enough to justify the cost

The current preferred low-cost fix is to shape the belly layer itself: tuck the upper-left contour inward so the mass follows Linxi's torso curve, while keeping the lower belly volume rounded. Avoid separate bridge/body-strip overlays unless a new pass is explicitly approved.

Always verify the overlay against:

`assets/sprites/linxi/t_early/weak_idle/00_idle_00.png`

## Production Methods

### Method A: Reference Clipping

Use this when a reference image already has the right volume.

1. Pick one source image per tier.
2. Crop only the useful volume/texture area.
3. Do not preserve full character body, face, limbs, clothing, background, or unrelated detail.
4. Color-grade the crop toward the project palette: dark teal-gray infected biomass, restrained pale undertone, cyan rim highlight.
5. Mask the crop into a compact belly silhouette.
6. Place it on a transparent canvas large enough to preserve the full visible silhouette.
7. Export idle and walk variants with small deterministic offsets only.

Source references stay in:

`source_assets/characters/linxi_vore_expansion_references/`

### Method B: Generated Sheet

Use this when references are not clean enough.

1. Generate one raw `2x2` sheet containing belly tiers 1-4.
2. Use solid `#FF00FF` magenta background.
3. Require no full character, no face, no limbs, no text, no frame borders.
4. Process the raw sheet with `generate2dsprite.py process`.
5. Export processed tiers into the runtime contract.
6. Compare against the current idle frame before import.

ComfyUI or model-specific generation is allowed only after Sprite Forge / built-in generation cannot produce a usable result.

### Method C: Integrated Full-Body Variants (Optional, Deferred)

This method is an approved optional direction when detached overlays cannot produce a believable torso connection.

1. Composite the current runtime body and belly tier only as a size/placement reference.
2. Generate one complete adult Linxi body variant per tier, preserving identity, outfit, stance, feet anchor, and character height.
3. Integrate the expanded abdomen continuously beneath the ribcage and shirt-to-skirt waistline instead of attaching a separate belly layer.
4. Let shirt tearing, exposed pale abdominal skin, navel placement, skirt compression, gravity, lighting, and surface tension change coherently with the tier.
5. For higher tiers, ambiguous broad pressure bulges may suggest internal mass, but never show identifiable faces, hands, feet, limbs, joints, or cutaway anatomy.
6. Approve the complete tier progression first, then regenerate every required idle, walk, sprint, attack, hit, dodge, Vore, and knocked-down body action from the approved tier identities.

Current proof-of-concept files live under:

`source_assets/characters/linxi_t_early/vore_preview_test/`

The tier-3 gravity/bulge preview is the strongest current demonstration of this method. Tier 1-3 outputs are reference previews only. They are not runtime assets and must not replace the active overlay folders.

Full-body Vore asset regeneration is **deferred**. Resume it only as a dedicated production project with explicit approval, enough time to regenerate the complete animation matrix, and rollback coverage for the current overlay system.

## Approval Gate

Before a Vore asset pass becomes active:

1. Create a preview sheet composited over Linxi's idle frame.
2. Check tier order reads clearly from 1 to 4.
3. Check tier 1 is not too large.
4. Check tier 4 does not hide the whole body silhouette.
5. Check the top pixel anchor follows the belly anchor rule.
6. Run Godot import.
7. Run `run_tests.gd`, `run_encounter_save_test.gd`, and `run_red_night_test.gd`.
8. Record the active pass and rollback folder in the reference manifest.

## Do Not Do Yet

- Do not author chest, lower-belly, or groin runtime overlays.
- Do not unlock `UPPER`, `LOWER`, or `BURST`.
- Do not make route-specific capacity rules.
- Do not change collision, attack range, movement speed, or digestion timing because of visual expansion.
- Do not overwrite source references or backups without explicit approval.
- Do not wire the integrated full-body tier previews into gameplay or begin whole-animation regeneration until the deferred Vore production project is explicitly resumed.
