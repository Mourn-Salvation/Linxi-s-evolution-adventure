# Red Night Asset Manifest

## Accepted Runtime Assets

Note: runtime animation frames remain under `assets/`. Heavy raw/source assets now live in `E:\Linxi_Production_Archive\source_assets\` and are indexed by `source_assets/archive_index/external_source_assets_index.csv`. Non-runtime full sheets, contact sheets, raw magenta packs, and preview sheets that were not referenced by scenes/scripts/resources were moved out of `assets` during the runtime-boundary cleanup and then archived externally.

### Safe House Memory Classroom Background

- Runtime: `assets/backgrounds/safe_house/memory_classroom.png`
- Accepted source raw: `source_assets/safe_house/memory_classroom/memory_classroom_v2_noon_pixel_raw.png`
- Accepted source crop: `source_assets/safe_house/memory_classroom/memory_classroom_v2_noon_pixel_1280x720.png`
- Accepted prompt: `source_assets/safe_house/memory_classroom/memory_classroom_v2_noon_pixel.prompt.txt`
- Preserved V1 source raw: `source_assets/safe_house/memory_classroom/memory_classroom_raw.png`
- Use: Bright noon memory-room safe-house background. Human Linxi stands small at center in front of the blackboard; station signs render over the scene.
- Status: V2 accepted for in-game scene direction. V1 is preserved as a more cinematic/dusk-like rejected reference.

### Fall Site School Background

- Runtime: `assets/backgrounds/red_night/fall_site_school.png`
- Source: `source_assets/red_night/backgrounds/fall_site_school.png`
- Prompt: `source_assets/red_night/backgrounds/fall_site_school.prompt.txt`
- Use: Late-map dorm/school-building landmark plate. It fades in near the end of the Red Night map instead of staying centered for the whole stage.
- Status: Accepted as destination landmark.

### School Exterior Ultra-Wide Background

- Runtime: `assets/backgrounds/red_night/school_exterior_ultrawide.png`
- Source: `source_assets/red_night/backgrounds/school_exterior_ultrawide_v3_stitched.png`
- Prompt: `source_assets/red_night/backgrounds/school_exterior_ultrawide.prompt.txt`
- Use: Early Red Night scenery plate behind the fake-3D combat belt. The composition keeps the center play area open and pushes school buildings/sports field context into a wide campus view.
- Status: Accepted stitched pass. V1 is preserved for left/center mood, with V2 blended into the right side to complete the panorama.

### School-To-Dorm Connector Background

- Runtime: `assets/backgrounds/red_night/school_to_dorm_connector.png`
- Source: `source_assets/red_night/backgrounds/school_to_dorm_connector.png`
- Prompt: `source_assets/red_night/backgrounds/school_to_dorm_connector.prompt.txt`
- Use: Mid-map Red Night scenery segment that connects the school sports-field/courtyard view to the dorm/teaching-building entrance view.
- Status: Accepted as middle puzzle-piece background segment.

### Classroom Chase Cutscene Plate

- Runtime: `assets/cutscenes/red_night/classroom_chase.png`
- Source: `source_assets/red_night/cutscenes/classroom_chase.png`
- Prompt: `source_assets/red_night/cutscenes/classroom_chase.prompt.txt`
- Use: Post-nebulizer blackout/chase cutscene overlay.
- Status: Accepted for first runtime pass.

### Dropped Chopper Nebulizer

- Runtime: `assets/props/red_night/chopper_nebulizer/dropped_nebulizer.png`
- Runtime sheet: `assets/props/red_night/chopper_nebulizer/nebulizer_sheet_transparent.png`
- Source sheet: `source_assets/red_night/props/chopper_nebulizer/raw-sheet-v2-impact-pod.png`
- Processed source: `source_assets/red_night/props/chopper_nebulizer/processed_v2_impact_pod/`
- Prompt: `source_assets/red_night/props/chopper_nebulizer/prompt-v2-impact-pod.txt`
- Drink-aligned prop clip: `source_assets/red_night/props/chopper_nebulizer/drink_animation_clip_20260617/dropped_nebulizer_from_drink_frame.png`
- Use: Interactive blue stock solution prop.
- Status: Accepted for runtime. The current ground prop is clipped from the accepted drink animation so the prop scale matches before and during the interaction.

### Red Night Story Item Props

- Runtime folder: `assets/props/red_night/story_items/`
- Runtime files:
  - `security_panel_claw_marked.png`
  - `dormitory_entrance_marker.png`
  - `su_ruo_room_door_marker.png`
  - `roof_stairwell_marker.png`
  - `su_ruo_student_id.png`
- Source attempts: `source_assets/red_night/props/story_items/generated_pack_20260617/`
- Rejection note: `source_assets/red_night/props/story_items/generated_pack_20260617/REJECTED.txt`
- Use: Replacement targets for Red Night interactables: claw-marked security panel, dormitory entrance, Su Ruo room, roof stairwell, and Su Ruo ID clue.
- Status: Preserved but not currently placed in Red Night. The playable Red Night map is temporarily stripped back to only the chopper nebulizer while the scene flow is redesigned. The source attempts in `generated_pack_20260617/` are rejected because they came from the same stale `.codex/generated_images` lookup mistake, not from a verified approved prop sheet. These filenames are stable replacement targets for later approved ComfyUI/Sprite Forge prop art.

### Linxi Drinks Blue Stock Solution

- Runtime frames: `assets/sprites/linxi/t_early/story/drink_blue/`
- Runtime sheet: `assets/sprites/linxi/t_early/story/drink_blue/sheet-transparent.png`
- Source sheet: `source_assets/red_night/characters/linxi_drink_blue/raw-sheet.png`
- Processed source: `source_assets/red_night/characters/linxi_drink_blue/processed/`
- Prompt: `source_assets/red_night/characters/linxi_drink_blue/prompt-used.txt`
- Use: Press F near the chopper-dropped nebulizer to play Linxi pulling the vial free and drinking it before the blackout chase.
- Status: Accepted for first runtime pass. Processor reported no edge-touch frames.

### Linxi Gets Up From The Ground

- Runtime frames: `assets/sprites/linxi/t_early/story/get_up/`
- Runtime sheet: `assets/sprites/linxi/t_early/story/get_up/sheet-transparent.png`
- Source sheet: `source_assets/red_night/characters/linxi_get_up/raw-sheet-v2-safe-margin.png`
- Processed source: `source_assets/red_night/characters/linxi_get_up/processed_v2_safe_margin/`
- Use: Red Night opening story pose `STAND_UP`, replacing the old rotated idle placeholder.
- Status: Accepted for first runtime pass, then normalized for runtime scale after playtest showed the final standing frame was larger than idle/walk. Current final standing frame is locked near `218 px` visible height with bottom anchor `245`. Backup before normalization: `work_backup/linxi_height_normalization_20260616_201046/story_get_up/`.

### Linxi Weak Walk V3 Anatomical

- Runtime frames: `assets/sprites/linxi/t_early/walk_horizontal/right_00.png` through `right_07.png`, mirrored as `left_00.png` through `left_07.png`
- Runtime sheet: `assets/sprites/linxi/t_early/walk_horizontal/weak_walk_v3_sheet-transparent.png`
- Compatibility runtime sheet: `assets/sprites/linxi/t_early/walk_horizontal/weak_walk_v2_sheet-transparent.png`
- Source raw: `source_assets/characters/linxi_t_early/weak_walk_v3_anatomical/raw-sheet-generated.png`
- Final source sheet: `source_assets/characters/linxi_t_early/weak_walk_v3_anatomical/weak_walk_v3_protected_mask_sheet-transparent.png`
- Final source strip: `source_assets/characters/linxi_t_early/weak_walk_v3_anatomical/right-strip-protected-mask.png`
- Prompt: `source_assets/characters/linxi_t_early/weak_walk_v3_anatomical/prompt-used.txt`
- Notes: `source_assets/characters/linxi_t_early/weak_walk_v3_anatomical/README.md`
- Backup of previous runtime walk: `work_backup/weak-walk-before-v3-anatomical/`
- Use: Eight-frame anatomical weak walk following Contact, Down, Up, Swing, then loop. The legs now visibly move through heel strike, mid-stance, heel-off, and swing phases.
- Status: Accepted runtime replacement for V2. The first postprocess pass was rejected because global style matching and heavy edge darkening made the skirt/tights read as glossy black metal. The current protected-mask runtime rebuild preserves the raw generated color layer, uses stable bottom anchors, mirrored left-facing frames, connected-background extraction, guide-line cleanup, and local-neighbor despill limited to a `5-6 px` edge band. A later internal hard-key cleanup removed trapped `#FF00FF` background pixels in negative spaces, including frame 3's leg gap, without recoloring character material. The runtime animation order was then rotated to old frames `[01, 02, 03, 04, 05, 06, 07, 00]` so the loop begins with a compact right-foot step instead of a wide mid-stride pose. Current runtime pass locks all 16 walk frames to `216 px` visible height and bottom anchor `245` to prevent head bobbing. Backup before normalization: `work_backup/linxi_height_normalization_20260616_201046/walk_horizontal/`.

