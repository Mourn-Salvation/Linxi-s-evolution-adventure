extends SceneTree

const RedNightScene = preload("res://scenes/red_night.tscn")


func _initialize() -> void:
	var stage = RedNightScene.instantiate()
	stage.load_saved_progress_on_start = false
	stage.save_path_override = "user://player_defeat_retry_test.json"
	root.add_child(stage)
	await process_frame
	stage.biomass = 7.0
	stage.player_health = 6
	stage.save_map_switch_checkpoint(stage.scene_file_path, "Current Area", false, stage.player_spawn)
	stage.player_component.damage(99)
	var failures := 0
	if not stage.player_defeated:
		push_error("Lethal damage must enter defeated state")
		failures += 1
	if not stage.defeat_panel.visible:
		push_error("Defeat panel must become visible")
		failures += 1
	var saved = JSON.parse_string(FileAccess.get_file_as_string(stage.save_path_override))
	if not saved is Dictionary or int(saved.get("player_health", 0)) != 6 or not is_equal_approx(float(saved.get("biomass", 0.0)), 7.0):
		push_error("Defeat must not overwrite the committed area-entry body checkpoint")
		failures += 1
	stage.queue_free()
	await process_frame
	var path := ProjectSettings.globalize_path("user://player_defeat_retry_test.json")
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	if failures == 0:
		print("PASS: player defeat exposes checkpoint retry without overwriting entry state")
	quit(1 if failures > 0 else 0)
