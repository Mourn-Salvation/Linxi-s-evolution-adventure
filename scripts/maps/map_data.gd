class_name MapData
extends Resource

@export_group("Identity")
@export var map_id := "unnamed_map"
@export var display_name := "Unnamed Map"
@export var encounter_id := "unnamed_encounter"
@export_multiline var objective := "Complete the encounter."
@export var story_id := ""
@export var initial_body_attack_unlocked := true
@export_enum("EVALUATION", "RED_NIGHT") var environment_theme := "EVALUATION"
@export_enum("SCROLLING", "FIXED_ROOM") var camera_mode := "SCROLLING"
@export var visual_data: MapVisualData
@export_enum("WET", "CONCRETE", "MARBLE", "GRASS") var footstep_surface := "CONCRETE"

@export_group("Bounds")
@export_range(-50000.0, 0.0, 10.0) var ground_min_x := 0.0
@export_range(640.0, 50000.0, 10.0) var length := 1800.0
@export_range(120.0, 1000.0, 10.0) var depth := 280.0
@export var player_spawn := Vector2(130.0, 155.0)
@export var walkable_areas: Array[Dictionary] = []
@export var blocked_areas: Array[Dictionary] = []
@export var gameplay_screen_offset := Vector2.ZERO

@export_group("Content")
@export var enemy_spawns: Array[Dictionary] = []
@export var items: Array[Dictionary] = []
@export var item_visual_data: ItemVisualData
