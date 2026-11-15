## Ausweichrolle mit Unverwundbarkeits-Frames (laut hero_sheet.json).
extends State

const ACTION := "roll"

var _direction: Vector2

@onready var _player: Player = owner


func enter(_previous: StringName) -> void:
	_direction = _player.action_direction()
	_player.update_facing(_direction)
	_player.hitbox.deactivate()
	_player.restart_animation(&"roll")


func exit() -> void:
	_player.set_roll_invulnerable(false)


func physics_update(delta: float) -> void:
	if not _player.sprite.is_playing():
		var moving := not _player.get_move_input().is_zero_approx()
		state_machine.transition_to(&"Move" if moving else &"Idle")
		return
	var frame := _player.sprite.frame
	_player.set_roll_invulnerable(HeroSheet.is_invulnerable(ACTION, frame))
	if frame < HeroSheet.frame_count(ACTION) - 1:
		_player.velocity = _direction * _player.combat.roll_speed
		_player.move_and_slide()
	else:
		_player.decelerate(delta, 2.0)
