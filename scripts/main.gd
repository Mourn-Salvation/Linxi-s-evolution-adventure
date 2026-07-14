extends Node2D

const GROUND_ORIGIN_X := 170.0
const GROUND_FRONT_SCREEN_MARGIN := 30.0
const DEFAULT_GROUND_WIDTH := 1800.0
const DEFAULT_GROUND_DEPTH := 280.0
const DEPTH_AXIS := Vector2(-0.32, 0.86)
const ACTOR_DEPTH_AXIS := Vector2(0.0, 0.86)
const PLAYER_BASE_SHADOW_RADIUS := 38.0
const HUMAN_SHADOW_RADIUS := 48.0
const ZOMBIE_SHADOW_RADIUS := 38.0
const MUTANT_SHADOW_RADIUS := 64.0
const SHADOW_DEPTH_RATIO := 0.32
const PAUSE_MENU_SCENE: PackedScene = preload("res://scenes/pause_menu.tscn")

enum EnemyFamily {
	HUMAN,
	ZOMBIE,
	MUTANT_CREATURE,
}

@export var map_data: Resource
@export var level_data: Resource
@export var balance: GameBalance
@export var development_mode := false
@export var force_mobile_controls := false
@export var resume_encounter_on_start := false
@export var load_saved_progress_on_start := true

var current_stage_id := ""
var current_level_id := ""
var current_level_name := ""
var ground_min_x := 0.0
var ground_width := DEFAULT_GROUND_WIDTH
var ground_depth := DEFAULT_GROUND_DEPTH
var player_spawn := Vector2(130.0, 155.0)
var player_ground := player_spawn
var enemies: Array[Dictionary] = []
var scene_items: Array[Dictionary] = []
var weapon_projectiles: Array[Dictionary] = []
var save_path_override := ""
var equipped_weapon := ""
var equipped_weapon_name := ""
var temporary_weapon_uses := 0
var body_weapon := "claws"
var body_weapon_name := "Claws"
var body_attack_unlocked := true
var tail_unlocked := false
var last_body_attack_id := "claw_neutral"
var story_objective := ""
var story_flags: Dictionary = {}
var story_control_locked := false
var story_pose := ""
var story_pose_time := 0.0
var story_overlay := ""
var story_movement_multiplier := 1.0
var story_tutorial_hint := ""
var hud_message := ""
var route_checkpoint: Dictionary = {}
var vore_enabled := true
var g_mode_enabled := true
var dialogue_active := false
var dialogue_speaker := ""
var active_enemy_index := -1
var camera_x := 0.0
var player_height := 0.0
var player_max_health := 10
var player_health := player_max_health
var player_invulnerability := 0.0
var player_hurt_flash := 0.0
var player_defeated := false
var vertical_velocity := 0.0
var facing := 1.0
var attack_cooldown := 0.0
var attack_duration_current := 0.0
var player_hit_reaction_time := 0.0
var player_hit_reaction_duration := 0.0
var combo_timeout := 0.0
var combo_step := 0
var clean_hits := 0
var evolved := false
var enemy_contained := false
var contained_prey_weight := 0.0
var occupied_vore_capacity := 0
var digest_progress := 0.0
var digesting := false
var vore_execution_time := 0.0
var vore_execution_duration := 0.0
var hit_stop := 0.0
var dodge_time := 0.0
var dodge_duration_current := 0.0
var dodge_cooldown := 0.0
var dodge_direction := Vector2.ZERO
var vore_flash := 0.0
var hit_effects: Array[Dictionary] = []
var contamination_mist_points: Array[Dictionary] = []
var last_tap_time_by_key: Dictionary = {}
var sprint_key: Key = KEY_NONE
var movement_mode := "WALK"
var mobile_digest_held := false
var player_animation_time := 0.0
var footstep_timer := 0.0
var g_mode := false
var g_mode_time := 0.0
var g_route_timestamps: Dictionary = {}
var last_v_press_time := -10.0
var active_intake_route := "CORE"
var contained_route_loads: Dictionary = {
	"BELLY": 0,
	"CHEST": 0,
	"LOWER_BELLY": 0,
	"GROIN": 0,
}
var unlocked_intake_routes: Dictionary = {
	"CORE": true,
	"LEFT": false,
	"RIGHT": false,
	"UPPER": false,
	"LOWER": false,
	"BURST": false,
}
var pause_menu: Control
var dev_placement_overlay_enabled := true
var components_ready := false

