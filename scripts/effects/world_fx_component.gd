extends Node

const DEPTH_AXIS := Vector2(-0.32, 0.86)
const NEBULIZER_FOG_OFFSETS := [
	Vector2(-96.0, -24.0),
	Vector2(86.0, -38.0),
	Vector2(-42.0, 66.0),
	Vector2(128.0, 42.0),
]

var host: Node2D
var player_message := ""
var player_message_time := 0.0
var player_message_duration := 1.35


func setup(value: Node) -> void:
	host = value as Node2D


func update_hit_effects(delta: float) -> void:
	player_message_time = maxf(player_message_time - delta, 0.0)
	if player_message_time <= 0.0:
		player_message = ""
	for index in range(host.hit_effects.size() - 1, -1, -1):
		var effect: Dictionary = host.hit_effects[index]
		effect["time"] = maxf(float(effect.get("time", 0.0)) - delta, 0.0)
		if float(effect["time"]) <= 0.0:
			host.hit_effects.remove_at(index)
		else:
			host.hit_effects[index] = effect


func show_player_message(message: String, duration := 1.35) -> void:
	player_message = message
	player_message_duration = maxf(duration, 0.1)
	player_message_time = player_message_duration


func draw_player_message(floor_position: Vector2) -> void:
	if player_message.is_empty() or player_message_time <= 0.0:
		return
	var alpha := clampf(player_message_time / minf(player_message_duration, 0.35), 0.0, 1.0)
	var font := ThemeDB.fallback_font
	var font_size := 16
	var text_size := font.get_string_size(player_message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var origin := floor_position + Vector2(-text_size.x * 0.5, -host.player_height - 152.0)
	for offset in [Vector2(-1.0, 0.0), Vector2(1.0, 0.0), Vector2(0.0, -1.0), Vector2(0.0, 1.0)]:
		host.draw_string(font, origin + offset, player_message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.02, 0.01, 0.015, alpha))
	host.draw_string(font, origin, player_message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.96, 0.72, 0.42, alpha))


func spawn_hit_effect(ground_position: Vector2, direction: float = 1.0) -> void:
	host.hit_effects.append({
		"kind": "BODY",
		"position": ground_position,
		"direction": direction,
		"time": 0.78,
		"duration": 0.78,
	})
	var residue_position := ground_position + Vector2(randf_range(-18.0, 18.0), randf_range(-10.0, 10.0))
	residue_position.x = clampf(residue_position.x, host.ground_min_x, host.ground_width)
	residue_position.y = clampf(residue_position.y, 0.0, host.ground_depth)
	var residue_duration := randf_range(2.0, 3.0)
	host.hit_effects.append({
		"kind": "GROUND",
		"position": residue_position,
		"direction": direction,
		"time": residue_duration,
		"duration": residue_duration,
		"scale": randf_range(0.48, 0.68),
		"angle": randf_range(-0.18, 0.18),
	})


func nebulizer_item() -> Dictionary:
	for item in host.scene_items:
		if String(item.get("id", "")) == "chopper_nebulizer":
			return item
	return {}


func build_contamination_mist_points() -> void:
	host.contamination_mist_points.clear()
	if host.map_data == null or String(host.map_data.environment_theme) != "RED_NIGHT":
		return
	var nebulizer := nebulizer_item()
	if nebulizer.is_empty():
		return
	var origin := Vector2(nebulizer["position"])
	var rng := RandomNumberGenerator.new()
	rng.seed = 0x4C49584E ^ int(origin.x * 17.0) ^ int(origin.y * 31.0) ^ int(host.ground_width)
	for index in range(NEBULIZER_FOG_OFFSETS.size()):
		var offset: Vector2 = NEBULIZER_FOG_OFFSETS[index] + Vector2(rng.randf_range(-18.0, 18.0), rng.randf_range(-10.0, 10.0))
		var position := origin + offset
		position.x = clampf(position.x, host.ground_min_x, host.ground_width)
		position.y = clampf(position.y, 0.0, host.ground_depth)
		var close_factor := clampf(1.0 - origin.distance_to(position) / 180.0, 0.0, 1.0)
		var alpha := lerpf(0.13, 0.19, close_factor) * rng.randf_range(0.92, 1.05)
		var radius := lerpf(92.0, 122.0, close_factor) * rng.randf_range(0.92, 1.10)
		var height := lerpf(96.0, 150.0, close_factor) * rng.randf_range(0.94, 1.08)
		host.contamination_mist_points.append({
			"position": position,
			"alpha": alpha,
			"radius": radius,
			"height": height,
			"scale_x": rng.randf_range(1.05, 1.42),
			"scale_y": rng.randf_range(0.72, 0.96),
			"screen_offset": Vector2(rng.randf_range(-18.0, 18.0), rng.randf_range(-42.0, -18.0)),
			"phase": rng.randf_range(0.0, TAU),
			"speed": rng.randf_range(0.18, 0.42),
			"drift": Vector2(rng.randf_range(-10.0, 10.0), rng.randf_range(-8.0, 8.0)),
		})


