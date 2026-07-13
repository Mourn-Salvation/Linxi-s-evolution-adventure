from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import time
from pathlib import Path

from PIL import Image, ImageOps


PROJECT_ROOT = Path(__file__).resolve().parents[1]


CELL_ASSIGNMENTS = {
    "guard": (0, 0),
    "human_male": (1, 0),
    "female_student_0": (0, 1),
    "female_student_1": (1, 1),
}


RUNTIME_TARGETS = [
    ("guard", "assets/sprites/enemies/human_guard/knocked_down"),
    ("human_male", "assets/sprites/enemies/human_student/knocked_down"),
    ("female_student_0", "assets/sprites/enemies/human_student/knocked_down_female"),
]


ZOMBIE_VARIANTS = [
    "female_student_0",
    "female_student_1",
    "female_student_0",
    "female_student_1",
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def chroma_to_alpha(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, _a = pixels[x, y]
            if r > 210 and b > 210 and g < 95:
                pixels[x, y] = (0, 0, 0, 0)
    return image


def crop_subject(image: Image.Image) -> Image.Image:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("No visible subject found after magenta cleanup.")
    return image.crop(bbox)


def fit_to_canvas(
    subject: Image.Image,
    canvas_size: tuple[int, int] = (256, 256),
    target_w: int = 226,
    target_h: int = 130,
    bottom_y: int = 232,
) -> Image.Image:
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    scale = min(target_w / max(subject.width, 1), target_h / max(subject.height, 1))
    size = (max(1, int(subject.width * scale)), max(1, int(subject.height * scale)))
    subject = subject.resize(size, Image.Resampling.LANCZOS)
    x = (canvas_size[0] - subject.width) // 2
    y = bottom_y - subject.height
    y = max(8, min(y, canvas_size[1] - subject.height - 8))
    canvas.alpha_composite(subject, (x, y))
    return canvas


def backup_existing_runtime(label: str) -> Path:
    backup_root = PROJECT_ROOT / "work_backup" / f"enemy_knocked_down_before_{label}_{time.strftime('%Y%m%d-%H%M%S')}"
    for _name, rel in RUNTIME_TARGETS:
        src = PROJECT_ROOT / rel
        if src.exists():
            dst = backup_root / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copytree(src, dst)
    zombie_src = PROJECT_ROOT / "assets/sprites/enemies/zombie_student/knocked_down"
    if zombie_src.exists():
        zombie_dst = backup_root / "assets/sprites/enemies/zombie_student/knocked_down"
        zombie_dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(zombie_src, zombie_dst)
    return backup_root


def write_runtime(processed: dict[str, Image.Image]) -> None:
    for key, rel in RUNTIME_TARGETS:
        folder = PROJECT_ROOT / rel
        folder.mkdir(parents=True, exist_ok=True)
        processed[key].save(folder / "right_00.png")
        ImageOps.mirror(processed[key]).save(folder / "left_00.png")

    zombie_folder = PROJECT_ROOT / "assets/sprites/enemies/zombie_student/knocked_down"
    zombie_folder.mkdir(parents=True, exist_ok=True)
    for index, key in enumerate(ZOMBIE_VARIANTS):
        processed[key].save(zombie_folder / f"right_{index:02d}.png")
        ImageOps.mirror(processed[key]).save(zombie_folder / f"left_{index:02d}.png")


def write_contact_sheet() -> None:
    contact = Image.new("RGBA", (1024, 512), (12, 10, 14, 255))
    slots = [
        PROJECT_ROOT / "assets/sprites/enemies/human_guard/knocked_down/right_00.png",
        PROJECT_ROOT / "assets/sprites/enemies/human_student/knocked_down/right_00.png",
        PROJECT_ROOT / "assets/sprites/enemies/human_student/knocked_down_female/right_00.png",
        PROJECT_ROOT / "assets/sprites/enemies/zombie_student/knocked_down/right_01.png",
    ]
    for index, path in enumerate(slots):
        frame = Image.open(path).convert("RGBA")
        x = (index % 2) * 512 + 128
        y = (index // 2) * 256
        contact.alpha_composite(frame, (x, y))
    contact.save(PROJECT_ROOT / "assets/sprites/enemies/spritesheet_knocked_down_contact.png")


def process_sheet(source: Path, output_slug: str) -> dict[str, str]:
    if not source.exists():
        raise FileNotFoundError(source)

    source_hash = sha256(source)
    output_dir = PROJECT_ROOT / "source_assets/enemies" / output_slug
    output_dir.mkdir(parents=True, exist_ok=True)
    project_copy = output_dir / "raw_knocked_down_pose_sheet.png"
    if not project_copy.exists() or source.resolve() != project_copy.resolve():
        shutil.copy2(source, project_copy)

    backup_root = backup_existing_runtime(output_slug)

    raw = Image.open(project_copy).convert("RGBA")
    cell_w = raw.width // 2
    cell_h = raw.height // 2
    processed: dict[str, Image.Image] = {}
    for name, (cell_x, cell_y) in CELL_ASSIGNMENTS.items():
        cell = raw.crop((cell_x * cell_w, cell_y * cell_h, (cell_x + 1) * cell_w, (cell_y + 1) * cell_h))
        subject = crop_subject(chroma_to_alpha(cell))
        frame = fit_to_canvas(subject)
        processed[name] = frame
        frame.save(output_dir / f"{name}_right_00.png")
        ImageOps.mirror(frame).save(output_dir / f"{name}_left_00.png")

    write_runtime(processed)
    write_contact_sheet()

    meta = {
        "version": output_slug,
        "approved_source": str(source),
        "approved_source_sha256": source_hash,
        "project_copy": str(project_copy),
        "runtime_backup": str(backup_root),
        "runtime_canvas": "256x256",
        "rule": "Process only an explicit approved source path/hash. Never use newest generated image cache selection.",
        "assignments": {
            "top_left": "human_guard knocked_down",
            "top_right": "human_student male knocked_down",
            "bottom_left": "human_student female and zombie variants 0/2 knocked_down",
            "bottom_right": "zombie variants 1/3 knocked_down",
        },
    }
    (output_dir / "pipeline-meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    return meta


def main() -> None:
    parser = argparse.ArgumentParser(description="Process an approved 2x2 enemy knocked-down pose sheet.")
    parser.add_argument("--source", required=True, type=Path, help="Exact approved 2x2 source sheet path.")
    parser.add_argument("--output-slug", default="knocked_down_user_approved_v3", help="source_assets/enemies output folder.")
    args = parser.parse_args()

    meta = process_sheet(args.source, args.output_slug)
    print(json.dumps(meta, indent=2))


if __name__ == "__main__":
    main()
