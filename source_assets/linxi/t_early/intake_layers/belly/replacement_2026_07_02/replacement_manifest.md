# Belly Tier 3-4 Replacement Pass

Created: `2026-07-02T13:15:30`
Backup: `E:\Linxi's evaluation adventure\work_backup\intake_layers_before_tier3_4_replace_20260702-131530`
Anchor corrected: `2026-07-02T13:17:56`

## Processing Contract

- Source candidates are archived unchanged in `originals/`.
- Runtime frames use larger transparent canvases where needed; visible pixels are never edge-cropped.
- Renderer crops alpha at draw time, so transparent margins are safe.
- Larger canvases place their alpha region lower than the old `256x256` baseline so the rendered top still lands at Linxi's shirt/skirt connection.
- The output replaces only belly `tier_3` and `tier_4` runtime frames.

## Tier 3

- Source: `C:\Users\13948\Desktop\belly layer 3 candidate.png`
- Source size: `(701, 779)`
- Runtime canvas: `(512, 512)`
- `idle_00` visible bbox: `(184, 220, 329, 368)`
- Runtime preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\processed\tier_3_idle_00_processed.png`

## Tier 4

- Source: `C:\Users\13948\Desktop\belly layer 4  candidate.png`
- Source size: `(1024, 1024)`
- Runtime canvas: `(640, 640)`
- `idle_00` visible bbox: `(218, 285, 422, 509)`
- Runtime preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\processed\tier_4_idle_00_processed.png`

## Pale Skin / Scale Correction

- Updated: `2026-07-02T13:27:49`
- Backup: `E:\Linxi's evaluation adventure\work_backup\intake_layers_before_belly_pale_scale_fix_20260702-132747`
- Tier 3 visible width scaled from about `152px` to `76px` (`50%`).
- Tier 4 visible width scaled from about `214px` to `128px` (`60%`).
- Tier 3/4 color remapped toward the tier 1/2 pale skin palette.
- Visible alpha is still positioned to render at the shirt/skirt connection.
- All-tier preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\previews\belly_all_tiers_pale_scaled_check.png`
- Renderer preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\previews\belly_tier_3_4_pale_scaled_renderer_position_preview.png`

## Tier Order Size Correction

- Updated: `2026-07-02T13:33:50`
- Backup: `E:\Linxi's evaluation adventure\work_backup\intake_layers_before_belly_tier_order_fix_20260702-133347`
- Tier 2 visible width is `82px`; tier 3 target is `90px` (`~110%`).
- Tier 4 target is `99px` (`~110%` of tier 3), slightly reduced from the previous pass.
- Shirt/skirt attachment and no-crop larger-canvas rule preserved.
- All-tier preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\previews\belly_all_tiers_order_fixed_check.png`
- Renderer preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\previews\belly_tier_3_4_order_fixed_renderer_position_preview.png`

## Enlarged Offset Correction

- Updated: `2026-07-02T13:46:04`
- Backup: `E:\Linxi's evaluation adventure\work_backup\intake_layers_before_belly_enlarge_offset_fix_20260702-134603`
- Tier 3 enlarged to about `106px` visible width.
- Tier 4 enlarged to about `118px` visible width.
- Both overlays shifted `5px` right and `3px` up.
- All-tier preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\previews\belly_all_tiers_enlarged_offset_check.png`
- Renderer preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\previews\belly_tier_3_4_enlarged_offset_renderer_position_preview.png`

## Left Curve Correction

- Updated: `2026-07-02T16:24:08`
- Backup: `E:\Linxi's evaluation adventure\work_backup\intake_layers_before_belly_left_curve_fix_20260702-162408`
- Applied an upper-left contour tuck to tiers 2-4 so the belly reads closer to Linxi's torso curve.
- No bridge layer is used; this is a belly silhouette-only correction.
- All-tier preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\previews\belly_left_curve_all_tiers_check.png`
- Before/after preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\previews\belly_left_curve_before_after.png`
- Renderer preview: `E:\Linxi's evaluation adventure\source_assets\linxi\t_early\intake_layers\belly\replacement_2026_07_02\previews\belly_left_curve_renderer_position_preview.png`
