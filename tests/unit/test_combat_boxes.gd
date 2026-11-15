extends GutTest
## Hitbox trifft Hurtbox: einmal pro Aktivierung, nicht bei Unverwundbarkeit, mit Rückstoß.

const HITBOX := preload("res://combat/hitbox.tscn")

var attacker: Node2D
var target: Node2D
var hitbox: Hitbox
var hurtbox: Hurtbox
var received: Array = []


func before_each() -> void:
	received.clear()
	attacker = Node2D.new()
	add_child_autofree(attacker)
	hitbox = HITBOX.instantiate()
	attacker.add_child(hitbox)
	hitbox.owner = attacker
	hitbox.collision_mask = 16

	target = Node2D.new()
	target.position = Vector2(12, 0)
	add_child_autofree(target)
	hurtbox = Hurtbox.new()
	hurtbox.collision_layer = 16
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 20)
	shape.shape = rect
	shape.position = Vector2(0, -10)
	hurtbox.add_child(shape)
	target.add_child(hurtbox)
	hurtbox.owner = target
	hurtbox.hurt.connect(func(info: DamageInfo) -> void: received.append(info))


func _attack(damage: int = 2) -> AttackData:
	var a := AttackData.new()
	a.damage = damage
	a.knockback = 100.0
	a.hitstop = 0.0
	return a


func test_hits_once_per_activation() -> void:
	hitbox.activate(_attack(), Vector2.RIGHT)
	await wait_physics_frames(6)
	assert_eq(received.size(), 1, "nur ein Treffer, obwohl mehrere Frames überlappt")
	assert_eq(received[0].amount, 2)
	assert_gt(received[0].knockback.x, 0.0, "Rückstoß weg vom Angreifer")


func test_new_activation_can_hit_again() -> void:
	hitbox.activate(_attack(), Vector2.RIGHT)
	await wait_physics_frames(3)
	hitbox.deactivate()
	await wait_physics_frames(2)
	hitbox.activate(_attack(), Vector2.RIGHT)
	await wait_physics_frames(3)
	assert_eq(received.size(), 2)


func test_invulnerable_hurtbox_ignores_hits() -> void:
	hurtbox.invulnerable = true
	hitbox.activate(_attack(), Vector2.RIGHT)
	await wait_physics_frames(4)
	assert_eq(received.size(), 0)


func test_inactive_hitbox_does_nothing() -> void:
	await wait_physics_frames(4)
	assert_eq(received.size(), 0)


func test_out_of_reach_is_not_hit() -> void:
	hitbox.activate(_attack(), Vector2.LEFT)  # Trefferzone links, Ziel steht rechts
	await wait_physics_frames(4)
	assert_eq(received.size(), 0)


func test_hitstop_freezes_and_restores_time() -> void:
	for i in 5:  # mehrfach, weil der Fehler (Zeit bleibt stehen) vom Timing abhing
		HitFeedback.hitstop(get_tree(), 0.05)
		assert_eq(Engine.time_scale, 0.0)
		await get_tree().create_timer(0.1, true, false, true).timeout
		assert_eq(Engine.time_scale, 1.0, "Lauf %d: Zeit läuft wieder" % i)


func test_overlapping_hitstops_restore_time() -> void:
	HitFeedback.hitstop(get_tree(), 0.05)
	HitFeedback.hitstop(get_tree(), 0.08)
	HitFeedback.hitstop(get_tree(), 0.02)  # kürzer: wird ignoriert
	await get_tree().create_timer(0.15, true, false, true).timeout
	assert_eq(Engine.time_scale, 1.0)


func after_each() -> void:
	HitFeedback.reset()
