# Linxi's Evolution Adventure

A Godot 4 prototype for a sprite-driven 2.5D belt-scrolling action game. The world uses 2D rendering with horizontal movement, lane depth, Y-sorting, layered backgrounds, and arcade combat.

## Open

Import `project.godot` from the Godot Project Manager and run the main scene.

Run the complete deterministic verification suite with `tools/run_test_suite.ps1` before changing mechanics or adding levels.

## Project Layout

- `docs/`: design, technical direction, art direction, and decisions. Start with `docs/README.md`.
- `scenes/`: Godot scenes grouped by gameplay responsibility
- `scripts/`: GDScript systems and behavior
- `resources/`: data-driven combat, character, enemy, and balance resources
- `assets/`: engine-ready visual and audio assets
- `source_assets/`: lightweight manifests, prompts, and archive index kept outside the import pipeline
- `E:\Linxi_Production_Archive\source_assets\`: heavy raw/source artwork archive, indexed from `source_assets/archive_index/`
- `tests/`: automated and manual test material
- `tools/`: project-specific import and validation utilities
