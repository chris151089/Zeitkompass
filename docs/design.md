# Design-Dokument: Action-RPG (Arbeitstitel „Zeitkompass“)

Stand: 2026-11-14

## Spielidee & Pitch

Ein 2D-Action-RPG in Pixel-Art, top-down, im Geist der großen SNES-Klassiker: Echtzeitkampf, Dungeons mit Rätseln und eine Welt, die sich sichtbar verändert, je weiter man kommt. Eigene Welt, eigene Story, eigene Grafik.

**Pitch in einem Satz:** Der Zeitstrom der Welt ist zerbrochen, jede Region ist in einem anderen Moment erstarrt – und nur der Held kann sie mit einem alten Kompass wieder in Gang setzen.

**Story-Grundidee (Vorschlag):**

- **Held:** Kael, ein junger Bastler von einer Leuchtturminsel, findet im Keller seines Großvaters den *Zeitkompass*.
- **Konflikt:** Eine Katastrophe hat die Zeit „angehalten“. Wälder stehen im ewigen Herbst, eine Hafenstadt ist mitten im Sturm eingefroren, ein Wüstenreich steckt in der Nacht fest.
- **Ziel:** In jedem Dungeon liegt ein *Zeitkern*. Wer ihn zurückholt, lässt die Region wieder laufen – Menschen erwachen, Städte wachsen, neue Wege öffnen sich.
- **Wendung (später):** Jemand hat die Zeit absichtlich angehalten, um eine noch größere Katastrophe zu verhindern. Der Held muss sich fragen, ob er das Richtige tut.

**Ton:** abenteuerlich und warm, mit melancholischen Momenten. Kein Grimdark, aber auch keine reine Kinderstory.

## Kernmechaniken

Der Kampf muss sich vom ersten Prototyp an gut anfühlen – alles andere baut darauf auf.

**1. Echtzeitkampf**

- Grundangriff mit kurzer 3er-Combo
- Sprintangriff (Anlauf, dann Stoß) und Sprungangriff (Sprung, Schlag von oben)
- Ausweichrolle mit kurzen Unverwundbarkeits-Frames
- Treffer-Feedback: Gegner blinkt, kurzer Rückschlag, Mini-Freeze („Hitstop“), Bildschirmwackeln bei starken Treffern
- Gegner mit klaren Angriffsmustern, die man lesen und kontern kann

**2. Echo-Magie**

- In Dungeons findet man *Echos* – erstarrte Zeitfragmente mit einem Element (Feuer, Eis, Wind, Erde)
- Ein Echo ist ein verbrauchbarer Zauber; im Dorf kann man Echos zu stärkeren Varianten kombinieren
- Manche Echos dienen auch als Rätsel-Werkzeug (Eis friert Wasser, Wind bewegt Plattformen)

**3. Fortschritt**

- Erfahrungsstufen erhöhen Leben, Angriff und Verteidigung
- Ausrüstung: Waffe und Rüstung, jeweils mit sichtbarem Werteunterschied
- Neue Fähigkeiten aus Dungeons schalten früher unerreichbare Wege frei (z. B. Kletterhaken, Doppelsprung)

**4. Lebendige Welt**

- Jede befreite Region läuft wieder: NPCs erwachen, Läden öffnen, das Dorf wird größer
- Kleine Nebenaufgaben im Dorf beschleunigen den Ausbau (Handwerker finden, Brücke reparieren)
- Der Ausbau ist sichtbar: neue Gebäude, mehr Leute auf der Straße, neue Waren

**5. Dungeons**

- Pro Dungeon ein Leitthema und eine neue Fähigkeit, die im Dungeon selbst gelernt und gebraucht wird
- Mischung aus Kampfräumen, Schalter- und Blockrätseln, verschlossenen Türen mit Schlüsseln
- Am Ende ein Boss mit 2–3 Phasen, der die neue Fähigkeit abfragt

## Umfang

Ziel Nummer eins ist ein **Vertical Slice**: ein kleines, aber komplett fertiges Stück des Spiels in Endqualität. Erst wenn das Spaß macht, wird die Welt erweitert.

