# Campaign Stage Plan

## Purpose

This document converts the fiction into a stage-and-level production plan for a 20+ hour Godot action campaign. It is a playable adaptation outline, not a scene-by-scene transcription. The manuscript remains the source material; this plan keeps the game focused on readable action, Linxi's identity, outbreak investigation, safe-house reflection, and staged biological progression.

## Adaptation Rules

- Linxi is 18 in game canon.
- Stage 1 is `Red Night`; its levels are scene/beat names such as `Courtyard Fall Site`, `Dormitory Lobby`, `Dormitory Second Floor`, `Dormitory: Su Ruo's Room`, `Roof Route`, `Playground Return`, `Teaching Building Lobby`, `Teaching Building Second Floor`, and `Outside The School`.
- Human Linxi appears in opening, memories, portraits, and the safe house. Story-stage gameplay begins with Early T-form after the fall.
- The campaign should not turn emotional trauma or predatory horror into spectacle. Events from the fiction are adapted through combat, investigation, environmental storytelling, dialogue, archive footage, and boss mechanics.
- Safe houses and shelters are where permanent progress is committed, the archive grows, equipment is adjusted, and character relationships breathe.
- Stages should be built as data-driven level resources: map data, encounters, item placements, story events, exits, checkpoints, and unlock gates all belong to the level file.

## Campaign Length Target

Target total: 23-27 hours for a first full game pass.

- Main story: 18-21 hours.
- Safe-house conversations, archives, training, and optional replays: 3-4 hours.
- Optional challenge encounters and upgrade hunts: 2-3 hours.

The campaign should be designed around 45-90 minute stages. Individual levels should usually run 8-20 minutes so we can polish them as playable slices instead of building huge unfinished maps.

## High-Level Arc

Linxi starts as an isolated student in W City. A coordinated biochemical incident hits the school, hospital, and Black King nightclub while an underground institute collapses from sabotage. Linxi survives the fall because the virus revives and rebuilds her. She drinks the blue virus stock solution from a chopper-dropped nebulizer, wakes as an intelligent infected, and searches for Su Ruo.

The early game is tactical and frightened: slow movement, weak attacks, ordinary infected that do not immediately treat Linxi as prey, and human threats that reveal the social collapse. The middle game opens W City, introduces company recovery teams, special infected, Yamata/Shanye, and body-weapon unlocks. The late game moves toward the institute, G-virus escalation, powered armor, rival evolved hosts, and the decision of what Linxi is willing to become.

## Stage Summary

| Stage | Name | Target Time | Story Function | Gameplay Function |
| --- | --- | ---: | --- | --- |
| 1 | Red Night | 2.0-2.5h | Linxi discovers that her body, the school, other people, and finally the whole world have changed while she was unconscious. | Movement, interaction, first infected behavior, first combat, digestion basics, route transitions, first shelter. |
| 2 | Campus Lockdown | 1.5-2.0h | The school becomes a closed ecosystem of survivors, infected, and human opportunists. | Full fake-3D combat lanes, survivor choices, claw combo, weak dodge, first mini-boss. |
| 3 | W City Emergency | 2.0-2.5h | Linxi exits campus and sees the citywide scale of the attack. | City map, item weapons, first shelter hub, route selection, enemy variants. |
| 4 | Central Hospital | 2.0-2.5h | The hospital outbreak center reveals medical evidence and the first organized recovery operations. | Dense interiors, vertical pressure routes, special infected, status ailments, archive clues. |
| 5 | Black King Nightclub | 2.0-2.5h | The second outbreak center connects Linxi to Yamata/Shanye and outside teams. | Dark-stage readability, licker-style enemies, tail unlock, pursuit encounters. |
| 6 | Lake Island Lab | 2.5-3.0h | Linxi follows the drug clue toward an isolated research route and learns the virus is not random. | Multi-floor stage, security doors, elite humans, biomass spending, first controlled G-mode event. |
| 7 | Shelter Between Monsters | 1.5-2.0h | Linxi confronts whether survivors see her as protector, weapon, or disaster. | Safe-house expansion, relationship choices, non-lethal routes, training challenges. |
| 8 | S City Return | 2.5-3.0h | The story shifts from W City outbreak survival to the deeper origin conspiracy. | Larger maps, gang/human factions, stronger firearms, advanced body weapons. |
| 9 | Underground Institute | 3.0-3.5h | The institute, Subject 47 thread, cloning, and G-virus truth become playable. | Lab labyrinth, powered armor boss, rival evolved host, G-form mastery. |
| 10 | Disaster Core | 2.5-3.0h | Linxi's growth threatens to become city-scale catastrophe; the ending locks her direction. | Set-piece boss chain, escape timer, final shelter decision, ending branch setup. |

