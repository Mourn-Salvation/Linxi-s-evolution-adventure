# Godot Plugin Import Manifest

Imported by Codex for review/sandbox use. Do not wire core gameplay directly to a plugin without a local adapter.

## Installed Addons

- `debug_console` from `source_assets/plugins/downloaded/debug_console.zip` -> `addons/debug_console`
- `dialogue_manager` from `source_assets/plugins/downloaded/dialogue_manager.zip` -> `addons/dialogue_manager`
- `phantom_camera` from `source_assets/plugins/downloaded/phantom_camera.zip` -> `addons/phantom_camera`
- `beehave` from `source_assets/plugins/downloaded/beehave.zip` -> `addons/beehave`
- `godot_projectile_engine` from `source_assets/plugins/downloaded/projectile_engine.zip` -> `addons/godot_projectile_engine`
- `AsepriteWizard` from `source_assets/plugins/downloaded/aseprite_wizard.zip` -> `addons/AsepriteWizard`

## Policy

- Debug console may become a development-only tool after parse verification.
- Projectile, camera, dialogue, behavior tree, and sprite import plugins must be tested in sandbox/adapters before production wiring.
- Never make permanent save/combat/story rules depend directly on third-party APIs.

## Local Compatibility Notes

- `addons/godot_projectile_engine/core/pattern_composer/component/PCCGroup.gd` was patched for Godot 4.6.2 compatibility. The upstream file used a `process_pattern(pattern_composer_pack, context)` signature that did not match `PatternComposerComponent.process_pattern(pattern_composer_pack)`, causing a parse/load failure. The local version now matches the parent signature and calls child pattern components with one argument.
- Dialogue Manager `views/main_view.gd` direct script load and headless editor import pass under Godot 4.6.2 after the projectile patch. If the editor still shows an old failure, close Godot and reopen the project so the addon script cache refreshes.
