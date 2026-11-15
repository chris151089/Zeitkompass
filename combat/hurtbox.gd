## Verwundbare Zone einer Figur. Nimmt Treffer von Hitboxen an.
class_name Hurtbox
extends Area2D

signal hurt(info: DamageInfo)

## Während Ausweichrolle oder nach einem Treffer: Treffer werden ignoriert.
var invulnerable: bool = false


func _ready() -> void:
	monitoring = false
	monitorable = true


## Gibt true zurück, wenn der Treffer angenommen wurde.
func receive(info: DamageInfo) -> bool:
	if invulnerable:
		return false
	hurt.emit(info)
	return true