## Stage Details

### Stage 1: Red Night

Stage goal: Linxi finds out the world has changed.

Player goal: learn how to control Linxi through story situations, not through a detached training room.

This stage should feel like waking into a familiar place that has become impossible. The player should not immediately understand the outbreak as a normal "zombie level." Each level answers one story question and teaches one practical layer of play:

- Level 0: What happened to Linxi's body? Teach movement, camera framing, inspection, F interaction, neutral infected behavior, and the first safe feeding loop.
- Level 1: How does map transfer work? Enter the dormitory lobby, a compact non-scrolling room, and learn that staircases and doors are physical scene routes.
- Level 2: What happened inside the dormitory corridors? Move through the scrolling second-floor hallway, read doors as route choices, and approach Su Ruo's room.
- Level 3: What happened to Su Ruo? Search her room, inspect evidence, and leave toward the teaching building.
- Later Red Night levels: What happened to the students and survivors, why survivors fled toward the teaching building, and how far has the world outside the school changed? Teach attack, dodge, stun, knockdown, enemy range, route choice, shelter transition, and save cadence.

Tutorial rules:

- Tutorial prompts should appear only when the player needs the input, then fade quickly.
- The first time the player uses a system, the environment should make the correct action obvious.
- New mechanics should be introduced one at a time before they are combined.
- Story pressure should stay gentle until the player has demonstrated the required action.
- Stage 1 should end with the player comfortable moving, interacting, reading objectives, fighting a basic enemy, using/understanding digestion, and entering the shelter flow.

#### Courtyard Fall Site

- Location: school courtyard, dormitory, rooftop route, playground halfway point, and the school exit.
- Discovery Beat: Linxi realizes she should be dead, then slowly understands that the school, the students, and her own instincts have changed while she was unconscious.
- Plot: Red Night begins with the fall aftermath and grows into a full opening-route chapter rather than a short courtyard demo. Linxi wakes collapsed, drinks the chopper-dropped blue virus solution, blacks out, wakes weak again, unlocks claws, confronts infected students, decides whether to save or consume human students, enters the dormitory, finds Su Ruo's room, survives a dorm fight, reaches daytime/upstairs/roof beats, returns halfway across the playground toward the teaching building, faces an elite bone-blade zombie, reaches the teaching building classroom survivors, and finally exits the school.
- Objective: move from bodily confusion to first agency, then from dormitory horror to school-scale escape.
- Tutorial: WASD movement, fake-3D depth movement, camera follow, F interaction, simple interactable highlight, neutral infected behavior, claw attacks, knockdown, Vore availability, first digestion/biomass feedback, human rescue/consumption choice, route transition confirmation, dorm-room investigation, and first elite/boss pressure.
- Systems: fake-3D ground movement, F interaction, weak walk, opening story flags, zombie neutral-wander AI, first map-driven feed group, human-student chase/rescue behavior, transition-circle route items, fixed-room dorm/shelter maps, dorm combat wave, rooftop combat, and a late elite bone-blade zombie encounter.
- Current map design: the courtyard runtime uses a two-plate stitched background resource, `red_night_courtyard_visual_data.tres`, with the dormitory route at `(2750, 8)`. The map length is tuned to the approved background's physical scroll span so Linxi does not appear to float over a poster.
- Combat Pacing: the first post-blackout group is placed by map data and activates automatically; it must not be triggered by an item panel, and it must not contain heavy or elite enemies. Elite/bone-blade pressure belongs near the end of Red Night, after the player has learned claws, dodge, feeding, and route movement.
- Required feelings: disorientation, wrongness, fragile curiosity, hunger, shame, the pressure of choosing whether Linxi protects or consumes, and finally a clear push toward the world outside school.
- Exit condition: Linxi survives the roof/playground return route, defeats or bypasses the elite bone-blade zombie, meets the teaching-building twins, and leaves the school.

Expanded Red Night beat order:

