extends Node

const HANDGUN_RANGE_X := 520.0
const HANDGUN_RANGE_DEPTH := 72.0
const KNIFE_RANGE_X := 380.0
const KNIFE_RANGE_DEPTH := 66.0
const KNIFE_DAMAGE := 4
const KNIFE_THROW_SPEED := 760.0
const KNIFE_GRAVITY := 760.0
const KNIFE_INITIAL_HEIGHT := 42.0
const KNIFE_INITIAL_VERTICAL_SPEED := 145.0
const KNIFE_HIT_RANGE_X := 34.0
const KNIFE_HIT_RANGE_DEPTH := 42.0
const KNIFE_KNOCKBACK_DISTANCE := 120.0
const KNIFE_TEXTURE: Texture2D = preload("res://assets/props/red_night/weapons/dropped_knife.png")
const KNIFE_PROJECTILE_SIZE := Vector2(58.0, 34.0)

var host: Node


func setup(value: Node) -> void:
	host = value


func initialize_body_weapon() -> void:
	host.body_weapon = "claws"
	host.body_weapon_name = "Claws"
	clear_temporary_weapon(false)
	clear_projectiles()


func equip_from_item(item: Dictionary) -> void:
	var weapon_id := String(item.get("weapon_id", "handgun")).to_lower()
	var display_name := String(item.get("name", "Human Weapon"))
	var uses := maxi(int(item.get("ammo", 1)), 1)
	if has_temporary_weapon():
		_drop_equipped_weapon(host.player_ground + Vector2(-float(host.facing) * 24.0, 4.0))
		host.update_hud("Linxi drops %s and picks up %s." % [host.equipped_weapon_name, display_name])
	host.equipped_weapon = weapon_id
	host.equipped_weapon_name = display_name
	host.temporary_weapon_uses = 1 if weapon_id == "knife" else uses
	host.update_hud("Picked up %s (%d use%s). It will be discarded when spent." % [display_name, host.temporary_weapon_uses, "" if host.temporary_weapon_uses == 1 else "s"])


func _drop_equipped_weapon(position: Vector2) -> void:
	if not has_temporary_weapon():
		return
	var weapon_id: String = String(host.equipped_weapon).to_lower()
	var prop_id: String = "dropped_%s" % weapon_id
	host.scene_items.append({
		"id": "swapped_%s_%d" % [weapon_id, Time.get_ticks_msec()],
		"type": "weapon",
		"weapon_id": weapon_id,
		"name": host.equipped_weapon_name,
		"prop_id": prop_id,
		"ammo": host.temporary_weapon_uses,
		"active": true,
		"position": position,
		"render_above_knocked_down": true,
	})


func has_temporary_weapon() -> bool:
	return not host.equipped_weapon.is_empty() and host.temporary_weapon_uses > 0


func display_name() -> String:
	if has_temporary_weapon():
		return "%s [%d]" % [host.equipped_weapon_name, host.temporary_weapon_uses]
	return "Body: %s" % host.body_weapon_name


func try_use_temporary_weapon() -> bool:
	if not has_temporary_weapon(): return false
	if host.digesting or host.player_defeated or host.player_hit_reaction_time > 0.0 or host.attack_cooldown > 0.0 or host.dodge_time > 0.0: return true
	match host.equipped_weapon:
		"handgun": _fire_handgun()
		"knife": _throw_knife()
		_: clear_temporary_weapon(true)
	return true


func _fire_handgun() -> void:
	host.attack_cooldown = 0.34
	host.attack_duration_current = 0.0
	var target_index: int = host.enemy_component.nearest_target_in_range(HANDGUN_RANGE_X, HANDGUN_RANGE_DEPTH, true)
	if target_index >= 0:
		_damage_target(target_index, host.balance.attack_damage(host.biomass), 0.035)
	consume_use("The handgun is empty. Linxi drops it and returns to her claws.")


func _throw_knife() -> void:
	host.attack_cooldown = 0.42
	host.attack_duration_current = 0.0
	var direction := Vector2(float(host.facing), 0.0)
	host.weapon_projectiles.append({
		"weapon_id": "knife",
		"position": host.player_ground + Vector2(float(host.facing) * 34.0, -4.0),
		"velocity": direction * KNIFE_THROW_SPEED,
		"height": KNIFE_INITIAL_HEIGHT,
		"vertical_velocity": KNIFE_INITIAL_VERTICAL_SPEED,
		"spin": 0.0,
		"spin_speed": 18.0 * float(host.facing),
		"life": 0.85,
		"broken": false,
	})
	consume_use("")


func _damage_target(target_index: int, damage: int, stop_time: float) -> void:
	var enemy: Dictionary = host.enemies[target_index]
	var applied_damage: int = host.enemy_component.apply_damage(target_index, damage)
	host.enemy_component.apply_hit_reaction(target_index, host.balance.attack_stun(0.1, applied_damage))
	host.spawn_hit_effect(Vector2(enemy["position"]), float(enemy["facing"]))
	host.enemy_component.sync_legacy_target(target_index)
	host.hit_stop = stop_time


func consume_use(empty_message: String) -> void:
	host.temporary_weapon_uses = maxi(host.temporary_weapon_uses - 1, 0)
	if host.temporary_weapon_uses > 0: return
	clear_temporary_weapon(false)
	if not empty_message.is_empty(): host.update_hud(empty_message)


func clear_temporary_weapon(show_message: bool = false) -> void:
	var old_name: String = host.equipped_weapon_name
	host.equipped_weapon = ""
	host.equipped_weapon_name = ""
	host.temporary_weapon_uses = 0
	if show_message and not old_name.is_empty():
		host.update_hud("Discarded %s. Body weapon restored: %s." % [old_name, host.body_weapon_name])


