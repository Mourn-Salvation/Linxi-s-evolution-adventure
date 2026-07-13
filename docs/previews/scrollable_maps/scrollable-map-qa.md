# Scrollable Map QA

Generated: 2026-07-06

## Summary

The renderer now stitches plates instead of fading them, but several existing art plates were originally generated as separate cinematic shots. They do not all join cleanly when placed side by side as a single traversable map.

## Verdicts

### Red Night Courtyard

- Status: usable for current demo after tuning its logical length to the two approved plates; connector polish still recommended.
- Preview strip: `red_night_courtyard_strip_preview.png`
- Runtime samples: `red_night_courtyard_runtime_samples.png`
- Issue: the courtyard now owns `red_night_courtyard_visual_data.tres` and uses only the first two outdoor plates. The map length is tuned to `3280`, with the dormitory gate route at `(2750, 8)`, so the rendered background scroll span and logical camera span stay near 1:1. The remaining seam between the two plates is still visible but acceptable for the current demo.
- Recommendation: keep for now if gameplay polish is the priority. For final polish, regenerate one continuous courtyard panorama or a connector plate that bridges the two accepted images without a perspective jump.

### Dormitory Second Floor

- Status: replaced with approved full-panorama slices; usable for current demo.
- Preview strip: `dormitory_second_floor_strip_preview.png`
- Runtime samples: `dormitory_second_floor_runtime_samples.png`
- Issue: the map now uses `dormitory_second_floor_full_panorama_left_v1.png` and `dormitory_second_floor_full_panorama_right_v1.png`, both sliced from one approved hallway panorama source. The old two-shot hallway/stair pair is superseded for runtime use.
- Scale note: the runtime length is tuned to `1714`, which keeps the hallway background physically locked to Linxi's camera movement after reducing depth to `345`.
- Floor-plan note: the playable Y-axis now starts at the wall/floor seam, not above it. This keeps actors on the floor plane and prevents the hallway from feeling like a flat backdrop.
- Recommendation: keep for current demo and tune encounter positions only after in-game scale review.

### Playground Return

- Status: wired to the approved 2x full-panorama production slices.
- Full panorama preview: `red_night_playground_return_v5_production_2x_preview.png`
- Sliced strip preview: `red_night_playground_return_v5_production_2x_sliced_strip_preview.png`
- Runtime samples: `red_night_playground_return_v5_production_2x_runtime_samples.png`
- Issue: the old three-plate runtime setup used `playground_return_morning_left_extension_v2.png` plus the previous middle/right slices, and that approach produced a visible middle gap and fence-height mismatch.
- Recommendation: keep the production 2x slices for runtime: `playground_return_morning_full_panorama_v5_production_2x_slice_1.png`, `playground_return_morning_full_panorama_v5_production_2x_slice_2.png`, and `playground_return_morning_full_panorama_v5_production_2x_slice_3.png`. Tune encounter positions only after in-game review.
- Scale note: the runtime length is tuned to `1694`, matching the rendered scroll span of the approved panorama. If this route needs to become a longer combat field, generate a wider panorama instead of stretching the current one.

### Roof Route

- Status: replaced with approved full-panorama slices; usable for current demo.
- Preview strip: `red_night_roof_route_strip_preview.png`
- Runtime samples: `red_night_roof_route_runtime_samples.png`
- Issue: the map now uses `red_night_roof_route_full_panorama_left_v1.png` and `red_night_roof_route_full_panorama_right_v1.png`, both sliced from one approved pre-dawn roof panorama source.
- Scale note: the runtime length is tuned to `1635`, matching the rendered scroll span of the approved panorama.
- Recommendation: keep for current demo and tune encounter readability after playtest.

### Outside The School

- Status: regenerate recommended.
- Preview strip: `red_night_school_exit_strip_preview.png`
- Runtime samples: `red_night_school_exit_runtime_samples.png`
- Issue: it reuses the courtyard/gate plates, so the final Red Night exit reads like the same school yard instead of leaving the school boundary.
- Recommendation: create a dedicated school-exit panorama: main gate, street outside school, police/emergency lights, city collapse hints, and a shelter-route transition point.

## Pipeline Rule

For scrollable traversal maps, each map should own visual data unless it is intentionally the same physical location. Shared visual resources are acceptable for temporary blockout only.

The rendered background scroll span should stay close to the logical camera span. Before placing encounters, compute the stitched background width at runtime scale and tune `MapData.length` so `Projection.camera_max_x()` is near `rendered_background_width - viewport_width`. If the ratio is far from `1.0`, regenerate or retune the map before adding gameplay.

Use `stitch_background_layers = true` for physical continuous maps. Do not use fade arrays for ordinary exploration movement.

Standalone continuation attempts are concept candidates only. Final multi-plate maps must come from a single approved panorama source, or from a true locked-canvas extension where the accepted neighbor is preserved unchanged and only the missing side is generated.

Future multi-plate maps should be generated as one continuous panorama first, then split into runtime plates. If generation must happen in multiple passes, use locked-canvas extension only: approve the good side, place it into a wider unfilled canvas as the locked left/right/center region, fill only the missing side, then slice the approved full panorama. If locked-canvas editing is not available, regenerate the full route instead. A plate set that looks like two images placed together should stay in QA and should not receive gameplay placement until corrected.

`Evolution Room` / `opening_scene` is technically a scrolling map through the default `MapData.camera_mode`, but it has no authored `MapVisualData` background resource. It was skipped from this visual-background QA pass.

## Regeneration Prompt Direction

All regenerated maps should follow the current Red Night art direction:

- high-resolution 1280x720-compatible, pixel-filter-friendly, not hand-drawn placeholder
- dark rainy school-horror atmosphere
- side-readable fake-3D brawler stage composition
- wide 21:9 traversal background plates
- stable horizon and floor plane across every plate
- single-scene continuity: no new-shot seams, no independent camera angles, no unrelated lighting rhythm
- approved-candidate extension pass: locked filled side plus generated missing side, followed by slicing into runtime plates
- no actors, UI, labels, arrows, circles, or player characters
- leave broad readable walkable floor space
- separate interactable doors, route markers, props, and foreground occluders into runtime assets when possible
