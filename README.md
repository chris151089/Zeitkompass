# Zeitkompass

2D-Action-RPG in Pixel-Art (Arbeitstitel), gebaut mit Godot 4.7 und GDScript.

- Design-Dokument: [docs/design.md](docs/design.md)
- Regeln für die Arbeit mit Claude Code: [CLAUDE.md](CLAUDE.md)

## Starten

Projekt in Godot 4.7.x öffnen (`project.godot`) und F5 drücken. Zurzeit startet das M0-Testbild:
F2 wechselt die Fenstergröße (720p → 4K), F11 schaltet Vollbild, alle Spiel-Aktionen werden angezeigt.

**Hinweis:** Godot startet das Spiel standardmäßig eingebettet im Tab „Game“. Dort lassen sich
Fenstergröße und Vollbild nicht ändern. Zum Testen der Auflösungen im Tab „Game“ oben rechts im
Drei-Punkte-Menü „Embed Game on Next Play“ abschalten – dann öffnet F5 ein eigenes Fenster.

## Tests

```bash
GODOT=/pfad/zu/godot ./run_tests.sh             # Unit-Tests (GUT)
GODOT=/pfad/zu/godot tools/check_scaling.sh     # Skalierung per Screenshot (Linux, Xvfb)
```

Im Editor: unten das Panel „GUT“ öffnen und „Run All“.
