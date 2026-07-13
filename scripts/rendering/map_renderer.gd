extends Node

var host: Node2D
var missing_visual_warnings: Dictionary = {}


func setup(owner: Node) -> void:
	host = owner as Node2D


func clear_color(map_data: MapData, fixed_room: bool) -> Color:
	if map_data == null:
		return Color("111523")
	var visual_data: MapVisualData = map_data.visual_data
	if visual_data == null:
		if String(map_data.environment_theme) == "RED_NIGHT":
			return Color("13080d")
		return Color("19151b") if fixed_room else Color("111523")
	if String(map_data.environment_theme) == "RED_NIGHT":
		return visual_data.themed_clear_color
	return visual_data.fixed_room_clear_color if fixed_room else visual_data.scrolling_clear_color


func draw_background(viewport_size: Vector2, map_data: MapData, fixed_room: bool, camera_x: float, camera_range: float, ground_width: float, ground_depth: float, far_left: Vector2, far_right: Vector2, near_left: Vector2, near_right: Vector2) -> void:
	if fixed_room:
		_draw_fixed_room_background(viewport_size, map_data, ground_width, ground_depth, far_left, far_right, near_left, near_right)
		return
	var visual_data: MapVisualData = map_data.visual_data if map_data != null else null
	if visual_data != null and not visual_data.background_layers.is_empty():
		_draw_layered_background(viewport_size, visual_data, camera_x, camera_range)
		_draw_background_props(viewport_size, map_data, visual_data, camera_x, camera_range, ground_width)
		return
	_warn_missing_map_visual(map_data, "scrolling background")
	if _development_mode():
		_draw_fallback_scrolling_background(viewport_size, camera_x)


func draw_foreground(viewport_size: Vector2, map_data: MapData, fixed_room: bool, camera_x: float, camera_range: float) -> void:
	var visual_data: MapVisualData = map_data.visual_data if map_data != null else null
	if visual_data == null or visual_data.foreground_layers.is_empty():
		return
	if fixed_room:
		for texture in visual_data.foreground_layers:
			_draw_fixed_room_image(texture, viewport_size, visual_data, false)
		return
	var progress := _map_camera_progress(camera_x, camera_range)
	for texture in visual_data.foreground_layers:
		_draw_background_segment(texture, viewport_size, progress, 1.0, visual_data.scrolling_background_scale, visual_data.scrolling_background_offset, visual_data, false)


func _draw_fallback_scrolling_background(viewport_size: Vector2, camera_x: float) -> void:
	var far_offset := fposmod(-camera_x * 0.12, 420.0)
	var mid_offset := fposmod(-camera_x * 0.28, 260.0)
	for index in range(-1, int(viewport_size.x / 420.0) + 2):
		var x := far_offset + index * 420.0
		host.draw_rect(Rect2(x, 150.0, 250.0, 150.0), Color("182238"), true)
		host.draw_rect(Rect2(x + 55.0, 105.0, 105.0, 195.0), Color("1b2942"), true)
	for index in range(-1, int(viewport_size.x / 260.0) + 2):
		var x := mid_offset + index * 260.0
		host.draw_rect(Rect2(x, 225.0, 145.0, 75.0), Color("253049"), true)
		host.draw_line(Vector2(x + 20.0, 225.0), Vector2(x + 20.0, 175.0), Color("33415e"), 5.0)
	host.draw_line(Vector2(0.0, 299.0), Vector2(viewport_size.x, 299.0), Color("3a4968"), 3.0)


func _draw_layered_background(viewport_size: Vector2, visual_data: MapVisualData, camera_x: float, camera_range: float) -> void:
	var progress := _map_camera_progress(camera_x, camera_range)
	if visual_data.stitch_background_layers:
		_draw_stitched_background(viewport_size, visual_data, progress)
		return
	for index in range(visual_data.background_layers.size()):
		var texture := visual_data.background_layers[index]
		var alpha := visual_data.background_layer_alpha(index, progress)
		_draw_background_segment(texture, viewport_size, progress, alpha, visual_data.scrolling_background_scale, visual_data.scrolling_background_offset, visual_data, true)


func _map_camera_progress(camera_x: float, camera_range: float) -> float:
	return clampf(camera_x / maxf(camera_range, 1.0), 0.0, 1.0)


