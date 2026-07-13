extends SceneTree

const ContentValidatorScript = preload("res://scripts/data/content_validator.gd")

const MAP_PATHS: Array[String] = [
	"res://resources/maps/red_night_teaching_lobby.tres",
	"res://resources/maps/red_night_teaching_building.tres",
	"res://resources/maps/red_night_classroom_503.tres",
	"res://resources/maps/red_night_school_exit.tres",
]


func _initialize() -> void:
	var failures := 0
	for path in MAP_PATHS:
		var map := load(path) as MapData
		if map == null:
			push_error("TEACHING_ROUTE failed to load %s" % path)
			failures += 1
			continue
		var errors: Array[String] = ContentValidatorScript.validate_map(map, path)
		for error in errors:
			push_error("TEACHING_ROUTE %s" % error)
		failures += errors.size()
		print("TEACHING_ROUTE map=", map.map_id, " items=", map.items.size())

	var lobby := load(MAP_PATHS[0]) as MapData
	var hallway := load(MAP_PATHS[1]) as MapData
	var classroom := load(MAP_PATHS[2]) as MapData
	failures += _expect_transition(lobby, "teaching_lobby_to_second_floor", "res://scenes/red_night_teaching_building.tscn")
	failures += _expect_transition(lobby, "teaching_lobby_return_to_playground", "res://scenes/red_night_playground_return.tscn")
	failures += _expect_transition(lobby, "teaching_lobby_to_school_front_gate", "res://scenes/red_night_school_exit.tscn", "red_night_twins_met")
	failures += _expect_transition(hallway, "teaching_second_floor_stairs_down", "res://scenes/red_night_teaching_lobby.tscn")
	failures += _expect_transition(hallway, "teaching_second_floor_classroom_503", "res://scenes/red_night_classroom_503.tscn")
	failures += _expect_transition(classroom, "classroom_503_exit", "res://scenes/red_night_teaching_building.tscn")
	if classroom.item_visual_data == null or classroom.item_visual_data.prop_texture("classroom_503_twins_dialogue") == null:
		push_error("TEACHING_ROUTE Classroom 503 twins must have a right-facing paired runtime frame")
		failures += 1
	var school_exit := _item(lobby, "teaching_lobby_to_school_front_gate")
	if school_exit.is_empty() or not bool(school_exit.get("hide_when_locked", false)) or Vector2(school_exit.get("position", Vector2.ZERO)).x < 900.0:
		push_error("TEACHING_ROUTE school-gate exit must stay hidden before the twins and sit at the lobby's right end")
		failures += 1
	var upper_edge := INF
	for area in hallway.walkable_areas:
		for point in area.get("points", []):
			upper_edge = minf(upper_edge, Vector2(point).y)
	if not is_equal_approx(upper_edge, 75.0):
		push_error("TEACHING_ROUTE second-floor upper walkable edge must be Y=75, got %s" % upper_edge)
		failures += 1
	if failures == 0:
		print("PASS: teaching route smoke test")
	quit(0 if failures == 0 else 1)


func _item(map: MapData, item_id: String) -> Dictionary:
	for item in map.items:
		if String(item.get("id", "")) == item_id:
			return item
	return {}


func _expect_transition(map: MapData, item_id: String, target_scene: String, required_flag: String = "") -> int:
	for item in map.items:
		if String(item.get("id", "")) != item_id:
			continue
		if String(item.get("target_scene", "")) != target_scene:
			push_error("TEACHING_ROUTE %s target mismatch" % item_id)
			return 1
		if not required_flag.is_empty() and String(item.get("required_story_flag", "")) != required_flag:
			push_error("TEACHING_ROUTE %s flag mismatch" % item_id)
			return 1
		return 0
	push_error("TEACHING_ROUTE missing transition %s" % item_id)
	return 1
