extends Node

const ENEMY_RENDER_SCALE := 0.58
const BONE_BLADE_ELITE_RENDER_SCALE := 0.78
const HUMAN_STUDENT_MALE_UPRIGHT_RENDER_SCALE := 1.10
const HUMAN_STUDENT_FEMALE_UPRIGHT_RENDER_SCALE := 1.06
const HUMAN_STUDENT_KNIFE_UPRIGHT_RENDER_SCALE := 0.99
const HUMAN_STUDENT_TARGET_VISIBLE_HEIGHT := 126.0
const DEFAULT_TARGET_VISIBLE_HEIGHT := 224.0
const OVERSIZED_TEXTURE_TOLERANCE := 1.08
const ATTACK_TEXTURE_HEIGHT_TOLERANCE := 1.03
const ZOMBIE_ATTACK_VISIBLE_HEIGHT_RATIO := 0.95
const KNOCKED_DOWN_GROUND_SINK := 34.0

var host: Node2D
var texture_visible_regions: Dictionary = {}
var cropped_textures: Dictionary = {}
var source_images: Dictionary = {}
var missing_visual_warnings: Dictionary = {}


func setup(owner: Node) -> void:
	host = owner as Node2D


func draw_enemy(floor_position: Vector2, enemy: Dictionary) -> void:
	var state := String(enemy["state"])
	var base_color: Color = Color("8e9a91") if int(enemy.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.ZOMBIE else Color("d35d6e")
	var color: Color = base_color
	if state == "RECOVER": color = Color("9b6f82")
	elif int(enemy["health"]) <= 0: color = Color("4b5268")
	if state == "KNOCKED_DOWN" or int(enemy["health"]) <= 0:
		var knocked_texture: Texture2D = host.enemy_visual_component.enemy_knocked_down_texture(enemy)
		if knocked_texture != null:
			host.draw_set_transform(floor_position, 0.0, enemy_render_scale(enemy, true))
			draw_enemy_texture_grounded(knocked_texture, Color.WHITE, Vector2(0.0, KNOCKED_DOWN_GROUND_SINK))
			host.draw_set_transform(Vector2.ZERO)
			return
	if float(enemy.get("hit_reaction_time", 0.0)) > 0.0 and int(enemy["health"]) > 0:
		var hit_texture: Texture2D = host.enemy_visual_component.current_enemy_hit_texture(enemy)
		if hit_texture != null:
			var hit_pose: Dictionary = host.enemy_visual_component.enemy_hit_pose(enemy)
			var flash_color := enemy_hit_flash_color(enemy)
			host.draw_set_transform(floor_position + Vector2(hit_pose["offset"]), float(hit_pose["rotation"]), enemy_render_scale_for_texture(enemy, hit_texture) * Vector2(hit_pose["scale"]))
			draw_enemy_texture_grounded(hit_texture, flash_color)
			host.draw_set_transform(Vector2.ZERO)
			draw_enemy_health_bar(floor_position, enemy)
			return
	var appearance_texture: Texture2D = host.enemy_visual_component.enemy_appearance_texture(enemy)
	if appearance_texture != null and int(enemy["health"]) > 0:
		var sprite_color: Color = Color.WHITE
		if state == "RECOVER": sprite_color = Color("9b6f82")
		var render_scale := enemy_render_scale_for_texture(enemy, appearance_texture)
		host.draw_set_transform(floor_position, 0.0, render_scale)
		if is_bone_blade_elite(enemy) and is_bone_blade_attack_state(state):
			draw_bone_blade_motion_blur(appearance_texture, enemy, state)
		if is_casting_state(state):
			draw_enemy_attack_rim(appearance_texture, enemy, state)
		if state == "RECOVER" and int(enemy.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.ZOMBIE and not is_bone_blade_elite(enemy):
			draw_enemy_strike_motion_blur(appearance_texture, enemy)
		elif state == "RECOVER" and String(enemy.get("weapon_id", "")) == "knife":
			draw_enemy_knife_motion_blur(appearance_texture, enemy)
		draw_enemy_texture_grounded(appearance_texture, sprite_color)
		if state == "RECOVER" or state == "SPECIAL_RUSH":
			draw_enemy_attack_slash_fx(floor_position, enemy)
		host.draw_set_transform(Vector2.ZERO)
		draw_enemy_health_bar(floor_position, enemy)
		if is_casting_state(state) and not is_bone_blade_elite(enemy):
			draw_enemy_cast_bar(floor_position, enemy, state)
		return
	var fallback_hit_pose: Dictionary = host.enemy_visual_component.enemy_hit_pose(enemy) if float(enemy.get("hit_reaction_time", 0.0)) > 0.0 and int(enemy["health"]) > 0 else {"offset": Vector2.ZERO, "rotation": 0.0, "scale": Vector2.ONE}
	var fallback_position := floor_position + Vector2(fallback_hit_pose["offset"])
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	_warn_missing_enemy_visual(enemy)
	if not _development_mode():
		return
	if state == "KNOCKED_DOWN" or int(enemy["health"]) <= 0:
		host.draw_set_transform(fallback_position + Vector2(0.0, KNOCKED_DOWN_GROUND_SINK), float(fallback_hit_pose["rotation"]), Vector2(fallback_hit_pose["scale"]))
		draw_procedural_knocked_down_enemy(enemy, color)
		host.draw_set_transform(Vector2.ZERO)
		return
	host.draw_set_transform(fallback_position, float(fallback_hit_pose["rotation"]), Vector2(fallback_hit_pose["scale"]))
	host.draw_circle(Vector2(0.0, -55.0), 18.0, color)
	if family == host.EnemyFamily.MUTANT_CREATURE:
		host.draw_circle(Vector2(0.0, -54.0), 25.0, color.darkened(0.08))
		host.draw_rect(Rect2(-38.0, -34.0, 76.0, 72.0), color, true)
		host.draw_line(Vector2(-28.0, -20.0), Vector2(float(enemy["facing"]) * 58.0, -46.0), Color("b8d3d0"), 10.0)
		host.draw_line(Vector2(22.0, 16.0), Vector2(-float(enemy["facing"]) * 50.0, 28.0), Color("56636f"), 8.0)
	else:
		host.draw_rect(Rect2(-28.0, -38.0, 56.0, 66.0), color, true)
		host.draw_line(Vector2.ZERO, Vector2(float(enemy["facing"]) * 42.0, -26.0), Color("e9e1cf"), 7.0)
	for knife_index in range(int(enemy.get("embedded_knives", 0))):
		host.draw_line(Vector2(-12.0 + knife_index * 5.0, -36.0), Vector2(14.0 + knife_index * 5.0, -43.0), Color("d8dde4"), 3.0)
	host.draw_set_transform(Vector2.ZERO)
	if is_casting_state(state):
		draw_procedural_attack_rim(floor_position, enemy, state)
	draw_enemy_health_bar(floor_position, enemy)
	if is_casting_state(state):
		draw_enemy_cast_bar(floor_position, enemy, state)


func enemy_render_scale(enemy: Dictionary, knocked_down: bool = false) -> Vector2:
	if is_bone_blade_elite(enemy):
		return Vector2.ONE * BONE_BLADE_ELITE_RENDER_SCALE
	if not knocked_down and is_human_student_archetype(enemy):
		if String(enemy.get("weapon_id", "")) == "knife":
			return Vector2.ONE * HUMAN_STUDENT_KNIFE_UPRIGHT_RENDER_SCALE
		if is_human_student_female_appearance_id(int(enemy.get("appearance_id", 0))):
			return Vector2.ONE * HUMAN_STUDENT_FEMALE_UPRIGHT_RENDER_SCALE
		return Vector2.ONE * HUMAN_STUDENT_MALE_UPRIGHT_RENDER_SCALE
	return Vector2.ONE * ENEMY_RENDER_SCALE


func enemy_render_scale_for_texture(enemy: Dictionary, texture: Texture2D, knocked_down: bool = false) -> Vector2:
	var base_scale := enemy_render_scale(enemy, knocked_down)
	if knocked_down or texture == null:
		return base_scale
	var region := enemy_texture_visible_region(texture)
	if region.size.y <= 0.0:
		return base_scale
	var attack_target_height := enemy_attack_reference_visible_height(enemy, texture)
	if attack_target_height > 0.0:
		if uses_reduced_zombie_attack_scale(enemy, texture):
			attack_target_height *= ZOMBIE_ATTACK_VISIBLE_HEIGHT_RATIO
			return base_scale * (attack_target_height / region.size.y)
		var height_ratio := region.size.y / attack_target_height
		if height_ratio > ATTACK_TEXTURE_HEIGHT_TOLERANCE or height_ratio < 1.0 / ATTACK_TEXTURE_HEIGHT_TOLERANCE:
			return base_scale * (attack_target_height / region.size.y)
		return base_scale
	var target_height := enemy_target_visible_height(enemy)
	if region.size.y <= target_height * OVERSIZED_TEXTURE_TOLERANCE:
		return base_scale
	return base_scale * (target_height / region.size.y)


func enemy_attack_reference_visible_height(enemy: Dictionary, texture: Texture2D) -> float:
	if not is_enemy_attack_texture(texture):
		return 0.0
	if host.enemy_visual_component == null:
		return 0.0
	var reference_texture: Texture2D = host.enemy_visual_component.enemy_scale_reference_texture(enemy)
	if reference_texture == null:
		return 0.0
	var reference_region := enemy_texture_visible_region(reference_texture)
	return reference_region.size.y


func is_enemy_attack_texture(texture: Texture2D) -> bool:
	if texture == null:
		return false
	var path := texture.resource_path
	return path.contains("/attack/") or path.contains("/attack_")


func uses_reduced_zombie_attack_scale(enemy: Dictionary, texture: Texture2D) -> bool:
	return (
		is_enemy_attack_texture(texture)
		and int(enemy.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.ZOMBIE
		and not is_bone_blade_elite(enemy)
	)


func enemy_target_visible_height(enemy: Dictionary) -> float:
	if is_human_student_archetype(enemy):
		return HUMAN_STUDENT_TARGET_VISIBLE_HEIGHT
	return DEFAULT_TARGET_VISIBLE_HEIGHT


func is_human_student_archetype(enemy: Dictionary) -> bool:
	return int(enemy.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.HUMAN and String(enemy.get("archetype", enemy.get("id", ""))) == "human_student"


func is_bone_blade_elite(enemy: Dictionary) -> bool:
	return String(enemy.get("archetype", "")) == "bone_blade_twin" or String(enemy.get("ai_profile", "")) == "BONE_BLADE_ELITE"


func is_human_student_female_appearance_id(appearance_id: int) -> bool:
	return appearance_id >= 1 and appearance_id <= 5


func enemy_motion_trail_direction(enemy: Dictionary) -> Vector2:
	var state := String(enemy.get("state", ""))
	var facing_value: float = enemy_attack_visual_facing(enemy) if state in ["TELEGRAPH", "HEAVY_TELEGRAPH", "RECOVER", "SPECIAL_TELEGRAPH", "SPECIAL_RUSH", "SPECIAL_RECOVER"] else float(enemy.get("facing", -1.0))
	if float(enemy.get("hit_reaction_time", 0.0)) > 0.0:
		return Vector2(-facing_value, 0.0)
	if state in ["NEUTRAL", "APPROACH", "RECOVER", "SPECIAL_RUSH"]:
		return Vector2(facing_value, 0.0)
	if state == "TELEGRAPH" or state == "HEAVY_TELEGRAPH":
		return Vector2(facing_value * 0.45, 0.0)
	return Vector2.ZERO


func enemy_hit_flash_color(enemy: Dictionary) -> Color:
	var duration := maxf(float(enemy.get("hit_reaction_duration", 0.28)), 0.001)
	var time_left := clampf(float(enemy.get("hit_reaction_time", 0.0)), 0.0, duration)
	var flash := smoothstep(0.0, 1.0, time_left / duration)
	return Color(
		lerpf(1.0, 1.65, flash),
		lerpf(1.0, 1.42, flash),
		lerpf(1.0, 1.42, flash),
		1.0
	)


func is_casting_state(state: String) -> bool:
	return state in ["TELEGRAPH", "HEAVY_TELEGRAPH", "SPECIAL_TELEGRAPH"]


func is_bone_blade_attack_state(state: String) -> bool:
	return state in ["HEAVY_TELEGRAPH", "RECOVER", "SPECIAL_TELEGRAPH", "SPECIAL_RUSH", "SPECIAL_RECOVER"]


func attack_cast_color(state: String) -> Color:
	return Color("b84cff") if state in ["HEAVY_TELEGRAPH", "SPECIAL_TELEGRAPH"] else Color("f03238")


func attack_cast_progress(enemy: Dictionary, state: String) -> float:
	var duration: float
	if state == "SPECIAL_TELEGRAPH":
		duration = host.balance.bone_blade_special_telegraph_time
	elif is_bone_blade_elite(enemy):
		duration = host.balance.bone_blade_normal_windup_time
	else:
		duration = host.balance.human_heavy_telegraph_time if state == "HEAVY_TELEGRAPH" else host.balance.human_telegraph_time
	return 1.0 - clampf(float(enemy.get("state_time", 0.0)) / maxf(duration, 0.001), 0.0, 1.0)


func draw_enemy_attack_rim(texture: Texture2D, enemy: Dictionary, state: String) -> void:
	var progress := attack_cast_progress(enemy, state)
	var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) / 1000.0 * 18.0)
	var rim_color := attack_cast_color(state)
	rim_color.a = lerpf(0.46, 0.82, maxf(progress, pulse * 0.65))
	var spread := lerpf(3.0, 7.0, progress)
	var offsets := [
		Vector2(-spread, 0.0),
		Vector2(spread, 0.0),
		Vector2(0.0, -spread),
		Vector2(0.0, spread),
		Vector2(-spread, -spread) * 0.72,
		Vector2(spread, -spread) * 0.72,
		Vector2(-spread, spread) * 0.72,
		Vector2(spread, spread) * 0.72,
	]
	for offset in offsets:
		draw_enemy_texture_grounded(texture, rim_color, offset)


func draw_enemy_strike_motion_blur(texture: Texture2D, enemy: Dictionary) -> void:
	var facing_value := enemy_attack_visual_facing(enemy)
	var trail_color := Color("9f2730", 0.18)
	draw_enemy_texture_grounded(texture, trail_color, Vector2(-facing_value * 7.0, -8.0))
	trail_color.a = 0.10
	draw_enemy_texture_grounded(texture, trail_color, Vector2(-facing_value * 13.0, -15.0))


func draw_enemy_knife_motion_blur(texture: Texture2D, enemy: Dictionary) -> void:
	var facing_value := enemy_attack_visual_facing(enemy)
	var trail_color := Color("cfd5dc", 0.15)
	draw_enemy_texture_grounded(texture, trail_color, Vector2(-facing_value * 5.0, -3.0))
	trail_color.a = 0.08
	draw_enemy_texture_grounded(texture, trail_color, Vector2(-facing_value * 10.0, -6.0))


func draw_bone_blade_motion_blur(texture: Texture2D, enemy: Dictionary, state: String) -> void:
	var facing_value := enemy_attack_visual_facing(enemy)
	var finishing_pose := state in ["RECOVER", "SPECIAL_RECOVER"]
	if state == "SPECIAL_RUSH":
		finishing_pose = enemy_special_strike_progress(enemy) >= 0.2
	var distance := 16.0 if finishing_pose else 8.0
	var vertical := 10.0 if finishing_pose else 4.0
	var trail_color := Color("a82432", 0.22 if finishing_pose else 0.12)
	draw_enemy_texture_grounded(texture, trail_color, Vector2(-facing_value * distance, -vertical))
	trail_color.a *= 0.48
	draw_enemy_texture_grounded(texture, trail_color, Vector2(-facing_value * distance * 1.8, -vertical * 1.65))


func draw_enemy_attack_slash_fx(floor_position: Vector2, enemy: Dictionary) -> void:
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	if is_bone_blade_elite(enemy):
		draw_bone_blade_diagonal_fx(floor_position, enemy)
		return
	if family == host.EnemyFamily.ZOMBIE and not is_bone_blade_elite(enemy):
		draw_zombie_attack_vertical_fx(floor_position, enemy)
		return
	if String(enemy.get("weapon_id", "")) == "knife":
		draw_knife_attack_horizontal_fx(floor_position, enemy)
		return
	var slash_type := enemy_attack_slash_type(enemy)
	if slash_type.is_empty() or host.effect_renderer_component == null:
		return
	var facing_value := enemy_attack_visual_facing(enemy)
	var frame_count: int = host.effect_renderer_component.claw_slash_frame_count(slash_type, facing_value)
	if frame_count <= 0:
		return
	var progress := enemy_special_strike_progress(enemy) if String(enemy.get("state", "")) == "SPECIAL_RUSH" else enemy_recovery_progress(enemy)
	var frame_index := mini(int(floor(progress * float(frame_count))), frame_count - 1)
	var slash_texture: Texture2D = host.effect_renderer_component.claw_slash_texture(slash_type, facing_value, frame_index)
	if slash_texture == null:
		return
	var render_scale := enemy_render_scale(enemy)
	var offset := Vector2(facing_value * 56.0, -94.0)
	var scale := Vector2.ONE * 0.92
	if String(enemy.get("weapon_id", "")) == "knife":
		offset = Vector2(facing_value * 64.0, -96.0)
		scale = Vector2.ONE * 0.78
	var alpha := 1.0 - smoothstep(0.74, 1.0, progress)
	var screen_offset := Vector2(offset.x * render_scale.x, offset.y * render_scale.y)
	var slash_scale := Vector2(render_scale.x * scale.x, render_scale.y * scale.y)
	host.draw_set_transform(floor_position + screen_offset, 0.0, slash_scale)
	host.draw_texture(slash_texture, -slash_texture.get_size() * 0.5, Color(1.0, 1.0, 1.0, alpha))


func draw_zombie_attack_vertical_fx(floor_position: Vector2, enemy: Dictionary) -> void:
	if host.effect_renderer_component == null:
		return
	var facing_value := enemy_attack_visual_facing(enemy)
	var frame_count: int = host.effect_renderer_component.zombie_attack_vertical_frame_count(facing_value)
	if frame_count <= 0:
		return
	var progress := enemy_recovery_progress(enemy)
	var frame_index := mini(int(floor(progress * float(frame_count))), frame_count - 1)
	var strike_texture: Texture2D = host.effect_renderer_component.zombie_attack_vertical_texture(facing_value, frame_index)
	if strike_texture == null:
		return
	var render_scale := enemy_render_scale(enemy)
	var offset := Vector2(facing_value * 42.0, -96.0)
	var screen_offset := Vector2(offset.x * render_scale.x, offset.y * render_scale.y)
	var strike_scale := Vector2(render_scale.x * 0.82, render_scale.y * 0.98)
	var alpha := 1.0 - smoothstep(0.76, 1.0, progress)
	host.draw_set_transform(floor_position + screen_offset, 0.0, strike_scale)
	host.draw_texture(strike_texture, -strike_texture.get_size() * 0.5, Color(1.0, 1.0, 1.0, alpha))


func draw_bone_blade_diagonal_fx(floor_position: Vector2, enemy: Dictionary) -> void:
	if host.effect_renderer_component == null:
		return
	var facing_value := enemy_attack_visual_facing(enemy)
	var frame_count: int = host.effect_renderer_component.zombie_attack_vertical_frame_count(facing_value)
	if frame_count <= 0:
		return
	var state := String(enemy.get("state", ""))
	var progress := enemy_special_strike_progress(enemy) if state == "SPECIAL_RUSH" else enemy_recovery_progress(enemy)
	var frame_index := mini(int(floor(progress * float(frame_count))), frame_count - 1)
	var strike_texture: Texture2D = host.effect_renderer_component.zombie_attack_vertical_texture(facing_value, frame_index)
	if strike_texture == null:
		return
	var render_scale := enemy_render_scale(enemy)
	var screen_offset := Vector2(facing_value * 54.0, -94.0) * render_scale
	var strike_scale := Vector2(render_scale.x * 0.72, render_scale.y * 1.45)
	var rotation := -PI * 0.25 * facing_value
	var alpha := 1.0 - smoothstep(0.78, 1.0, progress)
	host.draw_set_transform(floor_position + screen_offset, rotation, strike_scale)
	host.draw_texture(strike_texture, -strike_texture.get_size() * 0.5, Color(1.0, 1.0, 1.0, alpha))


func draw_knife_attack_horizontal_fx(floor_position: Vector2, enemy: Dictionary) -> void:
	if host.effect_renderer_component == null:
		return
	var facing_value := enemy_attack_visual_facing(enemy)
	var frame_count: int = host.effect_renderer_component.knife_attack_horizontal_frame_count(facing_value)
	if frame_count <= 0:
		return
	var progress := enemy_recovery_progress(enemy)
	var frame_index := mini(int(floor(progress * float(frame_count))), frame_count - 1)
	var strike_texture: Texture2D = host.effect_renderer_component.knife_attack_horizontal_texture(facing_value, frame_index)
	if strike_texture == null:
		return
	var render_scale := enemy_render_scale(enemy)
	var offset := Vector2(facing_value * 58.0, -86.0)
	var screen_offset := Vector2(offset.x * render_scale.x, offset.y * render_scale.y)
	var strike_scale := Vector2(render_scale.x * 0.68, render_scale.y * 0.52)
	var alpha := 1.0 - smoothstep(0.76, 1.0, progress)
	host.draw_set_transform(floor_position + screen_offset, 0.0, strike_scale)
	host.draw_texture(strike_texture, -strike_texture.get_size() * 0.5, Color(1.0, 1.0, 1.0, alpha))


func enemy_attack_slash_type(enemy: Dictionary) -> String:
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	if family == host.EnemyFamily.ZOMBIE:
		return "red"
	if family == host.EnemyFamily.HUMAN:
		return "silver"
	return ""


func enemy_attack_visual_facing(enemy: Dictionary) -> float:
	var value := float(enemy.get("attack_facing", enemy.get("facing", -1.0)))
	if absf(value) < 0.1:
		value = float(enemy.get("facing", -1.0))
	if absf(value) < 0.1:
		return -1.0
	return signf(value)


func enemy_recovery_progress(enemy: Dictionary) -> float:
	var duration: float = maxf(host.balance.human_recovery_time, 0.001)
	return clampf((duration - float(enemy.get("state_time", 0.0))) / duration, 0.0, 0.999)


func enemy_special_strike_progress(enemy: Dictionary) -> float:
	var duration: float = maxf(host.balance.bone_blade_special_strike_interval, 0.001)
	return clampf((duration - float(enemy.get("special_strike_time", 0.0))) / duration, 0.0, 0.999)


func draw_enemy_texture_region(texture: Texture2D, origin: Vector2, color: Color) -> void:
	var region := enemy_texture_visible_region(texture)
	if region.size.x <= 0.0 or region.size.y <= 0.0:
		return
	var cropped_texture := enemy_cropped_texture(texture, region)
	if cropped_texture == null:
		return
	host.draw_texture(cropped_texture, origin + region.position, color)


func draw_enemy_texture_grounded(texture: Texture2D, color: Color, ground_offset: Vector2 = Vector2.ZERO) -> void:
	var region := enemy_texture_visible_region(texture)
	if region.size.x <= 0.0 or region.size.y <= 0.0:
		return
	var origin := Vector2(
		-(region.position.x + region.size.x * 0.5),
		-(region.position.y + region.size.y)
	) + ground_offset
	var cropped_texture := enemy_cropped_texture(texture, region)
	if cropped_texture == null:
		return
	host.draw_texture(cropped_texture, origin + region.position, color)


func enemy_texture_visible_region(texture: Texture2D) -> Rect2:
	var key := texture.resource_path
	if key.is_empty():
		key = str(texture.get_rid())
	if texture_visible_regions.has(key):
		return texture_visible_regions[key]
	var image := enemy_texture_source_image(texture)
	if image == null or image.is_empty():
		push_warning("Enemy texture has no readable alpha source: %s" % key)
		var empty := Rect2(Vector2.ZERO, Vector2.ZERO)
		texture_visible_regions[key] = empty
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
		texture_visible_regions[key] = empty
		return empty
	var padding := 2
	min_x = maxi(min_x - padding, 0)
	min_y = maxi(min_y - padding, 0)
	max_x = mini(max_x + padding, image.get_width() - 1)
	max_y = mini(max_y + padding, image.get_height() - 1)
	var region := Rect2(Vector2(float(min_x), float(min_y)), Vector2(float(max_x - min_x + 1), float(max_y - min_y + 1)))
	texture_visible_regions[key] = region
	return region


func enemy_texture_source_image(texture: Texture2D) -> Image:
	var key := texture.resource_path
	if key.is_empty():
		key = str(texture.get_rid())
	if source_images.has(key):
		return source_images[key] as Image
	if not texture.resource_path.is_empty() and texture.resource_path.begins_with("res://"):
		var file_path := ProjectSettings.globalize_path(texture.resource_path)
		if FileAccess.file_exists(file_path):
			var source_image := Image.load_from_file(file_path)
			if source_image != null and not source_image.is_empty():
				source_images[key] = source_image
				return source_image
	var image := texture.get_image()
	if image != null and not image.is_empty():
		source_images[key] = image
	return image


func enemy_cropped_texture(texture: Texture2D, region: Rect2) -> Texture2D:
	var key := "%s:%s:%s:%s:%s" % [
		texture.resource_path if not texture.resource_path.is_empty() else str(texture.get_rid()),
		int(region.position.x),
		int(region.position.y),
		int(region.size.x),
		int(region.size.y),
	]
	if cropped_textures.has(key):
		return cropped_textures[key]
	var source_image := enemy_texture_source_image(texture)
	if source_image == null or source_image.is_empty():
		push_warning("Enemy texture crop failed: %s" % key)
		cropped_textures[key] = null
		return null
	var region_i := Rect2i(
		Vector2i(int(region.position.x), int(region.position.y)),
		Vector2i(int(region.size.x), int(region.size.y))
	)
	var cropped_image := source_image.get_region(region_i)
	if cropped_image == null or cropped_image.is_empty():
		cropped_textures[key] = null
		return null
	var cropped_texture := ImageTexture.create_from_image(cropped_image)
	cropped_textures[key] = cropped_texture
	return cropped_texture


func draw_procedural_attack_rim(floor_position: Vector2, enemy: Dictionary, state: String) -> void:
	var progress := attack_cast_progress(enemy, state)
	var rim_color := attack_cast_color(state)
	rim_color.a = lerpf(0.52, 0.9, progress)
	var height := 78.0 if int(enemy.get("family", host.EnemyFamily.HUMAN)) != host.EnemyFamily.MUTANT_CREATURE else 94.0
	var width := 52.0 + progress * 10.0
	host.draw_set_transform(floor_position)
	host.draw_arc(Vector2(0.0, -height * 0.56), width, deg_to_rad(205.0), deg_to_rad(335.0), 24, rim_color, 4.0)
	host.draw_arc(Vector2(0.0, -height * 0.56), width * 0.72, deg_to_rad(25.0), deg_to_rad(155.0), 24, rim_color, 3.0)
	host.draw_set_transform(Vector2.ZERO)


func draw_enemy_cast_bar(floor_position: Vector2, enemy: Dictionary, state: String) -> void:
	var progress := attack_cast_progress(enemy, state)
	var position := floor_position + Vector2(-38.0, -160.0)
	var size := Vector2(76.0, 5.0)
	var fill_color := attack_cast_color(state)
	fill_color.a = 0.95
	var glow_color := fill_color
	glow_color.a = 0.28
	host.draw_rect(Rect2(position + Vector2(-1.0, -1.0), size + Vector2(2.0, 2.0)), Color(0.02, 0.01, 0.015, 0.82), true)
	host.draw_rect(Rect2(position, size), Color(0.11, 0.025, 0.035, 0.92), true)
	host.draw_rect(Rect2(position + Vector2(1.0, 1.0), Vector2((size.x - 2.0) * progress, size.y - 2.0)), fill_color, true)
	if progress > 0.78:
		host.draw_rect(Rect2(position + Vector2(-3.0, -3.0), size + Vector2(6.0, 6.0)), glow_color, false, 2.0)


func draw_procedural_knocked_down_enemy(enemy: Dictionary, color: Color) -> void:
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	var facing_value := float(enemy.get("facing", -1.0))
	draw_flat_ellipse(Vector2(0.0, -4.0), Vector2(58.0, 12.0), Color(0.0, 0.0, 0.0, 0.36))
	if family == host.EnemyFamily.MUTANT_CREATURE:
		draw_flat_ellipse(Vector2(0.0, -18.0), Vector2(54.0, 22.0), color.darkened(0.08))
		host.draw_circle(Vector2(-facing_value * 58.0, -25.0), 18.0, color)
		host.draw_line(Vector2(-36.0, -24.0), Vector2(48.0, -3.0), Color("56636f"), 10.0)
		host.draw_line(Vector2(28.0, -22.0), Vector2(-48.0, 5.0), Color("b8d3d0"), 7.0)
	else:
		draw_flat_ellipse(Vector2(0.0, -17.0), Vector2(46.0, 17.0), color)
		host.draw_circle(Vector2(-facing_value * 48.0, -36.0), 14.0, color)
		host.draw_line(Vector2(-34.0, -20.0), Vector2(36.0, -5.0), Color("e9e1cf"), 6.0)


func draw_flat_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(24):
		var angle: float = TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	host.draw_colored_polygon(points, color)


func draw_enemy_health_bar(floor_position: Vector2, enemy: Dictionary) -> void:
	if int(enemy.get("health", 0)) <= 0:
		return
	var max_health := maxi(int(enemy.get("max_health", host.balance.unit_health)), 1)
	var ratio := clampf(float(enemy.get("health", 0)) / float(max_health), 0.0, 1.0)
	var position := floor_position + Vector2(-34.0, -148.0)
	var size := Vector2(68.0, 7.0)
	host.draw_rect(Rect2(position + Vector2(-1.0, -1.0), size + Vector2(2.0, 2.0)), Color(0.02, 0.015, 0.02, 0.78), true)
	host.draw_rect(Rect2(position, size), Color(0.12, 0.035, 0.045, 0.92), true)
	var fill_color: Color = Color("dd4050") if ratio > 0.35 else Color("f1a84e")
	host.draw_rect(Rect2(position + Vector2(1.0, 1.0), Vector2((size.x - 2.0) * ratio, size.y - 2.0)), fill_color, true)
	host.draw_line(position + Vector2(0.0, size.y + 1.0), position + Vector2(size.x, size.y + 1.0), Color(0.85, 0.22, 0.25, 0.45), 1.0)


func _development_mode() -> bool:
	return host != null and bool(host.get("development_mode"))


func _warn_missing_enemy_visual(enemy: Dictionary) -> void:
	var enemy_id := String(enemy.get("id", "unknown"))
	var key := "%s:%s" % [enemy_id, String(enemy.get("state", ""))]
	if missing_visual_warnings.has(key):
		return
	missing_visual_warnings[key] = true
	push_warning("Enemy %s has no approved runtime texture for state %s. Procedural fallback is development-mode only." % [enemy_id, String(enemy.get("state", ""))])
