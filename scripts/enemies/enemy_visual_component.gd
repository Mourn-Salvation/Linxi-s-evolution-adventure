extends Node

@export var visual_library: EnemyVisualLibrary

var host: Node
var texture_cache: Dictionary = {}
var missing_texture_paths: Dictionary = {}


func setup(value: Node) -> void:
	host = value
	if visual_library == null:
		visual_library = load("res://resources/enemies/red_night_enemy_visual_library.tres") as EnemyVisualLibrary


func enemy_hit_frames(enemy: Dictionary) -> Array[Texture2D]:
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	var facing_right := float(enemy.get("facing", -1.0)) > 0.0
	return visual_library.hit_frames(family, host.EnemyFamily.ZOMBIE, facing_right)


func load_enemy_action_texture(enemy_id: String, action: String, facing_right: bool, frame_index: int, variant_index: int = -1) -> Texture2D:
	var direction: String = "right" if facing_right else "left"
	var frame_name: String = "%s_%s.png" % [direction, str(frame_index).pad_zeros(2)]
	var path := ""
	if variant_index >= 0:
		path = "res://assets/sprites/enemies/%s/%s/variant_%s/%s" % [enemy_id, action, str(variant_index).pad_zeros(2), frame_name]
	else:
		path = "res://assets/sprites/enemies/%s/%s/%s" % [enemy_id, action, frame_name]
	return load_texture_if_exists(path)


func load_texture_if_exists(path: String) -> Texture2D:
	if texture_cache.has(path):
		return texture_cache[path] as Texture2D
	if missing_texture_paths.has(path):
		return null
	if not ResourceLoader.exists(path):
		missing_texture_paths[path] = true
		return null
	var texture := load(path) as Texture2D
	if texture == null:
		missing_texture_paths[path] = true
		return null
	texture_cache[path] = texture
	return texture


func load_human_student_variant_texture(action: String, facing_right: bool, frame_index: int, appearance_id: int) -> Texture2D:
	if not is_human_student_female_appearance_id(appearance_id):
		return null
	var direction: String = "right" if facing_right else "left"
	var variant: String = str(appearance_id).pad_zeros(2)
	match action:
		"move":
			return load_texture_if_exists("res://assets/sprites/enemies/human_student/run_female_variants/variant_%s/%s_%s.png" % [variant, direction, str(frame_index).pad_zeros(2)])
		"hurt":
			return load_texture_if_exists("res://assets/sprites/enemies/human_student/hurt_female_variants/variant_%s/%s_%s.png" % [variant, direction, str(frame_index).pad_zeros(2)])
		"knocked_down":
			return load_texture_if_exists("res://assets/sprites/enemies/human_student/knocked_down_female_variants/variant_%s/%s_00.png" % [variant, direction])
		"appearance":
			var idle_texture: Texture2D = load_texture_if_exists("res://assets/sprites/enemies/human_student/idle_female_variants_v2/variant_%s/%s_00.png" % [variant, direction])
			if idle_texture != null:
				return idle_texture
	return null


func load_human_student_male_variant_texture(action: String, facing_right: bool, frame_index: int, appearance_id: int) -> Texture2D:
	if appearance_id <= 0 or is_human_student_female_appearance_id(appearance_id):
		return null
	var direction: String = "right" if facing_right else "left"
	var variant: String = str(appearance_id).pad_zeros(2)
	match action:
		"move":
			return load_texture_if_exists("res://assets/sprites/enemies/human_student/run_male_variants/variant_%s/%s_%s.png" % [variant, direction, str(frame_index).pad_zeros(2)])
		"hurt":
			return load_texture_if_exists("res://assets/sprites/enemies/human_student/hurt_male_variants/variant_%s/%s_%s.png" % [variant, direction, str(frame_index).pad_zeros(2)])
		"knocked_down":
			return load_texture_if_exists("res://assets/sprites/enemies/human_student/knocked_down_male_variants/variant_%s/%s_00.png" % [variant, direction])
		"appearance":
			var idle_texture: Texture2D = load_texture_if_exists("res://assets/sprites/enemies/human_student/idle_male_variants_v2/variant_%s/%s_00.png" % [variant, direction])
			if idle_texture != null:
				return idle_texture
	return null


