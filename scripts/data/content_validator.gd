class_name ContentValidator
extends RefCounted

const VALID_ENVIRONMENT_THEMES := ["EVALUATION", "RED_NIGHT"]
const VALID_CAMERA_MODES := ["SCROLLING", "FIXED_ROOM"]
const VALID_FOOTSTEP_SURFACES := ["WET", "CONCRETE", "MARBLE", "GRASS"]
const VALID_ENEMY_FAMILIES := ["HUMAN", "ZOMBIE", "MUTANT", "MUTANT_CREATURE"]
const VALID_ENEMY_STATES := ["APPROACH", "DORMANT", "NEUTRAL", "STAGGER", "KNOCKED_DOWN", "CONTAINED", "DIGESTED", "ESCAPED"]
const VALID_ATTACK_TYPES := ["NORMAL", "HEAVY"]
const VALID_AI_PROFILES := ["STANDARD", "NEUTRAL_WANDER", "NON_COMBAT_WANDER", "ZOMBIE_CHASE_HUMAN", "BONE_BLADE_ELITE"]
const VALID_ITEM_TYPES := ["story", "dialogue", "weapon", "transition"]

const RED_NIGHT_STORY_EVENTS := [
	"drink_blue_stock",
	"inspect_empty_nebulizer",
	"unlock_claws",
	"unlock_tail",
	"enter_dormitory",
	"inspect_su_ruo_room",
	"reach_roof_stairs",
]

const RED_NIGHT_REQUIRED_EVENTS := [
	"drink_blue_stock",
]

const RED_NIGHT_STORY_GROUPS := ["scout", "claw_tutorial_infected", "dormitory_wave", "dormitory_civilians"]

const REQUIRED_RESOURCE_PATHS := [
	"res://resources/balance/default_balance.tres",
	"res://resources/attacks/claw_neutral.tres",
	"res://resources/attacks/claw_left.tres",
	"res://resources/attacks/claw_right.tres",
	"res://resources/attacks/claw_up.tres",
	"res://resources/attacks/claw_down.tres",
	"res://resources/maps/red_night_visual_data.tres",
	"res://resources/items/red_night_item_visual_data.tres",
	"res://resources/effects/red_night_effect_visual_data.tres",
	"res://assets/ui/achievements/whats_inside_the_vial.png",
]


static func validate_project() -> Array[String]:
	var errors: Array[String] = []
	for path in REQUIRED_RESOURCE_PATHS:
		if not ResourceLoader.exists(path):
			errors.append("Missing required resource: %s" % path)
	var map_paths := discover_resource_paths("res://resources/maps", "MapData")
	var level_paths := discover_resource_paths("res://resources/levels", "LevelData")
	var stage_paths := discover_resource_paths("res://resources/stages", "StageData")
	if map_paths.is_empty():
		errors.append("No MapData resources discovered under res://resources/maps.")
	if level_paths.is_empty():
		errors.append("No LevelData resources discovered under res://resources/levels.")
	if stage_paths.is_empty():
		errors.append("No StageData resources discovered under res://resources/stages.")
	for path in map_paths:
		errors.append_array(validate_map(load(path) as MapData, path))
	for path in level_paths:
		errors.append_array(validate_level(load(path) as LevelData, path))
	for path in stage_paths:
		errors.append_array(validate_stage(load(path) as StageData, path))
	errors.append_array(validate_frame_sequence("Linxi weak idle", "res://assets/sprites/linxi/t_early/weak_idle/%02d_idle_%02d.png", 4))
	errors.append_array(validate_directional_sequence("Linxi weak walk", "res://assets/sprites/linxi/t_early/walk_horizontal", 16))
	errors.append_array(validate_directional_sequence("Linxi sprint", "res://assets/sprites/linxi/t_early/sprint_horizontal", 8))
	errors.append_array(validate_directional_sequence("Linxi dodge", "res://assets/sprites/linxi/t_early/dodge", 4))
	errors.append_array(validate_directional_sequence("Linxi claw attack", "res://assets/sprites/linxi/t_early/claw_attack", 6))
	errors.append_array(validate_directional_sequence("Linxi hit reaction", "res://assets/sprites/linxi/t_early/hit_reaction", 4))
	errors.append_array(validate_frame_sequence("Linxi get-up story", "res://assets/sprites/linxi/t_early/story/get_up/%02d_get_up.png", 6))
	errors.append_array(validate_frame_sequence("Linxi drink-blue story", "res://assets/sprites/linxi/t_early/story/drink_blue/%02d_drink_blue.png", 6))
	errors.append_array(validate_directional_sequence("Zombie student hit reaction", "res://assets/sprites/enemies/zombie_student/hit_reaction", 4))
	errors.append_array(validate_directional_sequence("Zombie student appearance variants", "res://assets/sprites/enemies/zombie_student/appearance_variants", 4))
	errors.append_array(validate_directional_variant_sequence("Zombie student idle variants", "res://assets/sprites/enemies/zombie_student/idle", 4, 1))
	errors.append_array(validate_specific_directional_variant_sequence("Human female student true idle variants", "res://assets/sprites/enemies/human_student/idle_female_variants_v2", [1, 2, 3, 4, 5], 1))
	errors.append_array(validate_specific_directional_variant_sequence("Human male knife-student true idle variants", "res://assets/sprites/enemies/human_student/idle_male_variants_v2", [6, 7], 1))
	errors.append_array(validate_effect_visual(load("res://resources/effects/red_night_effect_visual_data.tres") as EffectVisualData, "Red Night effect visual data"))
	errors.append_array(validate_intake_layers())
	errors.append_array(validate_linxi_runtime_sprite_metrics())
	return errors


