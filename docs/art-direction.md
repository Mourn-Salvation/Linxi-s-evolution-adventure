# Art Direction

This is the canonical art-direction document for Linxi's Evolution Adventure. Use this file for current visual and asset-production rules.

## Core Identity

Use an original school-biochemical survival-horror style:

- high-resolution source art presented through a controlled pixel-filter effect
- contemporary Chinese school spaces, dormitories, classrooms, rooftops, emergency infrastructure, and W/S City outbreak materials
- severe directional lighting, broad shadow, restrained visibility, and readable fake-3D silhouettes
- cold blue-black neutrals with limited red, cyan, aerosol blue, and archive amber accents
- ordinary school life corrupted by covert biochemical research, blue aerosol compounds, pale infected tissue, biomass armor, and incomplete records

SIGNALIS remains a high-level reference for retro survival-horror grammar only. Do not copy its characters, uniforms, faces, symbols, UI layouts, rooms, props, monsters, animations, text, exact palettes, screenshots, or compositions. Prompts must describe this project's own identity, not ask for an exact external style.

## Presentation Rule

The game should look like high-quality art filtered into a disciplined retro presentation, not like muddy low-resolution art.

- Minimum target presentation: `1280x720`.
- `640x360` may be used as a layout/readability grid only.
- Source illustrations, cinematic plates, portraits, maps, and key art should be `1280x720` or higher.
- Pixel structure is a final treatment: nearest-neighbor scaling, quantization, sharpening, scanlines, mild noise, or the project pixel shader.
- Do not use self-drawn, procedural, or hand-sketched placeholder art as production gameplay art.
- Avoid smoothing character sprites, UI icons, portraits, and pixel props.
- Use integer sprite scale and whole-pixel resting positions wherever possible.
- Default animation playback is `8-12 fps`; fast impacts may use `12-15 fps`.

## No Drawn Runtime Assets

Runtime-visible production art must be an approved imported asset: Sprite Forge output, Codex image generation, ComfyUI/user-provided art, or a reviewed source file from the project pipeline.

Drawn/procedural visuals are allowed only in these cases:

- debug overlays, developer-only guides, and invisible collision/range helpers
- non-player-facing validation warnings when a required asset is missing
- temporary placeholders that are clearly documented and replaced before the feature is accepted

Do not add new self-drawn actors, maps, props, effects, UI boards, or cinematics to gameplay as if they were final art. If a feature needs a temporary placeholder, name it as a placeholder in the code or resource, document what approved asset will replace it, and keep it out of normal player-facing presentation. Missing approved runtime art should render invisible or fail validation, not draw an improvised shape in the game.

## Palette

Core neutrals:

- abyss black `#080B10`
- blue-black `#101923`
- steel navy `#1C2A36`
- cold gray `#7F8C91`
- pale interface white `#C8D0CD`

Functional accents:

- danger red `#9E2028`
- fresh warning red `#D44747`
- medical cyan `#4EA6AC`
- aerosol blue `#5B8FA8`
- archive amber `#C49A45`
- infected pale `#AEB9B4`

Rules:

- A normal gameplay screen should use two neutral families and no more than two accent families.
- Red means danger, infection, damage, alarms, and irreversible decisions.
- Cyan means medical technology, archives, scanning, and the experimental compound.
- Biomass is dark red-brown, black, bone gray, or bruised violet. Avoid bright fantasy slime colors.
- Saturated colors must occupy little screen area.

## Lighting And Composition

- Characters must read first as silhouettes, then as details.
- Keep faces partially obscured outside portraits and cinematic close-ups.
- Prefer lateral, overhead, or back lighting over even frontal lighting.
- Use hard pools of light separated by broad darkness.
- Preserve negative space around isolated characters.
- Use fog, darkness, occluders, or architecture to limit certainty without hiding gameplay information.
- Combat targets, telegraphs, and hit reactions must remain readable through silhouette, pose, or one controlled accent.
- Avoid filling every surface with debris, signs, lights, or texture.

## Character Rules