func load_human_student_base_female_idle(facing_right: bool) -> Texture2D:
	var direction: String = "right" if facing_right else "left"
	return load_texture_if_exists("res://assets/sprites/enemies/human_student/idle_female_v2/%s_00.png" % direction)


func load_zombie_student_idle_texture(facing_right: bool, appearance_id: int) -> Texture2D:
	var direction: String = "right" if facing_right else "left"
	var variant: String = str(appearance_id).pad_zeros(2)
	return load_texture_if_exists("res://assets/sprites/enemies/zombie_student/idle/variant_%s/%s_00.png" % [variant, direction])


func load_human_student_weapon_attack_texture(facing_right: bool, frame_index: int, appearance_id: int, weapon_id: String) -> Texture2D:
	if weapon_id != "knife" or appearance_id <= 0:
		return null
	var direction: String = "right" if facing_right else "left"
	var variant: String = str(appearance_id).pad_zeros(2)
	return load_texture_if_exists("res://assets/sprites/enemies/human_student/attack_knife_male_variants/variant_%s/%s_%s.png" % [variant, direction, str(frame_index).pad_zeros(2)])


func enemy_loop_frame(action_frame_count: int, frame_ms: float = 140.0) -> int:
	return int(floor(Time.get_ticks_msec() / frame_ms)) % action_frame_count


func enemy_attack_frame(enemy: Dictionary, frame_count: int = 2) -> int:
	var state := String(enemy.get("state", ""))
	if state == "TELEGRAPH" or state == "HEAVY_TELEGRAPH":
		return 0
	if state == "RECOVER":
		var recovery_progress: float = 1.0 - clampf(float(enemy.get("state_time", 0.0)) / maxf(host.balance.human_recovery_time, 0.001), 0.0, 1.0)
		return mini(1 + int(floor(recovery_progress * float(maxi(frame_count - 1, 1)))), frame_count - 1)
	var duration: float = host.balance.human_recovery_time
	if state == "HEAVY_TELEGRAPH":
		duration = host.balance.human_heavy_telegraph_time
	elif state == "TELEGRAPH":
		duration = host.balance.human_telegraph_time
	var progress: float = 1.0 - clampf(float(enemy.get("state_time", 0.0)) / maxf(duration, 0.001), 0.0, 1.0)
	return mini(int(floor(progress * float(frame_count))), frame_count - 1)


func current_enemy_action_texture(enemy: Dictionary, action: String, frame_count: int, progress: float = -1.0) -> Texture2D:
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	var facing_right := enemy_visual_facing_right(enemy, action)
	var frame_index: int = enemy_loop_frame(frame_count)
	if progress >= 0.0:
		frame_index = mini(int(floor(clampf(progress, 0.0, 0.999) * float(frame_count))), frame_count - 1)
	if is_bone_blade_elite(enemy):
		return load_enemy_action_texture("bone_blade_twin", action, facing_right, frame_index)
	if family == host.EnemyFamily.ZOMBIE:
		var appearance_frames: Array[Texture2D] = visual_library.zombie_appearance_frames(facing_right)
		var zombie_appearance_id: int = clampi(int(enemy.get("appearance_id", 0)), 0, appearance_frames.size() - 1)
		var asset_facing_right: bool = not facing_right if action == "attack" else facing_right
		return load_enemy_action_texture("zombie_student", action, asset_facing_right, frame_index, zombie_appearance_id)
	if family == host.EnemyFamily.HUMAN:
		if is_human_student_archetype(enemy):
			var appearance_id: int = int(enemy.get("appearance_id", 0))
			if action == "attack":
				var weapon_texture: Texture2D = load_human_student_weapon_attack_texture(facing_right, frame_index, appearance_id, String(enemy.get("weapon_id", "")).to_lower())
				if weapon_texture != null:
					return weapon_texture
			var variant_texture: Texture2D = load_human_student_variant_texture(action, facing_right, frame_index, appearance_id)
			if variant_texture == null:
				variant_texture = load_human_student_male_variant_texture(action, facing_right, frame_index, appearance_id)
			if variant_texture != null:
				return variant_texture
			var student_action: String = action
			if action == "hurt" and is_human_student_female_appearance_id(appearance_id):
				student_action = "hurt_female"
			return load_enemy_action_texture("human_student", student_action, facing_right, frame_index)
		return load_enemy_action_texture("human_guard", action, facing_right, frame_index)
	return null


