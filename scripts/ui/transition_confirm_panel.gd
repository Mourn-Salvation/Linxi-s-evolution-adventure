extends Control

signal accepted
signal cancelled
signal hovered

const PANEL_FRAME: Texture2D = preload("res://assets/ui/navigation/transition_hud/route_confirm_panel.png")
const BUTTON_CONFIRM: Texture2D = preload("res://assets/ui/navigation/transition_hud/button_confirm.png")
const BUTTON_CANCEL: Texture2D = preload("res://assets/ui/navigation/transition_hud/button_cancel.png")
const NODE_CURRENT: Texture2D = preload("res://assets/ui/navigation/transition_hud/node_current.png")
const NODE_AVAILABLE: Texture2D = preload("res://assets/ui/navigation/transition_hud/node_available.png")
const ROUTE_CONNECTOR: Texture2D = preload("res://assets/ui/navigation/transition_hud/route_connector.png")

const ROUTE_PANEL_MIN_WIDTH := 468.0
const PROMPT_PANEL_MIN_WIDTH := 360.0
const PANEL_MAX_WIDTH := 680.0
const PANEL_MIN_HEIGHT := 184.0
const PANEL_SCREEN_MARGIN := 64.0
const ROUTE_TEXT_LEFT := 228.0
const CONTENT_MARGIN := 36.0
const TITLE_TOP := 22.0
const BODY_GAP := 14.0
const BUTTON_HEIGHT := 40.0
const BUTTON_WIDTH := 116.0
const BUTTON_BOTTOM_MARGIN := 20.0

var destination_name := ""
var custom_prompt := false

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/Title
@onready var body_label: Label = $Panel/Body
@onready var yes_button: Button = $Panel/YesButton
@onready var no_button: Button = $Panel/NoButton


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var empty_style := StyleBoxEmpty.new()
	panel.add_theme_stylebox_override("panel", empty_style)
	for button in [yes_button, no_button]:
		button.flat = true
		button.add_theme_stylebox_override("normal", empty_style)
		button.add_theme_stylebox_override("hover", empty_style)
		button.add_theme_stylebox_override("pressed", empty_style)
		button.add_theme_stylebox_override("focus", empty_style)
		button.add_theme_color_override("font_color", Color("f3e5dc"))
		button.add_theme_color_override("font_hover_color", Color("ffffff"))
		button.add_theme_color_override("font_pressed_color", Color("ffcec7"))
		button.add_theme_font_size_override("font_size", 15)
		button.mouse_entered.connect(func() -> void: hovered.emit())
	yes_button.pressed.connect(func() -> void: accepted.emit())
	no_button.pressed.connect(func() -> void: cancelled.emit())
	for label in [title_label, body_label]:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.clip_text = false


func open(destination: String) -> void:
	custom_prompt = false
	destination_name = destination
	title_label.text = "ROUTE CONFIRMATION"
	body_label.text = "move to \"%s\"" % destination_name
	yes_button.text = "YES"
	no_button.text = "NO"
	visible = true
	_layout_panel()
	call_deferred("_layout_panel")
	yes_button.grab_focus()
	queue_redraw()


func open_prompt(title: String, body: String, yes_text: String = "YES", no_text: String = "NO") -> void:
	custom_prompt = true
	title_label.text = title
	body_label.text = body
	yes_button.text = yes_text
	no_button.text = no_text
	visible = true
	_layout_panel()
	call_deferred("_layout_panel")
	yes_button.grab_focus()
	queue_redraw()


func close() -> void:
	visible = false


func is_open() -> bool:
	return visible


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and visible:
		_layout_panel()


