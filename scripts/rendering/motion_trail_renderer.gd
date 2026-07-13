class_name MotionTrailRenderer
extends RefCounted


static func draw_texture_with_trail(
	canvas: CanvasItem,
	texture: Texture2D,
	offset: Vector2,
	color: Color,
	direction: Vector2,
	strength: float,
	trail_color: Color
) -> void:
	if texture == null:
		return
	var trail_direction := direction
	if trail_direction.length_squared() < 0.001:
		canvas.draw_texture(texture, offset, color)
		return
	trail_direction = trail_direction.normalized()
	var clamped_strength := clampf(strength, 0.0, 1.35)
	var steps := 3
	var spacing := 10.0 + 10.0 * clamped_strength
	for index in range(steps, 0, -1):
		var ratio := float(index) / float(steps)
		var alpha := 0.055 * clamped_strength * ratio
		var current_trail_color := trail_color
		current_trail_color.a = alpha
		canvas.draw_texture(texture, offset - trail_direction * spacing * ratio, current_trail_color)
	canvas.draw_texture(texture, offset, color)
