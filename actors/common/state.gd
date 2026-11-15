## Basisklasse für einen Zustand im StateMachine-Knoten.
## Zustände sind Kind-Knoten der StateMachine; ihr Knotenname ist der Zustandsname.
class_name State
extends Node

## Wird von der StateMachine gesetzt.
var state_machine: StateMachine


func enter(_previous: StringName) -> void:
	pass


func exit() -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
