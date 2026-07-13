@tool
extends SceneTree

const EnemyVisualLibrary = preload("res://scripts/enemies/enemy_visual_library.gd")
const OUTPUT_PATH := "res://resources/enemies/red_night_enemy_visual_library.tres"


func _initialize() -> void:
	var library := EnemyVisualLibrary.new()
	library.human_hit_reaction_left_frames = load_frames("res://assets/sprites/enemies/human_guard/hit_reaction", "left", 4)
	library.human_hit_reaction_right_frames = load_frames("res://assets/sprites/enemies/human_guard/hit_reaction", "right", 4)
	library.human_guard_knocked_down_left = load("res://assets/sprites/enemies/human_guard/knocked_down/left_00.png")
	library.human_guard_knocked_down_right = load("res://assets/sprites/enemies/human_guard/knocked_down/right_00.png")

	library.human_student_appearance_left = load("res://assets/sprites/enemies/human_student/run/appearance_left.png")
	library.human_student_appearance_right = load("res://assets/sprites/enemies/human_student/run/appearance_right.png")
	library.human_student_knocked_down_left = load("res://assets/sprites/enemies/human_student/knocked_down/left_00.png")
	library.human_student_knocked_down_right = load("res://assets/sprites/enemies/human_student/knocked_down/right_00.png")
	library.human_student_run_left_frames = load_frames("res://assets/sprites/enemies/human_student/run", "left", 8)
	library.human_student_run_right_frames = load_frames("res://assets/sprites/enemies/human_student/run", "right", 8)

	library.human_student_female_appearance_left = load("res://assets/sprites/enemies/human_student/run_female/appearance_left.png")
	library.human_student_female_appearance_right = load("res://assets/sprites/enemies/human_student/run_female/appearance_right.png")
	library.human_student_female_knocked_down_left = load("res://assets/sprites/enemies/human_student/knocked_down_female/left_00.png")
	library.human_student_female_knocked_down_right = load("res://assets/sprites/enemies/human_student/knocked_down_female/right_00.png")
	library.human_student_female_run_left_frames = load_frames("res://assets/sprites/enemies/human_student/run_female", "left", 8)
	library.human_student_female_run_right_frames = load_frames("res://assets/sprites/enemies/human_student/run_female", "right", 8)

	library.zombie_hit_reaction_left_frames = load_frames("res://assets/sprites/enemies/zombie_student/hit_reaction", "left", 4)
	library.zombie_hit_reaction_right_frames = load_frames("res://assets/sprites/enemies/zombie_student/hit_reaction", "right", 4)
	library.zombie_student_appearance_left_frames = load_frames("res://assets/sprites/enemies/zombie_student/appearance_variants", "left", 4)
	library.zombie_student_appearance_right_frames = load_frames("res://assets/sprites/enemies/zombie_student/appearance_variants", "right", 4)
	library.zombie_student_knocked_down_left_frames = load_frames("res://assets/sprites/enemies/zombie_student/knocked_down", "left", 4)
	library.zombie_student_knocked_down_right_frames = load_frames("res://assets/sprites/enemies/zombie_student/knocked_down", "right", 4)

	var error := ResourceSaver.save(library, OUTPUT_PATH)
	if error != OK:
		push_error("Failed to save enemy visual library: %s" % error_string(error))
		quit(1)
	print("Saved enemy visual library: %s" % OUTPUT_PATH)
	quit(0)


func load_frames(directory: String, direction: String, count: int) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for index in range(count):
		var path := "%s/%s_%s.png" % [directory, direction, str(index).pad_zeros(2)]
		var texture := load(path) as Texture2D
		if texture == null:
			push_error("Missing texture: %s" % path)
		frames.append(texture)
	return frames
