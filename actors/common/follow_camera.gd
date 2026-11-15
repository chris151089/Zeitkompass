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
var _shake_strength: float = 0.0
var _shake_time: float = 0.0
var _shake_duration: float = 0.0


func _ready() -> void:
	_target = get_parent() as Node2D
	top_level = true
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	# Erst nach der Bewegung des Ziels im selben Physik-Schritt nachziehen.
	process_physics_priority = 100
	add_to_group(HitFeedback.SHAKE_GROUP)
	snap_to_target()


func _physics_process(delta: float) -> void:
	if _target == null:
		return
	_smoothed = smooth_towards(_smoothed, _target_position(), follow_speed, delta)
	global_position = _smoothed
	_update_shake(delta)


## Bildschirmwackeln (über HitFeedback.shake() an alle Kameras der Gruppe).
func shake(strength: float, duration: float) -> void:
	if strength >= _shake_strength * (_shake_time / maxf(_shake_duration, 0.001)):
		_shake_strength = strength
		_shake_time = duration
		_shake_duration = duration


func _update_shake(delta: float) -> void:
	if _shake_time <= 0.0:
		offset = Vector2.ZERO
		return
	_shake_time -= delta
	var fade := clampf(_shake_time / _shake_duration, 0.0, 1.0)
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_strength * fade


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
