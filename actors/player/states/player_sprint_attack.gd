## Sprintangriff: aus dem Rennen heraus ein Stoß nach vorn (Animation „sprint“ ab dem Stoß).
extends State

const ACTION := "sprint"
## Die ersten Frames von „sprint“ sind der Anlauf (= Rennen), danach folgt der Stoß.
const THRUST_FRAME := 2

@onready var _player: Player = owner


func enter(_previous: StringName) -> void:
	_player.restart_animation(&"sprint", THRUST_FRAME)
	_player.velocity = _player.facing_vector() * _player.combat.sprint_attack_speed


func exit() -> void:
	_player.hitbox.deactivate()


func physics_update(delta: float) -> void:
	if not _player.sprite.is_playing():
		state_machine.transition_to(&"Idle")
		return
	if HeroSheet.is_hit_active(ACTION, _player.sprite.frame):
		_player.hitbox.activate(_player.combat.sprint_attack, _player.facing_vector())
	else:
		_player.hitbox.deactivate()
	_player.decelerate(delta, 0.6)
