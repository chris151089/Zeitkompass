## Baut die SpriteFrames des Helden aus assets/sprites/hero/hero_sheet.json + .png.
## Aufruf: godot --headless --script res://tools/build_hero_frames.gd
##
## Animationen heißen <aktion>_<down|left|right|up> (z. B. walk_left). Die Frame-Dauern
## stammen aus der JSON (duration_ms). hit_active/invulnerable bleiben in der JSON und
## werden in M2 vom Kampfsystem gelesen (HeroSheet.frame_flags()).
extends SceneTree

const JSON_PATH := "res://assets/sprites/hero/hero_sheet.json"
const OUT := "res://assets/sprites/hero/hero_frames.tres"
## Basistakt: 1 Frame-„Einheit“ = 10 ms, Frame-Dauer = duration_ms / 10.
const BASE_FPS := 100.0


func _init() -> void:
	var sheet: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(JSON_PATH))
	var texture: Texture2D = load(JSON_PATH.get_base_dir().path_join(sheet.image))
	var cell := Vector2(sheet.cell_width, sheet.cell_height)
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for action: String in sheet.animations:
		var spec: Dictionary = sheet.animations[action]
		for direction: String in sheet.rows:
			var anim := StringName("%s_%s" % [action, direction])
			frames.add_animation(anim)
			frames.set_animation_speed(anim, BASE_FPS)
			frames.set_animation_loop(anim, spec.loop)
			for f: Dictionary in spec.frames:
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(Vector2(f.column, sheet.rows[direction]) * cell, cell)
				frames.add_frame(anim, atlas, f.duration_ms / 10.0)
	var err := ResourceSaver.save(frames, OUT)
	print("SpriteFrames gespeichert: %s (%s)" % [OUT, error_string(err)])
	quit(0 if err == OK else 1)
