## Füllt die Testkarte levels/test/movement_test.tscn mit Kacheln und Props.
## Aufruf: godot --headless --script res://tools/build_movement_test_map.gd
##
## Achtung: überschreibt alle Änderungen an Kacheln und Props der Testkarte.
extends SceneTree

const SCENE := "res://levels/test/movement_test.tscn"
const PROPS := "res://levels/props/"
const SIZE := Vector2i(48, 30)  # Kacheln (16 px) -> 768 x 480 px

const SRC_FLOOR := 0
const SRC_WALL := 1
const SRC_VEG := 2

## Gras (Floors_Tiles), zufällig gemischt. Zeile 11 ist dunkler (Schattengras) – nicht mischen.
const GRASS: Array[Vector2i] = [Vector2i(1, 10), Vector2i(2, 10), Vector2i(3, 10)]

## Klippen als gestreckte Blöcke: [Spalte, Zeile, Breite, Höhe (mind. 10), Farbe 0/6/12]
## Zeilen: oben 0–1 Rand, 2–3 werden wiederholt, letzte 6 = Oberflächenrand + Wand + Grasrand.
const CLIFFS := [
	[-1, -4, 50, 12, 0],   # Felswand am oberen Kartenrand (sichtbar ab Zeile 0)
	[20, 12, 9, 10, 0],    # Plateau in der Mitte
	[35, 18, 6, 10, 6],    # graues Plateau rechts unten
]

## Props: [Szene, x, y] in Pixeln (Fuß)
const PROP_LIST := [
	["tree_oak", 72, 170], ["tree_oak_yellow", 250, 150], ["tree_oak_orange", 600, 170],
	["pine", 470, 140], ["pine_light", 690, 250], ["pine_slim", 300, 300],
	["tree_dead", 180, 400], ["bush_small", 200, 180], ["bush_wide", 520, 230],
	["bush_big", 120, 300], ["bush_small", 530, 440], ["rock_big", 400, 420],
	["rock_mid", 260, 350], ["rock_small", 360, 210], ["rock_small", 230, 260],
	["pine", 40, 460], ["pine_light", 730, 460], ["tree_oak", 520, 470],
]

## Waldrand links/rechts/unten (rein optisch, die Kartenränder blockieren ohnehin)
const BORDER_STEP := 28

## Deko-Kacheln (Vegetation): Blumen und Sprossen
const DECOR_TILES: Array[Vector2i] = [
	Vector2i(3, 23), Vector2i(3, 24), Vector2i(3, 25), Vector2i(3, 26), Vector2i(6, 24),
	Vector2i(6, 26), Vector2i(1, 9), Vector2i(2, 9), Vector2i(2, 12), Vector2i(1, 13),
]
const DECOR_COUNT := 60


func _init() -> void:
	var root: Node = (load(SCENE) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var ground: TileMapLayer = root.get_node("Ground")
	var decor: TileMapLayer = root.get_node("Decor")
	var cliffs: TileMapLayer = root.get_node("Cliffs")
	var world: Node2D = root.get_node("World")
	for layer in [ground, decor, cliffs]:
		layer.clear()
	for child in world.get_children():
		if child.name != "Player":
			world.remove_child(child)
			child.free()

	var rng := RandomNumberGenerator.new()
	rng.seed = 1607
	for y in SIZE.y:
		for x in SIZE.x:
			ground.set_cell(Vector2i(x, y), SRC_FLOOR, GRASS[rng.randi() % GRASS.size()])

	for c: Array in CLIFFS:
		_stamp_cliff(cliffs, Vector2i(c[0], c[1]), Vector2i(c[2], c[3]), c[4])

	var placed := 0
	while placed < DECOR_COUNT:
		var cell := Vector2i(rng.randi_range(1, SIZE.x - 2), rng.randi_range(8, SIZE.y - 2))
		if cliffs.get_cell_source_id(cell) != -1 or decor.get_cell_source_id(cell) != -1:
			continue
		decor.set_cell(cell, SRC_VEG, DECOR_TILES[rng.randi() % DECOR_TILES.size()])
		placed += 1

	for p: Array in PROP_LIST:
		_add_prop(root, world, p[0], Vector2(p[1], p[2]))
	var w := SIZE.x * 16
	var h := SIZE.y * 16
	for x in range(-6, w + 6, BORDER_STEP):
		_add_prop(root, world, "pine" if (x / BORDER_STEP) % 2 == 0 else "pine_light", Vector2(x, h + 6))
	for y in range(150, h, BORDER_STEP):
		_add_prop(root, world, "pine", Vector2(-8, y))
		_add_prop(root, world, "pine_light", Vector2(w + 8, y))

	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err == OK:
		err = ResourceSaver.save(packed, SCENE)
	print("Testkarte gespeichert: %s (%s)" % [SCENE, error_string(err)])
	root.free()
	quit(0 if err == OK else 1)


func _add_prop(root: Node, world: Node2D, scene_name: String, pos: Vector2) -> void:
	var prop: Node2D = (load(PROPS + scene_name + ".tscn") as PackedScene).instantiate(
		PackedScene.GEN_EDIT_STATE_INSTANCE
	)
	prop.position = pos
	world.add_child(prop, true)
	prop.owner = root


## Setzt einen Klippenblock beliebiger Größe aus dem 6x10-Vorbild in Wall_Tiles zusammen.
func _stamp_cliff(layer: TileMapLayer, origin: Vector2i, size: Vector2i, color_col: int) -> void:
	var src: TileSetAtlasSource = layer.tile_set.get_source(SRC_WALL)
	for j in size.y:
		var row := j
		if j >= size.y - 6:
			row = 4 + (j - (size.y - 6))
		elif j >= 2:
			row = 2 + (j - 2) % 2
		for i in size.x:
			var col := i
			if i >= size.x - 2:
				col = 4 + (i - (size.x - 2))
			elif i >= 2:
				col = 2 + (i - 2) % 2
			var atlas := Vector2i(color_col + col, row)
			if src.has_tile(atlas):
				layer.set_cell(origin + Vector2i(i, j), SRC_WALL, atlas)
