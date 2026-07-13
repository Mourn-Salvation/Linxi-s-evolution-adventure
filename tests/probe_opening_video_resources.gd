extends SceneTree

func _initialize() -> void:
	var paths := [
		"res://assets/videos/opening_frames/image__00002/frame_000.jpg",
		"res://assets/videos/opening_frames/image__00001/frame_000.jpg",
		"res://assets/videos/opening_frames/image__00004/frame_000.jpg",
		"res://assets/videos/opening_frames/image__00007/frame_000.jpg",
		"res://assets/videos/opening_frames/image__00003/frame_000.jpg",
		"res://assets/sprites/linxi/opening_sequence/flash_linxi_00013.png",
		"res://assets/sprites/linxi/opening_sequence/vertical_fall_school_campus.png",
		"res://assets/sprites/linxi/opening_sequence/lying_flat_ground.png",
	]
	for path in paths:
		var exists := ResourceLoader.exists(path)
		var resource := load(path) if exists else null
		print("%s exists=%s type=%s" % [path, exists, resource.get_class() if resource != null else "<null>"])
	quit(0)