@export_range(0.5, 100.0, 0.1) var permanent_weight := 1.0
@export_range(0.0, 50.0, 0.1) var biomass := 0.0
var weight_speed_debuff_disabled := false
@export_range(1, 100, 1) var vore_capacity := 1

@onready var phase_label: Label = $HUD/Phase
@onready var status_label: Label = $HUD/Status
@onready var health_label: Label = $HUD/EnemyHealth
@onready var player_health_label: Label = $HUD/PlayerHealth
@onready var player_hud_component: Control = $HUD/PlayerHud
@onready var mobile_controls: Control = $HUD/MobileControls
@onready var hint_label: Label = $HUD/Hint
@onready var title_label: Label = $HUD/Title
@onready var controls_label: Label = $HUD/Controls

@onready var player_component: Node = $Components/Player
@onready var player_visual_component: Node = $Components/PlayerVisual
@onready var player_renderer_component: Node = $Components/PlayerRenderer
@onready var enemy_component: Node = $Components/Enemy
@onready var enemy_visual_component: Node = $Components/EnemyVisual
@onready var enemy_renderer_component: Node = $Components/EnemyRenderer
@onready var combat_component: Node = $Components/Combat
@onready var vore_component: Node = $Components/Vore
@onready var encounter_component: Node = $Components/Encounter
@onready var interaction_component: Node = $Components/Interaction
@onready var item_renderer_component: Node = $Components/ItemRenderer
@onready var weapon_component: Node = $Components/Weapon
@onready var dialogue_component: Node = $Components/Dialogue
@onready var map_renderer_component: Node = $Components/MapRenderer
@onready var effect_renderer_component: Node = $Components/EffectRenderer
@onready var debug_component: Node = $Components/Debug
@onready var story_component: Node = $Components/Story
@onready var audio_component: Node = $Components/Audio
@onready var hud_controller_component: Node = $Components/HudController
@onready var projection_component: Node = $Components/Projection
@onready var world_fx_component: Node = $Components/WorldFx
@onready var scene_flow_component: Node = $Components/SceneFlow
@onready var dialogue_panel: Panel = $HUD/DialoguePanel
@onready var dialogue_name_label: Label = $HUD/DialoguePanel/SpeakerName
@onready var dialogue_text_label: Label = $HUD/DialoguePanel/DialogueText
@onready var dialogue_avatar_label: Label = $HUD/DialoguePanel/Avatar/Letter
@onready var dialogue_continue_label: Label = $HUD/DialoguePanel/Continue
@onready var achievement_component: Control = $HUD/AchievementPopup
@onready var transition_confirm_panel: Control = $HUD/TransitionConfirmPanel
@onready var defeat_panel: Control = $HUD/DefeatPanel


func _ready() -> void:
	randomize()
	if balance == null: balance = load("res://resources/balance/default_balance.tres")
	player_max_health = balance.unit_health
	player_health = player_max_health
	if not _initialize_components():
		return
	mobile_controls.setup(self)
	if not defeat_panel.retry_requested.is_connected(_retry_from_area_entry):
		defeat_panel.retry_requested.connect(_retry_from_area_entry)
	_load_level_data()
	_load_map_data()
	if should_load_saved_progress():
		vore_component.load_progress()
	else:
		reset_player_progress_to_defaults()
	scene_flow_component.apply_route_spawn_override()
	weapon_component.initialize_body_weapon()
	scene_flow_component.apply_route_weapon_override()
	enemy_component.reset_enemies()
	interaction_component.reset_items()
	var restored_encounter := false
	if resume_encounter_on_start:
		restored_encounter = encounter_component.load_state()
	else:
		encounter_component.discard_provisional_progress()
	story_component.initialize(restored_encounter)
	scene_flow_component.apply_map_entry_story_overlay()
	_build_contamination_mist_points()
	refresh_story_unlocks()
	if not restored_encounter:
		if _is_shelter_map():
			player_health = player_max_health
		update_hud(map_data.objective if map_data != null else "Encounter ready.")
	queue_redraw()


func should_load_saved_progress() -> bool:
	return load_saved_progress_on_start or resume_encounter_on_start


func _is_shelter_map() -> bool:
	return map_data != null and (String(map_data.story_id) == "shelter" or String(map_data.map_id).contains("shelter"))


