class_name GameSession
extends RefCounted

const LEGACY_SAVE_NAME := "linxi_progress.json"
const PROFILE_NAME := "linxi_profile.json"
const SAVE_SLOT_COUNT := 3
const DEFAULT_STAGE_SCENE := "res://scenes/red_night.tscn"

static var active_slot := 0
static var force_opening_once := false
static var storage_root_override := ""


static func initialize() -> void:
	_ensure_save_directory()
	var profile := read_profile()
	active_slot = clampi(int(profile.get("active_slot", 0)), 0, SAVE_SLOT_COUNT)
	_migrate_legacy_save()
	apply_saved_settings()


static func storage_root() -> String:
	return storage_root_override.trim_suffix("/") if not storage_root_override.is_empty() else "user:/"


static func profile_path() -> String:
	return "%s/%s" % [storage_root(), PROFILE_NAME]


static func legacy_save_path() -> String:
	return "%s/%s" % [storage_root(), LEGACY_SAVE_NAME]


static func slot_path(slot: int) -> String:
	return "%s/saves/slot_%d.json" % [storage_root(), clampi(slot, 1, SAVE_SLOT_COUNT)]


static func active_save_path() -> String:
	return slot_path(active_slot) if active_slot in range(1, SAVE_SLOT_COUNT + 1) else legacy_save_path()


static func select_slot(slot: int) -> void:
	active_slot = clampi(slot, 1, SAVE_SLOT_COUNT)
	var profile := read_profile()
	profile["active_slot"] = active_slot
	write_profile(profile)


static func has_returning_profile() -> bool:
	var profile := read_profile()
	if bool(profile.get("opening_completed", false)):
		return true
	if FileAccess.file_exists(legacy_save_path()):
		return true
	for slot in range(1, SAVE_SLOT_COUNT + 1):
		if slot_exists(slot):
			return true
	return false


static func mark_opening_completed() -> void:
	var profile := read_profile()
	profile["opening_completed"] = true
	if active_slot <= 0:
		active_slot = 1
	profile["active_slot"] = active_slot
	write_profile(profile)


static func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))


static func read_slot(slot: int) -> Dictionary:
	return _read_json(slot_path(slot))


static func slot_summary(slot: int) -> Dictionary:
	var data := read_slot(slot)
	if data.is_empty():
		return {"slot": slot, "occupied": false, "location": "EMPTY", "saved_at": 0}
	var checkpoint = data.get("route_checkpoint", {})
	var location := "RED NIGHT"
	var saved_at := 0
	if checkpoint is Dictionary:
		location = String(checkpoint.get("destination_name", checkpoint.get("level_name", location)))
		saved_at = int(checkpoint.get("saved_at_unix", 0))
	return {
		"slot": slot,
		"occupied": true,
		"location": location,
		"saved_at": saved_at,
		"hp": int(data.get("player_health", data.get("player_max_health", 10))),
		"max_hp": int(data.get("player_max_health", 10)),
		"biomass": float(data.get("biomass", 0.0)),
	}


static func scene_for_slot(slot: int) -> String:
	var data := read_slot(slot)
	var checkpoint = data.get("route_checkpoint", {})
	if checkpoint is Dictionary:
		var target_scene := String(checkpoint.get("target_scene", ""))
		if target_scene.begins_with("res://") and ResourceLoader.exists(target_scene):
			return target_scene
	return DEFAULT_STAGE_SCENE


static func begin_new_game(slot: int) -> void:
	select_slot(slot)
	clear_slot(slot)
	force_opening_once = true


static func clear_slot(slot: int) -> bool:
	var path := slot_path(slot)
	if not FileAccess.file_exists(path):
		return true
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK


static func read_profile() -> Dictionary:
	return _read_json(profile_path())


static func write_profile(profile: Dictionary) -> void:
	_ensure_save_directory()
	_write_json(profile_path(), profile)


static func save_settings(window_size: Vector2i, master_volume: float) -> void:
	var profile := read_profile()
	profile["window_width"] = window_size.x
	profile["window_height"] = window_size.y
	profile["master_volume"] = clampf(master_volume, 0.0, 100.0)
	write_profile(profile)


static func apply_saved_settings() -> void:
	var profile := read_profile()
	var width := int(profile.get("window_width", 0))
	var height := int(profile.get("window_height", 0))
	if width >= 1280 and height >= 720:
		DisplayServer.window_set_size(Vector2i(width, height))
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0 and profile.has("master_volume"):
		var volume := clampf(float(profile["master_volume"]), 0.0, 100.0)
		AudioServer.set_bus_volume_db(bus, -80.0 if volume <= 0.0 else linear_to_db(volume / 100.0))


static func _migrate_legacy_save() -> void:
	if not FileAccess.file_exists(legacy_save_path()):
		return
	for slot in range(1, SAVE_SLOT_COUNT + 1):
		if slot_exists(slot):
			return
	var legacy_data := _read_json(legacy_save_path())
	if legacy_data.is_empty():
		return
	_write_json(slot_path(1), legacy_data)
	active_slot = 1
	var profile := read_profile()
	profile["active_slot"] = 1
	profile["opening_completed"] = true
	profile["legacy_save_migrated"] = true
	write_profile(profile)


static func _ensure_save_directory() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("%s/saves" % storage_root()))


static func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var data = JSON.parse_string(file.get_as_text())
	return Dictionary(data).duplicate(true) if data is Dictionary else {}


static func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))