func clear_projectiles() -> void:
	if host != null:
		host.weapon_projectiles.clear()


func drop_weapon_from_enemy(enemy: Dictionary) -> void:
	var weapon_id := String(enemy.get("weapon_id", "")).to_lower()
	if weapon_id != "knife" or bool(enemy.get("weapon_dropped", false)):
		return
	enemy["weapon_dropped"] = true
	var position := Vector2(enemy.get("position", Vector2.ZERO)) + Vector2(float(enemy.get("facing", 1.0)) * -18.0, 4.0)
	host.scene_items.append({
		"id": "dropped_knife_%s" % String(enemy.get("id", host.scene_items.size())),
		"type": "weapon",
		"weapon_id": "knife",
		"name": "Knife",
		"prop_id": "dropped_knife",
		"ammo": 1,
		"active": true,
		"position": position,
		"render_above_knocked_down": true,
	})


func update_projectiles(delta: float) -> void:
	for index in range(host.weapon_projectiles.size() - 1, -1, -1):
		var projectile: Dictionary = host.weapon_projectiles[index]
		projectile["life"] = float(projectile.get("life", 0.0)) - delta
		projectile["position"] = Vector2(projectile.get("position", Vector2.ZERO)) + Vector2(projectile.get("velocity", Vector2.ZERO)) * delta
		projectile["height"] = maxf(float(projectile.get("height", 0.0)) + float(projectile.get("vertical_velocity", 0.0)) * delta, 0.0)
		projectile["vertical_velocity"] = float(projectile.get("vertical_velocity", 0.0)) - KNIFE_GRAVITY * delta
		projectile["spin"] = float(projectile.get("spin", 0.0)) + float(projectile.get("spin_speed", 0.0)) * delta
		if _try_projectile_hit(projectile):
			host.weapon_projectiles.remove_at(index)
			continue
		if float(projectile.get("height", 0.0)) <= 0.0 or float(projectile.get("life", 0.0)) <= 0.0 or _projectile_out_of_bounds(projectile):
			host.weapon_projectiles.remove_at(index)
			host.update_hud("The thrown knife breaks on the ground.")


func _try_projectile_hit(projectile: Dictionary) -> bool:
	var position := Vector2(projectile.get("position", Vector2.ZERO))
	var direction := signf(Vector2(projectile.get("velocity", Vector2.RIGHT)).x)
	if direction == 0.0:
		direction = float(host.facing)
	for index in range(host.enemies.size()):
		var enemy: Dictionary = host.enemies[index]
		if enemy["state"] in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED", "KNOCKED_DOWN"]:
			continue
		if int(enemy.get("health", 0)) <= 0:
			continue
		var enemy_position := Vector2(enemy.get("position", Vector2.ZERO))
		var range_x: float = KNIFE_HIT_RANGE_X + host.enemy_shadow_radius(enemy) * 0.45
		var range_depth: float = KNIFE_HIT_RANGE_DEPTH + host.enemy_shadow_depth_radius(enemy)
		if absf(enemy_position.x - position.x) > range_x or absf(enemy_position.y - position.y) > range_depth:
			continue
		var applied_damage: int = host.enemy_component.apply_damage(index, KNIFE_DAMAGE)
		if int(enemy["health"]) > 0:
			_knockback_enemy(index, direction)
		host.enemy_component.apply_hit_reaction(index, host.balance.attack_stun(0.1, applied_damage))
		host.spawn_hit_effect(enemy_position, direction)
		host.enemy_component.sync_legacy_target(index)
		host.hit_stop = maxf(host.hit_stop, 0.045)
		return true
	return false


func _knockback_enemy(index: int, direction: float) -> void:
	if index < 0 or index >= host.enemies.size():
		return
	var enemy: Dictionary = host.enemies[index]
	var previous := Vector2(enemy.get("position", Vector2.ZERO))
	var desired := previous + Vector2(direction * KNIFE_KNOCKBACK_DISTANCE, 0.0)
	desired.x = clampf(desired.x, host.ground_min_x, host.ground_width)
	desired.y = clampf(desired.y, 0.0, host.ground_depth)
	enemy["position"] = host.resolve_map_blockers(previous, desired)


func _projectile_out_of_bounds(projectile: Dictionary) -> bool:
	var position := Vector2(projectile.get("position", Vector2.ZERO))
	return position.x < host.ground_min_x - 80.0 or position.x > host.ground_width + 80.0 or position.y < -80.0 or position.y > host.ground_depth + 80.0


func draw_projectile(screen_position: Vector2, projectile: Dictionary) -> void:
	if KNIFE_TEXTURE == null:
		return
	var xform := Transform2D(float(projectile.get("spin", 0.0)), screen_position)
	host.draw_set_transform_matrix(xform)
	host.draw_texture_rect(KNIFE_TEXTURE, Rect2(-KNIFE_PROJECTILE_SIZE * 0.5, KNIFE_PROJECTILE_SIZE), false, Color.WHITE)
	host.draw_set_transform(Vector2.ZERO)


func restore_temporary_weapon(data) -> void:
	clear_temporary_weapon(false)
	if not data is Dictionary: return
	var uses := maxi(int(data.get("uses", 0)), 0)
	if uses <= 0: return
	host.equipped_weapon = String(data.get("weapon_id", ""))
	host.equipped_weapon_name = String(data.get("weapon_name", "Human Weapon"))
	host.temporary_weapon_uses = uses


func serialize_temporary_weapon() -> Dictionary:
	if not has_temporary_weapon(): return {}
	return {
		"weapon_id": host.equipped_weapon,
		"weapon_name": host.equipped_weapon_name,
		"uses": host.temporary_weapon_uses,
	}
