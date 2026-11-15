## Globaler Spielstand zur Laufzeit (Flags, Fortschritt, Werte des Helden).
## Wird ab M4 befüllt; Speichern übernimmt SaveManager.
extends Node

signal flag_changed(flag: StringName, value: Variant)

var _flags: Dictionary = {}


func set_flag(flag: StringName, value: Variant = true) -> void:
	if _flags.get(flag) == value:
		return
	_flags[flag] = value
	flag_changed.emit(flag, value)


func get_flag(flag: StringName, default: Variant = false) -> Variant:
	return _flags.get(flag, default)


func reset() -> void:
	_flags.clear()
