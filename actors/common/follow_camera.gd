## Kamera, die einem Ziel weich folgt, ohne dass das Ziel auf dem Bildschirm zittert.
##
## Problem bei Pixel-Art: Werden Kamera und Figur getrennt auf ganze Pixel gerundet,
## springt die Figur beim Laufen um ±1 Pixel. Lösung: Nur der *Abstand* zwischen Kamera
## und Ziel wird geglättet und gerundet; die Kamera sitzt immer auf der gerundeten
## Zielposition plus diesem ganzzahligen Abstand.
class_name FollowCamera
extends Camera2D

## Wie schnell die Kamera aufholt (höher = straffer).
@export_range(0.5, 30.0, 0.5) var follow_speed: float = 7.0
## Versatz zum Ziel, z. B. damit die Figurmitte statt der Füße zentriert ist.
@export var target_offset: Vector2 = Vector2(0, -12)

var _smoothed: Vector2
var _target: Node2D


func _ready() -> void:
	_target = get_parent() as Node2D
	top_level = true
	process_callback = Camera2D.CAMERA2D_PROCESS_IDLE
	snap_to_target()


func _process(delta: float) -> void:
	if _target == null:
		return
	var goal := _target_position()
	_smoothed = smooth_towards(_smoothed, goal, follow_speed, delta)
	global_position = pixel_position(goal, _smoothed)


## Springt ohne Glättung zum Ziel (z. B. nach Szenenwechsel oder Teleport).
func snap_to_target() -> void:
	if _target == null:
		return
	_smoothed = _target_position()
	global_position = _smoothed.round()
	reset_smoothing()


func _target_position() -> Vector2:
	return _target.global_position + target_offset


## Bildraten-unabhängige exponentielle Glättung.
static func smooth_towards(current: Vector2, goal: Vector2, speed: float, delta: float) -> Vector2:
	return goal + (current - goal) * exp(-speed * delta)


## Kameraposition auf ganzen Pixeln: gerundetes Ziel + gerundeter Abstand.
## Dadurch ändert sich die Bildschirmposition des Ziels nur, wenn sich der Abstand ändert.
static func pixel_position(goal: Vector2, smoothed: Vector2) -> Vector2:
	return goal.round() + (smoothed - goal).round()
