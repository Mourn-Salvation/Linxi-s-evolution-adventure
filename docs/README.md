# Documentation Map

This folder keeps design decisions for Linxi's Evolution Adventure. When documents disagree, use the canonical order below.

## Canonical Documents

1. `current-state.md` - short, verified runtime truth and current production boundary.
2. `game-adaptation-bible.md` - story canon, Linxi's forms, safe-house purpose, and game adaptation rules.
3. `campaign-stage-plan.md` - 20+ hour stage/level adaptation plan, campaign pacing, unlock rhythm, and safe-house cadence.
4. `art-direction.md` - art direction, pixel-filter presentation rules, asset pipeline, Sprite Forge contract, cleanup rules, and acceptance gates.
5. `technical-design.md` - runtime architecture, map-driven encounters, save rules, and development-mode tools.
6. `production-sop.md` - operational workflow for adding new levels, enemies, and accepted runtime assets.
7. `combat-design.md` - player controls, combat feel, weight/biomass, Vore, digestion, and capacity.
8. `linxi-progression.md` - progression values and form rules.
9. `vore-asset-pipeline.md` - belly-first Vore expansion asset production rules.
10. `asset-index.md` - generated inventory; consult when locating assets, not as routine design context.

## Supporting Documents

- `enemy-design.md` - enemy family behavior, cast/readability rules, and appearance/behavior split.
- `weapon-system.md` - temporary human-made weapon rules and body-weapon direction.
- `coordinate-model.md` - fake-3D belt and jump projection model.
- `milestones.md` - current implementation roadmap.
- `decisions/` - dated architectural decisions that should not be rewritten casually.

## Source Material

Large fiction/source files are preserved outside `docs` so developer-document scans stay lightweight. Heavy raw/source assets are archived outside the Godot project at `E:\Linxi_Production_Archive\source_assets\` and indexed by `source_assets/archive_index/external_source_assets_index.csv`.

## Consolidation Candidates

These files overlap with canonical docs and can be merged or replaced when you approve cleanup:

- None currently. The early gray-box design notes, duplicate visual rules, content pipeline checklist, and Red Night demo-slice notes have been merged into the canonical docs.

## Cleanup Rule

Never delete docs, old scenes, backup folders, source assets, generated candidates, or other project files without explicit user approval.

Before redoing an asset, animation, or mechanic, check `source_assets/`, `assets/`, `work_backup/`, and the relevant manifest first. If an older solution exists, document whether it is accepted, obsolete, or pending instead of silently replacing it.

New levels and enemies must follow `production-sop.md` before implementation. The SOP is the checklist; the domain documents explain the design rules.

After accepting or wiring new runtime art, regenerate `asset-index.md` with `tools/build_asset_index.py`.
