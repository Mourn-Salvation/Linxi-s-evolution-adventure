extends SceneTree

const BalanceScript = preload("res://scripts/data/game_balance.gd")
const Progression = preload("res://scripts/data/linxi_progression.gd")
const ContentValidator = preload("res://scripts/data/content_validator.gd")
const VoreComponentScript = preload("res://scripts/systems/vore_component.gd")
const TEST_VIEWPORT_SIZE := Vector2(1280.0, 720.0)
const TEST_GROUND_ORIGIN_X := 170.0
const TEST_DEPTH_AXIS_X := -0.32

var failures := 0


func _initialize() -> void:
	var balance: GameBalance = load("res://resources/balance/default_balance.tres")
	test_balance(balance)
	test_routes(balance)
	test_save_migration(balance)
	test_map_content()
	test_scrolling_map_visual_scale()
	test_project_content_validation()
	if failures == 0:
		print("PASS: stabilization mechanics tests")
		quit(0)
	else:
		push_error("FAIL: %d stabilization mechanics test(s)" % failures)
		quit(1)


func expect_equal(actual, expected, label: String) -> void:
	if actual != expected:
		failures += 1
		push_error("%s: expected %s, got %s" % [label, expected, actual])


func expect_true(actual: bool, label: String) -> void:
	if not actual:
		failures += 1
		push_error("%s: expected true, got false" % label)


func expect_near(actual: float, expected: float, label: String, epsilon := 0.0001) -> void:
	if absf(actual - expected) > epsilon:
		failures += 1
		push_error("%s: expected %.4f, got %.4f" % [label, expected, actual])


func test_balance(balance: GameBalance) -> void:
	expect_near(balance.weight_speed_multiplier(1.0), 1.0, "weight 1 speed")
	expect_near(balance.walk_speed * balance.weight_speed_multiplier(10000.0), 50.0, "minimum walk speed")
	expect_near(balance.sprint_speed, 360.0, "larger-map sprint speed")
	expect_near(balance.weight_speed_multiplier(100.0, true), 1.0, "weight adaptation")
	expect_equal(balance.attack_damage(0.0), 2, "base attack")
	expect_equal(balance.attack_damage(10.0), 3, "mid biomass attack")
	expect_equal(balance.attack_damage(20.0), 4, "maximum biomass attack")
	expect_near(balance.attack_stun(0.1, 2), 0.15, "base damage stun")
	expect_near(balance.attack_stun(0.1, 4), 0.20, "high damage stun")
	expect_near(balance.attack_stun(0.1, 99), 0.24, "stun cap")
	expect_near(balance.growth_scale(0.0), 1.0, "base growth")
	expect_near(balance.growth_scale(20.0), 1.2, "maximum growth")
	expect_near(balance.maximum_biomass, 50.0, "maximum biomass")
	expect_near(balance.clamp_biomass(55.0), 50.0, "biomass cap")
	expect_near(balance.clamp_biomass(-1.0), 0.0, "biomass floor")
	expect_equal(balance.capacity_bonus(20.0), 20, "biomass capacity")
	expect_equal(balance.capacity_bonus(20.0), 20, "maximum biomass capacity")
	expect_equal(balance.capacity_bonus(50.0), 20, "bounded biomass capacity")
	expect_near(balance.digest_seconds(0.0), 3.0, "base digest time")
	expect_near(balance.digest_seconds(25.0), 2.25, "mid biomass digest time")
	expect_near(balance.digest_seconds(50.0), 1.5, "maximum biomass digest time reduction")
	expect_near(balance.digested_biomass(4.0), 1.0, "digestion retention")
	expect_near(balance.live_vore_chance(0.0), 0.2, "base live Vore")
	expect_near(balance.live_vore_chance(25.0), 0.6, "mid live Vore")
	expect_near(balance.live_vore_chance(50.0), 1.0, "live Vore cap")
	expect_near(balance.live_vore_chance(0.0, true), 1.0, "G mode live Vore")


