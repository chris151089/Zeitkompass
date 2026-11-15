## Besiegt: kurzer Treffer-Stopp, rutscht vom letzten Schlag weg, Todesanimation,
## blinkt und verpufft in einer Staubwolke.
extends State

const DEATH_HITSTOP := 0.12
const DEATH_SHAKE := 2.0
const SLIDE_FRICTION := 500.0
const BLINKS := 4
const BLINK_TIME := 0.07

var _finished_animation: bool = false

@onready var _enemy: Enemy = owner


func enter(_previous: StringName) -> void:
	_finished_animation = false
	_enemy.hitbox.deactivate()
	_enemy.set_deferred(&"collision_layer", 0)
	_enemy.set_deferred(&"collision_mask", 1)  # rutscht nicht durch Wände
	_enemy.hurtbox.set_deferred(&"monitorable", false)
	_enemy.velocity = _enemy.pending_knockback
	_enemy.play(&"death")
	_enemy.died.emit(_enemy)
	HitFeedback.hitstop(_enemy.get_tree(), DEATH_HITSTOP)
	HitFeedback.shake(_enemy.get_tree(), DEATH_SHAKE, 0.15)
	_enemy.sprite.animation_finished.connect(_on_sprite_animation_finished, CONNECT_ONE_SHOT)


func physics_update(delta: float) -> void:
	_enemy.velocity = _enemy.velocity.move_toward(Vector2.ZERO, SLIDE_FRICTION * delta)
	_enemy.move_and_slide()


func _on_sprite_animation_finished() -> void:
	if _finished_animation:
		return
	_finished_animation = true
	var tween := _enemy.create_tween()
	for i in BLINKS:
		tween.tween_property(_enemy.sprite, ^"visible", false, BLINK_TIME)
		tween.tween_property(_enemy.sprite, ^"visible", true, BLINK_TIME)
	tween.tween_callback(_vanish)


func _vanish() -> void:
	HitFeedback.spawn_puff(_enemy.get_parent(), _enemy.position + Vector2(0, -8))
	_enemy.queue_free()
