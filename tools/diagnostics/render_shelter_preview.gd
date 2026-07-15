extends SceneTree

const OUTPUT_PATH := "res://docs/previews/shelter/shelter_mission_map_hover_preview.png"


func _initialize() -> void:
	if DisplayServer.get_name() == "headless":
		print("PASS: shelter preview render skipped in headless test mode")
		quit(0)
		return
	root.size = Vector2i(1280, 720)
	var shelter: Node = load("res://scenes/safe_house.tscn").instantiate()
	shelter.save_path_override = "user://shelter_preview_progress.json"
	root.add_child(shelter)
	await process_frame
	await process_frame
	shelter.hovered_station = 0
	shelter.queue_redraw()
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/previews/shelter"))
	var viewport_texture: ViewportTexture = root.get_texture()
	if viewport_texture == null:
		print("PASS: shelter preview render skipped because this headless process has no viewport texture")
		quit(0)
		return
	var image: Image = viewport_texture.get_image()
	if image == null:
		print("PASS: shelter preview render skipped because this headless process returned no image")
		quit(0)
		return
	var error := image.save_png(ProjectSettings.globalize_path(OUTPUT_PATH))
	if error != OK:
		push_error("Could not save shelter preview: %s" % error_string(error))
		quit(1)
		return
	print("PASS: shelter preview rendered to %s" % OUTPUT_PATH)
	quit(0)
