## Treffer-Feedback: Hitstop (kurzes Einfrieren), Bildschirmwackeln, Aufblitzen.
class_name HitFeedback
extends RefCounted

const FLASH_SHADER := preload("res://combat/flash.gdshader")
const SHAKE_GROUP := &"camera_shake"

static var _hitstop_until_ms: int = 0
## Kennnummer des jüngsten Hitstops – nur dieser darf die Zeit wieder anlaufen lassen.
## (Ein Uhrzeit-Vergleich ist unzuverlässig: Timer feuern am Bildtakt, ggf. eine ms „zu früh“,
## dann bliebe das Spiel für immer eingefroren.)
static var _hitstop_token: int = 0


## Friert das Spiel kurz ein. Überlappende Hitstops verlängern, statt sich zu stapeln.
static func hitstop(tree: SceneTree, duration: float) -> void:
	if duration <= 0.0 or tree == null:
		return
	var until := Time.get_ticks_msec() + int(duration * 1000.0)
	if until <= _hitstop_until_ms:
		return
	_hitstop_until_ms = until
	_hitstop_token += 1
	var token := _hitstop_token
	Engine.time_scale = 0.0
	await tree.create_timer(duration, true, false, true).timeout
	if token == _hitstop_token:
		_hitstop_until_ms = 0
		Engine.time_scale = 1.0


## Setzt alles zurück (z. B. nach Tests oder beim Szenenwechsel).
static func reset() -> void:
	_hitstop_until_ms = 0
	_hitstop_token += 1
	Engine.time_scale = 1.0


static func shake(tree: SceneTree, strength: float, duration: float = 0.2) -> void:
	if strength > 0.0 and tree != null:
		tree.call_group(SHAKE_GROUP, &"shake", strength, duration)


## Gibt dem Sprite ein eigenes Flash-Material (einmal in _ready aufrufen).
static func setup_flash(sprite: CanvasItem) -> void:
	var material := ShaderMaterial.new()
	material.shader = FLASH_SHADER
	material.set_shader_parameter(&"flash", 0.0)
	material.set_shader_parameter(&"flash_color", Color.WHITE)
	sprite.material = material


static func flash(sprite: CanvasItem, color: Color = Color.WHITE, duration: float = 0.15) -> void:
	var material := sprite.material as ShaderMaterial
	if material == null:
		return
	material.set_shader_parameter(&"flash_color", color)
	var tween := sprite.create_tween()
	tween.set_ignore_time_scale(true)  # läuft auch während des Hitstops ab
	tween.tween_method(
		func(v: float) -> void: material.set_shader_parameter(&"flash", v), 1.0, 0.0, duration
	)
