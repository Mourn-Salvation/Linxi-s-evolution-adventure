# Plugin Workflow

Third-party plugins may improve development speed, but they must not own Linxi's core rules directly. Put every production use behind a local adapter or component so a plugin can be replaced later without rewriting combat, save, story, or map data.

## Imported Plugins

Enabled:

- `addons/debug_console` - development console for map jumps, test commands, biomass setup, story flags, and runtime inspection.
- `addons/phantom_camera` - camera sandbox candidate for cinematic transitions and camera behaviors. Do not replace the fake-3D projection camera until tested.
- `addons/AsepriteWizard` - art workflow helper for Aseprite/SpriteFrames/AnimatedSprite2D imports.

Installed but disabled:

- `addons/godot_projectile_engine` - projectile/bullet sandbox candidate. It is disabled in `project.godot` because its editor/runtime scripts can still break clean Godot 4.6.2 launch. Use it only behind a future local `ProjectileAdapter`, not directly from weapon code.
- `addons/dialogue_manager` - dialogue-authoring candidate for branching conversations and larger shelter/character scenes. It is disabled until its Godot 4.6.2 view scripts are verified or wrapped by a local dialogue adapter.
- `addons/beehave` - behavior tree candidate for future enemy AI. It is disabled because the enabled editor plugin produced a Beehave debugger quit warning under the current Godot 4.6.2 test path. Keep it available for sandbox work, but do not enable it in the main project until the warning is resolved or judged harmless.

## Compatibility Notes

- Godot Projectile Engine has one local Godot 4.6.2 compatibility patch in `PCCGroup.gd`; see `source_assets/plugins/plugin_import_manifest.md`. Keep the plugin disabled until a projectile sandbox scene proves it loads cleanly.
- If a plugin breaks project launch, disable the plugin first and keep the addon installed for sandbox review. Main Red Night playtests should not be blocked by nonproduction plugin experiments.

## Integration Rules

- Debug tools must stay development-only.
- Projectile plugins must route through our weapon/combat rules: temporary weapons, no reload, ammo depletion, fake-3D lane checks, shadow-footprint hit logic, and existing hit FX/SFX.
- Dialogue plugins must not replace story truth directly. Dialogue results should set our existing story flags or call a local dialogue adapter.
- Camera plugins must not bypass `Projection` unless a dedicated camera sandbox proves the result fits fake-3D movement.
- AI plugins must not replace `Enemy` behavior wholesale. Start with one sandbox enemy profile before touching Red Night production enemies.
- Art import plugins may help create runtime sprite resources, but accepted sprites still follow the project asset pipeline: approved source, hash/manifest, cleanup, anchor validation, and visual-library rebuild.

## Source Audit

Downloaded plugin archives are kept under `source_assets/plugins/downloaded/`.
The import manifest is `source_assets/plugins/plugin_import_manifest.md`.
