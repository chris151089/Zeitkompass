## Schadenszone eines Angriffs. Wird für die Treffer-Frames aktiviert und trifft
## jede Hurtbox pro Aktivierung höchstens einmal.
class_name Hitbox
extends Area2D

signal hit_landed(hurtbox: Hurtbox)

## Höhe der Körpermitte über den Füßen – dort sitzt die Trefferzone.
@export var body_height: float = 10.0

var attack: AttackData
var direction: Vector2 = Vector2.RIGHT
var _already_hit: Dictionary = {}
var _active: bool = false

@onready var _shape: CollisionShape2D = $Shape


func _ready() -> void:
	monitorable = false
	monitoring = false
	# Jede Instanz braucht ihre eigene Form, weil Größe/Lage pro Angriff gesetzt werden.
	_shape.shape = _shape.shape.duplicate()


func activate(new_attack: AttackData, new_direction: Vector2) -> void:
	attack = new_attack
	direction = new_direction.normalized() if not new_direction.is_zero_approx() else Vector2.RIGHT
	(_shape.shape as RectangleShape2D).size = attack.hitbox_size
	_shape.position = direction * attack.hitbox_distance + Vector2(0, -body_height)
	if not _active:
		_already_hit.clear()
	_active = true
	monitoring = true


func deactivate() -> void:
	_active = false
	_already_hit.clear()
	monitoring = false


func is_active() -> bool:
	return _active


func _physics_process(_delta: float) -> void:
	if not _active:
		return
	for area in get_overlapping_areas():
		var hurtbox := area as Hurtbox
		if hurtbox == null or _already_hit.has(hurtbox) or hurtbox.owner == owner:
			continue
		_already_hit[hurtbox] = true
		if hurtbox.receive(_make_damage(hurtbox)):
			hit_landed.emit(hurtbox)


func _make_damage(target: Hurtbox) -> DamageInfo:
	var from := (owner as Node2D).global_position if owner is Node2D else global_position
	var to := (target.owner as Node2D).global_position if target.owner is Node2D else target.global_position
	var away := (to - from).normalized()
	if away.is_zero_approx():
		away = direction
	return DamageInfo.create(attack.damage, away * attack.knockback, attack.hitstop, attack.shake, owner)
