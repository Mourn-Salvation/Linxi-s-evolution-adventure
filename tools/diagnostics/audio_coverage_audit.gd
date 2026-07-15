extends SceneTree

const MainScene = preload("res://scenes/red_night.tscn")
const OpeningScene = preload("res://scenes/opening_intro.tscn")
const GameSessionData = preload("res://scripts/data/game_session.gd")
const REQUIRED_EVENTS := [
	"ui_hover", "ui_confirm", "ui_cancel", "achievement_pop",
	"footstep_wet", "footstep_concrete", "footstep_marble", "footstep_grass",
	"dodge_whoosh", "jump", "hurt", "linxi_claw_swing", "linxi_claw_hit_flesh",
	"enemy_zombie_groan", "enemy_hurt_flesh", "enemy_knockdown_bodyfall",
	"nebulizer_idle_hum", "blue_vial_drink", "signal_interference_burst",
	"map_transition_pulse",
]


func _initialize() -> void:
	var failures := 0
	var stage = MainScene.instantiate()
	root.add_child(stage)
	await process_frame
	for event_name in REQUIRED_EVENTS:
		var streams: Array = stage.audio_component.streams_by_event.get(event_name, [])
		if streams.is_empty():
			push_error("SFX event has no streams: %s" % event_name)
			failures += 1
	stage.queue_free()
	await process_frame

	GameSessionData.force_opening_once = true
	var opening = OpeningScene.instantiate()
	root.add_child(opening)
	await process_frame
	var rain: AudioStreamPlayer = opening.get_node_or_null("RainAmbience")
	var interference: AudioStreamPlayer = opening.get_node_or_null("SignalInterferenceSFX")
	if rain == null or rain.stream == null or not rain.playing:
		push_error("Opening rain ambience is missing or not playing")
		failures += 1
	if interference == null or interference.stream == null:
		push_error("Opening signal-interference SFX is missing")
		failures += 1
	opening.queue_free()
	await process_frame

	if failures == 0:
		print("PASS: opening ambience and %s named SFX events are wired" % REQUIRED_EVENTS.size())
	quit(1 if failures > 0 else 0)
