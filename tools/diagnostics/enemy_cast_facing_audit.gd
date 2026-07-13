extends SceneTree

const LobbyScene = preload("res://scenes/red_night_teaching_lobby.tscn")


func _initialize() -> void:
	var stage = LobbyScene.instantiate()
	root.add_child(stage)
	await process_frame
	var enemy: Dictionary = stage.enemies[0]
	enemy["position"] = Vector2(500.0, 260.0)
	enemy["facing"] = 1.0
	stage.enemy_component.start_attack_cast(enemy, "TELEGRAPH", 1.0, 1.0)
	stage.player_ground = Vector2(300.0, 260.0)
	stage.enemy_component.update(0.2)
	var failures := 0
	if float(enemy.get("attack_facing", 0.0)) != 1.0 or float(enemy.get("facing", 0.0)) != 1.0:
		push_error("Enemy changed direction after attack cast began")
		failures += 1
	stage.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: enemy attack direction remains locked through cast")
	quit(1 if failures > 0 else 0)
