## Lebenspunkte einer Figur. Meldet Änderungen per Signal (z. B. an das HUD).
class_name Health
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 6

var current: int


func _ready() -> void:
	if current == 0:
		current = max_health


## Setzt Maximum und füllt auf (von der Figur mit Werten aus ihrer Resource aufgerufen).
func setup(maximum: int) -> void:
	max_health = maximum
	current = maximum
	health_changed.emit(current, max_health)


func take_damage(amount: int) -> void:
	if is_dead() or amount <= 0:
		return
	current = maxi(0, current - amount)
	health_changed.emit(current, max_health)
	if current == 0:
		died.emit()


func heal(amount: int) -> void:
	if is_dead() or amount <= 0:
		return
	current = mini(max_health, current + amount)
	health_changed.emit(current, max_health)


func is_dead() -> bool:
	return current <= 0
