extends Node

const VORE_SWALLOW_DIR := "res://assets/audio/sfx/vore/swallow"
const VORE_BURP_DIR := "res://assets/audio/sfx/vore/burp"
const VORE_BELLY_STRUGGLE_DIR := "res://assets/audio/sfx/vore/belly_struggle"
const PREY_SCREAM_HUMAN_DIR := "res://assets/audio/sfx/vore/prey_scream_human"
const PREY_SCREAM_MONSTER_DIR := "res://assets/audio/sfx/vore/prey_scream_monster"
const DIGESTION_START_DIR := "res://assets/audio/sfx/vore/digestion_start"
const DIGESTION_LOOP_DIR := "res://assets/audio/sfx/vore/digestion_loop"
const DIGESTION_FINISH_DIR := "res://assets/audio/sfx/vore/digestion_finish"
const UI_DIR := "res://assets/audio/sfx/ui"
const PLAYER_DIR := "res://assets/audio/sfx/player"
const COMBAT_DIR := "res://assets/audio/sfx/combat"
const ENEMY_DIR := "res://assets/audio/sfx/enemy"
const RED_NIGHT_DIR := "res://assets/audio/sfx/red_night"
const ONE_SHOT_POOL_SIZE := 6

var host: Node
var streams_by_event: Dictionary = {}
var vore_swallow_streams: Array[AudioStream] = []
var vore_burp_streams: Array[AudioStream] = []
var belly_struggle_streams: Array[AudioStream] = []
var prey_scream_human_streams: Array[AudioStream] = []
var prey_scream_monster_streams: Array[AudioStream] = []
var digestion_start_streams: Array[AudioStream] = []
var digestion_loop_streams: Array[AudioStream] = []
var digestion_finish_streams: Array[AudioStream] = []
var one_shot_players: Array[AudioStreamPlayer] = []
var belly_struggle_player: AudioStreamPlayer
var digestion_loop_player: AudioStreamPlayer
var nebulizer_hum_player: AudioStreamPlayer
var one_shot_index := 0
var belly_struggle_gap_time := 0.0
var zombie_groan_gap_time := 0.0
var was_digesting := false


func setup(value: Node) -> void:
	host = value
	_build_one_shot_pool()
	_build_belly_struggle_player()
	_build_loop_players()
	vore_swallow_streams = _load_streams_from_directory(VORE_SWALLOW_DIR)
	vore_burp_streams = _load_streams_from_directory(VORE_BURP_DIR)
	belly_struggle_streams = _load_streams_from_directory(VORE_BELLY_STRUGGLE_DIR)
	prey_scream_human_streams = _load_streams_from_directory(PREY_SCREAM_HUMAN_DIR)
	prey_scream_monster_streams = _load_streams_from_directory(PREY_SCREAM_MONSTER_DIR)
	digestion_start_streams = _load_streams_from_directory(DIGESTION_START_DIR)
	digestion_loop_streams = _load_streams_from_directory(DIGESTION_LOOP_DIR)
	digestion_finish_streams = _load_streams_from_directory(DIGESTION_FINISH_DIR)
	_load_named_events()


func _process(delta: float) -> void:
	_update_digest_audio()
	_update_belly_struggle(delta)
	_update_nebulizer_hum()
	_update_zombie_groans(delta)


func play_event(event_name: String, volume_db := -3.0) -> void:
	var streams: Array[AudioStream] = streams_by_event.get(event_name, [])
	_play_random(streams, volume_db)


func play_ui_hover() -> void:
	play_event("ui_hover", -8.0)


func play_ui_confirm() -> void:
	play_event("ui_confirm", -5.0)


func play_ui_cancel() -> void:
	play_event("ui_cancel", -5.0)


func play_achievement_pop() -> void:
	play_event("achievement_pop", -4.0)


func play_footstep(surface: String = "") -> void:
	var resolved_surface := String(surface).strip_edges().to_lower()
	if resolved_surface.is_empty():
		resolved_surface = _current_footstep_surface()
	var event_name := "footstep_%s" % resolved_surface
	var volume_db := _footstep_volume_for_surface(resolved_surface)
	play_event(event_name, volume_db)


func play_dodge() -> void:
	play_event("dodge_whoosh", -5.0)


func play_jump() -> void:
	play_event("jump", -8.0)


func play_player_hurt() -> void:
	play_event("hurt", -5.0)


func play_claw_swing() -> void:
	play_event("linxi_claw_swing", -6.0)


func play_claw_hit() -> void:
	play_event("linxi_claw_hit_flesh", -4.0)


func play_enemy_hurt() -> void:
	play_event("enemy_hurt_flesh", -5.0)


