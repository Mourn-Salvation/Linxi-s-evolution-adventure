extends SceneTree

const SAVE_PATH := "user://stage_1_playthrough_test.json"

var failures := 0
var current_stage: Node


func _initialize() -> void:
	_remove_test_save()
	current_stage = await _load_stage("res://scenes/red_night.tscn", false)
	current_stage.biomass = 9.0
	current_stage.player_health = 6
	current_stage.contained_prey_weight = 1.0
	current_stage.occupied_vore_capacity = 1
	current_stage.enemy_contained = true
	current_stage.contained_route_loads["BELLY"] = 1
	current_stage.digest_progress = 0.75

	await _travel("roof_stairwell_transition", "res://scenes/dormitory_lobby.tscn", "dormitory_lobby")
	await _travel("lobby_staircase_to_second_floor", "res://scenes/dormitory_second_floor.tscn", "dormitory_second_floor")
	await _travel("su_ruo_room_door", "res://scenes/empty_bed.tscn", "empty_bed_dorm_room")

	current_stage.story_flags["red_night_su_ruo_clue"] = true
	await _travel("teaching_building_exit", "res://scenes/dormitory_second_floor.tscn", "dormitory_second_floor")
	var roof_route := _item(current_stage, "second_floor_roof_stairs")
	expect(current_stage.interaction_component.is_item_unlocked(roof_route), "Su Ruo clue unlocks the roof route after returning to the hallway")
	await _travel("second_floor_roof_stairs", "res://scenes/red_night_roof_route.tscn", "red_night_roof_route")

	current_stage.story_flags["red_night_roof_chose_save"] = true
	await _travel("route_to_playground_return", "res://scenes/red_night_playground_return.tscn", "red_night_playground_return")
	var elite: Dictionary = _enemy(current_stage, "elite_bone_blade_zombie")
	expect(not elite.is_empty(), "playground return contains the Bone-Blade Twin")
	elite["health"] = 0
	elite["state"] = "KNOCKED_DOWN"
	var teaching_route := _item(current_stage, "route_to_school_exit")
	expect(current_stage.interaction_component.is_item_unlocked(teaching_route), "defeating the Bone-Blade Twin unlocks the teaching route")
	await _travel("route_to_school_exit", "res://scenes/red_night_teaching_lobby.tscn", "red_night_teaching_lobby")

	await _travel("teaching_lobby_to_second_floor", "res://scenes/red_night_teaching_building.tscn", "red_night_teaching_second_floor")
	await _travel("teaching_second_floor_classroom_503", "res://scenes/red_night_classroom_503.tscn", "red_night_classroom_503")
	current_stage.story_flags["red_night_twins_met"] = true
	await _travel("classroom_503_exit", "res://scenes/red_night_teaching_building.tscn", "red_night_teaching_second_floor")
	await _travel("teaching_second_floor_stairs_down", "res://scenes/red_night_teaching_lobby.tscn", "red_night_teaching_lobby")
	var school_exit := _item(current_stage, "teaching_lobby_to_school_front_gate")
	expect(current_stage.interaction_component.is_item_unlocked(school_exit), "meeting the twins unlocks the school exit after returning downstairs")
	await _travel("teaching_lobby_to_school_front_gate", "res://scenes/red_night_school_exit.tscn", "red_night_school_exit")

	var shelter_route := _item(current_stage, "route_to_shelter_after_school_exit")
	expect(bool(shelter_route.get("stage_boundary", false)), "school exit marks the shelter route as a stage boundary")
	current_stage.save_map_switch_checkpoint(
		String(shelter_route.get("target_scene", "")),
		String(shelter_route.get("destination_name", "")),
		true,
		shelter_route.get("target_spawn", null)
	)
	var boundary_save: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	expect(boundary_save is Dictionary, "final Stage 1 checkpoint is valid JSON")
	if boundary_save is Dictionary:
		var checkpoint: Dictionary = boundary_save.get("route_checkpoint", {})
		expect(bool(checkpoint.get("stage_boundary", false)), "final checkpoint is a no-return stage boundary")
		expect(not bool(checkpoint.get("return_allowed", true)), "Stage 1 completion prevents returning to Red Night")

	current_stage.queue_free()
	await process_frame
	var shelter: Node = load("res://scenes/safe_house.tscn").instantiate()
	shelter.save_path_override = SAVE_PATH
	root.add_child(shelter)
	await process_frame
	expect(is_equal_approx(float(shelter.biomass), 9.0), "shelter receives Stage 1 biomass")
	expect(int(shelter.occupied_vore_capacity) == 1, "shelter receives carried prey")
	expect(is_equal_approx(float(shelter.digest_progress), 0.75), "shelter receives partial digestion progress")
	expect(int(shelter.current_health) == int(shelter.max_health), "shelter alone restores Linxi to full health")
	shelter.queue_free()
	await process_frame

	_remove_test_save()
	if failures == 0:
		print("PASS: uninterrupted Stage 1 route playthrough")
		quit(0)
	else:
		push_error("FAIL: %d Stage 1 playthrough check(s)" % failures)
		quit(1)


func _load_stage(scene_path: String, first_scene: bool) -> Node:
	var stage: Node = load(scene_path).instantiate()
	stage.save_path_override = SAVE_PATH
	stage.load_saved_progress_on_start = not first_scene
	root.add_child(stage)
	stage.process_mode = Node.PROCESS_MODE_DISABLED
	await process_frame
	expect(stage.map_data != null, "%s loads map data" % scene_path)
	return stage


func _travel(item_id: String, expected_scene: String, expected_map_id: String) -> void:
	var route_item := _item(current_stage, item_id)
	expect(not route_item.is_empty(), "%s exists on %s" % [item_id, current_stage.scene_file_path])
	if route_item.is_empty():
		return
	expect(String(route_item.get("target_scene", "")) == expected_scene, "%s targets the expected scene" % item_id)
	current_stage.save_map_switch_checkpoint(
		expected_scene,
		String(route_item.get("destination_name", "")),
		bool(route_item.get("stage_boundary", false)),
		route_item.get("target_spawn", null)
	)
	current_stage.queue_free()
	await process_frame
	current_stage = await _load_stage(expected_scene, false)
	expect(String(current_stage.map_data.map_id) == expected_map_id, "%s loads map %s" % [item_id, expected_map_id])
	expect(int(current_stage.player_health) == 6, "%s preserves current HP" % item_id)
	expect(is_equal_approx(float(current_stage.biomass), 9.0), "%s preserves biomass" % item_id)
	expect(int(current_stage.occupied_vore_capacity) == 1, "%s preserves occupied prey capacity" % item_id)
	expect(is_equal_approx(float(current_stage.digest_progress), 0.75), "%s preserves digestion progress" % item_id)


func _item(stage: Node, item_id: String) -> Dictionary:
	for candidate in stage.scene_items:
		if String(candidate.get("id", "")) == item_id:
			return candidate
	return {}


func _enemy(stage: Node, enemy_id: String) -> Dictionary:
	for candidate in stage.enemies:
		if String(candidate.get("id", "")) == enemy_id:
			return candidate
	return {}


func _remove_test_save() -> void:
	var absolute_path := ProjectSettings.globalize_path(SAVE_PATH)
	if FileAccess.file_exists(absolute_path):
		DirAccess.remove_absolute(absolute_path)


func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)
