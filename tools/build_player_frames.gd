## Baut die SpriteFrames des Helden aus dem Spritesheet.
## Aufruf: godot --headless --script res://tools/build_player_frames.gd
## Sheet-Aufbau: Frames 32x48, Zeilen down/left/right/up, Spalten idle_0, idle_1, walk_0..3.
extends SceneTree

const SHEET := "res://assets/sprites/player/player_placeholder.png"
const OUT := "res://assets/sprites/player/player_frames.tres"
const FRAME := Vector2i(32, 48)
const DIRECTIONS: Array[String] = ["down", "left", "right", "up"]
## Animation -> [erste Spalte, Anzahl Frames, FPS, Schleife]
const ANIMATIONS := {
	"idle": [0, 2, 2.0, true],
	"walk": [2, 4, 8.0, true],
}


func _init() -> void:
	var texture: Texture2D = load(SHEET)
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for anim_name: String in ANIMATIONS:
		var spec: Array = ANIMATIONS[anim_name]
		for row in DIRECTIONS.size():
			var anim := StringName("%s_%s" % [anim_name, DIRECTIONS[row]])
			frames.add_animation(anim)
			frames.set_animation_speed(anim, spec[2])
			frames.set_animation_loop(anim, spec[3])
			for i in spec[1]:
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(Vector2i((spec[0] + i) * FRAME.x, row * FRAME.y), FRAME)
				frames.add_frame(anim, atlas)
	var err := ResourceSaver.save(frames, OUT)
	print("SpriteFrames gespeichert: %s (%s)" % [OUT, error_string(err)])
	quit(0 if err == OK else 1)
