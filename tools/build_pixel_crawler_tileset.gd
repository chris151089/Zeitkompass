## Baut das TileSet aus „Pixel Crawler“ (16x16).
## Aufruf: godot --headless --script res://tools/build_pixel_crawler_tileset.gd
##
## Quellen (source_id):
##   0 = Floors_Tiles.png – Gras, Erde, Stein, Sand, Schnee
##   1 = Wall_Tiles.png   – Klippen (braun / grau / dunkel), Holzwände
##   2 = Vegetation.png   – Blumen, Sprossen, Gras als Deko (ohne Kollision)
## Physik-Ebene 0 = Welt (Kollisionsschicht 1).
extends SceneTree

const BASE := "res://assets/packs/pixel_crawler/Environment/"
const OUT := "res://assets/tilesets/pixel_crawler_tileset.tres"
const TILE := 16

const SOURCES := {
	0: BASE + "Tilesets/Floors_Tiles.png",
	1: BASE + "Tilesets/Wall_Tiles.png",
	2: BASE + "Props/Static/Vegetation.png",
}

## Klippenblöcke in Wall_Tiles: je 6 Spalten breit (braun 0–5, grau 6–11, dunkel 12–17).
## Zeilen 0–8 blockieren (Oberfläche + Wand + unterste Wandreihe), Zeile 9 ist der Grasrand.
## Zeilen 10/12/14 sind alternative unterste Wandreihen (Schnee/ohne Boden) und blockieren auch.
const CLIFF_COLUMNS := 18
const CLIFF_BLOCKING_ROWS: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14]
## Holzwände (Zeilen 16–18) blockieren ebenfalls.
const WOOD_WALL_ROWS: Array[int] = [16, 17, 18]


func _init() -> void:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE, TILE)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)
	tileset.set_physics_layer_collision_mask(0, 0)

	for id: int in SOURCES:
		var src := TileSetAtlasSource.new()
		tileset.add_source(src, id)  # vor dem Anlegen der Kacheln, damit sie die Physik-Ebene kennen
		_fill_source(src, SOURCES[id])

	var walls: TileSetAtlasSource = tileset.get_source(1)
	for y in CLIFF_BLOCKING_ROWS + WOOD_WALL_ROWS:
		for x in CLIFF_COLUMNS:
			var coords := Vector2i(x, y)
			if walls.has_tile(coords):
				_set_full_collision(walls.get_tile_data(coords, 0))

	var err := ResourceSaver.save(tileset, OUT)
	print("TileSet gespeichert: %s (%s)" % [OUT, error_string(err)])
	quit(0 if err == OK else 1)


## Legt für jede nicht leere 16x16-Zelle eine Kachel an.
func _fill_source(src: TileSetAtlasSource, path: String) -> void:
	src.texture = load(path)
	src.texture_region_size = Vector2i(TILE, TILE)
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	var grid := image.get_size() / TILE
	for y in grid.y:
		for x in grid.x:
			if not image.get_region(Rect2i(x * TILE, y * TILE, TILE, TILE)).is_invisible():
				src.create_tile(Vector2i(x, y))


func _set_full_collision(data: TileData) -> void:
	var h := TILE / 2.0
	data.add_collision_polygon(0)
	data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h),
	]))
