from __future__ import annotations

import argparse
from pathlib import Path
from statistics import mean

from PIL import Image


def visible_pixels(image: Image.Image, alpha_min: int) -> list[tuple[int, int, int, int]]:
    return [pixel for pixel in image.getdata() if pixel[3] >= alpha_min]


def channel_means(pixels: list[tuple[int, int, int, int]]) -> tuple[float, float, float]:
    if not pixels:
        return 0.0, 0.0, 0.0
    return (
        mean(pixel[0] for pixel in pixels),
        mean(pixel[1] for pixel in pixels),
        mean(pixel[2] for pixel in pixels),
    )


def clamp_channel(value: float) -> int:
    return max(0, min(255, round(value)))


def nearest_opaque_rgb(pixels, width: int, height: int, x: int, y: int, radius: int) -> tuple[int, int, int] | None:
    best_alpha = -1
    best_rgb = None
    for distance in range(1, radius + 1):
        for yy in range(max(0, y - distance), min(height, y + distance + 1)):
            for xx in range(max(0, x - distance), min(width, x + distance + 1)):
                if abs(xx - x) != distance and abs(yy - y) != distance:
                    continue
                r, g, b, a = pixels[xx, yy]
                if a > best_alpha:
                    best_alpha = a
                    best_rgb = (r, g, b)
        if best_alpha >= 245 and best_rgb is not None:
            return best_rgb
    return best_rgb


def style_match_image(source: Image.Image, reference: Image.Image, strength: float, edge_radius: int) -> Image.Image:
    source = source.convert("RGBA")
    reference = reference.convert("RGBA")
    src_mean = channel_means(visible_pixels(source, 80))
    ref_mean = channel_means(visible_pixels(reference, 80))
    delta = tuple((ref_mean[index] - src_mean[index]) * strength for index in range(3))

    output = Image.new("RGBA", source.size, (0, 0, 0, 0))
    src = source.load()
    dst = output.load()
    width, height = source.size

    for y in range(height):
        for x in range(width):
            r, g, b, a = src[x, y]
            if a == 0:
                dst[x, y] = (0, 0, 0, 0)
                continue

            # Match the general rendered layer without flattening costume contrast.
            alpha_strength = min(1.0, max(0.0, a / 255.0))
            nr = r + delta[0] * alpha_strength
            ng = g + delta[1] * alpha_strength
            nb = b + delta[2] * alpha_strength

            # Semi-transparent pixels carry the old matte color most visibly. Pull their
            # RGB from nearby opaque body pixels so compositing cannot reveal a pink rim.
            if a < 235:
                replacement = nearest_opaque_rgb(src, width, height, x, y, edge_radius)
                if replacement is not None:
                    edge_strength = 0.82 if a < 180 else 0.58
                    nr = nr * (1.0 - edge_strength) + (replacement[0] + delta[0]) * edge_strength
                    ng = ng * (1.0 - edge_strength) + (replacement[1] + delta[1]) * edge_strength
                    nb = nb * (1.0 - edge_strength) + (replacement[2] + delta[2]) * edge_strength

            # Extra despill for purple/magenta halos that survive the neighbor pull.
            purple_excess = max(0.0, min(nr, nb) - ng * 1.08)
            if purple_excess > 0.0 and a < 245:
                nr -= purple_excess * 0.72
                nb -= purple_excess * 0.82
                ng += purple_excess * 0.10

            dst[x, y] = (clamp_channel(nr), clamp_channel(ng), clamp_channel(nb), a)

    return output


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Experimental whole-sheet style matching. Do not use as default cleanup for "
            "character body sprites; project rules require protected-mask extraction and "
            "5-6 px edge-band cleanup unless the user explicitly approves recoloring."
        )
    )
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--reference", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--strength", type=float, default=0.78)
    parser.add_argument("--edge-radius", type=int, default=4)
    args = parser.parse_args()

    source = Image.open(args.input)
    reference = Image.open(args.reference)
    output = style_match_image(source, reference, args.strength, args.edge_radius)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    output.save(args.output)


if __name__ == "__main__":
    main()
