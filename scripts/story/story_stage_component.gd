extends Node

var host: Node
var phase := 0
var blackout_ground := Vector2.ZERO

func setup(value: Node) -> void: host = value
func is_active() -> bool: return host.map_data != null and String(host.map_data.story_id) == "red_night"
func handles_completion() -> bool: return is_active()

func initialize(restored: bool = false) -> void:
	if not is_active():
		host.body_attack_unlocked = true
		return
	if restored:
		_apply_phase_state(false)
		return
	phase = 0
	host.body_attack_unlocked = bool(host.map_data.initial_body_attack_unlocked)
	host.body_weapon = "claws"
	host.body_weapon_name = "Unstable Claws"
	host.vore_enabled = false
	host.g_mode_enabled = false
	host.encounter_component.mission_complete = false
	_apply_phase_state(true)

func update(_delta: float) -> void:
	if not is_active(): return
	if phase == 0 and host.story_pose == "STAND_UP" and host.story_pose_time >= 2.2:
		phase = 1
		_apply_phase_state(true)
	elif phase == 2 and host.story_pose == "DRINK_BLUE" and host.story_pose_time >= 2.7:
		_unlock_claws_from_vial(true)
		phase = 3
		_apply_phase_state(true)
	elif phase == 3 and host.story_overlay == "CHAOS_CHASE" and host.story_pose_time >= 7.0:
		phase = 4
		_apply_phase_state(true)
	elif phase == 4 and host.enemy_component.living_count() == 0:
		phase = 6
		_apply_phase_state(true)
	elif phase == 5 and host.enemy_component.living_count() == 0:
		phase = 6
		_apply_phase_state(true)
	elif phase == 8 and host.enemy_component.living_count() == 0:
		phase = 9
		_apply_phase_state(true)

func interact_event(event_id: String, item: Dictionary) -> bool:
	if not is_active(): return false
	match event_id:
		"drink_blue_stock":
			if phase != 1: return false
			phase = 2
			var item_position := Vector2(item["position"])
			blackout_ground = item_position
			host.player_ground = item_position
			host.vertical_velocity = 0.0
			item["emptied"] = true
			item["event_id"] = "inspect_empty_nebulizer"
			item["name"] = "Empty Chopper Nebulizer"
			host.story_flags["red_night_blue_stock_taken"] = true
			if is_instance_valid(host.audio_component):
				host.audio_component.play_blue_vial_drink()
			_apply_phase_state(true)
			return true
		"inspect_empty_nebulizer":
			host.update_hud("The chopper-dropped nebulizer is empty. Only the ruptured shell and drained vial remain.")
			return true
		"unlock_claws":
			host.update_hud("The security panel is dead. Linxi's claws already answered the blue vial.")
			return true
		"unlock_tail":
			item["active"] = false
			host.unlock_tail()
			return true
		"enter_dormitory":
			if phase < 6:
				host.update_hud("The infected are still between Linxi and the dormitory.")
				return false
			if phase != 6: return false
			phase = 7
			item["active"] = false
			host.story_flags["red_night_entered_dormitory"] = true
			_apply_phase_state(true)
			return true
		"inspect_su_ruo_room":
			if phase != 7:
				host.update_hud("Linxi cannot make sense of the room while danger is still moving outside.")
				return false
			phase = 8
			item["active"] = false
			host.story_flags["red_night_su_ruo_clue"] = true
			_apply_phase_state(true)
			return true
		"reach_roof_stairs":
			if phase < 9:
				host.update_hud("The stairwell is exposed. Linxi needs to clear the dormitory corridor first.")
				return false
			phase = 10
			host.story_flags["red_night_complete"] = true
			host.encounter_component.mission_complete = true
			_apply_phase_state(true)
			return true
	return false

func serialize_state() -> Dictionary:
	return {
		"phase": phase,
		"body_attack_unlocked": host.body_attack_unlocked,
		"body_weapon_name": host.body_weapon_name,
		"blackout_ground": [blackout_ground.x, blackout_ground.y],
	}

