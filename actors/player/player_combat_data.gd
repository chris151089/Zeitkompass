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
## Kometenstoß (Rennen → Sprung → Angriff in der Luft): Treffer, Flugtempo und -dauer.
@export var comet_attack: AttackData
@export var comet_speed: float = 260.0
@export_range(0.05, 1.0, 0.01, "suffix:s") var comet_time: float = 0.35
## Tempo der Ausweichrolle.
@export var roll_speed: float = 165.0
## Abspieltempo der Rollen-Animation (< 1 = längere Rolle, mehr Strecke).
@export_range(0.3, 2.0, 0.05) var roll_animation_speed: float = 0.75
## Wie lange Kael nach einem Treffer zurückgeschleudert wird.
@export_range(0.0, 1.0, 0.01, "suffix:s") var hurt_time: float = 0.25
## Unverwundbar nach einem Treffer (Kael blinkt).
@export_range(0.0, 3.0, 0.05, "suffix:s") var invulnerable_after_hurt: float = 1.0
