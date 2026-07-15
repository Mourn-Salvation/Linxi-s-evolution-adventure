extends Control

const GameSessionData = preload("res://scripts/data/game_session.gd")

const OPENING_SCENE := "res://scenes/opening_intro.tscn"
const BACKGROUND: Texture2D = preload("res://assets/videos/opening_frames/image__00002/frame_001.jpg")
const WINDOW_SIZES: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]

var content_panel: Panel
var content_title: Label
var content_body: VBoxContainer
var confirmation: Panel
var confirmation_text: Label
var confirmation_action: Callable
var volume_slider: HSlider
var window_options: OptionButton


func _ready() -> void:
	GameSessionData.initialize()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if confirmation.visible:
			confirmation.visible = false
		elif content_panel.visible:
			content_panel.visible = false


func _build_ui() -> void:
	var background := TextureRect.new()
	background.texture = BACKGROUND
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(background)

	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.02, 0.035, 0.62)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var title := Label.new()
	title.text = "LINXI'S EVOLUTION ADVENTURE"
	title.position = Vector2(74.0, 72.0)
	title.size = Vector2(780.0, 62.0)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color("d7e6e3"))
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "MEMORY ACCESS // SELECT RECORD"
	subtitle.position = Vector2(78.0, 132.0)
	subtitle.size = Vector2(640.0, 32.0)
	subtitle.add_theme_color_override("font_color", Color("8ee9ff"))
	add_child(subtitle)

	var menu := VBoxContainer.new()
	menu.position = Vector2(82.0, 240.0)
	menu.size = Vector2(290.0, 360.0)
	menu.add_theme_constant_override("separation", 14)
	add_child(menu)
	_add_menu_button(menu, "NEW GAME", _open_new_game)
	_add_menu_button(menu, "LOAD GAME", _open_load_game)
	_add_menu_button(menu, "SAVE FILES", _open_save_management)
	_add_menu_button(menu, "SETTINGS", _open_settings)
	_add_menu_button(menu, "EXIT", _request_exit)

	content_panel = Panel.new()
	content_panel.position = Vector2(455.0, 170.0)
	content_panel.size = Vector2(735.0, 470.0)
	content_panel.visible = false
	add_child(content_panel)

	content_title = Label.new()
	content_title.position = Vector2(32.0, 22.0)
	content_title.size = Vector2(650.0, 42.0)
	content_title.add_theme_font_size_override("font_size", 25)
	content_title.add_theme_color_override("font_color", Color("8ee9ff"))
	content_panel.add_child(content_title)

	content_body = VBoxContainer.new()
	content_body.position = Vector2(32.0, 80.0)
	content_body.size = Vector2(670.0, 350.0)
	content_body.add_theme_constant_override("separation", 12)
	content_panel.add_child(content_body)

	confirmation = Panel.new()
	confirmation.position = Vector2(410.0, 250.0)
	confirmation.size = Vector2(460.0, 220.0)
	confirmation.visible = false
	add_child(confirmation)
	confirmation_text = Label.new()
	confirmation_text.position = Vector2(30.0, 28.0)
	confirmation_text.size = Vector2(400.0, 90.0)
	confirmation_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	confirmation_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation.add_child(confirmation_text)
	var yes := Button.new()
	yes.text = "YES"
	yes.position = Vector2(76.0, 145.0)
	yes.size = Vector2(130.0, 44.0)
	yes.pressed.connect(_confirm_action)
	confirmation.add_child(yes)
	var no := Button.new()
	no.text = "NO"
	no.position = Vector2(254.0, 145.0)
	no.size = Vector2(130.0, 44.0)
	no.pressed.connect(func() -> void: confirmation.visible = false)
	confirmation.add_child(no)


func _add_menu_button(parent: VBoxContainer, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(290.0, 52.0)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 19)
	button.pressed.connect(action)
	parent.add_child(button)


func _clear_content(title: String) -> void:
	content_title.text = title
	content_panel.visible = true
	for child in content_body.get_children():
		content_body.remove_child(child)
		child.queue_free()


func _open_new_game() -> void:
	_clear_content("NEW GAME // SELECT SAVE SLOT")
	for slot in range(1, GameSessionData.SAVE_SLOT_COUNT + 1):
		var summary := GameSessionData.slot_summary(slot)
		var button := Button.new()
		button.text = _slot_label(summary)
		button.custom_minimum_size = Vector2(650.0, 64.0)
		button.pressed.connect(_request_new_game.bind(slot))
		content_body.add_child(button)


