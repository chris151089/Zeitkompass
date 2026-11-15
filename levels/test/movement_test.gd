## Testkarte für M1: Laufen, Kollision, Kamera.
extends Node2D

@onready var _ground: TileMapLayer = $Ground
@onready var _player: Player = $World/Player


func _ready() -> void:
	var used := _ground.get_used_rect()
	var tile := _ground.tile_set.tile_size
	_player.set_camera_limits(Rect2i(used.position * tile, used.size * tile))
