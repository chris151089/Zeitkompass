## 3er-Combo. Jeder Schlag besteht aus zwei Frames der Animation „combo“ (Ausholen, Treffer).
## Wird während eines Schlags erneut angegriffen, folgt nahtlos der nächste.
extends State

const ACTION := "combo"
const FRAMES_PER_HIT := 2

var _index: int = 0
var _buffered: bool = false
## Höchster erreichter Schlag dieser Combo (für Tests/Debug).
var last_hit_index: int = 0

@onready var _player: Player = owner


func enter(_previous: StringName) -> void:
	_index = 0
	_start_hit()


func exit() -> void:
	_player.hitbox.deactivate()


func _start_hit() -> void:
	var input := _player.get_move_input()
	if not input.is_zero_approx():
		_player.update_facing(input)
	_buffered = false
	last_hit_index = _index
	_player.hitbox.deactivate()
	_player.restart_animation(&"combo", _index * FRAMES_PER_HIT)


func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed(&"attack"):
		_buffered = true
	if Input.is_action_just_pressed(&"dodge"):
		state_machine.transition_to(&"Roll")
		return
	var frame := _player.sprite.frame
	var segment_end := _index * FRAMES_PER_HIT + FRAMES_PER_HIT - 1
	if frame > segment_end or not _player.sprite.is_playing():
		if _buffered and _index < _player.combat.combo.size() - 1:
			_index += 1
			_start_hit()
		else:
			state_machine.transition_to(&"Idle")
		return
	var attack: AttackData = _player.combat.combo[_index]
	if HeroSheet.is_hit_active(ACTION, frame):
		_player.hitbox.activate(attack, _player.facing_vector())
		_player.velocity = _player.facing_vector() * attack.lunge_speed
		_player.move_and_slide()
	else:
		_player.hitbox.deactivate()
		_player.decelerate(delta)
