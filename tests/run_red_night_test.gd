extends SceneTree

var failures := 0

func _initialize() -> void:
	var stage = load("res://scenes/red_night.tscn").instantiate()
	stage.save_path_override = "user://red_night_test.json"
	root.add_child(stage)
	await process_frame
	var visuals = stage.enemy_visual_component
	var visual_library = visuals.visual_library
	expect_near(stage.balance.dodge_cooldown_seconds, 1.0, "dodge cooldown is one second")
	var front_edge_y: float = stage._project_ground(Vector2(0.0, stage.ground_depth)).y
	expect_near(front_edge_y, 690.0, "walkable belt front edge stays near bottom of 720p screen", 0.1)
	var actor_back: Vector2 = stage._project_actor(Vector2(240.0, 0.0))
	var actor_front: Vector2 = stage._project_actor(Vector2(240.0, stage.ground_depth))
	expect_near(actor_back.x, actor_front.x, "actor depth movement stays visually vertical")
	expect_near(actor_front.y, front_edge_y, "actor depth uses the same front edge as the ground belt", 0.1)
	var ground_back: Vector2 = stage._project_ground(Vector2(240.0, 0.0))
	var ground_front: Vector2 = stage._project_ground(Vector2(240.0, stage.ground_depth))
	expect(ground_back.x != ground_front.x, "ground belt keeps angled fake-3D depth skew")
	stage.facing = 1.0
	var vertical_dodge: Vector2 = stage.combat_component.shaped_dodge_direction(Vector2.UP)
	expect_near(vertical_dodge.x, 1.0, "vertical dodge keeps full facing X speed")
	expect_near(vertical_dodge.y, -stage.balance.dodge_depth_ratio, "vertical dodge adds small Y drift")
	stage.combat_component.try_dodge()
	expect(stage.dodge_time > 0.0, "dodge locks the player into dodge time")
	expect(stage.dodge_cooldown > 0.99, "dodge starts its one-second cooldown")
	expect(stage.player_invulnerability >= stage.dodge_time, "dodge grants invulnerability during animation")
	var cooldown_before: float = stage.dodge_cooldown
	stage.dodge_time = 0.0
	stage.combat_component.try_dodge()
	expect_near(stage.dodge_cooldown, cooldown_before, "dodge cannot restart during cooldown", 0.001)
	stage.dodge_time = 0.0
	stage.dodge_duration_current = 0.0
	stage.dodge_cooldown = 0.0
	stage.player_invulnerability = 0.0
	expect(stage.story_component.phase == 0, "Red Night begins with stand-up objective")
	expect(stage.story_control_locked, "stand-up beat locks player control")
	expect(not stage.body_attack_unlocked, "body attacks begin locked")
	expect(not stage.vore_enabled and not stage.g_mode_enabled, "late biology is disabled in Red Night")
	var human_student := enemy(stage, "human_student")
	expect(not human_student.is_empty(), "Red Night defines a human_student enemy for the redesigned flow")
	expect(int(human_student.get("family", -1)) == stage.EnemyFamily.HUMAN, "human_student belongs to the Human family")
	expect(String(human_student.get("ai_profile", "")) == "NON_COMBAT_WANDER", "human_student uses non-combat AI")
	expect(int(human_student.get("appearance_id", -1)) == 1, "Red Night uses the female human_student variant")
	expect(String(human_student.get("state", "")) == "DORMANT", "human_student begins dormant")
	var female_idle_path := "res://assets/sprites/enemies/human_student/idle_female_variants_v2/variant_01/left_00.png"
	expect(stage.enemy_visual_component.enemy_appearance_texture(human_student) == load(female_idle_path), "human_student female variant has its own dormant appearance")
	human_student["appearance_id"] = 0
	expect(stage.enemy_visual_component.enemy_appearance_texture(human_student) == visual_library.human_student_appearance_left, "human_student male variant remains available")
	human_student["appearance_id"] = 1
	expect(stage.enemy_component.living_count() == 0, "dormant enemies do not count as active threats")
	human_student["state"] = "APPROACH"
	human_student["state_time"] = 0.0
	stage.enemy_component.update(0.2)
	human_student = enemy(stage, "human_student")
	expect(String(human_student.get("state", "")) == "NEUTRAL", "human_student cannot enter attack approach behavior")
	expect(String(human_student.get("state", "")) != "TELEGRAPH" and String(human_student.get("state", "")) != "HEAVY_TELEGRAPH", "human_student has no attack cast state")
	var human_student_run_texture: Texture2D = stage.enemy_visual_component.enemy_appearance_texture(human_student)
	var female_run_frames: Array[Texture2D] = visual_library.human_student_female_run_right_frames if float(human_student.get("facing", -1.0)) > 0.0 else visual_library.human_student_female_run_left_frames
	expect(female_run_frames.has(human_student_run_texture), "human_student uses its selected female 8-frame run set when active")
	human_student["state"] = "KNOCKED_DOWN"
	var expected_female_knocked: Texture2D = visual_library.human_student_female_knocked_down_right if float(human_student.get("facing", -1.0)) > 0.0 else visual_library.human_student_female_knocked_down_left
	expect(stage.enemy_visual_component.enemy_knocked_down_texture(human_student) == expected_female_knocked, "female human_student has a knocked-down pose")
	human_student["appearance_id"] = 0
	var expected_male_knocked: Texture2D = visual_library.human_student_knocked_down_right if float(human_student.get("facing", -1.0)) > 0.0 else visual_library.human_student_knocked_down_left
	expect(stage.enemy_visual_component.enemy_knocked_down_texture(human_student) == expected_male_knocked, "male human_student has a knocked-down pose")
	human_student["state"] = "DORMANT"
	var knife_student := {
		"archetype": "human_student",
		"family": stage.EnemyFamily.HUMAN,
		"appearance_id": 6,
		"weapon_id": "knife",
		"facing": 1.0,
		"health": stage.balance.unit_health,
		"state": "TELEGRAPH",
		"state_time": 0.0,
	}
	var knife_windup_right := load("res://assets/sprites/enemies/human_student/attack_knife_male_variants/variant_06/right_00.png") as Texture2D
	var knife_strike_right := load("res://assets/sprites/enemies/human_student/attack_knife_male_variants/variant_06/right_01.png") as Texture2D
	expect(stage.enemy_visual_component.enemy_appearance_texture(knife_student) == knife_windup_right, "knife human_student telegraph uses the weapon wind-up frame")
	knife_student["state"] = "RECOVER"
	expect(stage.enemy_visual_component.enemy_appearance_texture(knife_student) == knife_strike_right, "knife human_student recover uses the weapon strike frame")
	knife_student["appearance_id"] = 7
	knife_student["facing"] = -1.0
	knife_student["state"] = "TELEGRAPH"
	var knife_windup_left := load("res://assets/sprites/enemies/human_student/attack_knife_male_variants/variant_07/left_00.png") as Texture2D
	expect(stage.enemy_visual_component.enemy_appearance_texture(knife_student) == knife_windup_left, "second knife human_student variant has a left-facing wind-up frame")
	var dorm_student := enemy(stage, "dorm_human_student_01")
	var dorm_zombie := enemy(stage, "dormitory_infected_01")
	expect(not dorm_student.is_empty() and not dorm_zombie.is_empty(), "dorm chase places both civilian and zombie groups")
	expect(Vector2(dorm_student["position"]).x - Vector2(dorm_zombie["position"]).x >= 450.0, "dorm civilian starts far enough ahead for player intervention")
	expect(stage.enemy_renderer_component.enemy_render_scale(dorm_student).x <= 1.10, "human_student render scale stays close to zombie height")
	dorm_student["state"] = "NEUTRAL"
	dorm_student["neutral_direction"] = 1.0
	dorm_student["neutral_initialized"] = false
	var dorm_student_x_before: float = Vector2(dorm_student["position"]).x
	stage.enemy_component.update(0.5)
	dorm_student = enemy(stage, "dorm_human_student_01")
	expect(Vector2(dorm_student["position"]).x > dorm_student_x_before + 30.0, "dorm civilian keeps initial flee direction and runs forward")
	dorm_student["state"] = "DORMANT"
	var blocker := enemy(stage, "dormitory_infected_01")
	blocker["state"] = "KNOCKED_DOWN"
	blocker["health"] = 0
	expect(not stage.enemy_component.is_solid_for_movement(blocker), "knocked-down enemies do not block AI movement")
	blocker["state"] = "APPROACH"
	blocker["health"] = stage.balance.unit_health
	expect(stage.enemy_component.is_solid_for_movement(blocker), "active enemies still block AI movement")
	stage.story_pose_time = 2.2
	stage.story_component.update(0.01)
	expect(stage.story_component.phase == 1, "stand-up advances to blue stock objective")
	expect(not stage.story_control_locked, "player control unlocks after stand-up")
	expect(stage.scene_items.size() == 2, "Red Night places the nebulizer and one route transition marker")
	var nebulizer := item(stage, "chopper_nebulizer")
	expect(not nebulizer.is_empty(), "nebulizer remains a Red Night interactable")
	var route_marker := item(stage, "roof_stairwell_transition")
	expect(not route_marker.is_empty(), "Red Night defines the dormitory gate route marker")
	expect(String(route_marker.get("type", "")) == "transition", "dormitory gate marker uses transition item type")
	expect_near(Vector2(route_marker["position"]).x, 2750.0, "dormitory gate marker sits near the adjusted courtyard dorm approach")
	expect_near(Vector2(route_marker["position"]).y, 8.0, "dormitory gate marker stays near the back-depth lane")
	expect(String(route_marker.get("destination_name", "")) == "Dormitory Lobby", "route marker names the next place")
	expect(String(route_marker.get("target_scene", "")) == "res://scenes/dormitory_lobby.tscn", "route marker targets the dormitory lobby scene")
	expect(ResourceLoader.exists(String(route_marker.get("target_scene", ""))), "route marker target scene exists")
	expect_near(Vector2(nebulizer["position"]).x, 398.0, "nebulizer is farther from spawn on X")
	expect_near(Vector2(nebulizer["position"]).y, 140.0, "nebulizer is centered on Y")
	expect(stage.contamination_mist_points.size() > 0 and stage.contamination_mist_points.size() <= 12, "Red Night builds sparse nebulizer mist points")
	expect(float(stage.contamination_mist_points[0].get("height", 0.0)) >= 90.0, "nebulizer mist points float above the ground plane")
	expect(stage.contamination_mist_points[0].has("screen_offset"), "nebulizer mist uses screen-space airborne offset")
	for mist_index in range(stage.contamination_mist_points.size()):
		for other_index in range(mist_index + 1, stage.contamination_mist_points.size()):
			var mist_position := Vector2(stage.contamination_mist_points[mist_index]["position"])
			var other_position := Vector2(stage.contamination_mist_points[other_index]["position"])
			expect(mist_position.distance_to(other_position) >= 55.0, "nebulizer mist points do not stack on one another")
	stage.player_ground = Vector2(nebulizer["position"]) + Vector2(-64.0, 24.0)
	expect(stage.story_component.interact_event("drink_blue_stock", nebulizer), "blue stock solution advances story")
	expect(stage.story_component.phase == 2, "drinking animation starts")
	expect(stage.story_control_locked and stage.story_pose == "DRINK_BLUE", "Linxi drinks the vial before collapse")
	expect(stage.story_overlay.is_empty(), "blackout waits until drinking animation ends")
	expect(bool(nebulizer.get("emptied", false)), "nebulizer remains as an emptied prop")
	expect(bool(nebulizer.get("active", true)), "empty nebulizer does not disappear")
	expect(bool(stage.story_flags.get("red_night_blue_stock_taken", false)), "blue stock story flag disables atomization mist")
	expect_near(stage.player_ground.x, 398.0, "drink animation snaps to nebulizer X")
	expect_near(stage.player_ground.y, 140.0, "drink animation snaps to nebulizer Y")
	stage.story_pose_time = 2.7
	stage.story_component.update(0.01)
	expect(stage.story_component.phase == 3, "blackout chase cutscene starts")
	expect(stage.body_attack_unlocked and stage.body_weapon == "claws", "blue vial unlocks claw attacks")
	expect(stage.achievement_component.achievement_title == "what's inside the vial", "blue vial shows claw achievement")
	expect(stage.achievement_component.achievement_time > 0.0, "achievement popup starts")
	expect(stage.story_control_locked and stage.story_pose == "COLLAPSED", "Linxi collapses after drinking")
	expect(stage.story_overlay == "CHAOS_CHASE", "school chase cutscene overlay starts")
	expect_near(stage.player_ground.x, 398.0, "collapse happens where Linxi drank")
	expect_near(stage.player_ground.y, 140.0, "collapse keeps blackout Y position")
	stage.story_pose_time = 7.0
	stage.story_component.update(0.01)
	expect(stage.story_component.phase == 4, "evasion phase starts after blackout")
	expect(not stage.story_control_locked, "player control returns after chase cutscene")
	expect_near(stage.player_ground.x, 398.0, "second wake happens at blackout X")
	expect_near(stage.player_ground.y, 140.0, "second wake happens at blackout Y")
	expect(stage.enemy_component.living_count() == 4, "wandering infected feed group becomes active without an item trigger")
	var scout := enemy(stage, "courtyard_scout")
	expect(String(scout.get("ai_profile", "")) == "NEUTRAL_WANDER", "first zombie student uses map-authored neutral wander profile")
	expect(String(scout.get("state", "")) == "NEUTRAL", "first zombie student wanders instead of attacking Linxi")
	scout["state"] = "KNOCKED_DOWN"
	expect(stage.enemy_visual_component.enemy_knocked_down_texture(scout) == visual_library.zombie_student_knocked_down_left_frames[0], "zombie appearance 0 has a knocked-down pose")
	scout["appearance_id"] = 3
	expect(stage.enemy_visual_component.enemy_knocked_down_texture(scout) == visual_library.zombie_student_knocked_down_left_frames[3], "zombie appearance 3 keeps its knocked-down variant")
	scout["appearance_id"] = 0
	scout["state"] = "STAGGER"
	var scout_normal_texture: Texture2D = stage.enemy_visual_component.enemy_appearance_texture(scout)
	scout["hit_reaction_duration"] = 0.2
	scout["hit_reaction_time"] = 0.2
	expect(stage.enemy_visual_component.current_enemy_hit_texture(scout) == scout_normal_texture, "zombie hit reaction keeps the same appearance variant")
	scout["hit_reaction_time"] = 0.09
	var second_hit_pose: Dictionary = stage.enemy_visual_component.enemy_hit_pose(scout)
	scout["hit_reaction_time"] = 0.2
	var first_hit_pose: Dictionary = stage.enemy_visual_component.enemy_hit_pose(scout)
	expect(Vector2(first_hit_pose["offset"]) != Vector2(second_hit_pose["offset"]) or float(first_hit_pose["rotation"]) != float(second_hit_pose["rotation"]), "zombie has at least two distinct hit poses")
	scout["hit_reaction_time"] = 0.0
	scout["state"] = "TELEGRAPH"
	scout["state_time"] = stage.balance.human_telegraph_time
	scout["attack_facing"] = 1.0
	expect(stage.enemy_visual_component.enemy_appearance_texture(scout) == load("res://assets/sprites/enemies/zombie_student/attack/variant_00/left_00.png"), "zombie telegraph uses attack wind-up frame")
	scout["state"] = "RECOVER"
	scout["state_time"] = stage.balance.human_recovery_time
	expect(stage.enemy_visual_component.enemy_appearance_texture(scout) == load("res://assets/sprites/enemies/zombie_student/attack/variant_00/left_01.png"), "zombie recovery begins on the attack finishing sequence")
	scout["state"] = "TELEGRAPH"
	scout["attack_facing"] = 1.0
	scout["position"] = Vector2(260.0, 140.0)
	var zombie_reach: float = stage.balance.zombie_attack_range + stage.enemy_shadow_radius(scout) + stage.player_shadow_radius()
	stage.player_health = stage.player_max_health
	stage.player_invulnerability = 0.0
	stage.dodge_time = 0.0
	stage.player_height = 0.0
	stage.player_ground = Vector2(scout["position"]) + Vector2(zombie_reach + 1.0, 0.0)
	stage.enemy_component.resolve_human_attack(index_of_enemy(stage, "courtyard_scout"))
	expect(stage.player_health == stage.player_max_health, "zombie attack misses beyond hands-reach range")
	scout["state"] = "TELEGRAPH"
	stage.player_health = stage.player_max_health
	stage.player_ground = Vector2(scout["position"]) + Vector2(zombie_reach - 1.0, 0.0)
	stage.enemy_component.resolve_human_attack(index_of_enemy(stage, "courtyard_scout"))
	expect(stage.player_health == stage.player_max_health - stage.balance.unit_attack, "zombie attack hits inside hands-reach range")
	scout["state"] = "NEUTRAL"
	stage.enemy_component.update(1.0)
	scout = enemy(stage, "courtyard_scout")
	expect(String(scout.get("state", "")) == "NEUTRAL", "neutral zombie student remains non-hostile while Linxi passes")
	stage.enemy_component.apply_hit_reaction(index_of_enemy(stage, "courtyard_scout"), 0.1)
	stage.enemy_component.update(0.2)
	scout = enemy(stage, "courtyard_scout")
	expect(String(scout.get("state", "")) == "NEUTRAL", "first zombie student returns to wandering after a hit")
	expect(item(stage, "emergency_case").is_empty(), "security panel item is removed from Red Night")
	expect(item(stage, "dormitory_door").is_empty(), "dormitory door item is removed from Red Night")
	expect(item(stage, "su_ruo_room").is_empty(), "Su Ruo room item is removed from Red Night")
	expect(item(stage, "roof_stairs").is_empty(), "roof stairs item is removed from Red Night")
	expect(item(stage, "su_ruo_id").is_empty(), "Su Ruo ID item is removed from Red Night")
	for enemy in stage.enemies:
		if String(enemy.get("story_group", "")) == "claw_tutorial_infected":
			expect(String(enemy.get("state", "")) == "NEUTRAL", "first feed enemy wanders instead of attacking")
			expect(String(enemy.get("ai_profile", "")) == "NEUTRAL_WANDER", "first feed enemy uses neutral wander AI")
			expect(String(enemy.get("attack_type", "NORMAL")) != "HEAVY", "first feed group has no elite/heavy enemy")
	expect(stage.combat_component.attack_for_tag("UP").attack_id == "claw_up", "directional attack data resolves")
	for enemy in stage.enemies:
		if enemy["state"] == "NEUTRAL": enemy["health"] = 0
	stage.enemy_component.update(0.01)
	stage.story_component.update(0.01)
	expect(stage.story_component.phase == 6, "feeding/clearing wandering infected reaches the dorm chase beat")
	expect(stage.story_objective == "OBJECTIVE // REACH THE DORMITORY", "Red Night opens the dorm-side chase after the first feed group")
	var dorm_human := enemy(stage, "dorm_human_student_01")
	expect(not dorm_human.is_empty(), "Red Night defines a dorm-side human student prey")
	expect(String(dorm_human.get("archetype", "")) == "human_student", "dorm human uses the human_student archetype")
	expect(String(dorm_human.get("state", "")) == "NEUTRAL", "dorm human becomes active at the dorm chase beat")
	var dorm_civilians := 0
	var expected_civilian_appearance_ids := {
		"dorm_human_student_01": 2,
		"dorm_human_student_02": 3,
		"dorm_human_student_03": 4,
		"dorm_human_student_04": 5,
	}
	for candidate in stage.enemies:
		if String(candidate.get("story_group", "")) == "dormitory_civilians":
			dorm_civilians += 1
			expect(String(candidate.get("archetype", "")) == "human_student", "dorm civilian uses human_student archetype")
			expect(String(candidate.get("state", "")) == "NEUTRAL", "dorm civilian activates for the chase")
			expect(int(candidate.get("appearance_id", -1)) == int(expected_civilian_appearance_ids[String(candidate.get("id", ""))]), "dorm civilian uses approved appearance_id mapping")
	expect(dorm_civilians == 4, "dormitory chase has four female human-student civilians")
	var dorm_chasers := 0
	for candidate in stage.enemies:
		if String(candidate.get("story_group", "")) == "dormitory_wave":
			dorm_chasers += 1
			expect(String(candidate.get("ai_profile", "")) == "ZOMBIE_CHASE_HUMAN", "dormitory zombie chases human students")
			expect(String(candidate.get("state", "")) == "APPROACH", "dormitory zombie activates for the chase")
	expect(dorm_chasers == 5, "dormitory chase has five zombie students")
	var prey_index := index_of_enemy(stage, "dorm_human_student_01")
	var chaser_index := index_of_enemy(stage, "dormitory_infected_01")
	stage.enemies[prey_index]["health"] = stage.balance.unit_health
	stage.enemies[prey_index]["position"] = Vector2(2480, 150)
	stage.enemies[chaser_index]["position"] = Vector2(2420, 150)
	stage.enemies[chaser_index]["state"] = "TELEGRAPH"
	stage.enemies[chaser_index]["state_time"] = 0.0
	stage.enemies[chaser_index]["attack_target_index"] = prey_index
	stage.enemies[chaser_index]["attack_facing"] = 1.0
	stage.enemy_component.update(0.01)
	dorm_human = enemy(stage, "dorm_human_student_01")
	expect(int(dorm_human.get("health", 0)) == stage.balance.unit_health - stage.balance.unit_attack, "zombie chase AI can attack human student prey")
	for candidate_index in range(stage.enemies.size()):
		if String(stage.enemies[candidate_index].get("story_group", "")) == "dormitory_civilians":
			stage.enemies[candidate_index]["health"] = 0
			stage.enemies[candidate_index]["state"] = "KNOCKED_DOWN"
	stage.player_ground = Vector2(2380, 150)
	stage.enemies[chaser_index]["position"] = Vector2(2580, 150)
	stage.enemies[chaser_index]["state"] = "APPROACH"
	stage.enemy_component.update(0.25)
	expect(String(stage.enemies[chaser_index].get("state", "")) != "NEUTRAL", "dormitory zombie targets Linxi after human prey are finished")
	expect(Vector2(stage.enemies[chaser_index]["position"]).x < 2580.0, "dormitory zombie moves toward Linxi after human prey are finished")
	var guard_probe := {
		"id": "guard_probe",
		"archetype": "human_guard",
		"family": stage.EnemyFamily.HUMAN,
		"facing": -1.0,
		"appearance_id": 0,
		"state": "KNOCKED_DOWN",
	}
	expect(stage.enemy_visual_component.enemy_knocked_down_texture(guard_probe) == visual_library.human_guard_knocked_down_left, "human guard family has a knocked-down pose")
	stage.queue_free()
	await process_frame
	var path := ProjectSettings.globalize_path("user://red_night_test.json")
	if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	if failures == 0:
		print("PASS: Red Night vertical slice tests")
		quit(0)
	else:
		push_error("FAIL: %d Red Night test(s)" % failures)
		quit(1)

func item(stage, id: String) -> Dictionary:
	for candidate in stage.scene_items:
		if String(candidate.get("id", "")) == id: return candidate
	return {}

func enemy(stage, id: String) -> Dictionary:
	for candidate in stage.enemies:
		if String(candidate.get("id", "")) == id: return candidate
	return {}

func index_of_enemy(stage, id: String) -> int:
	for index in range(stage.enemies.size()):
		if String(stage.enemies[index].get("id", "")) == id: return index
	return -1

func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)

func expect_near(actual: float, expected: float, label: String, epsilon := 0.0001) -> void:
	if absf(actual - expected) > epsilon:
		failures += 1
		push_error("%s: expected %.4f, got %.4f" % [label, expected, actual])