1. Falling / aftermath.
2. First awakening on the ground.
3. Reach and drink the blue virus solution from the chopper-dropped nebulizer.
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
15. Teaching Building Lobby: enter after the playground battle and use the physical staircase.
16. Teaching Building Route: move from the lobby to the second-floor hallway, enter Classroom 503, speak with the twins, return through the hallway and lobby, then leave through the school front gate.
17. Exit the school.

#### Dormitory Lobby

- Location: dormitory first-floor entrance lobby with a visible switchback staircase.
- Discovery Beat: Linxi crosses from the open campus into an interior that should be safe but now feels sealed and watchful.
- Objective: enter the dormitory and use the staircase to reach the second floor.
- Systems: `FIXED_ROOM` camera mode, authored background image, map-authored `walkable_areas`, stair-run access, stair `blocked_areas`, upper platform route transition circle, no horizontal camera scroll, and a small rescue/fate dialogue beat.
- Current implementation: Li Yingying begins knocked down near the entrance, two zombie students attack from the stairs, and her conversation/choice unlocks only after the stair zombies are defeated.
- Presentation: the entire first floor fits on screen so the player reads it as a small contained space. Linxi can move on the lobby floor, lower switchback stair run, and upper/right stair platform, but not through the stair body or wall mass.

#### Dormitory Second Floor

- Location: second-floor hallway with multiple room doors.
- Discovery Beat: the dormitory expands from a single room into a route with multiple possible doors and later encounter hooks.
- Objective: move through the scrolling hallway and find Su Ruo's room.
- Systems: `SCROLLING` camera mode, generated hallway background, left return stair, Su Ruo room route, and a right-side roof stair transition locked by the Su Ruo clue story flag.
- Current implementation: the hallway stitches the accepted hallway plate with regenerated stair-side v4. It has three transition items, the Su Ruo room route is represented by an open-door prop, and four hostile infected are spaced through the corridor.
- Presentation: the second floor scrolls because it is a long corridor, not a compact room.

#### Dormitory: Su Ruo's Room

- Location: Su Ruo's dorm room.
- Discovery Beat: Linxi realizes the dormitory is no longer a living space; it is evidence of a collapse that happened while everyone slept.
- Plot: Linxi searches for Su Ruo and finds her bed empty, confirming she may have escaped.
- Objective: reach Linxi's room, collect Su Ruo's clue, leave toward the teaching building.
- Tutorial: read objective text, inspect items, collect archive records, approach interactables, avoid unnecessary fights, and understand that some items are story evidence rather than weapons.
- Systems: first archive pickup, dialogue window, ordinary infected avoidance, three non-combat human students as optional prey, and first basic feeding/digestion tutorial.
- Unlocks: claws as reliable body weapon; digestion bar; first biomass gain.
- Required feelings: personal fear, hunger, relief that Su Ruo may be alive, and shame/confusion about Linxi's new instincts.
- Presentation: small rooms use `FIXED_ROOM` camera mode so the entire room fits on screen and the player reads the scene as a contained dormitory space rather than a scrolling combat lane. Corridors may later use short scrolling maps if needed.

#### Roof Route

- Location: rooftop route spanning from the left edge of the school building to the right edge.
- Discovery Beat: Linxi realizes the outbreak did not only create monsters; it exposed what frightened people are capable of.
- Plot: survivors and hostile students reveal the school has become a moral pressure cooker.
- Objective: climb through blocked routes and locate evidence of Su Ruo's escape path.
- Tutorial: J attack, dodge timing, enemy attack range, stun/knockdown, simple combo timing, temporary weapon pickup/use/drop, and first safe feeding window after knockdown.
- Systems: first complete combat level, dedicated stitched roof visual data, stun behavior, knockdown states, basic enemy groups, item weapons.
- Boss: student thug or infected elite, depending on tone.
- Required feelings: tactical pressure, anger, protective instinct, and the first sense that Linxi can choose restraint or violence.
- Presentation: the roof map is a two-plate scrolling route set in the last few minutes before dawn. The left plate must show the left building edge, and the right plate must show the right building edge so the player reads the route as a complete rooftop.

#### Teaching Building Lobby And Second Floor

