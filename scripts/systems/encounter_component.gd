extends Node

const Progression = preload("res://scripts/data/linxi_progression.gd")
const AUTOSAVE_INTERVAL := 1.0

var host: Node
var autosave_time := 0.0
var mission_complete := false


func setup(value: Node) -> void:
	host = value


func reset() -> void:
	discard_provisional_progress()
	_reset_runtime()
	save_state()


func _reset_runtime() -> void:
	host.player_ground = host.player_spawn
	host.enemy_component.reset_enemies()
	host.interaction_component.reset_items()
	host.weapon_component.clear_temporary_weapon(false)
	host.weapon_component.clear_projectiles()
	if host.dialogue_active: host.dialogue_component.close()
	host.camera_x = 0.0
	host.player_height = 0.0
	host.player_health = host.player_max_health
	host.player_invulnerability = 0.0
	host.player_hurt_flash = 0.0
	host.player_hit_reaction_time = 0.0
	host.player_hit_reaction_duration = 0.0
	host.player_defeated = false
	host.vertical_velocity = 0.0
	host.facing = 1.0
	host.attack_cooldown = 0.0
	host.attack_duration_current = 0.0
	host.combat_component.reset_running_attack()
	host.combat_component.reset_running_attack_cooldown()
	host.combo_timeout = 0.0
	host.combo_step = 0
	host.clean_hits = 0
	host.evolved = false
	host.enemy_contained = false
	host.contained_prey_weight = 0.0
	host.story_control_locked = false
	host.story_pose = ""
	host.story_pose_time = 0.0
	host.story_overlay = ""
	host.vore_component.clear_route_loads()
	host.occupied_vore_capacity = 0
	host.digest_progress = 0.0
	host.digesting = false
	host.hit_stop = 0.0
	host.dodge_time = 0.0
	host.dodge_duration_current = 0.0
	host.dodge_cooldown = 0.0
	host.dodge_direction = Vector2.ZERO
	host.vore_flash = 0.0
	host.hit_effects.clear()
	host.sprint_key = KEY_NONE
	host.last_tap_time_by_key.clear()
	host.movement_mode = "WALK"
	host.g_mode = false
	host.g_mode_time = 0.0
	host.active_intake_route = "CORE"
	mission_complete = false
	host.update_hud(host.map_data.objective if host.map_data != null else "Encounter reset.")
	host.queue_redraw()


func update_autosave(delta: float) -> void:
	if not host.story_component.handles_completion() and not mission_complete and not host.enemies.is_empty() and host.enemy_component.living_count() == 0:
		mission_complete = true
		host.update_hud("MISSION COMPLETE - press Enter to settle rewards and return to the safe house.")
	autosave_time += delta
	if autosave_time < AUTOSAVE_INTERVAL: return
	autosave_time = 0.0


func save_state() -> void:
	if host.map_data == null: return
	var root := _read_save_root()
	root["encounter_state"] = {
		"map_id": host.map_data.map_id,
		"encounter_id": host.map_data.encounter_id,
		"player_ground": _vector_to_data(host.player_ground),
		"player_health": host.player_health,
		"player_height": host.player_height,
		"facing": host.facing,
		"clean_hits": host.clean_hits,
		"evolved": host.evolved,
		"enemies": _serialize_enemies(),
		"items": _serialize_items(),
		"temporary_weapon": host.weapon_component.serialize_temporary_weapon(),
		"contained_prey_weight": host.contained_prey_weight,
		"occupied_vore_capacity": host.occupied_vore_capacity,
		"contained_route_loads": host.contained_route_loads.duplicate(true),
		"digest_progress": host.digest_progress,
		"enemy_contained": host.enemy_contained,
		"mission_complete": mission_complete,
		"story_state": host.story_component.serialize_state(),
		"mission_progress": _mission_progress(),
	}
	_write_save_root(root)


