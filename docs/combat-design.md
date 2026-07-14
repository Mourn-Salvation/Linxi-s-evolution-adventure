# Combat Design

## Combat Arc

The demo begins as an evaluation. Linxi has deliberate recovery, short defensive movement, and limited combo freedom. Successful, well-positioned hits build Resolve. At six confirmed hits she evolves into a capable fighter during play.

Evolution changes the combat language:

- Attack recovery becomes substantially shorter.
- The three-hit chain can be repeated smoothly.
- Dodge travels farther and supports aggressive repositioning.
- A close-range Vore becomes available against weakened enemies.

The transformation is mechanical, visual, and audible. It should not be presented as a statistical upgrade alone.

## Prototype Controls

- `WASD` or arrow keys: walk across the combat belt at controlled speed
- Double-tap `A` or `D` within `0.3` seconds and hold it: sprint horizontally
- On Android, push the virtual joystick beyond `50%` of its range in a primarily horizontal direction to sprint; the inner half remains analog walking
- `W` and `S` always adjust depth at walking speed; they never start or receive sprint speed
- The camera/projection layer keeps Linxi's rendered body and shadow inside a dynamic viewport safe zone with `16px` of additional clearance; oversized forms receive larger insets
- Press `J` while sprinting to perform one running claw attack: Linxi uses claw stage one, slides about `50` pixels on X with rapid ground-friction deceleration, deals a fixed `2` damage once, and returns to locomotion without entering the standing three-hit chain. The running attack has its own `3s` cooldown
- `J`: basic attack chain
- `K`: directional dodge with a `1.0` second internal cooldown
- V: attempt Vore; knocked-down enemies are guaranteed, live enemies use the current chance
- Hold `L`: enter Digest and advance its timer; releasing `L` immediately returns Linxi to normal mode with movement, attack, jump, and dodge restored
- `Space`: jump
- `R`: development-mode encounter reset only; not available to players

Keyboard is the only required input device for the demo.
## Weight And Biomass

- Weight is the only progression value that reduces movement speed.
- Movement speed multiplier is `1 / sqrt(weight)`, with walking clamped to a minimum of `50`.
- The later Weight Adaptation passive removes this speed penalty.
- Biomass does not slow movement. It increases capacity, attack damage, live-Vore chance, digestion speed, and permanent body growth.
- Base attack is `2`; biomass adds up to `+2` linearly, reaching `4` total attack at `20` biomass.
- Permanent visual growth reaches its maximum `1.2x` scale at `20` biomass.

## Spatial Model

Combat occurs on a 2D belt. X controls horizontal position and Y represents lane depth. Visual draw order follows world Y. Attacks use separate gameplay hitboxes rather than sprite pixels.

Actor presentation uses a vertical screen-depth projection: pressing `W/S` moves Linxi visually up/down, not diagonally. The ground plane and background keep the angled fake-3D projection so the scene still reads as a depth belt.

Attack checks are shadow-footprint aware. Authored attack data describes reach beyond the attacker, but the final hit test includes the attacker's grounded shadow radius and the target's grounded shadow radius. Telegraph/previews must use the same footprint math, so a small projected enemy cannot show or apply a range that visually belongs to a larger unit.

Zombie-student attack range is intentionally shorter than human/weapon reach. Their current two-frame attack animation is bare-handed, so the authored reach is `zombie_attack_range = 46` with `zombie_depth_range = 30`; the final hit check still adds both actors' grounded shadow radii. Do not reuse the old human `125` reach for bare-handed zombies unless the animation visibly supports it.

## Initial Moveset

- Three-hit grounded claw attack chain
- Directional dodge
- Resolve-based mid-encounter evolution
- Vore against knocked-down enemies is guaranteed; live targets use the current success chance
- Hurt, short hit stun, knockdown, recovery, and defeat states

## Player Verbs

- Move left, right, upstage, and downstage within the fake-3D belt.
- Attack with short body-weapon chains.
- Launch, stagger, knock down, or finish enemies.
- Dodge or reposition.
- Interact with story objects, gates, temporary weapons, and shelters.
- Digest carried prey only when the current state allows it.