func _draw_background_segment(texture: Texture2D, viewport_size: Vector2, progress: float, alpha: float, scale_multiplier := 1.0, offset := Vector2.ZERO, visual_data: MapVisualData = null, fill_viewport := true) -> void:
	if texture == null or alpha <= 0.01:
		return
	var texture_size := texture.get_size()
	var scale := maxf(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y) * scale_multiplier
	var size := texture_size * scale
	var max_scroll := maxf(size.x - viewport_size.x, 0.0)
	var rect := Rect2(Vector2(-max_scroll * progress, (viewport_size.y - size.y) * 0.5) + offset, size)
	if fill_viewport and visual_data != null and visual_data.fill_viewport_with_scaled_backing and (size.x < viewport_size.x or size.y < viewport_size.y):
		_draw_viewport_backing(texture, viewport_size, progress, alpha, visual_data.viewport_backing_tint)
	host.draw_texture_rect(texture, rect, false, Color(1.0, 1.0, 1.0, alpha))


func _draw_stitched_background(viewport_size: Vector2, visual_data: MapVisualData, progress: float) -> void:
	var valid_layers: Array[Texture2D] = []
	var max_height := 1.0
	for texture in visual_data.background_layers:
		if texture == null:
			continue
		valid_layers.append(texture)
		max_height = maxf(max_height, texture.get_size().y)
	if valid_layers.is_empty():
		return
	var base_scale := viewport_size.y / max_height * visual_data.scrolling_background_scale
	var total_width := 0.0
	for texture in valid_layers:
		total_width += texture.get_size().x * base_scale
	if total_width <= 0.0:
		return
	var scroll := maxf(total_width - viewport_size.x, 0.0) * clampf(progress, 0.0, 1.0)
	var x := -scroll + visual_data.scrolling_background_offset.x
	var y := (viewport_size.y - max_height * base_scale) * 0.5 + visual_data.scrolling_background_offset.y
	if visual_data.fill_viewport_with_scaled_backing and total_width < viewport_size.x:
		_draw_viewport_backing(valid_layers[0], viewport_size, progress, 1.0, visual_data.viewport_backing_tint)
	for texture in valid_layers:
		var size := texture.get_size() * base_scale
		host.draw_texture_rect(texture, Rect2(Vector2(x, y), size), false, Color.WHITE)
		x += size.x


func _draw_background_props(viewport_size: Vector2, map_data: MapData, visual_data: MapVisualData, camera_x: float, camera_range: float, ground_width: float) -> void:
	if map_data == null or map_data.item_visual_data == null or not visual_data.stitch_background_layers:
		return
	var metrics := _stitched_metrics(viewport_size, visual_data)
	var total_width := float(metrics.get("total_width", 0.0))
	if total_width <= 0.0:
		return
	var progress := _map_camera_progress(camera_x, camera_range)
	var scroll := maxf(total_width - viewport_size.x, 0.0) * progress
	var viewport_scale := viewport_size.y / 720.0
	for item in map_data.items:
		if not (item is Dictionary):
			continue
		var item_data: Dictionary = item
		if not bool(item_data.get("background_prop", false)):
			continue
		var item_id := String(item_data.get("id", ""))
		var texture := map_data.item_visual_data.prop_texture(item_id)
		if texture == null:
			continue
		var anchor = item_data.get("background_anchor", item_data.get("position", Vector2.ZERO))
		if not (anchor is Vector2):
			continue
		var anchor_position := Vector2(anchor)
		var item_size := map_data.item_visual_data.prop_size(item_id) * viewport_scale
		var x := (anchor_position.x / maxf(ground_width, 1.0)) * total_width - scroll + visual_data.scrolling_background_offset.x
		var y := anchor_position.y * viewport_scale + visual_data.scrolling_background_offset.y
		host.draw_texture_rect(texture, Rect2(Vector2(x - item_size.x * 0.5, y - item_size.y), item_size), false, Color.WHITE)


func _stitched_metrics(viewport_size: Vector2, visual_data: MapVisualData) -> Dictionary:
	var max_height := 1.0
	var total_source_width := 0.0
	for texture in visual_data.background_layers:
		if texture == null:
			continue
		max_height = maxf(max_height, texture.get_size().y)
	for texture in visual_data.background_layers:
		if texture == null:
			continue
		total_source_width += texture.get_size().x
	var base_scale := viewport_size.y / max_height * visual_data.scrolling_background_scale
	return {
		"base_scale": base_scale,
		"total_width": total_source_width * base_scale,
		"max_height": max_height,
	}


