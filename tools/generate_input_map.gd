## Schreibt die Input-Map des Spiels in project.godot.
##
## Aufruf (aus dem Projektordner):
##   godot --headless --script res://tools/generate_input_map.gd
##
## Die Tabelle unten ist die einzige Quelle der Wahrheit für Standardbelegungen.
## Im Spielcode werden nur die Aktionsnamen verwendet, nie feste Tasten.
extends SceneTree

const DEADZONE := 0.2

## Aktion -> { keys: [Key], joy_buttons: [JoyButton], joy_axes: [[JoyAxis, Richtung]] }
const ACTIONS := {
	"move_up": {
		"keys": [KEY_W, KEY_UP],
		"joy_buttons": [JOY_BUTTON_DPAD_UP],
		"joy_axes": [[JOY_AXIS_LEFT_Y, -1.0]],
	},
	"move_down": {
		"keys": [KEY_S, KEY_DOWN],
		"joy_buttons": [JOY_BUTTON_DPAD_DOWN],
		"joy_axes": [[JOY_AXIS_LEFT_Y, 1.0]],
	},
	"move_left": {
		"keys": [KEY_A, KEY_LEFT],
		"joy_buttons": [JOY_BUTTON_DPAD_LEFT],
		"joy_axes": [[JOY_AXIS_LEFT_X, -1.0]],
	},
	"move_right": {
		"keys": [KEY_D, KEY_RIGHT],
		"joy_buttons": [JOY_BUTTON_DPAD_RIGHT],
		"joy_axes": [[JOY_AXIS_LEFT_X, 1.0]],
	},
	# Kampf
	"attack": {"keys": [KEY_J], "joy_buttons": [JOY_BUTTON_X], "joy_axes": []},
	"dodge": {"keys": [KEY_K, KEY_SHIFT], "joy_buttons": [JOY_BUTTON_B], "joy_axes": []},
	"jump": {"keys": [KEY_SPACE], "joy_buttons": [JOY_BUTTON_A], "joy_axes": []},
	"sprint": {"keys": [KEY_L], "joy_buttons": [], "joy_axes": [[JOY_AXIS_TRIGGER_LEFT, 1.0]]},
	# Echo-Magie
	"echo_cast": {"keys": [KEY_I], "joy_buttons": [], "joy_axes": [[JOY_AXIS_TRIGGER_RIGHT, 1.0]]},
	"echo_prev": {"keys": [KEY_Q], "joy_buttons": [JOY_BUTTON_LEFT_SHOULDER], "joy_axes": []},
	"echo_next": {"keys": [KEY_R], "joy_buttons": [JOY_BUTTON_RIGHT_SHOULDER], "joy_axes": []},
	# Welt & Menüs
	"interact": {"keys": [KEY_E, KEY_ENTER], "joy_buttons": [JOY_BUTTON_Y], "joy_axes": []},
	"inventory": {"keys": [KEY_TAB], "joy_buttons": [JOY_BUTTON_BACK], "joy_axes": []},
	"pause": {"keys": [KEY_ESCAPE], "joy_buttons": [JOY_BUTTON_START], "joy_axes": []},
	# Anzeige
	"toggle_fullscreen": {"keys": [KEY_F11], "joy_buttons": [], "joy_axes": []},
	"debug_cycle_resolution": {"keys": [KEY_F2], "joy_buttons": [], "joy_axes": []},
}


func _init() -> void:
	# Alte Spiel-Aktionen entfernen, damit gelöschte Aktionen nicht liegen bleiben.
	for prop in ProjectSettings.get_property_list():
		var setting: String = prop.name
		if setting.begins_with("input/") and not setting.begins_with("input/ui_"):
			ProjectSettings.clear(setting)

	for action: String in ACTIONS:
		var spec: Dictionary = ACTIONS[action]
		var events: Array = []
		for keycode: Key in spec.keys:
			var ev := InputEventKey.new()
			ev.device = -1
			ev.physical_keycode = keycode
			events.append(ev)
		for button: JoyButton in spec.joy_buttons:
			var ev := InputEventJoypadButton.new()
			ev.device = -1
			ev.button_index = button
			events.append(ev)
		for axis_spec: Array in spec.joy_axes:
			var ev := InputEventJoypadMotion.new()
			ev.device = -1
			ev.axis = axis_spec[0]
			ev.axis_value = axis_spec[1]
			events.append(ev)
		ProjectSettings.set_setting("input/" + action, {"deadzone": DEADZONE, "events": events})

	var err := ProjectSettings.save()
	if err != OK:
		push_error("Konnte project.godot nicht speichern: %s" % error_string(err))
		quit(1)
		return
	print("Input-Map geschrieben: %d Aktionen." % ACTIONS.size())
	quit(0)
