# Effects Assets

Runtime visual effects live here.

## Combat Slash FX

- Runtime folder: `assets/effects/combat/claw_slash/`
- Resource owner: `resources/effects/red_night_effect_visual_data.tres`
- Current runtime use: Linxi claw attacks, zombie attack release frames, and human melee/knife attack release frames.
- Direction rule: select `left_*` or `right_*` from the attacker's facing direction so the slash follows the actual attack flow.
- Color rule: red slash frames represent biomass/virus force and are used by Linxi's claws and zombie enemies. Silver slash frames represent steel or human weapon sharpness and are used by human melee/knife enemies.
- Presentation rule: slash FX are drawn on release/recovery frames, not across the whole cast bar. The cast bar/rim communicates anticipation; the slash communicates impact.

## Opening Signalis-Style Pixel Filter

- Shader: `assets/effects/opening_pixel_filter.gdshader`
- Material resource: `assets/effects/opening_signalis_pixel_filter.tres`
- Current runtime use: opening scene only, via `OpeningPixelFilter` in `scenes/opening_intro.tscn`.
- Resolution rule: the filter snaps/samples at a minimum of `1280x720`; do not lower it below 720p. This keeps the art high-resolution with a retro filter instead of turning it into low-resolution pixel art.
- Visual intent: restrained retro-survival-horror treatment inspired by Signalis art direction: mild palette compression, cool color bias, subtle scanlines, slight chromatic edge offset, and vignette.
- Rollout plan: verify the look in the opening scene first. After approval, promote the same material or a shared variant to gameplay scenes.

## Signal Interference Overlay

- Scene resource: `scenes/effects/signal_interference_overlay.tscn`
- Script/API: `scripts/effects/signal_interference_overlay.gd`
- Current runtime use: opening red-eye flash beat in `scenes/opening_intro.tscn`.
- Purpose: reusable full-screen signal-break effect for red-eye moments, mutation shocks, memory corruption, system failure, or later story events.
- Trigger API: call `trigger(duration, intensity)` on the overlay instance.
- Visual intent: original signal interference: scanline flicker, horizontal tear bands, cyan/red channel accents, dropout bars, and sparse static. It replaces blunt white-screen flashes while preserving readability.
- Usage rule: keep the effect short and event-driven. It should feel like a sensory/system rupture, not a constant screen filter.

## Red Night Atomization Fog

- Runtime folder: `assets/effects/red_night/atomization_fog/`
- Purpose: blue virus mist/fog around the chopper-dropped nebulizer, showing the rough spread range of the atomized stock solution.
- Current runtime: four texture-based atomization fog points are drawn around the chopper-dropped nebulizer only before Linxi drinks the vial. After `red_night_blue_stock_taken` or the nebulizer is marked empty, the fog disappears. Each fog point keeps a stable texture shape selected from its seed; only sparse screen-space drift, vertical bob, and opacity pulse are allowed.
- Placement rule: keep the fog sparse, airborne, and readable around the nebulizer. Do not scatter a full mist field across the courtyard.
- Fallback rule: procedural/hand-drawn haze is disabled for player-facing nebulizer fog. If approved atomization textures are missing, show no fog and fix the asset reference. The nebulizer item renderer must not draw its own circle/arc mist.
- Production rule: effects should use approved imported textures or sprite loops. Do not add new self-drawn/procedural player-facing effects except as a named temporary placeholder.

## Intake Layer Pixel Treatment

- Shader: `assets/effects/intake_layers/intake_layer_pixelize.gdshader`
- Material resource: `assets/effects/intake_layers/intake_layer_pixelize_material.tres`
- Current runtime use: belly/intake overlay PNGs are baked with the same pixel/posterized treatment because Red Night still draws these layers through custom `_draw()` calls.
- Purpose: make body-overlay assets read like in-game sprite layers instead of floating illustration cutouts.
- Visual intent: mild pixel snap, restrained palette compression, and darkened alpha-edge integration. The treatment must not repaint the approved source art or alter the character silhouette.
- Source rule: keep approved raw intake art under `source_assets/`; only runtime copies under `assets/` should receive baked shader-style processing.