- Location: a fixed-room first-floor lobby leading by stairs into the second-floor survivor classroom after the elite playground battle.
- Discovery Beat: Linxi first confirms the teaching building was a real survivor route, then discovers the survivors upstairs.
- Plot: the twins explain that Su Ruo and other survivors may have followed the emergency route beyond the school gate. This gives Linxi an in-story reason to leave campus instead of wandering out because the level ended.
- Objective: enter the lobby, climb the second-floor staircase, talk to the twins, and unlock the outside-school route.
- Systems: fixed-room lobby presentation with authored negative-X floor padding, a physical stair transition, dialogue/avatar window, story flag `red_night_twins_met`, and a right-end school-gate transition that remains hidden until the conversation. The left-side teaching entrance returns to Playground Return, preserving bidirectional exploration before Stage 1 is committed.
- Entry cutscene: when the player confirms the route transition from `Playground Return` into the teaching-building lobby, a short daytime story overlay shows infected students converging on the first-floor entrance and classroom windows before control returns. Direct-loading the lobby for development should not trigger this by itself. The playable background stays actor-free; the cutscene explains that the infected are drawn together by survivor scent/presence inside the building, not simply trapped behind glass.
- Required feelings: discovery, uneasy restraint, and the first clean narrative push from school survival into citywide outbreak investigation.

#### Outside The School

- Location: school gate and perimeter road.
- Discovery Beat: Linxi realizes the school is only one point in a coordinated citywide disaster.
- Plot: emergency broadcast names multiple outbreak centers: school, hospital, and Black King nightclub.
- Objective: break through or bypass the gate, confirm the emergency broadcast, and reach the first shelter route.
- Tutorial: finish a level objective, read route/map information, enter shelter, commit progress, and review unlocked records.
- Systems: first mission-complete checkpoint, route map unlock, first shelter transition.
- Reward: safe-house archive terminal opens with school records.
- Required feelings: scale shock, loneliness, and a clear decision to keep moving because Su Ruo may still be somewhere ahead.

### Stage 2: Campus Lockdown

#### Level 0: Girls' Dormitory Return

- Location: upper dormitory floors.
- Plot: Linxi returns for supplies and finds traces of choices students made during the first night.
- Objective: retrieve personal items without losing control.
- Systems: optional rescue/avoid encounters, environmental storytelling, capacity tutorial.

#### Level 1: Classroom Block

- Location: classrooms, stairwells, roof access.
- Plot: Su Ruo's trail points outside the school, but not cleanly.
- Objective: recover a message, ID card, or phone fragment.
- Systems: group combat, dodge cooldown HUD, hit reactions, first thrown weapon.

#### Level 2: Gym and Service Yard

- Location: gym, sports field edge, maintenance road.
- Plot: the player sees how ordinary infected ignore or defer to Linxi until provoked.
- Objective: cross the school without triggering an overwhelming horde.
- Systems: stealth-adjacent crowd reading, movement-lane polish, first mutant creature tease.

### Stage 3: W City Emergency

#### Level 0: Evacuation Road

- Location: road outside the school, crashed vehicles, barricades.
- Plot: W City is not being rescued; it is being contained.
- Objective: reach a temporary shelter while avoiding patrols and infected clusters.
- Systems: human gun enemies, temporary weapons, camera-based background parallax.

#### Level 1: First Shelter

- Location: maintenance classroom or small municipal shelter.
- Plot: the shelter page becomes a practical progression layer while Memory Settings remains only the paused settings menu.
- Objective: review status, unlock mission board, talk through Linxi's condition.
- Systems: permanent save point, training area, archive terminal, equipment table.

#### Level 2: Broadcast Street

- Location: shops, alleys, public screens.
- Plot: media and corporate messages conflict; the player learns Annewst/Annius-style corporate monitoring is active.
- Objective: recover a broadcast source and mark the hospital route.
- Systems: encounter replay unlock, route choice preview.

### Stage 4: Central Hospital

#### Level 0: Hospital Perimeter

- Location: ambulance bay and emergency entrance.
- Plot: the hospital nebulizer turned an evacuation point into a contamination center.
- Objective: enter the building and find records about the blue stock solution.
- Systems: dense enemy placement, medical item interactions, locked route keys.

#### Level 1: Ward Stack

- Location: ward floors, stairwells, nurse station.
- Plot: Linxi sees how infection, panic, and triage failed.
- Objective: reach the medicine storage route.
- Systems: vertical pressure maps, ranged human enemies, special infected introduction.

#### Level 2: Medicine Storage

