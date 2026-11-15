## Tod: Kael blendet aus, danach meldet der Spieler „died“ (das Level bietet Neustart an).
## Eigene Todes-Animation fehlt noch (siehe CLAUDE.md).
extends State

const FADE_TIME := 0.8

@onready var _player: Player = owner


func enter(_previous: StringName) -> void:
	_player.velocity = Vector2.ZERO
	_player.hitbox.deactivate()
	_player.play_animation(&"idle", 0.0)
	var tween := _player.create_tween()
	tween.tween_property(_player.sprite, ^"modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(_player.died.emit)
