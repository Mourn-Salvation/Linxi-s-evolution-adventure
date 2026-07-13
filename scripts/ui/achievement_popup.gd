extends Control

const ACHIEVEMENT_PANEL: Texture2D = preload("res://assets/ui/hud/achievement_panel.png")

var achievement_title := ""
var achievement_time := 0.0
var achievement_duration := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)


func _process(delta: float) -> void:
	if achievement_time <= 0.0:
		return
	achievement_time = maxf(achievement_time - delta, 0.0)
	queue_redraw()


func show_achievement(title: String, duration: float = 4.0) -> void:
	achievement_title = title
	achievement_duration = maxf(duration, 0.1)
	achievement_time = achievement_duration
	queue_redraw()


func is_showing() -> bool:
	return achievement_time > 0.0 and not achievement_title.is_empty()


func _draw() -> void:
	if not is_showing():
		return
	var viewport_size := get_viewport_rect().size
	var size := Vector2(430.0, 116.0)
	var margin := Vector2(18.0, 18.0)
	var progress := clampf((achievement_duration - achievement_time) / maxf(achievement_duration, 0.001), 0.0, 1.0)
	var slide_in := smoothstep(0.0, 0.16, progress)
	var fade_out := 1.0 - smoothstep(0.82, 1.0, progress)
	var alpha := clampf(slide_in * fade_out, 0.0, 1.0)
	var hidden_x := viewport_size.x + 20.0
	var visible_x := viewport_size.x - size.x - margin.x
	var position := Vector2(lerpf(hidden_x, visible_x, slide_in), viewport_size.y - size.y - margin.y)
	var rect := Rect2(position, size)
	draw_texture_rect(ACHIEVEMENT_PANEL, rect, false, Color(1.0, 1.0, 1.0, alpha))
	var title_position := position + Vector2(125.0, 50.0)
	draw_string(ThemeDB.fallback_font, title_position + Vector2(2.0, 2.0), "ACHIEVEMENT UNLOCKED", HORIZONTAL_ALIGNMENT_LEFT, 260.0, 13, Color(0.02, 0.0, 0.0, alpha * 0.8))
	draw_string(ThemeDB.fallback_font, title_position, "ACHIEVEMENT UNLOCKED", HORIZONTAL_ALIGNMENT_LEFT, 260.0, 13, Color(0.95, 0.2, 0.18, alpha))
	draw_string(ThemeDB.fallback_font, title_position + Vector2(0.0, 25.0), achievement_title, HORIZONTAL_ALIGNMENT_LEFT, 270.0, 18, Color(0.96, 0.88, 0.82, alpha))
