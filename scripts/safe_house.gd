extends Node2D

const BALANCE = preload("res://resources/balance/default_balance.tres")
const MEMORY_CLASSROOM_BACKGROUND: Texture2D = preload("res://assets/backgrounds/safe_house/memory_classroom.png")
const PauseMenuScript = preload("res://scripts/ui/pause_menu.gd")

const GROUND_ORIGIN := Vector2(100.0, 300.0)
const DEPTH_AXIS := Vector2(0.0, 1.0)
const PROGRESS_PATH := "user://linxi_progress.json"
const LOADOUT_PATH := "user://linxi_loadout.json"
const SIGN_SIZE := Vector2(154.0, 82.0)

@export var save_path_override := ""

var player_ground := Vector2(110.0, 155.0)
var panel_open := false
var active_station := ""
var hovered_station := -1
var permanent_weight := 1.0
var biomass := 0.0
var max_health := 10
var current_health := 10
var vore_capacity := 1
var body_weapon := "Claws"
var occupied_vore_capacity := 0
var contained_prey_weight := 0.0
var digest_progress := 0.0
var enemy_contained := false
var contained_route_loads := {"BELLY": 0, "CHEST": 0, "LOWER_BELLY": 0, "GROIN": 0}

var stations: Array[Dictionary] = [
	{"id": "mission", "name": "Mission Board", "position": Vector2(260, 55), "color": Color("d7a84b")},
	{"id": "archive", "name": "Archive Terminal", "position": Vector2(475, 190), "color": Color("58a9c9")},
	{"id": "training", "name": "Training Area", "position": Vector2(650, 55), "color": Color("d46c62")},
	{"id": "status", "name": "Status Station", "position": Vector2(825, 190), "color": Color("76c58a")},
	{"id": "equipment", "name": "Equipment Table", "position": Vector2(1000, 55), "color": Color("9d82ce")},
	{"id": "character", "name": "Character Area", "position": Vector2(1070, 205), "color": Color("d693b5")},
	{"id": "settings", "name": "Settings", "position": Vector2(90, 205), "color": Color("7f8b97")},
]

@onready var hint_label: Label = $HUD/Hint
@onready var panel: Panel = $HUD/StationPanel
@onready var panel_title: Label = $HUD/StationPanel/Title
@onready var panel_body: Label = $HUD/StationPanel/Body
@onready var panel_footer: Label = $HUD/StationPanel/Footer
@onready var avatar: ColorRect = $HUD/StationPanel/Avatar
@onready var avatar_letter: Label = $HUD/StationPanel/Avatar/Letter
@onready var primary_button: Button = $HUD/StationPanel/PrimaryButton
@onready var secondary_button: Button = $HUD/StationPanel/SecondaryButton
@onready var close_button: Button = $HUD/StationPanel/CloseButton

func _ready() -> void:
	get_tree().paused = false
	load_progress()
	_heal_and_commit_shelter_entry()
	primary_button.pressed.connect(_on_primary_pressed)
	secondary_button.pressed.connect(_on_secondary_pressed)
	close_button.pressed.connect(close_panel)
	panel.mouse_entered.connect(func() -> void: panel.modulate = Color(1.06, 1.04, 0.98))
	panel.mouse_exited.connect(func() -> void: panel.modulate = Color.WHITE)
	hint_label.text = "Shelter page: move the mouse over a sign, then click to open it."
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed and not event.echo and event.keycode == KEY_ESCAPE and panel_open: close_panel()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		hovered_station = station_at_screen_position(event.position)
		if hovered_station >= 0:
			hint_label.text = "Click: %s" % String(stations[hovered_station]["name"])
		else:
			hint_label.text = "Shelter page: move the mouse over a sign, then click to open it."
		queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var index := station_at_screen_position(event.position)
		if index >= 0: open_station(index)

func station_at_screen_position(mouse_position: Vector2) -> int:
	for index in range(stations.size() - 1, -1, -1):
		if station_screen_rect(stations[index]).has_point(mouse_position): return index
	return -1

func station_screen_rect(station: Dictionary) -> Rect2:
	var center := project_ground(Vector2(station["position"])) + Vector2(0.0, -42.0)
	return Rect2(center - SIGN_SIZE * 0.5, SIGN_SIZE)

func open_station(index: int) -> void:
	active_station = String(stations[index]["id"])
	panel_open = true
	panel.visible = true
	avatar.visible = active_station == "character"
	primary_button.visible = false
	secondary_button.visible = false
	match active_station:
		"mission": show_mission_board()
		"archive": show_archive()
		"training": show_training()
		"status": show_status()
		"equipment": show_equipment()
		"character": show_character()
		"settings": show_settings()

