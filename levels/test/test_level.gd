## Gemeinsames Skript der Testkarten: Kamera-Grenzen, Kartenränder, HUD, Tod und Neustart.
extends Node2D

## Dicke der unsichtbaren Kartenränder in Pixeln.
const BOUNDS_THICKNESS := 32.0
## So weit liegen die Ränder innerhalb der Karte (der Held soll nicht im Waldrand verschwinden).
@export var bounds_inset: float = 10.0

@onready var _ground: TileMapLayer = $Ground
@onready var _player: Player = $World/Player
@onready var _hud: Hud = get_node_or_null(^"HUD")
@onready var _game_over: GameOverScreen = get_node_or_null(^"GameOver")


func _ready() -> void:
	HitFeedback.reset()
	var rect := map_rect()
	_player.set_camera_limits(rect)
	_add_world_bounds(Rect2(rect).grow(-bounds_inset))
	if _hud:
		_hud.bind_health(_player.health)
	_player.died.connect(_on_player_died)
	if _game_over:
		_game_over.retry_requested.connect(_on_game_over_retry_requested)


## Kartenbereich in Pixeln (aus der Boden-Ebene).
func map_rect() -> Rect2i:
	var used := _ground.get_used_rect()
	var tile := _ground.tile_set.tile_size
	return Rect2i(used.position * tile, used.size * tile)


func _on_player_died() -> void:
	if _game_over:
		_game_over.show_screen()


func _on_game_over_retry_requested() -> void:
	HitFeedback.reset()
	# Über den Knotenpfad statt den Autoload-Namen: Generator-Skripte (--script) kennen
	# Autoload-Namen nicht und könnten dieses Skript sonst nicht laden.
	get_node(^"/root/SceneLoader").change_scene(scene_file_path)


## Unsichtbare Wände rund um die Karte, damit niemand hinausläuft.
func _add_world_bounds(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.name = "WorldBounds"
	body.collision_layer = 1
	body.collision_mask = 0
	var t := BOUNDS_THICKNESS
	for r in [
		Rect2(rect.position.x - t, rect.position.y - t, rect.size.x + 2 * t, t),  # oben
		Rect2(rect.position.x - t, rect.end.y, rect.size.x + 2 * t, t),  # unten
		Rect2(rect.position.x - t, rect.position.y, t, rect.size.y),  # links
		Rect2(rect.end.x, rect.position.y, t, rect.size.y),  # rechts
	]:
		var shape := RectangleShape2D.new()
		shape.size = r.size
		var collision := CollisionShape2D.new()
		collision.shape = shape
		collision.position = r.get_center()
		body.add_child(collision)
	add_child(body)
