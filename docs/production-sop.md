# Production SOP

This document is the operational checklist for adding new playable content to Linxi's Evolution Adventure. It exists to prevent the project from drifting into hardcoded one-off fixes.

When this SOP conflicts with a domain document, use the domain document for design detail and this SOP for execution order.

## Core Rule

Before adding anything, classify the work:

- **Story/campaign content:** update `StageData`, `LevelData`, `MapData`, story flags, objectives, and campaign docs.
- **Gameplay tuning:** update resources such as balance, attack data, AI profile data, or map spawn dictionaries.
- **Runtime behavior:** update scripts only when data resources cannot express the required behavior.
- **Art/content asset:** follow the asset pipeline, record exact source path and hash, then export accepted runtime files into `assets`.

Do not put new story flow, enemy placement, item placement, or encounter design directly into `main.gd`.

## Add A New Level

1. **Write the level brief.**
   - Stage id and level id.
   - Display name.
   - One-sentence story purpose.
   - Player goal and objective text.
   - Camera mode: `SCROLLING` for large exploration/combat lanes, `FIXED_ROOM` for dorms, classrooms, shelters, offices, and other small spaces.
   - Expected story flags, unlocks, tutorial purpose, or shelter/save point.

2. **Update planning docs.**
   - Update `docs/campaign-stage-plan.md` with the level's campaign role.
   - Update combat, progression, or art docs only if the level introduces new rules.

3. **Create or update the map resource.**
   - Add a `MapData` resource under `resources/maps/`.
   - Set `map_id`, `display_name`, `encounter_id`, `objective`, `story_id`, and `environment_theme`.
   - Set `footstep_surface` to match the player-readable floor material: `WET`, `CONCRETE`, `MARBLE`, or `GRASS`.
   - Set `length`, `depth`, and `player_spawn`.
   - Define `walkable_areas` before placing enemies, items, blockers, or route exits. These areas are the authored floor plan: where actors are allowed to stand and move. Use `position` plus `size` for rectangular floor bands, and `points` polygons for stair runs, wall-door approaches, angled landings, or other irregular walkable shapes.
   - Use `blocked_areas` only after `walkable_areas` are set, for stairs, furniture, walls, railings, counters, and other structure inside or beside the playable floor.
   - For fixed-room maps, trace the visible floor patches and route landings. For scrolling maps, define lane rectangles that match the generated floor band. For hallway maps, make the lane deep enough for the player to move from the foreground/bottom of the screen to wall-side doors. In map coordinates, low Y is the back/wall side and high Y is the foreground/bottom side.
   - Match `footstep_surface` to the authored floor band, not just the background theme. A rainy courtyard can be `WET`, a dorm lobby can be `MARBLE`, a hallway can be `CONCRETE`, and a sports field or grassy route can be `GRASS`.
   - Place `player_spawn`, enemies, items, and transition interaction points inside `walkable_areas`; the content validator should reject placements outside the playable floor.
   - In `development_mode`, open the pause menu and press `Dev Overlay` to read exact mouse coordinates and inspect map bounds, walkable zones, and blockers in-game before committing coordinate edits.
   - Author `enemy_spawns` and `items` in the map resource.
   - For exits or route changes, add a `type = "transition"` item with `destination_name` and `target_scene`. Use the glowing circle for ground/area exits. For wall-door exits, use a prop texture that covers a real door and set `show_transition_circle = false`. On scrolling stitched maps, mark the wall-door art with `background_prop = true` and place it with `background_anchor`; keep the transition `position` as the invisible interaction point.
   - Gate route items with `required_story_flag` when the destination should stay locked until a clue or plot beat is found. Let clue items set that flag with `set_story_flag`.
   - For a transition that commits the player into a shelter or next-stage gate, add `stage_boundary = true`. Normal transitions omit it and remain return-allowed inside the current stage.
   - Use `story_group`, `ai_profile`, `appearance_id`, and `attack_type` instead of hardcoding special cases by id.
   - For rescue or fate-choice beats, put the protected NPC in `enemy_spawns` and the conversation in a `type = "dialogue"` item at the same authored position. Use `required_defeated_group` on the dialogue item to lock conversation until the threat group is down. Use `vore_locked_until_group_defeated` on the NPC enemy entry when the NPC must not become a Vore target before that threat group is cleared.
   - Dialogue items may include `avatar_path`; accepted portraits belong under `assets/ui/dialogue_portraits/`. A dialogue item may also include a `choice` dictionary for a post-conversation YES/NO decision, including flags, HUD messages, optional enemy state changes, and optional item deactivation.

