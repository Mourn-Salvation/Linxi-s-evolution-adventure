extends Node

const MotionTrailRendererScript = preload("res://scripts/rendering/motion_trail_renderer.gd")

@export var visual_data: EffectVisualData

var host: Node2D
var atomization_fog_missing_warning_shown := false


func setup(owner: Node) -> void:
	host = owner as Node2D
	if visual_data == null:
		visual_data = load("res://resources/effects/red_night_effect_visual_data.tres") as EffectVisualData


func draw_texture_with_trail(texture: Texture2D, offset: Vector2, color: Color, direction: Vector2, strength: float = 1.0) -> void:
	if texture == null:
		return
	MotionTrailRendererScript.draw_texture_with_trail(host, texture, offset, color, direction, strength, visual_data.motion_trail_color)


func claw_slash_frame_count(slash_type: String, facing: float) -> int:
	return visual_data.claw_slash_frame_count(slash_type, facing) if visual_data != null else 0


func claw_slash_texture(slash_type: String, facing: float, frame_index: int) -> Texture2D:
	return visual_data.claw_slash_frame(slash_type, facing, frame_index) if visual_data != null else null


func zombie_attack_vertical_frame_count(facing: float) -> int:
	return visual_data.zombie_attack_vertical_frame_count(facing) if visual_data != null else 0


func zombie_attack_vertical_texture(facing: float, frame_index: int) -> Texture2D:
	return visual_data.zombie_attack_vertical_frame(facing, frame_index) if visual_data != null else null


func knife_attack_horizontal_frame_count(facing: float) -> int:
	return visual_data.knife_attack_horizontal_frame_count(facing) if visual_data != null else 0


func knife_attack_horizontal_texture(facing: float, frame_index: int) -> Texture2D:
	return visual_data.knife_attack_horizontal_frame(facing, frame_index) if visual_data != null else null


func draw_enemy_telegraph(floor_position: Vector2, facing: float, progress: float, heavy: bool) -> void:
	if visual_data == null:
		return
	var texture: Texture2D = visual_data.enemy_telegraph_frame(heavy, progress)
	if texture == null:
		return
	var alpha := smoothstep(0.0, 0.18, progress)
	var scale := Vector2(0.88, 0.48) * lerpf(0.78, 1.08, progress)
	var offset := Vector2(facing * 48.0, -18.0)
	host.draw_set_transform(floor_position + offset, 0.0, scale)
	host.draw_texture(texture, -texture.get_size() * 0.5, Color(1.0, 1.0, 1.0, alpha))
	host.draw_set_transform(Vector2.ZERO)


func draw_body_hit_effects(hit_effects: Array[Dictionary], project_actor: Callable) -> void:
	if visual_data == null:
		return
	for effect in hit_effects:
		if String(effect.get("kind", "BODY")) != "BODY":
			continue
		var ground_position := Vector2(effect["position"])
		var floor_position: Vector2 = project_actor.call(ground_position)
		var duration: float = maxf(float(effect.get("duration", 0.78)), 0.001)
		var progress := clampf((duration - float(effect.get("time", 0.0))) / duration, 0.0, 0.999)
		var frames: Array[Texture2D] = visual_data.virus_mist_hit_frames
		if frames.is_empty():
			continue
		var mist_index: int = mini(int(floor(progress * float(frames.size()))), frames.size() - 1)
		var fade := 1.0 - smoothstep(0.7, 1.0, progress)
		host.draw_set_transform(floor_position + Vector2(0.0, -54.0), 0.0, Vector2.ONE * 0.24)
		host.draw_texture(frames[mist_index], Vector2(-128.0, -128.0), Color(1.0, 1.0, 1.0, fade))
		host.draw_set_transform(Vector2.ZERO)


func draw_ground_hit_effects(hit_effects: Array[Dictionary], project_actor: Callable) -> void:
	if visual_data == null:
		return
	for effect in hit_effects:
		if String(effect.get("kind", "BODY")) != "GROUND":
			continue
		var ground_position := Vector2(effect["position"])
		var floor_position: Vector2 = project_actor.call(ground_position)
		var duration: float = maxf(float(effect.get("duration", 2.4)), 0.001)
		var progress := clampf((duration - float(effect.get("time", 0.0))) / duration, 0.0, 0.999)
		var frames: Array[Texture2D] = visual_data.virus_liquid_spread_frames
		if frames.is_empty():
			continue
		var spread_index: int = mini(int(floor(progress * float(frames.size()))), frames.size() - 1)
		var fade := 1.0 - smoothstep(0.25, 1.0, progress)
		var scale := float(effect.get("scale", 0.56))
		var angle := float(effect.get("angle", 0.0))
		host.draw_set_transform(floor_position + Vector2(0.0, -2.0), angle, Vector2(scale, scale * 0.56))
		host.draw_texture(frames[spread_index], Vector2(-128.0, -128.0), Color(1.0, 1.0, 1.0, fade * 0.78))
		host.draw_set_transform(Vector2.ZERO)


