class_name LevelData
extends Resource

@export_group("Identity")
@export var stage_id := "stage_00_unnamed"
@export var level_id := "level_00_unnamed"
@export_range(0, 99, 1) var level_index := 0
@export var display_name := "Unnamed Level"
@export_multiline var summary := ""

@export_group("Runtime Payload")
@export var map_data: MapData


func resolved_story_id() -> String:
	return map_data.story_id if map_data != null else ""


func resolved_objective() -> String:
	return map_data.objective if map_data != null else ""