func reset_player_progress_to_defaults() -> void:
	permanent_weight = 1.0
	biomass = 0.0
	vore_capacity = 1
	weight_speed_debuff_disabled = false
	player_max_health = balance.unit_health
	player_health = player_max_health
	enemy_contained = false
	contained_prey_weight = 0.0
	occupied_vore_capacity = 0
	digest_progress = 0.0
	digesting = false
	for region in contained_route_loads:
		contained_route_loads[region] = 0
	story_flags.clear()
	route_checkpoint.clear()
	for route in unlocked_intake_routes:
		unlocked_intake_routes[route] = route == "CORE"


func _initialize_components() -> bool:
	if components_ready:
		return true
	var component_nodes: Array[Node] = [
		player_component,
		player_visual_component,
		player_renderer_component,
		enemy_component,
		enemy_visual_component,
		enemy_renderer_component,
		combat_component,
		vore_component,
		encounter_component,
		interaction_component,
		item_renderer_component,
		weapon_component,
		dialogue_component,
		map_renderer_component,
		effect_renderer_component,
		debug_component,
		story_component,
		audio_component,
		hud_controller_component,
		projection_component,
		world_fx_component,
		scene_flow_component,
	]
	for component in component_nodes:
		if component == null:
			push_error("Main scene component is missing. Check scenes/main.tscn Components children.")
			return false
		if not component.has_method("setup"):
			push_error("Main scene component lacks setup(owner): %s" % component.name)
			return false
		component.setup(self)
	components_ready = true
	return true

func _load_level_data() -> void:
	scene_flow_component.load_level_data()

func _load_map_data() -> void:
	scene_flow_component.load_map_data()


func _process(delta: float) -> void:
	if not components_ready and not _initialize_components():
		return
	refresh_story_unlocks()
	if transition_confirm_panel.is_open():
		queue_redraw()
		return
	if dialogue_active:
		queue_redraw()
		return
	if development_mode and Input.is_key_pressed(KEY_R):
		encounter_component.reset()
		return

	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	combo_timeout = maxf(combo_timeout - delta, 0.0)
	dodge_cooldown = maxf(dodge_cooldown - delta, 0.0)
	combat_component.update(delta)

	player_invulnerability = maxf(player_invulnerability - delta, 0.0)
	player_hurt_flash = maxf(player_hurt_flash - delta, 0.0)
	player_hit_reaction_time = maxf(player_hit_reaction_time - delta, 0.0)
	vore_flash = maxf(vore_flash - delta, 0.0)
	vore_execution_time = maxf(vore_execution_time - delta, 0.0)
	if vore_execution_time <= 0.0:
		_update_hit_effects(delta)
	if not story_pose.is_empty() or not story_overlay.is_empty():
		story_pose_time += delta
	player_component.update_g_mode(delta)
	player_component.update_animation(delta)

	if combo_timeout <= 0.0:
		combo_step = 0

	if hit_stop > 0.0:
		hit_stop -= delta
		queue_redraw()
		return
	if vore_execution_time > 0.0:
		queue_redraw()
		return

	player_component.update_jump(delta)
	vore_component.update_digest(delta)
	if not player_defeated and not story_control_locked:
		enemy_component.update(delta)
	if not story_control_locked:
		weapon_component.update_projectiles(delta)
	var previous_player_ground := player_ground
	if story_control_locked:
		pass
	elif dodge_time > 0.0:
		dodge_time -= delta
		player_ground += dodge_direction * balance.dodge_speed * delta
	elif digesting:
		pass
	elif player_hit_reaction_time > 0.0:
		pass
	elif combat_component.is_running_attack_active():
		combat_component.update_running_attack(delta)
	elif not player_defeated:
		player_component.move(delta)

	player_ground = resolve_map_blockers(previous_player_ground, player_ground)
	player_ground.x = clampf(player_ground.x, ground_min_x, ground_width)
	player_ground.y = clampf(player_ground.y, 0.0, ground_depth)
	_update_camera(delta)
	player_ground = projection_component.constrain_player_to_safe_zone(player_ground)
	player_ground.x = clampf(player_ground.x, ground_min_x, ground_width)
	player_ground.y = clampf(player_ground.y, 0.0, ground_depth)
	_update_camera(delta)
	interaction_component.update_auto_triggers()
	_refresh_hud_labels()
	story_component.update(delta)
	scene_flow_component.update_story_overlay()
	encounter_component.update_autosave(delta)
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.echo:
		return
	if transition_confirm_panel.is_open():
		if event.pressed:
			match event.keycode:
				KEY_ENTER, KEY_Y:
					_confirm_pending_transition()
				KEY_ESCAPE, KEY_N:
					_cancel_pending_transition()
		return
	if player_defeated:
		return
	if event.pressed and development_mode and debug_component.handle_key(event): return
	if dialogue_active:
		if event.pressed and event.keycode == KEY_F: dialogue_component.advance()
		return
	if event.pressed and event.keycode == KEY_ESCAPE:
		open_pause_menu()
		return
	if event.pressed and event.keycode == KEY_EQUAL and development_mode:
		biomass = balance.clamp_biomass(biomass + 10.0)
		vore_component.save_progress()
		update_hud("DEV: Biomass increased by 10. Current biomass: %.1f." % biomass)
		return
	if story_control_locked:
		return
	if event.pressed and not event.echo and event.keycode in [KEY_A, KEY_D, KEY_W, KEY_S]:
		vore_component.record_route_key(event.keycode)
	if event.keycode == KEY_L and not event.pressed:
		vore_component.exit_digest_mode()
		return
	if player_component.is_horizontal_key(event.keycode):
		if event.pressed:
			player_component.register_movement_tap(event.keycode)
		elif sprint_key == event.keycode:
			sprint_key = KEY_NONE
		return
	if not event.pressed:
		return
	match event.keycode:
		KEY_ENTER:
			encounter_component.settle_and_return()
		KEY_F:
			interaction_component.interact()
		KEY_G:
			player_component.try_activate_g_mode()
		KEY_J:
			if not weapon_component.try_use_temporary_weapon(): combat_component.try_attack()
		KEY_K:
			combat_component.try_dodge()
		KEY_V:
			if vore_component.select_route():
				vore_component.try_vore()
		KEY_SPACE:
			player_component.try_jump()


