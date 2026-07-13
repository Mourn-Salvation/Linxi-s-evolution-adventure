extends Control

signal retry_requested

var retry_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	hide()


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
		retry_requested.emit()
		get_viewport().set_input_as_handled()


func open() -> void:
	show()
	if retry_button != null:
		retry_button.grab_focus()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.015, 0.008, 0.012, 0.78)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var panel := Panel.new()
	panel.position = Vector2(390.0, 230.0)
	panel.size = Vector2(500.0, 250.0)
	add_child(panel)

	var title := Label.new()
	title.position = Vector2(34.0, 24.0)
	title.size = Vector2(432.0, 44.0)
	title.text = "LINXI IS DOWN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("d72f38"))
	panel.add_child(title)

	var body := Label.new()
	body.position = Vector2(42.0, 80.0)
	body.size = Vector2(416.0, 62.0)
	body.text = "Reload from this area's entry checkpoint?\nCommitted body and story progress will be preserved."
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_color_override("font_color", Color("e5d8d2"))
	panel.add_child(body)

	retry_button = Button.new()
	retry_button.position = Vector2(118.0, 164.0)
	retry_button.size = Vector2(264.0, 52.0)
	retry_button.text = "RETRY FROM AREA ENTRY"
	retry_button.pressed.connect(func() -> void: retry_requested.emit())
	panel.add_child(retry_button)

	var hint := Label.new()
	hint.position = Vector2(42.0, 220.0)
	hint.size = Vector2(416.0, 22.0)
	hint.text = "Enter / Space: Retry"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color("b79c87"))
	panel.add_child(hint)
