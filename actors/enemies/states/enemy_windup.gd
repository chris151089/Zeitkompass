## Ausholen: bleibt stehen und glüht rot auf – die Vorwarnung, an der der Spieler den
## Angriff erkennt und ausweichen kann.
extends State

const MAX_GLOW := 0.75

var _time_left: float

@onready var _enemy: Enemy = owner


func enter(_previous: StringName) -> void:
	_time_left = _enemy.data.windup_time
	_enemy.play(&"idle", 2.0)


func exit() -> void:
	_enemy.set_warning_glow(0.0)


func physics_update(delta: float) -> void:
	var to_target := _enemy.vector_to_target()
	if not to_target.is_zero_approx():
		_enemy.attack_direction = to_target.normalized()
		_enemy.face_towards(to_target)
	_enemy.move_with(Vector2.ZERO, delta)
	_time_left -= delta
	var progress := 1.0 - clampf(_time_left / maxf(_enemy.data.windup_time, 0.01), 0.0, 1.0)
	_enemy.set_warning_glow(progress * MAX_GLOW)
	if _time_left <= 0.0:
		state_machine.transition_to(&"Attack")