func progress_save_path() -> String:
	return scene_flow_component.progress_save_path()


func save_map_switch_checkpoint(target_scene: String, destination_name: String, stage_boundary: bool = false, target_spawn = null) -> void:
	scene_flow_component.save_map_switch_checkpoint(target_scene, destination_name, stage_boundary, target_spawn)


func open_pause_menu() -> void:
	if is_instance_valid(pause_menu):
		return
	pause_menu = PAUSE_MENU_SCENE.instantiate() as Control
	add_child(pause_menu)
	get_tree().paused = true


func mobile_direction_pressed(keycode: Key) -> void:
	if story_control_locked or player_defeated:
		return
	vore_component.record_route_key(keycode)
	if player_component.is_horizontal_key(keycode):
		player_component.register_movement_tap(keycode)


func mobile_action_pressed(action_name: String) -> void:
	if player_defeated or transition_confirm_panel.is_open():
		return
	if action_name == "F":
		if dialogue_active:
			dialogue_component.advance()
		elif not story_control_locked:
			interaction_component.interact()
		return
	if story_control_locked or dialogue_active:
		return
	match action_name:
		"J":
			if not weapon_component.try_use_temporary_weapon(): combat_component.try_attack()
		"K":
			combat_component.try_dodge()
		"V":
			if vore_component.select_route(): vore_component.try_vore()


func show_defeat_panel() -> void:
	if is_instance_valid(defeat_panel):
		defeat_panel.open()


func _retry_from_area_entry() -> void:
	if not player_defeated:
		return
	encounter_component.retry_current_map()


func toggle_dev_placement_overlay() -> void:
	if not development_mode:
		return
	dev_placement_overlay_enabled = not dev_placement_overlay_enabled
	var state := "ON" if dev_placement_overlay_enabled else "OFF"
	update_hud("DEV: Placement overlay %s." % state)
	queue_redraw()


func unlock_weight_adaptation() -> void:
	weight_speed_debuff_disabled = true
	vore_component.save_progress()
	update_hud("Passive unlocked: weight no longer reduces movement speed.")


func start_vore_execution(duration: float) -> void:
	vore_execution_duration = maxf(duration, 0.001)
	vore_execution_time = vore_execution_duration
	hit_stop = maxf(hit_stop, vore_execution_duration)

func unlock_intake_route(route_name: String) -> bool:
	return vore_component.unlock_route(route_name)


func unlock_tail() -> void:
	story_flags["tail_unlocked"] = true
	tail_unlocked = true
	vore_component.save_progress()
	update_hud("Biomass tail unlocked. Linxi carries it behind her, ready to strike.")


func refresh_story_unlocks() -> void:
	tail_unlocked = bool(story_flags.get("tail_unlocked", false))


func update_hud(message: String) -> void:
	hud_controller_component.update_hud(message)


func open_transition_prompt(item: Dictionary) -> void:
	hud_controller_component.open_transition_prompt(item)


func _cancel_pending_transition() -> void:
	hud_controller_component.cancel_pending_transition()


