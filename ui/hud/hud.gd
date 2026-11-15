## Lebensanzeige: ein Herz pro 2 Lebenspunkte (voll / halb / leer).
class_name Hud
extends CanvasLayer

const HEARTS := preload("res://assets/sprites/ui/hearts.png")
const HEART_SIZE := Vector2i(9, 8)
const HP_PER_HEART := 2
enum HeartState { FULL, HALF, EMPTY }

@onready var _row: HBoxContainer = $Hearts


func bind_health(health: Health) -> void:
	health.health_changed.connect(_on_health_changed)
	_on_health_changed(health.current, health.max_health)


## Zustand jedes Herzens (für Tests und Debugging).
func heart_states() -> Array[int]:
	var states: Array[int] = []
	for heart: TextureRect in _row.get_children():
		states.append(int((heart.texture as AtlasTexture).region.position.x) / HEART_SIZE.x)
	return states


static func states_for(current: int, maximum: int) -> Array[int]:
	var states: Array[int] = []
	for i in ceili(maximum / float(HP_PER_HEART)):
		var hp := current - i * HP_PER_HEART
		states.append(HeartState.FULL if hp >= 2 else (HeartState.HALF if hp == 1 else HeartState.EMPTY))
	return states


func _on_health_changed(current: int, maximum: int) -> void:
	var states := states_for(current, maximum)
	while _row.get_child_count() < states.size():
		var heart := TextureRect.new()
		var atlas := AtlasTexture.new()
		atlas.atlas = HEARTS
		heart.texture = atlas
		_row.add_child(heart)
	while _row.get_child_count() > states.size():
		_row.get_child(-1).free()
	for i in states.size():
		var atlas := (_row.get_child(i) as TextureRect).texture as AtlasTexture
		atlas.region = Rect2(Vector2(states[i] * HEART_SIZE.x, 0), Vector2(HEART_SIZE))
