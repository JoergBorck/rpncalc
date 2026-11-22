# Lessons Learned – Claude

Was Claude bei der Arbeit am RPN-Rechner über die eigene Arbeitsweise gelernt hat. Aufbau wie
[lessons.md](lessons.md): was passiert ist, was daraus folgt. Fallen der Werkzeuge (Bash unter Windows) stehen in
Claudes lokalem Gedächtnis, weil sie nur dort gebraucht werden.

## 2026-11-21 Muster in `.ignore` ohne Pfad

Der erste Versuch für PG-7 (`lib/src/libraries/libraries.g.dart` in `.ignore`) hat nicht gewirkt: ripgrep wendet
ein Muster mit Pfad relativ zum Ordner an, in dem die Suche beginnt; eine Suche in lib/ fand die Datei weiter.

**Folge:** Ausschlüsse für die Suche ohne Pfad schreiben (`libraries.g.dart`) und mit einer Suche in einem
Unterordner prüfen, nicht nur von der Wurzel aus.

## 2026-11-21 Vor dem Entwurf einer Tastenbelegung die Regeln in doc/app.md 3.4 lesen

Die Belegung mit Shift in FR-15 war schon besprochen, als Claude die Regel „auf `~` ⇧ immer die Umkehrung, `|` ⇧
nicht erreichbar“ fand; sie musste nachträglich geändert werden.

**Folge:** Bei jeder neuen Belegung zuerst doc/app.md 3.4 und keys.dart ansehen und Konflikte gleich mit dem
Vorschlag nennen.

## 2026-11-21 Große Dateien, die jede Sitzung gelesen werden, klein halten

Der Backlog war mit 1143 Zeilen nach einer Zusammenfassung zu groß, um ihn mitzugeben; mehr als die Hälfte war
Geschichte.

**Folge:** Was Claude jede Sitzung liest (Backlog, CLAUDE.md), enthält nur Aktuelles; Geschichte kommt in eigene
Dateien (done.md). Beim Prozess-Review auf Dateien achten, die wachsen.
