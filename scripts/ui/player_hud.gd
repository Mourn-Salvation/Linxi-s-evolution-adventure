extends Control

const HP_FRAME: Texture2D = preload("res://assets/ui/hud/linxi_hp_frame.png")
const DODGE_ICON: Texture2D = preload("res://assets/ui/hud/dodge_ready_icon.png")
const PREY_CAPACITY_ICON: Texture2D = preload("res://assets/ui/hud/prey_capacity_icon.png")
const BIOMASS_BAR_FRAME: Texture2D = preload("res://assets/ui/hud/biomass_bar_frame.png")
const WEAPON_SLOT_FRAME: Texture2D = preload("res://assets/ui/hud/boss_health_frame.png")
const WEAPON_HANDGUN_ICON: Texture2D = preload("res://assets/props/red_night/weapons/dropped_handgun.png")
const WEAPON_KNIFE_ICON: Texture2D = preload("res://assets/props/red_night/weapons/dropped_knife.png")

var current_hp := 10
var max_hp := 10
var dodge_cooldown := 0.0
var dodge_cooldown_max := 1.0
var dodge_time := 0.0
var dodge_ready := true
var dodge_hidden := false
var occupied_capacity := 0
var max_capacity := 1
var biomass := 0.0
var max_biomass := 50.0
var temporary_weapon_equipped := false
var equipped_weapon_id := ""
var weapon_name := ""
var weapon_uses := 0
var body_weapon_name := "Claws"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)


func set_values(
	health_value: int,
	max_health_value: int,
	cooldown_value: float,
	cooldown_max_value: float,
	active_dodge_time: float,
	can_dodge: bool,
	hide_dodge: bool,
	occupied_capacity_value: int,
	max_capacity_value: int,
	biomass_value: float,
	max_biomass_value: float,
	has_temporary_weapon: bool,
	temporary_weapon_id: String,
	equipped_weapon_name: String,
	equipped_weapon_uses: int,
	current_body_weapon_name: String
) -> void:
	current_hp = clampi(health_value, 0, maxi(max_health_value, 1))
	max_hp = maxi(max_health_value, 1)
	dodge_cooldown = maxf(cooldown_value, 0.0)
	dodge_cooldown_max = maxf(cooldown_max_value, 0.001)
	dodge_time = maxf(active_dodge_time, 0.0)
	dodge_ready = can_dodge
	dodge_hidden = hide_dodge
	occupied_capacity = maxi(occupied_capacity_value, 0)
	max_capacity = maxi(max_capacity_value, 1)
	max_biomass = maxf(max_biomass_value, 1.0)
	biomass = clampf(biomass_value, 0.0, max_biomass)
	temporary_weapon_equipped = has_temporary_weapon
	equipped_weapon_id = temporary_weapon_id.to_lower()
	weapon_name = equipped_weapon_name
	weapon_uses = maxi(equipped_weapon_uses, 0)
	body_weapon_name = current_body_weapon_name
	queue_redraw()


func _draw() -> void:
	_draw_hp_bar()
	_draw_weapon_slot()
	_draw_capacity_badge()
	_draw_biomass_bar()
	_draw_dodge_icon()


func _draw_hp_bar() -> void:
	var hp_position := Vector2(24.0, 22.0)
	var hp_size := Vector2(490.0, 50.0)
	var ratio := clampf(float(current_hp) / float(max_hp), 0.0, 1.0)
	draw_texture_rect(HP_FRAME, Rect2(hp_position, hp_size), false, Color.WHITE)
	# Match the actual red channel in linxi_hp_frame.png after scaling to hp_size.
	var fill_rect := Rect2(hp_position + Vector2(37.0, 18.0), Vector2(415.0, 18.0))
	var missing_width := fill_rect.size.x * (1.0 - ratio)
	if missing_width > 0.5:
		var missing_rect := Rect2(fill_rect.position + Vector2(fill_rect.size.x - missing_width, 0.0), Vector2(missing_width, fill_rect.size.y))
		draw_rect(missing_rect, Color(0.025, 0.009, 0.012, 1.0), true)
	draw_string(ThemeDB.fallback_font, hp_position + Vector2(78.0, 42.0), "HP %d/%d" % [current_hp, max_hp], HORIZONTAL_ALIGNMENT_LEFT, 260.0, 15, Color("f2d1cf"))


