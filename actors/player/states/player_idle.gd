## Held steht. Bremst aus, wechselt bei Eingabe zu Move oder startet eine Aktion.
extends State

@onready var _player: Player = owner


func enter(_previous: StringName) -> void:
	_player.play_animation(&"idle")


func physics_update(delta: float) -> void:
	if _player.try_start_action(false):
		return
	var input := _player.get_move_input()
	if not input.is_zero_approx():
		state_machine.transition_to(&"Move")
		return
	_player.play_animation(&"idle")
	_player.apply_movement(Vector2.ZERO, delta)
