#!/usr/bin/env python3
"""Align animation frames by the lowest visible character pixel.

This keeps full frame canvases intact and fixes foot/bottom-anchor drift without
tight-cropping the sprite. It is meant for generated magenta-background sheets
where every cell already contains a full character.
"""

from __future__ import annotations

import argparse
import json
from collections import deque
from pathlib import Path

from PIL import Image


def is_background(px: tuple[int, int, int, int], mode: str) -> bool:
    r, g, b, a = px
    if a == 0:
        return True
    if mode == "strict":
        return r >= 245 and g <= 20 and b >= 245
    # Generated sheets sometimes have a magenta gradient. Keep this broad, but
    # still require red/blue dominance so skin, shirt, and shoes survive.
    return r >= 165 and b >= 145 and g <= 120 and r > g + 60 and b > g + 45


def remove_background(cell: Image.Image, mode: str) -> Image.Image:
    out = cell.convert("RGBA")
    pix = out.load()
    for y in range(out.height):
        for x in range(out.width):
            if is_background(pix[x, y], mode):
                pix[x, y] = (0, 0, 0, 0)
    return out


def alpha_bbox(img: Image.Image) -> tuple[int, int, int, int] | None:
    pix = img.load()
    xs: list[int] = []
    ys: list[int] = []
    for y in range(img.height):
        for x in range(img.width):
            if pix[x, y][3] > 0:
                xs.append(x)
                ys.append(y)
    if not xs:
        return None
    return min(xs), min(ys), max(xs) + 1, max(ys) + 1


def keep_largest_component(img: Image.Image) -> int:
    pix = img.load()
    seen: set[tuple[int, int]] = set()
    components: list[list[tuple[int, int]]] = []
    for y0 in range(img.height):
        for x0 in range(img.width):
            if (x0, y0) in seen or pix[x0, y0][3] == 0:
                continue
            q = deque([(x0, y0)])
            comp: list[tuple[int, int]] = []
            while q:
                x, y = q.popleft()
                if (x, y) in seen or not (0 <= x < img.width and 0 <= y < img.height):
                    continue
                seen.add((x, y))
                if pix[x, y][3] == 0:
                    continue
                comp.append((x, y))
                q.extend(((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)))
            components.append(comp)

    if not components:
        return 0
    largest = max(components, key=len)
    removed = 0
    for comp in components:
        if comp is largest:
            continue
        for x, y in comp:
            pix[x, y] = (0, 0, 0, 0)
            removed += 1
    return removed


def paste_shifted(img: Image.Image, dy: int) -> Image.Image:
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    src_y0 = max(0, -dy)
    src_y1 = min(img.height, img.height - dy)
    dst_y = max(0, dy)
    if src_y1 > src_y0:
        cropped = img.crop((0, src_y0, img.width, src_y1))
        out.alpha_composite(cropped, (0, dst_y))
    return out


def save_strip(frames: list[Image.Image], path: Path) -> None:
    strip = Image.new("RGBA", (frames[0].width * len(frames), frames[0].height), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        strip.alpha_composite(frame, (i * frame.width, 0))
    strip.save(path)


def main() -> int:
    parser = argparse.ArgumentParser(description="Align sprite sheet frames by bottom-most character pixel.")
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--rows", required=True, type=int)
    parser.add_argument("--cols", required=True, type=int)
    parser.add_argument("--background-mode", choices=("gradient-magenta", "strict"), default="gradient-magenta")
    parser.add_argument("--target-bottom", type=int, default=None, help="0-based target Y for the lowest visible pixel. Defaults to max detected bottom.")
    parser.add_argument("--bottom-padding", type=int, default=12, help="Clamp target bottom to height - padding.")
    parser.add_argument("--prefix", default="frame")
    parser.add_argument("--gif-duration", type=int, default=90)
    parser.add_argument("--keep-main-component", action="store_true", help="Remove detached non-body fragments after background isolation.")
    args = parser.parse_args()

    raw = Image.open(args.input).convert("RGBA")
    cell_w = raw.width // args.cols
    cell_h = raw.height // args.rows
    cleaned: list[Image.Image] = []
    bboxes: list[tuple[int, int, int, int]] = []
    removed_detached_counts: list[int] = []

    for i in range(args.rows * args.cols):
        row, col = divmod(i, args.cols)
        cell = raw.crop((col * cell_w, row * cell_h, (col + 1) * cell_w, (row + 1) * cell_h))
        frame = remove_background(cell, args.background_mode)
        removed_detached = keep_largest_component(frame) if args.keep_main_component else 0
        bbox = alpha_bbox(frame)
        if bbox is None:
            raise ValueError(f"Frame {i:02d} has no visible character pixels after background removal.")
        cleaned.append(frame)
        bboxes.append(bbox)
        removed_detached_counts.append(removed_detached)

    detected_bottoms = [bbox[3] - 1 for bbox in bboxes]
    default_target = max(detected_bottoms)
    clamped_target = min(default_target, cell_h - 1 - args.bottom_padding)
    target_bottom = args.target_bottom if args.target_bottom is not None else clamped_target
    target_bottom = min(target_bottom, cell_h - 1 - args.bottom_padding)

    args.output.mkdir(parents=True, exist_ok=True)
    aligned: list[Image.Image] = []
    qc: list[dict] = []
    for i, (frame, bbox, bottom, removed_detached) in enumerate(zip(cleaned, bboxes, detected_bottoms, removed_detached_counts)):
        dy = target_bottom - bottom
        shifted = paste_shifted(frame, dy)
        shifted_bbox = alpha_bbox(shifted)
        shifted.save(args.output / f"{args.prefix}_{i:02d}.png")
        aligned.append(shifted)
        qc.append({
            "frame": i,
            "source_bbox": bbox,
            "source_bottom_y": bottom,
            "dy": dy,
            "detached_pixels_removed": removed_detached,
            "aligned_bbox": shifted_bbox,
            "aligned_bottom_y": shifted_bbox[3] - 1 if shifted_bbox else None,
        })

    save_strip(aligned, args.output / "right-strip-bottom-aligned.png")
    aligned[0].save(
        args.output / "animation-bottom-aligned.gif",
        save_all=True,
        append_images=aligned[1:],
        duration=args.gif_duration,
        loop=0,
        disposal=2,
    )
    meta = {
        "input": str(args.input),
        "rows": args.rows,
        "cols": args.cols,
        "cell_size": [cell_w, cell_h],
        "background_mode": args.background_mode,
        "detected_bottoms": detected_bottoms,
        "target_bottom_y": target_bottom,
        "frames": qc,
    }
    (args.output / "bottom-anchor-meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    print(json.dumps({
        "frames": len(aligned),
        "target_bottom_y": target_bottom,
        "source_bottom_min": min(detected_bottoms),
        "source_bottom_max": max(detected_bottoms),
        "output": str(args.output),
    }, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