func draw_body_hit_effects() -> void:
	host.effect_renderer_component.draw_body_hit_effects(host.hit_effects, Callable(host, "_project_actor"))


func draw_ground_hit_effects() -> void:
	host.effect_renderer_component.draw_ground_hit_effects(host.hit_effects, Callable(host, "_project_actor"))


func draw_contamination_mist_field() -> void:
	var nebulizer := nebulizer_item()
	if nebulizer.is_empty() or bool(nebulizer.get("emptied", false)) or bool(host.story_flags.get("red_night_blue_stock_taken", false)):
		return
	host.effect_renderer_component.draw_contamination_mist_field(host.contamination_mist_points, 0.92, host.story_overlay, host.get_viewport_rect().size, Callable(host, "_project_actor"))


func draw_digest_bar(floor_position: Vector2) -> void:
	var bar_width := 110.0
	var bar_height := 12.0
	var bar_position := floor_position + Vector2(-bar_width * 0.5, -host.player_height - 125.0)
	var background := Rect2(bar_position, Vector2(bar_width, bar_height))
	host.draw_rect(background, Color(0.025, 0.035, 0.055, 0.92), true)
	host.draw_rect(background, Color(0.72, 0.82, 0.95, 0.9), false, 2.0)
	var fill_width: float = (bar_width - 4.0) * host.vore_component.digest_ratio()
	var fill_color := Color("74e08f") if host.digesting else Color("d3a94f")
	if fill_width > 0.0:
		host.draw_rect(Rect2(bar_position + Vector2(2.0, 2.0), Vector2(fill_width, bar_height - 4.0)), fill_color, true)
	if host.occupied_vore_capacity > 1:
		for slot in range(1, host.occupied_vore_capacity):
			var marker_x := bar_position.x + bar_width * float(slot) / float(host.occupied_vore_capacity)
			host.draw_line(Vector2(marker_x, bar_position.y + 1.0), Vector2(marker_x, bar_position.y + bar_height - 1.0), Color(0.92, 0.96, 1.0, 0.75), 1.0)


func draw_projected_belt() -> void:
	var viewport_width := host.get_viewport_rect().size.x
	var visible_start := clampf(host.camera_x - DEPTH_AXIS.x * host.ground_depth - 120.0, host.ground_min_x, host.ground_width)
	var visible_end := clampf(host.camera_x + viewport_width + 120.0, host.ground_min_x, host.ground_width)
	if host._is_fixed_room():
		visible_start = host.ground_min_x
		visible_end = host.ground_width
	var near_left: Vector2 = host._project_ground(Vector2(visible_start, 0.0))
	var near_right: Vector2 = host._project_ground(Vector2(visible_end, 0.0))
	var far_right: Vector2 = host._project_ground(Vector2(visible_end, host.ground_depth))
	var far_left: Vector2 = host._project_ground(Vector2(visible_start, host.ground_depth))
	var polygon := PackedVector2Array([near_left, near_right, far_right, far_left])
	var red_night := host.map_data != null and String(host.map_data.environment_theme) == "RED_NIGHT"
	if red_night and not host.development_mode:
		return
	var belt_color := Color("24141b") if red_night else (Color("2a252b") if host._is_fixed_room() else Color(0.12, 0.15, 0.23))
	belt_color.a = 0.30 if red_night else 1.0
	host.draw_colored_polygon(polygon, belt_color)
	if host.development_mode:
		for depth in range(0, int(host.ground_depth) + 1, 40):
			host.draw_line(host._project_ground(Vector2(visible_start, depth)), host._project_ground(Vector2(visible_end, depth)), Color(0.28, 0.34, 0.46, 0.32 if red_night else 1.0), 1.0)
		var first_grid_x := int(floor(visible_start / 100.0)) * 100
		for x in range(first_grid_x, int(visible_end) + 101, 100):
			host.draw_line(host._project_ground(Vector2(x, 0.0)), host._project_ground(Vector2(x, host.ground_depth)), Color(0.24, 0.30, 0.42, 0.24 if red_night else 1.0), 1.0)
		if visible_start <= 0.0:
			host.draw_line(host._project_ground(Vector2(0.0, 0.0)), host._project_ground(Vector2(0.0, host.ground_depth)), Color(0.38, 0.45, 0.62), 3.0)
		if visible_end >= host.ground_width:
			host.draw_line(host._project_ground(Vector2(host.ground_width, 0.0)), host._project_ground(Vector2(host.ground_width, host.ground_depth)), Color(0.38, 0.45, 0.62), 3.0)


