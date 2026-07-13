extends SceneTree

var failures := 0


func _initialize() -> void:
	var stage = load("res://scenes/main.tscn").instantiate()
	root.add_child(stage)
	await process_frame

	stage.player_ground = Vector2(220.0, 140.0)
	var hurt_origin: Vector2 = stage.player_ground
	stage.player_component.damage(2, {
		"position": Vector2(260.0, 140.0),
		"facing": -1.0,
	})
	expect_near(stage.player_hit_reaction_duration, 0.1, "Linxi hurt stun duration is 0.1s")
	expect_near(stage.player_hit_reaction_time, 0.1, "Linxi enters hurt stun")
	expect_near(stage.player_ground.x, hurt_origin.x, "Linxi does not slide backward when hit")
	expect_near(stage.player_ground.y, hurt_origin.y, "Linxi stays on the same lane when hit")

	stage.attack_cooldown = 0.0
	stage.combo_step = 0
	stage.combat_component.try_attack()
	expect_near(stage.attack_cooldown, 0.0, "hurt stun blocks body attacks")
	expect(stage.combo_step == 0, "hurt stun does not advance combo")

	stage.dodge_cooldown = 0.0
	stage.dodge_time = 0.0
	stage.player_height = 0.0
	stage.facing = 1.0
	stage.combat_component.try_dodge()
	expect(stage.dodge_time > 0.0, "dodge can cancel hurt stun")
	expect_near(stage.player_hit_reaction_time, 0.0, "dodge clears hurt stun")

	stage.dodge_time = 0.0
	stage.dodge_duration_current = 0.0
	stage.dodge_cooldown = 0.0
	stage.player_hit_reaction_time = 0.1
	stage.player_hurt_flash = 0.16
	stage.occupied_vore_capacity = 0
	stage.contained_prey_weight = 0.0
	stage.vore_capacity = 2
	stage.active_intake_route = "CORE"
	stage.hit_stop = 0.0
	stage.vore_execution_time = 0.0
	if stage.enemies.size() > 0:
		var target: Dictionary = stage.enemies[0]
		target["position"] = stage.player_ground + Vector2(24.0, 0.0)
		target["health"] = 0
		target["state"] = "KNOCKED_DOWN"
	stage.vore_component.try_vore()
	expect(stage.occupied_vore_capacity == 1, "Vore can cancel hurt stun")
	expect_near(stage.player_hit_reaction_time, 0.0, "Vore clears hurt stun")
	expect_near(stage.player_hurt_flash, 0.0, "Vore clears hurt flash")
	expect(stage.vore_execution_time > 0.0, "Vore starts execution freeze")
	expect(stage.hit_stop >= stage.vore_execution_time, "execution freeze stops the world")

	stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: player hit reaction cancel tests")
		quit(0)
	else:
		push_error("FAIL: %d player hit reaction cancel test(s)" % failures)
		quit(1)


func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)


func expect_near(actual: float, expected: float, label: String, epsilon := 0.0001) -> void:
	if absf(actual - expected) > epsilon:
		failures += 1
		push_error("%s: expected %.4f, got %.4f" % [label, expected, actual])