func test_routes(balance: GameBalance) -> void:
	var vore_component := VoreComponentScript.new()
	expect_equal(vore_component.route_region("CORE"), "BELLY", "core route region")
	expect_equal(vore_component.route_region("LEFT"), "BELLY", "left route region")
	expect_equal(vore_component.route_region("RIGHT"), "BELLY", "right route region")
	expect_equal(vore_component.route_region("UPPER"), "CHEST", "upper route region")
	expect_equal(vore_component.route_region("LOWER"), "LOWER_BELLY", "lower route region")
	expect_equal(vore_component.route_region("BURST"), "GROIN", "burst route region")
	expect_equal(vore_component.is_route_enabled("CORE"), true, "core route enabled")
	expect_equal(vore_component.is_route_enabled("LEFT"), true, "left route enabled")
	expect_equal(vore_component.is_route_enabled("RIGHT"), true, "right route enabled")
	expect_equal(vore_component.is_route_enabled("UPPER"), false, "upper route disabled")
	expect_equal(vore_component.is_route_enabled("LOWER"), false, "lower route disabled")
	expect_equal(vore_component.is_route_enabled("BURST"), false, "burst route disabled")
	expect_equal(vore_component.is_region_enabled("BELLY"), true, "belly region enabled")
	expect_equal(vore_component.is_region_enabled("CHEST"), false, "chest region disabled")
	expect_equal(vore_component.is_region_enabled("LOWER_BELLY"), false, "lower belly region disabled")
	expect_equal(vore_component.is_region_enabled("GROIN"), false, "groin region disabled")
	vore_component.free()
	expect_equal(balance.route_visual_tier(1), 1, "tier one")
	expect_equal(balance.route_visual_tier(4), 4, "tier four")
	expect_equal(balance.route_visual_tier(9), 4, "tier overflow")
	expect_near(balance.route_overflow_scale(4), 1.0, "tier four scale")
	expect_near(balance.route_overflow_scale(6), 1.16, "overflow scale")
	expect_equal(mini(balance.g_mode_batch_limit, 20), 6, "G mode batch limit")


func test_save_migration(balance: GameBalance) -> void:
	var old_save := {"balance_version": 1, "permanent_weight": 3.0, "player_max_health": 105}
	var migrated := Progression.normalize_save(old_save, balance.unit_health, balance.legacy_max_health)
	expect_equal(migrated["player_max_health"], 15, "legacy health migration")
	expect_near(migrated["biomass"], 0.0, "legacy biomass default")
	expect_equal(migrated["unlocked_intake_routes"], ["CORE"], "legacy route default")
	var current := Progression.normalize_save({"balance_version": 4, "player_max_health": 17, "unlocked_intake_routes": ["CORE", "UPPER", "UPPER", "INVALID"]}, balance.unit_health, balance.legacy_max_health)
	expect_equal(current["player_max_health"], 17, "current health")
	expect_equal(current["player_health"], 17, "missing current HP defaults to max HP")
	var damaged := Progression.normalize_save({"balance_version": 4, "player_max_health": 17, "player_health": 6}, balance.unit_health, balance.legacy_max_health)
	expect_equal(damaged["player_health"], 6, "current HP carries through progression")
	expect_equal(current["unlocked_intake_routes"], ["CORE", "UPPER"], "route normalization")
	var capped := Progression.normalize_save({"balance_version": 4, "biomass": 99.0}, balance.unit_health, balance.legacy_max_health, balance.maximum_biomass)
	expect_near(capped["biomass"], 50.0, "save biomass cap")
	var carried := Progression.normalize_save({
		"balance_version": 4,
		"contained_prey_weight": 2.0,
		"occupied_vore_capacity": 2,
		"contained_route_loads": {"BELLY": 2, "CHEST": -1},
		"digest_progress": 1.25,
		"enemy_contained": true,
	}, balance.unit_health, balance.legacy_max_health, balance.maximum_biomass)
	expect_near(carried["contained_prey_weight"], 2.0, "save carries prey weight")
	expect_equal(carried["occupied_vore_capacity"], 2, "save carries occupied capacity")
	expect_equal(carried["contained_route_loads"]["BELLY"], 2, "save carries belly load")
	expect_equal(carried["contained_route_loads"]["CHEST"], 0, "save clamps invalid route load")
	expect_near(carried["digest_progress"], 1.25, "save carries digestion progress")
	expect_true(carried["enemy_contained"], "save carries contained flag")