4. **Create the level resource.**
   - Add a `LevelData` resource under `resources/levels/`.
   - Name it with the stage and level number, such as `stage_01_level_02_<slug>.tres`.
   - Reference the new `MapData`.

5. **Register the level in the stage resource.**
   - Add the `LevelData` to the owning `StageData.levels` array.
   - Keep level ordering in `StageData`, not script branches.

6. **Add level art and props.**
   - Raw/generated candidates go in `source_assets`.
   - Heavy raw/source candidates go in `E:\Linxi_Production_Archive\source_assets\`; keep only lightweight manifests, prompts, and index files in the Godot project.
   - Accepted runtime art goes in `assets`.
   - Do not create production map, prop, actor, UI, or FX art with Godot `draw_*` code or self-drawn placeholder pixels. Drawn/procedural output is allowed only as developer-only debug presentation or a clearly marked temporary placeholder kept out of normal player-facing gameplay. If approved runtime art is missing, render the object invisible or fail validation instead of drawing an improvised shape.
   - Background scenery, gameplay floors, interactable props, doors, exits, and collision are separate authored pieces. Do not rely on background pixels for collision or interaction.
   - When generating a new map background, approve the playable floor layout first. If the background does not give us a clear walkable band, landing, or room floor, regenerate the background before adding gameplay.
   - For traversal backgrounds, use the approved 21:9 side-readable map pattern from `docs/art-direction.md`: broad playable lower band, visible fake-3D floor depth, actor scale for 160-190 cm characters, and physical route objects.
   - Treat every new traversal map as a **map generation mission**, not as a request for loose background pictures:
     1. Define the gameplay role first: route purpose, time of day, camera mode, expected `length`, `depth`, walkable band, entrances/exits, and major landmarks.
     2. Gather only approved visual references. Do not use rejected or unapproved candidates as generation references.
     3. Generate one full-route panorama candidate that already contains the whole physical space. The prompt must say it is a single source panorama, not separate plates.
     4. Review the full panorama before slicing. It must read as one camera, one horizon, one floor plane, one light direction, and one location.
     5. Slice/crop the approved full panorama into runtime plates only after user approval.
     6. Generate a sliced strip preview and runtime camera-sample preview before wiring `MapVisualData`.
     7. Wire the map only after the previews pass. Runtime plates are slices of the approved source, not independent generations.
   - Only use the approved-candidate extension workflow when a true locked-canvas/outpaint/inpaint process is available:
     1. User approves the candidate side that has the correct view, scale, time, and art direction.
     2. Place the approved candidate into a wider unfilled canvas as the locked left, right, or center area.
     3. Fill only the missing side of that canvas, preserving the approved side unchanged.
     4. Review the filled full-width image as one panorama.
     5. Split or crop the approved panorama into runtime plates only after the full image reads as one single map.
   - If locked-canvas editing is not available, regenerate the whole full-route panorama instead of making a free-standing continuation plate.
   - Do not generate a free-standing left/right continuation from a text prompt plus a visual reference and wire it directly into runtime. That method can match mood while still creating a different camera shot. It is allowed only as a concept candidate, never as an accepted multi-plate map.
   - Multi-plate approval requires a stitched strip preview before runtime wiring. Reject any pair that reads as a new camera shot, even if each plate looks good alone.
   - Multi-plate acceptance checklist: one horizon, one light direction, one camera height, continuous floor/tile/track scale, continuous fence/wall/building rhythm, no duplicated landmark or sun, no sudden perspective swing, and one uninterrupted playable floor band.
   - Every continuation prompt must explicitly lock horizon height, floor grid/perspective, parapet or wall height, lighting direction, time of day, material scale, actor scale, and landmark continuity from the approved neighboring plate.
   - For stairs, generate the route as architecture first: stair base, landing, railings, and upper/lower exits. Then author the actual stair interaction as map data or a runtime object.
   - For paired maps, generate them as connected spaces. Example: a dormitory lobby switchback stair should lead into a second-floor hallway image with a matching stair landing at the arrival edge.
   - Put accepted background image paths, blend timing, and any scrolling or fixed-room background scale/offset in a `MapVisualData` resource, then assign it to `MapData.visual_data`.
   - For multi-image traversal maps, set `stitch_background_layers = true` and keep fade arrays empty. Background plates should behave like exported pieces of one long panorama, not like cinematic shot changes.
   - Generate strip and runtime-sample previews for every scrollable map after changing plates or `MapVisualData`. Keep them under `docs/previews/scrollable_maps/` and update the QA note when a map remains blockout-only or needs regeneration.
   - Scrolling maps must use the shared Projection dead-zone camera. Background movement should use the same `camera_x / camera_max_x` range as actor projection; do not add a separate background denominator, parallax, or smoothing value that makes the stitched map drift at a different speed from Linxi.
   - Give each meaningful physical route its own `MapVisualData`. Sharing a visual resource across different locations is allowed only as a marked temporary blockout.
   - When only one side is wrong, either rebuild it through a true locked-canvas extension workflow or regenerate the whole full-route panorama. Do not keep iterating by swapping in more standalone plates.
   - If a stitched preview still reads as "two maps placed together", mark the asset as provisional or revert to the last accepted shorter route. The next attempt must be a full panorama regeneration or locked-canvas extension, not another independent side plate.
   - If a map is shortened by removing background plates, shorten `MapData.length` and move route exits, enemies, and story groups so gameplay still occurs inside the visible art. Update tests and docs with the new coordinate anchors.
   - For `FIXED_ROOM` maps, compare Linxi's rendered visible height against doors, beds, desks, and other human-scale background objects before approval. If the image looks oversized, reduce `fixed_room_background_scale` instead of changing Linxi's player scale.
   - When a correctly scaled map leaves black-box framing around the image, keep `fill_viewport_with_scaled_backing` enabled so `MapRenderer` fills the viewport with a dark backing copy of the same approved art. Do not solve framing by scaling the playable map back up until architecture becomes too large.
   - Put foreground occluders such as rails, fences, window frames, and near-camera architecture in `MapVisualData.foreground_layers`; they should draw after actors so map depth reads correctly.
   - Do not add new background preload tables to `main.gd`; background presentation belongs to `MapRenderer`.
   - Put accepted interactable prop textures, item sizes, offsets, and route-circle FX in an `ItemVisualData` resource, then assign it to `MapData.item_visual_data`.
   - Do not add new item prop preload tables to `main.gd`; item presentation belongs to `ItemRenderer`.
   - Put accepted combat/story FX frames in an `EffectVisualData` resource. Effect drawing belongs to `EffectRenderer`, while gameplay scripts should only create effect events.

7. **Integrate save/checkpoint behavior.**
   - Active encounters do not permanently save enemy state.
   - Confirmed map switches save a route checkpoint plus allowed Linxi/story progression.
   - Completed encounters may open a Shelter Page or move to a Safe House checkpoint.
   - Before a stage-boundary transition, the player may return to currently unlocked maps. After confirming the next stage, normal return is locked.
   - Shelters should be authored as fixed-room maps first, then layered with save/status/archive UI when the checkpoint rules are ready.
   - Story-critical item results become story flags or phase changes, not permanent arbitrary item dictionaries.

8. **Verify.**
   - Run Godot script parse checks for touched scripts.
   - Run content and mechanics tests.
   - Play the level in Godot.
   - Update the relevant manifest after acceptance.

## Add A New Enemy

1. **Define the enemy role before generating art.**
   - Family: `HUMAN`, `ZOMBIE`, or `MUTANT`.
   - Role: neutral wanderer, chaser, guard, heavy, ambusher, story civilian, elite, boss, or other authored role.
   - Required behavior: reuse existing `ai_profile`, attack type, and family logic when possible.
   - Required appearance: decide whether this is a new enemy type or only an `appearance_id` variant.

2. **Prefer data over code.**
   - New hair, outfit damage, infection marks, posture, or school role should be an appearance variant.
   - New behavior should first be an `ai_profile`, attack data, or map-authored profile.
   - New sprite sheets, appearance variants, hurt poses, and knocked-down art belong in a reusable `EnemyVisualLibrary` resource consumed by the enemy visual layer, not in `main.gd`.
   - Do not merge visual preloads into `enemy_component.gd`; it should stay focused on AI/mechanics.
   - Enemy drawing belongs to `EnemyRenderer`; enemy AI should not draw, and `main.gd` should only delegate enemy presentation.
   - Create new enemy script behavior only when family/profile/attack resources cannot express the design.

3. **Follow the art approval order.**
   - Base body/outfit.
   - Idle or neutral stance. Generate and approve one actual planted-feet standing pose for each human-student identity before wiring it. An idle must not be cropped, mirrored, or selected from a walk/run sheet: reject any pose with a stride, running lean, raised knee, or motion-ready arm swing. Current approved human-student runtime idles are versioned under `assets/sprites/enemies/human_student/idle_female_variants_v2/variant_01..05/` and `idle_male_variants_v2/variant_06..07/`. Zombie-student variants also require explicit idle frames under `assets/sprites/enemies/zombie_student/idle/variant_##/`.
   - Walk/wander/run if the enemy moves; default runtime contract is an 8-frame move loop.
   - Hurt reaction; default runtime contract is 2 readable hurt frames.
   - Knocked-down pose.
   - Attack or telegraph body action for combat-capable enemies; default runtime contract is 4 frames unless a level-specific contract says otherwise. Red Night zombie students currently use a two-frame contract: wind-up frame during cast, strike frame during recovery/release. Knife-armed human students use `assets/sprites/enemies/human_student/attack_knife_male_variants/variant_##/` with the same two-frame cast/release contract, selected by `weapon_id = "knife"`. Non-combat civilians intentionally skip attack sheets.
   - Heavy/cast, recovery, defeated, grab, or special state sheets only when that enemy needs them.
   - Separate FX/decal sheets for hit mist, blood/liquid spread, telegraphs, trails, sparks, or projectiles. Zombie basic attacks should use one vertical red biomass trajectory attached to the arm strike; reserve multi-claw slash FX for Linxi or weapon designs that actually imply multiple cutting paths.