| | Vertical Slice | Volles Spiel (Fernziel) |
| --- | --- | --- |
| Dorf | 1 Startdorf | 1 Hauptdorf, das mitwächst, + 3–4 Städte |
| Regionen | 1 Oberwelt-Gebiet | 5–6 Regionen |
| Dungeons | 1 Dungeon mit Boss | 6–8 Dungeons |
| Gegnertypen | 4–5 | 30+ |
| Echos | 2 Elemente | 4 Elemente mit Kombinationen |
| Spielzeit | 30–60 Minuten | 10–15 Stunden |

Wichtig: Das volle Spiel ist ein Projekt über Jahre, auch mit KI-Hilfe. Der Vertical Slice ist in einigen Monaten Freizeit realistisch.

## Technik

Godot 4 mit GDScript, ein Git-Repository von Tag eins an, Spieldaten als Godot-Resources statt fest im Code.

**Eckdaten**

- Engine: Godot 4 (aktuelle stabile Version), Sprache GDScript
- Interne Auflösung: 640 × 360 Pixel – gleiche Breite wie To the Moon (640 × 480), aber im 16:9-Format, damit es auf modernen Bildschirmen und in 4K ohne Ränder und gestochen scharf skaliert
- Skalierung: nur ganzzahlig, damit Pixel scharf bleiben – 720p = Faktor 2, 1080p = Faktor 3, 1440p = Faktor 4, **4K (3840 × 2160) = Faktor 6**
- Godot-Einstellungen: Stretch Mode `viewport`, Aspect `keep`, Scale Mode `integer`, Texturfilter `Nearest`, Pixel-Snapping an
- Optionsmenü: Auflösung (bis 4K), Vollbild / randloses Fenster, V-Sync; Bildschirme mit krummen Maßen bekommen schmale schwarze Ränder statt unscharfer Pixel
- Kachelgröße: 32 × 32 Pixel (wie To the Moon), Karten mit TileMapLayer
- Steuerung: Controller und Tastatur über Input-Map-Aktionen (nie feste Tasten im Code)
- Ziel-Plattform: Windows-PC, später optional Linux und Web

**Projektstruktur**

```
res://
  autoload/      GameState, SaveManager, AudioManager, DialogueManager, SceneLoader
  actors/        player/, enemies/, npcs/
  combat/        Hitbox, Hurtbox, Damage, Effekte
  data/          items/, enemies/, echos/, dialogues/ (.tres-Resources)
  levels/        overworld/, town/, dungeon_01/
  ui/            HUD, Menüs, Dialogbox, Inventar
  assets/        sprites/, tilesets/, audio/, fonts/
  tests/         automatische Tests (GUT oder gdUnit4)
docs/            dieses Design-Dokument, Notizen
```

**Architektur-Regeln**

- **Autoloads** nur für globale Dienste: Spielstand, Speichern, Audio, Dialoge, Szenenwechsel
- **Kommunikation über Signale** statt direkter Verweise zwischen Szenen
- **Hitbox/Hurtbox-System** für allen Schaden, egal ob Spieler, Gegner oder Falle
- **Zustandsautomat** (State Machine) für Spieler und Gegner: Idle, Laufen, Angriff, Rolle, Treffer, Tod
- **Daten getrennt vom Code:** Werte von Gegnern, Items und Echos stehen in Resources, damit man balancen kann, ohne Code anzufassen
- **Speicherstände** als JSON mit Versionsnummer, damit alte Spielstände nach Updates nicht kaputtgehen

## Grafik & Audio

Für den Vertical Slice reichen fertige Asset-Pakete aus einer einheitlichen Quelle. Eigene Grafik lohnt sich erst, wenn das Spiel trägt.

- **Stil:** Pixel-Art in der Detailstufe von To the Moon, 32 × 32-Kacheln, Figuren etwa 32 × 48 Pixel, begrenzte Farbpalette für einen einheitlichen Look
- **Quellen für Grafik:** itch.io (viele günstige Top-down-RPG-Pakete), OpenGameArt (kostenlos); möglichst alles von einem Künstler oder in einem Stil
- **Eigene Grafik:** Aseprite zum Zeichnen und Animieren, Export als Spritesheet
- **Musik und Sound:** fertige Pakete von itch.io oder Freesound; später eigene Musik oder Auftragsarbeit
- **Lizenzen:** Bei jedem Paket die Lizenz prüfen (kommerzielle Nutzung, Namensnennung) und in `docs/credits.md` festhalten
- **Tabu:** keine Grafiken, Musik, Namen oder Texte aus Terranigma oder anderen Spielen übernehmen

