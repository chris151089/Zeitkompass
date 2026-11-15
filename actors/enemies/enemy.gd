## Basis für alle Gegner. Das Verhalten steckt in den Zuständen (actors/enemies/states/),
## die Werte in EnemyData. Ziel ist der Knoten in der Gruppe „player“.
class_name Enemy
extends CharacterBody2D

signal died(enemy: Enemy)

@export var data: EnemyData

var pending_knockback: Vector2 = Vector2.ZERO
## Richtung des nächsten/aktuellen Angriffs (beim Ende des Ausholens festgelegt).
var attack_direction: Vector2 = Vector2.RIGHT

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	add_to_group(&"enemies")
	sprite.sprite_frames = data.sprite_frames
	sprite.play(&"idle")
	HitFeedback.setup_flash(sprite)
	health.setup(data.max_health)
	hurtbox.hurt.connect(_on_hurtbox_hurt)


## Der Held, oder null wenn keiner da (oder er besiegt ist).
func target() -> Node2D:
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	if player == null or (player is Player and (player as Player).health.is_dead()):
		return null
	return player


func vector_to_target() -> Vector2:
	var t := target()
	return t.global_position - global_position if t else Vector2.ZERO


func distance_to_target() -> float:
	var t := target()
	return global_position.distance_to(t.global_position) if t else INF


func face_towards(direction: Vector2) -> void:
	if absf(direction.x) > 0.01:
		sprite.flip_h = direction.x < 0.0


## Beschleunigt auf die gewünschte Geschwindigkeit und bewegt sich.
func move_with(desired: Vector2, delta: float) -> void:
	velocity = velocity.move_toward(desired, data.acceleration * delta)
	move_and_slide()


func play(anim: StringName, speed_scale: float = 1.0) -> void:
	sprite.speed_scale = speed_scale
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)


## Setzt das rote Ausholen-Leuchten (0 = aus).
func set_warning_glow(amount: float) -> void:
	var material := sprite.material as ShaderMaterial
	material.set_shader_parameter(&"flash_color", Color(1.0, 0.2, 0.2))
	material.set_shader_parameter(&"flash", amount)


func _on_hurtbox_hurt(info: DamageInfo) -> void:
	health.take_damage(info.amount)
	hitbox.deactivate()
	pending_knockback = info.knockback * (1.0 - data.knockback_resistance)
	HitFeedback.flash(sprite, Color.WHITE, 0.15)
	HitFeedback.hitstop(get_tree(), info.hitstop)
	HitFeedback.shake(get_tree(), info.shake, 0.18)
	state_machine.transition_to(&"Dead" if health.is_dead() else &"Hurt")
