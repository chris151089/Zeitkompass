## Reine Bewegungs-Logik für Top-down-Figuren (ohne Szene testbar).
class_name TopDownMotion
extends RefCounted

## Blickrichtung. Es gibt 4 Sprite-Richtungen, gelaufen wird in 8 (und analog stufenlos).
enum Facing { DOWN, LEFT, RIGHT, UP }

const FACING_NAMES: Array[StringName] = [&"down", &"left", &"right", &"up"]

## Die bisherige Blickrichtung bleibt, solange ihre Achse mindestens diesen Anteil der
## anderen Achse hat. Verhindert Flackern bei Diagonalen und unruhigem Stick.
const FACING_HYSTERESIS := 0.7


## Neue Geschwindigkeit: beschleunigt Richtung Eingabe bzw. bremst ohne Eingabe ab.
## input wird auf Länge 1 begrenzt, damit diagonal nicht schneller gelaufen wird.
static func approach_velocity(current: Vector2, input: Vector2, data: MovementData, delta: float) -> Vector2:
	var direction := input.limit_length(1.0)
	if direction.is_zero_approx():
		return current.move_toward(Vector2.ZERO, data.friction * delta)
	return current.move_toward(direction * data.max_speed, data.acceleration * delta)


## Blickrichtung zu einem Bewegungsvektor, mit Hysterese gegenüber previous.
static func facing_from_vector(v: Vector2, previous: Facing) -> Facing:
	if v.is_zero_approx():
		return previous
	var horizontal := Facing.RIGHT if v.x > 0.0 else Facing.LEFT
	var vertical := Facing.DOWN if v.y > 0.0 else Facing.UP
	var ax := absf(v.x)
	var ay := absf(v.y)
	if previous == horizontal and ax > 0.0 and ax >= ay * FACING_HYSTERESIS:
		return previous
	if previous == vertical and ay > 0.0 and ay >= ax * FACING_HYSTERESIS:
		return previous
	return horizontal if ax >= ay else vertical


static func facing_name(facing: Facing) -> StringName:
	return FACING_NAMES[facing]


## Sprite-Richtung für Sheets mit nur einer Seitenansicht (nach rechts):
## [Animations-Suffix, horizontal spiegeln]
static func sprite_direction(facing: Facing) -> Array:
	match facing:
		Facing.LEFT:
			return [&"side", true]
		Facing.RIGHT:
			return [&"side", false]
		Facing.UP:
			return [&"up", false]
	return [&"down", false]