## Feel Targets

- Tactical opening with meaningful whiff recovery
- Faster input cadence and cancel freedom after evolution
- Input buffering for attack chains
- Default claw chain reads as three coordinated body actions: right-arm downward cut, left-arm cross cut, right-arm finishing rake. Hips, waist, and legs should visibly carry the force instead of arms moving alone.
- Slash effects are separated from body animation as reusable aliases: red for virus/body attacks, silver for steel or other weapons.
- Tail attacks are a later body-weapon family. The tail must be designed as a black segmented biomass weapon held behind Linxi in a ready posture before tail combat frames are generated.
- The first runtime tail asset is a behind-body overlay controlled by `tail_unlocked`. It is visual/readiness language only until tail attack data and animations are authored.
- Short hit-stop on confirmed hits
- Clear anticipation and recovery frames
- Runtime motion trails are applied to player and enemy animation draws. They are a presentation layer, not baked sprite data, and should help actions feel heavier while masking minor frame-to-frame imperfections.
- Strong but controlled screen shake
- Separate body, weapon effect, projectile, and impact assets
- Hit reactions must preserve the enemy's visual identity. Variant enemies should keep the same `appearance_id` when struck and use hit poses, offsets, or variant-matched frames rather than swapping to an unrelated family-wide model. Stun duration controls mechanics; hit-reaction time controls presentation so short stuns can still read visually.
- Hit-stun scales from final attack damage, then clamps to the current stun cap. Higher ATK should make light enemies flinch longer without turning ordinary hits into permanent lockdown.
- Virus/body impacts use two separate FX families:
- Body-based hit FX appears only when a unit is struck. It is attached to the struck unit's ground position and plays briefly near the body.
- Ground-based biomass residue is spawned from the struck unit's coordinates with slight random offset. It stays on the ground for roughly `2-3` seconds and fades slowly instead of disappearing immediately.

## Hit And Hurt Rules

- The game has no accuracy roll, miss chance, evasion statistic, or separate miss-feedback system. Attacks resolve only through physical lane/depth range, grounded shadow footprints, attack direction, jump height, dodge, and invulnerability.
- Body attack volumes are measured from grounded shadow footprints, not raw sprite pixels or center points.
- Attacks that do not overlap a valid target simply complete their animation and recovery without displaying miss text or spawning hit feedback.
- When Linxi is hit, she enters a short hurt stun in place. Enemy hits should not push her backward; positioning remains stable unless the player cancels the hurt state with dodge or vore.
- When Linxi is hit, she enters a `0.1s` hurt stun. Movement, jump, body attacks, and temporary weapon use are blocked during this short stun.
- Dodge and Vore are special cancels: Linxi may still perform them during hurt stun.
- A successful Vore clears the hurt stun/flash and starts a short execution freeze. The world and generic hit FX pause while Linxi's intake/body expansion presentation continues, matching the intended execution feel.

## Level 0 Combat Readability

Red Night is the first place the player learns whether combat is fair. Before balance gets harder, the level must explain the rules visually:

