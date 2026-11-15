extends GutTest
## Lebenspunkte und Lebensanzeige.

var health: Health


func before_each() -> void:
	health = Health.new()
	add_child_autofree(health)
	health.setup(6)


func test_damage_reduces_and_clamps() -> void:
	health.take_damage(2)
	assert_eq(health.current, 4)
	health.take_damage(10)
	assert_eq(health.current, 0)
	assert_true(health.is_dead())


func test_died_is_emitted_once() -> void:
	watch_signals(health)
	health.take_damage(6)
	health.take_damage(1)
	assert_signal_emit_count(health, "died", 1)


func test_heal_caps_at_max_and_not_when_dead() -> void:
	health.take_damage(3)
	health.heal(10)
	assert_eq(health.current, 6)
	health.take_damage(6)
	health.heal(2)
	assert_eq(health.current, 0, "Tote werden nicht geheilt")


func test_health_changed_reports_values() -> void:
	watch_signals(health)
	health.take_damage(1)
	assert_signal_emitted_with_parameters(health, "health_changed", [5, 6])


func test_hud_heart_states() -> void:
	var F := Hud.HeartState.FULL
	var H := Hud.HeartState.HALF
	var E := Hud.HeartState.EMPTY
	assert_eq(Hud.states_for(6, 6), [F, F, F] as Array[int])
	assert_eq(Hud.states_for(5, 6), [F, F, H] as Array[int])
	assert_eq(Hud.states_for(2, 6), [F, E, E] as Array[int])
	assert_eq(Hud.states_for(0, 6), [E, E, E] as Array[int])
	assert_eq(Hud.states_for(3, 5).size(), 3, "ungerades Maximum: aufrunden")
