## Läuft auf den Helden zu, bis er in Angriffsreichweite ist.
extends State

## Verliert den Helden erst bei deutlich größerem Abstand aus den Augen.
const LOSE_SIGHT_FACTOR := 1.6

@onready var _enemy: Enemy = owner


func physics_update(delta: float) -> void:
	var distance := _enemy.distance_to_target()
	if distance > _enemy.data.sight_range * LOSE_SIGHT_FACTOR:
		state_machine.transition_to(&"Idle")
		return
	if distance <= _enemy.data.attack_range:
		state_machine.transition_to(&"Strafe" if _enemy.data.strafe_time > 0.0 else &"Windup")
		return
	var direction := _enemy.vector_to_target().normalized()
	_enemy.face_towards(direction)
	_enemy.play(&"run")
	_enemy.move_with(direction * _enemy.data.move_speed, delta)
