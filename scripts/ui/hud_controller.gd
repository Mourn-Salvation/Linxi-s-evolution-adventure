extends Node

var host: Node
var pending_transition_item: Dictionary = {}
var pending_dialogue_choice: Dictionary = {}


func setup(value: Node) -> void:
	host = value
	if not host.transition_confirm_panel.accepted.is_connected(confirm_pending_transition):
		host.transition_confirm_panel.accepted.connect(confirm_pending_transition)
	if not host.transition_confirm_panel.cancelled.is_connected(cancel_pending_transition):
		host.transition_confirm_panel.cancelled.connect(cancel_pending_transition)
	if not host.transition_confirm_panel.hovered.is_connected(_play_ui_hover):
		host.transition_confirm_panel.hovered.connect(_play_ui_hover)


func update_hud(message: String) -> void:
	host.hud_message = message
	refresh_hud_labels()


func is_prompt_open() -> bool:
	return host.transition_confirm_panel.is_open()


func open_transition_prompt(item: Dictionary) -> void:
	pending_transition_item = item.duplicate(true)
	var destination_name := String(item.get("destination_name", item.get("name", "Next Area")))
	host.transition_confirm_panel.open(destination_name)
	if is_instance_valid(host.audio_component):
		host.audio_component.play_map_transition_pulse()
	update_hud("Confirm route transition.")


func cancel_pending_transition() -> void:
	if not pending_dialogue_choice.is_empty():
		_resolve_pending_dialogue_choice(false)
		return
	pending_transition_item.clear()
	host.transition_confirm_panel.close()
	if is_instance_valid(host.audio_component):
		host.audio_component.play_ui_cancel()
	update_hud("Route transition cancelled.")
	host.queue_redraw()


func confirm_pending_transition() -> void:
	if not pending_dialogue_choice.is_empty():
		_resolve_pending_dialogue_choice(true)
		return
	if pending_transition_item.is_empty():
		host.transition_confirm_panel.close()
		return
	var target_scene := String(pending_transition_item.get("target_scene", ""))
	var destination_name := String(pending_transition_item.get("destination_name", pending_transition_item.get("name", "Next Area")))
	var stage_boundary := bool(pending_transition_item.get("stage_boundary", false))
	var target_spawn = pending_transition_item.get("target_spawn", null)
	host.transition_confirm_panel.close()
	pending_transition_item.clear()
	if is_instance_valid(host.audio_component):
		host.audio_component.play_ui_confirm()
	if target_scene.is_empty():
		update_hud("No route target assigned.")
		return
	if not ResourceLoader.exists(target_scene):
		update_hud("Route target missing: %s" % target_scene)
		return
	host.save_map_switch_checkpoint(target_scene, destination_name, stage_boundary, target_spawn)
	update_hud("Moving to %s..." % destination_name)
	var error := host.get_tree().change_scene_to_file(target_scene)
	if error != OK:
		update_hud("Failed to move to %s: %s" % [destination_name, error_string(error)])


func open_dialogue_choice(choice: Dictionary) -> void:
	if choice.is_empty():
		return
	pending_dialogue_choice = choice.duplicate(true)
	host.transition_confirm_panel.open_prompt(
		String(choice.get("title", "DECISION")),
		String(choice.get("body", "Decide what Linxi does next.")),
		String(choice.get("yes_text", "YES")),
		String(choice.get("no_text", "NO"))
	)
	update_hud(String(choice.get("prompt_message", "Choose Linxi's response.")))


func show_achievement(title: String, duration: float = 4.0) -> void:
	host.achievement_component.show_achievement(title, duration)
	if is_instance_valid(host.audio_component):
		host.audio_component.play_achievement_pop()


func refresh_hud_labels() -> void:
	host.title_label.visible = false
	host.health_label.visible = false
	host.player_health_label.visible = false
	host.player_hud_component.visible = true
	host.controls_label.visible = false
	host.status_label.visible = false
	host.phase_label.text = host.story_objective if not host.story_objective.is_empty() else "PHASE: %s" % ("EVOLVED FIGHTER" if host.evolved else "EVOLUTION")
	_update_status_label()
	var active_enemy := active_enemy_debug_state()
	var target_health := int(active_enemy.get("health", 0))
	host.health_label.text = "THREATS: %d/%d   Target HP: %d" % [host.enemy_component.living_count(), host.enemy_component.count_combatants(), target_health]
	host.player_health_label.text = "Linxi HP: %d/%d" % [host.player_health, host.player_max_health]
	_update_player_hud()
	var prompt: String = host.interaction_component.prompt_text() if is_instance_valid(host.interaction_component) else ""
	var parts: Array[String] = []
	if not host.hud_message.is_empty():
		parts.append(host.hud_message)
	if not host.story_tutorial_hint.is_empty():
		parts.append("TIP: %s" % host.story_tutorial_hint)
	if not prompt.is_empty():
		parts.append("[%s]" % prompt)
	host.hint_label.text = "     ".join(parts)


