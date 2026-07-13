extends Node

const Progression = preload("res://scripts/data/linxi_progression.gd")
const DISABLED_INTAKE_ROUTES := ["UPPER", "LOWER", "BURST"]
const DISABLED_EXPANSION_REGIONS := ["CHEST", "LOWER_BELLY", "GROIN"]

var host: Node

func setup(value: Node) -> void: host = value

func prey_capacity_cost(enemy: Dictionary = {}) -> int:
	return maxi(ceili(enemy_prey_weight(enemy)), 1)
func biomass_capacity_bonus() -> int: return host.balance.capacity_bonus(host.biomass)
func effective_capacity() -> int: return host.vore_capacity + biomass_capacity_bonus() + (host.balance.g_mode_capacity_bonus if host.g_mode else 0)
func available_capacity() -> int: return maxi(effective_capacity() - host.occupied_vore_capacity, 0)
func has_capacity(enemy: Dictionary = {}) -> bool: return available_capacity() >= prey_capacity_cost(enemy)
func current_weight() -> float: return host.permanent_weight + host.contained_prey_weight
func live_chance() -> float:
	return host.balance.live_vore_chance(host.biomass, host.g_mode)
func enemy_prey_weight(enemy: Dictionary = {}) -> float:
	return maxf(float(enemy.get("prey_weight", 1.0)), 0.0)


func enemy_visual_load(enemy: Dictionary = {}) -> int:
	return maxi(int(enemy.get("vore_visual_load", 1)), 1)
func route_region(route_name: String) -> String:
	match route_name:
		"UPPER": return "CHEST"
		"LOWER": return "LOWER_BELLY"
		"BURST": return "GROIN"
		_: return "BELLY"

func is_route_enabled(route_name: String) -> bool:
	return not DISABLED_INTAKE_ROUTES.has(route_name.to_upper())

func is_region_enabled(region_name: String) -> bool:
	return not DISABLED_EXPANSION_REGIONS.has(region_name.to_upper())

func clear_route_loads() -> void:
	for region in host.contained_route_loads:
		host.contained_route_loads[region] = 0

func record_route_key(keycode: Key) -> void:
	host.g_route_timestamps[keycode] = Time.get_ticks_msec() / 1000.0

func select_route() -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	var requested := "CORE"
	if now - float(host.g_route_timestamps.get(KEY_A, -10.0)) <= host.balance.route_input_window: requested = "LEFT"
	elif now - float(host.g_route_timestamps.get(KEY_D, -10.0)) <= host.balance.route_input_window: requested = "RIGHT"
	elif now - float(host.g_route_timestamps.get(KEY_W, -10.0)) <= host.balance.route_input_window: requested = "UPPER"
	elif now - float(host.g_route_timestamps.get(KEY_S, -10.0)) <= host.balance.route_input_window: requested = "LOWER"
	elif now - host.last_v_press_time <= host.balance.route_input_window: requested = "BURST"
	host.last_v_press_time = now
	if not is_route_available(requested):
		host.active_intake_route = "CORE"
		host.update_hud("%s intake route is locked. Continue the story to unlock it." % requested.capitalize())
		return false
	host.active_intake_route = requested
	return true

func is_route_available(route_name: String) -> bool:
	var normalized := route_name.to_upper()
	if not is_route_enabled(normalized):
		return false
	return host.g_mode or bool(host.unlocked_intake_routes.get(normalized, false))

func unlock_route(route_name: String) -> bool:
	var normalized := route_name.to_upper()
	if not host.unlocked_intake_routes.has(normalized):
		push_warning("Unknown intake route: %s" % route_name)
		return false
	if not is_route_enabled(normalized):
		host.update_hud("%s intake route is disabled in the current demo scope." % normalized.capitalize())
		return false
	if bool(host.unlocked_intake_routes[normalized]): return true
	host.unlocked_intake_routes[normalized] = true
	save_progress()
	host.update_hud("Plot skill unlocked: %s intake route." % normalized.capitalize())
	return true

func saved_routes() -> Array[String]:
	var routes: Array[String] = []
	for route_name in host.unlocked_intake_routes:
		if bool(host.unlocked_intake_routes[route_name]): routes.append(String(route_name))
	return routes

