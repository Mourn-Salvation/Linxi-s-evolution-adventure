extends Node

var host: Node
var panel: PanelContainer
var label: Label
var selected_region := 0
const REGIONS := ["BELLY"]


func setup(value: Node) -> void:
	host = value
	panel = PanelContainer.new()
	panel.position = Vector2(910.0, 82.0)
	panel.custom_minimum_size = Vector2(345.0, 238.0)
	panel.visible = false
	label = Label.new()
	label.add_theme_font_size_override("font_size", 14)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label)
	host.get_node("HUD").add_child(panel)
	refresh()


func handle_key(event: InputEventKey) -> bool:
	if not bool(host.get("development_mode")): return false
	if event.keycode == KEY_F10:
		panel.visible = not panel.visible
		refresh()
		return true
	if not panel.visible: return false
	var decrement := event.shift_pressed
	match event.keycode:
		KEY_F5:
			host.biomass = host.balance.clamp_biomass(host.biomass + (-5.0 if decrement else 5.0))
		KEY_F6:
			host.permanent_weight = maxf(host.permanent_weight + (-5.0 if decrement else 5.0), 0.5)
		KEY_F7:
			host.vore_capacity = maxi(host.vore_capacity + (-1 if decrement else 1), 1)
		KEY_F8:
			var region: String = REGIONS[selected_region]
			host.contained_route_loads[region] = maxi(int(host.contained_route_loads[region]) + (-1 if decrement else 1), 0)
			host.occupied_vore_capacity = 0
			for count in host.contained_route_loads.values(): host.occupied_vore_capacity += int(count)
			host.contained_prey_weight = float(host.occupied_vore_capacity)
			host.enemy_contained = host.occupied_vore_capacity > 0
		KEY_F9:
			host.weight_speed_debuff_disabled = not host.weight_speed_debuff_disabled
		KEY_TAB:
			selected_region = (selected_region + 1) % REGIONS.size()
		KEY_DELETE:
			host.biomass = 0.0
			host.permanent_weight = 1.0
			host.vore_capacity = 1
			host.weight_speed_debuff_disabled = false
			host.vore_component.clear_route_loads()
			host.occupied_vore_capacity = 0
			host.contained_prey_weight = 0.0
			host.enemy_contained = false
		_:
			return false
	host.vore_component.save_progress()
	host.update_hud("Debug values updated.")
	refresh()
	host.queue_redraw()
	return true


func refresh() -> void:
	if label == null: return
	var region: String = REGIONS[selected_region]
	label.text = "DEBUG BALANCE [F10]\nBiomass %.1f | Weight %.1f\nATK %d | Scale %.2f | Capacity %d/%d\nWeight passive: %s\nRegion: %s (%d prey)\n\nF5 / Shift+F5  Biomass +/-5\nF6 / Shift+F6  Weight +/-5\nF7 / Shift+F7  Base capacity +/-1\nTab  Select region\nF8 / Shift+F8  Region prey +/-1\nF9  Toggle weight passive\nDelete  Reset debug progression" % [
		host.biomass,
		host.vore_component.current_weight(),
		host.balance.attack_damage(host.biomass),
		host.balance.growth_scale(host.biomass),
		host.occupied_vore_capacity,
		host.vore_component.effective_capacity(),
		"ON" if host.weight_speed_debuff_disabled else "OFF",
		region,
		int(host.contained_route_loads[region]),
	]