static func discover_resource_paths(root_path: String, class_name_filter: String) -> Array[String]:
	var paths: Array[String] = []
	_collect_resource_paths(root_path, class_name_filter, paths)
	paths.sort()
	return paths


static func _collect_resource_paths(directory_path: String, class_name_filter: String, paths: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return
	directory.list_dir_begin()
	while true:
		var file_name := directory.get_next()
		if file_name.is_empty():
			break
		if file_name.begins_with("."):
			continue
		var path := "%s/%s" % [directory_path, file_name]
		if directory.current_is_dir():
			_collect_resource_paths(path, class_name_filter, paths)
		elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var resource := load(path)
			match class_name_filter:
				"MapData":
					if resource is MapData:
						paths.append(path)
				"LevelData":
					if resource is LevelData:
						paths.append(path)
				"StageData":
					if resource is StageData:
						paths.append(path)
				_:
					if resource != null:
						paths.append(path)
	directory.list_dir_end()


static func validate_stage(stage: StageData, label := "stage") -> Array[String]:
	var errors: Array[String] = []
	if stage == null:
		return ["%s did not load as StageData." % label]
	if stage.stage_id.strip_edges().is_empty():
		errors.append("%s has empty stage_id." % label)
	if stage.display_name.strip_edges().is_empty():
		errors.append("%s has empty display_name." % label)
	if stage.levels.is_empty():
		errors.append("%s has no levels." % label)
	if stage.opening_level_index < 0 or stage.opening_level_index >= stage.levels.size():
		errors.append("%s opening_level_index is outside levels." % label)
	var level_ids := {}
	for index in range(stage.levels.size()):
		var level := stage.levels[index] as LevelData
		if level == null:
			errors.append("%s levels[%d] is not LevelData." % [label, index])
			continue
		if level.stage_id != stage.stage_id:
			errors.append("%s level %s has mismatched stage_id: %s" % [label, level.level_id, level.stage_id])
		if level_ids.has(level.level_id):
			errors.append("%s has duplicate level_id: %s" % [label, level.level_id])
		else:
			level_ids[level.level_id] = true
		errors.append_array(validate_level(level, "%s/%s" % [label, level.level_id]))
	return errors


static func validate_level(level: LevelData, label := "level") -> Array[String]:
	var errors: Array[String] = []
	if level == null:
		return ["%s did not load as LevelData." % label]
	if level.stage_id.strip_edges().is_empty():
		errors.append("%s has empty stage_id." % label)
	if level.level_id.strip_edges().is_empty():
		errors.append("%s has empty level_id." % label)
	if level.display_name.strip_edges().is_empty():
		errors.append("%s has empty display_name." % label)
	if level.map_data == null:
		errors.append("%s has no map_data." % label)
	else:
		errors.append_array(validate_map(level.map_data, "%s/%s" % [label, level.map_data.map_id]))
	return errors


static func validate_map(map: MapData, label := "map") -> Array[String]:
	var errors: Array[String] = []
	if map == null:
		return ["%s did not load as MapData." % label]
	if map.map_id.strip_edges().is_empty():
		errors.append("%s has empty map_id." % label)
	if map.encounter_id.strip_edges().is_empty():
		errors.append("%s has empty encounter_id." % label)
	if not VALID_ENVIRONMENT_THEMES.has(map.environment_theme):
		errors.append("%s uses unknown environment_theme: %s" % [label, map.environment_theme])
	if not VALID_CAMERA_MODES.has(map.camera_mode):
		errors.append("%s uses unknown camera_mode: %s" % [label, map.camera_mode])
	if not VALID_FOOTSTEP_SURFACES.has(map.footstep_surface):
		errors.append("%s uses unknown footstep_surface: %s" % [label, map.footstep_surface])
	if map.ground_min_x > map.length:
		errors.append("%s ground_min_x exceeds map length." % label)
	if map.player_spawn.x < map.ground_min_x or map.player_spawn.x > map.length or map.player_spawn.y < 0.0 or map.player_spawn.y > map.depth:
		errors.append("%s player_spawn is outside map bounds." % label)
	errors.append_array(_validate_walkable_areas(map, label))
	errors.append_array(_validate_blocked_areas(map, label))
	errors.append_array(_validate_map_visual(map, label))
	errors.append_array(_validate_enemies(map, label))
	errors.append_array(_validate_items(map, label))
	errors.append_array(_validate_item_visual(map, label))
	if map.story_id == "red_night":
		errors.append_array(_validate_red_night_requirements(map, label))
	return errors


static func _validate_walkable_areas(map: MapData, label: String) -> Array[String]:
	var errors: Array[String] = []
	var walkable_polygons: Array[PackedVector2Array] = []
	for index in range(map.walkable_areas.size()):
		var area = map.walkable_areas[index]
		if not area is Dictionary:
			errors.append("%s walkable_areas[%d] is not a Dictionary." % [label, index])
			continue
		var area_data: Dictionary = area
		var polygon := _walkable_area_polygon(area_data, map, label, index, errors)
		if polygon.size() >= 3:
			walkable_polygons.append(polygon)
	if walkable_polygons.is_empty():
		return errors
	if not _position_in_any_polygon(map.player_spawn, walkable_polygons):
		errors.append("%s player_spawn is outside walkable_areas." % label)
	for index in range(map.enemy_spawns.size()):
		var enemy = map.enemy_spawns[index]
		if not enemy is Dictionary:
			continue
		var position = enemy.get("position", null)
		if position is Vector2 and not _position_in_any_polygon(position, walkable_polygons):
			errors.append("%s enemy %s is outside walkable_areas." % [label, String(enemy.get("id", index))])
	for index in range(map.items.size()):
		var item = map.items[index]
		if not item is Dictionary:
			continue
		var position = item.get("position", null)
		if position is Vector2 and not _position_in_any_polygon(position, walkable_polygons):
			var item_data: Dictionary = item
			var is_reachable_transition := String(item_data.get("type", "")) == "transition" and _position_near_any_polygon(Vector2(position), walkable_polygons, 105.0, 62.0)
			if not is_reachable_transition:
				errors.append("%s item %s is outside walkable_areas." % [label, String(item.get("id", index))])
	return errors


static func _position_in_any_polygon(position: Vector2, polygons: Array[PackedVector2Array]) -> bool:
	for polygon in polygons:
		if Geometry2D.is_point_in_polygon(position, polygon):
			return true
	return false


static func _position_near_any_polygon(position: Vector2, polygons: Array[PackedVector2Array], range_x: float, range_y: float) -> bool:
	for polygon in polygons:
		for index in range(polygon.size()):
			var start: Vector2 = polygon[index]
			var end: Vector2 = polygon[(index + 1) % polygon.size()]
			var nearest := Geometry2D.get_closest_point_to_segment(position, start, end)
			if absf(position.x - nearest.x) <= range_x and absf(position.y - nearest.y) <= range_y:
				return true
	return false


static func _walkable_area_polygon(area: Dictionary, map: MapData, label: String, index: int, errors: Array[String]) -> PackedVector2Array:
	var points = area.get("points", null)
	if points is Array:
		var polygon := PackedVector2Array()
		for point in points:
			if point is Vector2:
				var ground_point := Vector2(point)
				if ground_point.x < map.ground_min_x or ground_point.y < 0.0 or ground_point.x > map.length or ground_point.y > map.depth:
					errors.append("%s walkable_areas[%d] point %s is outside map bounds." % [label, index, str(ground_point)])
				polygon.append(ground_point)
			else:
				errors.append("%s walkable_areas[%d] has a non-Vector2 point." % [label, index])
		if polygon.size() < 3:
			errors.append("%s walkable_areas[%d] has fewer than 3 polygon points." % [label, index])
		return polygon
	var position = area.get("position", null)
	var size = area.get("size", null)
	if not position is Vector2:
		errors.append("%s walkable_areas[%d] has no Vector2 position or points." % [label, index])
		return PackedVector2Array()
	if not size is Vector2:
		errors.append("%s walkable_areas[%d] has no Vector2 size." % [label, index])
		return PackedVector2Array()
	if size.x <= 0.0 or size.y <= 0.0:
		errors.append("%s walkable_areas[%d] has non-positive size." % [label, index])
	var rect := Rect2(Vector2(position), Vector2(size)).abs()
	if rect.position.x < map.ground_min_x or rect.position.y < 0.0 or rect.end.x > map.length or rect.end.y > map.depth:
		errors.append("%s walkable_areas[%d] is outside map bounds." % [label, index])
	return PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	])


