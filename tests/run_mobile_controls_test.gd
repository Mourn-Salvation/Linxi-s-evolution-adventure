extends SceneTree

const RedNightScene = preload("res://scenes/red_night.tscn")


func _initialize() -> void:
	var stage = RedNightScene.instantiate()
	stage.load_saved_progress_on_start = false
	stage.force_mobile_controls = true
	root.add_child(stage)
	await process_frame
	var failures := 0
	if not stage.mobile_controls.visible:
		push_error("Forced mobile controls must be visible for desktop testing")
		failures += 1
	if stage.mobile_controls.get_child_count() != 6:
		push_error("Mobile overlay must provide one virtual joystick and F/J/K/L/V")
		failures += 1
	stage.story_control_locked = false
	stage.mobile_controls.set_direction_held(KEY_A, true)
	if stage.player_component.input_direction().x >= -0.9:
		push_error("Held mobile A must feed left movement")
		failures += 1
	if stage.combat_component.input_attack_tag() != "LEFT":
		push_error("Mobile direction must feed directional attacks")
		failures += 1
	stage.mobile_controls.set_direction_held(KEY_A, false)
	stage.mobile_controls.set_joystick_direction(Vector2(0.7, -0.7))
	var joystick_input: Vector2 = stage.player_component.input_direction()
	if joystick_input.x < 0.6 or joystick_input.y > -0.6:
		push_error("Virtual joystick must feed normalized diagonal movement")
		failures += 1
	if stage.combat_component.input_attack_tag() != "UP":
		push_error("Virtual joystick diagonals must preserve vertical-priority directional attacks")
		failures += 1
	stage.mobile_controls.set_joystick_direction(Vector2(0.49, 0.0))
	stage.player_component.move(0.0)
	if stage.movement_mode != "WALK":
		push_error("Virtual joystick at or below 50 percent must remain walking")
		failures += 1
	stage.mobile_controls.set_joystick_direction(Vector2(0.75, 0.0))
	stage.player_component.move(0.0)
	if stage.movement_mode != "SPRINT":
		push_error("Virtual joystick beyond 50 percent must sprint horizontally")
		failures += 1
	stage.mobile_controls.set_joystick_direction(Vector2(0.0, 0.9))
	stage.player_component.move(0.0)
	if stage.movement_mode != "WALK":
		push_error("Vertical joystick movement must never become a sprint")
		failures += 1
	stage.mobile_controls.set_joystick_direction(Vector2.ZERO)
	var mobile_j: Button = stage.mobile_controls.get_node("MobileJ") as Button
	if mobile_j.size.x < 105.0 or mobile_j.size.y < 105.0:
		push_error("Mobile action buttons must be enlarged by 50 percent")
		failures += 1
	stage.scene_items.clear()
	stage.scene_items.append({
		"id": "mobile_f_test_dialogue",
		"type": "dialogue",
		"name": "Test Speaker",
		"speaker": "Test Speaker",
		"allow_letter_avatar": true,
		"dialogue": ["First line", "Second line"],
		"position": stage.player_ground,
		"active": true,
	})
	stage.mobile_action_pressed("F")
	if not stage.dialogue_active or stage.dialogue_text_label.text != "First line":
		push_error("Mobile F must start a nearby interaction")
		failures += 1
	stage.mobile_action_pressed("F")
	if stage.dialogue_text_label.text != "Second line":
		push_error("Mobile F must advance active dialogue")
		failures += 1
	stage.dialogue_component.close()
	stage.enemy_contained = true
	stage.occupied_vore_capacity = 1
	stage.contained_prey_weight = 1.0
	stage.contained_route_loads["BELLY"] = 1
	stage.mobile_digest_held = true
	stage.vore_component.update_digest(0.1)
	if not stage.digesting or stage.digest_progress <= 0.0:
		push_error("Held mobile L must advance digestion")
		failures += 1
	stage.mobile_digest_held = false
	stage.vore_component.update_digest(0.0)
	if stage.digesting:
		push_error("Releasing mobile L must stop digestion")
		failures += 1
	stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: mobile controls feed movement, directional attack, and held digestion")
	quit(1 if failures > 0 else 0)
