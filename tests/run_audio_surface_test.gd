extends SceneTree

const AUDIO_COMPONENT_SCRIPT := preload("res://scripts/audio/audio_component.gd")


func _init() -> void:
	var errors: Array[String] = []
	var audio: Node = AUDIO_COMPONENT_SCRIPT.new()
	root.add_child(audio)
	audio._load_named_events()
	for event_name in ["footstep_wet", "footstep_concrete", "footstep_marble", "footstep_grass", "dodge_whoosh", "hurt", "linxi_claw_hit_flesh"]:
		var streams: Array = audio.streams_by_event.get(event_name, [])
		if streams.is_empty():
			errors.append("Audio event has no streams: %s" % event_name)
	_check_map_surface(errors, "res://resources/maps/red_night.tres", "WET")
	_check_map_surface(errors, "res://resources/maps/dormitory_lobby.tres", "MARBLE")
	_check_map_surface(errors, "res://resources/maps/dormitory_second_floor.tres", "CONCRETE")
	_check_map_surface(errors, "res://resources/maps/red_night_playground_return.tres", "GRASS")
	audio.queue_free()
	if not errors.is_empty():
		for error in errors:
			push_error(error)
		quit(1)
		return
	print("PASS: audio surface banks and map surfaces")
	quit(0)


func _check_map_surface(errors: Array[String], path: String, expected_surface: String) -> void:
	var map := load(path) as MapData
	if map == null:
		errors.append("Map failed to load: %s" % path)
		return
	if map.footstep_surface != expected_surface:
		errors.append("%s expected footstep_surface %s but got %s" % [path, expected_surface, map.footstep_surface])
