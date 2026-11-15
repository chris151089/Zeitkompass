extends GutTest
## Kael im Kampf: Combo, Sprint- und Sprungangriff, Rolle mit I-Frames, Treffer, Tod.

const LEVEL := preload("res://levels/test/movement_test.tscn")
const ORC := preload("res://actors/enemies/orc.tscn")

var level: Node2D
var player: Player
var dummy: Enemy


func before_each() -> void:
	HitFeedback.reset()
	level = LEVEL.instantiate()
	add_child_autofree(level)
	player = level.get_node("World/Player")
	player.global_position = Vector2(200, 230)
	player.reset_physics_interpolation()
	await wait_physics_frames(2)


func after_each() -> void:
	for action in [&"attack", &"dodge", &"jump", &"sprint", &"move_right", &"move_left"]:
		Input.action_release(action)
	HitFeedback.reset()


## Ein Ork, der nicht reagiert und sich nicht wegschieben lässt.
func _spawn_dummy(offset: Vector2) -> Enemy:
	var e: Enemy = ORC.instantiate()
	var data: EnemyData = e.data.duplicate(true)
	data.sight_range = 0.0
	data.knockback_resistance = 1.0
	e.data = data
	e.position = player.global_position + offset
	level.get_node("World").add_child(e)
	return e


func _tap(action: StringName) -> void:
	Input.action_press(action)
	await wait_physics_frames(2)
	Input.action_release(action)


func _face_right() -> void:
	player.update_facing(Vector2.RIGHT)


func test_single_attack_hits_enemy_in_front() -> void:
	dummy = _spawn_dummy(Vector2(16, 0))
	_face_right()
	await _tap(&"attack")
	assert_eq(player.state_machine.current_state_name(), &"Attack")
	await wait_seconds(0.5)
	assert_eq(dummy.health.current, dummy.data.max_health - player.combat.combo[0].damage)
	assert_eq(player.state_machine.current_state_name(), &"Idle", "nach einem Schlag zurück")


func test_three_hit_combo() -> void:
	dummy = _spawn_dummy(Vector2(16, 0))
	_face_right()
	var attack_state = player.get_node("StateMachine/Attack")
	for i in 3:
		await _tap(&"attack")
		await wait_seconds(0.1)
	await wait_seconds(0.6)
	assert_eq(attack_state.last_hit_index, 2, "dritter Schlag erreicht")
	var total := 0
	for a in player.combat.combo:
		total += a.damage
	assert_eq(dummy.health.current, dummy.data.max_health - total, "alle drei Schläge getroffen")


func test_enemy_behind_is_not_hit() -> void:
	dummy = _spawn_dummy(Vector2(-16, 0))
	_face_right()
	await _tap(&"attack")
	await wait_seconds(0.5)
	assert_eq(dummy.health.current, dummy.data.max_health)


func test_sprint_attack_from_running() -> void:
	Input.action_press(&"sprint")
	Input.action_press(&"move_right")
	await wait_seconds(0.25)
	assert_eq(player.state_machine.current_state_name(), &"Run")
	dummy = _spawn_dummy(Vector2(30, 0))
	await _tap(&"attack")
	assert_eq(player.state_machine.current_state_name(), &"SprintAttack")
	await wait_seconds(0.5)
	assert_eq(dummy.health.current, dummy.data.max_health - player.combat.sprint_attack.damage)


func test_jump_attack_hits() -> void:
	dummy = _spawn_dummy(Vector2(22, 0))
	_face_right()
	await _tap(&"jump")
	assert_eq(player.state_machine.current_state_name(), &"JumpAttack")
	await wait_seconds(0.6)
	assert_eq(dummy.health.current, dummy.data.max_health - player.combat.jump_attack.damage)


func test_roll_has_invulnerability_frames() -> void:
	_face_right()
	var start := player.global_position
	await _tap(&"dodge")
	assert_eq(player.state_machine.current_state_name(), &"Roll")
	var was_invulnerable := false
	for i in 30:
		await wait_physics_frames(1)
		was_invulnerable = was_invulnerable or player.is_invulnerable()
	assert_true(was_invulnerable, "während der Rolle unverwundbar")
	await wait_seconds(0.3)
	assert_false(player.is_invulnerable(), "danach wieder verwundbar")
	assert_gt(player.global_position.x, start.x + 20.0, "Rolle bewegt nach vorn")


func test_getting_hit_hurts_knocks_back_and_protects() -> void:
	var start := player.global_position
	assert_true(player.hurtbox.receive(DamageInfo.create(1, Vector2(150, 0))))
	assert_eq(player.health.current, player.combat.max_health - 1)
	assert_eq(player.state_machine.current_state_name(), &"Hurt")
	assert_false(player.hurtbox.receive(DamageInfo.create(1, Vector2.ZERO)), "Schonzeit nach Treffer")
	await wait_seconds(0.4)
	assert_gt(player.global_position.x, start.x + 5.0, "zurückgeschleudert")
	assert_eq(player.state_machine.current_state_name(), &"Idle")
	await wait_seconds(player.combat.invulnerable_after_hurt)
	assert_false(player.is_invulnerable(), "Schonzeit vorbei")


func test_death_emits_died_after_fade() -> void:
	watch_signals(player)
	player.hurtbox.receive(DamageInfo.create(99, Vector2.ZERO))
	assert_eq(player.state_machine.current_state_name(), &"Dead")
	await wait_seconds(1.2)
	assert_signal_emitted(player, "died")
	await _tap(&"attack")
	assert_eq(player.state_machine.current_state_name(), &"Dead", "Tote greifen nicht an")