- Gameplay actors use a `3/4` fake-3D brawler view with clear side readability and depth-lane orientation.
- Human Linxi appears in opening cinematics, memories, portraits, concept art, and safe-house/memory-room identity imagery. She is not the post-fall combat form.
- Classroom 503's adult twin survivors use one paired idle prop frame. They stand together facing screen-right toward the right-side classroom entrance, preserving the encounter's spatial eyeline when Linxi enters.
- Early T-form Linxi is the first playable story-stage body: same identity, paler skin, altered eyes, damaged school outfit, constrained stiffness, and small biological changes.
- Developed T-form gains more decisive posture, body-weapon silhouettes, and a black biomass tail while remaining recognizably Linxi.
- G-form is broad, heavy, asymmetrical, and protected by biomass exoskeleton language.
- Standard human enemies stay close to T-form Linxi's apparent scale.
- Infected enemies begin from human silhouettes and break them selectively.
- Feet anchor is mandatory for grounded animation. Body scale should not vary by more than about `10%` between accepted actions.

## Linxi G-Form Exoskeleton Language

G-form armor is grown biomass, not worn metal. It should look as if black and dark-gray biomass has surfaced from inside Linxi's body, with hard plates protecting impact zones and black mesh-filament tissue spreading across chest, belly, waist, limbs, and exposed skin.

- Rigid sections: obsidian-black or dark-gray carapace plates over shoulders, forearms, ribs, spine, hips, outer thighs, shins, and feet.
- Flexible sections: black mesh-filament/tendon texture at chest, belly, neck, shoulders, elbows, wrists, waist, hips, knees, ankles, exposed skin windows, and tail base. The surface may resemble taut sheer technical fabric fused with organic tendon fibers, but it must stay horror-toned rather than fashion-toned.
- Accent detail: narrow dark red cracks or wet highlights only; avoid bright fantasy glow.
- Silhouette: taller, heavier, curvier from accumulated biomass, and more armored than T-form, but still recognizably Linxi through hair, face, damaged school-uniform remnants, and posture. The expansion should feel twisted and pressured, with subtle asymmetry and biological strain rather than glamour posing.
- Tail: segmented black biomass tail may be present, thin enough to animate behind her and not block body-state overlays.
- Runtime rule: plates and filaments should read as protective biomass, not exposed anatomy. Avoid white armor, bright purple armor, random spikes, over-emphasized torso shapes, excessive skin exposure, high heels, or details that would collapse into noise at sprite scale.
- Spike rule: reduce spike language to small controlled ridges on forearms, shins, spine, and tail base only. Large shoulder/back spikes are a rejection risk because they complicate animation.
- Production status: `source_assets/characters/linxi_g_mode/exoskeleton_concepts/linxi_g_mode_biomass_exoskeleton_concept_v3_black_filament.png` is the current concept reference, not final runtime sheet art. V4 and V5 are archived direction experiments, but V3 is the approved visual target.

## Linxi Tail Language

Linxi's tail is an original black biomass weapon with obsidian-like wet sheen, segmented plates, sharp ridges, and a hooked blade tip. It may suggest predatory biomechanical danger, but must not copy a named franchise creature exactly.

- In idle and movement, it swings behind her back and reads as ready to strike.
- It must not obscure Linxi's face, hands, feet, or body-state expansion parts.
- Tail attacks should use separate slash/impact FX where possible.
- Enemy attack release FX follow the same language: zombie attacks use red biomass slash accents, while human melee or knife attacks use silver steel accents. The FX direction must follow the enemy's facing/attack flow.
- Tail silhouette approval happens before Vore expansion tier references.

## Animation Economy

- Every frame should communicate weight, intention, or state.
- Idle loops are subtle: breathing, balance adjustment, head movement, or biological twitch.
- Early T-form walk feels cautious and unstable; developed T-form movement becomes purposeful.
- Hit reactions favor a sharp pose break and short hold over large knockback.
- Attack anticipation must be readable before impact.
- Reuse held poses where stillness increases tension.
- Avoid elastic cartoon squash, cheerful bounce, and decorative flourishes.

## Environment And Map Rules