func _find_item(items: Array[Dictionary], id: String) -> Dictionary:
	for item in items:
		if String(item.get("id", "")) == id:
			return item
	return {}


func _find_enemy(enemies: Array[Dictionary], id: String) -> Dictionary:
	for enemy in enemies:
		if String(enemy.get("id", "")) == id:
			return enemy
	return {}


func _map_position_in_walkable(map: MapData, position: Vector2) -> bool:
	for area in map.walkable_areas:
		if not area is Dictionary:
			continue
		var area_position = area.get("position", null)
		var area_size = area.get("size", null)
		if area_position is Vector2 and area_size is Vector2:
			if Rect2(Vector2(area_position), Vector2(area_size)).abs().has_point(position):
				return true
	return false


func test_map_content() -> void:
	var map: MapData = load("res://resources/maps/opening_scene.tres")
	expect_equal(map.encounter_id, "evaluation_guards_01", "map encounter id")
	expect_equal(map.enemy_spawns.size(), 10, "map enemy count")
	expect_equal(map.items.size(), 3, "map item count")
	expect_equal(String(map.enemy_spawns[0]["id"]), "guard_01", "map enemy identity")
	var stage = load("res://resources/stages/stage_01_red_night.tres")
	expect_equal(stage.stage_id, "stage_01_red_night", "stage one id")
	expect_equal(stage.display_name, "Stage 1: Red Night", "stage one name")
	var level = stage.opening_level()
	expect_equal(level.level_id, "stage_01_level_00_courtyard_fall_site", "stage one level zero id")
	expect_equal(level.display_name, "Courtyard Fall Site", "stage one level zero name")
	expect_equal(level.map_data.map_id, "red_night_courtyard", "stage one level zero map")
	expect_true(level.map_data.visual_data.stitch_background_layers, "courtyard uses stitched map plates, not fades")
	expect_equal(stage.levels.size(), 10, "stage one level count")
	var dorm_lobby: LevelData = stage.level_by_id("stage_01_level_01_dormitory_lobby")
	expect_equal(dorm_lobby.display_name, "Dormitory Lobby", "stage one level one name")
	expect_equal(dorm_lobby.map_data.map_id, "dormitory_lobby", "stage one level one map")
	expect_equal(dorm_lobby.map_data.camera_mode, "FIXED_ROOM", "dormitory lobby camera mode")
	expect_equal(dorm_lobby.map_data.enemy_spawns.size(), 3, "dormitory lobby Li Yingying beat enemy count")
	expect_equal(dorm_lobby.map_data.items.size(), 3, "dormitory lobby dialogue and bidirectional route count")
	expect_equal(dorm_lobby.map_data.walkable_areas.size(), 4, "dormitory lobby walkable zones")
	expect_equal(dorm_lobby.map_data.blocked_areas.size(), 4, "dormitory lobby stair blockers")
	var li_yingying := _find_enemy(dorm_lobby.map_data.enemy_spawns, "li_yingying")
	expect_equal(String(li_yingying.get("initial_state", "")), "KNOCKED_DOWN", "Li Yingying starts knocked down")
	expect_equal(String(li_yingying.get("vore_locked_until_group_defeated", "")), "dormitory_lobby_stair_zombies", "Li Yingying vore lock")
	var li_dialogue := _find_item(dorm_lobby.map_data.items, "li_yingying_dialogue")
	expect_equal(String(li_dialogue.get("required_defeated_group", "")), "dormitory_lobby_stair_zombies", "Li Yingying dialogue lock")
	expect_equal(String(li_dialogue.get("avatar_path", "")), "res://assets/ui/dialogue_portraits/li_yingying.png", "Li Yingying dialogue avatar")
	expect_true(bool(li_dialogue.get("always_show_prompt", false)), "Li Yingying dialogue has floating F prompt")
	var dorm_lobby_transition := _find_item(dorm_lobby.map_data.items, "lobby_staircase_to_second_floor")
	expect_equal(Vector2(dorm_lobby_transition["position"]), Vector2(1085, 22), "dormitory lobby landing transition")
	expect_true(_map_position_in_walkable(dorm_lobby.map_data, Vector2(dorm_lobby_transition["position"])), "dormitory lobby landing transition is reachable")
	var dorm_second_floor: LevelData = stage.level_by_id("stage_01_level_02_dormitory_second_floor")
	expect_equal(dorm_second_floor.display_name, "Dormitory Second Floor", "stage one level two name")
	expect_equal(dorm_second_floor.map_data.map_id, "dormitory_second_floor", "stage one level two map")
	expect_equal(dorm_second_floor.map_data.camera_mode, "SCROLLING", "dormitory second floor camera mode")
	expect_equal(dorm_second_floor.map_data.walkable_areas.size(), 1, "dormitory second floor hallway walkable zone")
	expect_near(dorm_second_floor.map_data.depth, 345.0, "dormitory second floor starts Y depth at wall-floor seam")
	expect_equal(dorm_second_floor.map_data.enemy_spawns.size(), 4, "dormitory second floor hostile zombie count")
	expect_equal(dorm_second_floor.map_data.items.size(), 3, "dormitory second floor route count")
	expect_equal(dorm_second_floor.map_data.visual_data.foreground_layers.size(), 0, "dormitory second floor has no actor-covering foreground fence")
	expect_true(dorm_second_floor.map_data.visual_data.stitch_background_layers, "dormitory second floor uses stitched map plates, not fades")
	expect_near(dorm_second_floor.map_data.visual_data.scrolling_background_scale, 1.0, "dormitory second floor background scale")
	var su_ruo_room_door := _find_item(dorm_second_floor.map_data.items, "su_ruo_room_door")
	expect_equal(Vector2(su_ruo_room_door["position"]), Vector2(970, 5), "Su Ruo room interaction point")
	expect_true(bool(su_ruo_room_door.get("show_transition_circle", false)), "Su Ruo room door keeps its route marker")
	expect_true(bool(su_ruo_room_door.get("background_prop", false)), "Su Ruo room door art is drawn with the background")
	expect_equal(Vector2(su_ruo_room_door.get("background_anchor", Vector2.ZERO)), Vector2(1070, 430), "Su Ruo room background door anchor")
	expect_true(_map_position_in_walkable(dorm_second_floor.map_data, Vector2(su_ruo_room_door["position"])), "Su Ruo room transition is reachable")
	expect_true(dorm_second_floor.map_data.item_visual_data.prop_texture("su_ruo_room_door") != null, "Su Ruo room transition has open-door prop art")
	expect_equal(dorm_second_floor.map_data.item_visual_data.prop_size("su_ruo_room_door"), Vector2(150, 265), "Su Ruo room door prop covers the wall door")
	var second_floor_roof_stairs := _find_item(dorm_second_floor.map_data.items, "second_floor_roof_stairs")
	expect_equal(String(second_floor_roof_stairs.get("required_story_flag", "")), "red_night_su_ruo_clue", "second floor roof stairs require Su Ruo clue")
	expect_true(_map_position_in_walkable(dorm_second_floor.map_data, Vector2(second_floor_roof_stairs["position"])), "second floor roof stairs are reachable")
	var empty_bed: LevelData = stage.level_by_id("stage_01_level_01_dormitory_su_ruo_room")
	expect_equal(empty_bed.display_name, "Dormitory: Su Ruo's Room", "Su Ruo room level name")
	expect_equal(empty_bed.map_data.map_id, "empty_bed_dorm_room", "Su Ruo room map")
	expect_equal(empty_bed.map_data.camera_mode, "FIXED_ROOM", "empty bed camera mode")
	expect_near(empty_bed.map_data.visual_data.fixed_room_background_scale, 0.56, "Su Ruo room fixed-room background scale")
	expect_equal(empty_bed.map_data.enemy_spawns.size(), 3, "empty bed human-student prey count")
	expect_equal(empty_bed.map_data.items.size(), 4, "empty bed interactable count")
	var su_ruo_clue := _find_item(empty_bed.map_data.items, "su_ruo_first_clue")
	expect_equal(String(su_ruo_clue.get("set_story_flag", "")), "red_night_su_ruo_clue", "Su Ruo clue sets roof unlock flag")
	var su_ruo_id := _find_item(empty_bed.map_data.items, "su_ruo_student_id")
	expect_true(_map_position_in_walkable(empty_bed.map_data, Vector2(su_ruo_id["position"])), "Su Ruo student ID is reachable")
	expect_true(empty_bed.map_data.item_visual_data.prop_texture("su_ruo_student_id") != null, "Su Ruo student ID has prop art")
	var roof_route: LevelData = stage.level_by_id("stage_01_level_02_roof_route")
	expect_equal(roof_route.map_data.map_id, "red_night_roof_route", "stage one roof route map")
	expect_true(roof_route.map_data.visual_data != null, "roof route has map visual data")
	expect_true(roof_route.map_data.visual_data.stitch_background_layers, "roof route uses stitched roof plates")
	expect_equal(roof_route.map_data.visual_data.background_layers.size(), 2, "roof route owns two dedicated roof plates")
	var playground_return: LevelData = stage.level_by_id("stage_01_level_03_playground_return")
	expect_equal(playground_return.map_data.map_id, "red_night_playground_return", "stage one playground return map")
	expect_true(playground_return.map_data.visual_data != null, "playground return has map visual data")
	expect_true(playground_return.map_data.visual_data.stitch_background_layers, "playground return uses stitched morning plates")
	expect_near(playground_return.map_data.length, 1694.0, "playground return production-panorama length")
	expect_equal(playground_return.map_data.visual_data.background_layers.size(), 3, "playground return owns three morning background plates")
	var school_exit: LevelData = stage.level_by_id("stage_01_level_04_school_exit")
	expect_equal(school_exit.map_data.map_id, "red_night_school_exit", "stage one school exit map")


