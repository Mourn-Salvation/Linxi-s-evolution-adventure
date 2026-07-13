# Linxi Progression

## Forms

### Human Identity

Linxi is human before the worldwide biochemical incident, but Human is not a selectable or post-fall playable form. Human Linxi appears in the opening cinematic, memories, concept art, portraits, and the safe house's symbolic presentation. She establishes Linxi's original identity and remains the way Linxi understands herself internally.

### T-Zombie

The virus revives Linxi after the fall. She retains her human consciousness and proportions but develops pale skin and growing zombie abilities. T-Zombie is the first playable story-stage form and the normal body used after the outbreak.

Developed T-Zombie may unlock a black segmented biomass tail. The tail is a body weapon and silhouette change, not an early weak-form default. It should be approved before Vore expansion references because it occupies the same rear/hip silhouette space as belly and lower-body route visuals.

Tail unlock is plot-driven. Runtime uses `story_flags["tail_unlocked"]` to persist the unlock and draws the tail as a behind-body overlay when active. Tail attacks remain locked until their own combat animation and damage data are authored.

### G-Zombie

Linxi expands into an approximately three-meter muscular form protected by a biomass exoskeleton. G-Zombie currently provides fixed heavy movement, armor, expanded capacity, and guaranteed live Vore; final character artwork remains pending. The future multi-route batch-intake fantasy is deferred until the belly Vore module is stable. G-Zombie should carry a heavier version of the biomass tail language.

## Weight And Biomass Model

- `permanent_weight` is a saved body-weight stat and only affects movement speed.
- `contained_prey_weight` is temporary carried prey weight and also contributes to movement slowdown until digestion finishes.
- `biomass` is a separate saved progression resource.
- Digestion removes contained prey one unit at a time and converts 25 percent of each digested prey's weight into biomass.
- Biomass increases attack, capacity, live-Vore chance, digestion speed, and permanent visual growth; G mode spends 10 biomass.
- Attack reaches `4` and permanent body scale reaches `1.2x` at `20` biomass.
- Current maximum biomass is `50`. Live-Vore chance reaches 100 percent at `50` biomass.
- Digestion time reaches its maximum 50 percent reduction at `50` biomass, so the default three seconds per prey becomes 1.5 seconds per prey.

The current gray-box represents T-Zombie mechanics and G-Zombie transformation without treating Human Linxi as a playable combat form.
## Capacity Progression

Vore base capacity begins at one prey slot and is saved as a progression stat. Biomass adds one slot per whole point up to a maximum bonus of 20 biomass-derived slots. Base upgrades and G mode add capacity separately.

## G-Mode Prototype

- Press `G` to spend 10 permanent biomass and transform for 10 seconds.
- Movement speed is fixed at 150 and ignores weight.
- Jump, sprint, and dodge are disabled.
- Incoming hit damage is reduced by 5 through the biomass exoskeleton.
- Live-target Vore chance is 100 percent.
- Effective capacity gains 10 units. The active routes share one capacity pool and do not impose per-route limits.
- Current G-mode Vore inputs still use the belly-only active route set. Future batch intake will be reintroduced after the belly overlay pipeline is approved and tested.
- Active intake routes in the current demo scope: ordinary `V` Core, `A+V` Left, and `D+V` Right.
- `W+V` Upper, `S+V` Lower, and `V+V` Burst are known future routes but are disabled until the belly Vore module is proven.
- Route names are mechanical placeholders pending a non-explicit final presentation design.
## Maximum Health Growth

Each successful Vore increases mission-local maximum HP by one. The increase becomes permanent only when Linxi reaches a valid shelter, safe house, or authored story checkpoint that commits progression. Abandoning, restarting, or redeploying before a valid checkpoint discards the provisional gain. Completing digestion of each prey restores one current HP, clamped to Linxi's current maximum HP. If Linxi carries multiple prey and the player holds `L` long enough to digest only part of the batch, completed prey are removed immediately and the visible belly tier updates to the remaining prey count.

## Save And Digestion State

- Permanent save data is centered on Linxi and story progress, not on enemy simulation state.
- Save data may preserve carried prey, route loads, digestion progress, and body-presentation state at confirmed map switches, shelters, and safe-house status pages, because the player needs to see what Linxi currently looks like at valid checkpoints.
- Active enemy HP, enemy positions, telegraph timers, and repeatable encounter depletion should not become permanent save data.
- Digestion-derived biomass is provisional during active combat. It commits only at a confirmed map switch, shelter, true safe house, or authored story checkpoint.
- Shelters are the normal post-encounter stage gates. Before leaving for the next stage, the player may return to currently unlocked maps; after the next-stage confirmation, normal return is locked. Memory Settings only pauses the game and changes settings; it must not become a reward-farming exit.
## Intake Route Unlocks

- Core Vore is available from the beginning.
- Left, Right, Upper, Lower, and Burst are permanent plot-progression skill unlocks.
- Story code unlocks a route by calling `unlock_intake_route("ROUTE_NAME")`.
- Route unlocks are saved across sessions.
- G mode temporarily makes all currently enabled routes available, even when their story unlock has not occurred.
- Leaving G mode restores the normal saved unlock restrictions.

## Body Expansion Presentation

Contained prey is displayed through belly overlay layers rather than changing Linxi's base animation files. The current active overlay region is belly only, with four visual tiers. Chest, lower-belly, and groin presentation are deferred until the first belly Vore module is stable. This keeps the combat animation set stable while still showing what Linxi is carrying at shelters, during digestion, and during valid combat states.

G-mode exoskeleton art is a separate form/silhouette problem. The current uploaded exoskeleton prototype is a source reference, not final runtime art, and should guide the later G-form body sheet rather than being pasted over T-form frames directly.
