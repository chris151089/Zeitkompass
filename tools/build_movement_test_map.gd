## Füllt die Testkarte levels/test/movement_test.tscn mit Kacheln.
## Aufruf: godot --headless --script res://tools/build_movement_test_map.gd
##
## Die Karte kann danach im Editor frei weiterbearbeitet werden – dieses Skript
## überschreibt dann aber alle Änderungen an den Kachel-Ebenen.
extends SceneTree

const SCENE := "res://levels/test/movement_test.tscn"
const SRC_ENV := 0
const SRC_VEG := 1
const SIZE := Vector2i(40, 24)

## Erhöhte Felsplateaus ('#'). Unter jedem Plateau entsteht automatisch eine
## 2 Kacheln hohe Klippenwand, die ebenfalls blockiert.
const PLATEAU_RECTS: Array[Rect2i] = [
	Rect2i(0, 0, 40, 2),    # oben
	Rect2i(0, 0, 1, 24),    # links
	Rect2i(39, 0, 1, 24),   # rechts
	Rect2i(0, 23, 40, 1),   # unten
	Rect2i(16, 9, 8, 3),    # Block in der Mitte
	Rect2i(30, 16, 4, 2),   # kleiner Block rechts unten
]

## Grasvarianten (FA_Environment), zufällig gemischt.
const GRASS: Array[Vector2i] = [
	Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1),
	Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2),
]

## Plateau-Oberfläche: Spalte 7 = linker Rand, 8 = Mitte, 9 = rechter Rand,
## 10 = nur 1 Kachel breit; Zeile 0 = oberer Rand, 1 = Mitte, 2 = unterer Rand.
## Klippenwand darunter: Zeilen 3 und 4 (gleiche Spalten).
const CLIFF_LEFT := 7
const CLIFF_MID := 8
const CLIFF_RIGHT := 9
const CLIFF_SINGLE := 10

## Atlas-Koordinaten in FA_Vegetation (müssen zu build_forest_tileset.gd passen)
const PLANT := {
	"tree_big": Vector2i(0, 0), "tree_round": Vector2i(3, 1), "tree_slim": Vector2i(5, 1),
	"pine_big": Vector2i(0, 4), "pine_mid": Vector2i(3, 5), "bush": Vector2i(7, 7),
	"stump": Vector2i(7, 9), "grass_a": Vector2i(6, 4), "grass_b": Vector2i(7, 4),
	"mushrooms_a": Vector2i(6, 5), "mushrooms_b": Vector2i(7, 5),
	"flowers_a": Vector2i(6, 6), "flowers_b": Vector2i(7, 6), "fern": Vector2i(6, 7),
}

## Hindernisse mit Kollision (Ebene Objects, y-sortiert): [Pflanze oder Stein, x, y]
const OBSTACLES := [
	["tree_big", 4, 7], ["pine_big", 36, 6], ["tree_round", 27, 6], ["pine_mid", 6, 18],
	["tree_slim", 13, 19], ["tree_big", 24, 20], ["pine_big", 36, 21], ["tree_round", 9, 13],
	["bush", 8, 5], ["bush", 20, 6], ["bush", 28, 13], ["bush", 12, 16], ["stump", 31, 9],
	["rock_a", 14, 6], ["rock_b", 33, 11], ["rock_small", 21, 17],
]
const ROCK_TILES := {"rock_a": Vector2i(7, 12), "rock_b": Vector2i(8, 12), "rock_small": Vector2i(8, 13)}

## Deko ohne Kollision (Ebene Decor, unter dem Helden)
const DECOR := [
	["flowers_a", 9, 9], ["flowers_a", 18, 19], ["flowers_a", 3, 14], ["flowers_b", 24, 7],
	["flowers_b", 34, 14], ["mushrooms_a", 5, 11], ["mushrooms_b", 29, 21], ["fern", 17, 16],
	["grass_a", 11, 8], ["grass_b", 22, 14], ["grass_a", 31, 5], ["grass_b", 3, 20],
	["grass_a", 26, 16], ["fern", 35, 9],
]


func _init() -> void:
	var root: Node = (load(SCENE) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var ground: TileMapLayer = root.get_node("Ground")
	var decor: TileMapLayer = root.get_node("Decor")
	var cliffs: TileMapLayer = root.get_node("Cliffs")
	var objects: TileMapLayer = root.get_node("World/Objects")
	for layer in [ground, decor, cliffs, objects]:
		layer.clear()

	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	for y in SIZE.y:
		for x in SIZE.x:
			ground.set_cell(Vector2i(x, y), SRC_ENV, GRASS[rng.randi() % GRASS.size()])

	_paint_cliffs(cliffs)

	for entry: Array in OBSTACLES:
		var cell := Vector2i(entry[1], entry[2])
		_assert_free(cliffs, cell, entry[0])
		if ROCK_TILES.has(entry[0]):
			objects.set_cell(cell, SRC_ENV, ROCK_TILES[entry[0]])
		else:
			objects.set_cell(cell, SRC_VEG, PLANT[entry[0]])
	for entry: Array in DECOR:
		var cell := Vector2i(entry[1], entry[2])
		_assert_free(cliffs, cell, entry[0])
		decor.set_cell(cell, SRC_VEG, PLANT[entry[0]])

	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err == OK:
		err = ResourceSaver.save(packed, SCENE)
	print("Testkarte gespeichert: %s (%s)" % [SCENE, error_string(err)])
	root.free()
	quit(0 if err == OK else 1)


func _is_plateau(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.y < 0 or cell.x >= SIZE.x or cell.y >= SIZE.y:
		return true  # außerhalb der Karte gilt als Fels
	for r in PLATEAU_RECTS:
		if r.has_point(cell):
			return true
	return false


## 0 = keine Wand, 1 = obere Wandreihe, 2 = untere Wandreihe
func _wall_row(cell: Vector2i) -> int:
	if _is_plateau(cell):
		return 0
	if _is_plateau(cell + Vector2i.UP):
		return 1
	if _is_plateau(cell + Vector2i.UP * 2) and not _is_plateau(cell + Vector2i.UP):
		return 2
	return 0


func _paint_cliffs(cliffs: TileMapLayer) -> void:
	for y in SIZE.y:
		for x in SIZE.x:
			var cell := Vector2i(x, y)
			if _is_plateau(cell):
				var col := _edge_column(
					not _is_plateau(cell + Vector2i.LEFT), not _is_plateau(cell + Vector2i.RIGHT)
				)
				var row := 1
				if not _is_plateau(cell + Vector2i.UP):
					row = 0
				elif not _is_plateau(cell + Vector2i.DOWN):
					row = 2
				cliffs.set_cell(cell, SRC_ENV, Vector2i(col, row))
				continue
			var wall := _wall_row(cell)
			if wall == 0:
				continue
			var col := _edge_column(
				_wall_row(cell + Vector2i.LEFT) != wall, _wall_row(cell + Vector2i.RIGHT) != wall
			)
			cliffs.set_cell(cell, SRC_ENV, Vector2i(col, 2 + wall))


func _edge_column(open_left: bool, open_right: bool) -> int:
	if open_left and open_right:
		return CLIFF_SINGLE
	if open_left:
		return CLIFF_LEFT
	if open_right:
		return CLIFF_RIGHT
	return CLIFF_MID


func _assert_free(cliffs: TileMapLayer, cell: Vector2i, what: String) -> void:
	if cliffs.get_cell_source_id(cell) != -1:
		push_error("%s bei %s liegt auf Fels/Klippe" % [what, cell])