static func _validate_blocked_areas(map: MapData, label: String) -> Array[String]:
	var errors: Array[String] = []
	for index in range(map.blocked_areas.size()):
		var area = map.blocked_areas[index]
		if not area is Dictionary:
			errors.append("%s blocked_areas[%d] is not a Dictionary." % [label, index])
			continue
		var area_data: Dictionary = area
		var points = area_data.get("points", null)
		if points is Array:
			var polygon := PackedVector2Array()
			for point in points:
				if not point is Vector2:
					errors.append("%s blocked_areas[%d] has a non-Vector2 point." % [label, index])
					continue
				var blocked_point := Vector2(point)
				if blocked_point.x < map.ground_min_x or blocked_point.y < 0.0 or blocked_point.x > map.length or blocked_point.y > map.depth:
					errors.append("%s blocked_areas[%d] point %s is outside map bounds." % [label, index, str(blocked_point)])
				polygon.append(blocked_point)
			if polygon.size() < 3:
				errors.append("%s blocked_areas[%d] has fewer than 3 polygon points." % [label, index])
			elif Geometry2D.is_point_in_polygon(map.player_spawn, polygon):
				errors.append("%s player_spawn is inside blocked_areas[%d]." % [label, index])
			continue
		var position = area_data.get("position", null)
		var size = area_data.get("size", null)
		if not position is Vector2:
			errors.append("%s blocked_areas[%d] has no Vector2 position." % [label, index])
			continue
		if not size is Vector2:
			errors.append("%s blocked_areas[%d] has no Vector2 size." % [label, index])
			continue
		if size.x <= 0.0 or size.y <= 0.0:
			errors.append("%s blocked_areas[%d] has non-positive size." % [label, index])
		var rect := Rect2(Vector2(position), Vector2(size)).abs()
		if rect.position.x < map.ground_min_x or rect.position.y < 0.0 or rect.end.x > map.length or rect.end.y > map.depth:
			errors.append("%s blocked_areas[%d] is outside map bounds." % [label, index])
		if rect.has_point(map.player_spawn):
			errors.append("%s player_spawn is inside blocked_areas[%d]." % [label, index])
	return errors


