# Technical Design

## Runtime

- Godot 4.x
- GDScript
- 2D scenes and sprites
- Compatibility renderer initially

## Project Import Boundary

- Godot should import runtime content only: `assets`, `scenes`, `scripts`, and `resources`.
- `source_assets`, `work_backup`, `tools`, and `docs` are preserved inside the project folder for production history and collaboration, but each has `.gdignore` so Godot does not generate runtime texture imports for raw candidates, backups, tools, or documentation.
- Raw magenta sheets, rejected candidates, original MP4 references, and prompt/workflow files belong in `source_assets`, not runtime `assets`.
- Heavy raw/source material belongs in the external archive `E:\Linxi_Production_Archive\source_assets\`, with lightweight pointers and hashes kept under `source_assets/archive_index/`.
- Accepted runtime assets should be copied or exported into `assets` only after they are approved for in-game use.
- Third-party Godot plugins live under `addons/` and are tracked in `docs/plugin-workflow.md`. Production gameplay must call local adapters/components rather than depending directly on plugin APIs.

## Scene Boundaries

- `Main`: stage host for the currently loaded level. It initializes the runtime components, routes input/process/draw calls, and keeps compatibility wrappers while systems move into reusable components.
- `StageData`: owns a fiction arc such as `Stage 1: Red Night`
- `LevelData`: owns one playable scene/beat inside a stage, such as `Courtyard Fall Site`, and points to the map/encounter payload
- `MapData`: owns encounter flow payload, camera bounds, navigation belt, enemy placement, and item placement
- `MapVisualData`: owns background layers, clear colors, and map presentation tuning used by `MapRenderer`
- `ItemVisualData`: owns interactable prop textures, route-transition FX frames, item sizes, and item presentation offsets used by `ItemRenderer`
- `EffectVisualData`: owns combat effect frames, motion-trail color, and story overlay textures used by `EffectRenderer`
- Runtime components under `Main/Components` own scene flow, player movement, player visuals/rendering, enemy simulation, enemy visuals/rendering, combat, Vore, encounters, interaction, item rendering, weapons, dialogue, map rendering, effect rendering, HUD flow, projection/camera, world FX, debug tools, audio, and story events.
- Custom Resources own balance, attack definitions, stages, levels, maps, encounters, items, story events, and tuning
- Current combat range checks are custom shadow-footprint queries rather than `Area2D` hitbox/hurtbox collisions. If physics hitboxes are added later, they must preserve the same authored reach plus attacker/target shadow-radius logic.

## Audio Routing

- `Audio` is a shared runtime component under `Main/Components`.
- Mechanic-owned sounds, such as Linxi swallowing prey or finishing digestion, are triggered by the owning system/component and should not be authored per map.
- Map-owned sounds, such as rain, sirens, fluorescent buzz, nebulizer hum zones, classroom chaos behind doors, and footstep surface identity, belong in map data or future map audio resources.
- Stage-boundary transitions target `safe_house.tscn`, a UI-only shelter hub. `commit_route_checkpoint()` stores permanent progression and current biological body state before the scene change; the shelter applies its full-heal rule and immediately commits the healed HP without clearing prey or digestion state. The legacy walkable shelter map remains archived but is not part of the active route.
- At `0 HP`, Linxi enters the defeated/down state and a modal retry panel blocks gameplay input. Retry reloads the current scene from its last committed area-entry checkpoint: permanent/body progression and prior route commits remain, while combat damage, enemy positions, projectiles, and provisional interactions from the failed attempt are discarded. Retry is available by mouse, Enter, or Space; the player-only `R` reset remains disabled.
- Android gameplay uses a reusable touch overlay: an analog virtual joystick on the left and enlarged `F` interact/continue dialogue, `J` attack, `K` dodge, held `L` digestion, and `V` Vore buttons on the right. The inner `50%` of horizontal joystick travel is analog walking; beyond that threshold Linxi sprints, while primarily vertical input remains walking. Touch direction feeds the same fake-3D movement, dodge shaping, directional attack, running attack, and intake-route systems as keyboard input. Decision and transition panels remain directly tappable. The overlay appears automatically on Android; `force_mobile_controls` exists only for desktop testing. An arm64 Android test APK has been produced; release version metadata and signing remain distribution tasks.
- General runtime SFX now live under `assets/audio/sfx` by category: `ui`, `player`, `combat`, `enemy`, `red_night`, and `vore`.
- Current non-vore runtime SFX should be recorded/foley-based files, not generated electrical tones. Keep them wired through `scripts/audio/audio_component.gd` event methods so better recorded or edited audio can be dropped into the same folders without changing gameplay code.
- The current real-foley source audit lives at `source_assets/audio/downloaded_real_foley/runtime_real_foley_manifest.md`.
- Hooked events include UI hover/confirm/cancel, achievement pop, surface-driven footsteps, jump, dodge, player hurt, claw swing/hit, enemy hurt/knockdown, occasional zombie groans, blue vial drink, signal interference, transition pulse, digestion start/loop/finish, belly struggle, swallow, burp, and prey screams.
- The opening scene owns a quiet looping rain recording and plays the existing signal-interference burst with its flash. Long ambience, nebulizer hum, and digestion beds explicitly enable stream looping at runtime rather than relying on importer defaults.
- `MapData.footstep_surface` selects the active footstep bank for each map. Current valid values are `WET`, `CONCRETE`, `MARBLE`, and `GRASS`. Runtime resolves these to `footstep_wet`, `footstep_concrete`, `footstep_marble`, or `footstep_grass` audio events.
- Current vore SFX load from `assets/audio/sfx/vore/swallow`, `assets/audio/sfx/vore/burp`, `assets/audio/sfx/vore/belly_struggle`, `assets/audio/sfx/vore/prey_scream_human`, and `assets/audio/sfx/vore/prey_scream_monster`; the loader reads raw audio files directly so newly copied WAV/OGG/MP3 assets do not require hardcoded resource paths.
- Runtime WAV files should be 16-bit PCM when possible. Some external 24-bit WAV clips can trigger Godot 4.6 loader warnings, so convert accepted runtime copies while leaving original source files untouched.
- SFX direction is grounded survival horror, not fantasy. Prioritize real-world sources: wet footsteps on tile, cloth movement, breath, metal doors, fluorescent electrical buzz, glass/plastic handling, body impacts, restrained flesh impacts, and distant panic.
- UI and abstract system sounds should use short metallic/mechanical cues: relay ticks, stamped metal clicks, cassette/mechanism snaps, hard-drive chatter, camera shutter fragments, and restrained radio/electrical noise. Avoid magic chimes, harp-like tones, orchestral stingers, bright whooshes, spell risers, and colorful action-RPG reward sounds.
- Monster/zombie audio should stay biological and human-adjacent: breath, throat strain, wet rasp, teeth, cloth scrape, and body weight. Avoid demonic magic roars or synthetic creature shrieks unless a later mutant type explicitly needs them.

## 2.5D Rules

- Physics position remains 2D
- Lane depth is represented by Y position
- Characters and props use Y-sorting
- Runtime uses split projection: ground/environment art keeps the angled fake-3D depth axis, while actors, items, shadows, hit FX, and combat zones use vertical screen-depth projection so `W/S` reads as straight up/down movement.
- Ground grid and boundary guide lines are development-mode only.
- Attack ranges use grounded shadow footprints for both attacker and target. Runtime shadow radius values must stay shared between rendering, combat checks, and telegraph/previews.
- Enemy attack reach can differ by family. Human/armed enemies currently use `human_attack_range`, while zombie students use `zombie_attack_range` so the gameplay hit area matches their hands-forward attack frame.
- Enemy attacks commit direction at cast start. `Enemy` captures `attack_facing` when entering `TELEGRAPH` or `HEAVY_TELEGRAPH`; animation frames, release FX, motion trails, and hit checks use that locked direction until recovery ends. Enemies must not rotate an already-cast attack to follow Linxi or another target.
- Player attack range preview is currently disabled for normal gameplay presentation. Enemy telegraphs still use grounded footprint math with red or purple danger zones.
- Airborne height is a visual offset separate from ground position
- Shadows remain anchored to ground position
- Collision constrains actors to a walkable belt polygon

## Conventions

- Use snake_case for files and node names where practical
- Prefer typed GDScript
- Signals communicate across ownership boundaries
- Avoid hard-coded balance values in character scripts
- Before replacing a working asset or feature, check the relevant `source_assets/*/asset_manifest.md`, runtime `assets/`, and `work_backup/`. Do not delete or discard files without explicit user approval.


## Stabilization Tools

- Canonical gameplay tuning lives in `resources/balance/default_balance.tres` using `GameBalance`.
- Shared save migration lives in `scripts/data/linxi_progression.gd`.
- Project content validation lives in `scripts/data/content_validator.gd`; it checks map dictionaries, story event IDs, story groups, AI profiles, and required sprite/effect resources.
- Run the deterministic full suite with `tools/run_test_suite.ps1`. It executes all active tests and diagnostics in isolated Godot processes with timeouts. `run_stage_1_playthrough_test.gd` is the save-backed whole-route check; use `--headless --script res://tests/run_tests.gd` only for the smaller stabilization subset.
- When `development_mode` is enabled on the stage host, press `F10` in the combat room to open the balance debug panel.
- `R` encounter reset is development-mode only and must not be presented as a player control.
- `=` biomass boost is development-mode only and adds `10` biomass for test setup. It must not change permanent weight or function in normal play.
- The pause menu exposes a development-only `Dev Overlay` button. It resumes the game and toggles a placement overlay that shows mouse world coordinates, X/Y axis guides, map bounds, `walkable_areas`, and `blocked_areas`.
- Runtime components must read gameplay values from `balance`; presentation-only values may remain local.

## Stage And Level Content

- The fiction route is organized as `StageData -> LevelData -> MapData`.
- `StageData` names the major fiction arc and orders its levels.
- `LevelData` names a playable chapter/segment and references the map data used by runtime.
- `Main` presents the active level. New story content belongs in stage/level/map resources before code branches.
- Stage 1 is `Stage 1: Red Night`. Its first playable unit is `Courtyard Fall Site`.
- New levels must follow `docs/production-sop.md`.
- Level order belongs in `StageData.levels`, not `main.gd`.
- Route freedom is checkpoint-based, not open-world streaming. A shelter or safe house may expose unlocked `MapData` destinations and replayable completed encounters, but the story spine still controls first-time progression.

## Map-Driven Encounters

- `MapData` owns stage bounds, encounter identity, objective text, footstep surface, enemy spawn definitions, item definitions, walkable areas, blocked areas, and route-transition items.
- Runtime enemy and item components clone their initial state from the active map resource.
- `MapData.camera_mode` controls presentation scale. `SCROLLING` maps are long action/exploration lanes where the camera follows Linxi through a horizontal dead zone: the camera should remain still while Linxi moves in the comfortable center band, then scroll only when she pushes toward the left or right screen margins while still leaving visible space ahead. `FIXED_ROOM` maps fit the whole room on screen by default, keep `camera_x` at `0`, and clamp Linxi inside the visible room bounds. Use fixed rooms for dorm rooms, offices, infirmary corners, classrooms, shelters, and other small investigation spaces where the player should feel that the scene is exactly this size. When a generated room makes doors, beds, or furniture read too large against Linxi, tune `MapVisualData.fixed_room_background_scale` after comparing those background pixels against Linxi's rendered visible height.
- If a correctly scaled map image no longer fills the viewport, `MapVisualData.fill_viewport_with_scaled_backing` lets `MapRenderer` draw a dark full-screen backing copy of the same approved map art behind the playable-scale image. Use this instead of enlarging the playable map until doors or rooms become oversized again.
- Enemy placement and item placement are authored by the active map, not by permanent save data.
- Player movement/mechanics and player visuals are separate. `Player` owns input, movement state, jump, sprint, dodge gating, form rules, animation timing, and footstep cadence. `PlayerVisual` owns Linxi animation lookup, story-pose frames, render scale, and intake-overlay visual paths through a `PlayerVisualLibrary` resource. `PlayerRenderer` owns Linxi drawing, motion trails, claw slash presentation, story-pose drawing, and intake overlay composition.
- HUD flow is separated into `HudController`. `Main` keeps compatibility wrapper methods such as `update_hud`, `open_transition_prompt`, and `show_achievement`, but `HudController` owns status text refresh, visual HUD values, achievement triggering, route-confirmation prompts, and dialogue-choice prompts. Development mode must not replace the production image HUD with the old text-only prototype labels; debug readouts belong in the dev overlay or dedicated debug panels.
- Projection/camera flow is separated into `Projection`. `Main` keeps compatibility wrappers such as `_project_actor`, `_project_ground`, `resolve_map_blockers`, and `_is_fixed_room`, but `Projection` owns fake-3D projection math, dead-zone camera follow, walkable rectangles, blocked rectangles, and map-position resolution. Development placement overlay drawing belongs to `Debug`, which combines projection, mouse input, map bounds, walkable zones, and blocked zones for tooling only. `MapRenderer` must use `Projection.camera_max_x()` as its scrolling denominator so actor projection and stitched background movement stay locked to the same physical map range.
- Map depth uses fake-3D logical coordinates: `Y = 0` is the back/wall side of the stage, while `Y = map.depth` is the foreground/bottom side of the screen. Door-on-wall transitions should normally use very small Y values and still be included in the authored `walkable_areas`.
- World feedback presentation is separated into `WorldFx`. It owns transient hit effects, ground residue, nebulizer mist point generation, contamination mist drawing, digest bar drawing, development ground belt/grid, enemy telegraph zones, and grounded shadow drawing.
- Scene and route flow is separated into `SceneFlow`. `Main` keeps compatibility wrappers such as `_load_level_data`, `_load_map_data`, `progress_save_path`, and `save_map_switch_checkpoint`, but `SceneFlow` owns current level/map payload loading and route checkpoint metadata.
- `main.gd` is currently 747 lines. It is substantially smaller than the former 2,000-line host and delegates behavior to components, but it still owns most mutable runtime state plus process/draw orchestration. Further extraction should be driven by Stage 2 pressure, with `InputRouter`, `PlayerRuntimeState`, and stage/world render composition as the leading candidates.
- Linxi sprite tables should live in reusable resources such as `resources/characters/linxi_t_early_visual_library.tres`, not as one-off preload blocks in `main.gd`.
- Map structure and map visuals are separate. `MapData` owns bounds, `walkable_areas`, `blocked_areas`, spawns, items, story identity, camera mode, and `footstep_surface`. `MapVisualData` owns background layers, foreground occluder layers, blend timing, scrolling background scale/offset, and fixed-room background scale/offset, while `MapRenderer` draws the background/foreground presentation.
- Scrolling traversal maps made from multiple background plates should use `MapVisualData.stitch_background_layers = true`. This draws the plates side-by-side as one stable long map. Fade arrays are reserved for deliberate cinematic transitions, not normal exploration.
- Runtime plates should come from one continuous approved panorama. The preferred map-generation workflow is full source first, runtime slices second. If the route is generated in pieces, use only true locked-canvas extension: approve a candidate side, place it into a wider unfilled source canvas, fill the missing side while preserving the approved side unchanged, then slice that full panorama into runtime plates. If locked-canvas editing is not available, regenerate the whole full-route panorama instead. `MapRenderer` should stitch slices of one scene, not separate camera shots.
- `red_night_courtyard` owns `resources/maps/red_night_courtyard_visual_data.tres`, which intentionally uses only the first two outdoor school plates. Its current map length is `3280`, and its dormitory route marker is `(2750, 8)`.
- `dormitory_second_floor` owns `resources/maps/dormitory_second_floor_visual_data.tres` and now uses two runtime slices from the approved continuous hallway panorama. Its current map length is `1714`, depth is `345`, and Su Ruo's room is at `(889, 15)`. Its Y-axis begins at the wall/floor connection instead of above it, so actors cannot walk on the wall art.
- `red_night_roof_route` owns `resources/maps/red_night_roof_route_visual_data.tres` and now uses two runtime slices from the approved continuous pre-dawn roof panorama. Its current map length is `1635`.
- `red_night_playground_return` owns `resources/maps/red_night_playground_return_visual_data.tres` and now uses three 2x production slices from the approved full-panorama source `playground_return_morning_full_panorama_candidate_v5_production_2x.png`. Its current map length is `1694`.
- Scrolling maps must keep their logical camera span close to their rendered background scroll span. A ratio near `1.0` makes Linxi feel anchored to the world; a much lower ratio makes her slide over a static poster, while a much higher ratio makes the scenery race past her. When a panorama is approved, compute `background_scroll = rendered_stitched_width - viewport_width`, then set `map.length` so `Projection.camera_max_x()` is close to that value before placing enemies, items, or transitions.
- `red_night_school_exit` now uses the dedicated `red_night_school_exit_visual_data.tres` resource and approved `school_front_gate_fixed_21x9_v1.png` background. It is a non-scrolling `FIXED_ROOM` map with a broad pavement walkable zone and its stage-boundary transition positioned at the main gate opening.
- `walkable_areas` are the first-class floor plan for a map. If a map defines them, actors are constrained to those authored areas; if it leaves them empty, runtime falls back to the full rectangular map bounds for older/simple maps. Simple areas use `position` plus `size`; angled stair runs, wall-door approaches, and irregular floor shapes may use a `points` polygon.
- `blocked_areas` are optional refinements for stairs, walls, railings, furniture, counters, and other solid architecture. They should not replace an authored walkable floor plan.
- New generated maps must define walkable zones before enemies, items, and route transitions are placed.
- Background image paths should live in reusable resources such as `resources/maps/red_night_visual_data.tres`, not as one-off preload blocks in `main.gd`.
- Foreground rails, fences, window frames, nearby pillars, and other screen-space occluders should live in `MapVisualData.foreground_layers` so actors can pass behind them. Do not rely on a single baked background when the player should be visually occluded by architecture.
- Item behavior and item visuals are separate. `Interaction` owns pickup/story/dialogue/transition behavior. `ItemVisualData` owns prop art and transition-circle frames, while `ItemRenderer` draws item presentation.
- Item prop paths should live in reusable resources such as `resources/items/red_night_item_visual_data.tres`, then be assigned through `MapData.item_visual_data`.
- Dialogue items can be condition-gated with `required_defeated_group`. Dialogue portraits are optional `avatar_path` values; the dialogue component loads imported resources first and falls back to raw project PNG files for newly generated portraits. Dialogue items can also open a reusable YES/NO choice payload after the final line. Dialogue items may set `auto_trigger = true` with `trigger_range_x` and `trigger_range_depth` for proximity-started story beats.
- Authored character dialogue requires an `avatar_path`; only Linxi/Archive may use the built-in Linxi fallback, while intentionally faceless roles must declare `allow_letter_avatar = true`. Wide portraits automatically expand the avatar region and shift dialogue text, allowing paired characters such as the Classroom 503 twins to remain in one rectangular frame.
- Effect state and effect presentation are separate. Runtime may own transient effect events such as hit mist positions, but effect frames and drawing rules belong to `EffectVisualData` and `EffectRenderer`.
- Enemy behavior and enemy visuals are separate. `Enemy` owns AI, state transitions, attack timing, and placement logic. `EnemyVisual` owns visual lookup/presentation and consumes an `EnemyVisualLibrary` resource. `EnemyRenderer` draws enemy presentation, HP bars, cast bars, and release-frame attack slash FX.
- Enemy attack FX are presentation-only. Zombies use the single-trajectory red vertical biomass strike frames from `EffectVisualData`, attached to the downward arm attack path during `RECOVER`; do not reuse Linxi's multi-claw red slash language for zombie basic attacks. Knife-armed human students use one horizontal silver knife trajectory attached to their hand swipe. Broader multi-slash silver frames are reserved for attacks that actually imply a wide weapon arc. The renderer selects left/right frames from the attacker's locked cast direction and plays them after the cast resolves.
- Enemy action frames must keep the same bottom-anchor contract as their idle/move frames. `EnemyRenderer` grounds cropped textures by their alpha bounds and dynamically scales each attack frame against that enemy variant's own move/idle reference. Ordinary zombie attack poses render at `95%` of their idle visible height because their attack posture is slightly crouched; human enemies and authored elites retain their own full-scale contracts. This is a runtime guard only; attack/hurt assets should still be normalized before approval.
- Attack direction is captured in `attack_facing` when casting begins. Every committed telegraph, strike, and recovery frame synchronizes the actor to that stored direction; player movement cannot turn an enemy after the cast has started.
- Enemy sprite tables should live in reusable resources such as `resources/enemies/red_night_enemy_visual_library.tres`, not as one-off preload blocks in `main.gd` or the enemy AI component.
- Map data connects those layers with `family`, `archetype`, `appearance_id`, `ai_profile`, and `attack_type`.
- Route exits are authored as items with `type = "transition"`, a `destination_name`, and a `target_scene`. Ground/area exits draw the glowing ground-circle FX, open a HUD-styled confirmation panel on `F`, and change scene only after the player confirms. Wall-door transitions set `show_transition_circle = false`; if the door must visually cover a background doorway on a scrolling map, set `background_prop = true` and author a `background_anchor` so `MapRenderer` draws the prop in stitched-background space. The transition item position then remains the invisible interaction point, not the door artwork position.
- Current authored Red Night route chain begins in `resources/stages/stage_01_red_night.tres`: `Courtyard Fall Site -> Dormitory Lobby -> Dormitory Second Floor -> Dormitory: Su Ruo's Room -> Roof Route -> Playground Return -> Teaching Building Lobby -> Teaching Building Second Floor -> Classroom 503 -> Teaching Building Second Floor -> Teaching Building Lobby -> School Front Gate`.
- The current courtyard route marker to the dormitory is the `roof_stairwell_transition` item at logical map coordinate `(2750, 8)`. Its player-facing destination name is `Dormitory Lobby`.
- The dormitory lobby uses `FIXED_ROOM` camera mode with authored walkable stair/lobby rectangles and blocked stair/wall mass. Its upper platform transition is `lobby_staircase_to_second_floor` at `(1085, 22)`.
- The dormitory second floor uses `SCROLLING` camera mode with a deep hallway walkable area from foreground floor to wall-side doors. It has three transition items: down to the lobby, into Su Ruo's room through a background-mounted wall-door prop without a glowing circle, and a right-side roof stair locked by `red_night_su_ruo_clue`.
- The teaching-building lobby uses `FIXED_ROOM` camera mode with a trapezoid walkable floor from `(-120, 170)` through `(-200, 457)`, `(965, 457)`, and `(1035, 170)`. It uses `ground_min_x = -200` so the authored negative-X floor is playable, applies a gameplay-only screen offset of `(0, 100)` without moving the background, and places its second-floor stair transition at `(880, 175)`.
- The teaching-building second floor uses the approved unified hallway background `teaching_building_second_floor_unified_v1.png`. It is a `FIXED_ROOM` navigation map with a full-floor walkable polygon, stairs down to the lobby, and a wall-door transition into Classroom 503. Classroom 503 is a separate fixed-room scene containing the twins dialogue and a return door to the hallway. After that dialogue sets `red_night_twins_met`, the lobby front exit unlocks the School Front Gate route.
- Interactable items can be gated with `required_defeated_group` or `required_story_flag`. Dialogue/story items can set story truth with `set_story_flag`; use this for clue-driven doors and route unlocks instead of hardcoded scene checks.
- Local in-stage shelters may be authored as `MapData`/`LevelData` spaces. The current Stage 1 boundary uses `safe_house.tscn`, a UI-only shelter page; the earlier walkable shelter map is archived and must not be reintroduced into the active route accidentally.
- Enemy behavior selection begins in map data through `ai_profile`; do not special-case story enemies by hardcoded ID when a profile or story group can express the behavior.
- Map-authored spawns use fields such as `id`, `family`, `position`, `appearance_id`, `ai_profile`, `initial_state`, `story_group`, and `attack_type`.
- Visible story actors that should hold pose before a dialogue or choice can use `ai_frozen = true`; frozen `NEUTRAL` enemies render their idle/appearance frame instead of looping movement. Group choice results such as `yes_group_states` and `no_group_states` can then wake whole `story_group`s into `APPROACH`, `NEUTRAL`, or other valid states.
- Protected knocked-down NPCs can use `vore_locked_until_group_defeated` so they do not enter the Vore target list until the authored threat group is defeated.
- Add runtime code only when reusable resources/profiles cannot express the behavior.
- Active enemy positions, enemy HP, cast bars, and ordinary item pickup states should not become permanent progression. They are encounter-local simulation state.
- Story-critical item results should be represented by story phase/flags, not by saving arbitrary item dictionaries forever.

## Transactional Mission Progression

- Dialogue triggers with a choice or completion effect must save only after that delayed result resolves. Saving when the first line opens can consume the trigger while leaving its enemies frozen. Active, unfrozen `STANDARD` enemies normalize `NEUTRAL` to `APPROACH` so restored encounter data cannot strand them outside the AI state loop.
- Enemy pursuit remains lane-first for readable fake-3D combat. If the proposed X/Y-alignment step is rejected by a sloped walkable polygon or blocker and produces no movement, AI retries that frame with a direct vector toward its current target. The fallback still passes through map collision and cannot cross walls or leave walkable zones.
- The Bone-Blade Twin's basic blade attack and three-strike rush are armored heavy attacks. Its basic wind-up is `0.3s`; the rush uses `0.3s` initial wind-up and `0.3s` between strikes, advances `120` logical pixels per strike, and deals `4` damage per individual strike. It cannot be staggered once either attack has committed. Each rush interval gives 20% of its display time to preparation and 80% to the finishing pose. Every committed boss attack frame receives a directional motion-blur trail. Boss attacks omit the overhead cast bar and use one long red diagonal trajectory per blade swing rather than Linxi's multi-claw FX.

- Permanent saves store Linxi-related data and story truth: story progress, committed progression stats, route unlocks, body/form unlocks, maximum HP, weight, biomass, capacity, equipment/loadout choices, and enough digestion/body-presentation state to show what Linxi currently looks like on shelter/safe-house status pages.
- Active combat state is not a permanent save target. Do not permanently save enemy HP, enemy positions, current telegraphs, or repeatable encounter depletion.
- Confirmed map switches save a route checkpoint and commit allowed Linxi/story progression. This includes Linxi's current HP, carried undigested prey state, occupied capacity, contained prey weight, belly/intake route loads, digestion progress, and body-presentation flag. It still does not make enemy HP, enemy positions, telegraphs, or repeatable depletion permanent.
- Mission-local changes remain provisional until the player confirms a valid map switch, reaches a shelter/safe-house page, or clears an authored checkpoint.
- Ordinary map-switch checkpoints carry Linxi's one equipped temporary weapon and remaining uses. Weapon projectiles and dropped scene pickups are map-local. Stage-boundary transitions intentionally omit the temporary weapon.
- Fresh scene launch, F5 playtests, and Mission Board deployment start from the authored stage opening and discard any unfinished encounter transaction.
- Encounter resume must be explicit. Set `resume_encounter_on_start` only for tests or a future suspend/resume path that intentionally restores a temporary mission transaction.
- Biomass, maximum HP, G-mode spending, route unlocks, digestion carry state, and other mission changes remain provisional during an active combat section until one of those checkpoint events occurs.
- Clearing an authored encounter may open a local shelter/checkpoint beat. Shelter pages are stage gates: before advancing to the next stage, the player may return to currently unlocked maps and reclaim missed route content; after confirming the next stage, the previous stage is locked except for explicit replay/archive modes.
- Opening Memory Settings with Escape pauses the game and does not save, commit, or restore active encounter rewards.
- `Abandon & Restart`, normal deployment, fresh playtests, and encounter reset discard provisional progression and reload the committed save.

## Save Point Model

- **Memory Settings:** pause/settings menu. It pauses simulation and supports window size, master volume, key binding review, resume, and exit game. It is not a save point.
- **Map Switch:** route confirmation checkpoint. Saves the target route and allowed Linxi/story progression, including current HP and currently carried undigested prey/body presentation, then loads the next map. Normal map switches remain return-allowed inside the same stage and do not refill HP.
- **Shelter Page:** local post-encounter save point and stage gate. Appears after a completed encounter or authored story checkpoint. Entering a shelter refills Linxi's HP. Supports status/archive/training/equipment pages and can offer the last chance to return before the next stage.
- **Safe House:** larger between-stage hub. Supports mission selection, archives, training, status, equipment, and character conversations. It is a permanent no-return commit when moving into the next stage.
- **Active Encounter:** no permanent enemy-state save. The player can pause through Memory Settings, but enemy state and repeatable rewards are not committed as permanent world state.
