extends GutTest
## Schützt die Pixel-Art-Einstellungen aus docs/design.md vor versehentlichen Änderungen.


func test_internal_resolution_is_640x360() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width"), 640)
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_height"), 360)
	var base := Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"),
	)
	assert_eq(base, DisplaySettings.BASE_SIZE, "DisplaySettings.BASE_SIZE passt zum Projekt")


func test_stretch_viewport_keep_integer() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode"), "viewport")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/aspect"), "keep")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/scale_mode"), "integer")


func test_nearest_texture_filter() -> void:
	# Projekteinstellung: 0 = Nearest, 1 = Linear
	assert_eq(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter"), 0)
	assert_eq(
		get_tree().root.canvas_item_default_texture_filter,
		Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST,
		"Wurzel-Viewport filtert Nearest",
	)


func test_pixel_snapping_enabled() -> void:
	assert_true(ProjectSettings.get_setting("rendering/2d/snap/snap_2d_transforms_to_pixel"))
	assert_true(ProjectSettings.get_setting("rendering/2d/snap/snap_2d_vertices_to_pixel"))


func test_autoloads_registered() -> void:
	for autoload_name in ["GameState", "SaveManager", "AudioManager", "DialogueManager", "SceneLoader"]:
		assert_true(ProjectSettings.has_setting("autoload/" + autoload_name), autoload_name + " ist Autoload")
		assert_not_null(get_tree().root.get_node_or_null(autoload_name), autoload_name + " läuft")
