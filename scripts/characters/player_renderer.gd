extends Node

const INTAKE_LAYER_OFFSET := Vector2(0.0, 34.0)
const BELLY_LAYER_TIER_X_OFFSETS := {
	1: -5.0,
	3: -5.0
}
const SAFE_ZONE_PADDING := 16.0
const FRAME_HALF_WIDTH := 128.0
const FRAME_TOP_EXTENT := 248.0
const FRAME_BOTTOM_EXTENT := 8.0

var host: Node2D
var route_layer_visible_regions: Dictionary = {}
var route_layer_cropped_textures: Dictionary = {}


func setup(owner: Node) -> void:
	host = owner as Node2D


func draw_player(floor_position: Vector2) -> void:
	var color := Color("ffffff") if host.player_hurt_flash > 0.0 else (Color("708a92") if host.g_mode else Color.WHITE)
	var visual_position := floor_position + Vector2(0.0, -host.player_height)
	if host.story_pose == "STAND_UP":
		_draw_stand_up_pose(visual_position, color)
		return
	if host.story_pose == "DRINK_BLUE":
		_draw_drink_blue_pose(visual_position, color)
		return
	if host.story_pose == "COLLAPSED":
		_draw_collapsed_pose(visual_position, color)
		return
	if host.vore_execution_time > 0.0 and not host.g_mode:
		var vore_scale := t_form_visual_scale()
		_draw_tail_ready_overlay(visual_position, color)
		host.draw_set_transform(visual_position, 0.0, vore_scale)
		_draw_motion_texture(_current_t_form_texture(), Vector2(-128.0, -248.0), color, Vector2(host.facing, 0.0), 0.65)
		host.draw_set_transform(Vector2.ZERO)
		if host.enemy_contained:
			_draw_route_expansions(visual_position, vore_scale, color)
		var pulse := 1.0 - clampf(host.vore_execution_time / maxf(host.vore_execution_duration, 0.001), 0.0, 1.0)
		host.draw_set_transform(visual_position + Vector2(0.0, -72.0), 0.0, Vector2(1.0 + pulse * 0.35, 0.55 + pulse * 0.18))
		host.draw_arc(Vector2.ZERO, 36.0, 0.0, TAU, 28, Color(0.38, 0.9, 1.0, 0.35 * (1.0 - pulse)), 5.0)
		host.draw_set_transform(Vector2.ZERO)
		return
	if host.dodge_time > 0.0 and not host.g_mode:
		_draw_tail_ready_overlay(visual_position, color)
		host.draw_set_transform(visual_position, 0.0, Vector2.ONE * t_form_render_scale())
		_draw_motion_texture(_current_dodge_texture(), Vector2(-128.0, -248.0), color, _player_motion_trail_direction(), 1.25)
		host.draw_set_transform(Vector2.ZERO)
		return
	if host.player_hit_reaction_time > 0.0 and not host.g_mode:
		_draw_tail_ready_overlay(visual_position, color)
		host.draw_set_transform(visual_position, 0.0, Vector2.ONE * t_form_render_scale())
		_draw_motion_texture(_current_player_hit_texture(), Vector2(-128.0, -248.0), color, _player_motion_trail_direction(), 0.75)
		host.draw_set_transform(Vector2.ZERO)
		if host.enemy_contained:
			_draw_route_expansions(visual_position, Vector2.ONE * t_form_render_scale() * biomass_growth_scale(), color)
		return
	if host.attack_cooldown > 0.0 and host.attack_duration_current > 0.0 and host.body_weapon == "claws" and not host.g_mode:
		var attack_scale := Vector2.ONE * t_form_render_scale() * biomass_growth_scale()
		_draw_tail_ready_overlay(visual_position, color)
		host.draw_set_transform(visual_position, 0.0, attack_scale)
		_draw_motion_texture(_current_claw_attack_texture(), Vector2(-128.0, -248.0), color, _player_motion_trail_direction(), 1.05)
		host.draw_set_transform(Vector2.ZERO)
		if host.enemy_contained:
			_draw_route_expansions(visual_position, attack_scale, color)
		_draw_claw_slash_effect(visual_position)
		return
	if not host.g_mode:
		_draw_tail_ready_overlay(visual_position, color)
		host.draw_set_transform(visual_position, 0.0, t_form_visual_scale())
		_draw_motion_texture(_current_t_form_texture(), Vector2(-128.0, -248.0), color, _player_motion_trail_direction(), 0.52)
		host.draw_set_transform(Vector2.ZERO)
	else:
		host.draw_set_transform(visual_position, 0.0, Vector2(1.34, 1.46) * biomass_growth_scale())
		_draw_motion_texture(_current_t_form_texture(), Vector2(-128.0, -248.0), Color("59676d"), _player_motion_trail_direction(), 0.3)
		host.draw_set_transform(Vector2.ZERO)
	if host.enemy_contained:
		var form_scale := t_form_visual_scale() if not host.g_mode else Vector2(1.65, 1.8) * biomass_growth_scale()
		_draw_route_expansions(visual_position, form_scale, color)
	if host.attack_cooldown > 0.0:
		host.draw_set_transform(visual_position)
		host.draw_arc(Vector2(host.facing * 45.0, -36.0), 50.0 + host.combo_step * 7.0, -1.0, 1.0, 20, Color("f5c451"), 7.0)
		host.draw_set_transform(Vector2.ZERO)


