# Current Project State

Verified against the Godot 4.6.2 runtime on 2026-07-13. This is the first document to read during implementation. It records current truth only; campaign plans and historical decisions live in their domain documents.

## Product

- Display name: `Linxi's Evolution Adventure`.
- Internal `evaluation_*` IDs and the legacy custom user-data folder remain unchanged for save compatibility.
- Main scene: `opening_intro.tscn`.
- Reference viewport: `1280x720` with the Compatibility renderer.
- Windows and Android test exports exist. Android uses arm64 and a virtual joystick plus `F/J/K/L/V` touch buttons.

## Playable Content

- Runtime production content currently covers Stage 1, `Red Night`.
- Active route: Opening -> Courtyard Fall Site -> Dormitory Lobby -> Dormitory Second Floor -> Su Ruo's Room -> Roof Route -> Playground Return -> Teaching Building Lobby -> Teaching Building Second Floor -> Classroom 503 -> School Front Gate -> UI shelter.
- The courtyard dormitory transition is `(2750, 8)`.
- The school-front-gate stage boundary targets `safe_house.tscn`; the old walkable shelter scene is archived and not part of the active route.
- Stages 2-10 are campaign plans, not runtime levels.

## Implemented Systems

- Fake-3D movement, walk/sprint/jump/dodge, camera dead zone, authored walkable and blocked zones.
- Three-stage directional claw combat, hit reaction, attack-direction lock, ordinary and heavy attacks, Bone-Blade Twin boss behavior, disposable handgun/knife weapons.
- Weight/biomass separation, capacity, Vore, multi-prey G-mode intake, partial digestion, carried prey across map transitions, provisional mission progression, checkpoint retry.
- Map-driven enemies, items, transitions, visual resources, dialogue choices, objective HUD, boss HUD, achievements, audio routing, and development placement overlay.
- Mouse-driven UI shelter with mission, archive, training, status, equipment, achievements, and settings stations. Character Area is dormant and completely hidden until a companion joins Linxi. Shelter functions are migrating from code-drawn signs to separately generated physical classroom props: Mission Map is pinned to the left blackboard, the Achievements trophy stands on the middle-left desk, and the Settings book rests on the front-left desk. Each physical prop uses its own texture bounds and red hover outline.
- Android touch input with a virtual joystick and enlarged action buttons.

## Deliberately Deferred

- Integrated full-body belly animation regeneration; runtime intake overlays remain the active solution.
- Chest, lower-abdomen, and groin intake visuals/routes.
- Final G-mode exoskeleton animation set and later body weapons such as tail attacks, waist blades, and voice attacks.
- Full data-backed archive, bestiary, equipment progression, relationship system, and Stage 2+ content.

## Architecture Health

- `main.gd` is 747 lines. It is a stage host and render/process coordinator, but still owns most mutable runtime state.
- Components are separated by responsibility, although they remain coupled through host access. The next justified splits are `InputRouter`, `PlayerRuntimeState`, and world/stage render composition when Stage 2 begins.
- Runtime assets live in `assets`; raw candidates and backups are excluded from Godot import and heavy source material is indexed in the external production archive.

## Verification

- Run the complete test suite with `tools/run_test_suite.ps1`.
- The runner executes every `tests/run_*.gd` file and every diagnostic with a per-test timeout and fails on missing pass markers, script errors, or assertion failures.
- `run_stage_1_playthrough_test.gd` performs the uninterrupted automated route pass from the courtyard through the UI shelter. It verifies route targets and gates while carrying current HP, biomass, undigested prey, digestion progress, and story flags through every map switch.
- The deterministic suite passed all 27 tests and diagnostics on 2026-07-13, including the automated Stage 1 route. This does not replace a human assessment of pacing, visual continuity, input feel, audio balance, or performance.
- Before adding mechanics or levels, complete one uninterrupted human Stage 1 playthrough and record pacing, readability, navigation, audio, performance, and Android-control findings.
