## „Kael ist gefallen“ – wartet auf Bestätigung und meldet dann retry_requested.
class_name GameOverScreen
extends CanvasLayer

signal retry_requested


func _ready() -> void:
	visible = false


func show_screen() -> void:
	visible = true


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_accept"):
		get_viewport().set_input_as_handled()
		retry_requested.emit()