- Player-facing HUD keeps only objective text, Linxi HP, capacity, biomass, dodge readiness, contextual hints/prompts, dialogue, and achievements.
- Linxi's upper-left HP frame extends to `490 px` wide. A compact `50 px` temporary-weapon slot sits beside the prey-capacity indicator on the original row beneath HP. It shows the handgun/knife silhouette and remaining uses, or a subdued empty mark. Biomass remains on the next row.
- Digestion progress remains a world-space bar above Linxi and appears only while she is actively digesting.
- Prototype variables such as speed, height, raw ATK values, target HP numbers, enemy state, and full control listings are development-mode/debug information. They should not be visible during normal Red Night play.
- Enemy HP is shown as a compact bar above each visible enemy, because the player needs that information in the playfield rather than in a top-right debug label.
- Player attack range preview is currently disabled. Attack reach still uses shadow-footprint combat math; enemy telegraphs remain visible for readability.
- Normal enemy telegraphs show a warm red danger zone.
- Heavy enemy telegraphs show a purple danger zone and remain uninterruptible.
- Combat preview zones must align with the same shadow-footprint range used by hit checks, including family-specific reach such as the shorter zombie-student hand reach.
- These previews are tutorial readability layers, not final combat effects. They may later be faded, disabled by difficulty, or replaced by authored animation/FX once the player has learned the rules.
- The first post-blackout infected group is map-driven and already present in the scene. It is not spawned by an item interaction.
- Level 0's first feed group must use ordinary neutral zombie students only. No heavy, elite, or uninterruptible enemy belongs in this first courtyard round.
- Dorm-front zombie students can attack human-student NPC prey during the chase beat. If all human prey are knocked down or gone, they switch back to ordinary Linxi pursuit instead of harmless wandering.
- The dormitory lobby contains a separate rescue/fate beat: Li Yingying begins knocked down near the entrance, two stair zombies must be defeated first, and her dialogue/choice item unlocks only after that threat group is cleared.
- The fake-3D walkable belt/grid is development-mode information in Red Night. It should not be visible in normal play.
- Nebulizer contamination mist is airborne vapor. Local mist around the device and scattered environmental wisps float above the ground plane, with higher density near the source.

## Enemy Visual Variants

Boss enemies are marked in map data with `boss = true`, a reusable `boss_name`, and a `boss_approach_range`. Approaching one latches a centered bottom-screen boss health bar for the duration of that fight. The production boss bar spans 80 percent of the viewport and uses a compact 20-pixel outer frame. Ordinary enemies retain their compact world-space HP bars.

- Enemy behavior is owned by family and attack data, not by individual art files.
- Zombie-family enemies can specify `appearance_id` in map data to choose a visual variant while sharing the same AI, hit reaction, damage, and Vore rules.
- Hit reactions must not change `appearance_id`; at least two visual hit poses/frames should exist per enemy family so repeated hits read as impact instead of a color flash.
- Every sprite-backed enemy must have a knocked-down pose. Current coverage includes human guards, male/female human students, and zombie student variants; future mutant enemies need approved knocked-down sheets before they are accepted into runtime.
- Combat-capable sprite enemies should expose move, attack, hurt, and knocked-down art. The current demo has provisional derived move/attack/hurt frames for human guards and zombie students, with zombie frames stored per `appearance_id` so getting hit does not swap the model. Red Night zombie students use a two-frame attack contract: frame `00` is the hands-forward wind-up shown while the cast bar fills, and frame `01` is the downward arm strike shown after the attack releases. Knife-armed human students also use a two-frame weapon-specific contract: frame `00` holds the knife arm aside during cast, and frame `01` is the forward knife swing during recovery/release. Any provisional frames are temporary runtime placeholders until fully approved generated sheets replace them.
- This lets us build crowd variety first, then adjust AI profiles later without duplicating enemy classes.
- `human_student` is a Human-family non-combat enemy archetype for story/crowd redesign work. It uses `NON_COMBAT_WANDER`, begins dormant when placed in Red Night, and must never enter attack telegraph or attack recovery states.

## Dodge

- Dodge is a locked evasive animation, not free movement.
- Press `K` to dodge in the current movement vector.
- The dodge vector is mostly X-axis movement. `W/S` input adds only a small depth drift through `dodge_depth_ratio`.
- If the player presses only `W` or `S`, Linxi still dodges toward her current facing direction with slight depth movement.
- Dodge grants damage avoidance during the dodge animation.
- Dodge has a `1.0` second internal cooldown.
- A bottom-right HUD icon shows readiness. When unavailable, it shows remaining cooldown.
- G mode cannot dodge.

## Data Ownership

Canonical balance lives in `resources/balance/default_balance.tres` through `GameBalance`. Directional body attacks live in `resources/attacks/` as `AttackData` resources. The stage host may still own presentation state and temporary tutorial glue, but new combat tuning should move into resources instead of being added as permanent controller constants.

