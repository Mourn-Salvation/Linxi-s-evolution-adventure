@tool
extends SceneTree

const PlayerVisualLibrary = preload("res://scripts/characters/player_visual_library.gd")
const OUTPUT_PATH := "res://resources/characters/linxi_t_early_visual_library.tres"


func _initialize() -> void:
	var library := PlayerVisualLibrary.new()
	library.t_form_render_scale = 0.58
	library.idle_fps = 2.4
	library.walk_fps = 8.0
	library.sprint_fps = 11.0
	library.drink_blue_fps = 2.2

	library.idle_frames = load_numbered_frames("res://assets/sprites/linxi/t_early/weak_idle", "idle", 4, "%02d_idle_%02d.png")
	library.walk_left_frames = load_direction_frames("res://assets/sprites/linxi/t_early/walk_horizontal", "left", 16)
	library.walk_right_frames = load_direction_frames("res://assets/sprites/linxi/t_early/walk_horizontal", "right", 16)
	library.sprint_left_frames = load_direction_frames("res://assets/sprites/linxi/t_early/sprint_horizontal", "left", 8)
	library.sprint_right_frames = load_direction_frames("res://assets/sprites/linxi/t_early/sprint_horizontal", "right", 8)
	library.dodge_left_frames = load_direction_frames("res://assets/sprites/linxi/t_early/dodge", "left", 4)
	library.dodge_right_frames = load_direction_frames("res://assets/sprites/linxi/t_early/dodge", "right", 4)
	library.claw_attack_left_frames = load_direction_frames("res://assets/sprites/linxi/t_early/claw_attack", "left", 6)
	library.claw_attack_right_frames = load_direction_frames("res://assets/sprites/linxi/t_early/claw_attack", "right", 6)
	library.hit_reaction_left_frames = load_direction_frames("res://assets/sprites/linxi/t_early/hit_reaction", "left", 4)
	library.hit_reaction_right_frames = load_direction_frames("res://assets/sprites/linxi/t_early/hit_reaction", "right", 4)
	library.tail_ready_left_frames = load_direction_frames("res://assets/sprites/linxi/t_early/tail_ready_overlay", "left", 4)
	library.tail_ready_right_frames = load_direction_frames("res://assets/sprites/linxi/t_early/tail_ready_overlay", "right", 4)
	library.get_up_frames = load_named_frames("res://assets/sprites/linxi/t_early/story/get_up", "get_up", 6)
	library.drink_blue_frames = load_named_frames("res://assets/sprites/linxi/t_early/story/drink_blue", "drink_blue", 6)

	var error := ResourceSaver.save(library, OUTPUT_PATH)
	if error != OK:
		push_error("Failed to save player visual library: %s" % error_string(error))
		quit(1)
	print("Saved player visual library: %s" % OUTPUT_PATH)
	quit(0)


func load_direction_frames(directory: String, direction: String, count: int) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for index in range(count):
		frames.append(load_required("%s/%s_%s.png" % [directory, direction, str(index).pad_zeros(2)]))
	return frames


func load_named_frames(directory: String, name: String, count: int) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for index in range(count):
		frames.append(load_required("%s/%s_%s.png" % [directory, str(index).pad_zeros(2), name]))
	return frames


func load_numbered_frames(directory: String, _name: String, count: int, pattern: String) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for index in range(count):
		frames.append(load_required("%s/%s" % [directory, pattern % [index, index]]))
	return frames


func load_required(path: String) -> Texture2D:
	var texture := load(path) as Texture2D
	if texture == null:
		push_error("Missing texture: %s" % path)
	return texture
