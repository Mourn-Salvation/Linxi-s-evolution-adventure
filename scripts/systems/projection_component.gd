extends Node

const GROUND_ORIGIN_X := 170.0
const GROUND_FRONT_SCREEN_MARGIN := 30.0
const CAMERA_DEAD_ZONE_LEFT_RATIO := 0.28
const CAMERA_DEAD_ZONE_RIGHT_RATIO := 0.72
const DEPTH_AXIS := Vector2(-0.32, 0.86)
const ACTOR_DEPTH_AXIS := Vector2(0.0, 0.86)

var host: Node


func setup(value: Node) -> void:
	host = value


func update_camera(_delta: float) -> void:
	if is_fixed_room():
		_set_camera_x(0.0)
		return
	var viewport_width := viewport_size().x
	var screen_x := ground_origin().x + _player_ground().x - _camera_x()
	var dead_zone_left := viewport_width * CAMERA_DEAD_ZONE_LEFT_RATIO
	var dead_zone_right := viewport_width * CAMERA_DEAD_ZONE_RIGHT_RATIO
	if screen_x < dead_zone_left:
		_set_camera_x(_camera_x() - (dead_zone_left - screen_x))
	elif screen_x > dead_zone_right:
		_set_camera_x(_camera_x() + (screen_x - dead_zone_right))
	_set_camera_x(clampf(_camera_x(), 0.0, camera_max_x()))


func camera_max_x() -> float:
	if is_fixed_room():
		return 0.0
	var viewport_width := viewport_size().x
	return maxf(_ground_width() - viewport_width + ground_origin().x + DEPTH_AXIS.x * _ground_depth(), 0.0)


func viewport_size() -> Vector2:
	return host.get_viewport().get_visible_rect().size


func is_fixed_room() -> bool:
	var data = _map_data()
	return data != null and String(data.get("camera_mode")) == "FIXED_ROOM"


func ground_origin() -> Vector2:
	var viewport_height := viewport_size().y
	if is_fixed_room():
		var viewport_width := viewport_size().x
		var projected_width: float = _ground_width() - _ground_min_x() - DEPTH_AXIS.x * _ground_depth()
		var origin_x: float = (viewport_width - projected_width) * 0.5 - _ground_min_x() - DEPTH_AXIS.x * _ground_depth()
		var origin_y: float = viewport_height - 110.0 - DEPTH_AXIS.y * _ground_depth()
		return Vector2(origin_x, origin_y)
	var origin_y: float = viewport_height - GROUND_FRONT_SCREEN_MARGIN - DEPTH_AXIS.y * _ground_depth()
	return Vector2(GROUND_ORIGIN_X, origin_y)


func project_ground(ground: Vector2) -> Vector2:
	return ground_origin() + Vector2(ground.x - _camera_x(), 0.0) + DEPTH_AXIS * ground.y + gameplay_screen_offset()


func project_actor(ground: Vector2) -> Vector2:
	return ground_origin() + Vector2(ground.x - _camera_x(), 0.0) + ACTOR_DEPTH_AXIS * ground.y + gameplay_screen_offset()


func gameplay_screen_offset() -> Vector2:
	var data = _map_data()
	if data == null:
		return Vector2.ZERO
	var offset = data.get("gameplay_screen_offset")
	return Vector2(offset) if offset is Vector2 else Vector2.ZERO


func map_walkable_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var data = _map_data()
	if data == null:
		return rects
	var areas = data.get("walkable_areas")
	if not (areas is Array):
		return rects
	for area in areas:
		if not (area is Dictionary):
			continue
		var area_data: Dictionary = area
		var position = area_data.get("position", null)
		var size = area_data.get("size", null)
		if position is Vector2 and size is Vector2:
			rects.append(Rect2(Vector2(position), Vector2(size)).abs())
	return rects


func map_walkable_polygons() -> Array[PackedVector2Array]:
	var polygons: Array[PackedVector2Array] = []
	var data = _map_data()
	if data == null:
		return polygons
	var areas = data.get("walkable_areas")
	if not (areas is Array):
		return polygons
	for area in areas:
		if not (area is Dictionary):
			continue
		var polygon := _walkable_area_polygon(area)
		if polygon.size() >= 3:
			polygons.append(polygon)
	return polygons


func map_blocked_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var data = _map_data()
	if data == null:
		return rects
	var areas = data.get("blocked_areas")
	if not (areas is Array):
		return rects
	for area in areas:
		if not (area is Dictionary):
			continue
		var area_data: Dictionary = area
		var position = area_data.get("position", null)
		var size = area_data.get("size", null)
		if position is Vector2 and size is Vector2:
			rects.append(Rect2(Vector2(position), Vector2(size)).abs())
	return rects


func map_blocked_polygons() -> Array[PackedVector2Array]:
	var polygons: Array[PackedVector2Array] = []
	var data = _map_data()
	if data == null:
		return polygons
	var areas = data.get("blocked_areas")
	if not (areas is Array):
		return polygons
	for area in areas:
		if not (area is Dictionary):
			continue
		var area_data: Dictionary = area
		if not area_data.has("points"):
			continue
		var polygon := _walkable_area_polygon(area_data)
		if polygon.size() >= 3:
			polygons.append(polygon)
	return polygons


func is_ground_walkable(position: Vector2) -> bool:
	var walkable_polygons := map_walkable_polygons()
	if walkable_polygons.is_empty():
		return position.x >= _ground_min_x() and position.x <= _ground_width() and position.y >= 0.0 and position.y <= _ground_depth()
	for polygon in walkable_polygons:
		if Geometry2D.is_point_in_polygon(position, polygon):
			return true
	return false