- Playable stages use layered or parallax pipelines, not one flattened AI image.
- Generate scenery-only background layers first, then a stage reference mockup.
- Gameplay-relevant floors, doors, gates, signs, props, hazards, exits, and occluders become separate runtime assets or Godot objects.
- Walkable floor design comes before gameplay placement. Every accepted map background must make its playable floor band, room floor, stair landing, or corridor lane visually readable enough to trace into `MapData.walkable_areas`.
- Collision comes from explicit map data, never background pixels. `walkable_areas` define where actors can move, while `blocked_areas` refine solid structures such as stairs, railings, walls, counters, and furniture.
- Preserve the fake-3D lane angle and y-sorted actor readability.
- Use architecture to frame movement left-to-right unless the story deliberately reverses direction.
- Keep at least one visually quiet lane for combat readability.
- Environmental storytelling should rely on a few legible objects: empty bed, dropped ID, sealed door, broken aerosol device, emergency notice.

### Map Background Prompt Pattern

The approved Red Night dormitory lobby / second-floor hallway direction uses a side-readable stage composition, not a realistic room snapshot. This pattern should be the default for dormitory corridors, stair routes, school hallways, and other traversal maps.

Core rules:

- Prefer ultra-wide `21:9` backgrounds for traversal spaces.
- Design the map as a playable side-readable stage with visible depth, not a first-person hallway or cramped room painting.
- Dormitory and school traversal maps must stay shallow and side-readable, like a brawler stage. Do not accept deep one-point corridor/tunnel perspectives where the camera looks down the hallway; those make the fake-3D movement plane feel wrong.
- Use two readable layers when the space has vertical routing: lower foreground/playable layer and upper/back corridor layer.
- Reserve a broad lower-floor or corridor band for actors. Characters around `160-190 cm` tall must read at normal runtime scale.
- Leave enough visual floor surface for the intended `walkable_areas`; do not hide the playable lane behind decoration, stair geometry, props, or perspective clutter.
- Scrolling hallway maps must provide enough authored depth for actors to move from the bottom/foreground of the screen to wall-side doors. A corridor that only allows a narrow horizontal strip is not acceptable for Red Night traversal.
- Physical route objects must be real architecture: stair base, landing, handrails, door threshold, corridor mouth. Do not represent route movement with a glowing circle inside the art.
- Wall-door interactions should be separate prop art that fully covers or replaces one readable background door. The interaction point still lives in `MapData`, but the player should read the object as a real door, not a freestanding marker in the hall.
- For stair routes, use a reciprocating/switchback stair when the player enters from the outside/front side and exits to an inside/back upper corridor.
- Doors, stair bases, and room entrances may be background-visible, but the actual interaction/collision must come from map data or separate runtime objects.
- Avoid cramped single-room shots, fisheye perspective, photoreal first-person corridors, tiny-character scale, and cropped route geometry.

### Scrollable Plate Continuity

- Multi-plate traversal maps must be generated as one physical space, not as separate pretty shots. The final source should be a single approved panorama that is split into runtime plates only after approval.
- Start a map generation mission by generating one full-route panorama candidate whenever possible. This was the successful pattern for the dormitory second floor, roof route, and playground return: full source first, runtime slices second.
- If one generation cannot cover the full map, use a true locked-canvas extension workflow: approve the good side, place that approved candidate into a wider unfilled canvas as the locked left/right/center region, then fill the missing side with image generation/editing while preserving the approved side unchanged.
- If locked-canvas editing is unavailable, regenerate the whole full-route panorama instead of producing an independent third plate.
- Free-standing continuation plates are not production-acceptable, even when they use the neighboring plate as a reference. If the approved neighboring plate is not physically locked into the generation canvas, the result is only a concept candidate.
- The player should never feel that two independent images were placed together. The full-width source should read like one camera, one floor plane, one time of day, and one physical location before it is sliced into runtime plates.
- Every accepted plate set needs a strip preview and runtime camera samples before gameplay placement is considered final.
- Accept a multi-plate map only when it passes the continuity checklist: one horizon, one light source/time of day, one camera height, continuous floor scale, continuous wall/fence/building rhythm, no duplicated landmark, no sudden perspective turn, and an uninterrupted playable lane.
- Do not reuse one `MapVisualData` across different physical locations except as a temporary blockout. Roof routes, playground returns, school exits, courtyards, and dorm corridors should each own their own visual resource once the route matters.
- If a side does not connect well, rebuild it by placing the accepted neighboring side into an unfilled canvas and filling the missing side. Preserve wall height, floor grid, horizon, light rhythm, material palette, and actor scale.
- Avoid "new shot" discontinuities at seams: sudden window corners, changed perspective angle, changed floor tile scale, different wall height, or a landmark jumping into the middle of the next plate.
- For Red Night level 0, the courtyard currently uses only the first two outdoor plates through `red_night_courtyard_visual_data.tres`; the old third outdoor plate is not part of the courtyard runtime path.
- The second-floor hallway now uses runtime slices from one continuous approved panorama. Future replacements should use the approved-candidate extension workflow rather than independent hallway/stair shots.
- The roof route now uses runtime slices from one continuous approved panorama. Its time of day is the last few minutes before dawn, so keep the sky blue-black with pale cyan lift and a thin rose-orange horizon glow, not midnight black and not daytime.
- The playground return now uses 2x runtime slices from the approved full-panorama source `playground_return_morning_full_panorama_candidate_v5_production_2x.png`. It fixes the prior left-extension seam by returning to the full-source-first workflow.

