class_name ItemVisualData
extends Resource

@export_group("Special Props")
@export var nebulizer_texture: Texture2D
@export var nebulizer_size := Vector2(116.0, 77.0)
@export var nebulizer_offset := Vector2(-58.0, -82.0)

@export_group("Story Props")
@export var prop_ids: Array[String] = []
@export var prop_textures: Array[Texture2D] = []
@export var prop_paths: Array[String] = []
@export var prop_sizes: Array[Vector2] = []
@export var prop_y_offsets: Array[float] = []
@export var default_prop_size := Vector2(78.0, 78.0)

var raw_prop_cache: Dictionary = {}

@export_group("Route Transition")
@export var transition_circle_frames: Array[Texture2D] = []
@export var transition_frame_ms := 110.0


func prop_texture(item_id: String) -> Texture2D:
	var index := prop_index(item_id)
	if index < 0:
		return null
	if index < prop_textures.size() and prop_textures[index] != null:
		return prop_textures[index]
	if index >= prop_paths.size():
		return null
	var path := String(prop_paths[index])
	if path.is_empty():
		return null
	if raw_prop_cache.has(path):
		return raw_prop_cache[path]
	var texture: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	if texture == null:
		var image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if image != null and not image.is_empty():
			texture = ImageTexture.create_from_image(image)
	if texture != null:
		raw_prop_cache[path] = texture
	return texture


func prop_size(item_id: String) -> Vector2:
	var index := prop_index(item_id)
	if index < 0 or index >= prop_sizes.size():
		return default_prop_size
	return prop_sizes[index]


func prop_y_offset(item_id: String) -> float:
	var index := prop_index(item_id)
	if index < 0 or index >= prop_y_offsets.size():
		return 0.0
	return prop_y_offsets[index]


func transition_frame(time_msec: int) -> Texture2D:
	if transition_circle_frames.is_empty():
		return null
	var frame_index := int(floor(float(time_msec) / maxf(transition_frame_ms, 1.0))) % transition_circle_frames.size()
	return transition_circle_frames[frame_index]


func prop_index(item_id: String) -> int:
	for index in range(prop_ids.size()):
		if prop_ids[index] == item_id:
			return index
	return -1