4. **Use the accepted asset pipeline.**
   - Sprite Forge first, Codex image generation second, ComfyUI last.
   - Save the exact approved source under `source_assets`.
   - Record SHA-256 before processing.
   - Never select art by "latest generated image".
   - Never promote self-drawn/procedural placeholder art to runtime as a final enemy asset.
   - If a dedicated processor exists in `tools`, rerun that processor from the approved source path.
   - Mark accepted, rejected, and superseded folders explicitly.
   - Before splitting a raw sheet, inspect every grid cell for contact at the top, bottom, left, and right boundaries. Include hair, footwear, tails, fused anatomy, clothing, and attached weapons in this check.
   - For a complete but crowded source, extend only the solid `#FF00FF` blank canvas or choose a safer grid orientation such as `4x2` for a tall eight-frame actor. Do not resize the character to solve an undersized cell.
   - If the source has already cut off anatomy or a weapon, reject and regenerate it. Padding cannot reconstruct missing pixels.
   - Treat edge-QC failures as evidence to inspect, not as settings to disable. A connected-component diagnostic may distinguish real clipping from isolated matte noise, but the final accepted sheet must still have intact required components and visible padding.

5. **Export runtime files.**
   - Runtime-ready sprites go under `assets/sprites/enemies/<enemy_id>/`.
   - Runtime frames must match the renderer's canvas and anchor rules.
   - Upright idle, move, hurt, telegraph, and attack frames must share one visible-height and bottom-anchor contract for that enemy. Before wiring a new sheet, compare alpha-bounds against the approved idle/move frame for the same `appearance_id`; do not accept an attack frame that makes the enemy appear taller or larger unless the design explicitly calls for a transformation. Runtime rendering also height-locks attack textures to the enemy's move/idle reference, but this is a safety net rather than a substitute for normalized source assets.
   - Export all upright action families to one shared cell size. Measure and record visible alpha-bound height and bottom anchor per frame; normal upright actions should stay within about `10%` of the approved idle/move height.
   - Preview idle, move, hurt, and attack together before integration. Reject model-size jumps, head bob caused by inconsistent top bounds, incomplete feet, clipped weapons, or action-specific scaling.
   - Previous accepted runtime folders must be backed up under `work_backup` before replacement.
   - Update or rebuild the relevant visual library resource, such as `resources/enemies/red_night_enemy_visual_library.tres`. Use `tools/build_enemy_visual_library.gd` for the current Red Night enemy set.