func _open_load_game() -> void:
	_clear_content("LOAD GAME // COMMITTED CHECKPOINTS")
	var found := false
	for slot in range(1, GameSessionData.SAVE_SLOT_COUNT + 1):
		var summary := GameSessionData.slot_summary(slot)
		if not bool(summary["occupied"]):
			continue
		found = true
		var button := Button.new()
		button.text = _slot_label(summary)
		button.custom_minimum_size = Vector2(650.0, 64.0)
		button.pressed.connect(_load_slot.bind(slot))
		content_body.add_child(button)
	if not found:
		_add_info_label("No committed save data exists yet. Start a New Game.")


func _open_save_management() -> void:
	_clear_content("SAVE FILES // MANAGE RECORDS")
	for slot in range(1, GameSessionData.SAVE_SLOT_COUNT + 1):
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(650.0, 64.0)
		var label := Label.new()
		label.text = _slot_label(GameSessionData.slot_summary(slot))
		label.custom_minimum_size = Vector2(510.0, 60.0)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(label)
		var remove := Button.new()
		remove.text = "DELETE"
		remove.custom_minimum_size = Vector2(120.0, 48.0)
		remove.disabled = not GameSessionData.slot_exists(slot)
		remove.pressed.connect(_request_delete_slot.bind(slot))
		row.add_child(remove)
		content_body.add_child(row)


func _open_settings() -> void:
	_clear_content("SETTINGS // PRESENTATION")
	var window_label := Label.new()
	window_label.text = "Window Size"
	content_body.add_child(window_label)
	window_options = OptionButton.new()
	for size in WINDOW_SIZES:
		window_options.add_item("%dx%d" % [size.x, size.y])
	window_options.item_selected.connect(_on_window_size_selected)
	content_body.add_child(window_options)
	var current_size := DisplayServer.window_get_size()
	for index in range(WINDOW_SIZES.size()):
		if WINDOW_SIZES[index] == current_size:
			window_options.select(index)
			break
	var volume_label := Label.new()
	volume_label.text = "Master Volume"
	content_body.add_child(volume_label)
	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 100.0
	volume_slider.step = 1.0
	volume_slider.custom_minimum_size = Vector2(640.0, 36.0)
	var bus := AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus)) * 100.0
	volume_slider.value_changed.connect(_on_volume_changed)
	content_body.add_child(volume_slider)
	_add_info_label("These settings are shared with Memory Settings in the pause menu.")


func _add_info_label(value: String) -> void:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(650.0, 60.0)
	label.add_theme_color_override("font_color", Color("e8d7a5"))
	content_body.add_child(label)


func _slot_label(summary: Dictionary) -> String:
	var slot := int(summary["slot"])
	if not bool(summary["occupied"]):
		return "SLOT %d   //   EMPTY" % slot
	return "SLOT %d   //   %s   //   HP %d/%d   BIOMASS %.1f" % [slot, String(summary["location"]).to_upper(), int(summary["hp"]), int(summary["max_hp"]), float(summary["biomass"])]


func _request_new_game(slot: int) -> void:
	if GameSessionData.slot_exists(slot):
		_show_confirmation("Overwrite Slot %d? Existing progress in this slot will be replaced." % slot, _start_new_game.bind(slot))
	else:
		_start_new_game(slot)


func _start_new_game(slot: int) -> void:
	GameSessionData.begin_new_game(slot)
	get_tree().change_scene_to_file(OPENING_SCENE)


func _load_slot(slot: int) -> void:
	GameSessionData.select_slot(slot)
	get_tree().change_scene_to_file(GameSessionData.scene_for_slot(slot))


func _request_delete_slot(slot: int) -> void:
	_show_confirmation("Delete Slot %d? This cannot be undone." % slot, _delete_slot.bind(slot))


func _delete_slot(slot: int) -> void:
	GameSessionData.clear_slot(slot)
	_open_save_management()


func _request_exit() -> void:
	_show_confirmation("Exit Linxi's Evolution Adventure?", func() -> void: get_tree().quit())


func _show_confirmation(message: String, action: Callable) -> void:
	confirmation_text.text = message
	confirmation_action = action
	confirmation.visible = true


func _confirm_action() -> void:
	confirmation.visible = false
	if confirmation_action.is_valid():
		confirmation_action.call()


func _on_window_size_selected(index: int) -> void:
	if index < 0 or index >= WINDOW_SIZES.size():
		return
	DisplayServer.window_set_size(WINDOW_SIZES[index])
	DisplayServer.window_set_position((DisplayServer.screen_get_size() - WINDOW_SIZES[index]) / 2)
	GameSessionData.save_settings(WINDOW_SIZES[index], volume_slider.value if volume_slider != null else 100.0)


func _on_volume_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, -80.0 if value <= 0.0 else linear_to_db(value / 100.0))
	GameSessionData.save_settings(DisplayServer.window_get_size(), value)
