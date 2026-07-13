# Fake-3D Coordinate Model

## Logical Coordinates

Actors use three independent gameplay values:

- `ground.x`: horizontal position along the stage
- `ground.y`: depth into or out of the stage
- `height`: airborne distance above the ground plane

Depth remains a separate gameplay coordinate. In Red Night the projection is intentionally split:

- Environment/ground projection keeps a shallow diagonal so the floor reads as a fake-3D belt.
- Actor/item/combat-feedback projection uses vertical screen movement so `W/S` feels straight up/down to the player.

This keeps the depth illusion in the scene composition without making the player feel like the control scheme is diagonal.

```text
screen_ground_floor = origin + (ground.x - camera_x, 0) + floor_depth_axis * ground.y
screen_ground_actor = origin + (ground.x - camera_x, 0) + actor_depth_axis * ground.y
screen_sprite = screen_ground_actor - (0, height)
```

The current Red Night prototype uses:

```text
origin.x = 170
origin.y = viewport_height - 30 - floor_depth_axis.y * map_depth
floor_depth_axis = (-0.32, 0.86)
actor_depth_axis = (0.0, 0.86)
map_length = 2800
map_depth = 280
```

At the default 1280x720 presentation this places the projected belt around Y 449 to Y 690. The playable ground should read as a bottom-screen action belt, not a centered platform floating in the composition.

The floor axis's negative X component makes deeper grid lanes drift slightly left as they move down-screen, giving the ground plane a staged perspective. Actors do not inherit that X drift. If depth movement feels like the player is fighting a diagonal control scheme, the visual trick has failed.

Player input remains `W/S` for depth and `A/D` for horizontal movement. Jump uses `height`, not `ground.y`.

## Rules

- Movement and attack lane checks use logical ground coordinates.
- Draw order uses logical depth, never jump height.
- Shadows, sprites, interactable prompts, hit FX, and combat readability zones use the actor projection.
- The floor belt, floor grid, map edge lines, and fixed-room floor planes use the environment/ground projection.
- Floor grid, map edge guide lines, walkable-zone fills, blocker-zone fills, and live coordinate text are development-mode overlays only. Normal gameplay should show the floor/background art without construction grid lines.
- Use the pause-menu `Dev Overlay` button in `development_mode` when tuning map coordinates. The mouse readout reports logical actor/world placement coordinates, while zone rectangles are drawn through the floor projection so the authored floor plan can be compared against the background art.
- Attack and telegraph ranges are measured from grounded shadow footprints: authored reach plus attacker shadow radius plus target shadow radius.
- Player attack range preview is currently disabled. If restored later, it should be anchored to Linxi's actor-projected shadow rather than drawn as a rectangular ground debug box.
- Jump velocity and gravity affect only `height`.
- Stage collision constrains `ground.x` and `ground.y`.
- Future airborne attacks may query both ground range and height range.
- Teaching Building Lobby keeps its approved fixed-room background unchanged and applies a `+100 Y` correction only to the gameplay layer: walkable polygon, depth bound, player spawn, enemy spawns, and local transition. For background-alignment corrections, treat the approved image as the reference and move all world-space gameplay elements together.