Reusable prompt skeleton:

```text
Use case: stylized-concept
Asset type: 2D Godot background for a fake-3D / belt-scroller <map type>.
Primary request: Generate <specific place> as a usable game map, not a realistic room photo.
Scene/backdrop: Contemporary Chinese school <location> during the Red Night outbreak.
Composition/framing: ultra-wide 21:9 horizontal game background, side-readable stage layout, broad lower foreground playable band, clear fake-3D floor plane, character scale for 160-190 cm actors.
Continuity for multi-plate maps: generate one full-route source panorama candidate first. The image must already read as one camera, one horizon, one floor plane, one light direction, and one physical route before slicing. If extension is required, use only a true locked-canvas workflow where the approved side is preserved unchanged; otherwise regenerate the full panorama. Do not create an independent continuation plate from reference alone; that is concept-only until it is rebuilt as one locked panorama or replaced by a new full source.
Route logic: show the physical path clearly. For stairs, include a reciprocating / switchback staircase with stair base, landing, railings, and visible exit to the upper corridor.
Gameplay notes: leave clear interaction zones at stair bases, doors, and route exits; doors and stairs are tangible environmental objects, not UI markers.
Style/medium: high-resolution illustrated survival-horror anime game background, compatible with the project pixel-filter treatment; not low-resolution pixel art.
Lighting/mood: tense but readable, cool blue-gray shadows, muted red emergency lamps, practical fluorescent lights.
Color/materials: desaturated concrete, dirty cream walls, teal-gray lower wall paint, gray tile, dark metal railings, worn doors, scattered papers, grime, wet reflective patches.
Constraints: no characters, no UI, no readable text, no brand names, no glowing route circle, no teleport portal, no cropped stairs/corridors, no first-person hallway, no deep one-point corridor/tunnel view.
```

Approved examples:

- `assets/backgrounds/red_night/dormitory_lobby_switchback_21x9_v1.png`
- `assets/backgrounds/red_night/dormitory_second_floor_hallway_21x9_v1.png`

## UI Rules

- UI is flat, compact, technical, and mostly rectangular.
- Use uppercase headings, short labels, thin rules, case numbers, and diagnostic language.
- Normal text is pale gray; danger is red; selected technical information is cyan; archival emphasis is amber.
- Avoid fantasy frames, glossy gradients, rounded mobile-game cards, oversized icons, and rainbow rarity colors.
- Hot magenta is a pipeline key color, not a final HUD accent. Run `tools/clean_magenta_fringe.py <ui-folder> --recolor-opaque-ui-magenta` on accepted HUD/UI assets before wiring them so magenta specks become transparent and opaque magenta highlights are shifted into the project red/metal palette.
- Flicker, scanline interruption, offset frames, and corruption are allowed sparingly.
- Degradation must never reduce readability of controls, subtitles, health, or interaction prompts.
- Dialogue windows remain low on the screen, with portrait/avatar overlapping the upper-left edge.

## Effects Rules

