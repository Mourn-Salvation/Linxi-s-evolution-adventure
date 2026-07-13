class_name BoneBladeEliteProfile
extends RefCounted

const AI_PROFILE := "BONE_BLADE_ELITE"
const SPECIAL_STATES := ["SPECIAL_TELEGRAPH", "SPECIAL_RUSH", "SPECIAL_RECOVER"]

var host: Node
var enemy_component: Node


func setup(owner: Node, component: Node) -> void:
	host = owner
	enemy_component = component


func matches(enemy: Dictionary) -> bool:
	return String(enemy.get("ai_profile", "")) == AI_PROFILE


func is_special_state(enemy: Dictionary) -> bool:
	return String(enemy.get("state", "")) in SPECIAL_STATES


func update(index: int, delta: float) -> void:
	var enemy: Dictionary = host.enemies[index]
	enemy["special_cooldown"] = maxf(float(enemy.get("special_cooldown", 0.0)) - delta, 0.0)
	enemy["state_time"] = maxf(float(enemy.get("state_time", 0.0)) - delta, 0.0)
	match String(enemy.get("state", "APPROACH")):
		"STAGGER":
			if float(enemy["state_time"]) <= 0.0:
				enemy["state"] = "APPROACH"
		"SPECIAL_TELEGRAPH":
			if float(enemy["state_time"]) <= 0.0:
				_begin_rush(enemy)
		"SPECIAL_RUSH":
			enemy["special_strike_time"] = maxf(float(enemy.get("special_strike_time", 0.0)) - delta, 0.0)
			if float(enemy["special_strike_time"]) <= 0.0:
				_perform_strike(enemy)
		"SPECIAL_RECOVER":
			if float(enemy["state_time"]) <= 0.0:
				enemy["state"] = "APPROACH"
		"TELEGRAPH", "HEAVY_TELEGRAPH":
			if float(enemy["state_time"]) <= 0.0:
				enemy_component.resolve_human_attack(index)
		"RECOVER":
			if float(enemy["state_time"]) <= 0.0:
				enemy["state"] = "APPROACH"
		"APPROACH":
			if _can_begin_special(enemy):
				_begin_telegraph(enemy)
			else:
				enemy_component.approach_human(index, delta)
		_:
			enemy["state"] = "APPROACH"


func interrupt(enemy: Dictionary, hurt_duration: float) -> void:
	enemy["state"] = "STAGGER"
	enemy["state_time"] = hurt_duration
	enemy["special_cooldown"] = host.balance.bone_blade_special_cooldown
	enemy["special_strike_index"] = 0
	enemy["special_strike_time"] = 0.0
	enemy["special_visual_frame"] = 0
	enemy["attack_facing"] = float(enemy.get("facing", -1.0))


func _can_begin_special(enemy: Dictionary) -> bool:
	if float(enemy.get("special_cooldown", 0.0)) > 0.0:
		return false
	var offset: Vector2 = host.player_ground - Vector2(enemy["position"])
	return absf(offset.x) <= host.balance.bone_blade_special_trigger_range and absf(offset.y) <= host.balance.bone_blade_special_depth_range and host.player_height <= 55.0


func _begin_telegraph(enemy: Dictionary) -> void:
	var horizontal: float = host.player_ground.x - Vector2(enemy["position"]).x
	enemy_component.start_attack_cast(enemy, "SPECIAL_TELEGRAPH", host.balance.bone_blade_special_telegraph_time, signf(horizontal))
	enemy["special_strike_index"] = 0
	enemy["special_visual_frame"] = 0
	host.update_hud("Bone-Blade Twin braces for a three-strike rush.")


func _begin_rush(enemy: Dictionary) -> void:
	enemy["state"] = "SPECIAL_RUSH"
	enemy["special_strike_index"] = 0
	enemy["special_strike_time"] = 0.0
	_perform_strike(enemy)


func _perform_strike(enemy: Dictionary) -> void:
	var strike_index := int(enemy.get("special_strike_index", 0))
	if strike_index >= 3:
		_finish_rush(enemy)
		return
	var start_position := Vector2(enemy["position"])
	var facing: float = enemy_component.attack_facing_for(enemy)
	var desired_position := start_position + Vector2(facing * host.balance.bone_blade_special_rush_distance, 0.0)
	var end_position: Vector2 = host.resolve_map_blockers(start_position, desired_position)
	end_position.x = clampf(end_position.x, host.ground_min_x, host.ground_width)
	end_position.y = clampf(end_position.y, 0.0, host.ground_depth)
	enemy["position"] = end_position
	enemy["special_visual_frame"] = strike_index * 2
	_damage_in_swept_lane(enemy, start_position, end_position, facing)
	enemy["special_strike_index"] = strike_index + 1
	enemy["special_strike_time"] = host.balance.bone_blade_special_strike_interval


func _damage_in_swept_lane(enemy: Dictionary, start_position: Vector2, end_position: Vector2, facing: float) -> void:
	if host.player_invulnerability > 0.0 or host.dodge_time > 0.0 or host.player_height > 55.0:
		return
	var player_offset: Vector2 = Vector2(host.player_ground) - start_position
	var travelled := absf(end_position.x - start_position.x)
	var forward_distance: float = player_offset.x * facing
	var depth_limit: float = host.balance.bone_blade_special_depth_range + host.player_shadow_depth_radius()
	var forward_limit: float = travelled + host.balance.bone_blade_special_hit_range + host.player_shadow_radius()
	if absf(player_offset.y) <= depth_limit and forward_distance >= -host.player_shadow_radius() and forward_distance <= forward_limit:
		host.player_component.damage(host.balance.bone_blade_special_damage, {
			"position": start_position,
			"facing": facing,
		})


func _finish_rush(enemy: Dictionary) -> void:
	enemy["state"] = "SPECIAL_RECOVER"
	enemy["state_time"] = host.balance.bone_blade_special_recovery_time
	enemy["special_cooldown"] = host.balance.bone_blade_special_cooldown
	enemy["special_visual_frame"] = 5
