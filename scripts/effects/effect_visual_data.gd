class_name EffectVisualData
extends Resource

@export_group("Combat Slash")
@export var claw_slash_red_left_frames: Array[Texture2D] = []
@export var claw_slash_red_right_frames: Array[Texture2D] = []
@export var claw_slash_silver_left_frames: Array[Texture2D] = []
@export var claw_slash_silver_right_frames: Array[Texture2D] = []
@export var zombie_attack_vertical_red_left_frames: Array[Texture2D] = []
@export var zombie_attack_vertical_red_right_frames: Array[Texture2D] = []
@export var knife_attack_horizontal_silver_left_frames: Array[Texture2D] = []
@export var knife_attack_horizontal_silver_right_frames: Array[Texture2D] = []

@export_group("Hit Effects")
@export var virus_mist_hit_frames: Array[Texture2D] = []
@export var virus_liquid_spread_frames: Array[Texture2D] = []

@export_group("Enemy Telegraph")
@export var enemy_telegraph_normal_frames: Array[Texture2D] = []
@export var enemy_telegraph_heavy_frames: Array[Texture2D] = []

@export_group("Red Night Atomization")
@export var atomization_fog_dense_frames: Array[Texture2D] = []
@export var atomization_fog_subtle_frames: Array[Texture2D] = []

@export_group("Story Overlay")
@export var red_night_classroom_chase: Texture2D
@export var teaching_first_floor_zombie_gathering: Texture2D

@export_group("Motion Trail")
@export var motion_trail_color := Color(0.55, 0.86, 1.0, 1.0)


func claw_slash_frames(slash_type: String, facing: float) -> Array[Texture2D]:
	var red := slash_type == "red"
	if facing > 0.0:
		return claw_slash_red_right_frames if red else claw_slash_silver_right_frames
	return claw_slash_red_left_frames if red else claw_slash_silver_left_frames


func claw_slash_frame_count(slash_type: String, facing: float) -> int:
	return claw_slash_frames(slash_type, facing).size()


func claw_slash_frame(slash_type: String, facing: float, frame_index: int) -> Texture2D:
	var frames: Array[Texture2D] = claw_slash_frames(slash_type, facing)
	if frame_index < 0 or frame_index >= frames.size():
		return null
	return frames[frame_index]


func zombie_attack_vertical_frames(facing: float) -> Array[Texture2D]:
	if facing > 0.0:
		return zombie_attack_vertical_red_right_frames
	return zombie_attack_vertical_red_left_frames


func zombie_attack_vertical_frame_count(facing: float) -> int:
	return zombie_attack_vertical_frames(facing).size()


func zombie_attack_vertical_frame(facing: float, frame_index: int) -> Texture2D:
	var frames: Array[Texture2D] = zombie_attack_vertical_frames(facing)
	if frame_index < 0 or frame_index >= frames.size():
		return null
	return frames[frame_index]


func knife_attack_horizontal_frames(facing: float) -> Array[Texture2D]:
	if facing > 0.0:
		return knife_attack_horizontal_silver_right_frames
	return knife_attack_horizontal_silver_left_frames


func knife_attack_horizontal_frame_count(facing: float) -> int:
	return knife_attack_horizontal_frames(facing).size()


func knife_attack_horizontal_frame(facing: float, frame_index: int) -> Texture2D:
	var frames: Array[Texture2D] = knife_attack_horizontal_frames(facing)
	if frame_index < 0 or frame_index >= frames.size():
		return null
	return frames[frame_index]


func enemy_telegraph_frames(heavy: bool) -> Array[Texture2D]:
	return enemy_telegraph_heavy_frames if heavy else enemy_telegraph_normal_frames


func enemy_telegraph_frame(heavy: bool, progress: float) -> Texture2D:
	var frames: Array[Texture2D] = enemy_telegraph_frames(heavy)
	if frames.is_empty():
		return null
	var index: int = mini(int(floor(clampf(progress, 0.0, 0.999) * float(frames.size()))), frames.size() - 1)
	return frames[index]


func atomization_fog_frame(dense: bool, seed: int, _time_seconds: float) -> Texture2D:
	var frames: Array[Texture2D] = atomization_fog_dense_frames if dense else atomization_fog_subtle_frames
	if frames.is_empty():
		return null
	var index := absi(seed) % frames.size()
	return frames[index]
