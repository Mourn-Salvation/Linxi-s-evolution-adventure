# Milestones

## M1: Movement Room

- Walkable depth belt
- Camera and Y-sorting
- Prototype player and stage blockout, now retired from Red Night production maps

## M2: Combat Slice

- Attack chain
- Shadow-footprint attack range system
- One enemy with hit reactions

## M3: Evolution Encounter

- Encounter gates and waves
- Signature skill and dodge
- Elite enemy or boss

## M4: Presentation Pass

- Final sprite and effect pipeline
- HUD, audio, result screen, and tuning
- Regression playtest and export


## M5: Red Night Vertical Slice

- Canonical story route from opening cinematic into the courtyard
- Map-authored fall site, chopper-dropped nebulizer, weak movement, blackout, neutral zombie student, body-attack unlock, map-placed infected feed group, human-student crisis, dormitory lobby, dormitory second floor, Su Ruo room route, roof route, elite bone-blade zombie, teaching-building twins beat, and outside-school transition
- Directional body attacks driven by `AttackData` resources and `W/A/S/D + J`
- Compact player HUD: Linxi HP top-left, objective guidance top-right, capacity/biomass/dodge bottom-right, enemy HP above enemies, and digestion bar above Linxi only while digesting
- Player attack preview is disabled for now; ground grids are development-mode only
- Story phase and body-weapon unlock stored as player/story progress at authored checkpoints, not as permanent enemy encounter state
- Evolution Room retained as the mechanics laboratory under Training

### Current Implemented Red Night Flow

1. Opening cinematic transitions into `Stage 1: Red Night`, `Courtyard Fall Site`.
2. Linxi spawns near the beginning of the map and wakes from the ground.
3. Control unlocks with weak movement and a story-integrated tutorial hint for `WASD` movement.
4. The chopper-dropped nebulizer sits near Linxi and is interactable with `F`; nearby interaction prompts refresh as Linxi moves.
5. Pressing `F` plays the accepted six-frame drink animation.
6. Linxi collapses and the blackout/classroom chase overlay plays.
7. Linxi wakes again.
8. The first zombie student appears as a neutral zombie-family enemy. It wanders and does not attack Linxi because Linxi is infected too, with tutorial text explaining the behavior.
9. Finishing the blue-vial drink beat unlocks body attacks and shows the `what's inside the vial` achievement popup.
10. The first courtyard feed group is map-placed, not item-triggered. It teaches `J`, `W/A/S/D + J`, `K` dodge, enemy attack range, and safe feeding windows without adding a heavy or elite enemy.
11. Near the dormitory, five zombie students pressure four human-student NPCs. The player can intervene, feed, or move toward the dormitory route.
12. The dormitory main-gate transition at `(2750, 8)` opens a confirmation panel and loads `Dormitory Lobby`.
13. `Dormitory Lobby` is now a fixed-room map with a switchback staircase, Li Yingying knocked down near the entrance, two stair zombies, and a staircase transition to `Dormitory Second Floor`.
14. `Dormitory Second Floor` is now a scrolling hallway with transitions back to the lobby, into Su Ruo's room, and later toward the roof route after the Su Ruo clue flag is found.
15. Scrollable-map QA now uses stitched preview strips under `docs/previews/scrollable_maps/`; the courtyard uses the first two outdoor plates, the second-floor stair-side plate has been regenerated as v4, and the roof route now owns a dedicated two-plate pre-dawn rooftop panorama. Active scrolling maps are tuned so the background scroll span and logical camera span are near 1:1.
16. After the playground elite battle, `Teaching Building Lobby` now leads by a physical staircase into `Teaching Building Second Floor`; the twins conversation there sets `red_night_twins_met` and unlocks the outside-school route.
17. Completion hints introduce the shelter/save cadence.

### Target Red Night Flow

