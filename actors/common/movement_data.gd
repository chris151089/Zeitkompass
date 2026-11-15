## Bewegungswerte einer Figur. Instanzen liegen in data/<typ>/*.tres.
class_name MovementData
extends Resource

## Höchstgeschwindigkeit in Pixeln pro Sekunde.
@export_range(0.0, 400.0, 1.0, "suffix:px/s") var max_speed: float = 110.0
## Beschleunigung beim Loslaufen und Richtungswechsel.
@export_range(0.0, 5000.0, 10.0, "suffix:px/s²") var acceleration: float = 1000.0
## Abbremsen, wenn keine Eingabe anliegt.
@export_range(0.0, 5000.0, 10.0, "suffix:px/s²") var friction: float = 1400.0