func load_state() -> bool:
	if host.map_data == null: return false
	var root := _read_save_root()
	var state = root.get("encounter_state", {})
	if not state is Dictionary or state.is_empty(): return false
	if String(state.get("map_id", "")) != host.map_data.map_id: return false
	if String(state.get("encounter_id", "")) != host.map_data.encounter_id: return false
	_restore_mission_progress(state.get("mission_progress", {}))
	host.player_ground = _data_to_vector(state.get("player_ground", []), host.player_spawn)
	host.player_health = clampi(int(state.get("player_health", host.player_max_health)), 0, host.player_max_health)
	host.player_height = maxf(float(state.get("player_height", 0.0)), 0.0)
	host.facing = float(state.get("facing", 1.0))
	host.clean_hits = maxi(int(state.get("clean_hits", 0)), 0)
	host.evolved = bool(state.get("evolved", false))
	_restore_enemies(state.get("enemies", []))
	_restore_items(state.get("items", []))
	host.weapon_component.restore_temporary_weapon(state.get("temporary_weapon", {}))
	host.contained_prey_weight = maxf(float(state.get("contained_prey_weight", 0.0)), 0.0)
	host.occupied_vore_capacity = maxi(int(state.get("occupied_vore_capacity", 0)), 0)
	host.vore_component.clear_route_loads()
	var loads = state.get("contained_route_loads", {})
	if loads is Dictionary:
		for region in host.contained_route_loads:
			host.contained_route_loads[region] = maxi(int(loads.get(region, 0)), 0)
	host.digest_progress = clampf(float(state.get("digest_progress", 0.0)), 0.0, host.vore_component.total_digest_duration())
	host.enemy_contained = bool(state.get("enemy_contained", false)) and host.occupied_vore_capacity > 0
	mission_complete = bool(state.get("mission_complete", false))
	host.story_component.restore_state(state.get("story_state", {}))
	host.story_component.apply_restored_phase_state()
	host.digesting = false
	host.enemy_component.sync_legacy_target(host.enemy_component.nearest_enemy_index())
	host.update_hud("Restored %s." % host.map_data.display_name)
	return true


func settle_and_return() -> void:
	if not mission_complete:
		host.update_hud("Finish the encounter before settling mission rewards.")
		return
	commit_progress()
	get_tree().change_scene_to_file("res://scenes/safe_house.tscn")


func commit_progress() -> void:
	var root := _read_save_root()
	root.merge(_mission_progress(), true)
	root.erase("encounter_state")
	_write_save_root(root)


func commit_route_checkpoint(route_checkpoint: Dictionary) -> void:
	var root := _read_save_root()
	root.merge(_mission_progress(), true)
	root["route_checkpoint"] = route_checkpoint.duplicate(true)
	root.erase("encounter_state")
	_write_save_root(root)


func discard_provisional_progress() -> void:
	var root := _read_save_root()
	root.erase("encounter_state")
	_write_save_root(root)
	for route in host.unlocked_intake_routes:
		host.unlocked_intake_routes[route] = route == "CORE"
	if host.should_load_saved_progress():
		host.vore_component.load_progress()
	else:
		host.reset_player_progress_to_defaults()


func retry_current_map() -> void:
	# Keep the last committed route/body checkpoint, but remove this failed
	# attempt's local enemies, item changes, damage, and provisional story state.
	discard_provisional_progress()
	var error := host.get_tree().reload_current_scene()
	if error != OK:
		host.player_defeated = false
		host.update_hud("Could not reload this area: %s" % error_string(error))


func _mission_progress() -> Dictionary:
	return {
		"balance_version": Progression.CURRENT_BALANCE_VERSION,
		"permanent_weight": host.permanent_weight,
		"biomass": host.balance.clamp_biomass(host.biomass),
		"vore_capacity": host.vore_capacity,
		"weight_speed_debuff_disabled": host.weight_speed_debuff_disabled,
		"player_max_health": host.player_max_health,
		"player_health": clampi(host.player_health, 0, host.player_max_health),
		"unlocked_intake_routes": host.vore_component.saved_routes(),
		"story_flags": host.story_flags.duplicate(true),
		"contained_prey_weight": host.contained_prey_weight,
		"occupied_vore_capacity": host.occupied_vore_capacity,
		"contained_route_loads": host.contained_route_loads.duplicate(true),
		"digest_progress": host.digest_progress,
		"enemy_contained": host.enemy_contained and host.occupied_vore_capacity > 0,
	}