func _layout_panel() -> void:
	var viewport_size := get_viewport_rect().size
	var text_left := CONTENT_MARGIN if custom_prompt else ROUTE_TEXT_LEFT
	var minimum_panel_width := PROMPT_PANEL_MIN_WIDTH if custom_prompt else ROUTE_PANEL_MIN_WIDTH
	var maximum_panel_width := maxf(minimum_panel_width, viewport_size.x - PANEL_SCREEN_MARGIN * 2.0)
	maximum_panel_width = minf(maximum_panel_width, PANEL_MAX_WIDTH if custom_prompt else 620.0)
	var desired_text_width := maxf(_unwrapped_label_width(title_label), _unwrapped_label_width(body_label)) + 4.0
	var minimum_text_width := 240.0 if custom_prompt else 180.0
	var panel_width := clampf(text_left + maxf(desired_text_width, minimum_text_width) + CONTENT_MARGIN, minimum_panel_width, maximum_panel_width)
	var text_width := maxf(panel_width - text_left - CONTENT_MARGIN, minimum_text_width)

	panel.size = Vector2(panel_width, PANEL_MIN_HEIGHT)
	title_label.position = Vector2(text_left, TITLE_TOP)
	title_label.size = Vector2(text_width, 1.0)
	var title_height := _wrapped_label_height(title_label)
	title_label.size = Vector2(text_width, title_height)

	body_label.position = Vector2(text_left, TITLE_TOP + title_height + BODY_GAP)
	body_label.size = Vector2(text_width, 1.0)
	var body_height := _wrapped_label_height(body_label)
	body_label.size = Vector2(text_width, body_height)

	var button_top := body_label.position.y + body_height + 18.0
	var panel_height := maxf(PANEL_MIN_HEIGHT, button_top + BUTTON_HEIGHT + BUTTON_BOTTOM_MARGIN)
	panel.size = Vector2(panel_width, panel_height)
	panel.position = (viewport_size - panel.size) * 0.5

	var button_gap := 16.0
	var buttons_width := BUTTON_WIDTH * 2.0 + button_gap
	var button_left := (panel_width - buttons_width) * 0.5
	yes_button.position = Vector2(button_left, button_top)
	yes_button.size = Vector2(BUTTON_WIDTH, BUTTON_HEIGHT)
	no_button.position = Vector2(button_left + BUTTON_WIDTH + button_gap, button_top)
	no_button.size = Vector2(BUTTON_WIDTH, BUTTON_HEIGHT)


func _wrapped_label_height(label: Label) -> float:
	var line_count := maxi(label.get_line_count(), 1)
	return float(line_count * label.get_line_height()) + 4.0


func _unwrapped_label_width(label: Label) -> float:
	var font: Font = label.get_theme_font("font")
	if font == null:
		font = ThemeDB.fallback_font
	var font_size := label.get_theme_font_size("font_size")
	var widest_line := 0.0
	for line in label.text.split("\n"):
		widest_line = maxf(widest_line, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x)
	return widest_line


func _draw() -> void:
	if not visible:
		return
	var panel_rect := Rect2(panel.position, panel.size)
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.02, 0.0, 0.01, 0.38), true)
	draw_texture_rect(PANEL_FRAME, panel_rect.grow(22.0), false, Color.WHITE)
	if not custom_prompt:
		var left_node := Rect2(panel_rect.position + Vector2(40.0, 62.0), Vector2(44.0, 44.0))
		var connector := Rect2(panel_rect.position + Vector2(78.0, 76.0), Vector2(112.0, 22.0))
		var right_node := Rect2(panel_rect.position + Vector2(184.0, 62.0), Vector2(44.0, 44.0))
		draw_texture_rect(NODE_CURRENT, left_node, false, Color.WHITE)
		draw_texture_rect(ROUTE_CONNECTOR, connector, false, Color.WHITE)
		draw_texture_rect(NODE_AVAILABLE, right_node, false, Color.WHITE)
	draw_texture_rect(BUTTON_CONFIRM, Rect2(panel.position + yes_button.position - Vector2(7.0, 6.0), yes_button.size + Vector2(14.0, 12.0)), false, Color.WHITE)
	draw_texture_rect(BUTTON_CANCEL, Rect2(panel.position + no_button.position - Vector2(7.0, 6.0), no_button.size + Vector2(14.0, 12.0)), false, Color.WHITE)
