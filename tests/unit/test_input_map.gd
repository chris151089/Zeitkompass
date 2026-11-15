extends GutTest
## Jede Spiel-Aktion muss mit Tastatur UND Controller bedienbar sein.

const GAMEPLAY_ACTIONS: Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right",
	&"attack", &"dodge", &"jump", &"sprint",
	&"echo_cast", &"echo_prev", &"echo_next",
	&"interact", &"inventory", &"pause",
]

## Nur Tastatur: Anzeige/Debug.
const KEYBOARD_ONLY_ACTIONS: Array[StringName] = [&"toggle_fullscreen", &"debug_cycle_resolution"]


func test_gameplay_actions_have_keyboard_and_controller() -> void:
	for action in GAMEPLAY_ACTIONS:
		assert_true(InputMap.has_action(action), "%s existiert" % action)
		if not InputMap.has_action(action):
			continue
		var events := InputMap.action_get_events(action)
		assert_true(events.any(func(e): return e is InputEventKey), "%s: Tastatur" % action)
		assert_true(
			events.any(func(e): return e is InputEventJoypadButton or e is InputEventJoypadMotion),
			"%s: Controller" % action,
		)


func test_keyboard_only_actions_exist() -> void:
	for action in KEYBOARD_ONLY_ACTIONS:
		assert_true(InputMap.has_action(action), "%s existiert" % action)


func test_no_unlisted_game_actions() -> void:
	# Neue Aktionen bitte in tools/generate_input_map.gd UND hier eintragen.
	for action in InputMap.get_actions():
		if String(action).begins_with("ui_"):
			continue
		assert_true(
			action in GAMEPLAY_ACTIONS or action in KEYBOARD_ONLY_ACTIONS,
			"%s ist in den Tests bekannt" % action,
		)


func test_no_keyboard_key_bound_twice() -> void:
	var seen := {}
	for action in GAMEPLAY_ACTIONS + KEYBOARD_ONLY_ACTIONS:
		for e in InputMap.action_get_events(action):
			if e is InputEventKey:
				var key: int = e.physical_keycode
				assert_false(seen.has(key), "Taste %s doppelt (%s, %s)" % [OS.get_keycode_string(key), seen.get(key), action])
				seen[key] = action


## Bewusst geteilte Tasten (kontextabhängig): Controller-A = Springen oder Interagieren.
const SHARED_CONTROLLER_ACTIONS: Array[StringName] = [&"interact"]


func test_no_controller_input_bound_twice() -> void:
	var seen := {}
	for action in GAMEPLAY_ACTIONS:
		if action in SHARED_CONTROLLER_ACTIONS:
			continue
		for e in InputMap.action_get_events(action):
			var key := ""
			if e is InputEventJoypadButton:
				key = "button %d" % e.button_index
			elif e is InputEventJoypadMotion:
				key = "axis %d %s" % [e.axis, signf(e.axis_value)]
			else:
				continue
			assert_false(seen.has(key), "Controller %s doppelt (%s, %s)" % [key, seen.get(key), action])
			seen[key] = action


func test_xbox_layout() -> void:
	var expect := {
		&"attack": JOY_BUTTON_B, &"jump": JOY_BUTTON_A, &"sprint": JOY_BUTTON_X, &"interact": JOY_BUTTON_A,
	}
	for action: StringName in expect:
		var ok := InputMap.action_get_events(action).any(
			func(e): return e is InputEventJoypadButton and e.button_index == expect[action]
		)
		assert_true(ok, "%s liegt auf Taste %d" % [action, expect[action]])
	var roll_rt := InputMap.action_get_events(&"dodge").any(
		func(e): return e is InputEventJoypadMotion and e.axis == JOY_AXIS_TRIGGER_RIGHT
	)
	assert_true(roll_rt, "Rolle liegt auf RT")


func test_run_is_on_xbox_x() -> void:
	var on_x := InputMap.action_get_events(&"sprint").any(
		func(e): return e is InputEventJoypadButton and e.button_index == JOY_BUTTON_X
	)
	assert_true(on_x, "Rennen liegt auf X (Xbox)")


func test_move_vector_from_simulated_input() -> void:
	Input.action_press(&"move_right")
	Input.action_press(&"move_up")
	var v := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	Input.action_release(&"move_right")
	Input.action_release(&"move_up")
	assert_almost_eq(v, Vector2(1, -1).normalized(), Vector2(0.01, 0.01))