## Meilensteine

Sieben Etappen bis zum Vertical Slice. Ein Meilenstein gilt erst als fertig, wenn alle Kriterien erfüllt sind – vorher wird nichts Neues angefangen.

1. **M0 – Setup** ✅ (abgeschlossen 2026-11-15)
    - Godot-Projekt mit Ordnerstruktur, Git-Repository, Testframework läuft
    - Auflösung und Skalierung stimmen, getestet in 1080p, 1440p und 4K, Input-Map für Controller und Tastatur angelegt
2. **M1 – Bewegung**
    - Held läuft in 8 Richtungen mit Animationen, Kollision mit Wänden
    - Kamera folgt flüssig, Testkarte aus Kacheln
3. **M2 – Kampf**
    - Combo, Sprint- und Sprungangriff, Ausweichrolle, Hitstop und Treffer-Feedback
    - 2 Gegnertypen mit Zustandsautomat, Lebensanzeige im HUD, Tod und Neustart
    - Test: Fühlt sich der Kampf nach 10 Minuten noch gut an?
4. **M3 – Dungeon**
    - Ein kompletter Dungeon mit 8–12 Räumen, Schlüsseln, 2–3 Rätseltypen
    - Neue Fähigkeit im Dungeon, Boss mit 2 Phasen
5. **M4 – Systeme**
    - Inventar und Ausrüstung, Erfahrungsstufen, 2 Echo-Elemente
    - Speichern und Laden mit Versionsnummer
6. **M5 – Dorf & Dialoge**
    - Startdorf mit NPCs, Dialogsystem, Laden
    - Dorf verändert sich sichtbar nach dem Dungeon
7. **M6 – Vertical Slice**
    - Oberwelt verbindet Dorf und Dungeon, Intro und Abschluss-Szene
    - Musik und Sound, Hauptmenü, Optionen mit Auflösung bis 4K
    - 3 Testspieler spielen durch, ihr Feedback ist eingearbeitet

## Arbeiten mit Claude Code

Diese Datei als `docs/design.md` ins Projekt legen und in der `CLAUDE.md` darauf verweisen – dann kennt Claude in jeder Session das Ziel.

**Ablauf pro Session**

1. Einen Meilenstein oder eine Teilaufgabe nennen, nie „mach das ganze Spiel“
2. Claude zuerst einen kurzen Plan schreiben lassen, dann umsetzen
3. Selbst in Godot testen und konkretes Feedback geben („die Rolle ist zu kurz“, „der Gegner trifft durch Wände“)
4. Funktioniert es: Git-Commit. Geht etwas kaputt, lässt es sich so jederzeit zurückdrehen

**In die `CLAUDE.md` gehört**

- Godot-Version, Auflösung, Kachelgröße
- Die Architektur-Regeln aus dem Abschnitt Technik
- Aktueller Meilenstein und was als Nächstes kommt
- Eigene Konventionen, z. B. Namensschema für Szenen und Signale

**Wann Opus, wann Fable**

- **Opus:** Alltag – einzelne Features, UI, Dialoge, kleine Bugs
- **Fable:** Architektur-Entscheidungen zu Beginn, Kampfsystem und Gegner-KI, Speichersystem, hartnäckige Bugs über mehrere Systeme, größere Umbauten

## Offene Entscheidungen

- [ ] Story: Vorschlag mit Zeitkompass übernehmen oder eigene Idee?
- [ ] Name des Spiels und des Helden
- [ ] Welches Asset-Paket bestimmt den Grafikstil?
- [ ] Nur PC oder auch Web-Version (zum einfachen Teilen mit Testspielern)?
- [ ] Wie viel Zeit pro Woche ist realistisch? Danach richtet sich, wie groß der erste Dungeon wird
