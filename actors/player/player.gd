## Der Held Kael. Bewegung, Animation und Treffer-Reaktion; Entscheidungen treffen die
## Zustände in StateMachine (Idle, Move, Run, Attack, SprintAttack, JumpAttack, Roll, Hurt, Dead).
class_name Player
extends CharacterBody2D

signal facing_changed(facing: TopDownMotion.Facing)
## Nach der Todes-Ausblendung (das Level zeigt dann „Erneut versuchen“).
signal died

@export var movement: MovementData
@export var combat: PlayerCombatData

var facing: TopDownMotion.Facing = TopDownMotion.Facing.DOWN
## Rückstoß des letzten Treffers (vom Zustand Hurt verbraucht).
var pending_knockback: Vector2 = Vector2.ZERO
var _roll_invulnerable: bool = false
var _hurt_invulnerable_time: float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox
@onready var state_machine: StateMachine = $StateMachine
@onready var _camera: FollowCamera = $Camera


func _ready() -> void:
	add_to_group(&"player")
	HitFeedback.setup_flash(sprite)
	health.setup(combat.max_health)
	hurtbox.hurt.connect(_on_hurtbox_hurt)


func _physics_process(delta: float) -> void:
	if _hurt_invulnerable_time > 0.0:
		_hurt_invulnerable_time -= delta
	hurtbox.invulnerable = _roll_invulnerable or _hurt_invulnerable_time > 0.0 or health.is_dead()
	# Blinken während der Schonzeit nach einem Treffer
	var blinking := _hurt_invulnerable_time > 0.0 and not health.is_dead()
	sprite.visible = not blinking or int(_hurt_invulnerable_time * 16.0) % 2 == 0


func get_move_input() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


func is_run_held() -> bool:
	return Input.is_action_pressed(&"sprint")


## Startet Rolle, Sprung- oder Angriff, falls gerade gedrückt. true = Zustand gewechselt.
func try_start_action(running: bool) -> bool:
	if Input.is_action_just_pressed(&"dodge"):
		state_machine.transition_to(&"Roll")
	elif Input.is_action_just_pressed(&"jump"):
		state_machine.transition_to(&"JumpAttack")
	elif Input.is_action_just_pressed(&"attack"):
		state_machine.transition_to(&"SprintAttack" if running else &"Attack")
	else:
		return false
	return true


## Bewegt den Helden einen Physik-Schritt (input = Vector2.ZERO bremst ab).
func apply_movement(input: Vector2, delta: float, running: bool = false) -> void:
	velocity = TopDownMotion.approach_velocity(velocity, input, movement, delta, running)
	move_and_slide()


## Bremst mit der normalen Reibung ab.
func decelerate(delta: float, factor: float = 1.0) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, movement.friction * factor * delta)
	move_and_slide()


func update_facing(direction: Vector2) -> void:
	var new_facing := TopDownMotion.facing_from_vector(direction, facing)
	if new_facing != facing:
		facing = new_facing
		facing_changed.emit(facing)


func facing_vector() -> Vector2:
	match facing:
		TopDownMotion.Facing.LEFT:
			return Vector2.LEFT
		TopDownMotion.Facing.RIGHT:
			return Vector2.RIGHT
		TopDownMotion.Facing.UP:
			return Vector2.UP
	return Vector2.DOWN


## Eingabe-Richtung, sonst Blickrichtung (für Rolle, Sprung, Angriffe).
func action_direction() -> Vector2:
	var input := get_move_input()
	return input.normalized() if not input.is_zero_approx() else facing_vector()


## Spielt "<base>_<richtung>", z. B. walk_left. speed_scale passt die Abspielgeschwindigkeit an.
func play_animation(base: StringName, speed_scale: float = 1.0) -> void:
	var anim := _anim_name(base)
	sprite.speed_scale = speed_scale
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)


## Startet "<base>_<richtung>" neu ab from_frame (für Angriffe, Rolle, Sprung).
func restart_animation(base: StringName, from_frame: int = 0) -> void:
	sprite.speed_scale = 1.0
	sprite.play(_anim_name(base))
	sprite.set_frame_and_progress(from_frame, 0.0)


func set_roll_invulnerable(value: bool) -> void:
	_roll_invulnerable = value


func is_invulnerable() -> bool:
	return hurtbox.invulnerable


## Begrenzt die Kamera auf einen Bereich in Pixeln (vom Level aufgerufen).
func set_camera_limits(rect: Rect2i) -> void:
	_camera.limit_left = rect.position.x
	_camera.limit_top = rect.position.y
	_camera.limit_right = rect.end.x
	_camera.limit_bottom = rect.end.y
	_camera.snap_to_target()


func _anim_name(base: StringName) -> StringName:
	return StringName("%s_%s" % [base, TopDownMotion.facing_name(facing)])


func _on_hurtbox_hurt(info: DamageInfo) -> void:
	health.take_damage(info.amount)
	hitbox.deactivate()
	pending_knockback = info.knockback
	# Sofort schützen – nicht erst im nächsten Physik-Schritt (sonst zählen zwei Treffer gleichzeitig).
	hurtbox.invulnerable = true
	HitFeedback.flash(sprite, Color(1.0, 0.35, 0.35), 0.2)
	HitFeedback.hitstop(get_tree(), info.hitstop)
	HitFeedback.shake(get_tree(), maxf(info.shake, 2.0), 0.2)
	if health.is_dead():
		state_machine.transition_to(&"Dead")
	else:
		_hurt_invulnerable_time = combat.invulnerable_after_hurt
		state_machine.transition_to(&"Hurt")
