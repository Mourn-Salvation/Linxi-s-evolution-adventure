extends Node2D

enum Phase {
	TITLE_LOOP,
	CLIP_00001,
	CLIP_00004,
	CLIP_00007,
	FLASH_STILL,
	CLIP_00003,
	FALL_STILL,
	LYING_STILL,
	TRANSITION,
}

const RED_NIGHT_SCENE := "res://scenes/red_night.tscn"
const RAIN_AMBIENCE_PATH := "res://assets/audio/ambience/opening/rain_window_loop.ogg"
const MIN_WINDOW_SIZE := Vector2i(1280, 720)
const FRAME_FPS := 24.0
const FLASH_STILL_DURATION := 0.1
const FALL_STILL_DURATION := 0.45
const LYING_STILL_DURATION := 1.35
const CLIP_DEFINITIONS := {
	"image__00002": 73,
	"image__00001": 48,
	"image__00004": 49,
	"image__00007": 49,
	"image__00003": 75,
}
const CLIP_FPS_OVERRIDES := {
	"image__00001": 48.0,
}

var phase := Phase.TITLE_LOOP
var phase_time := 0.0
var title_ready := false
var cinematic_started := false
var transition_requested := false
var clip_frame_cache: Dictionary = {}
var flash_still: Texture2D
var fall_still: Texture2D
var lying_still: Texture2D

@onready var title: Label = $HUD/Title
@onready var prompt: Label = $HUD/Prompt
@onready var location: Label = $HUD/Location
@onready var subtitle: Label = $HUD/Subtitle
@onready var signal_interference = $HUD/SignalInterferenceOverlay
@onready var black: ColorRect = $HUD/Black
@onready var rain_ambience: AudioStreamPlayer = $RainAmbience
@onready var signal_interference_sfx: AudioStreamPlayer = $SignalInterferenceSFX


func _ready() -> void:
	DisplayServer.window_set_min_size(MIN_WINDOW_SIZE)
	DisplayServer.window_set_size(MIN_WINDOW_SIZE)
	load_opening_assets()
	rain_ambience.stream = AudioStreamOggVorbis.load_from_file(RAIN_AMBIENCE_PATH)
	_enable_audio_loop(rain_ambience.stream)
	if rain_ambience.stream != null:
		rain_ambience.play()
	else:
		push_warning("Opening rain ambience could not be loaded: %s" % RAIN_AMBIENCE_PATH)
	title.modulate.a = 0.0
	prompt.modulate.a = 0.0
	location.visible = false
	subtitle.visible = false
	black.color = Color(0.0, 0.0, 0.0, 1.0)
	create_tween().tween_property(black, "color:a", 0.0, 1.2)
	await get_tree().create_timer(0.75).timeout
	create_tween().tween_property(title, "modulate:a", 1.0, 0.8)
	await get_tree().create_timer(0.55).timeout
	title_ready = true
	queue_redraw()


func load_opening_assets() -> void:
	for clip_name in CLIP_DEFINITIONS:
		clip_frame_cache[clip_name] = {}
	flash_still = load_optional_texture("res://assets/sprites/linxi/opening_sequence/flash_linxi_00013_fullframe.png")
	fall_still = load_optional_texture("res://assets/sprites/linxi/opening_sequence/vertical_fall_school_campus.png")
	lying_still = load_optional_texture("res://assets/sprites/linxi/opening_sequence/lying_flat_ground.png")