func play_enemy_knockdown() -> void:
	play_event("enemy_knockdown_bodyfall", -4.0)


func play_blue_vial_drink() -> void:
	play_event("blue_vial_drink", -4.0)


func play_signal_interference() -> void:
	play_event("signal_interference_burst", -3.0)


func play_map_transition_pulse() -> void:
	play_event("map_transition_pulse", -6.0)


func play_vore_swallow() -> void:
	_play_random(vore_swallow_streams)


func play_vore_burp() -> void:
	_play_random(vore_burp_streams)


func play_digest_finish() -> void:
	_play_random(digestion_finish_streams, -5.0)


func play_human_prey_scream() -> void:
	_play_random(prey_scream_human_streams, -2.0)


func play_monster_prey_scream() -> void:
	_play_random(prey_scream_monster_streams, -2.0)


func _build_one_shot_pool() -> void:
	if not one_shot_players.is_empty():
		return
	for _index in range(ONE_SHOT_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		one_shot_players.append(player)


func _build_belly_struggle_player() -> void:
	if belly_struggle_player != null:
		return
	belly_struggle_player = AudioStreamPlayer.new()
	belly_struggle_player.bus = "Master"
	add_child(belly_struggle_player)


func _build_loop_players() -> void:
	if digestion_loop_player != null:
		return
	digestion_loop_player = AudioStreamPlayer.new()
	digestion_loop_player.bus = "Master"
	add_child(digestion_loop_player)
	nebulizer_hum_player = AudioStreamPlayer.new()
	nebulizer_hum_player.bus = "Master"
	add_child(nebulizer_hum_player)


func _play_random(streams: Array[AudioStream], volume_db := -3.0) -> void:
	if streams.is_empty() or one_shot_players.is_empty():
		return
	var player := one_shot_players[one_shot_index % one_shot_players.size()]
	one_shot_index += 1
	player.stop()
	player.stream = streams[randi() % streams.size()]
	player.pitch_scale = randf_range(0.985, 1.015)
	player.volume_db = volume_db
	player.play()


func _update_digest_audio() -> void:
	var currently_digesting := host != null and bool(host.digesting)
	if currently_digesting and not was_digesting:
		_play_random(digestion_start_streams, -5.0)
	if not currently_digesting:
		if digestion_loop_player != null and digestion_loop_player.playing:
			digestion_loop_player.stop()
		was_digesting = false
		return
	was_digesting = true
	if digestion_loop_streams.is_empty() or digestion_loop_player == null or digestion_loop_player.playing:
		return
	digestion_loop_player.stream = digestion_loop_streams[randi() % digestion_loop_streams.size()]
	_enable_audio_loop(digestion_loop_player.stream)
	digestion_loop_player.pitch_scale = randf_range(0.97, 1.03)
	digestion_loop_player.volume_db = -13.0
	digestion_loop_player.play()


func _update_belly_struggle(delta: float) -> void:
	if host == null or belly_struggle_player == null:
		return
	var has_belly_prey := int(host.occupied_vore_capacity) > 0 and bool(host.enemy_contained)
	if not has_belly_prey:
		belly_struggle_gap_time = 0.0
		if belly_struggle_player.playing:
			belly_struggle_player.stop()
		return
	if belly_struggle_streams.is_empty() or belly_struggle_player.playing:
		return
	belly_struggle_gap_time -= delta
	if belly_struggle_gap_time > 0.0:
		return
	belly_struggle_player.stream = belly_struggle_streams[randi() % belly_struggle_streams.size()]
	belly_struggle_player.pitch_scale = randf_range(0.985, 1.01)
	belly_struggle_player.volume_db = -9.0
	belly_struggle_player.play()
	belly_struggle_gap_time = randf_range(2.0, 5.0)


func _update_nebulizer_hum() -> void:
	if nebulizer_hum_player == null:
		return
	var should_hum := _has_active_nebulizer()
	if not should_hum:
		if nebulizer_hum_player.playing:
			nebulizer_hum_player.stop()
		return
	var streams: Array[AudioStream] = streams_by_event.get("nebulizer_idle_hum", [])
	if streams.is_empty() or nebulizer_hum_player.playing:
		return
	nebulizer_hum_player.stream = streams[0]
	_enable_audio_loop(nebulizer_hum_player.stream)
	nebulizer_hum_player.volume_db = -18.0
	nebulizer_hum_player.pitch_scale = randf_range(0.98, 1.02)
	nebulizer_hum_player.play()


func _enable_audio_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD


func _has_active_nebulizer() -> bool:
	if host == null:
		return false
	for item in host.scene_items:
		if String(item.get("id", "")) == "chopper_nebulizer":
			return bool(item.get("active", true)) and not bool(item.get("emptied", false))
	return false


func _update_zombie_groans(delta: float) -> void:
	if host == null:
		return
	zombie_groan_gap_time -= delta
	if zombie_groan_gap_time > 0.0:
		return
	for enemy in host.enemies:
		var state := String(enemy.get("state", ""))
		if int(enemy.get("family", -1)) == host.EnemyFamily.ZOMBIE and not (state in ["DIGESTED", "CONTAINED", "DORMANT", "ESCAPED", "KNOCKED_DOWN"]):
			play_event("enemy_zombie_groan", -12.0)
			zombie_groan_gap_time = randf_range(4.0, 8.0)
			return
	zombie_groan_gap_time = 2.0


func _load_named_events() -> void:
	_add_named_event("ui_hover", UI_DIR, "ui_hover")
	_add_named_event("ui_confirm", UI_DIR, "ui_confirm")
	_add_named_event("ui_cancel", UI_DIR, "ui_cancel")
	_add_named_event("achievement_pop", UI_DIR, "achievement_pop")
	_add_named_event("footstep_wet", PLAYER_DIR, "footstep_wet")
	_add_named_event("footstep_concrete", PLAYER_DIR, "footstep_concrete")
	_add_named_event("footstep_marble", PLAYER_DIR, "footstep_marble")
	_add_named_event("footstep_grass", PLAYER_DIR, "footstep_grass")
	_add_named_event("dodge_whoosh", PLAYER_DIR, "dodge_whoosh")
	_add_named_event("jump", PLAYER_DIR, "jump")
	_add_named_event("hurt", PLAYER_DIR, "hurt")
	_add_named_event("linxi_claw_swing", COMBAT_DIR, "linxi_claw_swing")
	_add_named_event("linxi_claw_hit_flesh", COMBAT_DIR, "linxi_claw_hit_flesh")
	_add_named_event("enemy_zombie_groan", ENEMY_DIR, "enemy_zombie_groan")
	_add_named_event("enemy_hurt_flesh", ENEMY_DIR, "enemy_hurt_flesh")
	_add_named_event("enemy_knockdown_bodyfall", ENEMY_DIR, "enemy_knockdown_bodyfall")
	_add_named_event("nebulizer_idle_hum", RED_NIGHT_DIR, "nebulizer_idle_hum")
	_add_named_event("blue_vial_drink", RED_NIGHT_DIR, "blue_vial_drink")
	_add_named_event("signal_interference_burst", RED_NIGHT_DIR, "signal_interference_burst")
	_add_named_event("map_transition_pulse", RED_NIGHT_DIR, "map_transition_pulse")


func _current_footstep_surface() -> String:
	if host != null and host.map_data != null:
		var surface := String(host.map_data.footstep_surface).strip_edges().to_lower()
		if _valid_footstep_surface(surface):
			return surface
	return "concrete"


func _valid_footstep_surface(surface: String) -> bool:
	return surface in ["wet", "concrete", "marble", "grass"]


func _footstep_volume_for_surface(surface: String) -> float:
	match surface:
		"marble":
			return -10.0
		"grass":
			return -13.0
		"wet":
			return -11.0
		_:
			return -12.0


func _add_named_event(event_name: String, directory_path: String, prefix: String) -> void:
	var streams: Array[AudioStream] = []
	for stream in _load_streams_from_directory(directory_path, prefix):
		streams.append(stream)
	streams_by_event[event_name] = streams


func _load_streams_from_directory(directory_path: String, prefix := "") -> Array[AudioStream]:
	var streams: Array[AudioStream] = []
	var directory := DirAccess.open(directory_path)
	if directory == null:
		push_warning("Audio directory missing: %s" % directory_path)
		return streams
	directory.list_dir_begin()
	var file_name := directory.get_next()
	while not file_name.is_empty():
		if not directory.current_is_dir() and file_name.get_extension().to_lower() in ["wav", "ogg", "mp3"]:
			if not prefix.is_empty() and not file_name.get_basename().begins_with(prefix):
				file_name = directory.get_next()
				continue
			var path := "%s/%s" % [directory_path, file_name]
			var stream := _load_audio_stream(path)
			if stream != null:
				streams.append(stream)
			else:
				push_warning("Audio stream failed to load: %s" % path)
		file_name = directory.get_next()
	directory.list_dir_end()
	return streams


func _load_audio_stream(path: String) -> AudioStream:
	match path.get_extension().to_lower():
		"wav":
			return AudioStreamWAV.load_from_file(path)
		"ogg":
			return AudioStreamOggVorbis.load_from_file(path)
		"mp3":
			return AudioStreamMP3.load_from_file(path)
		_:
			return null
