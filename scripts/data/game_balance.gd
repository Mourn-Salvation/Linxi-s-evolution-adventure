class_name GameBalance
extends Resource

@export_group("Units")
@export var unit_health := 10
@export var unit_attack := 2
@export var legacy_max_health := 100

@export_group("Movement")
@export var sprint_speed := 360.0
@export var walk_speed := 140.0
@export var minimum_move_speed := 50.0
@export var double_tap_window := 0.3
@export var mobile_sprint_threshold := 0.5
@export var dodge_speed := 760.0
@export var dodge_duration := 0.18
@export var evolved_dodge_duration := 0.16
@export var dodge_cooldown_seconds := 1.0
@export var dodge_depth_ratio := 0.25
@export var jump_speed := 650.0
@export var gravity := 1800.0

@export_group("Combat")
@export var evaluation_attack_cooldown := 0.46
@export var evolved_attack_cooldown := 0.22
@export var combo_reset_time := 0.72
@export var evolution_hits := 6
@export var biomass_for_max_attack := 20.0
@export var maximum_attack_bonus := 2.0
@export var hit_stun_per_damage := 0.025
@export var maximum_attack_stun := 0.24
@export var running_attack_damage := 2
@export var running_attack_slide_distance := 50.0
@export var running_attack_duration := 0.3

@export_group("Vore And Digestion")
@export var maximum_biomass := 50.0
@export var digest_seconds_per_prey := 3.0
@export var biomass_for_max_digest_speed := 50.0
@export var maximum_digest_time_reduction := 0.5
@export var biomass_retention := 0.25
@export var base_live_vore_chance := 0.20
@export var biomass_for_max_live_vore := 50.0
@export var vore_range_x := 185.0
@export var vore_range_depth := 80.0
@export var biomass_capacity_per_point := 1.0
@export var maximum_biomass_capacity_bonus := 20
@export var g_mode_batch_limit := 6
@export var route_input_window := 0.3

@export_group("Growth")
@export var biomass_for_max_growth := 20.0
@export var maximum_body_scale := 1.2
@export var overflow_scale_per_prey := 0.08

@export_group("G Mode")
@export var g_mode_duration := 10.0
@export var g_mode_biomass_cost := 10.0
@export var g_mode_move_speed := 150.0
@export var g_mode_armor := 5
@export var g_mode_capacity_bonus := 10

@export_group("Human Guard")
@export var human_move_speed := 105.0
@export var human_depth_speed := 85.0
@export var human_attack_range := 125.0
@export var human_depth_range := 42.0
@export var zombie_attack_range := 46.0
@export var zombie_depth_range := 30.0
@export var human_telegraph_time := 0.58
@export var human_recovery_time := 0.72
@export var human_heavy_telegraph_time := 1.15
@export var human_heavy_attack_damage := 4

@export_group("Bone Blade Elite")
@export var bone_blade_normal_windup_time := 0.3
@export var bone_blade_special_trigger_range := 240.0
@export var bone_blade_special_depth_range := 38.0
@export var bone_blade_special_rush_distance := 120.0
@export var bone_blade_special_hit_range := 72.0
@export var bone_blade_special_damage := 4
@export var bone_blade_special_cooldown := 5.0
@export var bone_blade_special_telegraph_time := 0.3
@export var bone_blade_special_strike_interval := 0.3
@export var bone_blade_special_recovery_time := 0.72


func weight_speed_multiplier(weight: float, debuff_disabled: bool = false) -> float:
	if debuff_disabled: return 1.0
	return clampf(1.0 / sqrt(maxf(weight, 1.0)), minimum_move_speed / walk_speed, 1.0)


func attack_bonus(biomass: float) -> float:
	return clampf(biomass / biomass_for_max_attack, 0.0, 1.0) * maximum_attack_bonus


func attack_damage(biomass: float) -> int:
	return maxi(roundi(unit_attack + attack_bonus(biomass)), 1)


func attack_stun(base_stun: float, damage: int) -> float:
	return minf(maxf(base_stun, 0.0) + maxf(float(damage), 0.0) * hit_stun_per_damage, maximum_attack_stun)


func growth_scale(biomass: float) -> float:
	return lerpf(1.0, maximum_body_scale, clampf(biomass / biomass_for_max_growth, 0.0, 1.0))


func capacity_bonus(biomass: float) -> int:
	return clampi(floori(maxf(biomass, 0.0) * biomass_capacity_per_point), 0, maximum_biomass_capacity_bonus)


func clamp_biomass(value: float) -> float:
	return clampf(value, 0.0, maximum_biomass)


func live_vore_chance(biomass: float, g_mode: bool = false) -> float:
	if g_mode: return 1.0
	var progress := clampf(maxf(biomass, 0.0) / biomass_for_max_live_vore, 0.0, 1.0)
	return lerpf(base_live_vore_chance, 1.0, progress)


func digested_biomass(prey_weight: float) -> float:
	return maxf(prey_weight, 0.0) * biomass_retention


func digest_seconds(biomass: float) -> float:
	var progress := clampf(maxf(biomass, 0.0) / biomass_for_max_digest_speed, 0.0, 1.0)
	var reduction := lerpf(0.0, maximum_digest_time_reduction, progress)
	return maxf(digest_seconds_per_prey * (1.0 - reduction), 0.1)


func route_visual_tier(prey_count: int) -> int:
	return clampi(prey_count, 0, 4)


func route_overflow_scale(prey_count: int) -> float:
	return 1.0 + maxf(float(prey_count - 4), 0.0) * overflow_scale_per_prey