func restore_state(value) -> void:
	if not is_active() or not value is Dictionary: return
	phase = clampi(int(value.get("phase", 0)), 0, 10)
	host.body_attack_unlocked = bool(value.get("body_attack_unlocked", phase >= 3))
	host.body_weapon_name = String(value.get("body_weapon_name", "Controlled Claws" if phase >= 3 else "Unstable Claws"))
	var restored_blackout = value.get("blackout_ground", [])
	if restored_blackout is Array and restored_blackout.size() >= 2:
		blackout_ground = Vector2(float(restored_blackout[0]), float(restored_blackout[1]))


func apply_restored_phase_state() -> void:
	if is_active():
		_apply_phase_state(false)

func _apply_phase_state(show_message: bool) -> void:
	host.story_control_locked = false
	host.story_pose = ""
	host.story_overlay = ""
	host.story_movement_multiplier = 1.0
	host.story_tutorial_hint = ""
	match phase:
		0:
			_set_group_state("scout", "DORMANT")
			_set_group_state("claw_tutorial_infected", "DORMANT")
			_set_group_state("dormitory_wave", "DORMANT")
			_set_group_state("dormitory_civilians", "DORMANT")
			host.body_attack_unlocked = false
			host.story_control_locked = true
			host.story_pose = "STAND_UP"
			host.story_pose_time = 0.0
			_set_objective("OBJECTIVE // STAND UP", "Linxi wakes on cold concrete. Her arms shake as she pushes herself up.", show_message, "Wait until Linxi can stand. Control begins after the get-up animation.")
		1:
			_set_group_state("scout", "DORMANT")
			_set_group_state("claw_tutorial_infected", "DORMANT")
			_set_group_state("dormitory_wave", "DORMANT")
			_set_group_state("dormitory_civilians", "DORMANT")
			host.story_movement_multiplier = 0.55
			_set_objective("OBJECTIVE // REACH THE NEBULIZER", "Linxi can barely stand. Walk to the chopper-dropped nebulizer and drink the blue stock solution.", show_message, "Use WASD to move. W/S adjust depth; walk close to the highlighted object and press F.")
		2:
			if blackout_ground == Vector2.ZERO:
				blackout_ground = host.player_ground
			host.player_ground = blackout_ground
			_set_group_state("scout", "DORMANT")
			_set_group_state("claw_tutorial_infected", "DORMANT")
			_set_group_state("dormitory_wave", "DORMANT")
			_set_group_state("dormitory_civilians", "DORMANT")
			host.story_control_locked = true
			host.story_pose = "DRINK_BLUE"
			host.story_pose_time = 0.0
			_set_objective("OBJECTIVE // DRINK THE BLUE STOCK SOLUTION", "Linxi pulls the vial free and drinks before she can think.", show_message, "Story actions lock control briefly. Watch Linxi's body response.")
		3:
			_unlock_claws_from_vial(false)
			if blackout_ground != Vector2.ZERO:
				host.player_ground = blackout_ground
			_set_group_state("scout", "DORMANT")
			_set_group_state("claw_tutorial_infected", "DORMANT")
			_set_group_state("dormitory_wave", "DORMANT")
			_set_group_state("dormitory_civilians", "DORMANT")
			host.story_control_locked = true
			host.story_pose = "COLLAPSED"
			host.story_overlay = "CHAOS_CHASE"
			host.story_pose_time = 0.0
			if show_message and is_instance_valid(host.audio_component):
				host.audio_component.play_signal_interference()
			_set_objective("OBJECTIVE // SURVIVE THE BLACKOUT", "The blue liquid hits like ice. Linxi falls back to the ground as the school erupts.", show_message, "This is a story blackout. Control returns when Linxi wakes again.")
		4:
			_unlock_claws_from_vial(false)
			if blackout_ground != Vector2.ZERO:
				host.player_ground = blackout_ground
			host.story_movement_multiplier = 0.75
			_set_group_state("scout", "NEUTRAL")
			_set_group_state("claw_tutorial_infected", "NEUTRAL")
			_set_group_state("dormitory_wave", "DORMANT")
			_set_group_state("dormitory_civilians", "DORMANT")
			_set_objective("OBJECTIVE // FEED ON THE WANDERING INFECTED", "Linxi wakes again. Something inside her hands has changed. Several zombie students wander nearby, but they do not attack her first.", show_message, "Claws are unlocked. Ordinary infected do not attack Linxi first here. Knock them down, feed, and learn what her body can do.")
		5:
			host.body_attack_unlocked = true
			host.body_weapon = "claws"
			host.body_weapon_name = "Controlled Claws"
			_set_group_state("scout", "ESCAPED")
			_set_group_state("claw_tutorial_infected", "APPROACH")
			_set_group_state("dormitory_wave", "DORMANT")
			_set_group_state("dormitory_civilians", "DORMANT")
			_set_objective("OBJECTIVE // DEFEAT THE THREE INFECTED", "Claw control stabilized. Use J or W/A/S/D + J for directional attacks.", show_message, "Press J to attack, WASD+J for direction, K to dodge. Knocked-down enemies are safe feeding targets.")
		6:
			_set_group_state("dormitory_civilians", "NEUTRAL")
			_set_group_state("dormitory_wave", "APPROACH")
			_set_objective("OBJECTIVE // REACH THE DORMITORY", "Near the dormitory, zombie students have found a fleeing student. Cross the courtyard and decide whether to intervene.", show_message, "The infected now have human prey. Zombies can attack human students even before Linxi enters the fight.")
		7:
			_set_group_state("dormitory_civilians", "DORMANT")
			_set_group_state("dormitory_wave", "DORMANT")
			_set_objective("OBJECTIVE // SEARCH SU RUO'S ROOM", "The dormitory lights still work, but every doorway sounds occupied.", show_message, "Inspect story items to update Linxi's objective and archive clues.")
		8:
			_set_group_state("dormitory_civilians", "DORMANT")
			_set_group_state("dormitory_wave", "APPROACH")
			_set_objective("OBJECTIVE // SURVIVE THE DORMITORY WAVE", "The room answers with footsteps. Hold the corridor and use directional claw attacks.", show_message, "Use lane movement and dodge to avoid attack casts; stun resets light attacks, not heavy ones.")
		9:
			_set_objective("OBJECTIVE // REACH THE ROOF STAIRWELL", "Su Ruo's clue is recorded. The roof stairs are the only clean route left.", show_message, "Finish the level by reaching the exit interactable.")
		10:
			_set_objective("RED NIGHT COMPLETE", "The stairwell door shuts behind Linxi. Press Enter to record the clue and return.", show_message, "Press Enter to settle rewards and return to the safe flow.")

func _set_group_state(group_name: String, state: String) -> void:
	for enemy in host.enemies:
		if String(enemy.get("story_group", "")) != group_name: continue
		if int(enemy["health"]) <= 0 and state == "APPROACH": continue
		enemy["state"] = state
		enemy["state_time"] = 0.0

func _set_objective(title: String, message: String, show_message: bool, tutorial_hint: String = "") -> void:
	host.story_objective = title
	host.story_tutorial_hint = tutorial_hint
	if show_message: host.update_hud(message)


func _unlock_claws_from_vial(show_achievement: bool) -> void:
	host.body_attack_unlocked = true
	host.body_weapon = "claws"
	host.body_weapon_name = "Controlled Claws"
	if bool(host.story_flags.get("red_night_claws_unlocked_by_vial", false)):
		return
	host.story_flags["red_night_claws_unlocked_by_vial"] = true
	if show_achievement:
		host.show_achievement("what's inside the vial")
