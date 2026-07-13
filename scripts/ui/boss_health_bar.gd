class_name BossHealthBar
extends Control

@export var frame_texture: Texture2D
@export var default_approach_range := 520.0
@export var bar_screen_width_ratio := 0.80
@export var health_channel_height := 8.0
@export var frame_height := 20.0

var host: Node
var engaged_boss_id := ""
var displayed_health := 0.0
var displayed_max_health := 1.0
var damage_trail_health := 0.0
var boss_name := ""


func _ready() -> void:
	host = get_parent().get_parent()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_process(true)


func _process(delta: float) -> void:
	if not is_instance_valid(host):
		visible = false
		return
	var boss := _current_or_nearby_boss()
	if boss.is_empty():
		visible = false
		engaged_boss_id = ""
		return
	var current_health := maxf(float(boss.get("health", 0)), 0.0)
	var maximum_health := maxf(float(boss.get("max_health", 1)), 1.0)
	if String(boss.get("id", "")) != engaged_boss_id:
		engaged_boss_id = String(boss.get("id", ""))
		displayed_health = current_health
		damage_trail_health = current_health
	displayed_health = current_health
	displayed_max_health = maximum_health
	damage_trail_health = move_toward(damage_trail_health, current_health, maximum_health * delta * 0.22)
	boss_name = String(boss.get("boss_name", boss.get("display_name", boss.get("id", "BOSS")))).to_upper()
	visible = current_health > 0.0 and String(boss.get("state", "")) not in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED"]
	queue_redraw()


func _current_or_nearby_boss() -> Dictionary:
	var nearest: Dictionary = {}
	var nearest_distance := INF
	for enemy_value in host.enemies:
		var enemy: Dictionary = enemy_value
		if not bool(enemy.get("boss", false)):
			continue
		if not bool(enemy.get("boss_engaged", false)):
			continue
		if int(enemy.get("health", 0)) <= 0:
			continue
		if String(enemy.get("state", "")) in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED"]:
			continue
		if String(enemy.get("id", "")) == engaged_boss_id:
			return enemy
		var distance := Vector2(enemy.get("position", Vector2.ZERO)).distance_to(Vector2(host.player_ground))
		var trigger_range := maxf(float(enemy.get("boss_approach_range", default_approach_range)), 1.0)
		if distance <= trigger_range and distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest


func _draw() -> void:
	if not visible or frame_texture == null:
		return
	var viewport_size := get_viewport_rect().size
	var bar_width := viewport_size.x * clampf(bar_screen_width_ratio, 0.1, 1.0)
	var bar_height := frame_height
	var frame_rect := Rect2(
		(viewport_size.x - bar_width) * 0.5,
		viewport_size.y - bar_height - 24.0,
		bar_width,
		bar_height
	)
	draw_texture_rect(frame_texture, frame_rect, false)
	var fill_rect := Rect2(
		frame_rect.position + Vector2(frame_rect.size.x * 0.058, (frame_rect.size.y - health_channel_height) * 0.5),
		Vector2(frame_rect.size.x * 0.884, health_channel_height)
	)
	var trail_ratio := clampf(damage_trail_health / displayed_max_health, 0.0, 1.0)
	var health_ratio := clampf(displayed_health / displayed_max_health, 0.0, 1.0)
	draw_rect(Rect2(fill_rect.position, Vector2(fill_rect.size.x * trail_ratio, fill_rect.size.y)), Color(0.72, 0.35, 0.12, 0.92), true)
	draw_rect(Rect2(fill_rect.position, Vector2(fill_rect.size.x * health_ratio, fill_rect.size.y)), Color(0.58, 0.015, 0.025, 1.0), true)
	draw_line(fill_rect.position + Vector2(2.0, 2.0), fill_rect.position + Vector2(fill_rect.size.x * health_ratio - 2.0, 2.0), Color(1.0, 0.22, 0.18, 0.82), 2.0)
	var font := ThemeDB.fallback_font
	var font_size := 22
	var name_width := font.get_string_size(boss_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2(viewport_size.x * 0.5 - name_width * 0.5, frame_rect.position.y - 8.0), boss_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.9, 0.86, 0.79, 1.0))
