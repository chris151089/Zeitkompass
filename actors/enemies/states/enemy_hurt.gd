## Getroffen: zurückgeschleudert und kurz benommen.
extends State

var _time_left: float

@onready var _enemy: Enemy = owner


func enter(_previous: StringName) -> void:
	_time_left = _enemy.data.hurt_time
	_enemy.velocity = _enemy.pending_knockback
	_enemy.play(&"idle")


func physics_update(delta: float) -> void:
	var brake := _enemy.pending_knockback.length() / maxf(_enemy.data.hurt_time, 0.01)
	_enemy.velocity = _enemy.velocity.move_toward(Vector2.ZERO, brake * delta)
	_enemy.move_and_slide()
	_time_left -= delta
	if _time_left <= 0.0:
		state_machine.transition_to(&"Chase")
