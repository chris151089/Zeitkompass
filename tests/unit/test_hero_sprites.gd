extends GutTest
## Held-Sprites: SpriteFrames müssen exakt zur Beschreibung in hero_sheet.json passen.

const JSON_PATH := "res://assets/sprites/hero/hero_sheet.json"
const FRAMES := preload("res://assets/sprites/hero/hero_frames.tres")

var sheet: Dictionary


func before_all() -> void:
	sheet = JSON.parse_string(FileAccess.get_file_as_string(JSON_PATH))


func test_all_actions_exist_in_four_directions() -> void:
	for action in ["idle", "walk", "combo", "sprint", "jump", "roll"]:
		for dir in ["down", "left", "right", "up"]:
			assert_true(FRAMES.has_animation(StringName("%s_%s" % [action, dir])), "%s_%s" % [action, dir])


func test_frame_counts_and_durations_match_json() -> void:
	for action: String in sheet.animations:
		var spec: Dictionary = sheet.animations[action]
		var anim := StringName(action + "_down")
		assert_eq(FRAMES.get_frame_count(anim), spec.frames.size(), "%s: Anzahl" % action)
		assert_eq(FRAMES.get_animation_loop(anim), spec.loop, "%s: Schleife" % action)
		for i in spec.frames.size():
			var seconds := FRAMES.get_frame_duration(anim, i) / FRAMES.get_animation_speed(anim)
			assert_almost_eq(seconds * 1000.0, float(spec.frames[i].duration_ms), 0.01, "%s Frame %d" % [action, i])


func test_run_loops_the_sprint_windup_frames() -> void:
	for dir in ["down", "left", "right", "up"]:
		var anim := StringName("run_" + dir)
		assert_true(FRAMES.has_animation(anim), String(anim))
		assert_eq(FRAMES.get_frame_count(anim), 2)
		assert_true(FRAMES.get_animation_loop(anim))
	var first: AtlasTexture = FRAMES.get_frame_texture(&"run_right", 0)
	assert_eq(int(first.region.position.x) / 64, int(sheet.animations.sprint.frames[0].column))


func test_frames_use_correct_sheet_cells() -> void:
	var atlas: AtlasTexture = FRAMES.get_frame_texture(&"walk_up", 2)
	var col: int = sheet.animations.walk.frames[2].column
	assert_eq(atlas.region, Rect2(col * 64, sheet.rows.up * 64, 64, 64))


func test_sprite_is_anchored_at_feet() -> void:
	var player: Node2D = load("res://actors/player/player.tscn").instantiate()
	var sprite: AnimatedSprite2D = player.get_node("Sprite")
	# zentriertes 64er-Bild: Bildmitte (32) + Versatz = Fußpunkt der JSON liegt im Ursprung
	assert_eq(sprite.position.y, 32.0 - sheet.anchor.y)
	assert_eq(sprite.position.x, 32.0 - sheet.anchor.x)
	player.free()