- Location: pharmacy, quarantine corridor, security checkpoint.
- Plot: a recovery team tries to extract valuable samples.
- Objective: take or destroy the sample record before the team leaves.
- Systems: elite human squad, uninterruptible heavy attacks, hit reaction rules.
- Reward: body-weapon upgrade path opens.

### Stage 5: Black King Nightclub

#### Level 0: Neon Street

- Location: entertainment district outside Black King.
- Plot: the nightclub is another deliberate outbreak point, not random chaos.
- Objective: enter the club while avoiding a heavy infected cluster.
- Systems: dark readability test, signage silhouettes, crowd noise cues.

#### Level 1: Dance Floor

- Location: main hall and balcony.
- Plot: infected movement becomes faster and less human.
- Objective: survive a multi-wave encounter and reach the upper floor.
- Systems: licker-style enemy family, pursuit pressure, tail foreshadowing.

#### Level 2: Back Rooms

- Location: KTV rooms, service corridors, broken outer wall.
- Plot: Yamata/Shanye leaves a clue and a drug sample that points to Lake Island.
- Objective: escape the club collapse and follow the clue.
- Systems: tail unlock or tail prototype; first serious monster-vs-monster duel.

### Stage 6: Lake Island Lab

#### Level 0: Bridge Approach

- Location: bridge, lake road, security perimeter.
- Plot: Linxi follows the clue to a controlled research site.
- Objective: enter the island facility.
- Systems: enemy patrol groups, alarm states, firearm pressure.

#### Level 1: Sample Vault

- Location: underground storage and specimen rooms.
- Plot: the virus has multiple branches and Linxi's body is unusually compatible.
- Objective: locate the second sample before the recovery team.
- Systems: resource locks, biomass spend gates, archive footage.

#### Level 2: White Lab

- Location: clean lab combat chamber.
- Plot: Linxi learns that G-form is not only power; it is cost, hunger, and risk.
- Objective: survive a controlled G-mode event and escape.
- Systems: temporary G-form tutorial, no-jump heavy movement, capacity expansion, biomass cost.

### Stage 7: Shelter Between Monsters

#### Level 0: Warm Classroom

- Location: memory-room classroom.
- Plot: the safe house reflects Linxi's inner human self and contrasts the fallen city.
- Objective: process archive discoveries and choose next route.
- Systems: mouse-based sign interaction, relationship conversations, status station expansion.

#### Level 1: Survivor Contact

- Location: small survivor pocket near the shelter.
- Plot: Linxi can protect people who fear her, but trust is fragile.
- Objective: resolve a shelter threat without turning every problem into feeding.
- Systems: non-lethal encounter rules, reputation flags, dialogue consequences.

#### Level 2: Training Evaluation

- Location: non-canon simulation room.
- Plot: the Evolution Room remains a training and replay interface.
- Objective: test new body weapons, dodge, tail, and combo branches.
- Systems: damage tables, combo review, challenge medals.

### Stage 8: S City Return

#### Level 0: Long Road Home

- Location: highway and abandoned checkpoint.
- Plot: Linxi's original home city becomes relevant again.
- Objective: reach S City while avoiding patrol containment.
- Systems: larger scrolling maps, vehicle wreck cover, stronger human firearms.

#### Level 1: Old District

- Location: streets, residential blocks, small shops.
- Plot: Linxi sees what survival outside W City looks like.
- Objective: gather clues about the company and S City facility.
- Systems: gang enemies, temporary gun/knife economy, tail combat.

#### Level 2: Bar Basement

- Location: underground gang room and connected alleys.
- Plot: human cruelty remains dangerous even after monsters appear.
- Objective: escape an ambush and decide what kind of monster Linxi refuses to become.
- Systems: confined combat, altered status effect, heavy G-arm moment.

### Stage 9: Underground Institute

#### Level 0: Lower Access

- Location: hidden elevator, old lab entrance, service tunnels.
- Plot: the institute becomes fully playable rather than background lore.
- Objective: reach the main experimental complex.
- Systems: lab security, environmental hazards, mutant creature family.

#### Level 1: Subject Records

- Location: observation rooms and archives.
- Plot: Subject 47 and earlier experiments explain why the outbreak had many outcomes.
- Objective: recover the records and survive containment release.
- Systems: archive terminal integration, clone/variant enemy wave.

#### Level 2: Powered Armor Trial

