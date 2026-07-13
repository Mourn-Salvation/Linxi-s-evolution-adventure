extends Node

const BoneBladeEliteProfileScript = preload("res://scripts/enemies/profiles/bone_blade_elite_profile.gd")

const PERSONAL_SPACE_X := 72.0
const PERSONAL_SPACE_DEPTH := 38.0
const AI_STANDARD := "STANDARD"
const AI_NEUTRAL_WANDER := "NEUTRAL_WANDER"
const AI_NON_COMBAT_WANDER := "NON_COMBAT_WANDER"
const AI_ZOMBIE_CHASE_HUMAN := "ZOMBIE_CHASE_HUMAN"

var host: Node
var bone_blade_elite_profile: BoneBladeEliteProfile

func setup(value: Node) -> void:
	host = value
	bone_blade_elite_profile = BoneBladeEliteProfileScript.new()
	bone_blade_elite_profile.setup(host, self)

func reset_enemies() -> void:
	host.enemies.clear()
	if host.map_data == null:
		push_warning("No map data available for enemy placement.")
		return
	for definition in host.map_data.enemy_spawns:
		var position := Vector2(definition.get("position", host.player_spawn))
		position.x = clampf(position.x, host.ground_min_x, host.ground_width)
		position.y = clampf(position.y, 0.0, host.ground_depth)
		# Map-authored spawn points can sit a few pixels inside blocker art. Resolve
		# them once here so the first AI step does not remain pinned in place.
		position = host.resolve_map_blockers(position, position)
		var family: int = family_from_name(String(definition.get("family", "HUMAN")))
		var appearance_id: int = int(definition.get("appearance_id", host.enemies.size() % 4))
		var max_health := maxi(int(definition.get("max_health", definition.get("health", host.balance.unit_health))), 1)
		var health := clampi(int(definition.get("initial_health", definition.get("health", max_health))), 0, max_health)
		host.enemies.append({
			"id": String(definition.get("id", "enemy_%d" % host.enemies.size())),
			"archetype": String(definition.get("archetype", definition.get("id", "enemy"))),
			"position": position,
			"health": health,
			"max_health": max_health,
			"state": String(definition.get("initial_state", "APPROACH")).to_upper(),
			"state_time": 0.0,
			"facing": float(definition.get("facing", -1.0)),
			"attack_facing": float(definition.get("facing", -1.0)),
			"hit_reaction_time": 0.0,
			"hit_reaction_duration": 0.0,
			"family": family,
			"appearance_id": appearance_id if family == host.EnemyFamily.ZOMBIE else int(definition.get("appearance_id", 0)),
			"shadow_radius": float(definition.get("shadow_radius", _default_shadow_radius(family))),
			"attack_type": String(definition.get("attack_type", "NORMAL")).to_upper(),
			"armor_class": maxi(int(definition.get("armor_class", 0)), 0),
			"prey_weight": maxf(float(definition.get("prey_weight", 1.0)), 0.0),
			"vore_visual_load": maxi(int(definition.get("vore_visual_load", 1)), 1),
			"ai_profile": String(definition.get("ai_profile", AI_STANDARD)).to_upper(),
			"embedded_knives": 0,
			"weapon_id": String(definition.get("weapon_id", _default_weapon_id(family, int(definition.get("appearance_id", 0))))).to_lower(),
			"weapon_dropped": false,
			"story_group": String(definition.get("story_group", "")),
			"display_name": String(definition.get("display_name", definition.get("id", ""))),
			"boss": bool(definition.get("boss", false)),
			"boss_name": String(definition.get("boss_name", definition.get("display_name", definition.get("id", "")))),
			"boss_approach_range": float(definition.get("boss_approach_range", 520.0)),
			"boss_engaged": bool(definition.get("boss_engaged", false)),
			"vore_locked_until_group_defeated": String(definition.get("vore_locked_until_group_defeated", "")),
			"ai_frozen": bool(definition.get("ai_frozen", false)),
			"neutral_direction": float(definition.get("neutral_direction", -1.0)),
			"neutral_initialized": false,
			"attack_target_index": -1,
			"special_cooldown": float(definition.get("special_cooldown", 0.0)),
			"special_strike_index": 0,
			"special_strike_time": 0.0,
			"special_visual_frame": 0,
		})
	sync_legacy_target(nearest_enemy_index(false))


