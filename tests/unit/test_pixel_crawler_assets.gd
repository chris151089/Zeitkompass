extends GutTest
## TileSet und Props aus „Pixel Crawler“.

const TILESET := preload("res://assets/tilesets/pixel_crawler_tileset.tres")
const PROP_DIR := "res://levels/props/"


func _collisions(source_id: int, coords: Vector2i) -> int:
	var src: TileSetAtlasSource = TILESET.get_source(source_id)
	return src.get_tile_data(coords, 0).get_collision_polygons_count(0)


func test_tile_size_is_16() -> void:
	assert_eq(TILESET.tile_size, Vector2i(16, 16))


func test_cliff_blocks_but_grass_fringe_does_not() -> void:
	assert_eq(_collisions(1, Vector2i(2, 2)), 1, "Plateau-Oberfläche")
	assert_eq(_collisions(1, Vector2i(2, 6)), 1, "Felswand")
	assert_eq(_collisions(1, Vector2i(2, 8)), 1, "unterste Wandreihe")
	assert_eq(_collisions(1, Vector2i(2, 9)), 0, "Grasrand")


func test_floor_and_decor_do_not_block() -> void:
	assert_eq(_collisions(0, Vector2i(2, 10)), 0, "Gras")
	assert_eq(_collisions(2, Vector2i(3, 24)), 0, "Blume")


func test_every_prop_has_sprite_above_its_foot() -> void:
	for file in DirAccess.get_files_at(PROP_DIR):
		if not file.ends_with(".tscn"):
			continue
		var prop: Node2D = load(PROP_DIR + file).instantiate()
		var sprite: Sprite2D = prop.get_node("Sprite")
		assert_lt(sprite.offset.y + sprite.region_rect.size.y, 8.0, "%s: Bild endet am Fuß" % file)
		assert_true(prop.has_node("Collision"), "%s: hat Kollision" % file)
		prop.free()

