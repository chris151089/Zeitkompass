## Werte eines Angriffs (Spieler oder Gegner). Instanzen in data/.
class_name AttackData
extends Resource

@export var damage: int = 1
## Rückstoß für das Ziel in px/s.
@export var knockback: float = 140.0
## Einfrieren bei Treffer in Sekunden (Hitstop).
@export_range(0.0, 0.3, 0.005, "suffix:s") var hitstop: float = 0.06
## Bildschirmwackeln bei Treffer (Pixel, 0 = keins).
@export_range(0.0, 8.0, 0.5) var shake: float = 0.0
## Größe der Trefferzone.
@export var hitbox_size: Vector2 = Vector2(18, 14)
## Abstand der Trefferzone vor der Figur (in Blickrichtung).
@export var hitbox_distance: float = 12.0
## Vorwärtsbewegung während des Schlags.
@export var lunge_speed: float = 40.0
