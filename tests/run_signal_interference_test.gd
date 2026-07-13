extends SceneTree

var failures := 0


func _initialize() -> void:
	var overlay = load("res://scenes/effects/signal_interference_overlay.tscn").instantiate()
	root.add_child(overlay)
	await process_frame
	expect(not overlay.visible, "signal overlay starts hidden")
	overlay.trigger(0.25, 1.0)
	expect(overlay.visible, "signal overlay becomes visible after trigger")
	expect(overlay.is_active(), "signal overlay reports active after trigger")
	await create_timer(0.35).timeout
	expect(not overlay.visible, "signal overlay hides after duration")
	expect(not overlay.is_active(), "signal overlay reports inactive after duration")
	overlay.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: signal interference overlay")
		quit(0)
	else:
		push_error("FAIL: %d signal interference test(s)" % failures)
		quit(1)


func expect(condition: bool, label: String) -> void:
	if condition:
		return
	failures += 1
	push_error(label)
