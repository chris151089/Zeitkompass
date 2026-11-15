## Angriff: kurzer Sprung/Stoß in die beim Ausholen festgelegte Richtung.
extends State

var _time_left: float

@onready var _enemy: Enemy = owner


func enter(_previous: StringName) -> void:
	_time_left = _enemy.data.attack_time
	_enemy.velocity = _enemy.attack_direction * _enemy.data.attack_dash_speed
	_enemy.hitbox.activate(_enemy.data.attack, _enemy.attack_direction)
	_enemy.play(&"run", 2.0)


func exit() -> void:
	_enemy.hitbox.deactivate()


func physics_update(delta: float) -> void:
	_enemy.move_and_slide()
	_time_left -= delta
	if _time_left <= 0.0:
		state_machine.transition_to(&"Recover")