static func _validate_map_visual(map: MapData, label: String) -> Array[String]:
	var errors: Array[String] = []
	var red_night := map.environment_theme == "RED_NIGHT"
	var scrolling := map.camera_mode == "SCROLLING"
	if red_night and scrolling and map.visual_data == null:
		errors.append("%s is a Red Night scrolling map but has no visual_data." % label)
	if map.visual_data == null:
		return errors
	for index in range(map.visual_data.background_layers.size()):
		if map.visual_data.background_layers[index] == null:
			errors.append("%s visual_data background_layers[%d] is empty." % [label, index])
	for index in range(map.visual_data.foreground_layers.size()):
		if map.visual_data.foreground_layers[index] == null:
			errors.append("%s visual_data foreground_layers[%d] is empty." % [label, index])
	if scrolling and red_night and map.visual_data.background_layers.is_empty():
		errors.append("%s Red Night visual_data has no background layers." % label)
	return errors


static func validate_directional_sequence(label: String, directory: String, frame_count: int) -> Array[String]:
	var errors: Array[String] = []
	for side in ["left", "right"]:
		for index in range(frame_count):
			var path := "%s/%s_%02d.png" % [directory, side, index]
			if not ResourceLoader.exists(path):
				errors.append("%s missing frame: %s" % [label, path])
	return errors


