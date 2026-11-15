extends GutTest
## Echte Physik auf der Testkarte: Laufen, Kollision, Zustände, Animationen.

const LEVEL := preload("res://levels/test/movement_test.tscn")

var level: Node2D
var player: Player


func before_each() -> void:
	level = LEVEL.instantiate()
	add_child_autofree(level)
	player = level.get_node("World/Player")
	await wait_physics_frames(2)


func after_each() -> void:
	for action in [&"move_left", &"move_right", &"move_up", &"move_down"]:
		Input.action_release(action)


func _teleport(pos: Vector2) -> void:
	player.global_position = pos
	player.velocity = Vector2.ZERO


func _hold(action: StringName, seconds: float) -> void:
	Input.action_press(action)
	await wait_seconds(seconds)
	Input.action_release(action)


func test_starts_idle_facing_down() -> void:
	assert_eq(player.state_machine.current_state_name(), &"Idle")
	assert_eq(player.facing, TopDownMotion.Facing.DOWN)


func test_walks_right_and_switches_states() -> void:
	var start := player.global_position
	Input.action_press(&"move_right")
	await wait_seconds(0.5)
	assert_eq(player.state_machine.current_state_name(), &"Move")
	assert_eq(player.facing, TopDownMotion.Facing.RIGHT)
	assert_eq(player.get_node("Sprite").animation, &"walk_right")
	Input.action_release(&"move_right")
	await wait_seconds(0.3)
	assert_eq(player.state_machine.current_state_name(), &"Idle")
	assert_eq(player.get_node("Sprite").animation, &"idle_right")
	assert_gt(player.global_position.x, start.x + 30.0, "ist nach rechts gelaufen")
	assert_eq(player.velocity, Vector2.ZERO, "steht wieder")


func test_cliff_wall_blocks() -> void:
	# links ist eine Felswand (Spalte 0, bis x = 32)
	_teleport(Vector2(80, 368))
	await _hold(&"move_left", 1.0)
	assert_gt(player.global_position.x, 32.0, "nicht in die Wand gelaufen")
	assert_lt(player.global_position.x, 60.0, "bis an die Wand gelaufen")


func test_tree_trunk_blocks() -> void:
	# Großer Baum auf Zelle (4, 7): Stamm-Kollision bei ca. y 238..252
	_teleport(Vector2(145, 320))
	await _hold(&"move_up", 1.0)
	assert_gt(player.global_position.y, 252.0, "steht unter dem Stamm")
	assert_lt(player.global_position.y, 270.0, "ist bis zum Stamm gelaufen")


func test_camera_follows_player() -> void:
	_teleport(Vector2(600, 400))
	player.get_node("Camera").snap_to_target()
	await _hold(&"move_right", 1.0)
	await wait_seconds(1.0)
	var cam: Camera2D = player.get_node("Camera")
	assert_almost_eq(cam.get_screen_center_position().x, player.global_position.x, 2.0)
