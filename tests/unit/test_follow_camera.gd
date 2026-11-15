extends GutTest
## Kamera-Glättung ohne Pixel-Zittern.


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


func test_camera_position_is_whole_pixels() -> void:
	var cam := FollowCamera.pixel_position(Vector2(10.4, 20.7), Vector2(7.9, 18.2))
	assert_eq(cam, cam.round())


func test_walking_target_does_not_jitter_on_screen() -> void:
	# Ziel läuft gleichmäßig mit krummen Schritten (110 px/s bei 60 FPS).
	var dt := 1.0 / 60.0
	var pos := Vector2(100.3, 200.6)
	var step := Vector2(110.0, 37.0) * dt
	var smoothed := pos
	var offsets: Array[Vector2] = []
	for i in 240:
		pos += step
		smoothed = FollowCamera.smooth_towards(smoothed, pos, 7.0, dt)
		var cam := FollowCamera.pixel_position(pos, smoothed)
		# Bildschirmposition der Figur = gerundete Figur - Kamera
		offsets.append(pos.round() - cam)
	# Nach dem Einschwingen darf sich der Bildschirm-Abstand nicht mehr hin und her bewegen.
	var settled := offsets.slice(120)
	for i in range(1, settled.size()):
		assert_eq(settled[i], settled[0], "Frame %d: Figur springt auf dem Bildschirm" % (120 + i))
		if settled[i] != settled[0]:
			break