func _draw_weapon_slot() -> void:
	var position := Vector2(398.0, 76.0)
	var size := Vector2(116.0, 48.0)
	draw_texture_rect(WEAPON_SLOT_FRAME, Rect2(position, size), false, Color(0.82, 0.84, 0.87, 0.96))
	var icon: Texture2D = null
	if temporary_weapon_equipped:
		icon = WEAPON_KNIFE_ICON if equipped_weapon_id == "knife" else WEAPON_HANDGUN_ICON
	if icon != null:
		draw_texture_rect(icon, Rect2(position + Vector2(9.0, 8.0), Vector2(52.0, 30.0)), false, Color.WHITE)
		draw_string(ThemeDB.fallback_font, position + Vector2(75.0, 31.0), "x%d" % weapon_uses, HORIZONTAL_ALIGNMENT_CENTER, 28.0, 14, Color("f2d1cf"))
	else:
		draw_string(ThemeDB.fallback_font, position + Vector2(45.0, 31.0), "-", HORIZONTAL_ALIGNMENT_CENTER, 26.0, 16, Color(0.52, 0.56, 0.59, 1.0))


func _draw_capacity_badge() -> void:
	var position := Vector2(24.0, 76.0)
	var icon_size := Vector2(48.0, 48.0)
	var tint := Color.WHITE if occupied_capacity < max_capacity else Color(1.0, 0.62, 0.58, 1.0)
	draw_texture_rect(PREY_CAPACITY_ICON, Rect2(position, icon_size), false, tint)
	draw_string(ThemeDB.fallback_font, position + Vector2(58.0, 31.0), "PREY %d/%d" % [occupied_capacity, max_capacity], HORIZONTAL_ALIGNMENT_LEFT, 145.0, 16, Color("f2d1cf"))


func _draw_biomass_bar() -> void:
	var position := Vector2(24.0, 125.0)
	var size := Vector2(490.0, 42.0)
	var ratio := clampf(biomass / max_biomass, 0.0, 1.0)
	draw_texture_rect(BIOMASS_BAR_FRAME, Rect2(position, size), false, Color.WHITE)
	# Match the full inner channel in biomass_bar_frame.png after scaling to size.
	var fill_rect := Rect2(position + Vector2(41.0, 15.0), Vector2(412.0, 14.0))
	var missing_width := fill_rect.size.x * (1.0 - ratio)
	if missing_width > 0.5:
		var missing_rect := Rect2(fill_rect.position + Vector2(fill_rect.size.x - missing_width, 0.0), Vector2(missing_width, fill_rect.size.y))
		draw_rect(missing_rect, Color(0.02, 0.008, 0.011, 1.0), true)
	draw_string(ThemeDB.fallback_font, position + Vector2(52.0, 39.0), "BIOMASS %.1f/%.0f" % [biomass, max_biomass], HORIZONTAL_ALIGNMENT_LEFT, 300.0, 13, Color("f2d1cf"))


func _draw_dodge_icon() -> void:
	if dodge_hidden:
		return
	var viewport_size := get_viewport_rect().size
	var size := Vector2(82.0, 82.0)
	var position := Vector2(viewport_size.x - size.x - 30.0, viewport_size.y - size.y - 28.0)
	var tint := Color.WHITE if dodge_ready else Color(0.55, 0.48, 0.52, 0.78)
	draw_texture_rect(DODGE_ICON, Rect2(position, size), false, tint)
	if not dodge_ready:
		if dodge_cooldown > 0.05:
			draw_string(ThemeDB.fallback_font, position + Vector2(24.0, 51.0), "%.1f" % dodge_cooldown, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color("e6d1d8"))
	draw_string(ThemeDB.fallback_font, position + Vector2(10.0, -7.0), "DODGE", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color("d4e8e8"))
