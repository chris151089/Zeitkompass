## Held rennt, solange „sprint“ gehalten wird (schneller als Gehen, eigene Animation).
extends State

## Rennanimation läuft bei langsamer Stick-Bewegung nicht langsamer als dieser Faktor.
const MIN_ANIMATION_SPEED := 0.6

@onready var _player: Player = owner


func physics_update(delta: float) -> void:
	var input := _player.get_move_input()
	if input.is_zero_approx():
		state_machine.transition_to(&"Idle")
		return
	if not _player.is_run_held():
		state_machine.transition_to(&"Move")
		return
	_player.update_facing(input)
	_player.apply_movement(input, delta, true)
	_player.play_animation(&"run", maxf(MIN_ANIMATION_SPEED, input.length()))
