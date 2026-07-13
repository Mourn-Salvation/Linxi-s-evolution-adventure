extends SceneTree

var failures := 0

func _initialize() -> void:
	var stage = load("res://scenes/red_night.tscn").instantiate()
	root.add_child(stage)
	await process_frame

	expect(not stage.development_mode, "development mode defaults off")
	stage._refresh_hud_labels()
	expect(not stage.title_label.visible, "prototype title is hidden outside development mode")
	expect(not stage.health_label.visible, "debug threat label is hidden outside development mode")
	expect(not stage.player_health_label.visible, "debug player health label is hidden outside development mode")
	expect(stage.player_hud_component.visible, "visual player HUD is visible outside development mode")
	expect(not stage.controls_label.visible, "full control listing is hidden outside development mode")
	expect(not stage.status_label.visible, "textual status strip is hidden outside development mode")
	expect(stage.status_label.text.find("Height") == -1, "compact status hides height")
	expect(stage.status_label.text.find("Biomass") == -1, "compact status hides biomass")
	expect(stage.status_label.text.find("ATK") == -1, "compact status hides attack value")

	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_F10
	expect(not stage.debug_component.handle_key(event), "debug keys are ignored when development mode is off")
	var equal_event := InputEventKey.new()
	equal_event.pressed = true
	equal_event.keycode = KEY_EQUAL
	stage.biomass = 0.0
	stage._unhandled_key_input(equal_event)
	expect(is_equal_approx(stage.biomass, 0.0), "equals debug biomass key is ignored outside development mode")

	stage.development_mode = true
	stage._refresh_hud_labels()
	expect(stage.debug_component.handle_key(event), "debug keys work when development mode is on")
	stage._unhandled_key_input(equal_event)
	expect(is_equal_approx(stage.biomass, 10.0), "equals debug key increases biomass in development mode")
	expect(not stage.title_label.visible, "development mode does not restore the retired prototype title")
	expect(not stage.health_label.visible, "development mode keeps the retired threat label hidden")
	expect(not stage.player_health_label.visible, "development mode keeps the retired health label hidden")
	expect(stage.player_hud_component.visible, "development mode preserves the production player HUD")
	expect(not stage.controls_label.visible, "development mode keeps the retired control listing hidden")
	expect(not stage.status_label.visible, "development readouts stay in the placement overlay")
	expect(stage.dev_placement_overlay_enabled, "development placement overlay is available")

	stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: development mode gate tests")
		quit(0)
	else:
		push_error("FAIL: %d development mode gate test(s)" % failures)
		quit(1)

func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)