static func validate_directional_variant_sequence(label: String, directory: String, variant_count: int, frame_count: int) -> Array[String]:
	var errors: Array[String] = []
	for variant_index in range(variant_count):
		var variant_directory := "%s/variant_%02d" % [directory, variant_index]
		for side in ["left", "right"]:
			for frame_index in range(frame_count):
				var path := "%s/%s_%02d.png" % [variant_directory, side, frame_index]
				if not ResourceLoader.exists(path):
					errors.append("%s missing frame: %s" % [label, path])
	return errors


static func validate_specific_directional_variant_sequence(label: String, directory: String, variant_ids: Array[int], frame_count: int) -> Array[String]:
	var errors: Array[String] = []
	for variant_id in variant_ids:
		var variant_directory := "%s/variant_%02d" % [directory, variant_id]
		for side in ["left", "right"]:
			for frame_index in range(frame_count):
				var path := "%s/%s_%02d.png" % [variant_directory, side, frame_index]
				if not ResourceLoader.exists(path):
					errors.append("%s missing frame: %s" % [label, path])
	return errors


static func validate_frame_sequence(label: String, pattern: String, frame_count: int) -> Array[String]:
	var errors: Array[String] = []
	for index in range(frame_count):
		var path := pattern % [index, index] if pattern.count("%") >= 2 else pattern % index
		if not ResourceLoader.exists(path):
			errors.append("%s missing frame: %s" % [label, path])
	return errors


static func validate_effect_visual(visual_data: EffectVisualData, label: String) -> Array[String]:
	var errors: Array[String] = []
	if visual_data == null:
		return ["%s did not load as EffectVisualData." % label]
	var required_groups := {
		"red slash left": visual_data.claw_slash_red_left_frames,
		"red slash right": visual_data.claw_slash_red_right_frames,
		"silver slash left": visual_data.claw_slash_silver_left_frames,
		"silver slash right": visual_data.claw_slash_silver_right_frames,
		"zombie vertical attack left": visual_data.zombie_attack_vertical_red_left_frames,
		"zombie vertical attack right": visual_data.zombie_attack_vertical_red_right_frames,
		"knife horizontal attack left": visual_data.knife_attack_horizontal_silver_left_frames,
		"knife horizontal attack right": visual_data.knife_attack_horizontal_silver_right_frames,
		"virus mist hit": visual_data.virus_mist_hit_frames,
		"virus liquid spread": visual_data.virus_liquid_spread_frames,
		"atomization fog dense": visual_data.atomization_fog_dense_frames,
		"atomization fog subtle": visual_data.atomization_fog_subtle_frames,
	}
	for group_name in required_groups:
		var frames: Array = required_groups[group_name]
		if frames.is_empty():
			errors.append("%s has no %s frames." % [label, group_name])
		for index in range(frames.size()):
			if frames[index] == null:
				errors.append("%s %s frame %d is empty." % [label, group_name, index])
	if visual_data.red_night_classroom_chase == null:
		errors.append("%s has no red_night_classroom_chase texture." % label)
	return errors


static func validate_intake_layers() -> Array[String]:
	var errors: Array[String] = []
	for region in ["belly"]:
		for tier in range(1, 5):
			for state in ["idle", "walk_left", "walk_right"]:
				for index in range(4):
					var path := "res://assets/sprites/linxi/t_early/intake_layers/%s/tier_%d/%s_%02d.png" % [region, tier, state, index]
					if not ResourceLoader.exists(path):
						errors.append("Linxi intake layer missing frame: %s" % path)
	return errors


static func validate_linxi_runtime_sprite_metrics() -> Array[String]:
	var errors: Array[String] = []
	for index in range(4):
		errors.append_array(validate_texture_used_rect("Linxi idle %02d" % index, "res://assets/sprites/linxi/t_early/weak_idle/%02d_idle_%02d.png" % [index, index], 212, 222, 245, 0))
	for side in ["left", "right"]:
		for index in range(16):
			errors.append_array(validate_texture_used_rect("Linxi walk %s %02d" % [side, index], "res://assets/sprites/linxi/t_early/walk_horizontal/%s_%02d.png" % [side, index], 212, 220, 245, 0))
		for index in range(8):
			errors.append_array(validate_texture_used_rect("Linxi sprint %s %02d" % [side, index], "res://assets/sprites/linxi/t_early/sprint_horizontal/%s_%02d.png" % [side, index], 202, 208, 235, 0))
	errors.append_array(validate_texture_used_rect("Linxi get-up final standing", "res://assets/sprites/linxi/t_early/story/get_up/05_get_up.png", 212, 222, 245, 0))
	return errors


