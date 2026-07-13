extends SceneTree

const ClassroomScene = preload("res://scenes/red_night_classroom_503.tscn")


func _initialize() -> void:
	var stage = ClassroomScene.instantiate()
	stage.load_saved_progress_on_start = false
	root.add_child(stage)
	await process_frame
	var twins: Dictionary = {}
	for item in stage.scene_items:
		if String(item.get("id", "")) == "classroom_503_twins_dialogue":
			twins = item
			break
	var failures := 0
	if twins.is_empty():
		push_error("Missing Classroom 503 twins dialogue")
		failures += 1
	else:
		stage.dialogue_component.start_dialogue(String(twins.get("speaker", "")), Array(twins.get("dialogue", [])), String(twins.get("avatar_path", "")))
		if stage.dialogue_component.avatar_texture_rect.texture == null:
			push_error("Twins portrait failed to load")
			failures += 1
		if stage.dialogue_component.avatar_box.offset_right < 270.0 or stage.dialogue_text_label.offset_left < 290.0:
			push_error("Twins portrait did not activate wide dialogue layout")
			failures += 1
	stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: dialogue avatar audit loads the wide twins portrait")
	quit(1 if failures > 0 else 0)