6. **Integrate with map data.**
   - Add enemy instances through `MapData.enemy_spawns`.
   - Use fields such as:
     - `id`
     - `family`
     - `position`
     - `appearance_id`
     - `ai_profile`
     - `initial_state`
     - `story_group`
     - `attack_type`
   - Use `appearance_id` to choose the visual variant while sharing the same AI/mechanic profile.
   - Do not use a new enemy id just to represent a hairstyle or costume variant.

7. **Verify enemy behavior.**
   - Appearance must not change when hit.
   - Knocked-down pose must appear at `0 HP` or `KNOCKED_DOWN`.
   - Normal attack cast must reset on stun.
   - Heavy attack cast must preserve its timer if authored as uninterruptible.
   - Vore, capacity, live-vore chance, and digestion behavior must match combat docs.

## Update Linxi Player Visuals

1. **Use the approved character asset pipeline.**
   - Generate or approve the source sheet first.
   - Record the exact source path and hash.
   - Process frames with the current alignment/chroma cleanup tools.
   - Keep rejected or superseded attempts marked, not deleted.

2. **Export runtime frames.**
   - Runtime-ready Linxi frames go under `assets/sprites/linxi/<form_or_scene>/`.
   - Keep frame canvas, bottom alignment, and character height consistent across idle, walk, sprint, dodge, hit, attack, and story-pose sheets.
   - Use the same cross-action scale and canvas-safety gate as enemies: compare alpha bounds against approved idle/walk, expand blank key-color canvas rather than shrinking one action, and regenerate any source that already contains clipped body parts.
   - Vore/intake visual layers belong with player visuals; gameplay capacity and digestion rules stay in mechanics resources/components.

