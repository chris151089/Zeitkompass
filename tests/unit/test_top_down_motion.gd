extends GutTest
## Bewegungs- und Blickrichtungs-Logik ohne Szene.

const F := TopDownMotion.Facing
const DT := 1.0 / 60.0

var data: MovementData


func before_each() -> void:
	data = MovementData.new()
	data.max_speed = 100.0
	data.acceleration = 1000.0
	data.friction = 1000.0


func _run(input: Vector2, frames: int, start := Vector2.ZERO) -> Vector2:
	var v := start
	for i in frames:
		v = TopDownMotion.approach_velocity(v, input, data, DT)
	return v


func test_accelerates_to_max_speed_and_stays_there() -> void:
	var v := _run(Vector2.RIGHT, 60)
	assert_almost_eq(v, Vector2(100, 0), Vector2(0.001, 0.001))


func test_acceleration_is_gradual() -> void:
	var v := _run(Vector2.RIGHT, 1)
	assert_almost_eq(v.x, 1000.0 * DT, 0.001, "ein Frame Beschleunigung")
	assert_lt(v.x, data.max_speed)


func test_diagonal_is_not_faster() -> void:
	var diagonal := _run(Vector2(1, 1), 60)
	assert_almost_eq(diagonal.length(), 100.0, 0.001)
	# auch wenn die Eingabe (z. B. von außen) länger als 1 ist
	var raw := _run(Vector2(1, 1) * 3.0, 60)
	assert_almost_eq(raw.length(), 100.0, 0.001)


func test_analog_input_walks_slower() -> void:
	var v := _run(Vector2(0.5, 0), 60)
	assert_almost_eq(v.x, 50.0, 0.001)


func test_friction_stops_without_overshoot() -> void:
	var v := _run(Vector2.ZERO, 60, Vector2(100, 0))
	assert_eq(v, Vector2.ZERO)


func test_facing_cardinals() -> void:
	assert_eq(TopDownMotion.facing_from_vector(Vector2.RIGHT, F.DOWN), F.RIGHT)
	assert_eq(TopDownMotion.facing_from_vector(Vector2.LEFT, F.DOWN), F.LEFT)
	assert_eq(TopDownMotion.facing_from_vector(Vector2.UP, F.DOWN), F.UP)
	assert_eq(TopDownMotion.facing_from_vector(Vector2.DOWN, F.UP), F.DOWN)


func test_zero_input_keeps_facing() -> void:
	assert_eq(TopDownMotion.facing_from_vector(Vector2.ZERO, F.LEFT), F.LEFT)


func test_diagonal_keeps_matching_previous_facing() -> void:
	var up_right := Vector2(1, -1).normalized()
	assert_eq(TopDownMotion.facing_from_vector(up_right, F.UP), F.UP)
	assert_eq(TopDownMotion.facing_from_vector(up_right, F.RIGHT), F.RIGHT)


func test_diagonal_from_unrelated_facing_prefers_horizontal() -> void:
	assert_eq(TopDownMotion.facing_from_vector(Vector2(1, -1).normalized(), F.DOWN), F.RIGHT)


func test_hysteresis_against_stick_wobble() -> void:
	# leicht mehr vertikal als horizontal: bleibt rechts
	assert_eq(TopDownMotion.facing_from_vector(Vector2(0.65, 0.76), F.RIGHT), F.RIGHT)
	# deutlich vertikal: wechselt
	assert_eq(TopDownMotion.facing_from_vector(Vector2(0.3, 0.95), F.RIGHT), F.DOWN)


func test_facing_names_match_animation_names() -> void:
	assert_eq(TopDownMotion.facing_name(F.DOWN), &"down")
	assert_eq(TopDownMotion.facing_name(F.LEFT), &"left")
	assert_eq(TopDownMotion.facing_name(F.RIGHT), &"right")
	assert_eq(TopDownMotion.facing_name(F.UP), &"up")
