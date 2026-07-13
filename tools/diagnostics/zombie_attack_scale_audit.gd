extends SceneTree

const MainScene = preload("res://scenes/red_night.tscn")
const EXPECTED_RATIO := 0.95
const EPSILON := 0.001


func _initialize() -> void:
	var stage = MainScene.instantiate()
	root.add_child(stage)
	await process_frame
	var failures := 0
	var checked := 0
	for appearance_id in range(4):
		for facing in [-1.0, 1.0]:
			var enemy := {
				"id": "zombie_scale_audit_%s" % appearance_id,
				"archetype": "zombie_student",
				"family": stage.EnemyFamily.ZOMBIE,
				"appearance_id": appearance_id,
				"facing": facing,
			}
			var reference: Texture2D = stage.enemy_visual_component.enemy_scale_reference_texture(enemy)
			if reference == null:
				push_error("Missing zombie reference: variant %s facing %s" % [appearance_id, facing])
				failures += 1
				continue
			var reference_height: float = stage.enemy_renderer_component.enemy_texture_visible_region(reference).size.y
			var base_scale: float = stage.enemy_renderer_component.enemy_render_scale(enemy).y
			for frame_index in range(4):
				var attack: Texture2D = stage.enemy_visual_component.current_enemy_action_texture(enemy, "attack", 4, (float(frame_index) + 0.1) / 4.0)
				if attack == null:
					push_error("Missing zombie attack: variant %s facing %s frame %s" % [appearance_id, facing, frame_index])
					failures += 1
					continue
				var attack_height: float = stage.enemy_renderer_component.enemy_texture_visible_region(attack).size.y
				var attack_scale: float = stage.enemy_renderer_component.enemy_render_scale_for_texture(enemy, attack).y
				var rendered_ratio: float = (attack_height * attack_scale) / (reference_height * base_scale)
				checked += 1
				if absf(rendered_ratio - EXPECTED_RATIO) > EPSILON:
					push_error("Zombie scale mismatch: variant %s facing %s frame %s ratio %.4f" % [appearance_id, facing, frame_index, rendered_ratio])
					failures += 1
	stage.queue_free()
	if failures == 0:
		print("PASS: %s zombie attack frames render at %.0f%% of their variant idle height" % [checked, EXPECTED_RATIO * 100.0])
	quit(1 if failures > 0 else 0)
