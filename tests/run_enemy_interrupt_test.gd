extends SceneTree

var failures := 0


func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var stage = packed.instantiate()
	root.add_child(stage)
	await process_frame

	var normal: Dictionary = stage.enemies[0]
	normal["health"] = 8
	normal["state"] = "TELEGRAPH"
	normal["state_time"] = 0.42
	expect(stage.enemy_component.apply_hit_reaction(0, 0.1), "normal cast reports interruption")
	expect(normal["state"] == "STAGGER", "normal cast resets to stagger")
	expect(is_equal_approx(float(normal["state_time"]), 0.1), "normal cast timer resets")
	expect(is_equal_approx(float(normal["hit_reaction_time"]), float(normal["state_time"])), "normal cast cannot restart while hurt")

	var heavy: Dictionary = stage.enemies[1]
	heavy["health"] = 8
	heavy["state"] = "HEAVY_TELEGRAPH"
	heavy["state_time"] = 0.73
	expect(not stage.enemy_component.apply_hit_reaction(1, 0.1), "heavy cast reports armor")
	expect(heavy["state"] == "HEAVY_TELEGRAPH", "heavy cast state continues")
	expect(is_equal_approx(float(heavy["state_time"]), 0.73), "heavy cast timer continues")
	heavy["health"] = 0
	expect(stage.enemy_component.apply_hit_reaction(1, 0.1), "lethal hit overrides heavy armor")
	expect(heavy["state"] == "KNOCKED_DOWN", "lethal heavy cast is knocked down")

	var attacker: Dictionary = stage.enemies[0]
	attacker["health"] = 10
	attacker["state"] = "TELEGRAPH"
	attacker["attack_facing"] = 1.0
	attacker["position"] = Vector2(260.0, 120.0)
	stage.player_ground = attacker["position"] + Vector2(stage.balance.human_attack_range + stage.enemy_shadow_radius(attacker) + stage.player_shadow_radius() - 1.0, 0.0)
	stage.player_health = stage.player_max_health
	stage.player_invulnerability = 0.0
	stage.dodge_time = 0.0
	stage.enemy_component.resolve_human_attack(0)
	expect(stage.player_health == stage.player_max_health - stage.balance.unit_attack, "enemy attack reaches to player shadow edge")
	attacker["state"] = "TELEGRAPH"
	attacker["attack_facing"] = 1.0
	attacker["position"] = Vector2(260.0, 120.0)
	stage.player_ground = attacker["position"] + Vector2(stage.balance.human_attack_range + stage.enemy_shadow_radius(attacker) + stage.player_shadow_radius() + 1.0, 0.0)
	stage.player_health = stage.player_max_health
	stage.player_invulnerability = 0.0
	stage.dodge_time = 0.0
	stage.enemy_component.resolve_human_attack(0)
	expect(stage.player_health == stage.player_max_health, "enemy attack misses beyond combined shadow range")

	stage.queue_free()
	await process_frame

	var boss_packed: PackedScene = load("res://scenes/red_night_playground_return.tscn")
	var boss_stage = boss_packed.instantiate()
	root.add_child(boss_stage)
	await process_frame
	var boss: Dictionary = boss_stage.enemies[0]
	boss["health"] = 20
	boss["state"] = "HEAVY_TELEGRAPH"
	boss["state_time"] = 0.2
	expect(not boss_stage.enemy_component.apply_hit_reaction(0, 0.1), "boss basic blade attack reports heavy armor")
	expect(boss["state"] == "HEAVY_TELEGRAPH", "boss basic blade attack cannot be staggered")
	boss["state"] = "SPECIAL_RUSH"
	boss["special_strike_time"] = 0.2
	expect(not boss_stage.enemy_component.apply_hit_reaction(0, 0.1), "boss blade rush reports heavy armor")
	expect(boss["state"] == "SPECIAL_RUSH", "boss blade rush cannot be staggered")
	boss_stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: enemy cast interruption tests")
		quit(0)
	else:
		push_error("FAIL: %d enemy cast interruption test(s)" % failures)
		quit(1)


func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)
