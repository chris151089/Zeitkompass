## Sprung (A). Kael behält dabei das Tempo vom Absprung.
## Wird in der Luft angegriffen (B), geht es nahtlos in den Sprungangriff über.
## Frames der Animation „jump“ laut hero_sheet.json: 0 Absprung, 1 Scheitel, 2 Schlag, 3 Landung.
## Ein normaler Sprung überspringt den Schlag-Frame und landet direkt.
extends State

const AIR_FRAMES := 2  # Frames 0 und 1
const STRIKE_FRAME := 2
const LANDING_FRAME := 3

var _landing: bool = false

@onready var _player: Player = owner


func enter(_previous: StringName) -> void:
	_landing = false
	var input := _player.get_move_input()
	if not input.is_zero_approx():
		_player.update_facing(input)
	_player.hitbox.deactivate()
	_player.restart_animation(&"jump")


func physics_update(_delta: float) -> void:
	var frame := _player.sprite.frame
	if not _landing and frame < AIR_FRAMES and Input.is_action_just_pressed(&"attack"):
		state_machine.transition_to(&"JumpAttack")
		return
	if not _landing and frame >= STRIKE_FRAME:
		_landing = true
		_player.sprite.set_frame_and_progress(LANDING_FRAME, 0.0)
	if _landing and not _player.sprite.is_playing():
		_player.carry_on_moving()
		return
	if not _landing:
		_player.move_and_slide()  # Schwung vom Absprung beibehalten
	else:
		_player.velocity = Vector2.ZERO
