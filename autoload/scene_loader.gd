## Zentraler Szenenwechsel. Szenen rufen nie direkt change_scene_to_file() auf,
## damit Übergänge (Abblenden, Laden) später an einer Stelle hinzukommen.
extends Node

signal scene_change_started(path: String)
signal scene_changed(path: String)


func change_scene(path: String) -> void:
	scene_change_started.emit(path)
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("Szenenwechsel nach %s fehlgeschlagen: %s" % [path, error_string(err)])
		return
	# change_scene_to_file wechselt erst am Ende des Frames.
	await get_tree().process_frame
	scene_changed.emit(path)
