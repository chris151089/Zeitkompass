## Kamera, die einem Ziel weich folgt.
##
## Läuft im Physik-Takt; Godots Physik-Interpolation glättet Kamera und Figuren gemeinsam
## zwischen den Physik-Schritten. Durch den Stretch-Modus „canvas_items“ darf die Kamera
## auf Bruchteile eines Spielpixels stehen – das Scrollen bleibt so auch bei großem
## Skalierungsfaktor (×6, ×8, ×12) gleichmäßig. Nicht auf ganze Pixel runden!
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
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	# Erst nach der Bewegung des Ziels im selben Physik-Schritt nachziehen.
	process_physics_priority = 100
	snap_to_target()


func _physics_process(delta: float) -> void:
	if _target == null:
		return
	_smoothed = smooth_towards(_smoothed, _target_position(), follow_speed, delta)
	global_position = _smoothed


## Springt ohne Glättung zum Ziel (z. B. nach Szenenwechsel oder Teleport).
func snap_to_target() -> void:
	if _target == null:
		return
	_smoothed = _target_position()
	global_position = _smoothed
	reset_smoothing()
	reset_physics_interpolation()


func _target_position() -> Vector2:
	return _target.global_position + target_offset


## Bildraten-unabhängige exponentielle Glättung.
static func smooth_towards(current: Vector2, goal: Vector2, speed: float, delta: float) -> Vector2:
	return goal + (current - goal) * exp(-speed * delta)
