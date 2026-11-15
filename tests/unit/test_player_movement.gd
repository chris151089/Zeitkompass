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
	for action in [&"move_left", &"move_right", &"move_up", &"move_down", &"sprint"]:
		Input.action_release(action)


func _teleport(pos: Vector2) -> void:
	player.global_position = pos
	player.velocity = Vector2.ZERO
	player.reset_physics_interpolation()


func _hold(action: StringName, seconds: float) -> void:
	Input.action_press(action)
	await wait_seconds(seconds)
	Input.action_release(action)


func test_starts_idle_facing_down() -> void:
	assert_eq(player.state_machine.current_state_name(), &"Idle")
	assert_eq(player.facing, TopDownMotion.Facing.DOWN)


func test_movement_is_direct() -> void:
	# Kaum Anlauf und kein Nachrutschen (wie in klassischen SNES-Action-RPGs)
	Input.action_press(&"move_right")
	await wait_physics_frames(4)
	assert_gte(player.velocity.x, player.movement.max_speed * 0.99, "nach 4 Frames volles Tempo")
	Input.action_release(&"move_right")
	await wait_physics_frames(4)
	assert_eq(player.velocity, Vector2.ZERO, "nach 4 Frames steht er")


func test_walks_right_and_switches_states() -> void:
	var start := player.global_position
	Input.action_press(&"move_right")
	await wait_seconds(0.5)
	assert_eq(player.state_machine.current_state_name(), &"Move")
	assert_eq(player.facing, TopDownMotion.Facing.RIGHT)
	var sprite: AnimatedSprite2D = player.get_node("Sprite")
	assert_eq(sprite.animation, &"walk_right")
	Input.action_release(&"move_right")
	await wait_seconds(0.3)
	assert_eq(player.state_machine.current_state_name(), &"Idle")
	assert_eq(sprite.animation, &"idle_right")
	assert_gt(player.global_position.x, start.x + 20.0, "ist nach rechts gelaufen")
	assert_eq(player.velocity, Vector2.ZERO, "steht wieder")


func test_running_is_faster_than_walking() -> void:
	_teleport(Vector2(120, 300))
	await _hold(&"move_right", 0.6)
	var walked := player.global_position.x - 120.0
	await wait_seconds(0.3)
	_teleport(Vector2(120, 300))
	Input.action_press(&"sprint")
	Input.action_press(&"move_right")
	await wait_seconds(0.3)
	assert_eq(player.state_machine.current_state_name(), &"Run")
	assert_eq(player.get_node("Sprite").animation, &"run_right")
	await wait_seconds(0.3)
	Input.action_release(&"move_right")
	var ran := player.global_position.x - 120.0
	assert_gt(ran, walked * 1.3, "rennt deutlich weiter als er geht (%.0f vs %.0f px)" % [ran, walked])
	Input.action_release(&"sprint")
	await wait_seconds(0.4)
	assert_eq(player.state_machine.current_state_name(), &"Idle")


func test_releasing_sprint_returns_to_walking() -> void:
	_teleport(Vector2(120, 300))
	Input.action_press(&"sprint")
	Input.action_press(&"move_right")
	await wait_seconds(0.2)
	Input.action_release(&"sprint")
	await wait_seconds(0.1)
	assert_eq(player.state_machine.current_state_name(), &"Move")


func test_walking_left_uses_left_animation() -> void:
	_teleport(Vector2(200, 220))
	Input.action_press(&"move_left")
	await wait_seconds(0.3)
	assert_eq(player.get_node("Sprite").animation, &"walk_left")


func test_cliff_wall_blocks() -> void:
	# Plateau in der Mitte: Kacheln x 20–28, Wand blockiert bis Zeile 20 (y < 336)
	_teleport(Vector2(24 * 16, 390))
	await _hold(&"move_up", 1.5)
	assert_gte(player.global_position.y, 336.0, "nicht in die Wand gelaufen")
	assert_lt(player.global_position.y, 350.0, "bis an die Wand gelaufen")


func test_prop_blocks() -> void:
	# Eigener Stein an freier Stelle, Held läuft von unten dagegen
	var rock: Node2D = load("res://levels/props/rock_mid.tscn").instantiate()
	rock.position = Vector2(100, 250)
	level.get_node("World").add_child(rock)
	_teleport(Vector2(100, 300))
	await _hold(&"move_up", 1.0)
	assert_gte(player.global_position.y, 250.0, "nicht durch den Stein")
	assert_lt(player.global_position.y, 262.0, "bis zum Stein gelaufen")


func test_world_bounds_block() -> void:
	_teleport(Vector2(380, 420))
	await _hold(&"move_down", 2.0)
	var bottom: int = level.map_rect().end.y
	assert_lte(player.global_position.y, float(bottom), "nicht aus der Karte gelaufen")


func test_camera_follows_player() -> void:
	_teleport(Vector2(600, 400))
	player.get_node("Camera").snap_to_target()
	await _hold(&"move_right", 1.0)
	await wait_seconds(1.0)
	var cam: Camera2D = player.get_node("Camera")
	assert_almost_eq(cam.get_screen_center_position().x, player.global_position.x, 2.0)
