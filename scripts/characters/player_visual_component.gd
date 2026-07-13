extends Node

@export var visual_library: PlayerVisualLibrary

var host: Node


func setup(owner: Node) -> void:
	host = owner
	if visual_library == null:
		visual_library = load("res://resources/characters/linxi_t_early_visual_library.tres") as PlayerVisualLibrary


func render_scale() -> float:
	return visual_library.t_form_render_scale if visual_library != null else 0.58


func animation_fps(movement_mode: String, moving: bool, direction: Vector2) -> float:
	if visual_library == null:
		return 8.0
	var fps := visual_library.sprint_fps if movement_mode == "SPRINT" else (visual_library.walk_fps if moving else visual_library.idle_fps)
	if moving and absf(direction.x) < 0.1 and absf(direction.y) > 0.1:
		fps *= 0.65
	return fps


func current_t_form_texture(moving: bool, movement_mode: String, animation_time: float, facing: float) -> Texture2D:
	if visual_library == null:
		return null
	var frame := int(floor(animation_time))
	if moving:
		if movement_mode == "SPRINT":
			return visual_library.current_sprint(frame, facing)
		return visual_library.current_walk(frame, facing)
	return visual_library.current_idle(frame)


func current_dodge_texture(progress: float, facing: float) -> Texture2D:
	return visual_library.current_dodge(progress, facing) if visual_library != null else null


func current_player_hit_texture(progress: float, facing: float) -> Texture2D:
	return visual_library.current_hit_reaction(progress, facing) if visual_library != null else null


func current_tail_ready_texture(animation_time: float, facing: float) -> Texture2D:
	if visual_library == null:
		return null
	return visual_library.current_tail_ready(int(floor(animation_time * 0.5)), facing)


func claw_attack_frame_count(facing: float) -> int:
	if visual_library == null:
		return 0
	var frames := visual_library.claw_attack_right_frames if facing > 0.0 else visual_library.claw_attack_left_frames
	return frames.size()


func current_claw_attack_texture(frame_index: int, facing: float) -> Texture2D:
	return visual_library.current_claw_attack(frame_index, facing) if visual_library != null else null


func current_get_up_texture(story_pose_time: float) -> Texture2D:
	if visual_library == null:
		return null
	var ratio := clampf(story_pose_time / 2.2, 0.0, 0.999)
	return visual_library.current_get_up(ratio)


func current_drink_blue_texture(story_pose_time: float) -> Texture2D:
	return visual_library.current_drink_blue(story_pose_time) if visual_library != null else null


func collapsed_texture() -> Texture2D:
	return visual_library.knocked_down() if visual_library != null else null


func first_idle_texture() -> Texture2D:
	return visual_library.current_idle(0) if visual_library != null else null


func route_layer_texture(region: String, tier: int, visual_state: String, frame_index: int) -> Texture2D:
	return visual_library.current_intake_layer(region, tier, visual_state, frame_index) if visual_library != null else null
