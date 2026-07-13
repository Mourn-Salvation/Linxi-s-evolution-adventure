class_name LinxiProgression
extends RefCounted

const CURRENT_BALANCE_VERSION := 4


static func normalize_save(data: Dictionary, base_health: int, legacy_max_health: int, maximum_biomass: float = 50.0) -> Dictionary:
	var normalized := {
		"balance_version": CURRENT_BALANCE_VERSION,
		"permanent_weight": maxf(float(data.get("permanent_weight", 1.0)), 0.5),
		"biomass": clampf(float(data.get("biomass", 0.0)), 0.0, maximum_biomass),
		"vore_capacity": maxi(int(data.get("vore_capacity", 1)), 1),
		"weight_speed_debuff_disabled": bool(data.get("weight_speed_debuff_disabled", false)),
		"player_max_health": base_health,
		"player_health": base_health,
		"unlocked_intake_routes": ["CORE"],
		"story_flags": {},
		"route_checkpoint": {},
		"contained_prey_weight": maxf(float(data.get("contained_prey_weight", 0.0)), 0.0),
		"occupied_vore_capacity": maxi(int(data.get("occupied_vore_capacity", 0)), 0),
		"contained_route_loads": {},
		"digest_progress": maxf(float(data.get("digest_progress", 0.0)), 0.0),
		"enemy_contained": false,
	}
	var saved_health := int(data.get("player_max_health", base_health))
	if int(data.get("balance_version", 1)) < 2:
		saved_health = base_health + maxi(saved_health - legacy_max_health, 0)
	normalized["player_max_health"] = maxi(saved_health, base_health)
	normalized["player_health"] = clampi(int(data.get("player_health", normalized["player_max_health"])), 0, int(normalized["player_max_health"]))
	var routes: Array[String] = ["CORE"]
	for route in data.get("unlocked_intake_routes", []):
		var normalized_route := String(route).to_upper()
		if normalized_route in ["CORE", "LEFT", "RIGHT", "UPPER", "LOWER", "BURST"] and normalized_route not in routes:
			routes.append(normalized_route)
	normalized["unlocked_intake_routes"] = routes
	if data.get("story_flags", {}) is Dictionary:
		normalized["story_flags"] = Dictionary(data.get("story_flags", {})).duplicate(true)
	if data.get("route_checkpoint", {}) is Dictionary:
		normalized["route_checkpoint"] = Dictionary(data.get("route_checkpoint", {})).duplicate(true)
	if data.get("contained_route_loads", {}) is Dictionary:
		var route_loads := {}
		for region in ["BELLY", "CHEST", "LOWER_BELLY", "GROIN"]:
			route_loads[region] = maxi(int(Dictionary(data.get("contained_route_loads", {})).get(region, 0)), 0)
		normalized["contained_route_loads"] = route_loads
	normalized["enemy_contained"] = bool(data.get("enemy_contained", false)) and int(normalized["occupied_vore_capacity"]) > 0
	return normalized
