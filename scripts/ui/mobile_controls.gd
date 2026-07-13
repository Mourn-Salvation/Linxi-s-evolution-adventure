extends Control

const MobileJoystick = preload("res://scripts/ui/mobile_joystick.gd")

var host: Node
var held_directions := {KEY_A: false, KEY_D: false, KEY_W: false, KEY_S: false}
var joystick_direction := Vector2.ZERO
var joystick: Control
var active_joystick_key: Key = KEY_NONE


func setup(value: Node) -> void:
	host = value
	visible = bool(host.force_mobile_controls) or OS.get_name() == "Android"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_joystick()
	_build_action_button("J", Vector2(-287.5, -182.5))
	_build_action_button("K", Vector2(-177.5, -292.5))
	_build_action_button("L", Vector2(-177.5, -122.5), true)
	_build_action_button("V", Vector2(-117.5, -182.5))
	_build_action_button("F", Vector2(-407.5, -122.5))


func movement_vector() -> Vector2:
	var direction := joystick_direction
	if bool(held_directions[KEY_A]): direction.x -= 1.0
	if bool(held_directions[KEY_D]): direction.x += 1.0
	if bool(held_directions[KEY_W]): direction.y -= 1.0
	if bool(held_directions[KEY_S]): direction.y += 1.0
	return direction.limit_length(1.0)


func release_all() -> void:
	for keycode in held_directions:
		held_directions[keycode] = false
	joystick_direction = Vector2.ZERO
	active_joystick_key = KEY_NONE
	if is_instance_valid(joystick):
		joystick.release()
	if host != null:
		host.mobile_digest_held = false


func set_direction_held(keycode: Key, held: bool) -> void:
	if not held_directions.has(keycode):
		return
	held_directions[keycode] = held
	if held and host != null:
		host.mobile_direction_pressed(keycode)


func set_joystick_direction(value: Vector2) -> void:
	joystick_direction = value.limit_length(1.0)
	var next_key := _dominant_direction_key(joystick_direction)
	if next_key != KEY_NONE and next_key != active_joystick_key and host != null:
		host.mobile_direction_pressed(next_key)
	active_joystick_key = next_key


func _build_joystick() -> void:
	joystick = MobileJoystick.new()
	joystick.name = "VirtualJoystick"
	joystick.anchor_top = 1.0
	joystick.anchor_bottom = 1.0
	joystick.position = Vector2(45.0, -245.0)
	joystick.size = Vector2(150.0, 150.0)
	joystick.direction_changed.connect(set_joystick_direction)
	add_child(joystick)


func _dominant_direction_key(value: Vector2) -> Key:
	if value.length() < 0.25:
		return KEY_NONE
	if absf(value.x) >= absf(value.y):
		return KEY_D if value.x > 0.0 else KEY_A
	return KEY_S if value.y > 0.0 else KEY_W


func _build_action_button(text: String, bottom_offset: Vector2, hold_action := false) -> void:
	var button := _make_button(text, bottom_offset, true)
	if hold_action:
		button.button_down.connect(func() -> void:
			if host != null: host.mobile_digest_held = true
		)
		button.button_up.connect(func() -> void:
			if host != null:
				host.mobile_digest_held = false
				host.vore_component.exit_digest_mode()
		)
	else:
		button.pressed.connect(func() -> void:
			if host != null: host.mobile_action_pressed(text)
		)


func _make_button(text: String, bottom_offset: Vector2, right_anchored: bool) -> Button:
	var button := Button.new()
	button.name = "Mobile%s" % text
	button.text = text
	button.custom_minimum_size = Vector2(105.0, 105.0)
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.anchor_left = 1.0 if right_anchored else 0.0
	button.anchor_right = button.anchor_left
	button.position = bottom_offset
	button.size = Vector2(105.0, 105.0)
	button.modulate = Color(0.82, 0.92, 0.96, 0.72)
	button.add_theme_font_size_override("font_size", 34)
	button.focus_mode = Control.FOCUS_NONE
	add_child(button)
	return button
