## Erzeugt Prop-Szenen (Bäume, Büsche, Steine) aus „Pixel Crawler“ nach levels/props/.
## Aufruf: godot --headless --script res://tools/build_props.gd
##
## Jedes Prop ist ein StaticBody2D mit Ursprung am Fuß (für Y-Sortierung) und einer
## kleinen Kollision am Stamm/Sockel. Im Editor einfach in den Knoten „World“ ziehen.
extends SceneTree

const STATIC := "res://assets/packs/pixel_crawler/Environment/Props/Static/"
const OUT_DIR := "res://levels/props/"

## Name -> [Bild, Zelle im Bild (Rect2i), Kollisionsgröße (Vector2, ZERO = keine)]
## Der genaue Bildbereich wird aus den nicht transparenten Pixeln der Zelle ermittelt.
const PROPS := {
	"tree_oak": ["Trees/Model_01/Size_03.png", Rect2i(0, 0, 48, 96), Vector2(10, 5)],
	"tree_oak_yellow": ["Trees/Model_01/Size_03.png", Rect2i(48, 0, 48, 96), Vector2(10, 5)],
	"tree_oak_orange": ["Trees/Model_01/Size_03.png", Rect2i(0, 96, 48, 96), Vector2(10, 5)],
	"tree_dead": ["Trees/Model_01/Size_03.png", Rect2i(96, 0, 48, 96), Vector2(6, 4)],
	"pine": ["Trees/Model_02/Size_03.png", Rect2i(0, 0, 46, 82), Vector2(8, 5)],
	"pine_light": ["Trees/Model_02/Size_03.png", Rect2i(48, 0, 46, 82), Vector2(8, 5)],
	"pine_slim": ["Trees/Model_03/Size_02.png", Rect2i(0, 0, 31, 82), Vector2(6, 4)],
	"bush_small": ["Vegetation.png", Rect2i(0, 0, 34, 32), Vector2(20, 8)],
	"bush_wide": ["Vegetation.png", Rect2i(194, 0, 44, 42), Vector2(28, 9)],
	"bush_big": ["Vegetation.png", Rect2i(0, 96, 48, 48), Vector2(32, 10)],
	"rock_big": ["Rocks.png", Rect2i(0, 16, 32, 48), Vector2(22, 8)],
	"rock_mid": ["Rocks.png", Rect2i(33, 16, 30, 30), Vector2(20, 8)],
	"rock_small": ["Rocks.png", Rect2i(64, 16, 15, 14), Vector2(10, 5)],
}

## Der Fuß liegt so viele Pixel über der Unterkante des Bildes.
const FOOT_INSET := 2


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var failed := false
	for prop_name: String in PROPS:
		if _build(prop_name, PROPS[prop_name]) != OK:
			failed = true
	print("Props gespeichert in %s" % OUT_DIR)
	quit(1 if failed else 0)


func _build(prop_name: String, spec: Array) -> Error:
	var path: String = STATIC + spec[0]
	var cell: Rect2i = spec[1]
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	var used := image.get_region(cell).get_used_rect()
	var region := Rect2i(cell.position + used.position, used.size)

	var root := StaticBody2D.new()
	root.name = prop_name.to_pascal_case()
	root.collision_layer = 1
	root.collision_mask = 0

	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = load(path)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(region)
	sprite.centered = false
	sprite.offset = Vector2(-floori(region.size.x / 2.0), -region.size.y + FOOT_INSET)
	root.add_child(sprite)
	sprite.owner = root

	var foot: Vector2 = spec[2]
	if foot != Vector2.ZERO:
		var shape := RectangleShape2D.new()
		shape.size = foot
		var collision := CollisionShape2D.new()
		collision.name = "Collision"
		collision.shape = shape
		collision.position = Vector2(0, -foot.y / 2.0)
		root.add_child(collision)
		collision.owner = root

	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err == OK:
		err = ResourceSaver.save(packed, OUT_DIR + prop_name + ".tscn")
	root.free()
	if err != OK:
		push_error("%s: %s" % [prop_name, error_string(err)])
	return err