func _confirm_pending_transition() -> void:
	hud_controller_component.confirm_pending_transition()


func open_dialogue_choice(choice: Dictionary) -> void:
	hud_controller_component.open_dialogue_choice(choice)


func show_achievement(title: String, duration: float = 4.0) -> void:
	hud_controller_component.show_achievement(title, duration)


func _refresh_hud_labels() -> void:
	hud_controller_component.refresh_hud_labels()


func active_enemy_debug_state() -> Dictionary:
	return hud_controller_component.active_enemy_debug_state()


func _update_camera(delta: float) -> void:
	projection_component.update_camera(delta)


func _is_fixed_room() -> bool:
	return projection_component.is_fixed_room()


func _ground_origin() -> Vector2:
	return projection_component.ground_origin()


func _project_ground(ground: Vector2) -> Vector2:
	return projection_component.project_ground(ground)


func _project_actor(ground: Vector2) -> Vector2:
	return projection_component.project_actor(ground)


func player_safe_screen_rect() -> Rect2:
	return projection_component.player_safe_screen_rect()


func _camera_scroll_range() -> float:
	return projection_component.camera_max_x()


func map_walkable_rects() -> Array[Rect2]:
	return projection_component.map_walkable_rects()


func map_walkable_polygons() -> Array[PackedVector2Array]:
	return projection_component.map_walkable_polygons()


func map_blocked_rects() -> Array[Rect2]:
	return projection_component.map_blocked_rects()


func map_blocked_polygons() -> Array[PackedVector2Array]:
	return projection_component.map_blocked_polygons()


func is_ground_walkable(ground_position: Vector2) -> bool:
	return projection_component.is_ground_walkable(ground_position)


func is_ground_blocked(ground_position: Vector2) -> bool:
	return projection_component.is_ground_blocked(ground_position)


func resolve_map_blockers(previous_position: Vector2, desired_position: Vector2) -> Vector2:
	return projection_component.resolve_map_blockers(previous_position, desired_position)


func _draw() -> void:
	if not components_ready:
		return
	var viewport_size := get_viewport_rect().size
	var fixed_room := _is_fixed_room()
	draw_rect(Rect2(Vector2.ZERO, viewport_size), map_renderer_component.clear_color(map_data, fixed_room))
	if story_overlay == "CHAOS_CHASE" and story_pose_time >= 1.25:
		_draw_story_overlay(viewport_size)
		return
	_draw_map_background(viewport_size)
	_draw_projected_belt()
	_draw_combat_readability_layers()
	_draw_ground_hit_effects()
	_draw_contamination_mist_field()

	var drawables: Array[Dictionary] = []
	drawables.append({"depth": player_ground.y, "kind": "player", "position": _project_actor(player_ground)})
	for index in range(scene_items.size()):
		var item: Dictionary = scene_items[index]
		if not bool(item.get("active", true)): continue
		var item_position := Vector2(item["position"])
		var item_depth := item_position.y + (8.0 if bool(item.get("render_above_knocked_down", false)) else 0.0)
		drawables.append({"depth": item_depth, "kind": "item", "position": _project_actor(item_position), "index": index})
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		if enemy["state"] in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED"]: continue
		var floor_position := _project_actor(Vector2(enemy["position"]))
		_draw_shadow(floor_position, enemy_shadow_radius(enemy))
		drawables.append({"depth": Vector2(enemy["position"]).y, "kind": "enemy", "position": floor_position, "index": index})
	for index in range(weapon_projectiles.size()):
		var projectile: Dictionary = weapon_projectiles[index]
		var projectile_position := Vector2(projectile.get("position", Vector2.ZERO))
		var screen_position := _project_actor(projectile_position) + Vector2(0.0, -float(projectile.get("height", 0.0)))
		drawables.append({"depth": projectile_position.y + 2.0, "kind": "weapon_projectile", "position": screen_position, "index": index})
	_draw_shadow(_project_actor(player_ground), player_shadow_radius())
	drawables.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["depth"]) < float(b["depth"]))
	for drawable in drawables:
		if drawable["kind"] == "player": _draw_player(drawable["position"])
		elif drawable["kind"] == "item": _draw_scene_item(drawable["position"], scene_items[int(drawable["index"])])
		elif drawable["kind"] == "weapon_projectile": _draw_weapon_projectile(drawable["position"], weapon_projectiles[int(drawable["index"])])
		else: _draw_enemy(drawable["position"], enemies[int(drawable["index"])])
	_draw_body_hit_effects()
	_draw_map_foreground(viewport_size)
	if development_mode and dev_placement_overlay_enabled:
		debug_component.draw_dev_placement_overlay(viewport_size)

	var player_floor := _project_actor(player_ground)
	if digesting and enemy_contained and occupied_vore_capacity > 0: _draw_digest_bar(player_floor)
	world_fx_component.draw_player_message(player_floor)
	if vore_flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.75, 0.9, 1.0, vore_flash * 0.55), true)
	if not story_overlay.is_empty():
		_draw_story_overlay(viewport_size)


