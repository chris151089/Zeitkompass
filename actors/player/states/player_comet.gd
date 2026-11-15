## Kometenstoß: aus einem Sprung aus dem Rennen heraus (X halten → A → B in der Luft)
## schießt Kael mit vorgestrecktem Stab waagerecht nach vorn und trifft alles auf dem Weg.
## Pose: Stoß-Frame der Animation „sprint“, festgehalten; dazu ein Funkenschweif.
extends State

## Frame aus „sprint“ mit vorgestrecktem Stab (laut hero_sheet.json ein Treffer-Frame).
const POSE_FRAME := 3
## Prallt Kael gegen eine Wand, endet der Stoß vorzeitig.
const WALL_STOP_SPEED := 30.0
## Während des Stoßes nur mit der Welt kollidieren: Kael fliegt durch Gegner hindurch
## und trifft so auch mehrere hintereinander.
const WORLD_ONLY_MASK := 1

var _normal_mask: int

var _direction: Vector2
var _time_left: float
var _sparks: CPUParticles2D

@onready var _player: Player = owner


func _ready() -> void:
	_sparks = _make_sparks()
	_player.add_child.call_deferred(_sparks)


func enter(_previous: StringName) -> void:
	_direction = _player.facing_vector()
	_time_left = _player.combat.comet_time
	_normal_mask = _player.collision_mask
	_player.collision_mask = WORLD_ONLY_MASK
	_player.restart_animation(&"sprint", POSE_FRAME, 0.0)  # Pose halten
	_player.velocity = _direction * _player.combat.comet_speed
	_player.hitbox.activate(_player.combat.comet_attack, _direction)
	_sparks.direction = -_direction
	_sparks.emitting = true


func exit() -> void:
	_player.collision_mask = _normal_mask
	_player.hitbox.deactivate()
	_sparks.emitting = false
	_player.sprite.speed_scale = 1.0


func physics_update(delta: float) -> void:
	_player.velocity = _direction * _player.combat.comet_speed
	_player.move_and_slide()
	_player.hitbox.activate(_player.combat.comet_attack, _direction)
	_time_left -= delta
	var blocked := _player.get_real_velocity().length() < WALL_STOP_SPEED
	if _time_left <= 0.0 or blocked:
		_player.carry_on_moving()


func _make_sparks() -> CPUParticles2D:
	var sparks := CPUParticles2D.new()
	sparks.name = "CometSparks"
	sparks.position = Vector2(0, -10)
	sparks.emitting = false
	sparks.amount = 48
	sparks.lifetime = 0.35
	sparks.spread = 35.0
	sparks.initial_velocity_min = 30.0
	sparks.initial_velocity_max = 70.0
	sparks.scale_amount_min = 2.0
	sparks.scale_amount_max = 3.5
	sparks.local_coords = false
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0, 0.95, 0.6))
	ramp.set_color(1, Color(1.0, 0.45, 0.1, 0.0))
	sparks.color_ramp = ramp
	return sparks
