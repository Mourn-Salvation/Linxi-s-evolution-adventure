extends SceneTree

const SCENES: Array[String] = [
	"res://scenes/dormitory_lobby.tscn",
	"res://scenes/red_night_teaching_lobby.tscn",
	"res://scenes/red_night_playground_return.tscn",
	"res://scenes/red_night_roof_route.tscn",
	"res://scenes/red_night_school_exit.tscn",
]

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for scene_path in SCENES:
		await _audit_scene(scene_path)
	if failures == 0:
		print("PASS: enemy AI smoke test")
	quit(1 if failures > 0 else 0)


func _audit_scene(scene_path: String) -> void:
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("AI_SMOKE load failed: %s" % scene_path)
		failures += 1
		return
	var instance := packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	if scene_path == "res://scenes/red_night_teaching_lobby.tscn":
		await _verify_story_lock_freezes_combat(instance)
	instance.story_control_locked = false
	instance.dialogue_active = false
	instance.player_defeated = false
	instance.story_overlay = ""
	var initial: Dictionary = {}
	for enemy in instance.enemies:
		enemy["ai_frozen"] = false
		if String(enemy.get("state", "")) in ["NEUTRAL", "DORMANT"]:
			enemy["state"] = "APPROACH"
		initial[String(enemy.get("id", ""))] = Vector2(enemy.get("position", Vector2.ZERO))
	for frame in range(90):
		await process_frame
	print("AI_SMOKE ", scene_path)
	for enemy in instance.enemies:
		var enemy_id := String(enemy.get("id", ""))
		var start := Vector2(initial.get(enemy_id, Vector2.ZERO))
		var finish := Vector2(enemy.get("position", Vector2.ZERO))
		var state := String(enemy.get("state", ""))
		var moved := start.distance_to(finish)
		print("  ", enemy_id, " state=", state, " moved=", moved, " from=", start, " to=", finish)
		var legitimately_stationary := state in ["KNOCKED_DOWN", "TELEGRAPH", "HEAVY_TELEGRAPH", "RECOVER", "SPECIAL_TELEGRAPH", "SPECIAL_RUSH", "SPECIAL_RECOVER"]
		if moved <= 1.0 and not legitimately_stationary:
			failures += 1
			push_error("AI_SMOKE %s remained idle in active state %s on %s" % [enemy_id, state, scene_path])
	instance.queue_free()
	await process_frame


func _verify_story_lock_freezes_combat(instance: Node) -> void:
	instance.story_control_locked = true
	var initial_positions: Array[Vector2] = []
	for enemy in instance.enemies:
		initial_positions.append(Vector2(enemy.get("position", Vector2.ZERO)))
	for frame in range(20):
		await process_frame
	var frozen := true
	for index in range(instance.enemies.size()):
		if initial_positions[index].distance_to(Vector2(instance.enemies[index].get("position", Vector2.ZERO))) > 0.01:
			frozen = false
	print("AI_SMOKE story_lock_freezes_combat=", frozen)
	if not frozen:
		failures += 1
		push_error("AI_SMOKE story lock did not freeze teaching-lobby combat")
