## Sprungangriff: Sprung nach vorn, Schlag von oben bei der Landung.
## Die Sprunghöhe ist in die Frames gezeichnet; die Figur bewegt sich nur am Boden.
extends State

const ACTION := "jump"
## Bis zu diesem Frame ist Kael in der Luft und bewegt sich vorwärts.
const AIRBORNE_FRAMES := 2

var _direction: Vector2

@onready var _player: Player = owner


func enter(_previous: StringName) -> void:
	_direction = _player.action_direction()
	_player.update_facing(_direction)
	_player.restart_animation(&"jump")


func exit() -> void:
	_player.hitbox.deactivate()


func physics_update(delta: float) -> void:
	if not _player.sprite.is_playing():
		state_machine.transition_to(&"Idle")
		return
	var frame := _player.sprite.frame
	if HeroSheet.is_hit_active(ACTION, frame):
		_player.hitbox.activate(_player.combat.jump_attack, _player.facing_vector())
	else:
		_player.hitbox.deactivate()
	if frame < AIRBORNE_FRAMES:
		_player.velocity = _direction * _player.combat.jump_attack_speed
		_player.move_and_slide()
	else:
		_player.decelerate(delta, 2.0)