func show_mission_board() -> void:
	panel_title.text = "MISSION BOARD"
	panel_body.text = "STAGE 1: RED NIGHT\nCourtyard Fall Site -> Dormitory: Su Ruo's Room -> Roof Route -> Playground Return -> Teaching Building -> Outside The School\n\nWake in the courtyard, drink the blue solution, unlock claws, face the dormitory crisis, meet the teaching-building survivors, and leave the school.\n\nTRAINING: EVOLUTION ROOM\nReplay the ten-guard mechanics laboratory."
	primary_button.text = "Deploy: Red Night"
	secondary_button.text = "Abandon & Restart"
	primary_button.visible = true
	secondary_button.visible = true
	panel_footer.text = "Select a mission with the mouse."

func show_archive() -> void:
	panel_title.text = "ARCHIVE TERMINAL"
	panel_body.text = "PLOT SUMMARY\nRed Night begins at the courtyard fall site and now spans the dormitory, roof route, playground return, teaching building, and school exit.\n\nDISCOVERED DOCUMENT\nEvolution Protocol remains available as a non-canon training simulation.\n\nCHARACTER RECORD\nLinxi: human consciousness retained. Current body classification: Early T-zombie."
	panel_footer.text = "Archive entries will expand as the story progresses."

func show_training() -> void:
	panel_title.text = "TRAINING AREA"
	panel_body.text = "MOVEMENT\nWASD: Move in fake-3D lanes   Double A/D: Sprint   Space: Jump\n\nCOMBAT\nJ: Attack or fire weapon   K: Dodge   V: Vore   Hold L: Digest\n\nVALUES\nBase HP: 10   Base ATK: 2   Enemy hit stun: 0.1s   Evolution: 6 clean hits"
	secondary_button.text = "Enter Evolution Room"
	secondary_button.visible = true
	panel_footer.text = "Mission controls remain keyboard-focused."

func show_status() -> void:
	panel_title.text = "STATUS STATION"
	var digestion_text := "No active prey"
	if enemy_contained and occupied_vore_capacity > 0:
		digestion_text = "%d capacity occupied / %.2fs accumulated" % [occupied_vore_capacity, digest_progress]
	var expansion_text := "Belly %d | Chest %d | Lower %d | Groin %d" % [contained_route_loads["BELLY"], contained_route_loads["CHEST"], contained_route_loads["LOWER_BELLY"], contained_route_loads["GROIN"]]
	panel_body.text = "INNER IDENTITY: Human\nCURRENT BODY: Early T-zombie\nHP: %d/%d\nWEIGHT: %.1f\nBIOMASS: %.1f/%.0f\nBASE CAPACITY: %d\nCURRENT CAPACITY: %d (%d occupied)\nCONTAINED WEIGHT: %.1f\nBODY LOAD: %s\nBODY WEAPON: %s\nDIGESTION: %s\nG MODE: Requires 10 biomass" % [current_health, max_health, permanent_weight, biomass, BALANCE.maximum_biomass, vore_capacity, vore_capacity + BALANCE.capacity_bonus(biomass), occupied_vore_capacity, contained_prey_weight, expansion_text, body_weapon, digestion_text]
	panel_footer.text = "Status data is loaded from Linxi's current save."

func show_equipment() -> void:
	panel_title.text = "EQUIPMENT TABLE"
	panel_body.text = "BODY ARSENAL\nClaws: active permanent weapon.\nTail, waist bone blades, and voice attacks unlock through story progression.\n\nHUMAN WEAPONS\nGuns and knives are temporary mission pickups. Linxi never reloads them: empty guns are dropped, and knives are thrown once."
	panel_footer.text = "Body attacks will use directional WASD + J commands as they unlock."

func show_character() -> void:
	panel_title.text = "MIRA - FIELD OPERATOR"
	panel_body.text = "You can return here between missions, Linxi. I will keep the records organized while you prepare.\n\nRelationship: Professional trust\nAvailable topic: The evolution facility"
	panel_footer.text = "Character conversations and relationships will grow with the plot."
	avatar_letter.text = "M"


func show_settings() -> void:
	panel_title.text = "MEMORY SETTINGS"
	panel_body.text = "Adjust window size and master volume, review keyboard controls, or exit the game. Gameplay remains paused while the settings panel is open."
	primary_button.text = "Open Settings"
	primary_button.visible = true
	panel_footer.text = "Settings use the same interface as the in-mission pause menu."

