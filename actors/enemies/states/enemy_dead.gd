## Besiegt: Todesanimation, dann ausblenden und entfernen.
extends State

const FADE_TIME := 0.5

@onready var _enemy: Enemy = owner


func enter(_previous: StringName) -> void:
	_enemy.velocity = Vector2.ZERO
	_enemy.hitbox.deactivate()
	_enemy.set_deferred(&"collision_layer", 0)
	_enemy.set_deferred(&"collision_mask", 0)
	_enemy.hurtbox.set_deferred(&"monitorable", false)
	_enemy.play(&"death")
	_enemy.died.emit(_enemy)
	await _enemy.sprite.animation_finished
	var tween := _enemy.create_tween()
	tween.tween_property(_enemy, ^"modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(_enemy.queue_free)
