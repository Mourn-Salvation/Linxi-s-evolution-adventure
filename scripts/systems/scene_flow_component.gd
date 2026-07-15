extends Node

const GameSessionData = preload("res://scripts/data/game_session.gd")

const SAVE_PATH := "user://linxi_progress.json"
const TEACHING_CROWD_CUTSCENE := "teaching_first_floor_crowd"
const TEACHING_CROWD_OVERLAY := "TEACHING_FIRST_FLOOR_CROWD"
const TEACHING_CROWD_DURATION := 4.5

var host: Node


func setup(value: Node) -> void:
	host = value


func progress_save_path() -> String:
	return host.save_path_override if not host.save_path_override.is_empty() else GameSessionData.active_save_path()


func load_level_data() -> void:
	var level := host.level_data as LevelData
	if level == null:
		host.current_stage_id = ""
		host.current_level_id = ""
		host.current_level_name = ""
		return
	host.current_stage_id = level.stage_id
	host.current_level_id = level.level_id
	host.current_level_name = level.display_name
	if level.map_data != null:
		host.map_data = level.map_data


func load_map_data() -> void:
	if host.map_data == null:
		push_warning("No MapData assigned. Using default stage dimensions.")
		return
	host.ground_min_x = minf(host.map_data.ground_min_x, host.map_data.length)
	host.ground_width = maxf(host.map_data.length, 640.0)
	host.ground_depth = maxf(host.map_data.depth, 120.0)
	host.player_spawn = Vector2(clampf(host.map_data.player_spawn.x, host.ground_min_x, host.ground_width), clampf(host.map_data.player_spawn.y, 0.0, host.ground_depth))
	host.player_ground = host.player_spawn


func apply_route_spawn_override() -> void:
	if host.route_checkpoint.is_empty():
		return
	var target_scene := String(host.route_checkpoint.get("target_scene", ""))
	if not target_scene.is_empty() and target_scene != host.scene_file_path:
		return
	var target_spawn: Variant = host.route_checkpoint.get("target_spawn", null)
	if not (target_spawn is Array) or target_spawn.size() < 2:
		return
	var spawn := Vector2(float(target_spawn[0]), float(target_spawn[1]))
	spawn.x = clampf(spawn.x, host.ground_min_x, host.ground_width)
	spawn.y = clampf(spawn.y, 0.0, host.ground_depth)
	host.player_spawn = spawn
	host.player_ground = spawn


func apply_route_weapon_override() -> void:
	if host.route_checkpoint.is_empty():
		return
	var target_scene := String(host.route_checkpoint.get("target_scene", ""))
	if not target_scene.is_empty() and target_scene != host.scene_file_path:
		return
	var weapon_data: Variant = host.route_checkpoint.get("temporary_weapon", {})
	if weapon_data is Dictionary and not Dictionary(weapon_data).is_empty():
		host.weapon_component.restore_temporary_weapon(weapon_data)


func apply_map_entry_story_overlay() -> void:
	if host.map_data == null:
		return
	if not _consume_pending_entry_cutscene(TEACHING_CROWD_CUTSCENE):
		return
	host.story_overlay = TEACHING_CROWD_OVERLAY
	host.story_pose_time = 0.0
	host.story_control_locked = true
	host.update_hud("The first floor is packed with infected. Something living inside keeps them gathered.")
	if is_instance_valid(host.audio_component):
		host.audio_component.play_signal_interference()


func update_story_overlay() -> void:
	if host.story_overlay != TEACHING_CROWD_OVERLAY:
		return
	if host.story_pose_time < TEACHING_CROWD_DURATION:
		return
	host.story_overlay = ""
	host.story_control_locked = false
	host.story_pose_time = 0.0
	if host.map_data != null:
		host.update_hud(host.map_data.objective)


func save_map_switch_checkpoint(target_scene: String, destination_name: String, stage_boundary: bool = false, target_spawn = null) -> void:
	var from_scene := host.scene_file_path
	var entry_cutscene: String = _entry_cutscene_for_route(target_scene)
	host.route_checkpoint = {
		"from_scene": from_scene,
		"target_scene": target_scene,
		"destination_name": destination_name,
		"stage_id": host.current_stage_id,
		"level_id": host.current_level_id,
		"level_name": host.current_level_name,
		"map_id": host.map_data.map_id if host.map_data != null else "",
		"stage_boundary": stage_boundary,
		"return_allowed": not stage_boundary,
		"saved_at_unix": Time.get_unix_time_from_system(),
	}
	if target_spawn is Vector2:
		host.route_checkpoint["target_spawn"] = [target_spawn.x, target_spawn.y]
	elif target_spawn is Array and target_spawn.size() >= 2:
		host.route_checkpoint["target_spawn"] = [float(target_spawn[0]), float(target_spawn[1])]
	if not entry_cutscene.is_empty():
		host.route_checkpoint["entry_cutscene"] = entry_cutscene
	if not stage_boundary:
		var temporary_weapon: Dictionary = host.weapon_component.serialize_temporary_weapon()
		if not temporary_weapon.is_empty():
			host.route_checkpoint["temporary_weapon"] = temporary_weapon
	if is_instance_valid(host.encounter_component):
		host.encounter_component.commit_route_checkpoint(host.route_checkpoint)


func _entry_cutscene_for_route(target_scene: String) -> String:
	if host.map_data == null:
		return ""
	var source_map_id: String = String(host.map_data.map_id)
	if source_map_id != "red_night_playground_return":
		return ""
	if target_scene == "res://scenes/red_night_teaching_lobby.tscn":
		return TEACHING_CROWD_CUTSCENE
	return ""


func _consume_pending_entry_cutscene(expected_cutscene: String) -> bool:
	if host.route_checkpoint.is_empty():
		return false
	if String(host.route_checkpoint.get("entry_cutscene", "")) != expected_cutscene:
		return false
	if host.map_data == null:
		return false
	var map_id: String = String(host.map_data.map_id)
	if map_id != "red_night_teaching_lobby":
		return false
	var target_scene: String = String(host.route_checkpoint.get("target_scene", ""))
	if not target_scene.is_empty() and target_scene != host.scene_file_path:
		return false
	host.route_checkpoint.erase("entry_cutscene")
	if is_instance_valid(host.encounter_component):
		host.encounter_component.commit_route_checkpoint(host.route_checkpoint)
	return true