func test_project_content_validation() -> void:
	var errors := ContentValidator.validate_project()
	for error in errors:
		failures += 1
		push_error(error)


func test_scrolling_map_visual_scale() -> void:
	var stage = load("res://resources/stages/stage_01_red_night.tres")
	var active_map_ids := [
		"stage_01_level_00_courtyard_fall_site",
		"stage_01_level_02_dormitory_second_floor",
		"stage_01_level_02_roof_route",
		"stage_01_level_03_playground_return",
	]
	for level_id in active_map_ids:
		var level: LevelData = stage.level_by_id(level_id)
		expect_true(level != null, "%s exists for visual scroll QA" % level_id)
		if level == null:
			continue
		var ratio := _visual_scroll_ratio(level.map_data)
		expect_true(ratio >= 0.98 and ratio <= 1.10, "%s visual scroll ratio stays within the approved map range, got %.3f" % [level.map_data.map_id, ratio])


func _visual_scroll_ratio(map: MapData) -> float:
	if map == null or map.visual_data == null or map.camera_mode == "FIXED_ROOM":
		return 1.0
	var camera_span := maxf(map.length - TEST_VIEWPORT_SIZE.x + TEST_GROUND_ORIGIN_X + TEST_DEPTH_AXIS_X * map.depth, 0.0)
	var background_span := _rendered_background_scroll_span(map.visual_data)
	if camera_span <= 0.0:
		return 1.0 if background_span <= 0.0 else INF
	return background_span / camera_span


func _rendered_background_scroll_span(visual_data: MapVisualData) -> float:
	var total_source_width := 0.0
	var max_source_height := 1.0
	for texture in visual_data.background_layers:
		if texture == null:
			continue
		var texture_size := texture.get_size()
		total_source_width += texture_size.x
		max_source_height = maxf(max_source_height, texture_size.y)
	var scale := TEST_VIEWPORT_SIZE.y / max_source_height * visual_data.scrolling_background_scale
	return maxf(total_source_width * scale - TEST_VIEWPORT_SIZE.x, 0.0)