static func validate_texture_used_rect(label: String, path: String, min_height: int, max_height: int, expected_bottom: int, bottom_tolerance: int) -> Array[String]:
	var errors: Array[String] = []
	var image := Image.new()
	var err := image.load(ProjectSettings.globalize_path(path))
	if err != OK:
		errors.append("%s failed to load image for bounds validation: %s" % [label, path])
		return errors
	var rect := image.get_used_rect()
	if rect.size.x <= 0 or rect.size.y <= 0:
		errors.append("%s has no visible pixels: %s" % [label, path])
		return errors
	var bottom := rect.position.y + rect.size.y
	if rect.size.y < min_height or rect.size.y > max_height:
		errors.append("%s height %d is outside locked range %d-%d: %s" % [label, rect.size.y, min_height, max_height, path])
	if abs(bottom - expected_bottom) > bottom_tolerance:
		errors.append("%s bottom anchor %d expected %d (+/-%d): %s" % [label, bottom, expected_bottom, bottom_tolerance, path])
	return errors


static func _validate_enemies(map: MapData, label: String) -> Array[String]:
	var errors: Array[String] = []
	var ids := {}
	for index in range(map.enemy_spawns.size()):
		var enemy = map.enemy_spawns[index]
		if not enemy is Dictionary:
			errors.append("%s enemy_spawns[%d] is not a Dictionary." % [label, index])
			continue
		var id := String(enemy.get("id", "")).strip_edges()
		if id.is_empty():
			errors.append("%s enemy_spawns[%d] has empty id." % [label, index])
		elif ids.has(id):
			errors.append("%s enemy id is duplicated: %s" % [label, id])
		else:
			ids[id] = true
		var family := String(enemy.get("family", "HUMAN")).to_upper()
		if not VALID_ENEMY_FAMILIES.has(family):
			errors.append("%s enemy %s has invalid family: %s" % [label, id, family])
		var state := String(enemy.get("initial_state", "APPROACH")).to_upper()
		if not VALID_ENEMY_STATES.has(state):
			errors.append("%s enemy %s has invalid initial_state: %s" % [label, id, state])
		var attack_type := String(enemy.get("attack_type", "NORMAL")).to_upper()
		if not VALID_ATTACK_TYPES.has(attack_type):
			errors.append("%s enemy %s has invalid attack_type: %s" % [label, id, attack_type])
		var ai_profile := String(enemy.get("ai_profile", "STANDARD")).to_upper()
		if not VALID_AI_PROFILES.has(ai_profile):
			errors.append("%s enemy %s has invalid ai_profile: %s" % [label, id, ai_profile])
		var position = enemy.get("position", null)
		if not position is Vector2:
			errors.append("%s enemy %s has no Vector2 position." % [label, id])
		elif position.x < map.ground_min_x or position.x > map.length or position.y < 0.0 or position.y > map.depth:
			errors.append("%s enemy %s position is outside map bounds." % [label, id])
		var story_group := String(enemy.get("story_group", "")).strip_edges()
		if map.story_id == "red_night" and not story_group.is_empty() and not RED_NIGHT_STORY_GROUPS.has(story_group):
			errors.append("%s enemy %s has unknown Red Night story_group: %s" % [label, id, story_group])
	return errors