func family_from_name(family_name: String) -> int:
	match family_name.to_upper():
		"ZOMBIE": return host.EnemyFamily.ZOMBIE
		"MUTANT", "MUTANT_CREATURE": return host.EnemyFamily.MUTANT_CREATURE
		_: return host.EnemyFamily.HUMAN


func _default_shadow_radius(family: int) -> float:
	match family:
		host.EnemyFamily.ZOMBIE:
			return host.ZOMBIE_SHADOW_RADIUS
		host.EnemyFamily.MUTANT_CREATURE:
			return host.MUTANT_SHADOW_RADIUS
		_:
			return host.HUMAN_SHADOW_RADIUS


func _default_weapon_id(family: int, appearance_id: int) -> String:
	if family == host.EnemyFamily.HUMAN and appearance_id in [6, 7]:
		return "knife"
	return ""

func update(delta: float) -> void:
	for index in range(host.enemies.size()):
		var enemy: Dictionary = host.enemies[index]
		if enemy["state"] in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED"]: continue
		enemy["hit_reaction_time"] = maxf(float(enemy.get("hit_reaction_time", 0.0)) - delta, 0.0)
		if int(enemy["health"]) <= 0:
			enemy["state"] = "KNOCKED_DOWN"
			host.weapon_component.drop_weapon_from_enemy(enemy)
			continue
		if bool(enemy.get("ai_frozen", false)):
			continue
		# A committed cast owns its direction until recovery ends. Keep the actor's
		# general facing synchronized so renderers and AI branches cannot retarget it.
		if _is_attack_committed(enemy):
			enemy["facing"] = attack_facing_for(enemy)
		if _uses_non_combat_profile(enemy):
			var previous_neutral_position: Vector2 = enemy["position"]
			_update_neutral_wander(index, delta)
			enemy["position"] = host.resolve_map_blockers(previous_neutral_position, Vector2(enemy["position"]))
			var neutral_position: Vector2 = enemy["position"]
			neutral_position.x = clampf(neutral_position.x, host.ground_min_x, host.ground_width)
			neutral_position.y = clampf(neutral_position.y, 0.0, host.ground_depth)
			enemy["position"] = neutral_position
			continue
		if _uses_zombie_chase_human_profile(enemy):
			var previous_chase_position: Vector2 = enemy["position"]
			var chase_target_position: Vector2 = _movement_target_position(enemy, previous_chase_position)
			_update_zombie_chase_human(index, delta)
			enemy["position"] = _resolve_enemy_step(previous_chase_position, Vector2(enemy["position"]), chase_target_position, delta)
			var chase_position: Vector2 = enemy["position"]
			chase_position.x = clampf(chase_position.x, host.ground_min_x, host.ground_width)
			chase_position.y = clampf(chase_position.y, 0.0, host.ground_depth)
			enemy["position"] = chase_position
			continue
		if bone_blade_elite_profile.matches(enemy):
			var previous_elite_position: Vector2 = enemy["position"]
			if not _is_attack_committed(enemy) and absf(host.player_ground.x - previous_elite_position.x) > 1.0:
				enemy["facing"] = signf(host.player_ground.x - previous_elite_position.x)
			bone_blade_elite_profile.update(index, delta)
			if String(enemy.get("state", "")) == "APPROACH":
				enemy["position"] = _resolve_enemy_step(previous_elite_position, Vector2(enemy["position"]), host.player_ground, delta)
			else:
				enemy["position"] = host.resolve_map_blockers(previous_elite_position, Vector2(enemy["position"]))
			var elite_position: Vector2 = enemy["position"]
			elite_position.x = clampf(elite_position.x, host.ground_min_x, host.ground_width)
			elite_position.y = clampf(elite_position.y, 0.0, host.ground_depth)
			enemy["position"] = elite_position
			continue
		var position: Vector2 = enemy["position"]
		if not _is_attack_committed(enemy) and absf(host.player_ground.x - position.x) > 1.0:
			enemy["facing"] = signf(host.player_ground.x - position.x)
		enemy["state_time"] = maxf(float(enemy["state_time"]) - delta, 0.0)
		match String(enemy["state"]):
			"STAGGER":
				if enemy["state_time"] <= 0.0: enemy["state"] = "APPROACH"
			"TELEGRAPH", "HEAVY_TELEGRAPH":
				if enemy["state_time"] <= 0.0: resolve_human_attack(index)
			"RECOVER":
				if enemy["state_time"] <= 0.0: enemy["state"] = "APPROACH"
			"NEUTRAL":
				enemy["state"] = "APPROACH"
				approach_human(index, delta)
			"APPROACH": approach_human(index, delta)
		enemy["position"] = _resolve_enemy_step(position, Vector2(enemy["position"]), host.player_ground, delta)
		position = enemy["position"]
		position.x = clampf(position.x, host.ground_min_x, host.ground_width)
		position.y = clampf(position.y, 0.0, host.ground_depth)
		enemy["position"] = position
	sync_legacy_target(nearest_enemy_index(false))

