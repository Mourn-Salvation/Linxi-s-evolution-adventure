extends Node

const ATTACKS := {
	"NEUTRAL": preload("res://resources/attacks/claw_neutral.tres"),
	"LEFT": preload("res://resources/attacks/claw_left.tres"),
	"RIGHT": preload("res://resources/attacks/claw_right.tres"),
	"UP": preload("res://resources/attacks/claw_up.tres"),
	"DOWN": preload("res://resources/attacks/claw_down.tres"),
}

var host: Node
var running_attack_time_remaining := 0.0
var running_attack_distance_remaining := 0.0
var running_attack_direction := 0.0

func setup(value: Node) -> void: host = value
func speed_weight_multiplier() -> float: return host.balance.weight_speed_multiplier(host.vore_component.current_weight(), host.weight_speed_debuff_disabled)
func attack_biomass_bonus() -> float: return host.balance.attack_bonus(host.biomass)

func input_attack_tag() -> String:
	var direction: Vector2 = host.player_component.input_direction()
	if direction.y < -0.1: return "UP"
	if direction.y > 0.1: return "DOWN"
	if direction.x < -0.1: return "LEFT"
	if direction.x > 0.1: return "RIGHT"
	return "NEUTRAL"

func attack_for_tag(tag: String) -> AttackData:
	return ATTACKS.get(tag.to_upper(), ATTACKS["NEUTRAL"])

func try_attack() -> void:
	if host.digesting or host.player_defeated or host.player_hit_reaction_time > 0.0 or host.attack_cooldown > 0.0 or host.dodge_time > 0.0: return
	if not host.body_attack_unlocked:
		host.update_hud("Linxi cannot shape her altered body into a reliable attack yet. Evade and keep moving.")
		return
	if host.player_height > 45.0:
		host.update_hud("Ground attacks cannot connect at this jump height yet.")
		return
	var direction: Vector2 = host.player_component.input_direction()
	var running_attack: bool = host.player_component.is_sprinting(direction)
	var attack: AttackData = attack_for_tag(input_attack_tag())
	host.last_body_attack_id = "claw_running" if running_attack else attack.attack_id
	if running_attack:
		_begin_running_attack(direction)
	else:
		host.combo_step = host.combo_step % 3 + 1
		host.combo_timeout = host.balance.combo_reset_time
		var speed_scale: float = 0.55 if host.evolved else 1.0
		host.attack_cooldown = attack.cooldown * speed_scale
	host.attack_duration_current = host.attack_cooldown
	if is_instance_valid(host.audio_component):
		host.audio_component.play_claw_swing()
	var attack_range_x: float = attack.range_x + (host.balance.running_attack_slide_distance if running_attack else 0.0)
	var target_index: int = host.enemy_component.nearest_target_in_attack(attack.input_tag, attack_range_x, attack.range_depth)
	if target_index < 0:
		return
	var enemy: Dictionary = host.enemies[target_index]
	var was_alive := int(enemy["health"]) > 0
	var raw_damage: int = host.balance.running_attack_damage if running_attack else maxi(host.balance.attack_damage(host.biomass) + attack.damage_bonus, 1)
	var damage: int = host.enemy_component.apply_damage(target_index, raw_damage)
	host.enemy_component.apply_hit_reaction(target_index, host.balance.attack_stun(attack.stun_time, damage))
	if is_instance_valid(host.audio_component):
		host.audio_component.play_claw_hit()
		if was_alive and int(enemy["health"]) <= 0:
			host.audio_component.play_enemy_knockdown()
		else:
			host.audio_component.play_enemy_hurt()
	host.spawn_hit_effect(Vector2(enemy["position"]), float(enemy["facing"]))
	host.enemy_component.sync_legacy_target(target_index)
	host.hit_stop = attack.hit_stop
	host.clean_hits += 1
	if not host.evolved and host.clean_hits >= host.balance.evolution_hits: evolve()
	if running_attack:
		host.combo_step = 1


func _begin_running_attack(direction: Vector2) -> void:
	host.facing = signf(direction.x) if absf(direction.x) > 0.1 else host.facing
	host.combo_step = 1
	host.combo_timeout = host.balance.running_attack_duration
	host.attack_cooldown = host.balance.running_attack_duration
	running_attack_time_remaining = host.balance.running_attack_duration
	running_attack_distance_remaining = host.balance.running_attack_slide_distance
	running_attack_direction = host.facing
	host.movement_mode = "ATTACK"


func is_running_attack_active() -> bool:
	return running_attack_time_remaining > 0.0 and running_attack_distance_remaining > 0.0


func update_running_attack(delta: float) -> void:
	if not is_running_attack_active():
		reset_running_attack()
		return
	var step_fraction := minf(delta / maxf(running_attack_time_remaining, 0.001), 1.0)
	var step_distance := running_attack_distance_remaining * step_fraction
	host.player_ground.x += running_attack_direction * step_distance
	running_attack_distance_remaining = maxf(running_attack_distance_remaining - step_distance, 0.0)
	running_attack_time_remaining = maxf(running_attack_time_remaining - delta, 0.0)
	if running_attack_time_remaining <= 0.0 or running_attack_distance_remaining <= 0.0:
		reset_running_attack()


func reset_running_attack() -> void:
	running_attack_time_remaining = 0.0
	running_attack_distance_remaining = 0.0
	running_attack_direction = 0.0
	if is_instance_valid(host) and host.last_body_attack_id == "claw_running":
		host.combo_step = 0

func try_dodge() -> void:
	if host.g_mode:
		host.update_hud("G mode cannot dodge.")
		return
	if host.digesting or host.player_defeated or host.dodge_time > 0.0 or host.player_height > 0.0 or is_running_attack_active(): return
	if host.dodge_cooldown > 0.0:
		host.update_hud("Dodge is recovering: %.1fs." % host.dodge_cooldown)
		return
	var direction: Vector2 = host.player_component.input_direction()
	host.dodge_direction = shaped_dodge_direction(direction)
	host.facing = signf(host.dodge_direction.x)
	host.dodge_duration_current = host.balance.evolved_dodge_duration if host.evolved else host.balance.dodge_duration
	host.dodge_time = host.dodge_duration_current
	host.dodge_cooldown = host.balance.dodge_cooldown_seconds
	host.player_hit_reaction_time = 0.0
	host.player_invulnerability = maxf(host.player_invulnerability, host.dodge_duration_current)
	host.movement_mode = "DODGE"
	host.combo_step = 0
	if is_instance_valid(host.audio_component):
		host.audio_component.play_dodge()


func shaped_dodge_direction(input_direction: Vector2) -> Vector2:
	var horizontal: float = signf(input_direction.x) if absf(input_direction.x) > 0.1 else float(host.facing)
	var depth: float = input_direction.y * host.balance.dodge_depth_ratio
	return Vector2(horizontal, depth)

func evolve() -> void:
	host.evolved = true
	host.combo_step = 0
	host.vore_flash = 0.35
	host.update_hud("ADAPTATION COMPLETE - recovery shortened and directional chains accelerated.")
