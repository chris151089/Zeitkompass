# Zeitkompass

Einfache Zeiterfassung für die Arbeit – eine einzige HTML-Datei, läuft im Browser auf Handy und PC, ohne Server und ohne Anmeldung.

## Funktionen

- **Kommen / Pause / Gehen** per Knopfdruck mit Live-Uhr
- Einträge **nachtragen, bearbeiten, löschen** (auch Schichten über Mitternacht)
- **Wochenansicht** (KW) mit Soll/Ist pro Tag
- **Monatsübersicht** mit CSV-Export und Druck/PDF
- Alle Stunden im **Dezimalformat** (z. B. 1 Std. 45 Min. = 1,75)
- **Überstundenkonto** inkl. Übertrag aus der Vergangenheit
- **Feiertage** automatisch für Österreich oder je deutschem Bundesland
- **Urlaub, halbe Urlaubstage, Krankenstand, Zeitausgleich** eintragen (auch als Zeitraum) mit Urlaubskonto
- Einstellbare Wochenstunden und Arbeitstage
- **Dienstplan** pro Wochentag (z. B. Mo–Do 9,25, Fr 6) mit Aufteilung in Einarbeitszeit und Mehrarbeit
- **Regelmäßiger Zeitausgleich** (jeder 2. Freitag frei)
- Optional **gesetzliche Mindestpause** (30 Min. ab 6 Std., AZG/ArbZG) wird automatisch abgezogen, wenn zu wenig Pause erfasst wurde
- **Backup** als JSON speichern und wieder laden

## Benutzung

`index.html` im Browser öffnen. Am Handy über „Zum Home-Bildschirm hinzufügen“ wie eine App nutzen.

Am einfachsten über GitHub Pages: *Settings → Pages → Branch auswählen → Save*, dann ist die App unter `https://<benutzer>.github.io/<repo>/` erreichbar.

## Daten

Alle Daten liegen nur im Browser des jeweiligen Geräts (localStorage). Sie werden nicht zwischen Geräten synchronisiert. Wenn Browserdaten gelöscht werden, sind die Einträge weg – deshalb regelmäßig unter *Einstellungen → Backup speichern* sichern.
