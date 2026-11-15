## Der Held. Bewegung und Animation; Entscheidungen treffen die Zustände in StateMachine.
class_name Player
extends CharacterBody2D

signal facing_changed(facing: TopDownMotion.Facing)

@export var movement: MovementData

var facing: TopDownMotion.Facing = TopDownMotion.Facing.DOWN

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _camera: FollowCamera = $Camera
@onready var state_machine: StateMachine = $StateMachine


func get_move_input() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


## Bewegt den Helden einen Physik-Schritt (input = Vector2.ZERO bremst ab).
func apply_movement(input: Vector2, delta: float) -> void:
	velocity = TopDownMotion.approach_velocity(velocity, input, movement, delta)
	move_and_slide()


func update_facing(direction: Vector2) -> void:
	var new_facing := TopDownMotion.facing_from_vector(direction, facing)
	if new_facing != facing:
		facing = new_facing
		facing_changed.emit(facing)


## Spielt "<base>_<richtung>", z. B. walk_left. speed_scale passt die Abspielgeschwindigkeit an.
func play_animation(base: StringName, speed_scale: float = 1.0) -> void:
	var anim := StringName("%s_%s" % [base, TopDownMotion.facing_name(facing)])
	_sprite.speed_scale = speed_scale
	if _sprite.animation != anim or not _sprite.is_playing():
		_sprite.play(anim)


## Begrenzt die Kamera auf einen Bereich in Pixeln (vom Level aufgerufen).
func set_camera_limits(rect: Rect2i) -> void:
	_camera.limit_left = rect.position.x
	_camera.limit_top = rect.position.y
	_camera.limit_right = rect.end.x
	_camera.limit_bottom = rect.end.y
	_camera.snap_to_target()
