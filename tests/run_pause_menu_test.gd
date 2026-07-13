extends SceneTree

var failures := 0


func _initialize() -> void:
	var menu = load("res://scenes/pause_menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame

	var background: Node = menu.get_node_or_null("Background")
	var panel: Control = menu.get_node_or_null("Panel") as Control
	expect(background != null, "pause menu has background image")
	expect(panel != null, "pause menu has settings panel")
	if panel != null:
		expect(panel.position.y < 0.0, "pause menu panel starts above screen")

	menu._process(0.3)

	if panel != null:
		expect(panel.position.distance_to(Vector2(330.0, 82.0)) < 1.0, "pause menu panel drops to target position")

	menu.queue_free()
	await process_frame

	if failures == 0:
		print("PASS: pause menu presentation")
		quit(0)
	else:
		push_error("FAIL: %d pause menu test(s)" % failures)
		quit(1)


func expect(condition: bool, label: String) -> void:
	if condition:
		return
	failures += 1
	push_error(label)
