from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

from PIL import Image


def is_hot_magenta(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    return r >= 225 and g <= 95 and b >= 185 and r - g >= 125 and b - g >= 95


def is_pink_fringe(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    return r >= 160 and b >= 125 and g <= 120 and r - g >= 70 and b - g >= 45


def is_dark_purple_fringe(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    return r >= 80 and b >= 95 and g <= 75 and r - g >= 35 and b - g >= 45


def is_ui_magenta_highlight(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    return r >= 185 and b >= 170 and g <= 100 and abs(r - b) <= 60 and r - g >= 100 and b - g >= 90


def recolor_ui_magenta_to_red(r: int, g: int, b: int, a: int) -> tuple[int, int, int, int]:
    brightness = max(r, b)
    new_r = min(255, max(176, brightness))
    new_g = min(64, max(0, g // 2))
    new_b = min(82, max(24, b // 5))
    return (new_r, new_g, new_b, a)


def has_transparent_neighbor(pixels, width: int, height: int, x: int, y: int, radius: int) -> bool:
    for yy in range(max(0, y - radius), min(height, y + radius + 1)):
        for xx in range(max(0, x - radius), min(width, x + radius + 1)):
            if pixels[xx, yy][3] == 0:
                return True
    return False


def nearest_clean_color(pixels, width: int, height: int, x: int, y: int, radius: int = 3):
    samples: list[tuple[int, int, int]] = []
    for yy in range(max(0, y - radius), min(height, y + radius + 1)):
        for xx in range(max(0, x - radius), min(width, x + radius + 1)):
            r, g, b, a = pixels[xx, yy]
            if a == 0:
                continue
            if is_pink_fringe(r, g, b, a):
                continue
            samples.append((r, g, b))
    if not samples:
        return None
    return tuple(sum(channel) // len(samples) for channel in zip(*samples))


def clean_image(path: Path, backup_root: Path | None, dry_run: bool, erase_purple_edge: bool, recolor_opaque_ui_magenta: bool) -> dict:
    image = Image.open(path).convert("RGBA")
    pixels = image.load()
    width, height = image.size
    transparent_removed = 0
    defringed = 0
    recolored = 0

    edits: list[tuple[int, int, tuple[int, int, int, int]]] = []
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if is_hot_magenta(r, g, b, a):
                if recolor_opaque_ui_magenta and a >= 32:
                    edits.append((x, y, recolor_ui_magenta_to_red(r, g, b, a)))
                    recolored += 1
                else:
                    edits.append((x, y, (r, g, b, 0)))
                    transparent_removed += 1
            elif is_pink_fringe(r, g, b, a) and has_transparent_neighbor(pixels, width, height, x, y, 2):
                clean = nearest_clean_color(pixels, width, height, x, y)
                if clean is None:
                    edits.append((x, y, (r, g, b, 0)))
                    transparent_removed += 1
                else:
                    # Keep the anti-aliased edge shape, but remove the magenta color contamination.
                    edits.append((x, y, (clean[0], clean[1], clean[2], max(0, min(a, 210)))))
                    defringed += 1
            elif is_dark_purple_fringe(r, g, b, a) and has_transparent_neighbor(pixels, width, height, x, y, 2):
                clean = nearest_clean_color(pixels, width, height, x, y)
                if erase_purple_edge or clean is None or a < 96:
                    edits.append((x, y, (r, g, b, 0)))
                    transparent_removed += 1
                else:
                    edits.append((x, y, (clean[0], clean[1], clean[2], max(0, min(a, 180)))))
                    defringed += 1
            elif recolor_opaque_ui_magenta and is_ui_magenta_highlight(r, g, b, a):
                edits.append((x, y, recolor_ui_magenta_to_red(r, g, b, a)))
                recolored += 1

    if edits and not dry_run:
        if backup_root is not None:
            backup_path = backup_root / path.drive.replace(":", "") / Path(*path.parts[1:])
            backup_path.parent.mkdir(parents=True, exist_ok=True)
            if not backup_path.exists():
                shutil.copy2(path, backup_path)
        for x, y, value in edits:
            pixels[x, y] = value
        image.save(path)

    return {
        "path": str(path),
        "changed": bool(edits),
        "transparent_removed": transparent_removed,
        "defringed": defringed,
        "recolored": recolored,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Remove solid-magenta and pink anti-alias fringes from generated PNG assets.")
    parser.add_argument("paths", nargs="+", type=Path)
    parser.add_argument("--backup-root", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--erase-purple-edge", action="store_true", help="Also remove dark purple edge glow pixels instead of recoloring them.")
    parser.add_argument("--recolor-opaque-ui-magenta", action="store_true", help="Convert fully opaque UI magenta highlights into the project red/metal palette.")
    parser.add_argument("--json-out", type=Path)
    args = parser.parse_args()

    files: list[Path] = []
    for path in args.paths:
        if path.is_dir():
            files.extend(sorted(path.rglob("*.png")))
        elif path.suffix.lower() == ".png":
            files.append(path)

    results = [clean_image(path, args.backup_root, args.dry_run, args.erase_purple_edge, args.recolor_opaque_ui_magenta) for path in files]
    changed = [result for result in results if result["changed"]]

    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(results, indent=2), encoding="utf-8")

    print(f"scanned={len(results)} changed={len(changed)}")
    print(f"transparent_removed={sum(r['transparent_removed'] for r in changed)} defringed={sum(r['defringed'] for r in changed)} recolored={sum(r['recolored'] for r in changed)}")
    for result in changed[:80]:
        print(f"{result['transparent_removed']:5d} removed {result['defringed']:5d} defringed {result['recolored']:5d} recolored  {result['path']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
