extends Node

const INTERACTION_RANGE_X := 105.0
const INTERACTION_RANGE_DEPTH := 62.0

var host: Node

func setup(value: Node) -> void:
	host = value

func reset_items() -> void:
	host.scene_items.clear()
	if host.map_data == null:
		push_warning("No map data available for item placement.")
		return
	for definition in host.map_data.items:
		var item: Dictionary = definition.duplicate(true)
		item["position"] = Vector2(definition.get("position", host.player_spawn))
		item["active"] = bool(definition.get("active", true))
		host.scene_items.append(item)


func update_auto_triggers() -> void:
	if host.dialogue_component.is_active() or host.transition_confirm_panel.is_open() or host.player_defeated or host.digesting:
		return
	for index in range(host.scene_items.size()):
		var item: Dictionary = host.scene_items[index]
		if not bool(item.get("active", true)) or not bool(item.get("auto_trigger", false)):
			continue
		if not is_item_unlocked(item):
			continue
		var offset: Vector2 = Vector2(item["position"]) - host.player_ground
		var range_x := float(item.get("trigger_range_x", INTERACTION_RANGE_X))
		var range_depth := float(item.get("trigger_range_depth", INTERACTION_RANGE_DEPTH))
		if absf(offset.x) > range_x or absf(offset.y) > range_depth:
			continue
		_trigger_item(index)
		return

func nearest_item_index() -> int:
	var best_index := -1
	var best_distance := INF
	for index in range(host.scene_items.size()):
		var item: Dictionary = host.scene_items[index]
		if not bool(item.get("active", true)):
			continue
		var offset: Vector2 = Vector2(item["position"]) - host.player_ground
		if absf(offset.x) > INTERACTION_RANGE_X or absf(offset.y) > INTERACTION_RANGE_DEPTH:
			continue
		var distance: float = offset.length_squared()
		if distance < best_distance:
			best_distance = distance
			best_index = index
	return best_index

func interact() -> void:
	if host.dialogue_component.is_active():
		host.dialogue_component.advance()
		return
	if host.player_defeated or host.digesting:
		return
	var index := nearest_item_index()
	if index < 0:
		host.update_hud("There is nothing close enough to interact with.")
		return
	var item: Dictionary = host.scene_items[index]
	if not is_item_unlocked(item):
		host.update_hud(String(item.get("locked_message", "This interaction is not available yet.")))
		return
	_trigger_item(index)


func _trigger_item(index: int) -> void:
	var item: Dictionary = host.scene_items[index]
	var item_type := String(item.get("type", "dialogue"))
	var choice_data_for_save = item.get("choice", {})
	var completion_data_for_save = item.get("completion_effects", {})
	var has_delayed_dialogue_result := item_type == "dialogue" and ((choice_data_for_save is Dictionary and not Dictionary(choice_data_for_save).is_empty()) or (completion_data_for_save is Dictionary and not Dictionary(completion_data_for_save).is_empty()))
	var save_provisional := bool(item.get("save_on_trigger", not has_delayed_dialogue_result))
	match item_type:
		"weapon":
			host.weapon_component.equip_from_item(item)
			item["active"] = false
		"story":
			if host.story_component.interact_event(String(item.get("event_id", "")), item):
				_apply_item_story_effects(item)
		"transition":
			host.open_transition_prompt(item)
			save_provisional = false
		"dialogue":
			var choice_data: Variant = item.get("choice", {})
			var choice_payload: Dictionary = {}
			if choice_data is Dictionary:
				choice_payload = Dictionary(choice_data)
			host.dialogue_component.start_dialogue(
				String(item.get("speaker", item.get("name", "Speaker"))),
				Array(item.get("dialogue", [])),
				String(item.get("avatar_path", "")),
				choice_payload,
				Dictionary(item.get("completion_effects", {}))
			)
			_apply_item_story_effects(item)
	if bool(item.get("auto_trigger_once", false)):
		item["active"] = false
	if save_provisional:
		host.encounter_component.save_state()
	host.queue_redraw()

func prompt_text() -> String:
	if host.dialogue_component.is_active():
		return "F: Continue"
	var index := nearest_item_index()
	if index < 0:
		return ""
	var item: Dictionary = host.scene_items[index]
	if not is_item_unlocked(item):
		return String(item.get("locked_prompt", "F: Locked"))
	var item_type := String(item.get("type", ""))
	var verb := "Talk"
	if item_type == "weapon":
		verb = "Pick up"
	elif item_type == "story":
		verb = "Inspect"
	elif item_type == "transition":
		verb = "Move"
	return "F: %s %s" % [verb, String(item.get("name", "Interact"))]


func is_item_unlocked(item: Dictionary) -> bool:
	var required_group := String(item.get("required_defeated_group", "")).strip_edges()
	if not required_group.is_empty() and not host.enemy_component.is_group_defeated(required_group):
		return false
	var required_story_flag := String(item.get("required_story_flag", "")).strip_edges()
	if not required_story_flag.is_empty() and not bool(host.story_flags.get(required_story_flag, false)):
		return false
	return true


func _apply_item_story_effects(item: Dictionary) -> void:
	var story_flag := String(item.get("set_story_flag", "")).strip_edges()
	if not story_flag.is_empty():
		host.story_flags[story_flag] = bool(item.get("story_flag_value", true))
	if bool(item.get("deactivate_on_interact", false)):
		item["active"] = false


func apply_completion_effects(effects: Dictionary) -> void:
	var story_flag := String(effects.get("set_story_flag", "")).strip_edges()
	if not story_flag.is_empty():
		host.story_flags[story_flag] = bool(effects.get("story_flag_value", true))
	var group_states = effects.get("group_states", {})
	if group_states is Dictionary:
		for group_name in Dictionary(group_states).keys():
			for enemy in host.enemies:
				if String(enemy.get("story_group", "")) != String(group_name):
					continue
				enemy["state"] = String(group_states[group_name]).to_upper()
				enemy["state_time"] = 0.0
				enemy["ai_frozen"] = false
	var boss_id := String(effects.get("engage_boss_id", "")).strip_edges()
	if not boss_id.is_empty():
		for enemy in host.enemies:
			if String(enemy.get("id", "")) != boss_id:
				continue
			enemy["boss_engaged"] = true
			enemy["ai_frozen"] = false
			enemy["state"] = "APPROACH"
			enemy["state_time"] = 0.0
			host.update_hud(String(effects.get("message", "%s attacks." % String(enemy.get("display_name", "The boss")))))
			break
	host.encounter_component.save_state()
	host.queue_redraw()
