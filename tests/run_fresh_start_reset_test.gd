extends SceneTree

const TEST_PATH := "user://fresh_start_reset_test.json"
var failures := 0


func _initialize() -> void:
	var global_path := ProjectSettings.globalize_path(TEST_PATH)
	if FileAccess.file_exists(global_path):
		DirAccess.remove_absolute(global_path)

	var stale_save := {
		"balance_version": 4,
		"biomass": 7.0,
		"player_max_health": 38,
		"vore_capacity": 9,
		"story_flags": {"red_night_blue_stock_taken": true},
		"encounter_state": {
			"map_id": "red_night_school_courtyard",
			"encounter_id": "red_night_01",
			"player_ground": [777.0, 222.0],
			"player_health": 2,
			"player_height": 0.0,
			"facing": -1.0,
			"clean_hits": 5,
			"evolved": true,
			"enemies": [],
			"items": [],
			"temporary_weapon": {},
			"contained_prey_weight": 0.0,
			"occupied_vore_capacity": 0,
			"contained_route_loads": {},
			"digest_progress": 0.0,
			"enemy_contained": false,
			"mission_complete": false,
			"story_state": {"phase": 8, "body_attack_unlocked": true, "body_weapon_name": "Controlled Claws"},
			"mission_progress": {"biomass": 9.0, "player_max_health": 14},
		},
	}
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(stale_save))
	file = null

	var stage = load("res://scenes/red_night.tscn").instantiate()
	stage.save_path_override = TEST_PATH
	root.add_child(stage)
	await process_frame

	expect(stage.story_component.phase == 0, "fresh start ignores stale story phase")
	expect(stage.player_ground == stage.player_spawn, "fresh start resets player position")
	expect(stage.player_health == stage.player_max_health, "fresh start resets player health")
	expect(stage.player_max_health == stage.balance.unit_health, "fresh start resets max HP to unit default")
	expect(is_equal_approx(stage.biomass, 0.0), "fresh start resets biomass")
	expect(stage.vore_capacity == 1, "fresh start resets vore capacity")
	expect(stage.story_flags.is_empty(), "fresh start ignores committed story flags")
	expect(not stage.evolved, "fresh start resets encounter combat state")
	expect(stage.story_control_locked and stage.story_pose == "STAND_UP", "fresh start begins with stand-up beat")
	var data = JSON.parse_string(FileAccess.get_file_as_string(TEST_PATH))
	expect(data is Dictionary and not data.has("encounter_state"), "fresh start clears stale encounter transaction")

	stage.queue_free()
	await process_frame
	if FileAccess.file_exists(global_path):
		DirAccess.remove_absolute(global_path)
	if failures == 0:
		print("PASS: fresh stage starts reset")
		quit(0)
	else:
		push_error("FAIL: %d fresh start reset test(s)" % failures)
		quit(1)


func expect(condition: bool, label: String) -> void:
	if condition:
		return
	failures += 1
	push_error(label)
