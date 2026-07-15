extends SceneTree

const GameSessionData = preload("res://scripts/data/game_session.gd")

const TEST_ROOT := "user://title_save_slots_test"
var failures := 0


func _initialize() -> void:
	GameSessionData.storage_root_override = TEST_ROOT
	GameSessionData.active_slot = 0
	_cleanup()
	_write_json(GameSessionData.legacy_save_path(), {
		"player_health": 7,
		"player_max_health": 12,
		"biomass": 4.5,
		"route_checkpoint": {
			"destination_name": "Dormitory Lobby",
			"target_scene": "res://scenes/dormitory_lobby.tscn",
			"saved_at_unix": 12345,
		},
	})

	GameSessionData.initialize()
	expect(GameSessionData.active_slot == 1, "legacy save migrates into Slot 1")
	expect(GameSessionData.slot_exists(1), "migrated Slot 1 exists")
	expect(FileAccess.file_exists(GameSessionData.legacy_save_path()), "migration preserves the legacy save")
	expect(GameSessionData.has_returning_profile(), "migrated progress is recognized as a returning player")
	expect(GameSessionData.scene_for_slot(1) == "res://scenes/dormitory_lobby.tscn", "load resolves the committed target scene")
	var summary: Dictionary = GameSessionData.slot_summary(1)
	expect(String(summary["location"]) == "Dormitory Lobby", "slot summary exposes checkpoint location")
	expect(int(summary["hp"]) == 7 and int(summary["max_hp"]) == 12, "slot summary exposes health")

	GameSessionData.select_slot(2)
	expect(GameSessionData.active_save_path() == GameSessionData.slot_path(2), "selected slots isolate the active save path")
	GameSessionData.begin_new_game(2)
	expect(GameSessionData.force_opening_once, "New Game requests the opening cinematic")
	expect(not GameSessionData.slot_exists(2), "an explicitly selected empty slot begins cleanly")

	var title_scene := load("res://scenes/title_menu.tscn") as PackedScene
	expect(title_scene != null, "title menu scene loads")
	if title_scene != null:
		var title_menu := title_scene.instantiate()
		root.add_child(title_menu)
		await process_frame
		var button_texts: Array[String] = []
		_collect_button_texts(title_menu, button_texts)
		for required in ["NEW GAME", "LOAD GAME", "SAVE FILES", "SETTINGS", "EXIT"]:
			expect(required in button_texts, "title menu exposes %s" % required)
		title_menu.queue_free()
		await process_frame

	_cleanup()
	GameSessionData.storage_root_override = ""
	GameSessionData.active_slot = 0
	GameSessionData.force_opening_once = false
	if failures == 0:
		print("PASS: title menu save slots")
		quit(0)
	else:
		push_error("FAIL: %d title/save-slot test(s)" % failures)
		quit(1)


func expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)


func _write_json(path: String, data: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(TEST_ROOT))
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func _collect_button_texts(node: Node, output: Array[String]) -> void:
	if node is Button:
		output.append((node as Button).text)
	for child in node.get_children():
		_collect_button_texts(child, output)


func _cleanup() -> void:
	for path in [GameSessionData.profile_path(), GameSessionData.legacy_save_path()]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	for slot in range(1, GameSessionData.SAVE_SLOT_COUNT + 1):
		var path: String = GameSessionData.slot_path(slot)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