3. **Rebuild the player visual resource.**
   - Update `tools/build_player_visual_library.gd` when folders or frame counts change.
   - Rebuild `resources/characters/linxi_t_early_visual_library.tres` with:
     `Godot --headless --path <project> --script res://tools/build_player_visual_library.gd`
   - Do not add new Linxi sprite preload tables to `main.gd`.

4. **Verify in scene.**
   - Run parse checks for touched scripts.
   - Run Red Night tests.
   - Play the level and check visual scale, feet alignment, story poses, and combat readability.

## Asset Folder Status

Every production asset folder should be understandable without chat history.

Use these status files:

- `ACCEPTED.txt`: approved source and runtime path.
- `REJECTED.txt`: failed visually or wrong source-selection step.
- `SUPERSEDED.txt`: older valid attempt replaced by a better accepted pass.
- `pipeline-meta.json`: source path, hash, processor, runtime output, backup path, and known caveats.

Rejected and superseded folders are not runtime sources. They stay only for audit and rollback unless the user explicitly approves deletion.

## Drawn Placeholder Gate

Before a feature is accepted, run a small asset audit:

1. Player-facing art must be referenced from `assets` through visual data resources, not authored directly in script drawing code.
2. Any `draw_*` presentation that remains in scripts must be debug-only, fallback-only, or explicitly labeled temporary.
3. Placeholder art must have a replacement plan in the relevant art/effect/enemy/map doc.
4. Obsolete drawn preview assets should be marked as superseded once the approved imported asset exists. Delete them only after explicit user approval.

## Final Acceptance Gate

A new level or enemy is accepted only when:

1. Its story/design purpose is documented.
2. Its data lives in stage, level, map, balance, attack, or enemy profile resources where possible.
3. Runtime scripts were changed only when data could not express the design.
4. Accepted source assets are traceable by exact path and hash.
5. Runtime assets are placed under `assets` and raw/candidates remain under `source_assets`.
6. Rejected/superseded attempts are marked.
7. Godot parse checks and relevant tests pass.
8. The result has been reviewed in the actual scene.
