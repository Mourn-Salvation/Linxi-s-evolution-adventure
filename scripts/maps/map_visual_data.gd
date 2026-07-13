class_name MapVisualData
extends Resource

@export_group("Base Colors")
@export var scrolling_clear_color := Color("111523")
@export var fixed_room_clear_color := Color("19151b")
@export var themed_clear_color := Color("13080d")

@export_group("Scrolling Background")
@export var background_layers: Array[Texture2D] = []
@export var foreground_layers: Array[Texture2D] = []
@export var stitch_background_layers := false
@export var layer_fade_in_start: PackedFloat32Array = PackedFloat32Array([])
@export var layer_fade_in_end: PackedFloat32Array = PackedFloat32Array([])
@export var layer_fade_out_start: PackedFloat32Array = PackedFloat32Array([])
@export var layer_fade_out_end: PackedFloat32Array = PackedFloat32Array([])
@export_range(0.5, 1.25, 0.01) var scrolling_background_scale := 1.0
@export var scrolling_background_offset := Vector2.ZERO

@export_group("Viewport Fill")
@export var fill_viewport_with_scaled_backing := true
@export var viewport_backing_tint := Color(0.34, 0.34, 0.34, 0.72)

@export_group("Fixed Room Fallback")
@export var fixed_room_label_color := Color("c9b8ad", 0.82)
@export_range(0.4, 1.25, 0.01) var fixed_room_background_scale := 1.0
@export var fixed_room_background_offset := Vector2.ZERO


func background_layer_alpha(index: int, progress: float) -> float:
	var alpha := 1.0
	if index < layer_fade_in_start.size() and index < layer_fade_in_end.size():
		var fade_in_start := layer_fade_in_start[index]
		var fade_in_end := layer_fade_in_end[index]
		if fade_in_end > fade_in_start:
			alpha *= smoothstep(fade_in_start, fade_in_end, progress)
	if index < layer_fade_out_start.size() and index < layer_fade_out_end.size():
		var fade_out_start := layer_fade_out_start[index]
		var fade_out_end := layer_fade_out_end[index]
		if fade_out_end > fade_out_start:
			alpha *= 1.0 - smoothstep(fade_out_start, fade_out_end, progress)
	return clampf(alpha, 0.0, 1.0)
