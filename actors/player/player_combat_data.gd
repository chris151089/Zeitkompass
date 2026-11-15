## Kampfwerte des Helden. Instanz: data/player/player_combat.tres
class_name PlayerCombatData
extends Resource

## Lebenspunkte (2 = ein Herz).
@export var max_health: int = 6
## Die drei Schläge der Combo.
@export var combo: Array[AttackData] = []
## Stoß am Ende des Sprints.
@export var sprint_attack: AttackData
## Schlag von oben nach dem Sprung.
@export var jump_attack: AttackData
## Tempo des Sprintangriffs (Stoß nach vorn).
@export var sprint_attack_speed: float = 170.0
## Tempo des Sprungs nach vorn.
@export var jump_attack_speed: float = 80.0
## Tempo der Ausweichrolle.
@export var roll_speed: float = 150.0
## Wie lange Kael nach einem Treffer zurückgeschleudert wird.
@export_range(0.0, 1.0, 0.01, "suffix:s") var hurt_time: float = 0.25
## Unverwundbar nach einem Treffer (Kael blinkt).
@export_range(0.0, 3.0, 0.05, "suffix:s") var invulnerable_after_hurt: float = 1.0