Current claw attacks are three separate combo stages. Each `J` press commits one stage, plays the matching section of the claw sheet, locks Linxi's movement during the attack window, and deals one `2` damage event before returning to idle/walk if the player stops pressing attack. The base stage cooldowns are short for the current fast Red Night pacing: neutral `0.30s`, left/right `0.34s`, and up/down `0.36s`.


## Vore And Digestion

- Enemies at zero HP enter `KNOCKED_DOWN` and cannot resist Vore.
- Live targets begin at a 20 percent Vore chance. Biomass raises this linearly to 100 percent at 50 biomass.
- Swallowed prey is currently assigned to the belly visual outfit layer only.
- Chest, lower-abdomen, and groin expansion are deferred until the belly pipeline is proven.
- Contained prey contributes its full weight immediately.
- Digestion starts at three cumulative seconds of holding `L` per prey. Biomass reduces the required time linearly, up to a maximum 50 percent reduction at 50 biomass. Releasing pauses without losing progress; incoming damage does not cancel stored progress.
- Each successful Vore adds `1` provisional maximum HP during the mission; settlement commits it permanently. Completing digestion restores `1` current HP, clamped to Linxi's current maximum HP.
- Digestion converts 25 percent of each prey's weight into provisional mission biomass. Mission settlement commits it across sessions.
- Ordinary test prey currently use weight `1.0`. Authored elites may override weight and visual load independently: the Bone-Blade Twin uses `prey_weight = 4.0` and `vore_visual_load = 4`, producing belly tier 4 immediately and four times ordinary digestion biomass while occupying one prey slot.

## Vore Capacity

- `vore_capacity` is an exported integer that defines how many prey slots Linxi can hold at once.
- The default base capacity is 1.
- Biomass grants one capacity slot per whole point, capped at 20 biomass-derived slots.
- Base-capacity upgrades and the G-mode bonus are added separately after this cap.
- `occupied_vore_capacity` tracks occupied prey-weight units rather than enemy count. Ordinary weight-one prey costs one slot; the Bone-Blade Twin costs four. Intake is rejected before animation when the target's full cost exceeds available capacity, with a short warning above Linxi and a detailed HUD message.
- Each current test enemy costs one capacity slot; later enemies may define larger costs.
- Vore is blocked when occupied capacity would exceed the maximum.
- Fully digesting prey frees its occupied slot.
- Capacity is included in Linxi's progression save data for future upgrades.
- Undigested prey is Linxi body state, not map enemy state. Route transitions carry occupied capacity, contained prey weight, route loads, and digestion progress into the next scene so belly presentation and digestion can continue after map switches.

## Route-Based Expansion Presentation

- Vore expansion is presentation-only. It must not change movement, attack range, collision, dodge, capacity, digestion timing, or hit checks.
- The hard mechanical limit is still capacity. In the current demo scope, all enabled intake routes add to `BELLY`.
- `CORE`, `LEFT`, and `RIGHT` are enabled and add to `BELLY`.
- `UPPER`, `LOWER`, and `BURST` remain future route names but are disabled until the belly module is proven.
- Belly has four visual tiers: one prey, two prey, three prey, and four-or-more prey. Counts above four reuse tier four with controlled overflow scaling.
- Runtime overlay art lives in `assets/sprites/linxi/t_early/intake_layers/`.
- Uploaded reference material lives in `source_assets/characters/linxi_vore_expansion_references/` and must be converted into frame-aligned transparent belly overlays before gameplay use.

## Digestion Bar

- A world-space bar appears above Linxi only while she is actively digesting.
- The bar hides immediately when `L` is released or when no prey is contained; paused progress remains stored.
- Each prey normally requires three cumulative seconds, reduced by Linxi's current biomass. At 50 biomass each prey requires 1.5 seconds. Two contained prey therefore require six total seconds at 0 biomass or three total seconds at 50 biomass if the player keeps holding `L`.
- Segment markers divide the current remaining prey count.
- Every completed three-second segment digests one prey immediately, frees that slot, reduces the visible belly/intake tier, and rescales the bar to the remaining prey count.
