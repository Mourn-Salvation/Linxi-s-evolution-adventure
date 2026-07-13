extends SceneTree

var failures := 0


func _initialize() -> void:
	var red_night = load("res://scenes/red_night.tscn").instantiate()
	red_night.save_path_override = "user://transition_route_test.json"
	root.add_child(red_night)
	await process_frame
	var route_marker := item(red_night, "roof_stairwell_transition")
	expect(not route_marker.is_empty(), "Red Night has a route transition marker")
	red_night.player_ground = Vector2(route_marker["position"])
	expect(red_night.interaction_component.nearest_item_index() >= 0, "route marker is interactable in range")
	red_night.interaction_component.interact()
	expect(red_night.transition_confirm_panel.is_open(), "transition marker opens confirmation window")
	expect(String(red_night.transition_confirm_panel.destination_name) == "Dormitory Lobby", "confirmation window displays destination name")
	red_night._cancel_pending_transition()
	expect(not red_night.transition_confirm_panel.is_open(), "transition prompt can be cancelled")
	red_night.biomass = 8.0
	red_night.player_health = 5
	red_night.contained_prey_weight = 2.0
	red_night.occupied_vore_capacity = 2
	red_night.enemy_contained = true
	red_night.contained_route_loads["BELLY"] = 2
	red_night.digest_progress = 1.25
	red_night.story_flags["transition_route_test"] = true
	red_night.save_map_switch_checkpoint("res://scenes/dormitory_lobby.tscn", "Dormitory Lobby", false)
	var checkpoint_save = JSON.parse_string(FileAccess.get_file_as_string(red_night.save_path_override))
	expect(checkpoint_save is Dictionary, "map switch checkpoint creates save data")
	expect(is_equal_approx(float(checkpoint_save.get("biomass", 0.0)), 8.0), "map switch checkpoint commits player biomass")
	expect(int(checkpoint_save.get("player_health", 0)) == 5, "map switch checkpoint commits current HP")
	expect(is_equal_approx(float(checkpoint_save.get("contained_prey_weight", 0.0)), 2.0), "map switch checkpoint carries prey weight")
	expect(int(checkpoint_save.get("occupied_vore_capacity", 0)) == 2, "map switch checkpoint carries occupied capacity")
	expect(bool(checkpoint_save.get("enemy_contained", false)), "map switch checkpoint carries contained flag")
	expect(checkpoint_save.get("contained_route_loads", {}) is Dictionary and int(checkpoint_save["contained_route_loads"].get("BELLY", 0)) == 2, "map switch checkpoint carries belly load")
	expect(is_equal_approx(float(checkpoint_save.get("digest_progress", 0.0)), 1.25), "map switch checkpoint carries digestion progress")
	expect(checkpoint_save.get("route_checkpoint", {}) is Dictionary, "map switch checkpoint stores route metadata")
	expect(String(checkpoint_save["route_checkpoint"].get("target_scene", "")) == "res://scenes/dormitory_lobby.tscn", "map switch checkpoint stores target scene")
	expect(bool(checkpoint_save["route_checkpoint"].get("return_allowed", false)), "normal map switch remains return-allowed")
	var lobby_with_prey = load("res://scenes/dormitory_lobby.tscn").instantiate()
	lobby_with_prey.save_path_override = "user://transition_route_test.json"
	root.add_child(lobby_with_prey)
	await process_frame
	expect(lobby_with_prey.player_health == 5, "normal destination scene restores current HP instead of full healing")
	expect(lobby_with_prey.enemy_contained, "destination scene restores carried prey flag")
	expect(lobby_with_prey.occupied_vore_capacity == 2, "destination scene restores occupied capacity")
	expect(lobby_with_prey.contained_route_loads["BELLY"] == 2, "destination scene restores belly load")
	expect(is_equal_approx(lobby_with_prey.digest_progress, 1.25), "destination scene restores digestion progress")
	lobby_with_prey.queue_free()
	await process_frame
	red_night.save_map_switch_checkpoint("res://scenes/safe_house.tscn", "Shelter", true)
	var boundary_save = JSON.parse_string(FileAccess.get_file_as_string(red_night.save_path_override))
	expect(bool(boundary_save["route_checkpoint"].get("stage_boundary", false)), "stage-boundary checkpoint is marked")
	expect(not bool(boundary_save["route_checkpoint"].get("return_allowed", true)), "stage-boundary checkpoint is no-return")
	red_night.queue_free()
	await process_frame

	var shelter = load("res://scenes/safe_house.tscn").instantiate()
	shelter.save_path_override = "user://transition_route_test.json"
	root.add_child(shelter)
	await process_frame
	expect(shelter.current_health == shelter.max_health, "UI shelter refills HP")
	expect(is_equal_approx(shelter.biomass, 8.0), "UI shelter restores biomass")
	expect(shelter.occupied_vore_capacity == 2, "UI shelter preserves occupied prey capacity")
	expect(shelter.contained_route_loads["BELLY"] == 2, "UI shelter preserves body expansion loads")
	expect(is_equal_approx(shelter.digest_progress, 1.25), "UI shelter preserves partial digestion")
	expect(shelter.stations.size() >= 7, "UI shelter exposes interactive stations without a walkable map")
	shelter.queue_free()
	await process_frame

	var lobby = load("res://scenes/dormitory_lobby.tscn").instantiate()
	root.add_child(lobby)
	await process_frame
	expect(lobby.map_data != null and String(lobby.map_data.map_id) == "dormitory_lobby", "dormitory gate loads the lobby map data")
	expect(String(lobby.map_data.camera_mode) == "FIXED_ROOM", "dormitory lobby is a non-scrolling first-floor room")
	expect(lobby.map_data.visual_data != null and not lobby.map_data.visual_data.background_layers.is_empty(), "dormitory lobby uses the generated switchback background")
	var stair_marker := item(lobby, "lobby_staircase_to_second_floor")
	expect(not stair_marker.is_empty(), "dormitory lobby has a staircase route")
	expect(String(stair_marker.get("target_scene", "")) == "res://scenes/dormitory_second_floor.tscn", "lobby staircase points to the second floor")
	lobby.queue_free()
	await process_frame

	var second_floor = load("res://scenes/dormitory_second_floor.tscn").instantiate()
	second_floor.load_saved_progress_on_start = false
	root.add_child(second_floor)
	await process_frame
	expect(second_floor.map_data != null and String(second_floor.map_data.map_id) == "dormitory_second_floor", "second-floor scene loads hallway map data")
	expect(String(second_floor.map_data.camera_mode) == "SCROLLING", "second-floor hallway is a scrolling map")
	expect(second_floor.map_data.visual_data != null and not second_floor.map_data.visual_data.background_layers.is_empty(), "second-floor hallway uses the generated hallway background")
	var su_ruo_marker := item(second_floor, "su_ruo_room_door")
	expect(not su_ruo_marker.is_empty(), "second-floor hallway has Su Ruo's room route")
	expect(String(su_ruo_marker.get("target_scene", "")) == "res://scenes/empty_bed.tscn", "Su Ruo room door points to the room scene")
	expect(Vector2(su_ruo_marker["position"]) == Vector2(970, 5), "Su Ruo room interaction point is reachable in the hallway")
	expect(bool(su_ruo_marker.get("show_transition_circle", false)), "Su Ruo room door keeps its floor route circle")
	expect(bool(su_ruo_marker.get("background_prop", false)), "Su Ruo room door art is mounted to the background")
	expect(second_floor.map_data.item_visual_data.prop_texture("su_ruo_room_door") != null, "Su Ruo room route draws open-door prop art")
	var roof_stair_marker := item(second_floor, "second_floor_roof_stairs")
	expect(not roof_stair_marker.is_empty(), "second-floor hallway has a roof stair route")
	expect(String(roof_stair_marker.get("target_scene", "")) == "res://scenes/red_night_roof_route.tscn", "second-floor roof stairs point to roof route")
	expect(not second_floor.interaction_component.is_item_unlocked(roof_stair_marker), "second-floor roof stairs are locked before Su Ruo clue")
	second_floor.story_flags["red_night_su_ruo_clue"] = true
	expect(second_floor.interaction_component.is_item_unlocked(roof_stair_marker), "second-floor roof stairs unlock after Su Ruo clue")
	second_floor.queue_free()
	await process_frame

	var dorm = load("res://scenes/empty_bed.tscn").instantiate()
	root.add_child(dorm)
	await process_frame
	expect(dorm.map_data != null and String(dorm.map_data.map_id) == "empty_bed_dorm_room", "Su Ruo room scene still loads empty-bed map data")
	expect(dorm.map_data.visual_data != null and not dorm.map_data.visual_data.background_layers.is_empty(), "Su Ruo room uses generated fixed-room background")
	expect(dorm.map_data.walkable_areas.size() == 1, "Su Ruo room has authored fixed-room walkable floor")
	var clue_marker := item(dorm, "su_ruo_first_clue")
	expect(String(clue_marker.get("set_story_flag", "")) == "red_night_su_ruo_clue", "Su Ruo clue item sets the roof unlock flag")
	var id_marker := item(dorm, "su_ruo_student_id")
	expect(not id_marker.is_empty(), "Su Ruo room has the student ID at the right side")
	expect(Vector2(id_marker["position"]).x >= 750.0, "Su Ruo student ID is placed near the right-side bed")
	var roof_marker := item(dorm, "teaching_building_exit")
	expect(not roof_marker.is_empty(), "dormitory room has a route back to the second-floor hallway")
	expect(String(roof_marker.get("type", "")) == "transition", "dormitory room return route uses transition item type")
	expect(String(roof_marker.get("target_scene", "")) == "res://scenes/dormitory_second_floor.tscn", "dormitory room returns to second floor")
	dorm.queue_free()
	await process_frame

	var roof = load("res://scenes/red_night_roof_route.tscn").instantiate()
	root.add_child(roof)
	await process_frame
	expect(roof.map_data != null and String(roof.map_data.map_id) == "red_night_roof_route", "roof scene loads roof route map data")
	expect(roof.map_data.visual_data != null, "roof route scene has visual data")
	expect(roof.map_data.visual_data.stitch_background_layers, "roof route scene stitches its background plates")
	expect(roof.map_data.visual_data.background_layers.size() == 2, "roof route scene uses two roof background plates")
	roof.queue_free()
	await process_frame

	var path := ProjectSettings.globalize_path("user://transition_route_test.json")
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	if failures == 0:
		print("PASS: transition route tests")
		quit(0)
	else:
		push_error("FAIL: %d transition route test(s)" % failures)
		quit(1)


func item(stage, id: String) -> Dictionary:
	for candidate in stage.scene_items:
		if String(candidate.get("id", "")) == id:
			return candidate
	return {}


func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)
