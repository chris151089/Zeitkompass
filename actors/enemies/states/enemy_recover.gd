## Verschnaufpause nach dem Angriff – das Zeitfenster zum Kontern.
extends State

var _time_left: float

@onready var _enemy: Enemy = owner


func enter(_previous: StringName) -> void:
	_time_left = _enemy.data.recover_time
	_enemy.play(&"idle")


func physics_update(delta: float) -> void:
	_enemy.move_with(Vector2.ZERO, delta)
	_time_left -= delta
	if _time_left <= 0.0:
		state_machine.transition_to(&"Chase")
