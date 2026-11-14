extends GutTest
## Ganzzahlige Skalierung der internen Auflösung 640×360.


func test_scale_factors_for_standard_resolutions() -> void:
	assert_eq(DisplaySettings.compute_integer_scale(Vector2i(1280, 720)), 2, "720p")
	assert_eq(DisplaySettings.compute_integer_scale(Vector2i(1920, 1080)), 3, "1080p")
	assert_eq(DisplaySettings.compute_integer_scale(Vector2i(2560, 1440)), 4, "1440p")
	assert_eq(DisplaySettings.compute_integer_scale(Vector2i(3840, 2160)), 6, "4K")


func test_standard_resolutions_have_no_borders() -> void:
	for size: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)]:
		assert_eq(DisplaySettings.compute_viewport_rect(size), Rect2i(Vector2i.ZERO, size), str(size))


func test_odd_resolutions_get_black_borders_not_fractional_scale() -> void:
	# 1366×768: Faktor 2 (1280×720), Rand 43 px links/rechts, 24 px oben/unten
	assert_eq(DisplaySettings.compute_integer_scale(Vector2i(1366, 768)), 2)
	assert_eq(DisplaySettings.compute_viewport_rect(Vector2i(1366, 768)), Rect2i(43, 24, 1280, 720))
	# Ultrawide 3440×1440: Höhe begrenzt auf Faktor 4
	assert_eq(DisplaySettings.compute_integer_scale(Vector2i(3440, 1440)), 4)
	# 16:10 1920×1200: Breite begrenzt auf Faktor 3
	assert_eq(DisplaySettings.compute_viewport_rect(Vector2i(1920, 1200)), Rect2i(0, 60, 1920, 1080))


func test_tiny_window_never_scales_below_one() -> void:
	assert_eq(DisplaySettings.compute_integer_scale(Vector2i(320, 200)), 1)


func test_all_presets_are_exact_multiples_of_base_size() -> void:
	for preset in DisplaySettings.PRESETS:
		var factor := DisplaySettings.compute_integer_scale(preset)
		assert_eq(DisplaySettings.BASE_SIZE * factor, preset, str(preset))
	assert_eq(DisplaySettings.PRESETS.back(), Vector2i(3840, 2160), "Optionen gehen bis 4K")