func draw_combat_readability_layers() -> void:
	if host.story_control_locked or host.dialogue_active or host.player_defeated:
		return
	_draw_enemy_telegraph_zones()


func _draw_enemy_telegraph_zones() -> void:
	for enemy in host.enemies:
		var state := String(enemy.get("state", ""))
		if state != "TELEGRAPH" and state != "HEAVY_TELEGRAPH":
			continue
		var heavy := state == "HEAVY_TELEGRAPH"
		var fill := Color("bf45ff", 0.24) if heavy else Color("ff5c3c", 0.22)
		var outline := Color("e5a0ff", 0.72) if heavy else Color("ffb18d", 0.7)
		_draw_ground_zone(Vector2(enemy["position"]), "NEUTRAL", host.enemy_component.attack_range_for(enemy), host.enemy_component.depth_range_for(enemy), float(enemy.get("facing", -1.0)), host.enemy_shadow_radius(enemy), host.enemy_shadow_depth_radius(enemy), fill, outline)


func _draw_ground_zone(center: Vector2, tag: String, range_x: float, range_depth: float, direction: float, shadow_radius_x: float, shadow_radius_depth: float, fill: Color, outline: Color) -> void:
	var x0 := center.x - shadow_radius_x
	var x1 := center.x + shadow_radius_x
	var y0 := center.y - shadow_radius_depth - range_depth
	var y1 := center.y + shadow_radius_depth + range_depth
	match tag:
		"LEFT":
			x0 = center.x - shadow_radius_x - range_x
			x1 = center.x + shadow_radius_x
		"RIGHT":
			x0 = center.x - shadow_radius_x
			x1 = center.x + shadow_radius_x + range_x
		"UP":
			x0 = center.x - shadow_radius_x - range_x
			x1 = center.x + shadow_radius_x + range_x
			y0 = center.y - shadow_radius_depth - range_depth
			y1 = center.y + shadow_radius_depth
		"DOWN":
			x0 = center.x - shadow_radius_x - range_x
			x1 = center.x + shadow_radius_x + range_x
			y0 = center.y - shadow_radius_depth
			y1 = center.y + shadow_radius_depth + range_depth
		_:
			if direction >= 0.0:
				x0 = center.x - shadow_radius_x
				x1 = center.x + shadow_radius_x + range_x
			else:
				x0 = center.x - shadow_radius_x - range_x
				x1 = center.x + shadow_radius_x
	var min_x := clampf(minf(x0, x1), host.ground_min_x, host.ground_width)
	var max_x := clampf(maxf(x0, x1), host.ground_min_x, host.ground_width)
	var min_y := clampf(minf(y0, y1), 0.0, host.ground_depth)
	var max_y := clampf(maxf(y0, y1), 0.0, host.ground_depth)
	if max_x <= min_x or max_y <= min_y:
		return
	var polygon := PackedVector2Array([
		host._project_actor(Vector2(min_x, min_y)),
		host._project_actor(Vector2(max_x, min_y)),
		host._project_actor(Vector2(max_x, max_y)),
		host._project_actor(Vector2(min_x, max_y)),
	])
	host.draw_colored_polygon(polygon, fill)
	host.draw_polyline(PackedVector2Array([polygon[0], polygon[1], polygon[2], polygon[3], polygon[0]]), outline, 2.0)


func draw_shadow(at: Vector2, width: float) -> void:
	host.draw_set_transform(at)
	var alpha := clampf(0.38 - host.player_height / 1200.0, 0.16, 0.38) if width < 40.0 else 0.35
	host.draw_set_transform(at, 0.0, Vector2(1.0, 0.32))
	host.draw_circle(Vector2.ZERO, width, Color(0.0, 0.0, 0.0, alpha))
	host.draw_set_transform(Vector2.ZERO)