func _on_primary_pressed() -> void:
	if active_station == "mission":
		clear_encounter_transaction()
		get_tree().change_scene_to_file("res://scenes/red_night.tscn")
	elif active_station == "settings":
		var settings := PauseMenuScript.new()
		settings.name = "MemorySettings"
		add_child(settings)
		get_tree().paused = true

func _on_secondary_pressed() -> void:
	if active_station == "mission":
		clear_encounter_transaction()
		get_tree().change_scene_to_file("res://scenes/red_night.tscn")
	elif active_station == "training":
		get_tree().change_scene_to_file("res://scenes/main.tscn")
func clear_encounter_transaction() -> void:
	var path := progress_path()
	if not FileAccess.file_exists(path): return
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary: return
	data.erase("encounter_state")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(data))


func close_panel() -> void:
	panel_open = false
	panel.visible = false
	panel.modulate = Color.WHITE
	active_station = ""

func load_progress() -> void:
	var path := progress_path()
	if not FileAccess.file_exists(path): return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file: return
	var data = JSON.parse_string(file.get_as_text())
	if not data is Dictionary: return
	permanent_weight = float(data.get("permanent_weight", 1.0))
	biomass = BALANCE.clamp_biomass(float(data.get("biomass", 0.0)))
	max_health = int(data.get("player_max_health", 10))
	current_health = clampi(int(data.get("player_health", max_health)), 0, max_health)
	vore_capacity = int(data.get("vore_capacity", 1))
	occupied_vore_capacity = maxi(int(data.get("occupied_vore_capacity", 0)), 0)
	contained_prey_weight = maxf(float(data.get("contained_prey_weight", 0.0)), 0.0)
	digest_progress = maxf(float(data.get("digest_progress", 0.0)), 0.0)
	enemy_contained = bool(data.get("enemy_contained", false)) and occupied_vore_capacity > 0
	var saved_loads = data.get("contained_route_loads", {})
	if saved_loads is Dictionary:
		for region in contained_route_loads:
			contained_route_loads[region] = maxi(int(saved_loads.get(region, 0)), 0)


func progress_path() -> String:
	return save_path_override if not save_path_override.is_empty() else PROGRESS_PATH


func _heal_and_commit_shelter_entry() -> void:
	current_health = max_health
	var path := progress_path()
	var data: Dictionary = {}
	if FileAccess.file_exists(path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			data = parsed
	data["player_health"] = current_health
	data.erase("encounter_state")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func project_ground(point: Vector2) -> Vector2:
	return GROUND_ORIGIN + Vector2(point.x, 0.0) + DEPTH_AXIS * point.y

func _draw() -> void:
	var viewport := get_viewport_rect().size
	draw_texture_rect(MEMORY_CLASSROOM_BACKGROUND, Rect2(Vector2.ZERO, viewport), false, Color.WHITE)
	draw_rect(Rect2(Vector2.ZERO, viewport), Color(0.18, 0.11, 0.06, 0.16), true)
	var drawables: Array[Dictionary] = []
	for index in range(stations.size()): drawables.append({"depth": Vector2(stations[index]["position"]).y, "kind": "station", "position": project_ground(stations[index]["position"]), "index": index})
	drawables.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["depth"]) < float(b["depth"]))
	for entry in drawables:
		draw_station(entry["position"], int(entry["index"]))

func draw_station(at: Vector2, index: int) -> void:
	var station: Dictionary = stations[index]
	var highlighted := index == hovered_station or (panel_open and String(station["id"]) == active_station)
	var color: Color = station["color"]
	if highlighted: color = color.lightened(0.25)
	draw_set_transform(at)
	if highlighted:
		draw_rect(Rect2(-82, -88, 164, 94), Color(color, 0.24), true)
		draw_rect(Rect2(-82, -88, 164, 94), color, false, 4.0)
	draw_rect(Rect2(-70, -72, 140, 66), color.darkened(0.38), true)
	draw_rect(Rect2(-62, -64, 124, 50), color, true)
	draw_string(ThemeDB.fallback_font, Vector2(-60, -34), String(station["name"]), HORIZONTAL_ALIGNMENT_CENTER, 120, 15, Color.WHITE)
	if highlighted: draw_string(ThemeDB.fallback_font, Vector2(-45, 25), "CLICK", HORIZONTAL_ALIGNMENT_CENTER, 90, 13, Color("ffe99a"))
	draw_set_transform(Vector2.ZERO)
