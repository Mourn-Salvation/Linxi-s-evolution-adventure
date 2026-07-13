# Enemy Design

## Families

### Human

Humans read the combat belt, align to Linxi's depth lane, use clear tactical telegraphs, and expose punishable recovery. Equipment, training, and group roles create variety within the family.

### Zombie

Zombies prioritize pressure over self-preservation. Their later implementation may use poor lane discipline, armor through light hits, grabs, infection, or revival depending on the fiction.

### Mutant Creature

Mutant Creatures are allowed to break ordinary humanoid rules through unusual bodies, ranges, movement patterns, and attack heights. Their mechanics must be derived from the creature design rather than forced into the Human controller.

## Appearance And Behavior Split

Enemy appearance and enemy behavior are separate systems.

- Appearance variants cover outfit damage, hair silhouette, posture, infection marks, and readable role identity.
- Behavior is owned by family, `ai_profile`, attack type, state rules, and encounter data.
- A new hairstyle, outfit variant, or infection detail should not create a new enemy behavior class.
- Map data should select appearance through `appearance_id` or a future equivalent.
- Future behavior variety should use data such as `ai_profile = "NEUTRAL_WANDER"`, `"ZOMBIE_CHASE_HUMAN"`, `"CHASER"`, `"AMBUSHER"`, or `"HEAVY"` before creating separate scripts.
- `scripts/data/content_validator.gd` validates known `ai_profile` values so map typos fail tests early.

New enemies must follow `docs/production-sop.md`. Use `docs/art-direction.md` for art order and acceptance. Do not accept a new enemy into runtime until its source folder states whether it is accepted, rejected, or superseded.

## Current Red Night Enemy: First Zombie Student

The first enemy Linxi meets after the blackout is a zombie-family student, authored as `courtyard_scout`.

This enemy uses `ai_profile = "NEUTRAL_WANDER"` instead of the normal attacker loop:

1. It enters `NEUTRAL` state when the story reaches the second wake-up phase.
2. It wanders inside the courtyard and faces its movement direction.
3. It does not approach, telegraph, or attack Linxi.
4. If Linxi hits it, it staggers briefly, then returns to `NEUTRAL`.
5. Its purpose is narrative and mechanical: the player learns that ordinary infected do not initially read Linxi as normal prey because she is infected too.

This behavior is selected by map data. Do not hardcode special behavior by enemy ID unless the story beat truly cannot be expressed through `story_group`, `ai_profile`, or a future behavior resource.

## Current Red Night Dorm Chase: Zombies Attacking Humans

Near the dormitory, Red Night now uses `ai_profile = "ZOMBIE_CHASE_HUMAN"` for a group of five zombie students.

1. The zombies begin dormant while Linxi learns the first feeding loop.
2. When the dorm-side beat opens, the `dormitory_wave` group enters `APPROACH`.
3. Each zombie searches for active human-student prey by `archetype = "human_student"`, not by a single hardcoded id.
4. Zombies approach the nearest human student, telegraph, and damage that human if still in range.
5. If no living human prey remains, they fall back to wandering until Linxi engages or later behavior is authored.

This is the first civilian-pressure scene: the world continues collapsing around Linxi instead of waiting for the player to interact with an item.

## Current Combat Test Enemy: Human Guard / Standard Attacker

State loop:

1. Align to Linxi's logical depth lane.
2. Approach horizontally.
3. Telegraph a close strike.
4. Resolve the attack against ground range and height.
5. Enter a punishable recovery.
6. Stagger briefly when Linxi confirms a hit.

Current production direction uses the enemy HP/cast bar plus a red or purple outline/rim during casting. Obsolete drawn telegraph arcs and preview cones must not return to normal gameplay.

## Current Red Night Roof: Knife Students

The rooftop armed students are Human-family `human_student` enemies with `weapon_id = "knife"` and appearance variants `06` and `07`.

1. They begin frozen during the rooftop standoff.
2. The dialogue choice releases them into the normal attack loop.
3. Their attack visuals are weapon-specific: frame `00` keeps the knife arm aside while the cast bar fills, and frame `01` shows the forward knife swing during release/recovery.
4. The weapon animation is selected by `weapon_id`, not by a separate enemy class, so future knife variants can share the same behavior profile while keeping appearance-specific art.

## Bone-Blade Twin Elite

The Playground Return elite uses `archetype = "bone_blade_twin"` and the dedicated `BONE_BLADE_ELITE` profile. Its authored combat values are `25 HP` and `AC 1`; enemy AC is flat incoming-damage reduction shared by body attacks and temporary weapons. As prey it has weight and visual load `4`, so consuming its knocked-down body immediately selects belly tier 4 and digestion grants four times the biomass of one ordinary zombie. Its approved runtime set contains idle, eight-frame movement, two-frame normal attack, two hurt frames, a knocked-down pose, and a three-strike bone-blade rush. Each strike uses two timed poses from the approved four-pose source: source `03 -> 01`, then `02 -> 02`, then `04 -> 01`.

The special begins only when Linxi is within 240 horizontal pixels and the elite's depth lane. A purple 0.72-second telegraph locks its facing, followed by three blade swings. Each swing advances up to 80 world pixels and deals 4 damage through a swept lane test; dodge, airborne height, and ordinary player invulnerability still apply. Strikes are spaced 0.55 seconds apart, followed by recovery and a five-second cooldown. A confirmed interruptible hit during the special cancels the sequence and starts its cooldown.

On Playground Return, the elite begins frozen at the center of the walkable zone. Crossing an invisible map-authored trigger starts a short failed-communication dialogue. Closing the final line marks the boss engaged, reveals the boss HUD, and releases its AI. The Teaching Building transition requires the `playground_bone_blade_elite` group to be defeated and remains hidden and locked beforehand.

## Cast Interruption

- Normal telegraphed attacks are interruptible. A confirmed hit clears the cast timer and replaces the attack with the standard 0.1-second stagger.
- Heavy telegraphed attacks are uninterruptible. Damage still applies, but the cast state and remaining timer continue unchanged.
- Heavy attacks use a longer purple telegraph and must be answered by dodge or lane movement.
- Attack type is authored per enemy spawn in `MapData` through `attack_type = "NORMAL"` or `"HEAVY"`.
