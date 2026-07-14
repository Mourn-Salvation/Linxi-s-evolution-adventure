extends Node

var host: Node

func setup(value: Node) -> void:
	host = value

func move(delta: float) -> void:
	var direction: Vector2 = input_direction()
	if host.attack_cooldown > 0.0:
		host.movement_mode = "ATTACK"
		return
	if host.g_mode:
		if absf(direction.x) > 0.1: host.facing = signf(direction.x)
		host.movement_mode = "G-MODE"
		host.player_ground += direction * host.balance.g_mode_move_speed * delta
		return
	if absf(direction.x) > 0.1: host.facing = signf(direction.x)
	var sprinting: bool = is_sprinting(direction)
	host.movement_mode = "SPRINT" if sprinting else "WALK"
	var story_speed: float = float(host.get("story_movement_multiplier"))
	var velocity: Vector2 = direction * host.balance.walk_speed * host.combat_component.speed_weight_multiplier() * story_speed
	if sprinting: velocity.x = direction.x * host.balance.sprint_speed * host.combat_component.speed_weight_multiplier() * story_speed
	host.player_ground += velocity * delta


func is_sprinting(direction: Vector2) -> bool:
	if host.g_mode or absf(direction.x) <= 0.1:
		return false
	var sprint_direction: Vector2 = movement_vector_for_key(host.sprint_key)
	var keyboard_sprint: bool = host.sprint_key != KEY_NONE and Input.is_key_pressed(host.sprint_key) and signf(direction.x) == sprint_direction.x
	var mobile_sprint: bool = false
	if is_instance_valid(host.mobile_controls):
		var joystick: Vector2 = host.mobile_controls.joystick_vector()
		mobile_sprint = joystick.length() > host.balance.mobile_sprint_threshold and absf(joystick.x) >= absf(joystick.y)
	return keyboard_sprint or mobile_sprint

func input_direction() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): direction.y += 1.0
	if is_instance_valid(host.mobile_controls):
		direction += host.mobile_controls.movement_vector()
	return direction.limit_length(1.0)

func is_horizontal_key(keycode: Key) -> bool:
	return keycode == KEY_A or keycode == KEY_D

func movement_vector_for_key(keycode: Key) -> Vector2:
	if keycode == KEY_A or keycode == KEY_LEFT: return Vector2.LEFT
	if keycode == KEY_D or keycode == KEY_RIGHT: return Vector2.RIGHT
	return Vector2.ZERO

func register_movement_tap(keycode: Key) -> void:
	if host.g_mode: return
	var now := Time.get_ticks_msec() / 1000.0
	var previous := float(host.last_tap_time_by_key.get(keycode, -10.0))
	if now - previous <= host.balance.double_tap_window:
		host.sprint_key = keycode
		host.movement_mode = "SPRINT"
	host.last_tap_time_by_key[keycode] = now

func current_move_speed() -> float:
	if host.g_mode: return host.balance.g_mode_move_speed
	var base_speed: float = host.balance.sprint_speed if host.movement_mode == "SPRINT" else host.balance.walk_speed
	return base_speed * host.combat_component.speed_weight_multiplier() * float(host.get("story_movement_multiplier"))

func update_jump(delta: float) -> void:
	if host.player_height <= 0.0 and host.vertical_velocity <= 0.0:
		host.player_height = 0.0
		host.vertical_velocity = 0.0
		return
	host.vertical_velocity -= host.balance.gravity * delta
	host.player_height += host.vertical_velocity * delta
	if host.player_height <= 0.0:
		host.player_height = 0.0
		host.vertical_velocity = 0.0

func try_jump() -> void:
	if host.g_mode:
		host.update_hud("G mode cannot jump.")
		return
	if host.digesting or host.player_defeated or host.player_hit_reaction_time > 0.0 or host.player_height > 0.0 or host.dodge_time > 0.0: return
	host.vertical_velocity = host.balance.jump_speed
	host.combo_step = 0
	if is_instance_valid(host.audio_component):
		host.audio_component.play_jump()
	host.update_hud("Jump height is independent from ground depth.")

func try_activate_g_mode() -> void:
	if host.g_mode:
		host.update_hud("G mode is already active for %d more seconds." % ceili(host.g_mode_time))
		return
	if host.biomass < host.balance.g_mode_biomass_cost:
		host.update_hud("G mode requires %.1f permanent biomass. Current: %.1f." % [host.balance.g_mode_biomass_cost, host.biomass])
		return
	host.biomass = host.balance.clamp_biomass(host.biomass - host.balance.g_mode_biomass_cost)
	host.g_mode = true
	host.g_mode_time = host.balance.g_mode_duration
	host.player_height = 0.0
	host.vertical_velocity = 0.0
	host.dodge_time = 0.0
	host.dodge_duration_current = 0.0
	host.dodge_direction = Vector2.ZERO
	host.sprint_key = KEY_NONE
	host.movement_mode = "G-MODE"
	host.vore_flash = 0.45
	host.vore_component.save_progress()
	host.update_hud("G MODE: biomass exoskeleton active for 10 seconds.")

func update_g_mode(delta: float) -> void:
	if not host.g_mode: return
	host.g_mode_time = maxf(host.g_mode_time - delta, 0.0)
	if host.g_mode_time <= 0.0:
		host.g_mode = false
		host.movement_mode = "WALK"
		host.active_intake_route = "CORE"
		host.update_hud("G mode ended. Linxi returned to T mode.")


func update_animation(delta: float) -> void:
	var direction: Vector2 = input_direction()
	var moving: bool = direction.length_squared() > 0.01 and not host.digesting and not host.player_defeated
	var fps: float = host.player_visual_component.animation_fps(host.movement_mode, moving, direction)
	host.player_animation_time = fmod(host.player_animation_time + delta * fps, 16.0)
	_update_footstep_audio(delta, moving)


func _update_footstep_audio(delta: float, moving: bool) -> void:
	var can_step: bool = moving and host.player_height <= 0.0 and host.movement_mode in ["WALK", "SPRINT", "G-MODE"]
	if not can_step:
		host.footstep_timer = 0.0
		return
	host.footstep_timer -= delta
	if host.footstep_timer > 0.0:
		return
	if is_instance_valid(host.audio_component):
		host.audio_component.play_footstep()
	host.footstep_timer = 0.22 if host.movement_mode == "SPRINT" else 0.36

func damage(damage_value: int, source: Dictionary = {}) -> void:
	var applied := maxi(damage_value - (host.balance.g_mode_armor if host.g_mode else 0), 0)
	host.player_health = maxi(host.player_health - applied, 0)
	host.player_invulnerability = 0.48
	host.player_hurt_flash = 0.16
	host.player_hit_reaction_duration = 0.1
	host.player_hit_reaction_time = host.player_hit_reaction_duration
	var source_facing := float(source.get("facing", -host.facing))
	host.spawn_hit_effect(host.player_ground, -source_facing)
	host.hit_stop = 0.075
	if is_instance_valid(host.audio_component):
		host.audio_component.play_player_hurt()
	host.attack_cooldown = 0.0
	host.attack_duration_current = 0.0
	if is_instance_valid(host.combat_component):
		host.combat_component.reset_running_attack()
	host.combo_step = 0
	if host.player_health <= 0:
		host.player_defeated = true
		host.movement_mode = "DOWN"
		host.update_hud("Linxi is down. Retry from the area's entry checkpoint.")
		host.show_defeat_panel()
	else:
		host.update_hud("Linxi took %d damage. Invulnerable briefly." % applied)
