extends SceneTree

const GameSessionData = preload("res://scripts/data/game_session.gd")

var failures := 0

func _initialize() -> void:
	GameSessionData.force_opening_once = true
	var packed: PackedScene = load("res://scenes/opening_intro.tscn")
	var intro = packed.instantiate()
	root.add_child(intro)
	await process_frame
	expect(intro.phase == intro.Phase.TITLE_LOOP, "opening loops first clip at title")
	expect(not intro.cinematic_started, "opening does not move before input")
	expect(ResourceLoader.exists(intro.RED_NIGHT_SCENE), "Red Night transition target exists")
	expect(intro.clip_frame_count("image__00002") == 73, "title loop frame contract is available")
	expect(intro.clip_frame_count("image__00003") == 75, "final clip frame contract is available")
	expect(intro.clip_frame_texture("image__00002", 1) != null, "title loop first frame is available")
	expect(intro.clip_frame_texture("image__00002", 73) != null, "title loop final frame is available")
	expect(intro.clip_frame_texture("image__00003", 1) != null, "final clip first frame is available")
	expect(intro.clip_frame_texture("image__00003", 75) != null, "final clip final frame is available")
	expect(intro.flash_still != null and intro.fall_still != null and intro.lying_still != null, "opening stills are available")
	intro.title_ready = true
	intro.begin_cinematic()
	expect(intro.phase == intro.Phase.CLIP_00001, "keypress begins the second clip")
	intro.set_phase(intro.Phase.FLASH_STILL)
	expect(intro.phase == intro.Phase.FLASH_STILL, "0.1 second Linxi still and interference beat exists")
	expect(intro.signal_interference.is_active(), "Linxi still triggers signal interference")
	intro.set_phase(intro.Phase.FALL_STILL)
	expect(intro.phase == intro.Phase.FALL_STILL, "school campus fall still exists")
	intro.set_phase(intro.Phase.LYING_STILL)
	expect(intro.phase == intro.Phase.LYING_STILL, "lying flat final still exists")
	expect(intro.get_node_or_null("HUD/PixelFilter") == null, "opening does not use a self-drawn pixel filter overlay")
	intro.set_phase(intro.Phase.TRANSITION)
	expect(not intro.location.visible, "transition keeps lab label hidden")
	# Let the opening's startup timers and short interference playback finish so
	# the headless test does not exit with live audio/timer references.
	await create_timer(1.5).timeout
	intro.clip_frame_cache.clear()
	intro.rain_ambience.stop()
	intro.rain_ambience.stream = null
	intro.signal_interference_sfx.stop()
	intro.signal_interference_sfx.stream = null
	intro.flash_still = null
	intro.fall_still = null
	intro.lying_still = null
	intro.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: opening cinematic tests")
		quit(0)
	else:
		push_error("FAIL: %d opening cinematic test(s)" % failures)
		quit(1)

func expect(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)