func draw_contamination_mist_field(mist_points: Array[Dictionary], post_drink_scale: float, story_overlay: String, viewport_size: Vector2, project_actor: Callable) -> void:
	if mist_points.is_empty() or story_overlay == "CHAOS_CHASE":
		return
	var time := Time.get_ticks_msec() / 1000.0
	for mist in mist_points:
		var ground_position := Vector2(mist["position"])
		var floor_position: Vector2 = project_actor.call(ground_position)
		if floor_position.x < -520.0 or floor_position.x > viewport_size.x + 520.0:
			continue
		var phase := float(mist["phase"])
		var pulse := 0.88 + sin(time * float(mist["speed"]) + phase) * 0.12
		var base_alpha := float(mist["alpha"]) * post_drink_scale
		var alpha := base_alpha * pulse
		if alpha <= 0.012:
			continue
		var radius := float(mist["radius"])
		var height := float(mist.get("height", 54.0))
		var drift := Vector2(mist["drift"]) * sin(time * 0.35 + phase)
		var screen_offset := Vector2(mist.get("screen_offset", Vector2.ZERO))
		var float_bob := Vector2(sin(time * 0.31 + phase) * 5.0, sin(time * 0.55 + phase) * 7.0)
		var center := floor_position + Vector2(0.0, -height) + screen_offset + drift + float_bob
		var dense := base_alpha > 0.115
		var texture: Texture2D = visual_data.atomization_fog_frame(dense, int(phase * 1000.0), time)
		if texture != null:
			_draw_atomization_fog_texture(texture, center, radius, phase, alpha, Vector2(float(mist["scale_x"]), float(mist["scale_y"])))
		elif not atomization_fog_missing_warning_shown:
			atomization_fog_missing_warning_shown = true
			push_warning("Atomization fog texture missing; procedural mist fallback is disabled by art direction.")


func _draw_atomization_fog_texture(texture: Texture2D, center: Vector2, radius: float, phase: float, alpha: float, shape_scale: Vector2) -> void:
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var target_width := radius * 2.42
	var target_height := radius * 1.18
	var scale := Vector2(target_width / texture_size.x, target_height / texture_size.y)
	scale.x *= lerpf(0.74, 1.08, clampf(shape_scale.x / 2.35, 0.0, 1.0))
	scale.y *= lerpf(0.72, 1.02, clampf(shape_scale.y / 1.05, 0.0, 1.0))
	var angle := sin(phase) * 0.045
	var color := Color(1.0, 1.0, 1.0, clampf(alpha * 1.55, 0.025, 0.34))
	host.draw_set_transform(center, angle, scale)
	host.draw_texture(texture, -texture_size * 0.5, color)
	host.draw_set_transform(Vector2.ZERO)


func draw_story_overlay(viewport_size: Vector2, overlay_id: String, story_pose_time: float) -> void:
	if overlay_id == "TEACHING_FIRST_FLOOR_CROWD":
		_draw_teaching_first_floor_crowd(viewport_size, story_pose_time)
		return
	if overlay_id != "CHAOS_CHASE":
		return
	var t := story_pose_time
	if t < 1.25:
		host.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.0, 0.0, 0.0, smoothstep(0.0, 1.0, t / 1.25)), true)
		return
	if t < 2.25:
		host.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color.BLACK, true)
		return
	if visual_data == null or visual_data.red_night_classroom_chase == null:
		return
	var chase_time := t - 2.25
	var fade_out := clampf((t - 6.2) / 0.8, 0.0, 1.0)
	var texture_size := visual_data.red_night_classroom_chase.get_size()
	var scale := maxf(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y) * lerpf(1.0, 1.06, clampf(chase_time / 4.0, 0.0, 1.0))
	var size := texture_size * scale
	var pan := Vector2(sin(chase_time * 1.7) * 10.0, cos(chase_time * 1.1) * 5.0)
	host.draw_texture_rect(visual_data.red_night_classroom_chase, Rect2((viewport_size - size) * 0.5 + pan, size), false, Color.WHITE)
	host.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.0, 0.0, 0.0, fade_out), true)


func _draw_teaching_first_floor_crowd(viewport_size: Vector2, story_pose_time: float) -> void:
	if visual_data == null or visual_data.teaching_first_floor_zombie_gathering == null:
		return
	var t: float = story_pose_time
	var fade_in: float = smoothstep(0.0, 0.35, t)
	var fade_out: float = 1.0 - smoothstep(3.9, 4.5, t)
	var alpha: float = minf(fade_in, fade_out)
	host.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color.BLACK, true)
	_draw_cover_texture(visual_data.teaching_first_floor_zombie_gathering, viewport_size, Color(1.0, 1.0, 1.0, alpha))
	var interference: float = 0.04 + sin(t * 32.0) * 0.015
	host.draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.75, 0.05, 0.08, maxf(interference, 0.0) * alpha), true)


func _draw_cover_texture(texture: Texture2D, viewport_size: Vector2, color: Color) -> void:
	var texture_size: Vector2 = texture.get_size()
	var scale: float = maxf(viewport_size.x / texture_size.x, viewport_size.y / texture_size.y)
	var size: Vector2 = texture_size * scale
	host.draw_texture_rect(texture, Rect2((viewport_size - size) * 0.5, size), false, color)