func t_form_render_scale() -> float:
	return host.player_visual_component.render_scale()


func t_form_visual_scale() -> Vector2:
	var scale := Vector2.ONE * t_form_render_scale() * biomass_growth_scale()
	var moving: bool = host.player_component.input_direction().length_squared() > 0.01 and not host.digesting and not host.player_defeated
	if not moving and host.facing > 0.0:
		scale.x *= -1.0
	return scale


func screen_safe_insets() -> Vector4:
	var visual_scale: Vector2
	if host.g_mode:
		visual_scale = Vector2(1.34, 1.46) * biomass_growth_scale()
	else:
		visual_scale = Vector2.ONE * t_form_render_scale() * biomass_growth_scale()
	var horizontal: float = FRAME_HALF_WIDTH * visual_scale.x + SAFE_ZONE_PADDING
	var top: float = FRAME_TOP_EXTENT * visual_scale.y + SAFE_ZONE_PADDING
	var bottom: float = maxf(FRAME_BOTTOM_EXTENT * visual_scale.y, host.player_shadow_depth_radius()) + SAFE_ZONE_PADDING
	return Vector4(horizontal, top, horizontal, bottom)


func biomass_growth_scale() -> float:
	return host.balance.growth_scale(host.biomass)


func _current_t_form_texture() -> Texture2D:
	var moving: bool = host.player_component.input_direction().length_squared() > 0.01 and not host.digesting and not host.player_defeated
	return host.player_visual_component.current_t_form_texture(moving, host.movement_mode, host.player_animation_time, host.facing)


func _current_dodge_texture() -> Texture2D:
	var duration: float = maxf(host.dodge_duration_current, 0.001)
	var progress := clampf((duration - host.dodge_time) / duration, 0.0, 0.999)
	return host.player_visual_component.current_dodge_texture(progress, host.facing)


func _current_player_hit_texture() -> Texture2D:
	var duration: float = maxf(host.player_hit_reaction_duration, 0.001)
	var progress := clampf((duration - host.player_hit_reaction_time) / duration, 0.0, 0.999)
	return host.player_visual_component.current_player_hit_texture(progress, host.facing)


func _current_tail_ready_texture() -> Texture2D:
	return host.player_visual_component.current_tail_ready_texture(host.player_animation_time, host.facing)


func _attack_progress() -> float:
	var duration: float = maxf(host.attack_duration_current, 0.001)
	return clampf((duration - host.attack_cooldown) / duration, 0.0, 0.999)


func _combo_stage_frame_index(frame_count: int) -> int:
	var stage := clampi(host.combo_step, 1, 3)
	var frames_per_stage := maxi(floori(float(frame_count) / 3.0), 1)
	var start_index := mini((stage - 1) * frames_per_stage, frame_count - 1)
	var end_index := frame_count - 1 if stage == 3 else mini(start_index + frames_per_stage - 1, frame_count - 1)
	var stage_frame_count := maxi(end_index - start_index + 1, 1)
	return mini(start_index + int(floor(_attack_progress() * float(stage_frame_count))), end_index)


func _current_claw_attack_texture() -> Texture2D:
	var frame_count: int = host.player_visual_component.claw_attack_frame_count(host.facing)
	if frame_count <= 0:
		return null
	var frame_index: int = _combo_stage_frame_index(frame_count)
	return host.player_visual_component.current_claw_attack_texture(frame_index, host.facing)


func _current_claw_slash_texture() -> Texture2D:
	var slash_type := "red" if host.body_weapon == "claws" else "silver"
	var frame_count: int = host.effect_renderer_component.claw_slash_frame_count(slash_type, host.facing)
	if frame_count <= 0:
		return null
	var frame_index: int = _combo_stage_frame_index(frame_count)
	return host.effect_renderer_component.claw_slash_texture(slash_type, host.facing, frame_index)


