class_name AttackData
extends Resource

@export var attack_id := "claw_neutral"
@export var display_name := "Claw Strike"
@export_enum("NEUTRAL", "LEFT", "RIGHT", "UP", "DOWN") var input_tag := "NEUTRAL"
@export var range_x := 155.0
@export var range_depth := 70.0
@export var cooldown := 0.46
@export var damage_bonus := 0
@export var hit_stop := 0.085
@export var stun_time := 0.1