func _restore_mission_progress(value) -> void:
	if not value is Dictionary: return
	host.permanent_weight = maxf(float(value.get("permanent_weight", host.permanent_weight)), 0.5)
	host.biomass = host.balance.clamp_biomass(float(value.get("biomass", host.biomass)))
	host.vore_capacity = maxi(int(value.get("vore_capacity", host.vore_capacity)), 1)
	host.weight_speed_debuff_disabled = bool(value.get("weight_speed_debuff_disabled", host.weight_speed_debuff_disabled))
	host.player_max_health = maxi(int(value.get("player_max_health", host.player_max_health)), host.balance.unit_health)
	host.player_health = clampi(int(value.get("player_health", host.player_health)), 0, host.player_max_health)
	if value.get("story_flags", {}) is Dictionary: host.story_flags = Dictionary(value.get("story_flags", {})).duplicate(true)
	host.contained_prey_weight = maxf(float(value.get("contained_prey_weight", host.contained_prey_weight)), 0.0)
	host.occupied_vore_capacity = maxi(int(value.get("occupied_vore_capacity", host.occupied_vore_capacity)), 0)
	host.vore_component.clear_route_loads()
	var loads = value.get("contained_route_loads", {})
	if loads is Dictionary:
		for region in host.contained_route_loads:
			host.contained_route_loads[region] = maxi(int(loads.get(region, 0)), 0)
	host.digest_progress = clampf(float(value.get("digest_progress", host.digest_progress)), 0.0, host.vore_component.total_digest_duration())
	host.enemy_contained = bool(value.get("enemy_contained", host.enemy_contained)) and host.occupied_vore_capacity > 0
	for route_name in value.get("unlocked_intake_routes", []):
		var route := String(route_name).to_upper()
		if host.unlocked_intake_routes.has(route): host.unlocked_intake_routes[route] = true


func _serialize_enemies() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for enemy in host.enemies:
		result.append({
			"id": String(enemy.get("id", "")),
			"archetype": String(enemy.get("archetype", enemy.get("id", ""))),
			"position": _vector_to_data(Vector2(enemy["position"])),
			"health": int(enemy["health"]),
			"max_health": int(enemy.get("max_health", host.balance.unit_health)),
			"state": String(enemy["state"]),
			"state_time": float(enemy["state_time"]),
			"facing": float(enemy["facing"]),
			"attack_facing": float(enemy.get("attack_facing", enemy["facing"])),
			"family": int(enemy["family"]),
			"appearance_id": int(enemy.get("appearance_id", 0)),
			"shadow_radius": float(enemy.get("shadow_radius", host.enemy_shadow_radius(enemy))),
			"attack_type": String(enemy.get("attack_type", "NORMAL")),
			"armor_class": maxi(int(enemy.get("armor_class", 0)), 0),
			"prey_weight": maxf(float(enemy.get("prey_weight", 1.0)), 0.0),
			"vore_visual_load": maxi(int(enemy.get("vore_visual_load", 1)), 1),
			"ai_profile": String(enemy.get("ai_profile", "STANDARD")),
			"embedded_knives": int(enemy.get("embedded_knives", 0)),
			"weapon_id": String(enemy.get("weapon_id", "")),
			"weapon_dropped": bool(enemy.get("weapon_dropped", false)),
			"story_group": String(enemy.get("story_group", "")),
			"display_name": String(enemy.get("display_name", "")),
			"boss": bool(enemy.get("boss", false)),
			"boss_name": String(enemy.get("boss_name", enemy.get("display_name", ""))),
			"boss_approach_range": float(enemy.get("boss_approach_range", 520.0)),
			"boss_engaged": bool(enemy.get("boss_engaged", false)),
			"vore_locked_until_group_defeated": String(enemy.get("vore_locked_until_group_defeated", "")),
			"ai_frozen": bool(enemy.get("ai_frozen", false)),
			"special_cooldown": float(enemy.get("special_cooldown", 0.0)),
			"special_strike_index": int(enemy.get("special_strike_index", 0)),
			"special_strike_time": float(enemy.get("special_strike_time", 0.0)),
			"special_visual_frame": int(enemy.get("special_visual_frame", 0)),
		})
	return result


