extends SceneTree

func _initialize() -> void:
	var paths := _discover_enemy_pngs("res://assets/sprites/enemies")
	for path in paths:
		var image := Image.new()
		var error := image.load(ProjectSettings.globalize_path(path))
		if error != OK:
			push_error("could not read source texture: %s" % path)
			quit(1)
			return
		var stats := _texture_stats(image)
		if float(stats["near_white_ratio"]) > 0.2 or float(stats["opaque_ratio"]) > 0.72:
			push_error("%s looks like a white/opaque card in Godot import. opaque=%.3f nearwhite=%.3f" % [path, float(stats["opaque_ratio"]), float(stats["near_white_ratio"])])
			quit(1)
			return
	print("PASS: enemy texture source alpha (%d files)" % paths.size())
	quit(0)


func _discover_enemy_pngs(path: String) -> Array[String]:
	var results: Array[String] = []
	var dir := DirAccess.open(path)
	if dir == null:
		return results
	dir.list_dir_begin()
	var name := dir.get_next()
	while not name.is_empty():
		if name.begins_with("."):
			name = dir.get_next()
			continue
		var child := "%s/%s" % [path, name]
		if dir.current_is_dir():
			results.append_array(_discover_enemy_pngs(child))
		elif name.ends_with(".png"):
			results.append(child)
		name = dir.get_next()
	dir.list_dir_end()
	return results


func _texture_stats(image: Image) -> Dictionary:
	var opaque := 0
	var near_white := 0
	var stride := maxi(1, ceili(sqrt(float(image.get_width() * image.get_height()) / 262144.0)))
	var total := 0
	for y in range(0, image.get_height(), stride):
		for x in range(0, image.get_width(), stride):
			total += 1
			var color := image.get_pixel(x, y)
			if color.a > 0.94:
				opaque += 1
				if color.r > 0.92 and color.g > 0.92 and color.b > 0.92:
					near_white += 1
	return {
		"opaque_ratio": float(opaque) / float(total),
		"near_white_ratio": float(near_white) / float(total),
	}
