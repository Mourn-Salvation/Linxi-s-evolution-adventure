class_name StageData
extends Resource

@export_group("Identity")
@export var stage_id := "stage_00_unnamed"
@export_range(0, 99, 1) var stage_number := 0
@export var display_name := "Unnamed Stage"
@export_multiline var summary := ""

@export_group("Levels")
@export_range(0, 99, 1) var opening_level_index := 0
@export var levels: Array[Resource] = []


func opening_level() -> LevelData:
	if levels.is_empty():
		return null
	var index := clampi(opening_level_index, 0, levels.size() - 1)
	return levels[index] as LevelData


func level_by_id(level_id: String) -> LevelData:
	for level in levels:
		var data := level as LevelData
		if data != null and data.level_id == level_id:
			return data
	return null