func _restore_enemies(serialized) -> void:
	if not serialized is Array or serialized.is_empty(): return
	host.enemies.clear()
	for saved in serialized:
		if not saved is Dictionary: continue
		host.enemies.append({
			"id": String(saved.get("id", "")),
			"archetype": String(saved.get("archetype", saved.get("id", ""))),
			"position": _data_to_vector(saved.get("position", []), host.player_spawn),
			"health": clampi(int(saved.get("health", host.balance.unit_health)), 0, int(saved.get("max_health", host.balance.unit_health))),
			"max_health": maxi(int(saved.get("max_health", host.balance.unit_health)), 1),
			"state": String(saved.get("state", "APPROACH")),
			"state_time": maxf(float(saved.get("state_time", 0.0)), 0.0),
			"facing": float(saved.get("facing", -1.0)),
			"attack_facing": float(saved.get("attack_facing", saved.get("facing", -1.0))),
			"hit_reaction_time": 0.0,
			"hit_reaction_duration": 0.0,
			"family": int(saved.get("family", host.EnemyFamily.HUMAN)),
			"appearance_id": int(saved.get("appearance_id", 0)),
			"shadow_radius": float(saved.get("shadow_radius", host.HUMAN_SHADOW_RADIUS)),
			"attack_type": String(saved.get("attack_type", "NORMAL")),
			"armor_class": maxi(int(saved.get("armor_class", 0)), 0),
			"prey_weight": maxf(float(saved.get("prey_weight", 1.0)), 0.0),
			"vore_visual_load": maxi(int(saved.get("vore_visual_load", 1)), 1),
			"ai_profile": String(saved.get("ai_profile", "STANDARD")),
			"embedded_knives": maxi(int(saved.get("embedded_knives", 0)), 0),
			"weapon_id": String(saved.get("weapon_id", "")),
			"weapon_dropped": bool(saved.get("weapon_dropped", false)),
			"story_group": String(saved.get("story_group", "")),
			"display_name": String(saved.get("display_name", "")),
			"boss": bool(saved.get("boss", false)),
			"boss_name": String(saved.get("boss_name", saved.get("display_name", ""))),
			"boss_approach_range": float(saved.get("boss_approach_range", 520.0)),
			"boss_engaged": bool(saved.get("boss_engaged", false)),
			"vore_locked_until_group_defeated": String(saved.get("vore_locked_until_group_defeated", "")),
			"ai_frozen": bool(saved.get("ai_frozen", false)),
			"attack_target_index": -1,
			"special_cooldown": maxf(float(saved.get("special_cooldown", 0.0)), 0.0),
			"special_strike_index": clampi(int(saved.get("special_strike_index", 0)), 0, 3),
			"special_strike_time": maxf(float(saved.get("special_strike_time", 0.0)), 0.0),
			"special_visual_frame": clampi(int(saved.get("special_visual_frame", 0)), 0, 5),
		})


func _serialize_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in host.scene_items:
		var serialized: Dictionary = item.duplicate(true)
		if serialized.has("position"):
			serialized["position"] = _vector_to_data(Vector2(serialized["position"]))
		result.append(serialized)
	return result


func _restore_items(serialized) -> void:
	if not serialized is Array: return
	var state_by_id := {}
	for saved in serialized:
		if saved is Dictionary: state_by_id[String(saved.get("id", ""))] = saved
	for item in host.scene_items:
		var id := String(item.get("id", ""))
		if not state_by_id.has(id): continue
		var saved_item: Dictionary = state_by_id[id]
		item["active"] = bool(saved_item.get("active", true))
		item["emptied"] = bool(saved_item.get("emptied", false))
		if saved_item.has("position"):
			item["position"] = _data_to_vector(saved_item.get("position", []), Vector2(item.get("position", host.player_spawn)))
		if String(saved_item.get("type", "")) != "":
			item["type"] = String(saved_item.get("type", ""))
		if String(saved_item.get("weapon_id", "")) != "":
			item["weapon_id"] = String(saved_item.get("weapon_id", ""))
		if String(saved_item.get("prop_id", "")) != "":
			item["prop_id"] = String(saved_item.get("prop_id", ""))
		if saved_item.has("ammo"):
			item["ammo"] = int(saved_item.get("ammo", 1))
		if String(saved_item.get("event_id", "")) != "":
			item["event_id"] = String(saved_item.get("event_id", ""))
		if String(saved_item.get("name", "")) != "":
			item["name"] = String(saved_item.get("name", ""))
	for id in state_by_id:
		var exists := false
		for item in host.scene_items:
			if String(item.get("id", "")) == id:
				exists = true
				break
		if exists:
			continue
		var saved_dynamic: Dictionary = state_by_id[id]
		if String(saved_dynamic.get("type", "")) == "weapon":
			var restored := saved_dynamic.duplicate(true)
			restored["position"] = _data_to_vector(saved_dynamic.get("position", []), host.player_spawn)
			host.scene_items.append(restored)


func _read_save_root() -> Dictionary:
	var path: String = host.progress_save_path()
	if not FileAccess.file_exists(path): return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return {}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK: return {}
	var data = parser.data
	return data if data is Dictionary else {}


func _write_save_root(root: Dictionary) -> void:
	var file := FileAccess.open(host.progress_save_path(), FileAccess.WRITE)
	if file == null:
		push_warning("Could not save encounter state.")
		return
	file.store_string(JSON.stringify(root))


func _vector_to_data(value: Vector2) -> Array[float]:
	return [value.x, value.y]


func _data_to_vector(value, fallback: Vector2) -> Vector2:
	if value is Array and value.size() >= 2: return Vector2(float(value[0]), float(value[1]))
	return fallback
