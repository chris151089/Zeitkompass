# CLAUDE.md – Zeitkompass

2D-Action-RPG in Pixel-Art, top-down, Echtzeitkampf. **Das vollständige Design steht in
[docs/design.md](docs/design.md) – vor jeder größeren Aufgabe lesen.** Diese Datei fasst nur die
verbindlichen Regeln zusammen.

## Eckdaten

- **Engine:** Godot **4.7.2** (stable), GDScript, Renderer „Compatibility“ (OpenGL)
- **Interne Auflösung:** 640 × 360, ganzzahlig skaliert (720p ×2, 1080p ×3, 1440p ×4, 4K ×6);
  krumme Bildschirme bekommen schwarze Ränder, nie unscharfe Pixel
- **Projekteinstellungen (nicht ändern):** Stretch `viewport`, Aspect `keep`, Scale Mode `integer`,
  Texturfilter `Nearest`, 2D-Pixel-Snapping an – abgesichert durch `tests/unit/test_project_settings.gd`
- **Kachelgröße:** 32 × 32, Karten mit `TileMapLayer` (nicht das alte `TileMap`)
- **Figuren:** ca. 32 × 48 Pixel
- **Ziel:** Windows-PC, später optional Linux/Web

## Aktueller Stand

- **Fertig:** M0 – Setup (Projekt, Ordner, GUT-Tests, Skalierung geprüft in 1080p/1440p/4K,
  Input-Map; vom Nutzer unter Windows mit Tastatur und Controller bestätigt)
- **Als Nächstes: M1 – Bewegung:** Held läuft in 8 Richtungen mit Animationen, Kollision mit Wänden,
  Kamera folgt flüssig, Testkarte aus Kacheln
- Ein Meilenstein ist erst fertig, wenn **alle** Kriterien aus `docs/design.md` erfüllt sind –
  vorher nichts Neues anfangen. Abschnitt „Aktueller Stand“ nach jedem Meilenstein aktualisieren.

## Architektur-Regeln

- **Autoloads nur für globale Dienste:** `GameState`, `SaveManager`, `AudioManager`,
  `DialogueManager`, `SceneLoader` (in `autoload/`). Keine weiteren ohne guten Grund.
- **Signale statt direkter Verweise** zwischen Szenen. Eltern dürfen Kinder direkt ansprechen,
  Kinder melden sich per Signal nach oben („call down, signal up“).
- **Hitbox/Hurtbox-System** (`combat/`) für **jeden** Schaden – Spieler, Gegner, Fallen.
- **Zustandsautomat** für Spieler und Gegner (Idle, Laufen, Angriff, Rolle, Treffer, Tod).
- **Daten getrennt vom Code:** Werte von Gegnern, Items, Echos als `.tres`-Resources in `data/`.
  Keine Balancing-Zahlen im Code.
- **Speicherstände** als JSON mit Versionsnummer (`SaveManager.SAVE_VERSION`) + Migration.
- **Szenenwechsel** nur über `SceneLoader.change_scene()`, nie direkt `change_scene_to_file()`.
- **Eingaben nur über Input-Map-Aktionen**, nie feste Tasten im Code.

## Input-Map

Quelle der Wahrheit ist `tools/generate_input_map.gd`. Neue Aktion → dort eintragen, ausführen
(`godot --headless --script res://tools/generate_input_map.gd`) und in `tests/unit/test_input_map.gd`
ergänzen. Jede Spiel-Aktion braucht Tastatur **und** Controller.

| Aktion | Tastatur | Controller |
| --- | --- | --- |
| `move_*` | WASD / Pfeile | linker Stick / D-Pad |
| `attack` | J | X |
| `dodge` | K / Shift | B |
| `jump` | Leertaste | A |
| `sprint` | L | LT |
| `echo_cast` | I | RT |
| `echo_prev` / `echo_next` | Q / R | LB / RB |
| `interact` | E / Enter | Y |
| `inventory` | Tab | Back/Select |
| `pause` | Esc | Start |
| `toggle_fullscreen`, `debug_cycle_resolution` | F11, F2 | – |

## Konventionen

- **Dateien und Ordner:** `snake_case` (`player.tscn`, `player.gd`); Szene und Skript gleichnamig
  im selben Ordner
- **Klassen:** `class_name` in `PascalCase`, nur wenn die Klasse woanders gebraucht wird
- **Knoten im Szenenbaum:** `PascalCase` (`Hitbox`, `AnimationPlayer`)
- **Signale:** `snake_case`, Vergangenheitsform für Ereignisse (`died`, `health_changed`,
  `door_opened`); Handler heißen `_on_<knoten>_<signal>`
- **Konstanten:** `UPPER_SNAKE_CASE`; private Member mit `_`-Präfix
- **Statische Typen** überall (`var speed: float`, `-> void`)
- **Resources:** Skript `*_data.gd` (`class_name EnemyData`), Instanzen in `data/<typ>/<name>.tres`
- **Sprache:** Code-Bezeichner Englisch, Kommentare und Doku Deutsch
- **Debug-/Testszenen** in `levels/test/`

## Tests

- Framework: **GUT 9.7.1** (`addons/gut/`), Tests in `tests/` mit Präfix `test_`
- Unit-Tests: `GODOT=/pfad/zu/godot ./run_tests.sh`
- Skalierung per Screenshot (Linux mit Xvfb): `GODOT=/pfad/zu/godot tools/check_scaling.sh`
- CI: `.github/workflows/tests.yml` führt beides bei jedem Push aus
- Neue Logik möglichst als testbare, szenenunabhängige Funktionen schreiben und Tests mitliefern

## Assets & Lizenzen

- Jedes fremde Asset mit Quelle und Lizenz in [docs/credits.md](docs/credits.md) eintragen
- **Tabu:** keine Grafiken, Musik, Namen oder Texte aus Terranigma oder anderen Spielen

## Arbeitsweise

1. Pro Session ein Meilenstein oder eine Teilaufgabe, nie „das ganze Spiel“
2. Erst einen kurzen Plan schreiben, dann umsetzen
3. Tests laufen lassen; der Nutzer testet selbst in Godot und gibt Feedback
4. Funktioniert es: Git-Commit mit klarer Nachricht