func try_vore() -> void:
	if host.player_defeated or host.digesting: return
	if available_capacity() <= 0:
		host.world_fx_component.show_player_message("NOT ENOUGH ROOM FOR THIS PREY")
		host.update_hud("Vore capacity is full (%d/%d). Digest contained prey to free capacity." % [host.occupied_vore_capacity, effective_capacity()])
		return
	if host.player_height > 0.0:
		host.update_hud("Vore requires Linxi to be grounded.")
		return

	var targets: Array[int] = host.enemy_component.targets_in_range(host.balance.vore_range_x, host.balance.vore_range_depth)
	if targets.is_empty():
		host.update_hud("Vore requires close range and matching depth.")
		return

	var intake_limit := mini(host.balance.g_mode_batch_limit if host.g_mode else 1, available_capacity())
	var swallowed := 0
	var resisted := 0
	var insufficient_capacity := false
	for target_index in targets:
		if swallowed >= intake_limit: break
		var target: Dictionary = host.enemies[target_index]
		if not has_capacity(target):
			insufficient_capacity = true
			continue
		var chance := 1.0 if target["state"] == "KNOCKED_DOWN" else live_chance()
		if randf() <= chance:
			if swallow_enemy(target_index):
				swallowed += 1
		else:
			resisted += 1
	if insufficient_capacity:
		host.world_fx_component.show_player_message("NOT ENOUGH ROOM FOR THIS PREY")

	if swallowed == 0:
		if insufficient_capacity:
			var nearest_cost := prey_capacity_cost(host.enemies[targets[0]])
			host.update_hud("Not enough room for this prey. Requires %d free slots; %d available." % [nearest_cost, available_capacity()])
			return
		host.update_hud("Live Vore resisted. Current success chance: %d%%." % roundi(live_chance() * 100.0))
		return
	host.player_hit_reaction_time = 0.0
	host.player_hurt_flash = 0.0
	host.start_vore_execution(0.22)
	if is_instance_valid(host.audio_component):
		host.audio_component.play_vore_swallow()
	var capacity_note := " Some prey require more free slots." if insufficient_capacity else ""
	host.update_hud("Swallowed %d prey via %s route. Capacity %d/%d%s.%s Hold L to digest." % [swallowed, host.active_intake_route, host.occupied_vore_capacity, effective_capacity(), " (%d resisted)" % resisted if resisted > 0 else "", capacity_note])

