class_name EnemyVisualLibrary
extends Resource

@export_group("Human Guard")
@export var human_hit_reaction_left_frames: Array[Texture2D] = []
@export var human_hit_reaction_right_frames: Array[Texture2D] = []
@export var human_guard_knocked_down_left: Texture2D
@export var human_guard_knocked_down_right: Texture2D

@export_group("Human Student Base")
@export var human_student_appearance_left: Texture2D
@export var human_student_appearance_right: Texture2D
@export var human_student_knocked_down_left: Texture2D
@export var human_student_knocked_down_right: Texture2D
@export var human_student_run_left_frames: Array[Texture2D] = []
@export var human_student_run_right_frames: Array[Texture2D] = []

@export_group("Human Student Female Base")
@export var human_student_female_appearance_left: Texture2D
@export var human_student_female_appearance_right: Texture2D
@export var human_student_female_knocked_down_left: Texture2D
@export var human_student_female_knocked_down_right: Texture2D
@export var human_student_female_run_left_frames: Array[Texture2D] = []
@export var human_student_female_run_right_frames: Array[Texture2D] = []

@export_group("Zombie Student")
@export var zombie_hit_reaction_left_frames: Array[Texture2D] = []
@export var zombie_hit_reaction_right_frames: Array[Texture2D] = []
@export var zombie_student_appearance_left_frames: Array[Texture2D] = []
@export var zombie_student_appearance_right_frames: Array[Texture2D] = []
@export var zombie_student_knocked_down_left_frames: Array[Texture2D] = []
@export var zombie_student_knocked_down_right_frames: Array[Texture2D] = []


func hit_frames(family: int, zombie_family: int, facing_right: bool) -> Array[Texture2D]:
	if family == zombie_family:
		return zombie_hit_reaction_right_frames if facing_right else zombie_hit_reaction_left_frames
	return human_hit_reaction_right_frames if facing_right else human_hit_reaction_left_frames


func zombie_appearance_frames(facing_right: bool) -> Array[Texture2D]:
	return zombie_student_appearance_right_frames if facing_right else zombie_student_appearance_left_frames


func zombie_knocked_down_frames(facing_right: bool) -> Array[Texture2D]:
	return zombie_student_knocked_down_right_frames if facing_right else zombie_student_knocked_down_left_frames


func human_student_run_frames(facing_right: bool, female_variant: bool) -> Array[Texture2D]:
	if female_variant:
		return human_student_female_run_right_frames if facing_right else human_student_female_run_left_frames
	return human_student_run_right_frames if facing_right else human_student_run_left_frames


func human_student_appearance(facing_right: bool, female_variant: bool) -> Texture2D:
	if female_variant:
		return human_student_female_appearance_right if facing_right else human_student_female_appearance_left
	return human_student_appearance_right if facing_right else human_student_appearance_left


func human_student_knocked_down(facing_right: bool, female_variant: bool) -> Texture2D:
	if female_variant:
		return human_student_female_knocked_down_right if facing_right else human_student_female_knocked_down_left
	return human_student_knocked_down_right if facing_right else human_student_knocked_down_left


func human_guard_knocked_down(facing_right: bool) -> Texture2D:
	return human_guard_knocked_down_right if facing_right else human_guard_knocked_down_left