func active_enemy_debug_state() -> Dictionary:
	if host.active_enemy_index < 0 or host.active_enemy_index >= host.enemies.size():
		return {}
	return host.enemies[host.active_enemy_index]


func _resolve_pending_dialogue_choice(accepted: bool) -> void:
	var choice := pending_dialogue_choice.duplicate(true)
	pending_dialogue_choice.clear()
	host.transition_confirm_panel.close()
	var flag := String(choice.get("yes_flag" if accepted else "no_flag", ""))
	if not flag.is_empty():
		host.story_flags[flag] = true
	var target_enemy_id := String(choice.get("target_enemy_id", ""))
	if not target_enemy_id.is_empty():
		_apply_choice_enemy_result(target_enemy_id, String(choice.get("yes_enemy_state" if accepted else "no_enemy_state", "")))
	var group_states_data = choice.get("yes_group_states" if accepted else "no_group_states", {})
	if group_states_data is Dictionary:
		_apply_choice_group_states(Dictionary(group_states_data))
	var deactivate_item_id := String(choice.get("deactivate_item_id", ""))
	if not deactivate_item_id.is_empty():
		for item in host.scene_items:
			if String(item.get("id", "")) == deactivate_item_id:
				item["active"] = false
	var message := String(choice.get("yes_message" if accepted else "no_message", "Choice recorded."))
	update_hud(message)
	host.encounter_component.save_state()
	host.queue_redraw()


func _apply_choice_enemy_result(enemy_id: String, state: String) -> void:
	if state.is_empty():
		return
	for enemy in host.enemies:
		if String(enemy.get("id", "")) != enemy_id:
			continue
		enemy["state"] = state
		if state in ["ESCAPED", "DIGESTED", "CONTAINED"]:
			enemy["health"] = 0
		return


func _apply_choice_group_states(group_states: Dictionary) -> void:
	for group_id in group_states.keys():
		var normalized_group := String(group_id).strip_edges()
		var state := String(group_states[group_id]).to_upper()
		if normalized_group.is_empty() or state.is_empty():
			continue
		for enemy in host.enemies:
			if String(enemy.get("story_group", "")) != normalized_group:
				continue
			enemy["state"] = state
			enemy["ai_frozen"] = false
			if state in ["ESCAPED", "DIGESTED", "CONTAINED"]:
				enemy["health"] = 0


func _update_player_hud() -> void:
	var hide_dodge: bool = host.story_control_locked or not host.story_overlay.is_empty() or host.dialogue_active
	var ready: bool = host.dodge_cooldown <= 0.0 and host.dodge_time <= 0.0 and not host.digesting and not host.player_defeated and host.player_height <= 0.0 and not host.g_mode
	host.player_hud_component.set_values(
		host.player_health,
		host.player_max_health,
		host.dodge_cooldown,
		host.balance.dodge_cooldown_seconds,
		host.dodge_time,
		ready,
		hide_dodge,
		host.occupied_vore_capacity,
		host.vore_component.effective_capacity(),
		host.biomass,
		host.balance.maximum_biomass,
		host.weapon_component.has_temporary_weapon(),
		host.equipped_weapon,
		host.equipped_weapon_name,
		host.temporary_weapon_uses,
		host.body_weapon_name
	)


func _update_status_label() -> void:
	if host.development_mode:
		var active_enemy := active_enemy_debug_state()
		host.status_label.text = "Resolve: %d/%d   Combo: %d   Height: %d   %s: %d   Weight: %.1f   Biomass: %.1f   ATK: %.1f   Weapon: %s   Capacity: %d/%d   G: %ds   Vore: %d%%   Digest: %d%%   Enemy: %s" % [
			mini(host.clean_hits, host.balance.evolution_hits),
			host.balance.evolution_hits,
			host.combo_step,
			roundi(host.player_height),
			host.movement_mode,
			roundi(host.player_component.current_move_speed()),
			host.vore_component.current_weight(),
			host.biomass,
			host.balance.unit_attack + host.combat_component.attack_biomass_bonus(),
			host.weapon_component.display_name(),
			host.occupied_vore_capacity,
			host.vore_component.effective_capacity(),
			ceili(host.g_mode_time),
			roundi(host.vore_component.live_chance() * 100.0),
			roundi(host.vore_component.digest_ratio() * 100.0),
			String(active_enemy.get("state", "NONE"))
		]
		return
	var state_text := "WEAK FORM" if not host.body_attack_unlocked else "CLAWS READY"
	if host.g_mode:
		state_text = "G MODE"
	elif host.digesting:
		state_text = "DIGESTING"
	elif host.enemy_contained:
		state_text = "PREY CONTAINED"
	host.status_label.text = "%s   Weapon: %s   Prey: %d/%d" % [
		state_text,
		host.weapon_component.display_name(),
		host.occupied_vore_capacity,
		host.vore_component.effective_capacity()
	]


func _play_ui_hover() -> void:
	if is_instance_valid(host.audio_component):
		host.audio_component.play_ui_hover()
