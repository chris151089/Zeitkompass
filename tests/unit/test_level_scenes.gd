extends GutTest
## Die Testkarten haben ihr Level-Skript und die erwarteten Bausteine.

const SCENES := ["res://levels/test/movement_test.tscn", "res://levels/test/combat_test.tscn"]


func test_levels_have_level_script() -> void:
	for path in SCENES:
		var level: Node = load(path).instantiate()
		assert_not_null(level.get_script(), "%s hat ein Skript" % path)
		assert_true(level.has_method("map_rect"), "%s: Level-Skript test_level.gd" % path)
		level.free()


func test_combat_arena_has_enemies_hud_and_game_over() -> void:
	var level: Node = load("res://levels/test/combat_test.tscn").instantiate()
	var enemies := level.get_node("World").get_children().filter(func(n: Node) -> bool: return n is Enemy)
	assert_gte(enemies.size(), 4, "mehrere Gegner")
	var kinds := {}
	for e: Enemy in enemies:
		kinds[e.data.display_name] = true
	assert_eq(kinds.size(), 2, "zwei Gegnertypen")
	assert_true(level.has_node("HUD"))
	assert_true(level.has_node("GameOver"))
	level.free()
