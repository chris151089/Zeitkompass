## Anzeige-Logik: ganzzahlige Skalierung der internen Auflösung, Fenstermodi.
##
## Die reine Rechenlogik (compute_*) ist statisch und ohne Fenster testbar.
## Das spätere Optionsmenü (M6) benutzt dieselben Funktionen.
class_name DisplaySettings
extends RefCounted

## Interne Auflösung des Spiels in Pixeln.
const BASE_SIZE := Vector2i(640, 360)

## Wählbare Fenstergrößen im Optionsmenü (alle ganzzahlige Vielfache von BASE_SIZE).
const PRESETS: Array[Vector2i] = [
	Vector2i(1280, 720),   # 720p,  Faktor 2
	Vector2i(1920, 1080),  # 1080p, Faktor 3
	Vector2i(2560, 1440),  # 1440p, Faktor 4
	Vector2i(3200, 1800),  # 1800p, Faktor 5
	Vector2i(3840, 2160),  # 4K,    Faktor 6
]

enum WindowMode { WINDOWED, BORDERLESS, FULLSCREEN }


## Größter ganzzahliger Faktor, mit dem BASE_SIZE ganz in window_size passt (mindestens 1).
static func compute_integer_scale(window_size: Vector2i) -> int:
	var fx := window_size.x / BASE_SIZE.x
	var fy := window_size.y / BASE_SIZE.y
	return maxi(1, mini(fx, fy))


## Rechteck, in dem das Spielbild im Fenster liegt (zentriert, Rest = schwarze Ränder).
static func compute_viewport_rect(window_size: Vector2i) -> Rect2i:
	var scaled := BASE_SIZE * compute_integer_scale(window_size)
	var offset := (window_size - scaled) / 2
	return Rect2i(offset, scaled)


static func apply_window_mode(mode: WindowMode) -> void:
	match mode:
		WindowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		WindowMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


## Setzt die Fenstergröße und zentriert das Fenster auf dem aktuellen Bildschirm.
static func apply_window_size(size: Vector2i) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(size)
	var screen := DisplayServer.window_get_current_screen()
	var screen_rect := DisplayServer.screen_get_usable_rect(screen)
	DisplayServer.window_set_position(screen_rect.position + (screen_rect.size - size) / 2)


static func apply_vsync(enabled: bool) -> void:
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	)
