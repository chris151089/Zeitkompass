## Wartet, bis der Held in Sichtweite kommt.
extends State

@onready var _enemy: Enemy = owner


func enter(_previous: StringName) -> void:
	_enemy.play(&"idle")


func physics_update(delta: float) -> void:
	_enemy.move_with(Vector2.ZERO, delta)
	if _enemy.distance_to_target() <= _enemy.data.sight_range:
		state_machine.transition_to(&"Chase")
