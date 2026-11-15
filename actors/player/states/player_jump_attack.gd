## Sprungangriff: aus dem Sprung heraus (B in der Luft) Schlag von oben mit der Landung.
## Startet beim Schlag-Frame der Animation „jump“; Treffer-Frames laut hero_sheet.json.
extends State

const ACTION := "jump"
const STRIKE_FRAME := 2

@onready var _player: Player = owner


func enter(_previous: StringName) -> void:
	_player.restart_animation(&"jump", STRIKE_FRAME)


func exit() -> void:
	_player.hitbox.deactivate()


func physics_update(delta: float) -> void:
	if not _player.sprite.is_playing():
		_player.carry_on_moving()
		return
	if HeroSheet.is_hit_active(ACTION, _player.sprite.frame):
		_player.hitbox.activate(_player.combat.jump_attack, _player.facing_vector())
	else:
		_player.hitbox.deactivate()
	_player.decelerate(delta, 0.5)