func approach_human(index: int, delta: float) -> void:
	var enemy: Dictionary = host.enemies[index]
	var position: Vector2 = enemy["position"]
	var horizontal: float = host.player_ground.x - position.x
	var depth: float = host.player_ground.y - position.y
	var attack_range: float = attack_range_for(enemy)
	var depth_range: float = depth_range_for(enemy)
	var movement := Vector2.ZERO
	if absf(depth) > depth_range * 0.7:
		var depth_speed: float = host.balance.human_depth_speed * (0.72 if int(enemy["family"]) == host.EnemyFamily.ZOMBIE else 1.0)
		movement.y = signf(depth) * depth_speed
	elif absf(horizontal) > attack_range:
		var move_speed: float = host.balance.human_move_speed * (0.72 if int(enemy["family"]) == host.EnemyFamily.ZOMBIE else 1.0)
		movement.x = signf(horizontal) * move_speed
	else:
		var elite: bool = bone_blade_elite_profile.matches(enemy)
		var heavy: bool = elite or String(enemy.get("attack_type", "NORMAL")) == "HEAVY"
		var windup: float = host.balance.bone_blade_normal_windup_time if elite else (host.balance.human_heavy_telegraph_time if heavy else host.balance.human_telegraph_time)
		start_attack_cast(enemy, "HEAVY_TELEGRAPH" if heavy else "TELEGRAPH", windup, signf(horizontal))
		host.update_hud("Heavy attack: casting cannot be interrupted. Dodge away." if heavy else "A Human Guard telegraphs an attack. Hit them or leave the lane.")
		return
	movement += separation_force(index)
	enemy["position"] = position + movement.limit_length(host.balance.human_move_speed) * delta


func _resolve_enemy_step(previous_position: Vector2, desired_position: Vector2, target_position: Vector2, delta: float) -> Vector2:
	var resolved: Vector2 = host.resolve_map_blockers(previous_position, desired_position)
	var requested_distance := previous_position.distance_to(desired_position)
	if requested_distance <= 0.01 or previous_position.distance_to(resolved) > 0.05:
		return resolved
	var target_offset := target_position - previous_position
	if target_offset.length_squared() <= 0.01:
		return resolved
	var fallback_distance: float = maxf(requested_distance, host.balance.human_move_speed * delta * 0.72)
	var direct_desired: Vector2 = previous_position + target_offset.normalized() * fallback_distance
	var direct_resolved: Vector2 = host.resolve_map_blockers(previous_position, direct_desired)
	if previous_position.distance_to(direct_resolved) > previous_position.distance_to(resolved):
		return direct_resolved
	return resolved


func _movement_target_position(enemy: Dictionary, from_position: Vector2) -> Vector2:
	if _uses_zombie_chase_human_profile(enemy):
		var target_index := _nearest_human_prey_index(from_position)
		if target_index >= 0:
			return Vector2(host.enemies[target_index]["position"])
	return host.player_ground

func _uses_neutral_wander_profile(enemy: Dictionary) -> bool:
	return String(enemy.get("ai_profile", AI_STANDARD)) == AI_NEUTRAL_WANDER

func _uses_non_combat_profile(enemy: Dictionary) -> bool:
	var ai_profile := String(enemy.get("ai_profile", AI_STANDARD))
	return ai_profile == AI_NEUTRAL_WANDER or ai_profile == AI_NON_COMBAT_WANDER