func swallow_enemy(target_index: int) -> bool:
	if target_index < 0 or target_index >= host.enemies.size(): return false
	var target: Dictionary = host.enemies[target_index]
	if not has_capacity(target) or target["state"] in ["CONTAINED", "DIGESTED"]: return false
	target["state"] = "CONTAINED"
	if is_instance_valid(host.audio_component):
		if int(target.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.HUMAN:
			host.audio_component.play_human_prey_scream()
		else:
			host.audio_component.play_monster_prey_scream()
	host.enemy_contained = true
	host.occupied_vore_capacity += prey_capacity_cost(target)
	host.contained_prey_weight += enemy_prey_weight(target)
	var region := route_region(host.active_intake_route)
	if not is_region_enabled(region):
		region = "BELLY"
	host.contained_route_loads[region] = int(host.contained_route_loads.get(region, 0)) + enemy_visual_load(target)
	host.digest_progress = 0.0
	host.player_max_health += 1
	host.vore_flash = 0.5
	host.hit_stop = 0.16
	save_progress()
	return true

func digest_seconds_per_current_prey() -> float:
	return host.balance.digest_seconds(host.biomass)

func total_digest_duration() -> float: return digest_seconds_per_current_prey() * maxf(float(host.occupied_vore_capacity), 1.0)
func digest_ratio() -> float: return clampf(host.digest_progress / total_digest_duration(), 0.0, 1.0)

func update_digest(delta: float) -> void:
	host.digesting = host.enemy_contained and (Input.is_key_pressed(KEY_L) or host.mobile_digest_held) and not host.player_defeated
	if not host.digesting: return
	host.digest_progress += delta
	host.movement_mode = "DIGEST"
	resolve_completed_digest_progress()

func resolve_completed_digest_progress() -> void:
	while host.occupied_vore_capacity > 0 and host.digest_progress >= digest_seconds_per_current_prey():
		host.digest_progress -= digest_seconds_per_current_prey()
		digest_one_prey()
	if host.occupied_vore_capacity <= 0:
		host.digest_progress = 0.0
		host.digesting = false
		if not host.player_defeated: host.movement_mode = "WALK"

func exit_digest_mode() -> void:
	if not host.digesting: return
	host.digesting = false
	if not host.player_defeated: host.movement_mode = "WALK"
	host.update_hud("Digestion paused at %d%%. Attack, jump, and dodge are available." % roundi(digest_ratio() * 100.0))

func finish_digest() -> void:
	var total_gained_biomass: float = 0.0
	var total_healed: int = 0
	while host.occupied_vore_capacity > 0:
		var result: Dictionary = digest_one_prey(false)
		total_gained_biomass += float(result.get("biomass", 0.0))
		total_healed += int(result.get("healed", 0))
	host.digesting = false
	host.digest_progress = 0.0
	host.movement_mode = "WALK"
	save_progress()
	host.update_hud("Digestion complete. Biomass increased by %.2f. HP restored by %d." % [total_gained_biomass, total_healed])

func digest_one_prey(update_message := true) -> Dictionary:
	if host.occupied_vore_capacity <= 0:
		return {"biomass": 0.0, "healed": 0}
	if is_instance_valid(host.audio_component):
		host.audio_component.play_vore_burp()
	var prey_weight: float = float(host.contained_prey_weight) / maxf(float(host.occupied_vore_capacity), 1.0)
	var biomass_before: float = host.biomass
	host.biomass = host.balance.clamp_biomass(host.biomass + host.balance.digested_biomass(prey_weight))
	var gained_biomass: float = host.biomass - biomass_before
	var health_before: int = host.player_health
	host.player_health = mini(host.player_health + 1, host.player_max_health)
	var healed: int = host.player_health - health_before
	if is_instance_valid(host.audio_component):
		host.audio_component.play_digest_finish()
	_mark_one_contained_enemy_digested()
	host.contained_prey_weight = maxf(host.contained_prey_weight - prey_weight, 0.0)
	host.occupied_vore_capacity = maxi(host.occupied_vore_capacity - 1, 0)
	_consume_one_route_load()
	if host.occupied_vore_capacity <= 0:
		host.contained_prey_weight = 0.0
		clear_route_loads()
		host.enemy_contained = false
		host.digest_progress = 0.0
	else:
		host.enemy_contained = true
	if update_message:
		save_progress()
		host.update_hud("Digested 1 prey. Biomass +%.2f, HP +%d. Remaining prey: %d." % [gained_biomass, healed, host.occupied_vore_capacity])
	return {"biomass": gained_biomass, "healed": healed}

func _mark_one_contained_enemy_digested() -> void:
	for enemy in host.enemies:
		if enemy["state"] == "CONTAINED":
			enemy["state"] = "DIGESTED"
			return

func _consume_one_route_load() -> void:
	var preferred_regions := ["BELLY", "CHEST", "LOWER_BELLY", "GROIN"]
	for region in preferred_regions:
		if int(host.contained_route_loads.get(region, 0)) > 0:
			host.contained_route_loads[region] = int(host.contained_route_loads[region]) - 1
			return
	for region in host.contained_route_loads:
		if int(host.contained_route_loads.get(region, 0)) > 0:
			host.contained_route_loads[region] = int(host.contained_route_loads[region]) - 1
			return

func save_progress() -> void:
	if is_instance_valid(host.encounter_component): host.encounter_component.save_state()
func load_progress() -> void:
	if not FileAccess.file_exists(host.progress_save_path()): return
	var file := FileAccess.open(host.progress_save_path(), FileAccess.READ)
	if file == null: return
	var data = JSON.parse_string(file.get_as_text())
	if not data is Dictionary: return
	var normalized: Dictionary = Progression.normalize_save(data, host.balance.unit_health, host.balance.legacy_max_health, host.balance.maximum_biomass)
	host.permanent_weight = float(normalized["permanent_weight"])
	host.biomass = host.balance.clamp_biomass(float(normalized["biomass"]))
	host.vore_capacity = int(normalized["vore_capacity"])
	host.weight_speed_debuff_disabled = bool(normalized["weight_speed_debuff_disabled"])
	host.player_max_health = int(normalized["player_max_health"])
	host.player_health = clampi(int(normalized.get("player_health", host.player_max_health)), 0, host.player_max_health)
	if normalized.get("story_flags", {}) is Dictionary:
		host.story_flags = Dictionary(normalized.get("story_flags", {})).duplicate(true)
	if normalized.get("route_checkpoint", {}) is Dictionary:
		host.route_checkpoint = Dictionary(normalized.get("route_checkpoint", {})).duplicate(true)
	host.contained_prey_weight = maxf(float(normalized.get("contained_prey_weight", 0.0)), 0.0)
	host.occupied_vore_capacity = maxi(int(normalized.get("occupied_vore_capacity", 0)), 0)
	clear_route_loads()
	var loads = normalized.get("contained_route_loads", {})
	if loads is Dictionary:
		for region in host.contained_route_loads:
			host.contained_route_loads[region] = maxi(int(loads.get(region, 0)), 0)
	host.digest_progress = clampf(float(normalized.get("digest_progress", 0.0)), 0.0, total_digest_duration())
	host.enemy_contained = bool(normalized.get("enemy_contained", false)) and host.occupied_vore_capacity > 0
	for route_name in normalized["unlocked_intake_routes"]:
		if host.unlocked_intake_routes.has(route_name): host.unlocked_intake_routes[route_name] = true