1. Falling / aftermath.
2. First awakening on the ground.
3. Drink the blue virus solution from the chopper-dropped nebulizer.
4. Collapse / blackout / weak second awakening.
5. Claw unlock and first claw fight.
6. Human-student crisis: save them or consume them.
7. Enter the dormitory.
8. Find Su Ruo's room.
9. Dormitory fight.
10. Daytime transition.
11. Upstairs route.
12. Roof fight.
13. Return halfway toward the teaching building across the playground.
14. Elite bone-blade zombie encounter.
15. Teaching Building Lobby and stair route.
16. Teaching Building Second Floor and twins conversation.
17. Exit the school.

Current implementation now connects the entire Stage 1 route through data-driven levels. The roof encounter, daytime playground return, Bone-Blade Twin boss, teaching-building lobby and second floor, Classroom 503 twins conversation, school-front-gate exit, and UI shelter are implemented. They still require one uninterrupted human pacing/readability playthrough before Stage 1 is accepted as complete.

The executable now distinguishes first-time and returning players. A first-time profile receives the authored opening cinematic directly. Once that opening has completed, later launches enter a title menu with New Game, Load Game, Save Files, Settings, and Exit. Three save slots isolate committed Linxi/story progress; the previous single-save format migrates non-destructively into Slot 1.

### Accepted Red Night Assets

Do not redo these unless a specific problem is identified:

- Dropped Chopper Nebulizer prop:
  - Runtime: `assets/props/red_night/chopper_nebulizer/dropped_nebulizer.png`
  - Source and prompt: `source_assets/red_night/props/chopper_nebulizer/`
  - Manifest: `source_assets/red_night/asset_manifest.md`
- Linxi Drinks Blue Stock Solution animation:
  - Runtime frames: `assets/sprites/linxi/t_early/story/drink_blue/`
  - Source and prompt: `source_assets/red_night/characters/linxi_drink_blue/`
  - Runtime hook: `story_pose == "DRINK_BLUE"`
- Classroom chase cutscene plate:
  - Runtime: `assets/cutscenes/red_night/classroom_chase.png`
- Red Night background segments:
  - `school_exterior_ultrawide.png`
  - `school_to_dorm_connector.png`
  - `fall_site_school.png`

### Red Night Acceptance Questions

- Does Linxi's wake-up read as vulnerable and controllable at the right moment?
- Is the weak walk to the nebulizer clear without feeling like a bug?
- Is the first neutral zombie student understandable as "she is infected too"?
- Does the first combat unlock feel like a change in Linxi's body, not a random tutorial button?
- Does the achievement popup read clearly at the bottom-right without hiding movement/combat?
- Are the camera, Y-depth, and background composition readable at `1280x720`?

## M6: Save Point And Shelter Architecture (Implemented)

- Permanent player/story progress is separated from provisional encounter state.
- Confirmed map switches carry Linxi's HP, temporary weapon, undigested prey, digestion, body presentation, and story progress without permanently saving repeatable enemy depletion.
- The UI shelter refills HP, commits the stage boundary, and exposes mission, archive, training, status, equipment, and settings stations. Character Area remains hidden until the story introduces a companion.
- Defeat retry reloads the committed area-entry checkpoint without committing the failed attempt.
- Memory Settings pauses gameplay and supports window size, volume, key binding review, resume, development overlay access, and exit.

## Current Production Priority

The integrated full-body Vore expansion experiment is deferred. Its tier-1/2/3 previews remain optional pipeline references under `source_assets/characters/linxi_t_early/vore_preview_test/`; the current runtime overlay system remains active until a dedicated full animation-regeneration project is approved.

Do not add mechanics or levels until the stabilization gate is complete:

- deterministic full test suite passes: 27/27 on 2026-07-13
- automated save-backed Stage 1 route passes from courtyard to UI shelter
- canonical docs and generated asset index match runtime
- Git baseline exists with caches, builds, archives, and exports excluded
- one uninterrupted human Stage 1 playthrough covers opening through UI shelter
- playthrough notes cover pacing, objective clarity, navigation, combat readability, story-choice flow, audio, performance, Android controls, and checkpoint behavior