func _uses_zombie_chase_human_profile(enemy: Dictionary) -> bool:
	return String(enemy.get("ai_profile", AI_STANDARD)) == AI_ZOMBIE_CHASE_HUMAN and int(enemy.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.ZOMBIE

func _is_human_student(enemy: Dictionary) -> bool:
	return int(enemy.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.HUMAN and String(enemy.get("archetype", enemy.get("id", ""))) == "human_student"

func _is_human_prey(enemy: Dictionary) -> bool:
	if not _is_human_student(enemy):
		return false
	if int(enemy.get("health", 0)) <= 0:
		return false
	return String(enemy.get("state", "")) not in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED", "KNOCKED_DOWN"]

func _nearest_human_prey_index(from_position: Vector2) -> int:
	var best_index := -1
	var best_distance := INF
	for candidate_index in range(host.enemies.size()):
		var candidate: Dictionary = host.enemies[candidate_index]
		if not _is_human_prey(candidate):
			continue
		var distance := from_position.distance_squared_to(Vector2(candidate["position"]))
		if distance < best_distance:
			best_distance = distance
			best_index = candidate_index
	return best_index

func _update_neutral_wander(index: int, delta: float) -> void:
	var enemy: Dictionary = host.enemies[index]
	if String(enemy["state"]) == "STAGGER":
		enemy["state_time"] = maxf(float(enemy["state_time"]) - delta, 0.0)
		if float(enemy["state_time"]) <= 0.0:
			enemy["state"] = "NEUTRAL"
		return
	if String(enemy["state"]) != "NEUTRAL":
		enemy["state"] = "NEUTRAL"
		enemy["state_time"] = 0.0
	var position: Vector2 = enemy["position"]
	if not bool(enemy.get("neutral_initialized", false)):
		enemy["neutral_initialized"] = true
		enemy["state_time"] = 1.0 + 0.35 * float((index % 3))
	elif float(enemy["state_time"]) <= 0.0:
		enemy["neutral_direction"] = -float(enemy.get("neutral_direction", -1.0))
		enemy["state_time"] = 1.0 + 0.35 * float((index % 3))
	else:
		enemy["state_time"] = maxf(float(enemy["state_time"]) - delta, 0.0)
	var direction: Vector2 = Vector2(float(enemy.get("neutral_direction", -1.0)), sin(Time.get_ticks_msec() * 0.0017 + index) * 0.28).limit_length(1.0)
	if absf(direction.x) > 0.01:
		enemy["facing"] = signf(direction.x)
	var speed: float = host.balance.human_move_speed * (0.92 if String(enemy.get("ai_profile", AI_STANDARD)) == AI_NON_COMBAT_WANDER else 0.28)
	enemy["position"] = position + direction * speed * delta + separation_force(index) * 0.18 * delta

func _update_zombie_chase_human(index: int, delta: float) -> void:
	var enemy: Dictionary = host.enemies[index]
	enemy["state_time"] = maxf(float(enemy["state_time"]) - delta, 0.0)
	match String(enemy["state"]):
		"STAGGER":
			if enemy["state_time"] <= 0.0:
				enemy["state"] = "APPROACH"
		"TELEGRAPH", "HEAVY_TELEGRAPH":
			if enemy["state_time"] <= 0.0:
				_resolve_zombie_human_attack(index)
		"RECOVER":
			if enemy["state_time"] <= 0.0:
				enemy["state"] = "APPROACH"
		"APPROACH", "NEUTRAL":
			_approach_human_prey(index, delta)
		_:
			enemy["state"] = "APPROACH"

func _approach_human_prey(index: int, delta: float) -> void:
	var enemy: Dictionary = host.enemies[index]
	var position: Vector2 = enemy["position"]
	var target_index := _nearest_human_prey_index(position)
	if target_index < 0:
		enemy["state"] = "APPROACH"
		enemy["attack_target_index"] = -1
		approach_human(index, delta)
		return
	var target: Dictionary = host.enemies[target_index]
	var target_position := Vector2(target["position"])
	var horizontal: float = target_position.x - position.x
	var depth: float = target_position.y - position.y
	var attack_range: float = attack_range_for(enemy)
	var depth_range: float = depth_range_for(enemy)
	if absf(horizontal) > 1.0:
		enemy["facing"] = signf(horizontal)
	var movement := Vector2.ZERO
	if absf(depth) > depth_range * 0.62:
		movement.y = signf(depth) * host.balance.human_depth_speed * 0.72
	elif absf(horizontal) > attack_range * 0.72:
		movement.x = signf(horizontal) * host.balance.human_move_speed * 0.78
	else:
		enemy["attack_target_index"] = target_index
		start_attack_cast(enemy, "TELEGRAPH", host.balance.human_telegraph_time, signf(horizontal))
		return
	movement += separation_force(index)
	enemy["position"] = position + movement.limit_length(host.balance.human_move_speed * 0.82) * delta

func _resolve_zombie_human_attack(index: int) -> void:
	var enemy: Dictionary = host.enemies[index]
	var target_index := int(enemy.get("attack_target_index", -1))
	if target_index < 0 or target_index >= host.enemies.size() or not _is_human_prey(host.enemies[target_index]):
		target_index = _nearest_human_prey_index(Vector2(enemy["position"]))
		if target_index < 0:
			# A civilian can be knocked down while this cast is already committed.
			# Continue the same cast against Linxi instead of playing a harmless attack.
			enemy["attack_target_index"] = -1
			resolve_human_attack(index)
			return
	if target_index >= 0:
		var target: Dictionary = host.enemies[target_index]
		var offset: Vector2 = Vector2(target["position"]) - Vector2(enemy["position"])
		var attack_facing: float = attack_facing_for(enemy)
		var horizontal_range: float = attack_range_for(enemy) + host.enemy_shadow_radius(enemy) + host.enemy_shadow_radius(target)
		var depth_range: float = depth_range_for(enemy) + host.enemy_shadow_depth_radius(enemy) + host.enemy_shadow_depth_radius(target)
		var in_attack_direction: bool = absf(offset.x) <= host.enemy_shadow_radius(enemy) * 0.35 or signf(offset.x) == attack_facing
		var can_hit: bool = in_attack_direction and absf(offset.x) <= horizontal_range and absf(offset.y) <= depth_range
		if can_hit:
			target["health"] = maxi(int(target["health"]) - host.balance.unit_attack, 0)
			target["hit_reaction_duration"] = 0.16
			target["hit_reaction_time"] = 0.16
			if int(target["health"]) <= 0:
				target["state"] = "KNOCKED_DOWN"
				target["state_time"] = 0.0
			elif String(target.get("state", "")) != "STAGGER":
				target["state"] = "STAGGER"
				target["state_time"] = 0.16
	enemy["attack_target_index"] = -1
	enemy["state"] = "RECOVER"
	enemy["state_time"] = host.balance.human_recovery_time

func separation_force(index: int) -> Vector2:
	var force := Vector2.ZERO
	var position: Vector2 = host.enemies[index]["position"]
	for other_index in range(host.enemies.size()):
		if other_index == index: continue
		var other: Dictionary = host.enemies[other_index]
		if not is_solid_for_movement(other): continue
		var offset: Vector2 = position - Vector2(other["position"])
		if absf(offset.x) < PERSONAL_SPACE_X and absf(offset.y) < PERSONAL_SPACE_DEPTH:
			if absf(offset.x) < 0.1: offset.x = -1.0 if index < other_index else 1.0
			force += offset.normalized() * host.balance.human_move_speed
	return force


func is_solid_for_movement(enemy: Dictionary) -> bool:
	return String(enemy.get("state", "")) not in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED", "KNOCKED_DOWN"] and int(enemy.get("health", 0)) > 0

func resolve_human_attack(index: int) -> void:
	var enemy: Dictionary = host.enemies[index]
	var position: Vector2 = enemy["position"]
	var horizontal_offset: float = host.player_ground.x - position.x
	var horizontal: float = absf(horizontal_offset)
	var depth: float = absf(host.player_ground.y - position.y)
	var attack_facing: float = attack_facing_for(enemy)
	var in_attack_direction: bool = absf(horizontal_offset) <= host.enemy_shadow_radius(enemy) * 0.35 or signf(horizontal_offset) == attack_facing
	var can_hit: bool = in_attack_direction and horizontal <= attack_range_for(enemy) + host.enemy_shadow_radius(enemy) + host.player_shadow_radius() and depth <= depth_range_for(enemy) + host.enemy_shadow_depth_radius(enemy) + host.player_shadow_depth_radius() and host.player_height <= 55.0
	if can_hit and host.player_invulnerability <= 0.0 and host.dodge_time <= 0.0:
		var damage: int = host.balance.human_heavy_attack_damage if String(enemy.get("attack_type", "NORMAL")) == "HEAVY" else host.balance.unit_attack
		host.player_component.damage(damage, {
			"position": position,
			"facing": attack_facing,
		})
	enemy["state"] = "RECOVER"
	enemy["state_time"] = host.balance.human_recovery_time

func apply_hit_reaction(index: int, stun_duration: float = 0.1) -> bool:
	if index < 0 or index >= host.enemies.size(): return false
	var enemy: Dictionary = host.enemies[index]
	if int(enemy["health"]) <= 0:
		enemy["state"] = "KNOCKED_DOWN"
		enemy["state_time"] = 0.0
		enemy["hit_reaction_time"] = 0.0
		host.weapon_component.drop_weapon_from_enemy(enemy)
		return true
	var hurt_duration := maxf(stun_duration, 0.001)
	enemy["hit_reaction_duration"] = hurt_duration
	enemy["hit_reaction_time"] = float(enemy["hit_reaction_duration"])
	if String(enemy["state"]) == "HEAVY_TELEGRAPH":
		return false
	if bone_blade_elite_profile.matches(enemy) and bone_blade_elite_profile.is_special_state(enemy):
		return false
	_reset_interruptible_attack_cast(enemy, hurt_duration)
	return true


func apply_damage(index: int, raw_damage: int) -> int:
	if index < 0 or index >= host.enemies.size():
		return 0
	var enemy: Dictionary = host.enemies[index]
	var armor_class: int = maxi(int(enemy.get("armor_class", 0)), 0)
	var applied_damage: int = maxi(raw_damage - armor_class, 0)
	enemy["health"] = maxi(int(enemy.get("health", 0)) - applied_damage, 0)
	return applied_damage


func _reset_interruptible_attack_cast(enemy: Dictionary, hurt_duration: float) -> void:
	enemy["state"] = "STAGGER"
	enemy["state_time"] = hurt_duration
	enemy["attack_facing"] = float(enemy.get("facing", -1.0))


func start_attack_cast(enemy: Dictionary, state: String, duration: float, desired_facing: float) -> void:
	var locked_facing := desired_facing
	if absf(locked_facing) < 0.1:
		locked_facing = float(enemy.get("facing", -1.0))
	locked_facing = signf(locked_facing)
	if absf(locked_facing) < 0.1:
		locked_facing = -1.0
	enemy["attack_facing"] = locked_facing
	enemy["facing"] = locked_facing
	enemy["state"] = state
	enemy["state_time"] = duration


func attack_facing_for(enemy: Dictionary) -> float:
	var value := float(enemy.get("attack_facing", enemy.get("facing", -1.0)))
	if absf(value) < 0.1:
		value = float(enemy.get("facing", -1.0))
	if absf(value) < 0.1:
		return -1.0
	return signf(value)


func _is_attack_committed(enemy: Dictionary) -> bool:
	return String(enemy.get("state", "")) in ["TELEGRAPH", "HEAVY_TELEGRAPH", "RECOVER", "SPECIAL_TELEGRAPH", "SPECIAL_RUSH", "SPECIAL_RECOVER"]


func attack_range_for(enemy: Dictionary) -> float:
	if int(enemy.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.ZOMBIE:
		return host.balance.zombie_attack_range
	return host.balance.human_attack_range


func depth_range_for(enemy: Dictionary) -> float:
	if int(enemy.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.ZOMBIE:
		return host.balance.zombie_depth_range
	return host.balance.human_depth_range

func nearest_enemy_index(include_knocked_down: bool = true) -> int:
	var best_index := -1
	var best_distance := INF
	for index in range(host.enemies.size()):
		var enemy: Dictionary = host.enemies[index]
		if enemy["state"] in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED"]: continue
		if not include_knocked_down and int(enemy["health"]) <= 0: continue
		var distance: float = host.player_ground.distance_squared_to(Vector2(enemy["position"]))
		if distance < best_distance:
			best_distance = distance
			best_index = index
	return best_index

func targets_in_range(range_x: float, range_depth: float) -> Array[int]:
	var candidates: Array[Dictionary] = []
	for index in range(host.enemies.size()):
		var enemy: Dictionary = host.enemies[index]
		if enemy["state"] in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED"]: continue
		if not can_be_vored(enemy): continue
		var offset: Vector2 = Vector2(enemy["position"]) - host.player_ground
		if absf(offset.x) > range_x or absf(offset.y) > range_depth: continue
		candidates.append({"index": index, "distance": offset.length_squared()})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["distance"]) < float(b["distance"]))
	var result: Array[int] = []
	for candidate in candidates: result.append(int(candidate["index"]))
	return result


func can_be_vored(enemy: Dictionary) -> bool:
	var locked_group := String(enemy.get("vore_locked_until_group_defeated", "")).strip_edges()
	if locked_group.is_empty():
		return true
	return is_group_defeated(locked_group)


func is_group_defeated(group_id: String) -> bool:
	var normalized := group_id.strip_edges()
	if normalized.is_empty():
		return true
	var found := false
	for enemy in host.enemies:
		if String(enemy.get("story_group", "")) != normalized:
			continue
		found = true
		if int(enemy.get("health", 0)) > 0 and String(enemy.get("state", "")) not in ["DIGESTED", "CONTAINED", "ESCAPED"]:
			return false
	return found

func nearest_target_in_attack(input_tag: String, range_x: float, range_depth: float) -> int:
	var best_index := -1
	var best_distance := INF
	for index in range(host.enemies.size()):
		var enemy: Dictionary = host.enemies[index]
		if enemy["state"] in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED"]: continue
		var offset: Vector2 = Vector2(enemy["position"]) - host.player_ground
		var effective_range_x: float = range_x + host.player_shadow_radius() + host.enemy_shadow_radius(enemy)
		var effective_range_depth: float = range_depth + host.player_shadow_depth_radius() + host.enemy_shadow_depth_radius(enemy)
		var in_volume := false
		match input_tag:
			"LEFT": in_volume = offset.x <= 0.0 and absf(offset.x) <= effective_range_x and absf(offset.y) <= effective_range_depth
			"RIGHT": in_volume = offset.x >= 0.0 and absf(offset.x) <= effective_range_x and absf(offset.y) <= effective_range_depth
			"UP": in_volume = offset.y <= 0.0 and absf(offset.x) <= effective_range_x and absf(offset.y) <= effective_range_depth
			"DOWN": in_volume = offset.y >= 0.0 and absf(offset.x) <= effective_range_x and absf(offset.y) <= effective_range_depth
			_: in_volume = signf(offset.x) == host.facing and absf(offset.x) <= effective_range_x and absf(offset.y) <= effective_range_depth
		if in_volume and offset.length_squared() < best_distance:
			best_distance = offset.length_squared()
			best_index = index
	return best_index

func count_combatants() -> int:
	var count := 0
	for enemy in host.enemies:
		if enemy["state"] not in ["DORMANT", "ESCAPED"]: count += 1
	return count

func nearest_target_in_range(range_x: float, range_depth: float, require_facing: bool = false) -> int:
	var best_index := -1
	var best_distance := INF
	for index in range(host.enemies.size()):
		var enemy: Dictionary = host.enemies[index]
		if enemy["state"] in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED"]: continue
		var position: Vector2 = enemy["position"]
		var offset: Vector2 = position - host.player_ground
		var effective_range_x: float = range_x + host.player_shadow_radius() + host.enemy_shadow_radius(enemy)
		var effective_range_depth: float = range_depth + host.player_shadow_depth_radius() + host.enemy_shadow_depth_radius(enemy)
		if absf(offset.x) > effective_range_x or absf(offset.y) > effective_range_depth: continue
		if require_facing and signf(offset.x) != host.facing: continue
		var distance: float = offset.length_squared()
		if distance < best_distance:
			best_distance = distance
			best_index = index
	return best_index

func living_count() -> int:
	var count := 0
	for enemy in host.enemies:
		if int(enemy["health"]) > 0 and enemy["state"] not in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED"]: count += 1
	return count

func sync_legacy_target(index: int) -> void:
	host.active_enemy_index = index

func family_name() -> String: return "HUMAN"
