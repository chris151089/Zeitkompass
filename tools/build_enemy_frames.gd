## Baut SpriteFrames für die Gegner aus assets/sprites/enemies/<name>/<anim>.png (64er-Zellen).
## Aufruf: godot --headless --script res://tools/build_enemy_frames.gd
## Blick nach rechts; links wird im Spiel gespiegelt. Fußpunkt (32, 60).
extends SceneTree

const DIR := "res://assets/sprites/enemies/"
const CELL := 64
const ENEMIES: Array[String] = ["orc", "skeleton"]
## Animation -> [FPS, Schleife]
const ANIMATIONS := {"idle": [6.0, true], "run": [10.0, true], "death": [10.0, false]}


func _init() -> void:
	var failed := false
	for enemy in ENEMIES:
		var frames := SpriteFrames.new()
		frames.remove_animation(&"default")
		for anim: String in ANIMATIONS:
			var texture: Texture2D = load(DIR + "%s/%s.png" % [enemy, anim])
			frames.add_animation(anim)
			frames.set_animation_speed(anim, ANIMATIONS[anim][0])
			frames.set_animation_loop(anim, ANIMATIONS[anim][1])
			for i in texture.get_width() / CELL:
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(i * CELL, 0, CELL, CELL)
				frames.add_frame(anim, atlas)
		var out := DIR + "%s/%s_frames.tres" % [enemy, enemy]
		var err := ResourceSaver.save(frames, out)
		print("SpriteFrames gespeichert: %s (%s)" % [out, error_string(err)])
		failed = failed or err != OK
	quit(1 if failed else 0)