func _draw_map_background(viewport_size: Vector2) -> void:
	var far_left := _project_ground(Vector2(ground_min_x, ground_depth))
	var far_right := _project_ground(Vector2(ground_width, ground_depth))
	var near_left := _project_ground(Vector2(ground_min_x, 0.0))
	var near_right := _project_ground(Vector2(ground_width, 0.0))
	map_renderer_component.draw_background(viewport_size, map_data, _is_fixed_room(), camera_x, _camera_scroll_range(), ground_width, ground_depth, far_left, far_right, near_left, near_right)


func _draw_map_foreground(viewport_size: Vector2) -> void:
	map_renderer_component.draw_foreground(viewport_size, map_data, _is_fixed_room(), camera_x, _camera_scroll_range())


func _update_hit_effects(delta: float) -> void:
	world_fx_component.update_hit_effects(delta)


func spawn_hit_effect(ground_position: Vector2, direction: float = 1.0) -> void:
	world_fx_component.spawn_hit_effect(ground_position, direction)


func _nebulizer_item() -> Dictionary:
	return world_fx_component.nebulizer_item()


func _build_contamination_mist_points() -> void:
	world_fx_component.build_contamination_mist_points()


func _draw_body_hit_effects() -> void:
	world_fx_component.draw_body_hit_effects()


func _draw_ground_hit_effects() -> void:
	world_fx_component.draw_ground_hit_effects()


func _draw_contamination_mist_field() -> void:
	world_fx_component.draw_contamination_mist_field()


func _draw_digest_bar(floor_position: Vector2) -> void:
	world_fx_component.draw_digest_bar(floor_position)


func _draw_projected_belt() -> void:
	world_fx_component.draw_projected_belt()


func _draw_combat_readability_layers() -> void:
	world_fx_component.draw_combat_readability_layers()


func _draw_shadow(at: Vector2, width: float) -> void:
	world_fx_component.draw_shadow(at, width)


func biomass_growth_scale() -> float:
	return balance.growth_scale(biomass)


func player_shadow_radius() -> float:
	var base_radius := PLAYER_BASE_SHADOW_RADIUS
	if g_mode:
		base_radius = MUTANT_SHADOW_RADIUS
	return base_radius * biomass_growth_scale()


func player_shadow_depth_radius() -> float:
	return player_shadow_radius() * SHADOW_DEPTH_RATIO


func enemy_shadow_radius(enemy: Dictionary) -> float:
	if enemy.has("shadow_radius"):
		return maxf(float(enemy.get("shadow_radius", HUMAN_SHADOW_RADIUS)), 1.0)
	match int(enemy.get("family", EnemyFamily.HUMAN)):
		EnemyFamily.ZOMBIE:
			return ZOMBIE_SHADOW_RADIUS
		EnemyFamily.MUTANT_CREATURE:
			return MUTANT_SHADOW_RADIUS
		_:
			return HUMAN_SHADOW_RADIUS


func enemy_shadow_depth_radius(enemy: Dictionary) -> float:
	return enemy_shadow_radius(enemy) * SHADOW_DEPTH_RATIO


func _draw_player(floor_position: Vector2) -> void:
	player_renderer_component.draw_player(floor_position)


func _draw_story_overlay(viewport_size: Vector2) -> void:
	effect_renderer_component.draw_story_overlay(viewport_size, story_overlay, story_pose_time)


func _draw_scene_item(floor_position: Vector2, item: Dictionary) -> void:
	var visual_data: ItemVisualData = map_data.item_visual_data if map_data != null else null
	item_renderer_component.draw_item(floor_position, item, player_ground, story_pose, visual_data)


func _draw_enemy(floor_position: Vector2, enemy: Dictionary) -> void:
	enemy_renderer_component.draw_enemy(floor_position, enemy)


func _draw_weapon_projectile(screen_position: Vector2, projectile: Dictionary) -> void:
	weapon_component.draw_projectile(screen_position, projectile)
