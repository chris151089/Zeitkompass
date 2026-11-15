## Liest hero_sheet.json: welche Frames treffen (hit_active) und welche unverwundbar machen.
## Die JSON ist die gemeinsame Quelle für Animation (build_hero_frames.gd) und Kampf.
class_name HeroSheet
extends RefCounted

const PATH := "res://assets/sprites/hero/hero_sheet.json"

static var _data: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty():
		_data = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return _data


static func _frame(action: String, index: int) -> Dictionary:
	var anims: Dictionary = data().animations
	if not anims.has(action):
		return {}
	var frames: Array = anims[action].frames
	if index < 0 or index >= frames.size():
		return {}
	return frames[index]


static func is_hit_active(action: String, index: int) -> bool:
	return _frame(action, index).get("hit_active", false)


static func is_invulnerable(action: String, index: int) -> bool:
	return _frame(action, index).get("invulnerable", false)


static func frame_count(action: String) -> int:
	return data().animations[action].frames.size()
