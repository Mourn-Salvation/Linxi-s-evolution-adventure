extends Control

const GameSessionData = preload("res://scripts/data/game_session.gd")

const PAUSE_BACKGROUND: Texture2D = preload("res://assets/backgrounds/safe_house/memory_classroom.png")
const TITLE_MENU_SCENE := "res://scenes/title_menu.tscn"
const PANEL_TARGET_POSITION := Vector2(330.0, 82.0)
const PANEL_START_POSITION := Vector2(330.0, -620.0)
const PANEL_SIZE := Vector2(620.0, 556.0)
const DROP_DURATION := 0.28
const WINDOW_SIZES: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]

var volume_slider: HSlider
var window_options: OptionButton
var panel: Panel
var dev_overlay_button: Button
var main_menu_confirmation: ConfirmationDialog
var drop_time := 0.0

func _ready() -> void:
	GameSessionData.initialize()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	mouse_filter = Control.MOUSE_FILTER_STOP
	anchors_preset = Control.PRESET_FULL_RECT
	_build_ui()
	_sync_current_settings()

func _process(delta: float) -> void:
	if panel == null or drop_time >= DROP_DURATION:
		return
	drop_time = minf(drop_time + delta, DROP_DURATION)
	var t := drop_time / DROP_DURATION
	var eased := 1.0 - pow(1.0 - t, 3.0)
	panel.position = PANEL_START_POSITION.lerp(PANEL_TARGET_POSITION, eased)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_resume_game()

func _build_ui() -> void:
	var background := TextureRect.new()
	background.name = "Background"
	background.texture = PAUSE_BACKGROUND
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(0.72, 0.82, 0.86, 1.0)
	add_child(background)

	var dim := ColorRect.new()
	dim.name = "Dim"
	dim.color = Color(0.02, 0.025, 0.04, 0.76)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	panel = Panel.new()
	panel.name = "Panel"
	panel.position = PANEL_START_POSITION
	panel.size = PANEL_SIZE
	add_child(panel)

	var title := Label.new()
	title.text = "MEMORY SETTINGS"
	title.offset_left = 38.0
	title.offset_top = 24.0
	title.offset_right = 560.0
	title.offset_bottom = 58.0
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("8ee9ff"))
	panel.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Game paused. Adjust presentation or review controls."
	subtitle.offset_left = 40.0
	subtitle.offset_top = 66.0
	subtitle.offset_right = 560.0
	subtitle.offset_bottom = 96.0
	subtitle.add_theme_color_override("font_color", Color("e8d7a5"))
	panel.add_child(subtitle)

	_add_section_label(panel, "Window Size", Vector2(42.0, 116.0))
	window_options = OptionButton.new()
	window_options.offset_left = 42.0
	window_options.offset_top = 148.0
	window_options.offset_right = 300.0
	window_options.offset_bottom = 184.0
	for size in WINDOW_SIZES:
		window_options.add_item("%dx%d" % [size.x, size.y])
	window_options.item_selected.connect(_on_window_size_selected)
	panel.add_child(window_options)

	_add_section_label(panel, "Master Volume", Vector2(342.0, 116.0))
	volume_slider = HSlider.new()
	volume_slider.offset_left = 342.0
	volume_slider.offset_top = 150.0
	volume_slider.offset_right = 565.0
	volume_slider.offset_bottom = 184.0
	volume_slider.min_value = 0.0
	volume_slider.max_value = 100.0
	volume_slider.step = 1.0
	volume_slider.value_changed.connect(_on_volume_changed)
	panel.add_child(volume_slider)

	_add_section_label(panel, "Key Binding Review", Vector2(42.0, 212.0))
	var bindings := Label.new()
	bindings.offset_left = 42.0
	bindings.offset_top = 246.0
	bindings.offset_right = 570.0
	bindings.offset_bottom = 410.0
	bindings.add_theme_font_size_override("font_size", 16)
	bindings.text = "WASD / Arrows: Move fake-3D belt\nA / D double tap: Sprint horizontally\nF: Interact / Continue dialogue\nJ: Attack or use temporary weapon\nK: Dodge\nV: Vore\nHold L: Digest\nSpace: Jump\nG: G mode when unlocked\nEnter: Settle completed mission"
	panel.add_child(bindings)

	var resume_button := Button.new()
	resume_button.name = "ResumeButton"
	resume_button.text = "Resume"
	resume_button.offset_left = 42.0
	resume_button.offset_top = 452.0
	resume_button.offset_right = 166.0
	resume_button.offset_bottom = 498.0
	resume_button.pressed.connect(_resume_game)
	panel.add_child(resume_button)

	var main_menu_button := Button.new()
	main_menu_button.name = "MainMenuButton"
	main_menu_button.text = "To Main Menu"
	main_menu_button.offset_left = 176.0
	main_menu_button.offset_top = 452.0
	main_menu_button.offset_right = 302.0
	main_menu_button.offset_bottom = 498.0
	main_menu_button.pressed.connect(_request_main_menu)
	panel.add_child(main_menu_button)

	dev_overlay_button = Button.new()
	dev_overlay_button.name = "DevOverlayButton"
	dev_overlay_button.text = "Dev Overlay"
	dev_overlay_button.offset_left = 312.0
	dev_overlay_button.offset_top = 452.0
	dev_overlay_button.offset_right = 428.0
	dev_overlay_button.offset_bottom = 498.0
	dev_overlay_button.visible = _host_development_mode()
	dev_overlay_button.pressed.connect(_toggle_dev_overlay)
	panel.add_child(dev_overlay_button)

	var exit_button := Button.new()
	exit_button.name = "ExitButton"
	exit_button.text = "Exit Game"
	exit_button.offset_left = 438.0
	exit_button.offset_top = 452.0
	exit_button.offset_right = 565.0
	exit_button.offset_bottom = 498.0
	exit_button.pressed.connect(_exit_game)
	panel.add_child(exit_button)

	main_menu_confirmation = ConfirmationDialog.new()
	main_menu_confirmation.name = "MainMenuConfirmation"
	main_menu_confirmation.title = "Return to Main Menu"
	main_menu_confirmation.dialog_text = "Return to the main menu? Progress since the last committed map transition or shelter will be discarded."
	main_menu_confirmation.ok_button_text = "Main Menu"
	main_menu_confirmation.cancel_button_text = "Stay"
	main_menu_confirmation.confirmed.connect(_return_to_main_menu)
	add_child(main_menu_confirmation)

	var footer := Label.new()
	footer.text = "Esc: Resume"
	footer.offset_left = 42.0
	footer.offset_top = 512.0
	footer.offset_right = 565.0
	footer.offset_bottom = 540.0
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	footer.add_theme_color_override("font_color", Color("f3c66f"))
	panel.add_child(footer)

