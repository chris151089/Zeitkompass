## Bewegungswerte einer Figur. Instanzen liegen in data/<typ>/*.tres.
class_name MovementData
extends Resource

## Höchstgeschwindigkeit beim Gehen in Pixeln pro Sekunde.
@export_range(0.0, 300.0, 1.0, "suffix:px/s") var max_speed: float = 72.0
## Höchstgeschwindigkeit beim Rennen (Aktion „sprint“ gehalten).
@export_range(0.0, 400.0, 1.0, "suffix:px/s") var run_speed: float = 120.0
## Beschleunigung beim Loslaufen und Richtungswechsel.
@export_range(0.0, 5000.0, 10.0, "suffix:px/s²") var acceleration: float = 650.0
## Abbremsen, wenn keine Eingabe anliegt.
@export_range(0.0, 5000.0, 10.0, "suffix:px/s²") var friction: float = 900.0
