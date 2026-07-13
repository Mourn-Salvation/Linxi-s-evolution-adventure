extends SceneTree

var failures := 0


func _initialize() -> void:
	var stage = load("res://scenes/red_night.tscn").instantiate()
	stage.save_path_override = "user://digest_heal_test.json"
	root.add_child(stage)
	await process_frame
	stage.player_max_health = 12
	stage.player_health = 5
	stage.biomass = 0.0
	stage.contained_prey_weight = 4.0
	stage.occupied_vore_capacity = 1
	stage.enemy_contained = true
	stage.digesting = true
	stage.digest_progress = stage.vore_component.total_digest_duration()
	stage.contained_route_loads["BELLY"] = 1
	stage.enemies[0]["state"] = "CONTAINED"
	stage.vore_component.finish_digest()
	expect(stage.player_health == 6, "digestion restores 1 HP")
	expect(stage.player_max_health == 12, "digestion heal does not change max HP directly")
	expect(is_equal_approx(stage.biomass, 1.0), "digestion still converts biomass")
	expect(stage.occupied_vore_capacity == 0, "digestion frees capacity")
	stage.player_health = 5
	stage.biomass = 0.0
	stage.contained_prey_weight = 3.0
	stage.occupied_vore_capacity = 3
	stage.enemy_contained = true
	stage.digesting = true
	stage.digest_progress = stage.balance.digest_seconds_per_prey * 2.0
	stage.contained_route_loads["BELLY"] = 3
	stage.enemies[0]["state"] = "CONTAINED"
	stage.enemies[1]["state"] = "CONTAINED"
	stage.enemies[2]["state"] = "CONTAINED"
	stage.vore_component.resolve_completed_digest_progress()
	expect(stage.occupied_vore_capacity == 1, "partial digestion frees only completed prey")
	expect(stage.contained_route_loads["BELLY"] == 1, "partial digestion reduces belly form tier")
	expect(is_equal_approx(stage.contained_prey_weight, 1.0), "partial digestion preserves remaining prey weight")
	expect(stage.player_health == 7, "partial digestion heals per completed prey")
	expect(is_equal_approx(stage.biomass, 0.5), "partial digestion converts completed prey biomass")
	expect(stage.enemies[0]["state"] == "DIGESTED" and stage.enemies[1]["state"] == "DIGESTED" and stage.enemies[2]["state"] == "CONTAINED", "partial digestion digests two contained enemies")
	stage.vore_component.exit_digest_mode()
	expect(stage.occupied_vore_capacity == 1 and stage.enemy_contained, "releasing digest keeps remaining prey contained")
	stage.player_health = 5
	stage.biomass = 50.0
	stage.contained_prey_weight = 1.0
	stage.occupied_vore_capacity = 1
	stage.enemy_contained = true
	stage.digesting = true
	stage.digest_progress = stage.balance.digest_seconds_per_prey * 0.5
	stage.contained_route_loads["BELLY"] = 1
	stage.enemies[0]["state"] = "CONTAINED"
	stage.vore_component.resolve_completed_digest_progress()
	expect(stage.occupied_vore_capacity == 0, "max biomass halves digestion time")
	expect(stage.player_health == 6, "max biomass digestion still heals once")
	stage.player_health = stage.player_max_health
	stage.biomass = 0.0
	stage.contained_prey_weight = 1.0
	stage.occupied_vore_capacity = 1
	stage.enemy_contained = true
	stage.enemies[0]["state"] = "CONTAINED"
	stage.vore_component.finish_digest()
	expect(stage.player_health == stage.player_max_health, "digestion heal clamps to max HP")
	stage.queue_free()
	await process_frame
	var path := ProjectSettings.globalize_path("user://digest_heal_test.json")
	if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	if failures == 0:
		print("PASS: digestion heal")
		quit(0)
	else:
		push_error("FAIL: %d digestion heal test(s)" % failures)
		quit(1)


func expect(condition: bool, label: String) -> void:
	if condition:
		return
	failures += 1
	push_error(label)