func _draw_claw_slash_effect(visual_position: Vector2) -> void:
	var slash_texture: Texture2D = _current_claw_slash_texture()
	var slash_offset := Vector2(host.facing * 58.0, -94.0)
	var slash_scale := Vector2.ONE * t_form_render_scale() * biomass_growth_scale() * 1.12
	host.draw_set_transform(visual_position + slash_offset, 0.0, slash_scale)
	_draw_motion_texture(slash_texture, Vector2(-128.0, -128.0), Color.WHITE, Vector2(host.facing, 0.0), 1.0)
	host.draw_set_transform(Vector2.ZERO)


func _draw_tail_ready_overlay(visual_position: Vector2, color: Color = Color.WHITE) -> void:
	if not host.tail_unlocked or host.g_mode:
		return
	var tail_offset := Vector2(-26.0 * host.facing, -118.0)
	var tail_scale := Vector2.ONE * t_form_render_scale() * biomass_growth_scale()
	host.draw_set_transform(visual_position + tail_offset, 0.0, tail_scale)
	_draw_motion_texture(_current_tail_ready_texture(), Vector2(-128.0, -128.0), color, Vector2(host.facing, 0.0), 0.42)
	host.draw_set_transform(Vector2.ZERO)


func _current_visual_state() -> String:
	var moving: bool = host.player_component.input_direction().length_squared() > 0.01 and not host.digesting and not host.player_defeated
	if not moving:
		return "idle"
	return "walk_right" if host.facing > 0.0 else "walk_left"


func _route_layer_texture(region: String, prey_count: int) -> Texture2D:
	if prey_count <= 0 or host.g_mode:
		return null
	var tier := route_visual_tier(prey_count)
	var visual_state := _current_visual_state()
	var frame := _route_layer_frame_index(visual_state)
	return host.player_visual_component.route_layer_texture(region, tier, visual_state, frame)


func _route_layer_frame_index(visual_state: String) -> int:
	var body_frame := int(floor(host.player_animation_time))
	if visual_state.begins_with("walk"):
		if host.movement_mode == "SPRINT":
			return int(floor(float(body_frame % 8) / 2.0)) % 4
		return int(floor(float(body_frame % 16) / 4.0)) % 4
	return body_frame % 4


func _draw_route_expansions(visual_position: Vector2, form_scale: Vector2, color: Color) -> void:
	var belly := int(host.contained_route_loads.get("BELLY", 0))
	var region_counts := {"BELLY": belly}
	for region in region_counts:
		var prey_count := int(region_counts[region])
		var layer := _route_layer_texture(region, prey_count)
		if layer != null:
			var tier := route_visual_tier(prey_count)
			var overflow := route_overflow_scale(prey_count) * 1.2
			var tier_offset := belly_layer_tier_offset(tier) if region == "BELLY" else Vector2.ZERO
			host.draw_set_transform(visual_position + (INTAKE_LAYER_OFFSET + tier_offset) * form_scale, 0.0, form_scale * overflow)
			_draw_route_layer_texture(layer, _route_layer_draw_origin(layer), color)
			region_counts[region] = 0
	var y_belly := -48.0 if not host.g_mode else 20.0
	belly = int(region_counts["BELLY"])
	if belly > 0 and _development_mode():
		var tier := route_visual_tier(belly)
		host.draw_set_transform(visual_position + Vector2(0.0, y_belly) * form_scale, 0.0, Vector2(1.25, 0.82) * form_scale * route_overflow_scale(belly))
		host.draw_circle(Vector2.ZERO, [0.0, 14.0, 18.0, 22.0, 26.0][tier], Color(0.45, 0.82, 0.92, 0.68))
	host.draw_set_transform(Vector2.ZERO)


func _draw_route_layer_texture(texture: Texture2D, origin: Vector2, color: Color) -> void:
	var region := _route_layer_visible_region(texture)
	if region.size.x <= 0.0 or region.size.y <= 0.0:
		return
	var cropped_texture := _route_layer_cropped_texture(texture, region)
	if cropped_texture == null:
		return
	host.draw_texture(cropped_texture, origin + region.position, color)


func _route_layer_draw_origin(texture: Texture2D) -> Vector2:
	var size := texture.get_size()
	var extra_size := Vector2(maxf(0.0, size.x - 256.0), maxf(0.0, size.y - 256.0))
	return Vector2(-128.0 - extra_size.x * 0.5, -248.0 - extra_size.y * 0.5)