func is_ground_blocked(position: Vector2) -> bool:
	for rect in map_blocked_rects():
		if rect.has_point(position):
			return true
	for polygon in map_blocked_polygons():
		if Geometry2D.is_point_in_polygon(position, polygon):
			return true
	return false


func resolve_map_blockers(previous_position: Vector2, desired_position: Vector2) -> Vector2:
	var resolved := Vector2(clampf(desired_position.x, _ground_min_x(), _ground_width()), clampf(desired_position.y, 0.0, _ground_depth()))
	resolved = _resolve_walkable_areas(previous_position, resolved)
	for rect in map_blocked_rects():
		if not rect.has_point(resolved):
			continue
		var x_only := Vector2(resolved.x, previous_position.y)
		var y_only := Vector2(previous_position.x, resolved.y)
		if is_ground_walkable(x_only) and not rect.has_point(x_only):
			resolved = x_only
		elif is_ground_walkable(y_only) and not rect.has_point(y_only):
			resolved = y_only
		else:
			var left_push := absf(resolved.x - rect.position.x)
			var right_push := absf(rect.end.x - resolved.x)
			var top_push := absf(resolved.y - rect.position.y)
			var bottom_push := absf(rect.end.y - resolved.y)
			var min_push := minf(minf(left_push, right_push), minf(top_push, bottom_push))
			if min_push == left_push:
				resolved.x = rect.position.x
			elif min_push == right_push:
				resolved.x = rect.end.x
			elif min_push == top_push:
				resolved.y = rect.position.y
			else:
				resolved.y = rect.end.y
		resolved.x = clampf(resolved.x, _ground_min_x(), _ground_width())
		resolved.y = clampf(resolved.y, 0.0, _ground_depth())
		resolved = _resolve_walkable_areas(previous_position, resolved)
	for polygon in map_blocked_polygons():
		if not Geometry2D.is_point_in_polygon(resolved, polygon):
			continue
		var polygon_x_only := Vector2(resolved.x, previous_position.y)
		var polygon_y_only := Vector2(previous_position.x, resolved.y)
		if is_ground_walkable(polygon_x_only) and not is_ground_blocked(polygon_x_only):
			resolved = polygon_x_only
		elif is_ground_walkable(polygon_y_only) and not is_ground_blocked(polygon_y_only):
			resolved = polygon_y_only
		else:
			resolved = _nearest_point_on_polygon(resolved, polygon)
		resolved.x = clampf(resolved.x, _ground_min_x(), _ground_width())
		resolved.y = clampf(resolved.y, 0.0, _ground_depth())
		resolved = _resolve_walkable_areas(previous_position, resolved)
	return resolved


func _camera_x() -> float:
	return float(host.get("camera_x"))


func _set_camera_x(value: float) -> void:
	host.set("camera_x", value)


func _player_ground() -> Vector2:
	var value = host.get("player_ground")
	return Vector2(value) if value is Vector2 else Vector2.ZERO


func _ground_width() -> float:
	return float(host.get("ground_width"))


func _ground_min_x() -> float:
	return float(host.get("ground_min_x"))


func _ground_depth() -> float:
	return float(host.get("ground_depth"))


func _map_data():
	return host.get("map_data")


func _resolve_walkable_areas(previous_position: Vector2, desired_position: Vector2) -> Vector2:
	var walkable_polygons := map_walkable_polygons()
	if walkable_polygons.is_empty() or is_ground_walkable(desired_position):
		return desired_position
	var x_only := Vector2(desired_position.x, previous_position.y)
	var y_only := Vector2(previous_position.x, desired_position.y)
	if is_ground_walkable(x_only):
		return x_only
	if is_ground_walkable(y_only):
		return y_only
	if is_ground_walkable(previous_position):
		return previous_position
	return _nearest_point_on_walkable_polygons(desired_position, walkable_polygons)


func _walkable_area_polygon(area: Dictionary) -> PackedVector2Array:
	var points = area.get("points", null)
	if points is Array:
		var polygon := PackedVector2Array()
		for point in points:
			if point is Vector2:
				polygon.append(Vector2(point))
		if polygon.size() >= 3:
			return polygon
	var position = area.get("position", null)
	var size = area.get("size", null)
	if position is Vector2 and size is Vector2:
		var rect := Rect2(Vector2(position), Vector2(size)).abs()
		return PackedVector2Array([
			rect.position,
			Vector2(rect.end.x, rect.position.y),
			rect.end,
			Vector2(rect.position.x, rect.end.y),
		])
	return PackedVector2Array()


func _nearest_point_on_walkable_polygons(point: Vector2, polygons: Array[PackedVector2Array]) -> Vector2:
	var nearest := point
	var nearest_distance := INF
	for polygon in polygons:
		for index in range(polygon.size()):
			var start: Vector2 = polygon[index]
			var end: Vector2 = polygon[(index + 1) % polygon.size()]
			var candidate := _closest_point_on_segment(point, start, end)
			var distance := point.distance_squared_to(candidate)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = candidate
	return nearest


func _nearest_point_on_polygon(point: Vector2, polygon: PackedVector2Array) -> Vector2:
	var nearest := point
	var nearest_distance := INF
	for index in range(polygon.size()):
		var start: Vector2 = polygon[index]
		var end: Vector2 = polygon[(index + 1) % polygon.size()]
		var candidate := _closest_point_on_segment(point, start, end)
		var distance := point.distance_squared_to(candidate)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	return nearest


func _closest_point_on_segment(point: Vector2, start: Vector2, end: Vector2) -> Vector2:
	var segment := end - start
	var length_squared := segment.length_squared()
	if length_squared <= 0.0001:
		return start
	var t := clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
	return start + segment * t