static func _validate_items(map: MapData, label: String) -> Array[String]:
	var errors: Array[String] = []
	var ids := {}
	for index in range(map.items.size()):
		var item = map.items[index]
		if not item is Dictionary:
			errors.append("%s items[%d] is not a Dictionary." % [label, index])
			continue
		var id := String(item.get("id", "")).strip_edges()
		if id.is_empty():
			errors.append("%s items[%d] has empty id." % [label, index])
		elif ids.has(id):
			errors.append("%s item id is duplicated: %s" % [label, id])
		else:
			ids[id] = true
		var item_type := String(item.get("type", "dialogue"))
		if not VALID_ITEM_TYPES.has(item_type):
			errors.append("%s item %s has invalid type: %s" % [label, id, item_type])
		var position = item.get("position", null)
		if not position is Vector2:
			errors.append("%s item %s has no Vector2 position." % [label, id])
		elif position.x < map.ground_min_x or position.x > map.length or position.y < 0.0 or position.y > map.depth:
			errors.append("%s item %s position is outside map bounds." % [label, id])
		if item_type == "story":
			var event_id := String(item.get("event_id", "")).strip_edges()
			if event_id.is_empty():
				errors.append("%s story item %s has empty event_id." % [label, id])
			elif map.story_id == "red_night" and not RED_NIGHT_STORY_EVENTS.has(event_id):
				errors.append("%s story item %s has unknown Red Night event_id: %s" % [label, id, event_id])
		elif item_type == "dialogue":
			var dialogue = item.get("dialogue", [])
			if not dialogue is Array or dialogue.is_empty():
				errors.append("%s dialogue item %s has no dialogue lines." % [label, id])
			var avatar_path := String(item.get("avatar_path", "")).strip_edges()
			if not avatar_path.is_empty() and not _resource_or_file_exists(avatar_path):
				errors.append("%s dialogue item %s has missing avatar_path: %s" % [label, id, avatar_path])
			var speaker := String(item.get("speaker", "")).strip_edges().to_lower()
			var uses_builtin_avatar := speaker in ["linxi", "archive"]
			if avatar_path.is_empty() and not uses_builtin_avatar and not bool(item.get("allow_letter_avatar", false)):
				errors.append("%s dialogue item %s requires avatar_path or explicit allow_letter_avatar." % [label, id])
		elif item_type == "weapon":
			var weapon_id := String(item.get("weapon_id", "")).strip_edges()
			if weapon_id.is_empty():
				errors.append("%s weapon item %s has empty weapon_id." % [label, id])
	return errors


static func _resource_or_file_exists(path: String) -> bool:
	if ResourceLoader.exists(path):
		return true
	if path.begins_with("res://"):
		return FileAccess.file_exists(ProjectSettings.globalize_path(path))
	return FileAccess.file_exists(path)


static func _validate_item_visual(map: MapData, label: String) -> Array[String]:
	var errors: Array[String] = []
	var has_transition := false
	var has_chopper_nebulizer := false
	for item in map.items:
		if not item is Dictionary:
			continue
		if String(item.get("type", "")) == "transition":
			has_transition = true
		if String(item.get("id", "")) == "chopper_nebulizer":
			has_chopper_nebulizer = true
	if (has_transition or has_chopper_nebulizer) and map.item_visual_data == null:
		errors.append("%s has transition/nebulizer items but no item_visual_data." % label)
	if map.item_visual_data == null:
		return errors
	if has_chopper_nebulizer and map.item_visual_data.nebulizer_texture == null:
		errors.append("%s item_visual_data has no nebulizer_texture." % label)
	if has_transition and map.item_visual_data.transition_circle_frames.is_empty():
		errors.append("%s item_visual_data has no transition_circle_frames." % label)
	for index in range(map.item_visual_data.transition_circle_frames.size()):
		if map.item_visual_data.transition_circle_frames[index] == null:
			errors.append("%s item_visual_data transition_circle_frames[%d] is empty." % [label, index])
	for index in range(map.item_visual_data.prop_textures.size()):
		if map.item_visual_data.prop_textures[index] == null:
			var fallback_path := ""
			if index < map.item_visual_data.prop_paths.size():
				fallback_path = String(map.item_visual_data.prop_paths[index])
			if fallback_path.is_empty() or not _resource_or_file_exists(fallback_path):
				errors.append("%s item_visual_data prop[%d] has neither a texture nor a valid fallback path." % [label, index])
	return errors


static func _validate_red_night_requirements(map: MapData, label: String) -> Array[String]:
	var errors: Array[String] = []
	var groups := {}
	for enemy in map.enemy_spawns:
		if enemy is Dictionary:
			var group := String(enemy.get("story_group", "")).strip_edges()
			if not group.is_empty():
				groups[group] = true
	for group in RED_NIGHT_STORY_GROUPS:
		if not groups.has(group):
			errors.append("%s is missing Red Night story_group: %s" % [label, group])
	var events := {}
	for item in map.items:
		if item is Dictionary and String(item.get("type", "")) == "story":
			events[String(item.get("event_id", ""))] = true
	for event_id in RED_NIGHT_REQUIRED_EVENTS:
		if not events.has(event_id):
			errors.append("%s is missing Red Night story event item: %s" % [label, event_id])
	return errors
