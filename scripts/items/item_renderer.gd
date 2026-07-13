extends Node

@export var fallback_visual_data: ItemVisualData

var host: Node2D


func setup(owner: Node) -> void:
	host = owner as Node2D
	if fallback_visual_data == null:
		fallback_visual_data = load("res://resources/items/red_night_item_visual_data.tres") as ItemVisualData


func draw_item(floor_position: Vector2, item: Dictionary, player_ground: Vector2, story_pose: String, visual_data: ItemVisualData = null) -> void:
	if bool(item.get("render_hidden", false)):
		return
	if bool(item.get("hide_when_locked", false)) and is_instance_valid(host.interaction_component) and not host.interaction_component.is_item_unlocked(item):
		return
	var data: ItemVisualData = visual_data if visual_data != null else fallback_visual_data
	var nearby := absf(Vector2(item["position"]).x - player_ground.x) <= 105.0 and absf(Vector2(item["position"]).y - player_ground.y) <= 62.0
	var item_type := String(item.get("type", "dialogue"))
	if item_type == "dialogue":
		host.draw_set_transform(floor_position)
		_draw_prop(String(item.get("id", "")), data)
		host.draw_set_transform(Vector2.ZERO)
		_draw_dialogue_prompt(floor_position, item, nearby)
		return
	if item_type == "transition":
		if not bool(item.get("background_prop", false)):
			host.draw_set_transform(floor_position + item_visual_offset(item))
			_draw_prop(String(item.get("prop_id", item.get("id", ""))), data)
			host.draw_set_transform(Vector2.ZERO)
		_draw_transition_item(floor_position, item, nearby, data)
		return
	if String(item.get("id", "")) == "chopper_nebulizer" and story_pose == "DRINK_BLUE":
		return
	host.draw_set_transform(floor_position)
	if String(item.get("id", "")) == "chopper_nebulizer":
		_draw_nebulizer(floor_position, item, data)
	elif _draw_prop(String(item.get("prop_id", item.get("id", ""))), data):
		pass
	if nearby:
		host.draw_circle(Vector2(0.0, -84.0), 15.0, Color("f4cf61"))
		host.draw_string(ThemeDB.fallback_font, Vector2(-5.0, -78.0), "F", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color("172033"))
	host.draw_set_transform(Vector2.ZERO)


func item_visual_offset(item: Dictionary) -> Vector2:
	var offset = item.get("visual_offset", Vector2.ZERO)
	if offset is Vector2:
		return Vector2(offset)
	return Vector2.ZERO


func _draw_dialogue_prompt(floor_position: Vector2, item: Dictionary, nearby: bool) -> void:
	var unlocked := true
	if is_instance_valid(host.interaction_component):
		unlocked = host.interaction_component.is_item_unlocked(item)
	if not unlocked:
		return
	if not nearby and not bool(item.get("always_show_prompt", false)):
		return
	host.draw_set_transform(floor_position)
	var pulse := 0.75 + sin(Time.get_ticks_msec() * 0.006) * 0.12
	var prompt_position := Vector2(0.0, -112.0)
	host.draw_circle(prompt_position, 14.0, Color(0.05, 0.08, 0.10, 0.78))
	host.draw_arc(prompt_position, 16.0, 0.0, TAU, 28, Color(0.78, 0.08, 0.13, pulse), 2.0)
	host.draw_string(ThemeDB.fallback_font, prompt_position + Vector2(-5.0, 6.0), "F", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color("f7e8e8"))
	host.draw_set_transform(Vector2.ZERO)


func _draw_transition_item(floor_position: Vector2, item: Dictionary, nearby: bool, data: ItemVisualData) -> void:
	var texture := data.transition_frame(Time.get_ticks_msec()) if data != null else null
	if texture != null and bool(item.get("show_transition_circle", true)):
		var size := texture.get_size()
		host.draw_texture_rect(texture, Rect2(floor_position - size * 0.5, size), false, Color.WHITE)
	if nearby:
		host.draw_string(ThemeDB.fallback_font, floor_position + Vector2(-32.0, -66.0), "F", HORIZONTAL_ALIGNMENT_CENTER, 64.0, 20, Color("f7e8e8"))


func _draw_nebulizer(floor_position: Vector2, item: Dictionary, data: ItemVisualData) -> void:
	var emptied := bool(item.get("emptied", false))
	var texture := data.nebulizer_texture if data != null else null
	var rect := Rect2(data.nebulizer_offset if data != null else Vector2(-58.0, -82.0), data.nebulizer_size if data != null else Vector2(116.0, 77.0))
	if texture != null:
		host.draw_texture_rect(texture, rect, false, Color("9aa0a4") if emptied else Color.WHITE)


func _draw_prop(item_id: String, data: ItemVisualData) -> bool:
	if data == null:
		return false
	var texture := data.prop_texture(item_id)
	if texture == null:
		return false
	var size := data.prop_size(item_id)
	var y_offset := data.prop_y_offset(item_id)
	var rect := Rect2(Vector2(-size.x * 0.5, -size.y + y_offset), size)
	host.draw_texture_rect(texture, rect, false, Color.WHITE)
	return true