### Linxi Weak Walk 16F Close-Legs Candidates

- V1 source: `source_assets/characters/linxi_t_early/walk_16f_close_legs_v1/`
- V2 source: `source_assets/characters/linxi_t_early/walk_16f_close_legs_v2/`
- V1 aligned preview: `source_assets/characters/linxi_t_early/walk_16f_close_legs_v1/bottom_aligned_preview/right-strip-bottom-aligned.png`
- V2 aligned preview: `source_assets/characters/linxi_t_early/walk_16f_close_legs_v2/bottom_aligned_preview/right-strip-bottom-aligned.png`
- Use: Candidate replacement direction for weak walk. Motion plan starts with legs close together, then opens/closes the right leg and opens/closes the left leg.
- Status: Candidate only, not integrated into runtime. The bottom-anchor tool revealed V1 had a raw bottom spread of `40 px` and V2 had a raw bottom spread of `18 px`. Both rebuilt previews now use explicit clipped shifting and main-component cleanup; top 8 strip rows contain `0` visible pixels and all aligned bottoms are Y `296`.

### Linxi Idle V3 User Color Grade

- Runtime frames: `assets/sprites/linxi/t_early/weak_idle/00_idle_00.png` through `03_idle_03.png`
- Runtime sheet: `assets/sprites/linxi/t_early/weak_idle/sheet-transparent.png`
- Accepted source sheet: `source_assets/characters/linxi_t_early/idle_v3_user_color_grade/sheet-transparent.png`
- Style-matched source sheet: `source_assets/characters/linxi_t_early/idle_v3_user_color_grade/sheet-transparent-stylematch-walk-edge-darkened.png`
- Runtime comparison preview: `source_assets/characters/linxi_t_early/idle_v3_user_color_grade/idle-walk-stylematch-final-preview.png`
- Accepted source notes: `source_assets/characters/linxi_t_early/idle_v3_user_color_grade/README.md`
- Generation source sheet: `source_assets/characters/linxi_t_early/idle_v3_white_uniform/raw-sheet.png`
- Generation processed source: `source_assets/characters/linxi_t_early/idle_v3_white_uniform/processed/`
- Generation prompt: `source_assets/characters/linxi_t_early/idle_v3_white_uniform/prompt-used.txt`
- Backups of previous runtime idle: `work_backup/weak-idle-before-combat-matching-v2/`, `work_backup/weak-idle-before-shirt-white-correction/`, `work_backup/weak-idle-before-full-costume-palette-correction/`, `work_backup/weak-idle-before-v3-white-uniform/`, `work_backup/weak-idle-before-v3-user-color-grade/`, `work_backup/weak-idle-before-v3-user-color-grade-scale94/`, `work_backup/weak-idle-before-style-match-to-walk/`
- Use: Gameplay standing/idle loop matching the accepted walk/attack costume palette: cold white blouse, dark teal-black skirt, black tights, pale infected skin, and sharper blue-green grading.
- Status: User color-graded V3 accepted for runtime, then matched against the accepted weak-walk sheet with `tools/match_sprite_style.py` and an edge-only darkening pass. V2 and earlier palette-corrected variants were rejected for reading too brown. Runtime content was scaled to 94% with bottom foot anchors preserved so the bent idle posture is not taller than the walk cycle. Transparency was preserved and the final diagnostic found no remaining pink-edge pixels on the idle sheet.