func draw_dev_placement_overlay(viewport_size: Vector2) -> void:
	if not bool(host.development_mode):
		return
	var safe_rect: Rect2 = host.player_safe_screen_rect()
	host.draw_rect(safe_rect, Color(0.2, 0.9, 1.0, 0.035), true)
	host.draw_rect(safe_rect, Color(0.35, 0.95, 1.0, 0.88), false, 2.0)
	var map_bounds := Rect2(Vector2(host.ground_min_x, 0.0), Vector2(host.ground_width - host.ground_min_x, host.ground_depth))
	_draw_ground_rect_overlay(map_bounds, Color(0.1, 0.45, 1.0, 0.08), Color(0.35, 0.75, 1.0, 0.72), 2.0)
	for polygon in host.map_walkable_polygons():
		_draw_ground_polygon_overlay(polygon, Color(0.15, 1.0, 0.42, 0.16), Color(0.2, 1.0, 0.52, 0.8), 2.0)
	for rect in host.map_blocked_rects():
		_draw_ground_rect_overlay(rect, Color(1.0, 0.08, 0.12, 0.22), Color(1.0, 0.16, 0.18, 0.92), 2.0)
	for polygon in host.map_blocked_polygons():
		_draw_ground_polygon_overlay(polygon, Color(1.0, 0.08, 0.12, 0.22), Color(1.0, 0.16, 0.18, 0.92), 2.0)

	var mouse_screen: Vector2 = host.get_viewport().get_mouse_position()
	var mouse_ground: Vector2 = _screen_to_actor_ground(mouse_screen)
	var clamped_ground := Vector2(clampf(mouse_ground.x, host.ground_min_x, host.ground_width), clampf(mouse_ground.y, 0.0, host.ground_depth))
	var axis_span_x := 180.0
	var axis_span_y := 96.0
	var x_start: Vector2 = host._project_actor(Vector2(clampf(clamped_ground.x - axis_span_x, host.ground_min_x, host.ground_width), clamped_ground.y))
	var x_end: Vector2 = host._project_actor(Vector2(clampf(clamped_ground.x + axis_span_x, host.ground_min_x, host.ground_width), clamped_ground.y))
	var y_start: Vector2 = host._project_actor(Vector2(clamped_ground.x, clampf(clamped_ground.y - axis_span_y, 0.0, host.ground_depth)))
	var y_end: Vector2 = host._project_actor(Vector2(clamped_ground.x, clampf(clamped_ground.y + axis_span_y, 0.0, host.ground_depth)))
	host.draw_line(x_start, x_end, Color(0.35, 0.95, 1.0, 0.96), 3.0)
	host.draw_line(y_start, y_end, Color(1.0, 0.75, 0.22, 0.96), 3.0)
	host.draw_circle(host._project_actor(clamped_ground), 5.0, Color(1.0, 1.0, 1.0, 0.95))

	var info := "DEV PLACEMENT\nMAP X %.1f  Y %.1f\nCLAMP X %.1f  Y %.1f\nwalkable: %s  blocked: %s" % [
		mouse_ground.x,
		mouse_ground.y,
		clamped_ground.x,
		clamped_ground.y,
		"YES" if host.is_ground_walkable(clamped_ground) else "NO",
		"YES" if host.is_ground_blocked(clamped_ground) else "NO",
	]
	var label_position: Vector2 = (mouse_screen + Vector2(18.0, -44.0)).clamp(Vector2(12.0, 48.0), viewport_size - Vector2(230.0, 72.0))
	host.draw_rect(Rect2(label_position - Vector2(8.0, 24.0), Vector2(230.0, 104.0)), Color(0.02, 0.025, 0.04, 0.78), true)
	host.draw_rect(Rect2(label_position - Vector2(8.0, 24.0), Vector2(230.0, 104.0)), Color(0.4, 0.9, 1.0, 0.74), false, 1.0)
	host.draw_multiline_string(ThemeDB.fallback_font, label_position, info, HORIZONTAL_ALIGNMENT_LEFT, 220.0, 12, 14, Color(0.88, 0.98, 1.0, 1.0))


func _draw_ground_rect_overlay(rect: Rect2, fill_color: Color, outline_color: Color, width: float = 1.0) -> void:
	var normalized := rect.abs()
	var p0: Vector2 = host._project_ground(normalized.position)
	var p1: Vector2 = host._project_ground(Vector2(normalized.end.x, normalized.position.y))
	var p2: Vector2 = host._project_ground(normalized.end)
	var p3: Vector2 = host._project_ground(Vector2(normalized.position.x, normalized.end.y))
	var polygon := PackedVector2Array([p0, p1, p2, p3])
	host.draw_colored_polygon(polygon, fill_color)
	host.draw_polyline(PackedVector2Array([p0, p1, p2, p3, p0]), outline_color, width)


func _draw_ground_polygon_overlay(polygon: PackedVector2Array, fill_color: Color, outline_color: Color, width: float = 1.0) -> void:
	if polygon.size() < 3:
		return
	var projected := PackedVector2Array()
	for point in polygon:
		projected.append(host._project_ground(point))
	host.draw_colored_polygon(projected, fill_color)
	projected.append(projected[0])
	host.draw_polyline(projected, outline_color, width)


func _screen_to_actor_ground(screen_position: Vector2) -> Vector2:
	var origin: Vector2 = host._project_actor(Vector2.ZERO)
	var x_axis: Vector2 = host._project_actor(Vector2(1.0, 0.0)) - origin
	var y_axis: Vector2 = host._project_actor(Vector2(0.0, 1.0)) - origin
	var determinant := x_axis.x * y_axis.y - x_axis.y * y_axis.x
	if absf(determinant) < 0.0001:
		return Vector2.ZERO
	var relative := screen_position - origin
	return Vector2(
		(relative.x * y_axis.y - relative.y * y_axis.x) / determinant,
		(x_axis.x * relative.y - x_axis.y * relative.x) / determinant
	)