func _route_layer_visible_region(texture: Texture2D) -> Rect2:
	if texture == null:
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	var key := texture.resource_path
	if key.is_empty():
		key = str(texture.get_rid())
	if route_layer_visible_regions.has(key):
		return route_layer_visible_regions[key]
	var image := _route_layer_source_image(texture)
	if image == null or image.is_empty():
		push_warning("Route layer has no readable alpha source: %s" % key)
		var empty := Rect2(Vector2.ZERO, Vector2.ZERO)
		route_layer_visible_regions[key] = empty
		return empty
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a <= 0.02:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		var empty := Rect2(Vector2.ZERO, Vector2.ZERO)
		route_layer_visible_regions[key] = empty
		return empty
	var padding := 2
	min_x = maxi(min_x - padding, 0)
	min_y = maxi(min_y - padding, 0)
	max_x = mini(max_x + padding, image.get_width() - 1)
	max_y = mini(max_y + padding, image.get_height() - 1)
	var region := Rect2(Vector2(float(min_x), float(min_y)), Vector2(float(max_x - min_x + 1), float(max_y - min_y + 1)))
	route_layer_visible_regions[key] = region
	return region


func _route_layer_source_image(texture: Texture2D) -> Image:
	if texture != null and not texture.resource_path.is_empty() and texture.resource_path.begins_with("res://"):
		var file_path := ProjectSettings.globalize_path(texture.resource_path)
		if FileAccess.file_exists(file_path):
			var source_image := Image.load_from_file(file_path)
			if source_image != null and not source_image.is_empty():
				return source_image
	return texture.get_image() if texture != null else null


func _route_layer_cropped_texture(texture: Texture2D, region: Rect2) -> Texture2D:
	var key := "%s:%s:%s:%s:%s" % [
		texture.resource_path if not texture.resource_path.is_empty() else str(texture.get_rid()),
		int(region.position.x),
		int(region.position.y),
		int(region.size.x),
		int(region.size.y),
	]
	if route_layer_cropped_textures.has(key):
		return route_layer_cropped_textures[key]
	var source_image := _route_layer_source_image(texture)
	if source_image == null or source_image.is_empty():
		route_layer_cropped_textures[key] = null
		return null
	var cropped_image := source_image.get_region(Rect2i(
		Vector2i(int(region.position.x), int(region.position.y)),
		Vector2i(int(region.size.x), int(region.size.y))
	))
	if cropped_image == null or cropped_image.is_empty():
		route_layer_cropped_textures[key] = null
		return null
	var cropped_texture := ImageTexture.create_from_image(cropped_image)
	route_layer_cropped_textures[key] = cropped_texture
	return cropped_texture


func _draw_motion_texture(texture: Texture2D, offset: Vector2, color: Color, direction: Vector2, strength: float = 1.0) -> void:
	host.effect_renderer_component.draw_texture_with_trail(texture, offset, color, direction, strength)


func _player_motion_trail_direction(reason: String = "") -> Vector2:
	if host.dodge_time > 0.0:
		return host.dodge_direction
	if host.attack_cooldown > 0.0:
		return Vector2(host.facing, 0.0)
	if host.player_hit_reaction_time > 0.0:
		return Vector2(-host.facing, 0.0)
	var input_direction: Vector2 = host.player_component.input_direction()
	if input_direction.length_squared() > 0.001:
		return Vector2(input_direction.x, input_direction.y * 0.35)
	if reason == "story":
		return Vector2(host.facing, 0.0)
	return Vector2.ZERO


func _draw_stand_up_pose(visual_position: Vector2, color: Color) -> void:
	host.draw_set_transform(visual_position, 0.0, Vector2.ONE * t_form_render_scale())
	_draw_motion_texture(host.player_visual_component.current_get_up_texture(host.story_pose_time), Vector2(-128.0, -248.0), color, Vector2(0.0, -1.0), 0.35)
	host.draw_set_transform(Vector2.ZERO)


func _draw_collapsed_pose(visual_position: Vector2, color: Color) -> void:
	host.draw_set_transform(visual_position, 0.0, Vector2.ONE * t_form_render_scale())
	_draw_motion_texture(host.player_visual_component.collapsed_texture(), Vector2(-128.0, -248.0), color.darkened(0.08), Vector2.ZERO, 0.0)
	host.draw_set_transform(Vector2.ZERO)


func _draw_drink_blue_pose(visual_position: Vector2, color: Color) -> void:
	host.draw_set_transform(visual_position, 0.0, Vector2.ONE * t_form_render_scale())
	_draw_motion_texture(host.player_visual_component.current_drink_blue_texture(host.story_pose_time), Vector2(-128.0, -248.0), color, Vector2(0.35, -0.15), 0.35)
	host.draw_set_transform(Vector2.ZERO)


func route_visual_tier(prey_count: int) -> int:
	return host.balance.route_visual_tier(prey_count)


func route_overflow_scale(prey_count: int) -> float:
	return host.balance.route_overflow_scale(prey_count)


func belly_layer_tier_offset(tier: int) -> Vector2:
	return Vector2(float(BELLY_LAYER_TIER_X_OFFSETS.get(tier, 0.0)), 0.0)


func _development_mode() -> bool:
	return host != null and bool(host.get("development_mode"))