### Linxi Dodge

- Runtime frames: `assets/sprites/linxi/t_early/dodge/right_00.png` through `right_03.png`, mirrored as `left_00.png` through `left_03.png`
- Runtime sheet: `assets/sprites/linxi/t_early/dodge/sheet-transparent.png`
- Source sheet: `source_assets/characters/linxi_t_early/dodge/raw-sheet.png`
- Processed source: `source_assets/characters/linxi_t_early/dodge/processed/`
- Prompt: `source_assets/characters/linxi_t_early/dodge/prompt-used.txt`
- Use: Locked dodge animation while the player has dodge invulnerability.
- Status: Accepted for first runtime pass. Processor reported no edge-touch frames, followed by magenta/purple edge cleanup.

### Linxi Claw Attack

- Runtime frames: `assets/sprites/linxi/t_early/claw_attack/right_00.png` through `right_05.png`, mirrored as `left_00.png` through `left_05.png`
- Runtime sheet: `assets/sprites/linxi/t_early/claw_attack/sheet-transparent.png`
- Source sheet: `source_assets/characters/linxi_t_early/claw_attack/raw-sheet.png`
- Processed source: `source_assets/characters/linxi_t_early/claw_attack/processed/`
- Prompt: `source_assets/characters/linxi_t_early/claw_attack/prompt-used.txt`
- Use: Three-phase body attack animation for the default claw chain: right-arm down cut, left-arm cross cut, right-arm finishing rake.
- Status: Accepted for first runtime pass. Processor reported no edge-touch frames, followed by magenta/purple edge cleanup.