- Effects are short, sharp, and low-frame.
- Actor motion trails/afterimages are a runtime layer. Do not bake motion blur into source sprite sheets unless a specific animation needs hand-authored smear frames.
- Trails should stay translucent, cold cyan/silver, and restrained; they should improve impact and hide minor animation flaws without turning crowds into visual noise.
- Gunfire: compact white-yellow flash plus at most one red/cyan afterimage.
- Body/bone blade attacks: pale bone core, dark red edge, or restrained red trail.
- Steel or human weapons use silver/white sharpness effects.
- Hit effect: one strong silhouette break, small particles, optional one-frame inversion, and restrained virus mist/liquid spread.
- Biomass growth: layered dark tissue, bone plates, and controlled wet highlights.
- Digestion/body-state visualization must stay readable and horror-toned.
- Avoid large colorful action-RPG explosions for ordinary attacks.
- Audio follows the same grounded horror rule. Real-world actions should sound like real materials and bodies; abstract UI/system events should use restrained recorded clicks, switches, closures, radio noise, or mechanical foley rather than generated electrical tones. Footsteps must follow map-authored surface identity (`WET`, `CONCRETE`, `MARBLE`, `GRASS`) so movement sounds belong to the scene.

## Production Pipeline

Use `docs/production-sop.md` for the full operational checklist. This file keeps only visual and acceptance rules.

Tool order:

1. Sprite Forge for production candidates.
2. Codex image generation for concepts, missing plates, temporary production art, or Sprite Forge failures.
3. ComfyUI only for identity-specific consistency or user-directed experiments.

Acceptance is bound to an exact approved source path and SHA-256. Never process a "latest generated image" cache result.

## Required Asset Brief

Before generation, record asset id, purpose, view, target size, frame count, stable identity markers, palette/lighting, anchor, FX separation, and Godot destination. Do not generate from only a character name and an external game reference.

## Prompt Contract

Prompts must use this project's own language: school-biochemical survival horror, high-quality source art with pixel-filtered presentation, cold blue-black palette, controlled red/cyan accents, severe directional light, readable silhouettes, and `3/4` fake-3D brawler view for gameplay actors.

Sprite prompts must specify exact grid/frame count, solid `#FF00FF` background, stable identity/scale/lighting, full body inside the safe area, and stable feet/bottom anchor. Avoid colored outer glow, baked shadows, text, logos, borders, UI, scenery, or copied franchise symbols.

Never prompt for the exact style of another game.

## Sheet Strategy

- Generate and review each main-character action separately.
- Four-frame body action: `2x2`.
- Six-frame body action: `2x3`.
- Eight-frame body action: `2x4`.
- `2x4` is the default for eight-frame bodies, not an obligation. Tall actors, long hair, tails, or attached weapons may use `4x2` when that gives every frame safer vertical padding.
- Four-direction locomotion may use a canonical `4x4`.
- Do not generate unrelated idle, walk, attack, hurt, and death rows in one raw atlas.
- Assemble engine atlases only after each action passes review.
- Body sheets contain body and held weapon only.
- Muzzle flashes, bone-blade arcs, blood, dust, biomass trails, projectiles, and impacts are separate FX sheets.
- Use shared scale and feet alignment during post-processing.

## Cross-Action Scale And Canvas Safety

- Choose one runtime cell size for an actor before export. Idle, movement, attack, hurt, and upright recovery frames must use that same cell size; knocked-down frames may use a wider canvas but must preserve the same world scale.
- Measure each frame's visible alpha bounds before approval. Compare visible body height against the approved idle and movement references; routine pose variation should remain within about `10%` unless the animation is intentionally crouched, airborne, transformed, or knocked down.
- Compare head/top drift as well as the feet anchor. Matching shoe position alone does not prove that the character scale is stable.
- Hair, shoes, tails, fused limbs, held weapons, and body-attached blades must have clear padding from every cell boundary. A frame that touches an edge is rejected until inspected.
- If the complete source artwork exists but the frame canvas is too small, extend the surrounding solid `#FF00FF` blank canvas or change the grid orientation. Keep the character pixels and scale unchanged; do not shrink only the oversized action and create a visible model-size jump.
- If any body part is already clipped in the generated source, blank-canvas extension cannot restore it. Regenerate that action with a larger safe area.
- Run connected-component diagnostics when the edge checker reports contact. `largest` component mode is allowed only when all required anatomy and the attached weapon belong to the same connected silhouette; otherwise preserve all components and regenerate with more spacing.
- Normalize accepted action sheets to the same output cell dimensions before runtime wiring. Preview all actions together on dark and bright backgrounds to catch scale changes, clipped edges, and residual magenta.