func _draw_fixed_room_background(viewport_size: Vector2, map_data: MapData, _ground_width: float, _ground_depth: float, far_left: Vector2, far_right: Vector2, near_left: Vector2, near_right: Vector2) -> void:
	var visual_data: MapVisualData = map_data.visual_data if map_data != null else null
	if visual_data != null and not visual_data.background_layers.is_empty():
		_draw_fixed_room_image(visual_data.background_layers[0], viewport_size, visual_data, true)
		return
	_warn_missing_map_visual(map_data, "fixed-room background")
	if not _development_mode():
		return
	var room_left := minf(far_left.x, near_left.x) - 36.0
	var room_right := maxf(far_right.x, near_right.x) + 36.0
	var room_top := maxf(96.0, far_left.y - 230.0)
	var back_wall_bottom := far_left.y + 16.0
	host.draw_rect(Rect2(room_left, room_top, room_right - room_left, back_wall_bottom - room_top), Color("2a2028"), true)
	host.draw_rect(Rect2(room_left + 22.0, room_top + 22.0, room_right - room_left - 44.0, back_wall_bottom - room_top - 34.0), Color("362936"), false, 3.0)
	for x in range(int(room_left + 80.0), int(room_right - 40.0), 160):
		host.draw_rect(Rect2(float(x), room_top + 38.0, 52.0, 82.0), Color("151923"), true)
		host.draw_rect(Rect2(float(x) + 7.0, room_top + 45.0, 38.0, 68.0), Color("33404d"), false, 2.0)
	host.draw_rect(Rect2(room_left, back_wall_bottom - 10.0, room_right - room_left, 18.0), Color("17131a"), true)
	host.draw_line(far_left, far_right, Color("5b4c52", 0.7), 3.0)
	host.draw_line(near_left, near_right, Color("1b151b", 0.8), 4.0)
	var label_color := visual_data.fixed_room_label_color if visual_data != null else Color("c9b8ad", 0.82)
	host.draw_string(ThemeDB.fallback_font, Vector2(room_left + 28.0, room_top + 28.0), map_data.display_name if map_data != null else "Fixed Room", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, label_color)


func _draw_fixed_room_image(texture: Texture2D, viewport_size: Vector2, visual_data: MapVisualData = null, fill_viewport := true) -> void:
	if texture == null:
		return
	var texture_size := texture.get_size()
	var scale_multiplier: float = visual_data.fixed_room_background_scale if visual_data != null else 1.0
	var offset: Vector2 = visual_data.fixed_room_background_offset if visual_data != null else Vector2.ZERO
	var scale: float = minf(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y) * scale_multiplier
	var size := texture_size * scale
	var rect := Rect2((viewport_size - size) * 0.5 + offset, size)
	if fill_viewport and visual_data != null and visual_data.fill_viewport_with_scaled_backing and (size.x < viewport_size.x or size.y < viewport_size.y):
		_draw_viewport_backing(texture, viewport_size, 0.5, 1.0, visual_data.viewport_backing_tint)
	host.draw_texture_rect(texture, rect, false, Color.WHITE)


func _draw_viewport_backing(texture: Texture2D, viewport_size: Vector2, progress: float, alpha: float, tint: Color) -> void:
	if texture == null:
		return
	var texture_size := texture.get_size()
	var cover_scale := maxf(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	var cover_size := texture_size * cover_scale
	var cover_scroll := maxf(cover_size.x - viewport_size.x, 0.0)
	var cover_rect := Rect2(Vector2(-cover_scroll * clampf(progress, 0.0, 1.0), (viewport_size.y - cover_size.y) * 0.5), cover_size)
	var cover_tint := Color(tint.r, tint.g, tint.b, tint.a * alpha)
	host.draw_texture_rect(texture, cover_rect, false, cover_tint)


func _development_mode() -> bool:
	return host != null and bool(host.get("development_mode"))


func _warn_missing_map_visual(map_data: MapData, context: String) -> void:
	var map_id := String(map_data.map_id) if map_data != null else "unknown"
	var key := "%s:%s" % [map_id, context]
	if missing_visual_warnings.has(key):
		return
	missing_visual_warnings[key] = true
	push_warning("%s has no approved %s visual data. Runtime skips procedural placeholder art outside development mode." % [map_id, context])
