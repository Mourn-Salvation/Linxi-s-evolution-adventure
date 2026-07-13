class_name PlayerVisualLibrary
extends Resource

@export_group("Timing")
@export var t_form_render_scale := 0.58
@export var idle_fps := 2.4
@export var walk_fps := 8.0
@export var sprint_fps := 11.0
@export var drink_blue_fps := 2.2

@export_group("Early T Form")
@export var idle_frames: Array[Texture2D] = []
@export var walk_left_frames: Array[Texture2D] = []
@export var walk_right_frames: Array[Texture2D] = []
@export var sprint_left_frames: Array[Texture2D] = []
@export var sprint_right_frames: Array[Texture2D] = []
@export var dodge_left_frames: Array[Texture2D] = []
@export var dodge_right_frames: Array[Texture2D] = []
@export var claw_attack_left_frames: Array[Texture2D] = []
@export var claw_attack_right_frames: Array[Texture2D] = []
@export var hit_reaction_left_frames: Array[Texture2D] = []
@export var hit_reaction_right_frames: Array[Texture2D] = []
@export var tail_ready_left_frames: Array[Texture2D] = []
@export var tail_ready_right_frames: Array[Texture2D] = []
@export var intake_layer_base_path := "res://assets/sprites/linxi/t_early/intake_layers"

@export_group("Story")
@export var get_up_frames: Array[Texture2D] = []
@export var drink_blue_frames: Array[Texture2D] = []
@export var knocked_down_texture: Texture2D


func frames_for_direction(right_frames: Array[Texture2D], left_frames: Array[Texture2D], facing: float) -> Array[Texture2D]:
	return right_frames if facing > 0.0 else left_frames


func current_idle(frame_index: int) -> Texture2D:
	return idle_frames[frame_index % idle_frames.size()] if not idle_frames.is_empty() else null


func current_walk(frame_index: int, facing: float) -> Texture2D:
	var frames := frames_for_direction(walk_right_frames, walk_left_frames, facing)
	return frames[frame_index % frames.size()] if not frames.is_empty() else null


func current_sprint(frame_index: int, facing: float) -> Texture2D:
	var frames := frames_for_direction(sprint_right_frames, sprint_left_frames, facing)
	return frames[frame_index % frames.size()] if not frames.is_empty() else null


func current_dodge(progress: float, facing: float) -> Texture2D:
	return frame_by_progress(frames_for_direction(dodge_right_frames, dodge_left_frames, facing), progress)


func current_hit_reaction(progress: float, facing: float) -> Texture2D:
	return frame_by_progress(frames_for_direction(hit_reaction_right_frames, hit_reaction_left_frames, facing), progress)


func current_tail_ready(frame_index: int, facing: float) -> Texture2D:
	var frames := frames_for_direction(tail_ready_right_frames, tail_ready_left_frames, facing)
	return frames[frame_index % frames.size()] if not frames.is_empty() else null


func current_claw_attack(frame_index: int, facing: float) -> Texture2D:
	var frames := frames_for_direction(claw_attack_right_frames, claw_attack_left_frames, facing)
	return frames[frame_index] if frame_index >= 0 and frame_index < frames.size() else null


func current_get_up(progress: float) -> Texture2D:
	return frame_by_progress(get_up_frames, progress)


func current_drink_blue(story_pose_time: float) -> Texture2D:
	if drink_blue_frames.is_empty():
		return null
	var frame_index := mini(int(floor(story_pose_time * drink_blue_fps)), drink_blue_frames.size() - 1)
	return drink_blue_frames[frame_index]


func final_drink_blue() -> Texture2D:
	if drink_blue_frames.is_empty():
		return null
	return drink_blue_frames[drink_blue_frames.size() - 1]


func knocked_down() -> Texture2D:
	return knocked_down_texture if knocked_down_texture != null else final_drink_blue()


func current_intake_layer(region: String, tier: int, visual_state: String, frame_index: int) -> Texture2D:
	var path := "%s/%s/tier_%d/%s_%02d.png" % [intake_layer_base_path, region.to_lower(), tier, visual_state, frame_index]
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


func frame_by_progress(frames: Array[Texture2D], progress: float) -> Texture2D:
	if frames.is_empty():
		return null
	var frame_index := mini(int(floor(clampf(progress, 0.0, 0.999) * float(frames.size()))), frames.size() - 1)
	return frames[frame_index]
