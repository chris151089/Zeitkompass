extends GutTest
## Das TileSet aus dem Forest-Adventure-Paket: Kollisionen an den richtigen Kacheln.

const TILESET := preload("res://assets/tilesets/forest_adventure/forest_tileset.tres")


func _collision_count(source_id: int, coords: Vector2i) -> int:
	var src: TileSetAtlasSource = TILESET.get_source(source_id)
	return src.get_tile_data(coords, 0).get_collision_polygons_count(0)


func test_tile_size_is_32() -> void:
	assert_eq(TILESET.tile_size, Vector2i(32, 32))


func test_cliffs_block() -> void:
	for coords in [Vector2i(7, 0), Vector2i(8, 1), Vector2i(9, 2), Vector2i(10, 1), Vector2i(8, 3), Vector2i(8, 4)]:
		assert_eq(_collision_count(0, coords), 1, "Klippe %s" % coords)


func test_grass_does_not_block() -> void:
	assert_eq(_collision_count(0, Vector2i(5, 1)), 0)


func test_trees_block_but_flowers_do_not() -> void:
	assert_eq(_collision_count(1, Vector2i(0, 0)), 1, "großer Baum")
	assert_eq(_collision_count(1, Vector2i(7, 7)), 1, "Busch")
	assert_eq(_collision_count(1, Vector2i(6, 6)), 0, "Blumen")


func test_vegetation_is_animated() -> void:
	var src: TileSetAtlasSource = TILESET.get_source(1)
	assert_eq(src.get_tile_animation_frames_count(Vector2i(0, 0)), 6)
