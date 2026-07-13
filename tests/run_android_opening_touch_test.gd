extends SceneTree

const OpeningScene = preload("res://scenes/opening_intro.tscn")


func _initialize() -> void:
	var opening = OpeningScene.instantiate()
	root.add_child(opening)
	await process_frame
	opening.title_ready = true
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(640.0, 360.0)
	opening._unhandled_input(touch)
	var passed: bool = bool(opening.cinematic_started) and int(opening.phase) == int(opening.Phase.CLIP_00001)
	if not passed:
		push_error("Android screen touch must start the opening cinematic")
	opening.queue_free()
	await process_frame
	if passed:
		print("PASS: Android touch starts the opening cinematic")
	quit(0 if passed else 1)
