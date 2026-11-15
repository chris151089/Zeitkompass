## Einfacher Zustandsautomat für Spieler und Gegner.
## Kind-Knoten vom Typ State sind die Zustände; gewechselt wird mit transition_to().
class_name StateMachine
extends Node

signal state_changed(from: StringName, to: StringName)

@export var initial_state: State

var current: State
var _states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			_states[child.name] = child
			child.state_machine = self
	# Erst starten, wenn die ganze Figur bereit ist (Zustände greifen auf sie zu).
	if owner != null and not owner.is_node_ready():
		await owner.ready
	current = initial_state
	if current != null:
		current.enter(&"")


func _unhandled_input(event: InputEvent) -> void:
	if current != null:
		current.handle_input(event)


func _process(delta: float) -> void:
	if current != null:
		current.update(delta)


func _physics_process(delta: float) -> void:
	if current != null:
		current.physics_update(delta)


func transition_to(state_name: StringName) -> void:
	var next: State = _states.get(state_name)
	if next == null:
		push_error("Unbekannter Zustand: %s" % state_name)
		return
	if next == current:
		return
	var previous := current.name if current != null else &""
	if current != null:
		current.exit()
	current = next
	current.enter(previous)
	state_changed.emit(previous, current.name)


func current_state_name() -> StringName:
	return current.name if current != null else &""
