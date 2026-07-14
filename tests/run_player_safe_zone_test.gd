extends SceneTree

var failures := 0


func _initialize() -> void:
	var fixed_stage = load("res://scenes/red_night_teaching_building.tscn").instantiate()
	fixed_stage.load_saved_progress_on_start = false
	root.add_child(fixed_stage)
	await process_frame
	fixed_stage.story_control_locked = false
	fixed_stage.player_ground = Vector2(fixed_stage.ground_width, fixed_stage.ground_depth)
	fixed_stage._update_camera(0.0)
	fixed_stage.player_ground = fixed_stage.projection_component.constrain_player_to_safe_zone(fixed_stage.player_ground)
	_expect_inside_safe_zone(fixed_stage, "fixed-room lower-right edge")
	expect(fixed_stage.player_ground.x < fixed_stage.ground_width, "fixed-room safe zone prevents walking into its off-screen X tail")
	expect(fixed_stage.is_ground_walkable(fixed_stage.player_ground), "fixed-room correction remains on authored walkable ground")

	fixed_stage.player_ground = Vector2(fixed_stage.ground_min_x, 0.0)
	fixed_stage.player_ground = fixed_stage.projection_component.constrain_player_to_safe_zone(fixed_stage.player_ground)
	_expect_inside_safe_zone(fixed_stage, "fixed-room upper-left edge")
	var normal_safe: Rect2 = fixed_stage.player_safe_screen_rect()
	fixed_stage.g_mode = true
	var g_mode_safe: Rect2 = fixed_stage.player_safe_screen_rect()
	expect(g_mode_safe.position.x > normal_safe.position.x, "G mode receives a wider horizontal safe inset")
	expect(g_mode_safe.position.y > normal_safe.position.y, "G mode receives a taller upper safe inset")
	fixed_stage.queue_free()
	await process_frame

	var scrolling_stage = load("res://scenes/red_night.tscn").instantiate()
	scrolling_stage.load_saved_progress_on_start = false
	root.add_child(scrolling_stage)
	await process_frame
	scrolling_stage.story_control_locked = false
	scrolling_stage.player_ground = Vector2(scrolling_stage.ground_width, scrolling_stage.ground_depth)
	scrolling_stage._update_camera(0.0)
	scrolling_stage.player_ground = scrolling_stage.projection_component.constrain_player_to_safe_zone(scrolling_stage.player_ground)
	_expect_inside_safe_zone(scrolling_stage, "scrolling-map terminal edge")
	expect(scrolling_stage.player_ground.x < scrolling_stage.ground_width, "scrolling safe zone prevents the terminal actor overflow")
	expect(scrolling_stage.is_ground_walkable(scrolling_stage.player_ground), "scrolling correction remains in map bounds")
	scrolling_stage.queue_free()
	await process_frame

	if failures == 0:
		print("PASS: player screen safe zone")
		quit(0)
	else:
		push_error("FAIL: %d player safe-zone check(s)" % failures)
		quit(1)


func _expect_inside_safe_zone(stage: Node, label: String) -> void:
	var safe_rect: Rect2 = stage.player_safe_screen_rect()
	var screen_position: Vector2 = stage._project_actor(stage.player_ground)
	expect(screen_position.x >= safe_rect.position.x - 0.01, "%s stays inside left edge" % label)
	expect(screen_position.x <= safe_rect.end.x + 0.01, "%s stays inside right edge" % label)
	expect(screen_position.y >= safe_rect.position.y - 0.01, "%s stays inside top edge" % label)
	expect(screen_position.y <= safe_rect.end.y + 0.01, "%s stays inside bottom edge" % label)


func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)