func current_enemy_hit_texture(enemy: Dictionary) -> Texture2D:
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	if family == host.EnemyFamily.MUTANT_CREATURE:
		return null
	if is_bone_blade_elite(enemy):
		var elite_duration: float = maxf(float(enemy.get("hit_reaction_duration", 0.28)), 0.001)
		var elite_progress: float = clampf((elite_duration - float(enemy.get("hit_reaction_time", 0.0))) / elite_duration, 0.0, 0.999)
		return current_enemy_action_texture(enemy, "hurt", 2, elite_progress)
	if family == host.EnemyFamily.ZOMBIE:
		return enemy_appearance_texture(enemy)
	var duration: float = maxf(float(enemy.get("hit_reaction_duration", 0.28)), 0.001)
	var time_left: float = float(enemy.get("hit_reaction_time", 0.0))
	var progress: float = clampf((duration - time_left) / duration, 0.0, 0.999)
	var derived_hurt: Texture2D = current_enemy_action_texture(enemy, "hurt", 2, progress)
	if derived_hurt != null:
		return derived_hurt
	var frames: Array[Texture2D] = enemy_hit_frames(enemy)
	var frame_index: int = mini(int(floor(progress * float(frames.size()))), frames.size() - 1)
	return frames[frame_index]


func enemy_appearance_texture(enemy: Dictionary) -> Texture2D:
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	var facing_right := float(enemy.get("facing", -1.0)) > 0.0
	var state := String(enemy.get("state", ""))
	if is_bone_blade_elite(enemy):
		if state in ["SPECIAL_TELEGRAPH", "SPECIAL_RUSH", "SPECIAL_RECOVER"]:
			var special_frame := clampi(int(enemy.get("special_visual_frame", 0)), 0, 5)
			if state == "SPECIAL_RUSH":
				var strike_index := clampi(int(enemy.get("special_strike_index", 1)) - 1, 0, 2)
				var interval: float = maxf(host.balance.bone_blade_special_strike_interval, 0.001)
				var strike_progress := 1.0 - clampf(float(enemy.get("special_strike_time", 0.0)) / interval, 0.0, 1.0)
				# Keep preparation brief and let the impact silhouette carry the strike.
				special_frame = strike_index * 2 + (1 if strike_progress >= 0.2 else 0)
			return load_enemy_action_texture("bone_blade_twin", "special_rush", enemy_visual_facing_right(enemy, "attack"), special_frame)
		if state in ["TELEGRAPH", "HEAVY_TELEGRAPH", "RECOVER"]:
			return current_enemy_action_texture(enemy, "attack", 2, float(enemy_attack_frame(enemy, 2)) / 2.0)
		if state in ["APPROACH", "NEUTRAL"] and not _should_hold_idle(enemy, state):
			return current_enemy_action_texture(enemy, "move", 8)
		return current_enemy_action_texture(enemy, "idle", 4)
	if state in ["TELEGRAPH", "HEAVY_TELEGRAPH", "RECOVER"]:
		var attack_frame_count: int = enemy_attack_frame_count(enemy)
		var attack_frame: int = enemy_attack_frame(enemy, attack_frame_count)
		var attack_texture: Texture2D = current_enemy_action_texture(enemy, "attack", attack_frame_count, float(attack_frame) / float(attack_frame_count))
		if attack_texture != null:
			return attack_texture
	if state in ["APPROACH", "NEUTRAL"] and not _should_hold_idle(enemy, state):
		var move_texture: Texture2D = current_enemy_action_texture(enemy, "move", 8)
		if move_texture != null:
			return move_texture
	if family == host.EnemyFamily.ZOMBIE:
		var frames: Array[Texture2D] = visual_library.zombie_appearance_frames(facing_right)
		var appearance_id: int = clampi(int(enemy.get("appearance_id", 0)), 0, frames.size() - 1)
		var idle_texture: Texture2D = load_zombie_student_idle_texture(facing_right, appearance_id)
		if idle_texture != null:
			return idle_texture
		return frames[appearance_id]
	if family == host.EnemyFamily.HUMAN:
		if is_human_student_archetype(enemy):
			return human_student_texture(enemy, facing_right)
		var frames: Array[Texture2D] = visual_library.hit_frames(family, host.EnemyFamily.ZOMBIE, facing_right)
		return frames[mini(3, frames.size() - 1)]
	return null


