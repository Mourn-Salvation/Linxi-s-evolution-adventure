from __future__ import annotations

import re
from collections import defaultdict
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DOC_PATH = PROJECT_ROOT / "docs" / "asset-index.md"

TEXT_EXTENSIONS = {".gd", ".tres", ".tscn", ".godot", ".md", ".json"}
ASSET_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".mp4", ".wav", ".ogg", ".mp3", ".ttf", ".otf"}
SCAN_ROOTS = ["scripts", "resources", "scenes", "project.godot"]


def rel(path: Path) -> str:
	return path.relative_to(PROJECT_ROOT).as_posix()


def read_text(path: Path) -> str:
	try:
		return path.read_text(encoding="utf-8")
	except UnicodeDecodeError:
		return path.read_text(encoding="utf-8", errors="ignore")


def collect_referenced_assets() -> dict[str, set[str]]:
	referenced: dict[str, set[str]] = defaultdict(set)
	pattern = re.compile(r"res://assets/[^\"'\]\)\s]+")
	for root_name in SCAN_ROOTS:
		root = PROJECT_ROOT / root_name
		if root.is_file():
			files = [root]
		elif root.exists():
			files = [p for p in root.rglob("*") if p.is_file() and p.suffix in TEXT_EXTENSIONS]
		else:
			files = []
		for path in files:
			text = read_text(path)
			for match in pattern.findall(text):
				cleaned = match.rstrip(",")
				referenced[cleaned].add(rel(path))
	return referenced


def collect_runtime_folders() -> list[dict[str, str]]:
	rows: list[dict[str, str]] = []
	assets_root = PROJECT_ROOT / "assets"
	for folder in sorted([p for p in assets_root.rglob("*") if p.is_dir()]):
		files = [p for p in folder.iterdir() if p.is_file() and p.suffix.lower() in ASSET_EXTENSIONS]
		if not files:
			continue
		category = folder.relative_to(assets_root).parts[0] if folder.relative_to(assets_root).parts else "assets"
		rows.append({
			"category": category,
			"folder": rel(folder),
			"count": str(len(files)),
			"examples": ", ".join(p.name for p in sorted(files)[:4]),
		})
	return rows


def collect_visual_resources() -> list[dict[str, str]]:
	rows: list[dict[str, str]] = []
	for path in sorted((PROJECT_ROOT / "resources").rglob("*.tres")):
		text = read_text(path)
		if "Visual" not in text and "Texture2D" not in text:
			continue
		script_class = "Resource"
		script_match = re.search(r'script_class="([^"]+)"', text)
		if script_match:
			script_class = script_match.group(1)
		asset_refs = sorted(set(re.findall(r'path="(res://assets/[^"]+)"', text)))
		if asset_refs:
			rows.append({
				"resource": rel(path),
				"type": script_class,
				"asset_refs": str(len(asset_refs)),
				"examples": ", ".join(asset_refs[:3]),
			})
	return rows


def parse_map_blocks(field_name: str, map_text: str) -> list[dict[str, str]]:
	match = re.search(rf"{field_name}\s*=\s*Array\[Dictionary\]\(\[(.*?)\]\)", map_text, re.S)
	if not match:
		return []
	blocks = re.split(r"\},\s*\{", match.group(1).strip())
	entries: list[dict[str, str]] = []
	for raw in blocks:
		block = raw.strip().removeprefix("{").removesuffix("}")
		entry: dict[str, str] = {}
		for key in ["id", "archetype", "family", "ai_profile", "appearance_id", "weapon_id", "type", "name", "target_scene", "destination_name", "position"]:
			value_match = re.search(rf'"{key}"\s*:\s*("[^"]*"|Vector2\([^)]+\)|[-\d.]+|true|false)', block)
			if value_match:
				entry[key] = value_match.group(1).strip('"')
		if entry:
			entries.append(entry)
	return entries


def collect_map_content() -> tuple[list[dict[str, str]], list[dict[str, str]]]:
	enemies: list[dict[str, str]] = []
	items: list[dict[str, str]] = []
	for path in sorted((PROJECT_ROOT / "resources" / "maps").glob("*.tres")):
		text = read_text(path)
		map_id_match = re.search(r'map_id\s*=\s*"([^"]+)"', text)
		map_id = map_id_match.group(1) if map_id_match else path.stem
		for entry in parse_map_blocks("enemy_spawns", text):
			entry["map"] = map_id
			enemies.append(entry)
		for entry in parse_map_blocks("items", text):
			entry["map"] = map_id
			items.append(entry)
	return enemies, items


