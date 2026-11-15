## Ausweichrolle mit Unverwundbarkeits-Frames (laut hero_sheet.json).
## Volles Tempo bis zum Schluss, danach geht es nahtlos weiter (kein Abbremsen).
extends State

const ACTION := "roll"

var _direction: Vector2

@onready var _player: Player = owner


func enter(_previous: StringName) -> void:
	_direction = _player.action_direction()
	_player.update_facing(_direction)
	_player.hitbox.deactivate()
	_player.restart_animation(&"roll", 0, _player.combat.roll_animation_speed)


func exit() -> void:
	_player.set_roll_invulnerable(false)


func physics_update(_delta: float) -> void:
	if not _player.sprite.is_playing():
		_player.carry_on_moving()
		return
	_player.set_roll_invulnerable(HeroSheet.is_invulnerable(ACTION, _player.sprite.frame))
	_player.velocity = _direction * _player.combat.roll_speed
	_player.move_and_slide()