### Claw Slash Effect Aliases

- Runtime red alias: `assets/effects/combat/claw_slash/red/right_00.png` through `right_05.png`, mirrored as `left_00.png` through `left_05.png`
- Runtime silver alias: `assets/effects/combat/claw_slash/silver/right_00.png` through `right_05.png`, mirrored as `left_00.png` through `left_05.png`
- Source sheet: `source_assets/effects/claw_slash/raw-sheet-silver.png`
- Processed source: `source_assets/effects/claw_slash/processed_silver/`
- Prompt: `source_assets/effects/claw_slash/prompt-used.txt`
- Use: Reusable slash afterimage family. Red is used for virus/body attacks; silver is reserved for steel or non-virus weapon attacks.
- Status: Accepted for first runtime pass.

### Linxi Hit Reaction

- Runtime frames: `assets/sprites/linxi/t_early/hit_reaction/right_00.png` through `right_03.png`, mirrored as `left_00.png` through `left_03.png`
- Runtime sheet: `assets/sprites/linxi/t_early/hit_reaction/sheet-transparent.png`
- Source sheet: `source_assets/characters/linxi_t_early/hit_reaction/raw-sheet.png`
- Processed source: `source_assets/characters/linxi_t_early/hit_reaction/processed/`
- Prompt: `source_assets/characters/linxi_t_early/hit_reaction/prompt-used.txt`
- Use: Linxi hurt reaction while `player_hit_reaction_time` is active.
- Status: Accepted for first runtime pass. Processor reported no edge-touch frames, followed by magenta/purple edge cleanup.

### Human Student Non-Combat Run

- Runtime frames: `assets/sprites/enemies/human_student/run/right_00.png` through `right_07.png`, mirrored as `left_00.png` through `left_07.png`
- Runtime appearance frames: `assets/sprites/enemies/human_student/run/appearance_right.png`, `assets/sprites/enemies/human_student/run/appearance_left.png`
- Runtime female variant: `assets/sprites/enemies/human_student/run_female/`
- Runtime sheet: `assets/sprites/enemies/human_student/run/sheet-transparent.png`
- Accepted source: `source_assets/enemies/human_student/run_v3_user_clipboard_male/raw-sheet.png`
- Accepted processed source: `source_assets/enemies/human_student/run_v3_user_clipboard_male/processed/`
- Accepted note: `source_assets/enemies/human_student/run_v3_user_clipboard_male/ACCEPTED.txt`
- Accepted candidate variant: `source_assets/enemies/human_student/run_v3_user_clipboard_female/`
- Rejected/stale integration notes: `source_assets/enemies/human_student/run/REJECTED.txt`, `source_assets/enemies/human_student/derived_runtime_v1/README.md`
- Use: Human-family non-combat `human_student` enemy archetype. The run cycle is used when `NON_COMBAT_WANDER` is active; the appearance frame is used when dormant or static. `appearance_id = 0` selects the male variant and `appearance_id = 1` selects the female variant. Red Night currently uses the female variant.
- Status: Accepted from the user-provided male and female human-student run sheets. The earlier G-mode-looking integration was a file-selection error: the script copied a stale image from `.codex/generated_images` instead of the approved clipboard/temp sheet. Future integrations must use the exact approved source path or hash rather than a generic "latest generated image" lookup.