func enemy_scale_reference_texture(enemy: Dictionary) -> Texture2D:
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	var facing_right := enemy_visual_facing_right(enemy, "move")
	if family == host.EnemyFamily.ZOMBIE:
		var move_texture: Texture2D = current_enemy_action_texture(enemy, "move", 8, 0.0)
		if move_texture != null:
			return move_texture
		var appearance_frames: Array[Texture2D] = visual_library.zombie_appearance_frames(facing_right)
		if appearance_frames.is_empty():
			return null
		var zombie_appearance_id: int = clampi(int(enemy.get("appearance_id", 0)), 0, appearance_frames.size() - 1)
		return appearance_frames[zombie_appearance_id]
	if family == host.EnemyFamily.HUMAN:
		if is_human_student_archetype(enemy):
			var student_move_texture: Texture2D = current_enemy_action_texture(enemy, "move", 8, 0.0)
			if student_move_texture != null:
				return student_move_texture
			return human_student_texture(enemy, facing_right)
		return current_enemy_action_texture(enemy, "move", 8, 0.0)
	return null


func human_student_texture(enemy: Dictionary, facing_right: bool) -> Texture2D:
	var state := String(enemy.get("state", "DORMANT"))
	var appearance_id: int = int(enemy.get("appearance_id", 0))
	var female_variant: bool = is_human_student_female_appearance_id(appearance_id)
	if (state == "NEUTRAL" or state == "APPROACH" or state == "STAGGER") and not _should_hold_idle(enemy, state):
		var variant_texture: Texture2D = load_human_student_variant_texture("move", facing_right, enemy_loop_frame(8, 120.0), appearance_id)
		if variant_texture == null:
			variant_texture = load_human_student_male_variant_texture("move", facing_right, enemy_loop_frame(8, 120.0), appearance_id)
		if variant_texture != null:
			return variant_texture
		var frames: Array[Texture2D] = visual_library.human_student_run_frames(facing_right, female_variant)
		var frame_index: int = int(floor(Time.get_ticks_msec() / 120.0)) % frames.size()
		return frames[frame_index]
	if female_variant:
		var variant_appearance: Texture2D = load_human_student_variant_texture("appearance", facing_right, 0, appearance_id)
		if variant_appearance != null:
			return variant_appearance
		var base_female_idle: Texture2D = load_human_student_base_female_idle(facing_right)
		if base_female_idle != null:
			return base_female_idle
	var male_variant_appearance: Texture2D = load_human_student_male_variant_texture("appearance", facing_right, 0, appearance_id)
	if male_variant_appearance != null:
		return male_variant_appearance
	return visual_library.human_student_appearance(facing_right, female_variant)


