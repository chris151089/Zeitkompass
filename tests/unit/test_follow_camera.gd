extends GutTest
## Kamera-Glättung.


func test_smoothing_converges() -> void:
	var p := Vector2.ZERO
	for i in 120:
		p = FollowCamera.smooth_towards(p, Vector2(100, 50), 7.0, 1.0 / 60.0)
	assert_almost_eq(p, Vector2(100, 50), Vector2(0.1, 0.1))


func test_smoothing_is_frame_rate_independent() -> void:
	var one_step := FollowCamera.smooth_towards(Vector2.ZERO, Vector2(100, 0), 7.0, 0.1)
	var two_steps := FollowCamera.smooth_towards(Vector2.ZERO, Vector2(100, 0), 7.0, 0.05)
	two_steps = FollowCamera.smooth_towards(two_steps, Vector2(100, 0), 7.0, 0.05)
	assert_almost_eq(one_step, two_steps, Vector2(0.001, 0.001))