### Enemy Knocked-Down Poses

- Human guard runtime: `assets/sprites/enemies/human_guard/knocked_down/`
- Human student male runtime: `assets/sprites/enemies/human_student/knocked_down/`
- Human student female runtime: `assets/sprites/enemies/human_student/knocked_down_female/`
- Zombie student runtime variants: `assets/sprites/enemies/zombie_student/knocked_down/`
- Contact sheet archive: `source_assets/runtime_boundary_cleanup_20260618/moved_from_assets/assets/sprites/enemies/spritesheet_knocked_down_contact.png`
- Accepted source: `source_assets/enemies/knocked_down_user_approved_v3/raw_knocked_down_pose_sheet.png`
- Accepted source SHA-256: `21EE3A637AA4E5E3FF0158DF1BE392E3DFD6D3C1B558CCF404EB896202ED51E9`
- Rebuild tool: `tools/process_enemy_knocked_down_sheet.py`
- Source notes: `source_assets/enemies/knocked_down_user_approved_v3/README.md`
- Rejected/stale notes: `source_assets/enemies/knocked_down_derived_v1/README.md`, `source_assets/enemies/knocked_down_generated_v2/README.md`
- Use: Drawn when enemies enter `KNOCKED_DOWN` or reach `0 HP`, preserving zombie `appearance_id` and human-student gender variant selection.
- Status: Accepted from the explicit user-provided knocked-down pose sheet. The earlier derived pass looked like clipped animation frames, and the generated V2 pass was a wrong-source cache pick. Future integrations must process only the exact approved image path/hash, never the newest generated cache file. Mutant/procedural enemies currently use a flattened procedural fallback pose because no final mutant sprite sheet exists yet.

### Provisional Enemy Animation Contract Pass

- Human guard runtime move: `assets/sprites/enemies/human_guard/move/`
- Human guard runtime attack: `assets/sprites/enemies/human_guard/attack/`
- Human guard runtime hurt: `assets/sprites/enemies/human_guard/hurt/`
- Zombie student runtime move: `assets/sprites/enemies/zombie_student/move/variant_00/` through `variant_03/`
- Zombie student runtime attack: `assets/sprites/enemies/zombie_student/attack/variant_00/` through `variant_03/`
- Zombie student runtime hurt: `assets/sprites/enemies/zombie_student/hurt/variant_00/` through `variant_03/`
- Human student hurt runtime: `assets/sprites/enemies/human_student/hurt/`
- Human student female hurt runtime: `assets/sprites/enemies/human_student/hurt_female/`
- Source/metadata: `source_assets/enemies/derived_provisional_enemy_animation_20260618/`
- Use: Completes the current renderer contract for enemy move, attack, hurt, and knocked-down states. Combat enemies use move frames while approaching, attack frames while telegraphing/recovering, and hurt frames during hit stun. Zombie variants keep their `appearance_id` for move/attack/hurt so damage no longer swaps them to another model.
- Status: Provisional runtime pass derived from verified accepted enemy sprites because the attempted fresh image-generation output folder returned stale unrelated G-mode material. This is acceptable for gameplay polish, but not final art approval. Replace these folders with true approved generated/Sprite Forge/ComfyUI sheets when the art pipeline is stable.

### Human Guard Hit Reaction

- Runtime frames: `assets/sprites/enemies/human_guard/hit_reaction/right_00.png` through `right_03.png`, mirrored as `left_00.png` through `left_03.png`
- Runtime sheet: `assets/sprites/enemies/human_guard/hit_reaction/sheet-transparent.png`
- Source sheet: `source_assets/enemies/human_guard/hit_reaction/raw-sheet.png`
- Processed source: `source_assets/enemies/human_guard/hit_reaction/processed/`
- Prompt: `source_assets/enemies/human_guard/hit_reaction/prompt-used.txt`
- Use: Human-family stagger presentation.
- Status: Accepted for first runtime pass. Processor reported no edge-touch frames, followed by magenta/purple edge cleanup.

