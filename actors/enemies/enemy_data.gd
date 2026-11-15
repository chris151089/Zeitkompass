## Werte eines Gegnertyps. Instanzen: data/enemies/<name>.tres
class_name EnemyData
extends Resource

@export var display_name: String = ""
@export var sprite_frames: SpriteFrames
@export var max_health: int = 3
@export_group("Bewegung")
@export var move_speed: float = 40.0
@export var acceleration: float = 600.0
## Ab dieser Entfernung bemerkt der Gegner den Helden.
@export var sight_range: float = 110.0
## Ab dieser Entfernung holt er zum Angriff aus (bzw. beginnt zu umkreisen).
@export var attack_range: float = 30.0
## > 0: umkreist den Helden so lange, bevor er ausholt (Skelett).
@export var strafe_time: float = 0.0
@export var strafe_speed: float = 40.0
@export_group("Angriff")
@export var attack: AttackData
## Ausholen: der Gegner leuchtet rot auf – lesbare Vorwarnung für den Spieler.
@export var windup_time: float = 0.5
@export var attack_dash_speed: float = 150.0
@export var attack_time: float = 0.25
## Pause nach dem Angriff – Gelegenheit zum Kontern.
@export var recover_time: float = 0.6
@export_group("Treffer")
@export var hurt_time: float = 0.25
## 0 = voller Rückstoß, 1 = unbeweglich.
@export_range(0.0, 1.0, 0.05) var knockback_resistance: float = 0.0
