## Getroffen: kurz zurückgeschleudert, nicht steuerbar. Danach blinkt Kael (Schonzeit, siehe Player).
## Eigene Treffer-Animation fehlt noch (siehe CLAUDE.md) – bis dahin rotes Aufblitzen + Rückstoß.
extends State

var _time_left: float

@onready var _player: Player = owner


func enter(_previous: StringName) -> void:
	_time_left = _player.combat.hurt_time
	_player.velocity = _player.pending_knockback
	_player.play_animation(&"idle")


func physics_update(delta: float) -> void:
	_time_left -= delta
	var brake := _player.pending_knockback.length() / maxf(_player.combat.hurt_time, 0.01)
	_player.velocity = _player.velocity.move_toward(Vector2.ZERO, brake * delta)
	_player.move_and_slide()
	if _time_left <= 0.0:
		state_machine.transition_to(&"Idle")
