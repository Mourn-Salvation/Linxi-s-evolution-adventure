extends Node

const LINXI_T_EARLY_AVATAR := "res://assets/ui/dialogue_portraits/linxi_t_early.png"

var host: Node
var lines: Array[String] = []
var line_index := 0
var avatar_path := ""
var pending_choice: Dictionary = {}
var pending_completion_effects: Dictionary = {}
var avatar_texture_rect: TextureRect
var avatar_box: Control

const AVATAR_DEFAULT_RIGHT := 154.0
const AVATAR_WIDE_RIGHT := 274.0
const TEXT_DEFAULT_LEFT := 178.0
const TEXT_WIDE_LEFT := 294.0

func setup(value: Node) -> void:
	host = value
	avatar_box = host.dialogue_avatar_label.get_parent() as ColorRect
	if avatar_box != null:
		avatar_box.color = Color.TRANSPARENT
	_ensure_avatar_texture_rect()

func is_active() -> bool:
	return host.dialogue_active

func start_dialogue(speaker: String, dialogue_lines: Array, speaker_avatar_path: String = "", choice: Dictionary = {}, completion_effects: Dictionary = {}) -> void:
	lines.clear()
	for line in dialogue_lines: lines.append(String(line))
	if lines.is_empty(): return
	host.dialogue_active = true
	host.dialogue_speaker = speaker
	avatar_path = speaker_avatar_path
	if avatar_path.is_empty() and speaker.strip_edges().to_lower() in ["linxi", "archive"]:
		avatar_path = LINXI_T_EARLY_AVATAR
	pending_choice = choice.duplicate(true)
	pending_completion_effects = completion_effects.duplicate(true)
	line_index = 0
	show_current_line()

func advance() -> void:
	if not host.dialogue_active: return
	line_index += 1
	if line_index >= lines.size():
		close()
		return
	show_current_line()

func close() -> void:
	host.dialogue_active = false
	host.dialogue_panel.visible = false
	if avatar_texture_rect != null:
		avatar_texture_rect.visible = false
	var choice := pending_choice.duplicate(true)
	pending_choice.clear()
	var completion_effects := pending_completion_effects.duplicate(true)
	pending_completion_effects.clear()
	host.update_hud("Conversation ended.")
	if not completion_effects.is_empty():
		host.interaction_component.apply_completion_effects(completion_effects)
	if not choice.is_empty():
		host.open_dialogue_choice(choice)

func show_current_line() -> void:
	host.dialogue_panel.visible = true
	host.dialogue_name_label.text = host.dialogue_speaker
	host.dialogue_text_label.text = lines[line_index]
	_update_avatar()
	host.dialogue_continue_label.text = "F: Continue" if line_index < lines.size() - 1 else "F: Close"


func _ensure_avatar_texture_rect() -> void:
	if host == null or host.dialogue_avatar_label == null:
		return
	var avatar_box := host.dialogue_avatar_label.get_parent() as Control
	if avatar_box == null:
		return
	var existing := avatar_box.get_node_or_null("Portrait") as TextureRect
	if existing != null:
		avatar_texture_rect = existing
		return
	avatar_texture_rect = TextureRect.new()
	avatar_texture_rect.name = "Portrait"
	avatar_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	avatar_texture_rect.offset_left = 0.0
	avatar_texture_rect.offset_top = 0.0
	avatar_texture_rect.offset_right = 0.0
	avatar_texture_rect.offset_bottom = 0.0
	avatar_texture_rect.expand_mode = 1
	avatar_texture_rect.stretch_mode = 6
	avatar_texture_rect.visible = false
	avatar_box.add_child(avatar_texture_rect)
	avatar_box.move_child(avatar_texture_rect, 0)


func _update_avatar() -> void:
	host.dialogue_avatar_label.text = host.dialogue_speaker.substr(0, 1).to_upper()
	var use_texture := false
	if avatar_texture_rect != null and not avatar_path.is_empty():
		avatar_texture_rect.texture = _load_avatar_texture(avatar_path)
		use_texture = avatar_texture_rect.texture != null
	if avatar_texture_rect != null:
		avatar_texture_rect.visible = use_texture
	host.dialogue_avatar_label.visible = not use_texture
	var wide_portrait := use_texture and avatar_texture_rect.texture.get_width() > avatar_texture_rect.texture.get_height() * 1.25
	_apply_avatar_layout(wide_portrait)


func _apply_avatar_layout(wide: bool) -> void:
	if avatar_box != null:
		avatar_box.offset_right = AVATAR_WIDE_RIGHT if wide else AVATAR_DEFAULT_RIGHT
	var text_left := TEXT_WIDE_LEFT if wide else TEXT_DEFAULT_LEFT
	host.dialogue_name_label.offset_left = text_left
	host.dialogue_text_label.offset_left = text_left


func _load_avatar_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	if path.begins_with("res://"):
		var file_path := ProjectSettings.globalize_path(path)
		if FileAccess.file_exists(file_path):
			var image := Image.load_from_file(file_path)
			if image != null and not image.is_empty():
				return ImageTexture.create_from_image(image)
	return null
