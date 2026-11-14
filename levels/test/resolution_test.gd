## Testbild für M0: prüft interne Auflösung, ganzzahlige Skalierung und Input-Map.
##
## - 32×32-Kachelraster über die volle interne Auflösung (640×360 = 20×11,25 Kacheln)
## - 1-Pixel-Rahmen und Schachbrett-Ecken: verschwommene oder doppelte Linien
##   bedeuten, dass nicht ganzzahlig skaliert wird
## - zeigt Fenstergröße, Skalierungsfaktor und die zuletzt gedrückte Aktion
##
## Tasten: F2 = nächste Fenstergröße, F11 = Vollbild.
extends Node2D

const TILE := 32
const COLOR_BG_A := Color("1d1a2b")
const COLOR_BG_B := Color("252238")
const COLOR_GRID := Color("3d3860")
const COLOR_BORDER := Color("f2c14e")

## Spiel-Aktionen, die im Testbild angezeigt werden (Debug-Aktionen ausgenommen).
const WATCHED_ACTIONS: Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right",
	&"attack", &"dodge", &"jump", &"sprint",
	&"echo_cast", &"echo_prev", &"echo_next",
	&"interact", &"inventory", &"pause",
]

var _preset_index := -1
var _last_action := "—"

@onready var _info: Label = $UI/Info


func _ready() -> void:
	get_viewport().size_changed.connect(_update_info)
	_update_info()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_fullscreen"):
		var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplaySettings.apply_window_mode(
			DisplaySettings.WindowMode.WINDOWED if fullscreen else DisplaySettings.WindowMode.BORDERLESS
		)
	elif event.is_action_pressed(&"debug_cycle_resolution"):
		_preset_index = (_preset_index + 1) % DisplaySettings.PRESETS.size()
		DisplaySettings.apply_window_size(DisplaySettings.PRESETS[_preset_index])
	else:
		for action in WATCHED_ACTIONS:
			if event.is_action_pressed(action):
				_last_action = "%s  (%s)" % [action, _device_name(event)]
				_update_info()
				break


func _process(_delta: float) -> void:
	# Analoge Bewegung live anzeigen.
	var move := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	$Marker.position = Vector2(DisplaySettings.BASE_SIZE) / 2.0 + move * 48.0


func _draw() -> void:
	var size := DisplaySettings.BASE_SIZE
	# Schachbrett aus 32×32-Kacheln
	for y in range(0, size.y, TILE):
		for x in range(0, size.x, TILE):
			var odd := ((x / TILE) + (y / TILE)) % 2 == 1
			draw_rect(Rect2(x, y, TILE, TILE), COLOR_BG_B if odd else COLOR_BG_A)
	# Rasterlinien (1 px, auf ganzen Pixeln)
	for x in range(0, size.x, TILE):
		draw_rect(Rect2(x, 0, 1, size.y), COLOR_GRID)
	for y in range(0, size.y, TILE):
		draw_rect(Rect2(0, y, size.x, 1), COLOR_GRID)
	# 1-px-Rahmen am Bildrand
	draw_rect(Rect2(0, 0, size.x, 1), COLOR_BORDER)
	draw_rect(Rect2(0, size.y - 1, size.x, 1), COLOR_BORDER)
	draw_rect(Rect2(0, 0, 1, size.y), COLOR_BORDER)
	draw_rect(Rect2(size.x - 1, 0, 1, size.y), COLOR_BORDER)
	# 1-px-Schachbrett in den Ecken: muss in jeder Auflösung als feines, gleichmäßiges Muster erscheinen
	for corner in [Vector2i(2, 2), Vector2i(size.x - 10, 2), Vector2i(2, size.y - 10), Vector2i(size.x - 10, size.y - 10)]:
		for py in 8:
			for px in 8:
				if (px + py) % 2 == 0:
					draw_rect(Rect2(corner.x + px, corner.y + py, 1, 1), COLOR_BORDER)


func _update_info() -> void:
	var window := DisplayServer.window_get_size()
	var scale := DisplaySettings.compute_integer_scale(window)
	var rect := DisplaySettings.compute_viewport_rect(window)
	_info.text = "\n".join([
		"ZEITKOMPASS - M0 Testbild",
		"Intern: %dx%d   Fenster: %dx%d" % [DisplaySettings.BASE_SIZE.x, DisplaySettings.BASE_SIZE.y, window.x, window.y],
		"Faktor: %dx   Rand: %d / %d px" % [scale, rect.position.x, rect.position.y],
		"Aktion: %s" % _last_action,
		"F2: Groesse wechseln   F11: Vollbild",
	])


static func _device_name(event: InputEvent) -> String:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return "Controller"
	return "Tastatur"