- Location: combat testing chamber.
- Plot: the company has already designed weapons for evolved infected.
- Objective: defeat or outlast a powered armor unit.
- Systems: heavy attacks that do not reset on stun, shield/weak point phases, G-form pressure.

#### Level 3: Rival Host

- Location: pure white lab and broken containment corridors.
- Plot: a rival G-compatible host forces Linxi to understand her own limits.
- Objective: win the duel and escape the failing lab.
- Systems: rival body-weapon mirror, advanced intake route unlock, final G-form mastery.

### Stage 10: Disaster Core

#### Level 0: Lab Self-Destruct

- Location: collapsing institute.
- Plot: human plans and viral growth collide into a disaster no one fully controls.
- Objective: escape with chosen records/allies before self-destruction.
- Systems: timed route, rescue vs archive tradeoff, final encounter flags.

#### Level 1: City-Scale Set Piece

- Location: S City surface.
- Plot: Linxi's power briefly becomes something too large for ordinary life.
- Objective: survive the catastrophe and retain selfhood.
- Systems: cinematic gameplay, limited-control G-disaster sequence, no farming.

#### Level 2: After Snow

- Location: aftermath field and memory space.
- Plot: Linxi survives, changed beyond easy categories.
- Objective: choose the ending posture: hide, protect, hunt the company, or seek Su Ruo/answers.
- Systems: ending records, New Game Plus flags, postgame Evolution Room.

## Progression Plan

### Forms

- Human: opening, safe house, memories, portraits.
- Early T-form: Stage 1 and Stage 2.
- Developed T-form: Stage 3 through Stage 6.
- Controlled G-form: introduced in Stage 6, mastered by Stage 9.
- Disaster-scale G expression: Stage 10 set piece only, not normal gameplay.

### Body Weapons

- Claws: Stage 1.
- Wrist bone blade: Stage 2 or Stage 3, after the first serious survival fight.
- Tail: Stage 5, tied to Black King/Lake Island evolution.
- Waist bone blade: Stage 8, after S City route opens.
- Voice or virus resonance: Stage 9, as anti-mutant or crowd-control weapon.

### Vore, Digestion, Biomass

- Stage 1 teaches digestion as a survival horror system with strict capacity.
- Stage 2 introduces capacity pressure and visible body-state overlays.
- Stage 3 makes biomass a real upgrade economy.
- Stage 5-6 unlocks additional intake routes through plot progression.
- Stage 6 introduces G-form 100% live-vore chance as a costly power mode.
- Stage 9 lets advanced intake routes matter tactically, but capacity remains the single hard limit.

## Safe-House Rhythm

Every major stage should end at either a shelter or the memory-room safe house. Confirmed map switches inside a stage save route checkpoints and allowed Linxi/story progression, but the stage-end shelter is the no-return gate. Before the player confirms the next stage, they can go back through currently unlocked routes and reclaim missed content; after the next stage begins, normal return is locked.

Recommended save points:

- After Stage 1, first true shelter / next-stage gate.
- After each later stage's final level.
- Before major point-of-no-return levels.
- In the shelter/safe-house page after skill, archive, status, or equipment changes.

Do not permanently save ordinary enemy positions or temporary encounter state when replaying from the editor/test start. Permanent saves should focus on route checkpoints, player status, story progress, unlocked records, skills, forms, biomass, weight, capacity, and currently undigested prey at valid checkpoints.

## Development Priority

1. Finish Stage 1 as the vertical slice: Courtyard Fall Site, Dormitory Lobby, Dormitory Second Floor, Dormitory: Su Ruo's Room, Roof Route, Playground Return, Teaching Building Lobby, Teaching Building Second Floor, and Outside The School.
2. Make the shelter/save rhythm real before adding more long-term growth.
3. Build one polished enemy family per stage before adding many behavior types.
4. Treat art production as gated: approved appearance first, then movement, attack, hit, knockdown, and special-state overlays.
5. Keep each new system attached to a level that teaches it.

## Open Questions

- How soon should Su Ruo appear directly: late Stage 2, Stage 3, or much later through records first?
- Should Yamata/Shanye be framed first as enemy, rescuer, or ambiguous observer?
- Does the first full G-form playable event belong in Lake Island Lab, or should the player see it once in a cutscene before controlling it?
- Which ending direction should the first complete version support: escape, revenge, protection, or unresolved continuation?