func load_optional_texture(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null


func clip_frame_count(clip_name: String) -> int:
	return int(CLIP_DEFINITIONS.get(clip_name, 0))


func clip_frame_texture(clip_name: String, frame_number: int) -> Texture2D:
	if not clip_frame_cache.has(clip_name):
		clip_frame_cache[clip_name] = {}
	var cache: Dictionary = clip_frame_cache[clip_name]
	if cache.has(frame_number):
		return cache[frame_number]
	var path := "res://assets/videos/opening_frames/%s/frame_%03d.jpg" % [clip_name, frame_number]
	var texture := load_optional_texture(path)
	if texture != null:
		cache[frame_number] = texture
	return texture


func _process(delta: float) -> void:
	phase_time += delta
	if phase == Phase.TITLE_LOOP:
		prompt.modulate.a = (0.55 + sin(Time.get_ticks_msec() * 0.004) * 0.35) if title_ready else 0.0
	elif phase == Phase.CLIP_00001 and phase_time >= clip_duration("image__00001"):
		set_phase(Phase.CLIP_00004)
	elif phase == Phase.CLIP_00004 and phase_time >= clip_duration("image__00004"):
		set_phase(Phase.CLIP_00007)
	elif phase == Phase.CLIP_00007 and phase_time >= clip_duration("image__00007"):
		set_phase(Phase.FLASH_STILL)
	elif phase == Phase.FLASH_STILL and phase_time >= FLASH_STILL_DURATION:
		set_phase(Phase.CLIP_00003)
	elif phase == Phase.CLIP_00003 and phase_time >= clip_duration("image__00003"):
		set_phase(Phase.FALL_STILL)
	elif phase == Phase.FALL_STILL and phase_time >= FALL_STILL_DURATION:
		set_phase(Phase.LYING_STILL)
	elif phase == Phase.LYING_STILL and phase_time >= LYING_STILL_DURATION:
		set_phase(Phase.TRANSITION)
	elif phase == Phase.TRANSITION and phase_time >= 0.65:
		transition_to_red_night()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not title_ready or cinematic_started:
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventScreenTouch:
		if event.pressed:
			begin_cinematic()


func begin_cinematic() -> void:
	cinematic_started = true
	title.visible = false
	prompt.visible = false
	subtitle.visible = false
	set_phase(Phase.CLIP_00001)


func set_phase(next_phase: Phase) -> void:
	phase = next_phase
	phase_time = 0.0
	location.visible = false
	subtitle.visible = false
	match phase:
		Phase.FLASH_STILL:
			signal_interference.trigger(FLASH_STILL_DURATION, 1.0)
			signal_interference_sfx.play()
		Phase.TRANSITION:
			black.color = Color(0.0, 0.0, 0.0, 0.0)
			create_tween().tween_property(black, "color:a", 1.0, 0.6)
		_:
			black.color.a = 0.0


func _enable_audio_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD


func clip_duration(clip_name: String) -> float:
	return float(clip_frame_count(clip_name)) / clip_fps(clip_name)


func clip_fps(clip_name: String) -> float:
	return float(CLIP_FPS_OVERRIDES.get(clip_name, FRAME_FPS))


func transition_to_red_night() -> void:
	if transition_requested:
		return
	transition_requested = true
	if not ResourceLoader.exists(RED_NIGHT_SCENE):
		transition_requested = false
		black.color.a = 0.0
		subtitle.visible = true
		subtitle.text = "RED NIGHT could not be loaded. Press F6 on red_night.tscn."
		push_error("Missing Red Night scene: %s" % RED_NIGHT_SCENE)
		return
	var error := get_tree().change_scene_to_file(RED_NIGHT_SCENE)
	if error != OK:
		transition_requested = false
		black.color.a = 0.0
		subtitle.visible = true
		subtitle.text = "Scene transition failed: %s" % error_string(error)
		push_error("Could not enter Red Night: %s" % error_string(error))


func _draw() -> void:
	var viewport := get_viewport_rect().size
	match phase:
		Phase.TITLE_LOOP:
			draw_clip_frame("image__00002", true)
		Phase.CLIP_00001:
			draw_clip_frame("image__00001")
		Phase.CLIP_00004:
			draw_clip_frame("image__00004")
		Phase.CLIP_00007:
			draw_clip_frame("image__00007")
		Phase.FLASH_STILL:
			draw_fullscreen_art(flash_still, Color.WHITE)
		Phase.CLIP_00003:
			draw_clip_frame("image__00003")
		Phase.FALL_STILL:
			draw_fullscreen_art(fall_still, Color.WHITE)
		Phase.LYING_STILL, Phase.TRANSITION:
			draw_fullscreen_art(lying_still, Color.WHITE)


func draw_clip_frame(clip_name: String, loop: bool = false) -> void:
	var frame_count := clip_frame_count(clip_name)
	if frame_count <= 0:
		return
	var frame_index := int(floor(phase_time * clip_fps(clip_name)))
	if loop:
		frame_index = frame_index % frame_count
	else:
		frame_index = mini(frame_index, frame_count - 1)
	draw_fullscreen_art(clip_frame_texture(clip_name, frame_index + 1), Color.WHITE)


func draw_fullscreen_art(texture: Texture2D, color: Color) -> void:
	if texture == null:
		return
	var viewport := get_viewport_rect().size
	draw_texture_rect(texture, cover_rect(texture, viewport), false, color)


func cover_rect(texture: Texture2D, viewport: Vector2, zoom: float = 1.0) -> Rect2:
	var texture_size := texture.get_size()
	var scale := maxf(viewport.x / texture_size.x, viewport.y / texture_size.y) * zoom
	var size := texture_size * scale
	return Rect2((viewport - size) * 0.5, size)
