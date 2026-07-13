extends SceneTree

const TEST_PATH := "user://linxi_encounter_test.json"
var failures := 0


func _initialize() -> void:
	if FileAccess.file_exists(TEST_PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	var packed: PackedScene = load("res://scenes/main.tscn")
	var stage = packed.instantiate()
	stage.save_path_override = TEST_PATH
	root.add_child(stage)
	await process_frame
	stage.player_ground = Vector2(444.0, 123.0)
	stage.player_health = 7
	stage.digest_progress = 2.25
	stage.contained_prey_weight = 3.0
	stage.occupied_vore_capacity = 3
	stage.enemy_contained = true
	stage.contained_route_loads["BELLY"] = 3
	stage.contained_route_loads["CHEST"] = 0
	stage.enemies[0]["health"] = 4
	stage.enemies[0]["state"] = "STAGGER"
	stage.scene_items[0]["active"] = false
	stage.biomass = 7.0
	stage.player_max_health = 14
	var committed := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	committed.store_string(JSON.stringify({"balance_version": 4, "biomass": 2.0, "player_max_health": 10}))
	committed = null
	stage.encounter_component.save_state()
	var before_settlement = JSON.parse_string(FileAccess.get_file_as_string(TEST_PATH))
	expect(is_equal_approx(float(before_settlement["biomass"]), 2.0), "autosave does not commit biomass")
	expect(int(before_settlement["player_max_health"]) == 10, "autosave does not commit max HP")
	expect(is_equal_approx(float(before_settlement["encounter_state"]["mission_progress"]["biomass"]), 7.0), "autosave stores provisional biomass")
	stage.player_ground = Vector2.ZERO
	stage.player_health = 1
	stage.digest_progress = 0.0
	stage.contained_prey_weight = 0.0
	stage.occupied_vore_capacity = 0
	stage.enemy_contained = false
	stage.vore_component.clear_route_loads()
	stage.enemies[0]["health"] = 10
	stage.enemies[0]["state"] = "APPROACH"
	stage.scene_items[0]["active"] = true
	expect(stage.encounter_component.load_state(), "encounter loads")
	expect(stage.player_ground == Vector2(444.0, 123.0), "player position restores")
	expect(stage.player_health == 7, "player health restores")
	expect(is_equal_approx(stage.digest_progress, 2.25), "digest progress restores")
	expect(is_equal_approx(stage.contained_prey_weight, 3.0), "undigested prey weight restores")
	expect(stage.occupied_vore_capacity == 3, "occupied capacity restores")
	expect(stage.enemy_contained, "contained state restores")
	expect(stage.contained_route_loads["BELLY"] == 3 and stage.contained_route_loads["CHEST"] == 0, "belly-only route loads restore")
	expect(stage.enemies[0]["health"] == 4 and stage.enemies[0]["state"] == "STAGGER", "enemy state restores")
	expect(not stage.scene_items[0]["active"], "item state restores")
	stage.encounter_component.mission_complete = true
	stage.encounter_component.commit_progress()
	var after_settlement = JSON.parse_string(FileAccess.get_file_as_string(TEST_PATH))
	expect(is_equal_approx(float(after_settlement["biomass"]), 7.0), "settlement commits biomass")
	expect(int(after_settlement["player_max_health"]) == 14, "settlement commits max HP")
	expect(not after_settlement.has("encounter_state"), "settlement clears encounter transaction")
	stage.biomass = 12.0
	stage.player_max_health = 18
	stage.encounter_component.save_state()
	stage.encounter_component.discard_provisional_progress()
	expect(is_equal_approx(stage.biomass, 7.0), "abandon restores committed biomass")
	expect(stage.player_max_health == 14, "abandon restores committed max HP")
	var after_abandon = JSON.parse_string(FileAccess.get_file_as_string(TEST_PATH))
	expect(not after_abandon.has("encounter_state"), "abandon clears encounter transaction")
	stage.queue_free()
	await process_frame
	if FileAccess.file_exists(TEST_PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	if failures == 0:
		print("PASS: active encounter save and restore")
		quit(0)
	else:
		push_error("FAIL: %d encounter save test(s)" % failures)
		quit(1)


func expect(condition: bool, label: String) -> void:
	if condition: return
	failures += 1
	push_error(label)
