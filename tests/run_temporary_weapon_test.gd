extends SceneTree

var failures := 0

func _initialize() -> void:
	var stage = load("res://scenes/main.tscn").instantiate()
	stage.save_path_override = "user://temporary_weapon_test.json"
	root.add_child(stage)
	await process_frame
	stage.weapon_component.equip_from_item({"weapon_id": "handgun", "name": "Test Handgun", "ammo": 1})
	expect(stage.temporary_weapon_uses == 1, "handgun receives authored ammo")
	stage.attack_cooldown = 0.0
	expect(stage.weapon_component.try_use_temporary_weapon(), "handgun consumes J")
	expect(stage.equipped_weapon.is_empty(), "empty handgun is dropped")
	stage.weapon_component.equip_from_item({"weapon_id": "knife", "name": "Test Knife", "ammo": 8})
	expect(stage.temporary_weapon_uses == 1, "knife is always one use")
	stage.attack_cooldown = 0.0
	expect(stage.weapon_component.try_use_temporary_weapon(), "knife consumes J")
	expect(stage.equipped_weapon.is_empty(), "thrown knife leaves temporary slot")
	stage.queue_free()
	await process_frame
	var path := ProjectSettings.globalize_path("user://temporary_weapon_test.json")
	if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	if failures == 0:
		print("PASS: disposable human weapon tests")
		quit(0)
	else:
		push_error("FAIL: %d disposable weapon test(s)" % failures)
		quit(1)

func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)