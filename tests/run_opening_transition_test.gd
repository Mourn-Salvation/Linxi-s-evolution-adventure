extends SceneTree

func _initialize() -> void:
	change_scene_to_file("res://scenes/opening_intro.tscn")
	await process_frame
	await process_frame
	var intro = current_scene
	if intro == null:
		push_error("FAIL: opening scene did not become current")
		quit(1)
		return
	intro.transition_to_red_night()
	await process_frame
	await process_frame
	if current_scene != null and current_scene.scene_file_path == "res://scenes/red_night.tscn":
		print("PASS: opening transitions into Red Night")
		quit(0)
	else:
		push_error("FAIL: current scene is %s" % (current_scene.scene_file_path if current_scene != null else "null"))
		quit(1)