def collect_achievements() -> list[dict[str, str]]:
	rows: list[dict[str, str]] = []
	for path in sorted((PROJECT_ROOT / "scripts").rglob("*.gd")):
		text = read_text(path)
		for title in re.findall(r'show_achievement\("([^"]+)"', text):
			rows.append({
				"title": title,
				"caller": rel(path),
				"icon": "assets/ui/achievements/whats_inside_the_vial.png" if "vial" in title else "",
				"panel": "assets/ui/hud/achievement_panel.png",
			})
	return rows


def collect_weapon_ids(enemies: list[dict[str, str]], items: list[dict[str, str]]) -> list[dict[str, str]]:
	weapon_sources: dict[str, set[str]] = defaultdict(set)
	weapon_sources["claws"].add("scripts/story/story_stage_component.gd")
	for entry in enemies:
		weapon_id = entry.get("weapon_id", "")
		if weapon_id:
			weapon_sources[weapon_id].add(f"map enemy: {entry.get('map', '')}/{entry.get('id', '')}")
	for entry in items:
		weapon_id = entry.get("weapon_id", "")
		if weapon_id:
			weapon_sources[weapon_id].add(f"map item: {entry.get('map', '')}/{entry.get('id', '')}")
	for path in sorted((PROJECT_ROOT / "scripts").rglob("*.gd")):
		text = read_text(path)
		for weapon_id in re.findall(r'"(handgun|knife|claws)"', text):
			weapon_sources[weapon_id].add(rel(path))
	return [{"weapon_id": key, "sources": "; ".join(sorted(value))} for key, value in sorted(weapon_sources.items())]


def markdown_table(headers: list[str], rows: list[dict[str, str]], limit: int | None = None) -> str:
	if limit is not None:
		rows = rows[:limit]
	lines = [
		"| " + " | ".join(headers) + " |",
		"| " + " | ".join("---" for _ in headers) + " |",
	]
	for row in rows:
		values = [str(row.get(header, "")).replace("\n", " ").replace("|", "\\|") for header in headers]
		lines.append("| " + " | ".join(values) + " |")
	return "\n".join(lines)


def main() -> None:
	referenced = collect_referenced_assets()
	runtime_folders = collect_runtime_folders()
	visual_resources = collect_visual_resources()
	enemies, items = collect_map_content()
	achievements = collect_achievements()
	weapons = collect_weapon_ids(enemies, items)
	referenced_rows = [
		{"asset": asset.removeprefix("res://"), "referenced_by": ", ".join(sorted(sources)[:4])}
		for asset, sources in sorted(referenced.items())
	]

	content = f"""# Asset Index

This is the human-readable sheet for assets currently wired into the game. It is generated by `tools/build_asset_index.py` so we can find runtime art, visual resources, enemy variants, weapons, achievements, and map content without searching every folder by hand.

Regenerate after accepting or wiring new assets:

```powershell
& "C:\\Users\\13948\\.cache\\codex-runtimes\\codex-primary-runtime\\dependencies\\python\\python.exe" "E:\\Linxi's evaluation adventure\\tools\\build_asset_index.py"
```

## Visual Data Resources

{markdown_table(["resource", "type", "asset_refs", "examples"], visual_resources)}

## Runtime Asset Folders

Folder-level view of production assets. This intentionally summarizes folders instead of listing every frame PNG.

{markdown_table(["category", "folder", "count", "examples"], runtime_folders)}

## Referenced Runtime Assets

Exact `res://assets/...` paths found in scripts, scenes, and resources.

{markdown_table(["asset", "referenced_by"], referenced_rows)}

## Map Enemy Sheet

Enemy instances authored in `MapData.enemy_spawns`.

{markdown_table(["map", "id", "archetype", "family", "ai_profile", "appearance_id", "weapon_id", "position"], enemies)}

## Map Item Sheet

Item, dialogue, weapon, and transition instances authored in `MapData.items`.

{markdown_table(["map", "id", "type", "name", "destination_name", "target_scene", "weapon_id", "position"], items)}

## Weapon Sheet

Weapon ids currently detected in maps or scripts.

{markdown_table(["weapon_id", "sources"], weapons)}

## Achievement Sheet

Achievements currently triggered by code.

{markdown_table(["title", "caller", "icon", "panel"], achievements)}

## Maintenance Rule

- Runtime art belongs under `assets/`.
- Accepted raw/generated sources and pipeline notes belong under `source_assets/`.
- Visual resources under `resources/*` are the canonical wiring layer.
- `main.gd` should not gain new preload tables.
- If an asset is wired dynamically by naming convention, keep the folder contract documented here and in the relevant domain doc.
"""
	DOC_PATH.write_text(content, encoding="utf-8")
	print(DOC_PATH)


if __name__ == "__main__":
	main()
