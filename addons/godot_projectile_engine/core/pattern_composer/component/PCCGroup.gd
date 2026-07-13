## Projectile Pattern Component
@icon("uid://cy7d1ahfwwkll")
extends PatternComposerComponent
class_name PCCGroup


func process_pattern(pattern_composer_pack: Array[PatternComposerData]) -> Array:
	var _new_pattern_composer_pack : Array[PatternComposerData] = []
	for pattern_data : PatternComposerData in pattern_composer_pack:
		var _sub_pattern_composer_pack : Array[PatternComposerData] = [pattern_data]

		for pattern_component in get_children():
			if not (pattern_component is PatternComposerComponent):
				continue
			if not pattern_component.active:
				continue
			_sub_pattern_composer_pack = pattern_component.process_pattern(_sub_pattern_composer_pack)

		_new_pattern_composer_pack.append_array(_sub_pattern_composer_pack)
	return _new_pattern_composer_pack
