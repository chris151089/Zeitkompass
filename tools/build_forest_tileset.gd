## Baut das Godot-TileSet aus dem Paket „Forest Adventure“ (32x32).
## Aufruf: godot --headless --script res://tools/build_forest_tileset.gd
##
## Quellen (source_id):
##   0 = FA_Environment.png  – Gras, Felsplateaus, Steine
##   1 = FA_Vegetation_Sheet.png – Bäume, Büsche, Blumen (6 Frames Wind-Animation)
## Physik-Ebene 0 = Welt (Kollisionsschicht 1).
extends SceneTree

const BASE := "res://assets/tilesets/forest_adventure/"
const ENVIRONMENT := BASE + "FA_Environment/FA_Environment.png"
const VEGETATION := BASE + "FA_Environment/FA_Vegetation_Sheet.png"
const OUT := BASE + "forest_tileset.tres"
const TILE := 32
const VEGETATION_FRAMES := 6
const VEGETATION_FRAME_COLUMNS := 8  # 256 px pro Frame
const VEGETATION_FPS := 5.0

const SRC_ENVIRONMENT := 0
const SRC_VEGETATION := 1

## Felsplateau + Klippenwand (beide Varianten): volle Kollision
const CLIFF_RECTS: Array[Rect2i] = [Rect2i(7, 0, 4, 8)]

## Einzelne Steine in FA_Environment: Kachel -> Kollisionsrechteck (relativ zur Kachelmitte)
const ROCKS := {
	Vector2i(7, 12): Rect2(-13, -6, 26, 18),
	Vector2i(8, 12): Rect2(-13, -6, 26, 18),
	Vector2i(8, 13): Rect2(-9, -4, 18, 14),
}

## Pflanzen: Name -> [Atlas-Koordinate, Größe in Kacheln, Stammfuß-y im Bild (px ab Oberkante),
##                   Kollisionsrechteck relativ zur Zellmitte oder null]
## Der Stammfuß wird per texture_origin auf die Zelle gelegt, auf der der Baum steht.
const PLANTS := {
	"tree_big": [Vector2i(0, 0), Vector2i(3, 4), 115, Rect2(-14, -2, 30, 14)],
	"tree_round": [Vector2i(3, 1), Vector2i(2, 3), 85, Rect2(-8, -2, 16, 12)],
	"tree_slim": [Vector2i(5, 1), Vector2i(1, 3), 83, Rect2(-5, -2, 10, 10)],
	"pine_big": [Vector2i(0, 4), Vector2i(3, 4), 115, Rect2(-14, -2, 28, 14)],
	"pine_mid": [Vector2i(3, 5), Vector2i(2, 3), 83, Rect2(-8, -2, 16, 12)],
	"bush": [Vector2i(7, 7), Vector2i(1, 1), 30, Rect2(-14, -12, 28, 22)],
	"stump": [Vector2i(7, 9), Vector2i(1, 1), 26, Rect2(-8, -6, 16, 12)],
	"grass_a": [Vector2i(6, 4), Vector2i(1, 1), 30, null],
	"grass_b": [Vector2i(7, 4), Vector2i(1, 1), 30, null],
	"mushrooms_a": [Vector2i(6, 5), Vector2i(1, 1), 28, null],
	"mushrooms_b": [Vector2i(7, 5), Vector2i(1, 1), 28, null],
	"flowers_a": [Vector2i(6, 6), Vector2i(1, 1), 28, null],
	"flowers_b": [Vector2i(7, 6), Vector2i(1, 1), 28, null],
	"fern": [Vector2i(6, 7), Vector2i(1, 1), 28, null],
}


func _init() -> void:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE, TILE)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)
	tileset.set_physics_layer_collision_mask(0, 0)

	# Quellen zuerst einhängen, damit ihre Kacheln die Physik-Ebene kennen.
	var environment := TileSetAtlasSource.new()
	tileset.add_source(environment, SRC_ENVIRONMENT)
	_build_environment(environment)
	var vegetation := TileSetAtlasSource.new()
	tileset.add_source(vegetation, SRC_VEGETATION)
	_build_vegetation(vegetation)

	var err := ResourceSaver.save(tileset, OUT)
	print("TileSet gespeichert: %s (%s)" % [OUT, error_string(err)])
	quit(0 if err == OK else 1)


func _build_environment(src: TileSetAtlasSource) -> void:
	src.texture = load(ENVIRONMENT)
	src.texture_region_size = Vector2i(TILE, TILE)
	var image := Image.load_from_file(ProjectSettings.globalize_path(ENVIRONMENT))
	var grid := image.get_size() / TILE
	for y in grid.y:
		for x in grid.x:
			if not _region_is_empty(image, Rect2i(x * TILE, y * TILE, TILE, TILE)):
				src.create_tile(Vector2i(x, y))
	for r in CLIFF_RECTS:
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				var coords := Vector2i(x, y)
				if src.has_tile(coords):
					_set_collision(src.get_tile_data(coords, 0), Rect2(-16, -16, 32, 32))
	for coords: Vector2i in ROCKS:
		var data := src.get_tile_data(coords, 0)
		_set_collision(data, ROCKS[coords])
		data.y_sort_origin = int(ROCKS[coords].end.y)


func _build_vegetation(src: TileSetAtlasSource) -> void:
	src.texture = load(VEGETATION)
	src.texture_region_size = Vector2i(TILE, TILE)
	for plant_name: String in PLANTS:
		var spec: Array = PLANTS[plant_name]
		var coords: Vector2i = spec[0]
		var size: Vector2i = spec[1]
		src.create_tile(coords, size)
		src.set_tile_animation_columns(coords, 0)
		src.set_tile_animation_separation(coords, Vector2i(VEGETATION_FRAME_COLUMNS - size.x, 0))
		src.set_tile_animation_frames_count(coords, VEGETATION_FRAMES)
		src.set_tile_animation_speed(coords, VEGETATION_FPS)
		var data := src.get_tile_data(coords, 0)
		# Stammfuß (spec[2] px ab Bildoberkante) soll 12 px unter der Zellmitte liegen.
		var foot_from_center: int = spec[2] - size.y * TILE / 2
		data.texture_origin = Vector2i(0, foot_from_center - 12)
		data.y_sort_origin = 12
		if spec[3] != null:
			_set_collision(data, spec[3])


func _set_collision(data: TileData, rect: Rect2) -> void:
	data.add_collision_polygon(0)
	data.set_collision_polygon_points(0, data.get_collision_polygons_count(0) - 1, PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	]))


func _region_is_empty(image: Image, rect: Rect2i) -> bool:
	for y in range(rect.position.y, rect.end.y, 2):
		for x in range(rect.position.x, rect.end.x, 2):
			if image.get_pixel(x, y).a > 0.0:
				return false
	return true