func enemy_knocked_down_texture(enemy: Dictionary) -> Texture2D:
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	var facing_right := float(enemy.get("facing", -1.0)) > 0.0
	if is_bone_blade_elite(enemy):
		return load_enemy_action_texture("bone_blade_twin", "knocked_down", facing_right, 0)
	if family == host.EnemyFamily.ZOMBIE:
		var frames: Array[Texture2D] = visual_library.zombie_knocked_down_frames(facing_right)
		var appearance_id: int = clampi(int(enemy.get("appearance_id", 0)), 0, frames.size() - 1)
		return frames[appearance_id]
	if family == host.EnemyFamily.HUMAN:
		if is_human_student_archetype(enemy):
			var appearance_id: int = int(enemy.get("appearance_id", 0))
			var female_variant: bool = is_human_student_female_appearance_id(appearance_id)
			if female_variant:
				var variant_knocked: Texture2D = load_human_student_variant_texture("knocked_down", facing_right, 0, appearance_id)
				if variant_knocked != null:
					return variant_knocked
			else:
				var male_variant_knocked: Texture2D = load_human_student_male_variant_texture("knocked_down", facing_right, 0, appearance_id)
				if male_variant_knocked != null:
					return male_variant_knocked
			return visual_library.human_student_knocked_down(facing_right, female_variant)
		return visual_library.human_guard_knocked_down(facing_right)
	return null


func enemy_hit_pose(enemy: Dictionary) -> Dictionary:
	var duration: float = maxf(float(enemy.get("hit_reaction_duration", 0.28)), 0.001)
	var time_left: float = float(enemy.get("hit_reaction_time", 0.0))
	var progress: float = clampf((duration - time_left) / duration, 0.0, 0.999)
	var stage: int = 0 if progress < 0.5 else 1
	var facing_value := float(enemy.get("facing", -1.0))
	var family: int = int(enemy.get("family", host.EnemyFamily.HUMAN))
	if family == host.EnemyFamily.ZOMBIE:
		return {
			"offset": Vector2(-facing_value * (7.0 if stage == 0 else 3.0), -2.0 if stage == 0 else 1.0),
			"rotation": deg_to_rad((-5.5 if stage == 0 else 3.0) * facing_value),
			"scale": Vector2(0.98, 1.02) if stage == 0 else Vector2(1.02, 0.99),
		}
	if family == host.EnemyFamily.MUTANT_CREATURE:
		return {
			"offset": Vector2(-facing_value * (10.0 if stage == 0 else 4.0), 1.0),
			"rotation": deg_to_rad((-7.0 if stage == 0 else 4.0) * facing_value),
			"scale": Vector2(1.08, 0.94) if stage == 0 else Vector2(0.98, 1.04),
		}
	return {
		"offset": Vector2.ZERO,
		"rotation": 0.0,
		"scale": Vector2.ONE,
	}


func enemy_attack_frame_count(enemy: Dictionary) -> int:
	if is_bone_blade_elite(enemy):
		return 2
	if int(enemy.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.ZOMBIE:
		return 4
	return 2


func _should_hold_idle(enemy: Dictionary, state: String) -> bool:
	return bool(enemy.get("ai_frozen", false)) and state == "NEUTRAL"


func is_human_student_female_appearance_id(appearance_id: int) -> bool:
	return appearance_id >= 1 and appearance_id <= 5


func enemy_visual_facing_right(enemy: Dictionary, action: String) -> bool:
	var state := String(enemy.get("state", ""))
	var facing_value := float(enemy.get("facing", -1.0))
	if action == "attack" or state in ["TELEGRAPH", "HEAVY_TELEGRAPH", "RECOVER", "SPECIAL_TELEGRAPH", "SPECIAL_RUSH", "SPECIAL_RECOVER"]:
		facing_value = float(enemy.get("attack_facing", facing_value))
	return facing_value > 0.0


func is_human_student_archetype(enemy: Dictionary) -> bool:
	return int(enemy.get("family", host.EnemyFamily.HUMAN)) == host.EnemyFamily.HUMAN and String(enemy.get("archetype", enemy.get("id", ""))) == "human_student"


func is_bone_blade_elite(enemy: Dictionary) -> bool:
	return String(enemy.get("archetype", "")) == "bone_blade_twin" or String(enemy.get("ai_profile", "")) == "BONE_BLADE_ELITE"
