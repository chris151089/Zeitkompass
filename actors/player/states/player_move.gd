## Held läuft in 8 Richtungen (analog stufenlos).
extends State

## Laufanimation läuft bei langsamer Stick-Bewegung nicht langsamer als dieser Faktor.
const MIN_ANIMATION_SPEED := 0.5

@onready var _player: Player = owner


func physics_update(delta: float) -> void:
	if _player.try_start_action(false):
		return
	var input := _player.get_move_input()
	if input.is_zero_approx():
		state_machine.transition_to(&"Idle")
		return
	if _player.is_run_held():
		state_machine.transition_to(&"Run")
		return
	_player.update_facing(input)
	_player.apply_movement(input, delta)
	var anim_speed := maxf(MIN_ANIMATION_SPEED, input.length())
	_player.play_animation(&"walk", anim_speed)
