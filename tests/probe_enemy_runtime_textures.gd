extends SceneTree

const EnemyVisualComponentScript = preload("res://scripts/enemies/enemy_visual_component.gd")
const MainScene = preload("res://scenes/red_night.tscn")


func _initialize() -> void:
	var stage = MainScene.instantiate()
	root.add_child(stage)
	await process_frame
	var visual_component = EnemyVisualComponentScript.new()
	stage.add_child(visual_component)
	visual_component.setup(stage)
	var checked := {}
	for enemy in stage.enemies:
		var samples: Array[Texture2D] = []
		samples.append(visual_component.enemy_appearance_texture(enemy))
		samples.append(visual_component.current_enemy_hit_texture(enemy))
		samples.append(visual_component.enemy_knocked_down_texture(enemy))
		for texture in samples:
			if texture == null:
				continue
			var path := texture.resource_path
			if checked.has(path):
				continue
			checked[path] = true
			var source_image := Image.load_from_file(ProjectSettings.globalize_path(path))
			var import_image := texture.get_image()
			var source_stats := _image_stats(source_image)
			var import_stats := _image_stats(import_image)
			print("%s source=%s imported=%s" % [path, source_stats, import_stats])
	stage.queue_free()
	print("PASS: probed %d runtime enemy textures" % checked.size())
	quit(0)


func _image_stats(image: Image) -> Dictionary:
	if image == null or image.is_empty():
		return {"empty": true}
	var opaque := 0
	var near_white := 0
	var total := image.get_width() * image.get_height()
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color := image.get_pixel(x, y)
			if color.a > 0.02:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
			if color.a > 0.94:
				opaque += 1
				if color.r > 0.92 and color.g > 0.92 and color.b > 0.92:
					near_white += 1
	return {
		"size": Vector2i(image.get_width(), image.get_height()),
		"opaque": snappedf(float(opaque) / float(total), 0.001),
		"white": snappedf(float(near_white) / float(total), 0.001),
		"bbox": Rect2i(Vector2i(min_x, min_y), Vector2i(max_x - min_x + 1, max_y - min_y + 1)) if max_x >= min_x else Rect2i(),
	}
