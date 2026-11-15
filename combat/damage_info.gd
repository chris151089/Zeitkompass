## Ein einzelner Treffer: wie viel Schaden, wohin geschleudert, wie stark das Feedback.
class_name DamageInfo
extends RefCounted

var amount: int = 1
## Rückstoß als Geschwindigkeit (Richtung * Stärke in px/s).
var knockback: Vector2 = Vector2.ZERO
## Kurzes Einfrieren des Spiels in Sekunden.
var hitstop: float = 0.0
## Bildschirmwackeln (Stärke in Pixeln, 0 = keins).
var shake: float = 0.0
var source: Node


static func create(
	amount: int, knockback: Vector2, hitstop: float = 0.0, shake: float = 0.0, source: Node = null
) -> DamageInfo:
	var info := DamageInfo.new()
	info.amount = amount
	info.knockback = knockback
	info.hitstop = hitstop
	info.shake = shake
	info.source = source
	return info
