## Baut die SpriteFrames des Helden aus den eingekleideten Sheets (tools/build_hero_sprites.py).
## Aufruf: godot --headless --script res://tools/build_hero_frames.gd
## Animationen heißen <aktion>_<down|side|up>; „side“ blickt nach rechts, links = gespiegelt.
extends SceneTree

const DIR := "res://assets/sprites/hero/"
const OUT := "res://assets/sprites/hero/hero_frames.tres"
const FRAME := 64
const DIRECTIONS: Array[String] = ["down", "side", "up"]
## Aktion -> [FPS, Schleife]
const ANIMATIONS := {
	"idle": [6.0, true],
	"walk": [10.0, true],
	"run": [12.0, true],
	"slice": [16.0, false],
	"pierce": [16.0, false],
	"crush": [14.0, false],
	"hit": [12.0, false],
	"death": [10.0, false],
}


func _init() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for action: String in ANIMATIONS:
		for direction in DIRECTIONS:
			var anim := StringName("%s_%s" % [action, direction])
			var texture: Texture2D = load(DIR + "%s.png" % anim)
			frames.add_animation(anim)
			frames.set_animation_speed(anim, ANIMATIONS[action][0])
			frames.set_animation_loop(anim, ANIMATIONS[action][1])
			for i in texture.get_width() / FRAME:
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(i * FRAME, 0, FRAME, FRAME)
				frames.add_frame(anim, atlas)
	var err := ResourceSaver.save(frames, OUT)
	print("SpriteFrames gespeichert: %s (%s)" % [OUT, error_string(err)])
	quit(0 if err == OK else 1)
