class_name SignalInterferenceOverlay
extends Control

@export var base_alpha := 0.42
@export var scanline_spacing := 4.0
@export var tear_count := 12
@export var noise_count := 90

var effect_time := 0.0
var effect_duration := 0.001
var effect_intensity := 1.0
var effect_seed := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_process(false)


func trigger(duration := 0.42, intensity := 1.0) -> void:
	effect_duration = maxf(duration, 0.001)
	effect_time = effect_duration
	effect_intensity = clampf(intensity, 0.0, 1.5)
	effect_seed += 1
	visible = true
	set_process(true)
	queue_redraw()


func is_active() -> bool:
	return effect_time > 0.0


func _process(delta: float) -> void:
	effect_time = maxf(effect_time - delta, 0.0)
	if effect_time <= 0.0:
		visible = false
		set_process(false)
	queue_redraw()


func _draw() -> void:
	if effect_time <= 0.0:
		return
	var size := get_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var progress := 1.0 - effect_time / maxf(effect_duration, 0.001)
	var envelope := (1.0 - smoothstep(0.48, 1.0, progress)) * effect_intensity
	var frame_bucket := int(Time.get_ticks_msec() / 33)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(0x5349474E + effect_seed * 101 + frame_bucket * 17)

	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.08, 0.095, base_alpha * 0.16 * envelope), true)

	var spacing := maxf(scanline_spacing, 1.0)
	var y := 0.0
	while y < size.y:
		var line_alpha := (0.035 + rng.randf() * 0.045) * envelope
		draw_rect(Rect2(0.0, y, size.x, 1.0), Color(0.55, 0.95, 1.0, line_alpha), true)
		y += spacing

	for index in range(tear_count):
		var band_y := rng.randf_range(0.0, size.y)
		var band_h := rng.randf_range(2.0, 18.0) * lerpf(0.7, 1.25, envelope)
		var offset := rng.randf_range(-60.0, 60.0) * envelope
		var width := size.x * rng.randf_range(0.35, 1.1)
		var start_x := clampf(offset, -80.0, size.x * 0.35)
		var color := Color(0.0, 0.0, 0.0, rng.randf_range(0.10, 0.28) * envelope)
		draw_rect(Rect2(start_x, band_y, width, band_h), color, true)
		var accent := Color(0.55, 0.95, 1.0, rng.randf_range(0.08, 0.18) * envelope)
		draw_rect(Rect2(start_x - offset * 0.35, band_y + band_h * 0.5, width * 0.72, 1.0), accent, true)
		var red_ghost := Color(0.9, 0.08, 0.1, rng.randf_range(0.04, 0.12) * envelope)
		draw_rect(Rect2(start_x + offset * 0.24, band_y + band_h * 0.25, width * 0.52, 1.0), red_ghost, true)

	for index in range(noise_count):
		if rng.randf() > envelope:
			continue
		var dot_size := rng.randf_range(1.0, 3.0)
		var dot_position := Vector2(rng.randf_range(0.0, size.x), rng.randf_range(0.0, size.y))
		var dot_color := Color(0.7, 0.95, 1.0, rng.randf_range(0.05, 0.22) * envelope)
		draw_rect(Rect2(dot_position, Vector2(dot_size, dot_size)), dot_color, true)

	if progress < 0.18:
		var flash_alpha := (1.0 - progress / 0.18) * 0.18 * effect_intensity
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.85, 0.96, 1.0, flash_alpha), true)