func _add_section_label(parent: Node, text: String, position: Vector2) -> void:
	var label := Label.new()
	label.text = text
	label.offset_left = position.x
	label.offset_top = position.y
	label.offset_right = position.x + 240.0
	label.offset_bottom = position.y + 28.0
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("f3c66f"))
	parent.add_child(label)

func _sync_current_settings() -> void:
	var current_size := DisplayServer.window_get_size()
	var selected := 0
	for index in range(WINDOW_SIZES.size()):
		if WINDOW_SIZES[index] == current_size:
			selected = index
			break
	window_options.select(selected)

	var bus := AudioServer.get_bus_index("Master")
	var db := AudioServer.get_bus_volume_db(bus)
	volume_slider.value = clampf(db_to_linear(db) * 100.0, 0.0, 100.0)

func _on_window_size_selected(index: int) -> void:
	if index < 0 or index >= WINDOW_SIZES.size():
		return
	DisplayServer.window_set_size(WINDOW_SIZES[index])
	DisplayServer.window_set_position((DisplayServer.screen_get_size() - WINDOW_SIZES[index]) / 2)
	GameSessionData.save_settings(WINDOW_SIZES[index], volume_slider.value)

func _on_volume_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	if value <= 0.0:
		AudioServer.set_bus_volume_db(bus, -80.0)
	else:
		AudioServer.set_bus_volume_db(bus, linear_to_db(value / 100.0))
	GameSessionData.save_settings(DisplayServer.window_get_size(), value)


func _host_development_mode() -> bool:
	var host := get_parent()
	if host == null:
		return false
	var value = host.get("development_mode")
	return value is bool and value


func _toggle_dev_overlay() -> void:
	var host := get_parent()
	if host != null and host.has_method("toggle_dev_placement_overlay"):
		host.toggle_dev_placement_overlay()
	_resume_game()


func _request_main_menu() -> void:
	main_menu_confirmation.popup_centered(Vector2i(560, 210))


func _return_to_main_menu() -> void:
	var host := get_parent()
	if host != null:
		var encounter := host.get_node_or_null("Components/Encounter")
		if encounter != null and encounter.has_method("discard_provisional_progress"):
			encounter.discard_provisional_progress()
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_MENU_SCENE)


func _resume_game() -> void:
	get_tree().paused = false
	queue_free()

func _exit_game() -> void:
	get_tree().quit()