## Character Cleanup

For Linxi and recurring actors, protect raw character pixels. Remove only background-connected magenta/white matte and a narrow `5-6 px` edge band. Do not recolor, darken, palette-match, or replace pixels inside the protected body mask without approval.

Inspect transparent sprites on black and bright backgrounds. `tools/clean_magenta_fringe.py` is safe for simple props/effects, but not for blind character-body cleanup. `tools/match_sprite_style.py` is approval-only for character sheets.

## Locomotion Anchor Alignment

For grounded body animations, foot completeness is not enough. Every frame must share the same bottom anchor and stay inside an approved visible-height range.

Runtime Early T-form height locks:

- Idle: about `216-219 px` visible height, bottom anchor `245`.
- Walk: `216 px` visible height, bottom anchor `245`.
- Sprint: `205 px` visible height, bottom anchor `235`, until the sprint/run set is re-authored at the full common actor height.
- Get-up final standing frame: about `218 px` visible height, bottom anchor `245`.

Story frames may be shorter while Linxi is lying, kneeling, crouching, or drinking, but the final standing/controllable frame must return to the same runtime scale as idle/walk. Do not approve a locomotion or transition sheet only because the shoes are aligned; measure visible height and top/head drift too.

Use `tools/align_sprite_bottom_anchor.py` for grounded animation previews. Accept only if all aligned bottom values match, top artifact check passes, body parts are preserved, and the preview is visually stable. Keep raw, preserved-cell preview, bottom-aligned preview, and metadata under `source_assets`.

## Character And Enemy Pipeline

Ground pickup props must match the fake-3D floor projection rather than use catalog side elevations. Show top surfaces with roughly 35-45 degree overhead viewing, compress the object's apparent height through foreshortening, align its long axis diagonally along the ground plane, and use only a tight contact shadow contained beneath the footprint. Side-view weapon renders may remain reference/UI sources but must not be wired as world pickups.

Approval order: body/outfit, core movement, hurt reaction, knocked-down posture, combat/state animations, FX/decal pass, data integration, Godot test.

Sprite-backed combat enemies need a minimum runtime animation contract: idle/stance or appearance frame, 8-frame move loop, 4-frame attack/telegraph body action, 2-frame hurt reaction, knocked-down pose, and recovery handled either by the final attack frames or a future dedicated recovery sheet. Non-combat civilians do not need attack frames, but still need move, hurt, and knocked-down coverage.

Temporary enemy scale bridge: the current human-student upright run assets still need runtime scaling so their crouched/running poses read closer to Linxi and the zombie-student silhouettes in scene. Runtime currently scales upright male `human_student` sprites to `1.10` and upright female `human_student` sprites to `1.06`; knocked-down human-student sprites stay on the normal enemy scale. Future regenerated human-student sheets should use the normal source height and less extreme crouch so this bridge can be removed.

Do not create a new enemy behavior class only because hair, outfit, or infection detail changed.

New enemies and level-specific assets must follow `docs/production-sop.md`. Source files, rejected candidates, and backups are kept unless the user explicitly approves deletion.

Godot import boundary:

- Runtime-ready art goes in `assets`.
- Raw sheets, contact sheets, preview sheets, ComfyUI/Sprite Forge candidates, rejected variants, MP4 references, and processing intermediates stay in `source_assets` only while active and lightweight; heavy archives live in `E:\Linxi_Production_Archive\source_assets\` and are indexed from `source_assets/archive_index/`.
- Rollback copies stay in `work_backup`.
- `source_assets` and `work_backup` are intentionally hidden from Godot imports with `.gdignore`; do not reference them from runtime scripts.

## Acceptance Gate

Accept an asset only if it fits Linxi's world, reads at runtime size, follows palette/lighting rules, keeps identity/scale/anchor stable, separates body from wide FX, avoids copied external material, passes cleanup/QC, previews cleanly on black and bright backgrounds, and has been tested in the target Godot scene.
