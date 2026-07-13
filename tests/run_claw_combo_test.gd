extends SceneTree

var failures := 0


func _initialize() -> void:
	var stage = load("res://scenes/main.tscn").instantiate()
	root.add_child(stage)
	await process_frame

	stage.body_attack_unlocked = true
	stage.body_weapon = "claws"
	stage.biomass = 0.0
	stage.facing = 1.0
	stage.player_ground = Vector2(200.0, 120.0)
	stage.enemies[0]["position"] = stage.player_ground + Vector2(80.0, 0.0)
	stage.enemies[0]["state"] = "APPROACH"
	stage.enemies[0]["health"] = 10
	stage.enemies[0]["max_health"] = 10

	stage.combat_component.try_attack()
	expect_equal(stage.combo_step, 1, "first claw press uses combo stage one")
	expect_equal(int(stage.enemies[0]["health"]), 8, "first claw stage deals base damage")
	expect_near(stage.attack_cooldown, 0.3, "neutral claw stage uses faster commitment")
	expect(stage.attack_cooldown > 0.0, "claw attack starts commitment window")
	var locked_position: Vector2 = stage.player_ground
	stage.player_component.move(1.0)
	expect(stage.player_ground == locked_position, "Linxi movement is locked while attacking")
	expect(stage.movement_mode == "ATTACK", "attack commitment sets attack movement mode")
	expect_equal(stage.player_renderer_component._combo_stage_frame_index(6), 0, "stage one starts on first animation slice")

	stage.attack_cooldown = 0.0
	stage.combat_component.try_attack()
	expect_equal(stage.combo_step, 2, "second claw press uses combo stage two")
	expect_equal(int(stage.enemies[0]["health"]), 6, "second claw stage deals base damage")
	expect_near(stage.attack_cooldown, 0.3, "second neutral stage keeps faster commitment")
	expect_equal(stage.player_renderer_component._combo_stage_frame_index(6), 2, "stage two starts on second animation slice")

	stage.attack_cooldown = 0.0
	stage.combat_component.try_attack()
	expect_equal(stage.combo_step, 3, "third claw press uses combo stage three")
	expect_equal(int(stage.enemies[0]["health"]), 4, "third claw stage deals base damage")
	expect_near(stage.attack_cooldown, 0.3, "third neutral stage keeps faster commitment")
	expect_equal(stage.player_renderer_component._combo_stage_frame_index(6), 4, "stage three starts on third animation slice")

	stage.attack_cooldown = 0.0
	stage.evolved = true
	stage.combat_component.try_attack()
	expect_near(stage.attack_cooldown, 0.165, "evolved claw stage remains accelerated")

	var neutral_attack = stage.combat_component.attack_for_tag("NEUTRAL")
	var shadow_aware_range: float = neutral_attack.range_x + stage.player_shadow_radius() + stage.enemy_shadow_radius(stage.enemies[0])
	stage.evolved = false
	stage.combo_step = 0
	stage.attack_cooldown = 0.0
	stage.enemies[0]["health"] = 10
	stage.enemies[0]["position"] = stage.player_ground + Vector2(shadow_aware_range - 1.0, 0.0)
	stage.combat_component.try_attack()
	expect_equal(int(stage.enemies[0]["health"]), 8, "player attack reaches to enemy shadow edge")
	stage.attack_cooldown = 0.0
	stage.enemies[0]["health"] = 10
	stage.enemies[0]["position"] = stage.player_ground + Vector2(shadow_aware_range + 1.0, 0.0)
	stage.combat_component.try_attack()
	expect_equal(int(stage.enemies[0]["health"]), 10, "player attack misses beyond combined shadow range")

	stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: claw combo stage tests")
		quit(0)
	else:
		push_error("FAIL: %d claw combo stage test(s)" % failures)
		quit(1)


func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)


func expect_equal(actual, expected, label: String) -> void:
	if actual != expected:
		failures += 1
		push_error("%s: expected %s, got %s" % [label, expected, actual])


func expect_near(actual: float, expected: float, label: String, epsilon := 0.001) -> void:
	if absf(actual - expected) > epsilon:
		failures += 1
		push_error("%s: expected %.4f, got %.4f" % [label, expected, actual])
