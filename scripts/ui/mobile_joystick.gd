extends Control

signal direction_changed(direction: Vector2)

@export var outer_radius := 75.0
@export var thumb_radius := 34.0
@export var dead_zone := 0.18

var direction := Vector2.ZERO
var active_touch_index := -1
var mouse_dragging := false


func _ready() -> void:
	custom_minimum_size = Vector2(outer_radius * 2.0, outer_radius * 2.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and active_touch_index < 0 and _contains_screen_point(touch.position):
			active_touch_index = touch.index
			_update_from_screen_point(touch.position)
			get_viewport().set_input_as_handled()
		elif not touch.pressed and touch.index == active_touch_index:
			active_touch_index = -1
			_set_direction(Vector2.ZERO)
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == active_touch_index:
			_update_from_screen_point(drag.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_button.pressed and _contains_screen_point(mouse_button.position):
			mouse_dragging = true
			_update_from_screen_point(mouse_button.position)
			get_viewport().set_input_as_handled()
		elif not mouse_button.pressed and mouse_dragging:
			mouse_dragging = false
			_set_direction(Vector2.ZERO)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and mouse_dragging:
		var mouse_motion := event as InputEventMouseMotion
		_update_from_screen_point(mouse_motion.position)
		get_viewport().set_input_as_handled()


func release() -> void:
	active_touch_index = -1
	mouse_dragging = false
	_set_direction(Vector2.ZERO)


func set_direction_for_test(value: Vector2) -> void:
	_set_direction(value.limit_length(1.0))


func _contains_screen_point(screen_point: Vector2) -> bool:
	var local_point: Vector2 = get_global_transform_with_canvas().affine_inverse() * screen_point
	return local_point.distance_to(size * 0.5) <= outer_radius * 1.18


func _update_from_screen_point(screen_point: Vector2) -> void:
	var local_point: Vector2 = get_global_transform_with_canvas().affine_inverse() * screen_point
	var raw_direction: Vector2 = (local_point - size * 0.5) / outer_radius
	var magnitude := raw_direction.length()
	if magnitude <= dead_zone:
		_set_direction(Vector2.ZERO)
		return
	var normalized_magnitude: float = inverse_lerp(dead_zone, 1.0, minf(magnitude, 1.0))
	_set_direction(raw_direction.normalized() * normalized_magnitude)


func _set_direction(value: Vector2) -> void:
	var next_direction := value.limit_length(1.0)
	if next_direction.is_equal_approx(direction):
		return
	direction = next_direction
	direction_changed.emit(direction)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, outer_radius, Color(0.04, 0.10, 0.13, 0.48))
	draw_arc(center, outer_radius - 2.0, 0.0, TAU, 64, Color(0.35, 0.88, 1.0, 0.72), 3.0, true)
	draw_circle(center + direction * (outer_radius - thumb_radius), thumb_radius, Color(0.16, 0.44, 0.53, 0.78))
	draw_arc(center + direction * (outer_radius - thumb_radius), thumb_radius - 2.0, 0.0, TAU, 48, Color(0.62, 0.96, 1.0, 0.92), 3.0, true)
