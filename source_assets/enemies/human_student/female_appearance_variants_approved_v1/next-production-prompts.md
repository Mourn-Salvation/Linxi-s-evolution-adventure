# Female Human Student Variant Production Prompts

Status: approved base design. Use `approved_design_sheet.png` and the extracted transparent references in this folder as the identity source. Do not use files from `female_appearance_variants_provisional_20260618` or `female_appearance_variants_concept_v1`; those folders are rejected.

## Runtime IDs

- `appearance_id = 1`: current existing female student fallback
- `appearance_id = 2`: black ponytail
- `appearance_id = 3`: long straight black hair
- `appearance_id = 4`: blonde hair
- `appearance_id = 5`: red hair

## Approved References

- `appearance_02_black_ponytail.png`
- `appearance_03_long_straight_black_hair.png`
- `appearance_04_blonde_hair.png`
- `appearance_05_red_hair.png`

## Required Runtime Output

For each approved variant, export:

- `assets/sprites/enemies/human_student/run_female_variants/variant_XX/`
  - `right_00.png` through `right_07.png`
  - `left_00.png` through `left_07.png`
  - `appearance_right.png`
  - `appearance_left.png`
- `assets/sprites/enemies/human_student/hurt_female_variants/variant_XX/`
  - `right_00.png`, `right_01.png`
  - `left_00.png`, `left_01.png`
- `assets/sprites/enemies/human_student/knocked_down_female_variants/variant_XX/`
  - `right_00.png`
  - `left_00.png`

## Run Sheet Prompt

Create an 8-frame running/fleeing animation sheet for the approved adult female human student variant.

Use the approved variant design as identity reference. Preserve the exact outfit, hair style, hair color, body proportions, and frightened civilian role. The character is an adult college-age student, not a minor.

Visual style: project-native anime-inspired survival horror sprite art, SIGNALIS-inspired mood but not a copy, crisp silhouette, muted palette, dark outline, pixel-filter-friendly high-resolution art.

Action: terrified run/flee cycle, side view facing RIGHT. The run should feel like a civilian fleeing zombies, not a combat sprint.

Layout: exact 2 rows x 4 columns, one frame per cell, frame order left-to-right then top-to-bottom. Solid pure `#FF00FF` magenta background. Full body inside each cell, stable feet/bottom baseline, consistent scale, generous padding. No borders, labels, shadows, ground plane, weapons, FX, zombies, or extra characters.

Frame intent:

1. right foot contact, body leaning forward
2. weight transfer, arms tight near body
3. push-off, hair trailing
4. short airborne/long stride
5. left foot contact
6. compression, frightened forward lean
7. push-off opposite leg
8. recovery into loop

## Hurt Sheet Prompt

Create a 2-frame hurt reaction sheet for the approved adult female human student variant.

Preserve identity, outfit, hair style, and hair color from the approved design. Side view facing RIGHT. She is struck or startled by a zombie attack and recoils, but no gore spray or exaggerated violence.

Layout: exact 2 rows x 2 columns for generator stability, using only two distinct required poses repeated/held as needed. Solid pure `#FF00FF` magenta background. Full body visible, stable feet/bottom baseline, consistent scale, generous padding. No text, no borders, no extra characters, no FX.

Required poses:

1. impact recoil, shoulders pulled back, frightened expression
2. stagger/bent recovery, arms guarding torso

## Knocked-Down Pose Prompt

Create one knocked-down pose for the approved adult female human student variant.

Preserve identity, outfit, hair style, and hair color from the approved design. She is lying quietly on the ground after being overwhelmed, not mid-animation and not clipped from a running frame.

Composition: side-view game sprite pose, full body visible, lying horizontally, head and limbs readable, modest/non-sexual pose. Solid pure `#FF00FF` magenta background. No text, no borders, no shadows, no zombies, no blood pool, no FX.

## Acceptance Checklist

- Variant identity and hair style are clear at game scale.
- Shirt/skirt/tights match the human-student outfit language.
- No direct pixel edits of existing runtime frames as the source of truth.
- Run frames have stable bottom anchors and no cut feet.
- Hurt has two readable poses.
- Knocked-down pose is quiet and horizontal, not a clipped animation frame.
- Raw/source files are stored in `source_assets` with prompt and metadata.
- Runtime frames are only copied into `assets` after approval.
