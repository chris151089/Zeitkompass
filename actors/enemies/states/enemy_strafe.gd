## Umkreist den Helden kurz in Angriffsreichweite, bevor er ausholt (Skelett).
extends State

const KEEP_DISTANCE := 0.85
const ESCAPE_FACTOR := 1.7

var _time_left: float
var _side: float = 1.0

@onready var _enemy: Enemy = owner


func enter(_previous: StringName) -> void:
	_time_left = _enemy.data.strafe_time
	_side = 1.0 if randf() < 0.5 else -1.0


func physics_update(delta: float) -> void:
	var to_target := _enemy.vector_to_target()
	var distance := to_target.length()
	if distance > _enemy.data.attack_range * ESCAPE_FACTOR:
		state_machine.transition_to(&"Chase")
		return
	_time_left -= delta
	if _time_left <= 0.0:
		state_machine.transition_to(&"Windup")
		return
	var toward := to_target.normalized()
	var around := toward.orthogonal() * _side * _enemy.data.strafe_speed
	var keep := toward * (distance - _enemy.data.attack_range * KEEP_DISTANCE) * 2.0
	_enemy.face_towards(toward)
	_enemy.play(&"run")
	_enemy.move_with(around + keep, delta)