### Zombie Student Hit Reaction

- Runtime frames: `assets/sprites/enemies/zombie_student/hit_reaction/right_00.png` through `right_03.png`, mirrored as `left_00.png` through `left_03.png`
- Runtime sheet: `assets/sprites/enemies/zombie_student/hit_reaction/sheet-transparent.png`
- Source sheet: `source_assets/enemies/zombie_student/hit_reaction/raw-sheet.png`
- Processed source: `source_assets/enemies/zombie_student/hit_reaction/processed/`
- Prompt: `source_assets/enemies/zombie_student/hit_reaction/prompt-used.txt`
- Use: Zombie-family stagger presentation.
- Status: Accepted for first runtime pass. Processor reported no edge-touch frames, followed by magenta/purple edge cleanup.

### Female Zombie Student Appearance Variants

- Runtime frames: `assets/sprites/enemies/zombie_student/appearance_variants/right_00.png` through `right_03.png`, mirrored as `left_00.png` through `left_03.png`
- Runtime sheet: `assets/sprites/enemies/zombie_student/appearance_variants/sheet-transparent.png`
- Source sheet: `source_assets/enemies/zombie_student/appearance_variants/raw-sheet.png`
- Processed source: `source_assets/enemies/zombie_student/appearance_variants/processed/`
- Prompt: `source_assets/enemies/zombie_student/appearance_variants/prompt-used.txt`
- Use: Map-driven zombie-family visual variety. `appearance_id` selects which adult female infected school student sprite to draw while preserving shared zombie AI.
- Status: Accepted for first runtime pass. Processor reported no edge-touch frames, followed by magenta/purple edge cleanup.

### Linxi Biomass Tail Ready Overlay

- Runtime frames: `assets/sprites/linxi/t_early/tail_ready_overlay/right_00.png` through `right_03.png`, mirrored as `left_00.png` through `left_03.png`
- Runtime sheet: `assets/sprites/linxi/t_early/tail_ready_overlay/sheet-transparent.png`
- Accepted T-form source sheet: `source_assets/characters/linxi_t_tail/ready_overlay_v2_slim/raw-sheet.png`
- Accepted T-form processed source: `source_assets/characters/linxi_t_tail/ready_overlay_v2_slim/processed/`
- Accepted T-form prompt: `source_assets/characters/linxi_t_tail/ready_overlay_v2_slim/prompt-used.txt`
- Preserved heavier V1 source: `source_assets/characters/linxi_t_tail/ready_overlay/raw-sheet.png`
- Design brief: `source_assets/characters/linxi_t_tail/tail-design-brief.md`
- Use: Unlockable behind-body overlay for Linxi's developed T-form tail. Runtime draws it only when `tail_unlocked` is true.
- Status: V2 slim accepted for T-form runtime. Processor reported no edge-touch frames, followed by magenta/purple edge cleanup. V1 is kept as a possible heavier G-form reference. Placement may need offset tuning after visual playtest.

### Virus Hit Mist And Ground Spread

- Runtime mist frames: `assets/effects/combat/virus_mist_hit/00.png` through `03.png`
- Runtime ground frames: `assets/effects/combat/virus_liquid_ground_spread/00.png` through `03.png`
- Mist source: `source_assets/effects/virus_mist_hit/raw-sheet.png`
- Ground source: `source_assets/effects/virus_liquid_ground_spread/raw-sheet.png`
- Prompts: `source_assets/effects/virus_mist_hit/prompt-used.txt`, `source_assets/effects/virus_liquid_ground_spread/prompt-used.txt`
- Use: Red virus impact mist and liquid floor spread spawned by hit events.
- Status: Accepted for first runtime pass after magenta/purple edge cleanup.

## Briefed But Not Generated

### Linxi T-form Collapse

- Brief: `source_assets/red_night/characters/linxi_standup_collapse_brief.md`
- Reason: Get-up has been generated and integrated. Collapse after drinking still uses the current runtime pose until a dedicated collapse sheet is produced.
