extends GutTest
## Gegner-KI: Verfolgen, Ausholen (Vorwarnung), Angriff, Treffer, Tod.

const LEVEL := preload("res://levels/test/movement_test.tscn")
const ORC := preload("res://actors/enemies/orc.tscn")
const SKELETON := preload("res://actors/enemies/skeleton.tscn")

var level: Node2D
var player: Player
var states_seen: Array[StringName] = []


func before_each() -> void:
	HitFeedback.reset()
	states_seen.clear()
	level = LEVEL.instantiate()
	add_child_autofree(level)
	player = level.get_node("World/Player")
	player.global_position = Vector2(200, 230)
	player.reset_physics_interpolation()
	await wait_physics_frames(2)


func after_each() -> void:
	HitFeedback.reset()


func _spawn(scene: PackedScene, offset: Vector2) -> Enemy:
	var e: Enemy = scene.instantiate()
	e.position = player.global_position + offset
	level.get_node("World").add_child(e)
	e.state_machine.state_changed.connect(func(_from: StringName, to: StringName) -> void: states_seen.append(to))
	return e


func test_orc_chases_winds_up_and_hits_player() -> void:
	var orc := _spawn(ORC, Vector2(70, 0))
	await wait_seconds(3.0)
	assert_has(states_seen, &"Chase")
	assert_has(states_seen, &"Windup")
	assert_has(states_seen, &"Attack")
	assert_lt(player.health.current, player.combat.max_health, "Kael wurde getroffen")
	assert_true(is_instance_valid(orc))


func test_windup_glows_red_as_warning() -> void:
	var orc := _spawn(ORC, Vector2(26, 0))
	var max_glow := 0.0
	for i in 60:
		await wait_physics_frames(1)
		if orc.state_machine.current_state_name() == &"Windup":
			var m := orc.sprite.material as ShaderMaterial
			max_glow = maxf(max_glow, float(m.get_shader_parameter(&"flash")))
	assert_gt(max_glow, 0.3, "sichtbares Aufleuchten vor dem Angriff")


func test_skeleton_circles_before_attacking() -> void:
	_spawn(SKELETON, Vector2(80, 0))
	await wait_seconds(3.0)
	assert_has(states_seen, &"Strafe")
	var strafe_at := states_seen.find(&"Strafe")
	assert_gt(states_seen.find(&"Windup", strafe_at), strafe_at, "erst umkreisen, dann ausholen")


func test_enemy_ignores_player_out_of_sight() -> void:
	var orc := _spawn(ORC, Vector2(300, 150))
	await wait_seconds(0.5)
	assert_eq(orc.state_machine.current_state_name(), &"Idle")


func test_hit_enemy_is_knocked_back_and_dies_at_zero() -> void:
	var skel := _spawn(SKELETON, Vector2(100, 100))
	watch_signals(skel)
	var start := skel.global_position
	skel.hurtbox.receive(DamageInfo.create(1, Vector2(200, 0)))
	assert_eq(skel.state_machine.current_state_name(), &"Hurt")
	await wait_seconds(0.25)
	assert_gt(skel.global_position.x, start.x + 5.0, "zurückgeschleudert")
	skel.hurtbox.receive(DamageInfo.create(99, Vector2.ZERO))
	assert_eq(skel.state_machine.current_state_name(), &"Dead")
	assert_signal_emitted(skel, "died")
	await wait_seconds(2.5)
	assert_false(is_instance_valid(skel), "nach Todesanimation, Blinken und Staubwolke entfernt")


func test_enemies_stop_when_player_is_dead() -> void:
	var orc := _spawn(ORC, Vector2(60, 0))
	player.hurtbox.receive(DamageInfo.create(99, Vector2.ZERO))
	await wait_seconds(1.0)
	assert_eq(orc.state_machine.current_state_name(), &"Idle")
