# Anforderungen

Inhaltsverzeichnis aller Einträge des [Backlogs](../backlog.md), geordnet nach den Fähigkeiten des Produkts. Jede
ID steht genau einmal, dort, wo sie hauptsächlich hingehört; Querbezüge stehen in der Datei des Eintrags unter
„Bezüge“. Hinter dem Titel steht der Abschnitt im Backlog, ✓ heißt erledigt. Bugs, Recherchen und Tests stehen
nur hier, solange sie offen sind; ihre Dateien liegen in [bugs/](bugs/), [research/](research/) und
[tests/](tests/) und bleiben als Nachweis erhalten.

Ein Eintrag bekommt eine eigene Datei `ID.md`, sobald er mehr braucht als seine Zeilen im Backlog, spätestens vor
„Bereit“ (Vorlage: [template.md](template.md), Regeln: process/workflow.md, „Anforderungen“). Ohne Datei führt der
Link zum Backlog.

- **Backlog:** der Index mit Titel, Merkmalen, Abschnitt, Reife und Commit.
- **Datei des Eintrags:** die Analyse, also was gewollt ist, warum, welche Varianten es gab, was entschieden und
  was noch offen ist.
- **Spezifikation** (doc/reference.md, doc/api.md, doc/app.md): wie es nach der Umsetzung ist.

## Rechnen

### Stack

(noch keine)

### Zahlen und Formate

- [FR-3](../backlog.md) Anzeigeformat (z.B. FIX) als Einstellung des Rechners · Angedacht

### Funktionen

- [FR-1](../backlog.md) sinh, cosh und tanh im Rechner (die Tasten zeigen sie schon auf Shift) · ✓

### Variablen und Tags

(noch keine)

### Programmierung

- [FR-5](../backlog.md) print und input: Programme geben Text aus und fragen Werte ab · Angedacht
- [VR-2](../backlog.md) Grenze für loop und times einstellbar, danach parser und calculator privat · Angedacht
- [RR-4](../backlog.md) Unbenannte Code-Blöcke: wie geht der Nutzer mit Blöcken auf dem Code-Stapel um, die keinen Namen haben? · Angedacht
- [FR-6](../backlog.md) Code-Debugger · Angedacht

### Fehler und Undo

- [RR-1](../backlog.md) Einheitliche Fehlercodes für Grammatik und Rechner (z.B. X1)? · Angedacht
- [RR-2](../backlog.md) Verwerfen nach einem Fehler: braucht es neben Return eine eigene Taste? · Angedacht
- [VR-7](../backlog.md) Löschen nach einem Fehler nimmt alle Tasten danach auf einmal zurück · ✓
- [FR-4](../backlog.md) Undo über ein Änderungsprotokoll (Journal) · Angedacht

## Sprache

### Grammatik

- [DS-1](../backlog.md) EBNF in reference.md auf den Stand der Sprache bringen · ✓
- [RS-2](../backlog.md) Felder: Reihenfolge der Elemente (heute ist Element 0 der damalige Tos) · Geplant

### Zeichen und Namen

- [FS-4](../backlog.md) Alle Buchstaben außer A–Z gelten wie Kleinbuchstaben, auch in Namen (ä, ß, ẋ, ω …) · Angedacht

### Sonderzeichen

- [FS-5](../backlog.md) Symbolschreibweise: `\name ` bis einschließlich Leerzeichen wird vor dem DEA durch ein Zeichen ersetzt · Angedacht

### Skriptformat

- [RS-1](../backlog.md) Version des Skriptformats: was passiert mit Code aus einer älteren Sprachversion? · Geplant

## Bibliotheken

### Domänen

- [FA-7](../backlog.md) Fachbereiche statt Domänen: Bibliotheken und Programme ein- und ausschalten · Angedacht
- [FL-2](../backlog.md) Einzelne Funktionen einer Bibliothek als intern kennzeichnen (z.B. Hilfsfunktionen wie rw, osz) · ✓
- [VA-11](../backlog.md) Der Name interner Funktionen ist auf der Seite Funktionen kaum von den anderen zu unterscheiden · ✓

### Bibliotheken laden

- [FA-12](../backlog.md) Bibliotheken zur Laufzeit hinzufügen: Download, Datei, „Öffnen mit …“ · Angedacht

### Einheiten

- [FS-1](../backlog.md) Einheiten in [ ] · Angedacht

### Konstanten

(noch keine)

## Bedienung

### App: Anzeige

- [FA-19](../backlog.md) Die aktuelle Eingabezeile bleibt beim Blättern im Verlauf stehen und bekommt dafür einen eigenen Hintergrund · Angedacht
- [FA-20](FA-20.md) Mausrad in den Bereichen der Anzeige: Verlauf, Stack, Variablen, Funktionen, Hilfe · Angedacht
- [FA-24](../backlog.md) Senkrechtes Wischen in Eingabe und Stack scrollt zeilenweise mit dem Finger, mit Nachlauf · ✓

### App: Tastenfeld

- [FA-1](../backlog.md) Rechenfunktion klein unter dem Zeichen von ~ (±) und | (□|.□, zwei Kästen für Ganzzahl- und Nachkommateil) · ✓
- [VA-2](../backlog.md) Nach `~` bzw. `|` die Tasten mit einem dünnen Rand markieren, die dann eine andere Bedeutung haben · ✓
- [FA-10](../backlog.md) SHIFT-Taste mit dem Zeichen ⇧, vielleicht nur das Zeichen · Angedacht
- [FA-18](../backlog.md) Freie Taste in R2 (Buchstabe d) mit AC und „Eingabebereich löschen“ belegen · ✗ abgelehnt
- [FA-25](../backlog.md) Taste CL (Zeile löschen) auf der freien Taste d, mit Shift AC (Eingabe und Stack mit Tags löschen) · ✓
- [VA-16](../backlog.md) AC kehrt zur Seite Rechnen zurück und wählt die Eingabe · ✓
- [FA-21](../backlog.md) ENTER und Return auf der PC-Tastatur (und Alpha ⏎) wirken mehrmals hintereinander · ✓
- [FA-11](../backlog.md) Verhalten der Enter-Taste einstellbar: nur Leerzeichen oder Leerzeichen und Zeilenumbruch · Angedacht
- [FA-14](../backlog.md) F2–F10 mit eigenen Funktionen belegen · ✗ abgelehnt

### App: Funktionstasten

- [FA-3](../backlog.md) Wischen und Mausrad über die Funktionstasten blättern durch ihre Seiten · ✓
- [FA-23](../backlog.md) Im Hilfe-Modus blättern Mausrad und Wischen die Funktionstasten, ein Klick in den Rahmen zeigt die Hilfe zur Seite · ✓
- [FA-26](FA-26.md) Variablen auf den Funktionstasten blättern: mehr als zehn, mit Mausrad, Wischen und Pfeilen · Angedacht
- [VA-15](VA-15.md) Funktionen und Variablen: Liste der Anzeige und Tastenblock als zwei Bereiche, Klick wechselt · ✓
- [VA-4](../backlog.md) Am PC färbt sich der Block der Funktionstasten leicht orange, solange die Maus darüber steht · ✓
- [VA-10](../backlog.md) Mausrad schiebt die Funktionstasten sichtbar wie Text, beim Loslassen rasten sie ein · ✓
- [VA-13](../backlog.md) Mausrad über den Funktionstasten: beim langsamen Drehen rastet es zu schnell ein · ✓
- [VA-14](../backlog.md) Im Bereich Funktionen blättern die Pfeiltasten mit ◄ ►, passend wäre ▲ ▼ · ✓

### App: Alpha und Symbole

- [FA-2](../backlog.md) ALPHA ohne „ABC“: oben links in Orange später das Symbol von Shift+ALPHA (z.B. „Symbol“) · Angedacht
- [FA-9](../backlog.md) Shift+ALPHA stellt die Zeichen bereit, aus denen man Symbole baut (\ ^ . - < …), mit Vorschau · Angedacht
- [FA-15](../backlog.md) Punkte über Buchstaben im Alpha-Modus: Shift+: setzt ¨ (ä ö ü ẍ), Shift+. setzt ˙ (ẋ) · Angedacht

### App: Zwischenablage

- [FA-4](../backlog.md) Zwischenablage in der App: Kontextmenü in der Anzeige, Strg+C/V und `\c \s \v` · ✓
- [VA-12](../backlog.md) Werte aus dem Stack mit „Text einfügen“ in der Schreibweise des Rechners einsetzen, mit Leerzeichen statt ; · ✓

### App: Tooltips

- [FA-22](../backlog.md) Ein Tastendruck auf der PC-Tastatur blendet die Tooltips aus, bis die Maus auf ein anderes Element wechselt · ✓
- [VA-1](../backlog.md) Tooltip von ' auch mit „als Präfix: …“ wie bei ~ und | · Vorgeschlagen

### App: Menü und Einstellungen

- [FA-6](../backlog.md) Menü auf dem Tastenfeld nach scratchpad/Menue.md · Angedacht
- [FA-16](../backlog.md) Zeilenmodus (zuschaltbar): erst bei ENTER rechnen, frühere Zeilen übernehmen und korrigieren · Angedacht
- [RA-1](../backlog.md) Welche Tasten wirken auf welcher Seite der Anzeige? · Angedacht

### App: Layout und Schrift

- [FA-5](../backlog.md) Querformat: Anzeige oben über die volle Breite, darunter drei Tastenfelder · Angedacht
- [VA-3](VA-3.md) JuliaMono als mitgelieferte Monospace-Schrift, auf die benötigten Zeichen beschnitten · Vorgeschlagen

### Hilfe

- [DG-1](../backlog.md) Hilfetexte und Tooltips auf der Prüfseite durchgehen und abhaken · ✓
- [DG-3](../backlog.md) Hilfetexte so überarbeiten, dass sie zeigen, wie man mit dem Rechner arbeitet · Angedacht
- [DG-4](../backlog.md) Hilfetexte: Funde aus DG-1 (Protokoll vom 2026-11-06) einarbeiten · ✓
- [DG-5](../backlog.md) Startseite der Hilfe und „Alle Zeichen und Namen“ neu gliedern · ✓
- [VA-5](../backlog.md) Verweise einer Hilfeseite in Gruppen mit kleiner Überschrift („Zeichen“, „Funktionen und Befehle“, „Themen“) · Angedacht
- [FA-17](../backlog.md) Hilfe zu einem beliebigen Namen in der App, wie `\?name` in der Konsole · Angedacht
- [FK-1](../backlog.md) Verweise in der Hilfe der Konsole mit Nummern wählen, Backspace zurück, Esc verlässt · Geplant

### Mehrsprachigkeit

- [FA-13](../backlog.md) Mehrsprachigkeit der Oberfläche mit flutter_localizations · Angedacht
- [FR-2](../backlog.md) Mehrsprachigkeit der Texte des Rechners: Hilfe und Meldungen je Sprache · Angedacht
- [VR-3](../backlog.md) Texte der Oberflächen und Fehlermeldungen auslagern wie die Hilfe des Rechners · Angedacht

### Konsole

- [FK-2](../backlog.md) Konsolenmenü zum Benutzen statt zum Testen überarbeiten · Angedacht

### Socket und CLI

(noch keine)

## Daten

### Persistenz

- [RG-2](../backlog.md) Persistenz in allen Umgebungen: was wird wo gespeichert, und was folgt daraus? · Geplant
- [FA-8](../backlog.md) Sitzungen: letzter Stand automatisch, benannte Sitzungen mit Verlauf · Angedacht

### Import und Export

- [VR-1](../backlog.md) Import-Fehler als Daten mit Zeilennummer, damit die App die Stelle markieren kann · Geplant

## Plattformen

### Windows

- [PT-1](../backlog.md) `--exe` für tool/veroeffentlichen.dart: Windows-Version bauen und als Release hochladen · Vorgeschlagen

### Browser

- [FW-1](FW-1.md) Browser-Version installierbar und offline nutzbar (PWA) · Geplant

### Android

(noch keine)

## Für später

### Zahlen mit hoher Genauigkeit

- [FL-1](../backlog.md) Bibliothek für hohe Genauigkeit: Zahlen mit viel mehr Stellen statt num · Für die Zukunft

### Komplexe Zahlen

- [FS-3](../backlog.md) Komplexe Zahlen als eigener Zahlentyp · Für die Zukunft

### Multidimensionale Objekte

- [FS-2](../backlog.md) Vektoren, Matrizen und Tabellen in ( ) · Angedacht

### Lua

- [FS-6](../backlog.md) Lua-Unterstützung: Lua-Code im rpncalc-Code, Lua-Bibliotheken, Ein- und Ausgabe mit Plots · Für die Zukunft

### Chronos, Finanz, Strings

(noch keine)

## Projekt

### Prozess

- [PG-1](../backlog.md) Backlog und Arbeitsregeln in process/ einführen, offene Punkte aus app.md und api.md übernehmen · ✓
- [PG-2](../backlog.md) Reifegrad 0–5 für alle offenen Einträge, als Gate: In Arbeit und Bereit 5, Erforderlich und Geplant ab 4 · ✓
- [PG-3](../backlog.md) Ein Ordner für die Ergebnisse von Tests und Reviews · ✓
- [PG-4](../backlog.md) Anforderungen in process/requirements/: eine Datei je Eintrag, Inhaltsverzeichnis nach Fähigkeiten · ✓

### Werkzeuge

- [DG-2](../backlog.md) CHANGELOG.md aus „Erledigt“ erzeugen, für das öffentliche Repository und den Text eines Releases · ✓
- [PT-2](../backlog.md) tool/requirements.dart: Inhaltsverzeichnis der Anforderungen aus Gliederung und Backlog erzeugen · Vorgeschlagen

### Architektur und Code

- [RG-4](../backlog.md) Logging, um Laufzeitfehler zu finden · Angedacht
- [VA-6](../backlog.md) App: englische Dateinamen, Ordner model/, display/, keypad/, anzeige.dart teilen · ✓
- [VA-7](../backlog.md) tastenfeld.dart teilen: Tastenfeld aus Blöcken, Taste, Cursorkreuz, Zeichnungen · ✓
- [VA-8](../backlog.md) modell.dart über part-Dateien teilen: Kern und Mixins nach Aufgaben · ✓
- [VA-9](../backlog.md) Bedienmodi: Rechnen und Hilfe als eigene Objekte, statt hilfeModus an jeder Stelle abzufragen · ✓
- [VR-4](../backlog.md) Excel-Format aus der Konsole lösen: die App importiert nur noch rpnapi.dart · ✓
- [VR-5](../backlog.md) Rechner nach lib/src mit englischen Dateinamen, Türen console.dart und net.dart · ✓
- [VR-6](../backlog.md) RpnApi wird reine Tür: die Verarbeitung kommt in einen Interpreter, Daten, Bibliotheken und Hilfe in lib/src · ✓
- [VG-1](../backlog.md) Aufräumen nach DG-6: veraltete Kommentare, rpnGramma, help_texts.dart nach Sprache teilen · ✓
- [VG-2](../backlog.md) Englische Bezeichner auf Deutsch · Vorgeschlagen
- [VG-3](../backlog.md) Aufräumen nach RG-3: Logging-Reste und obsolete Felder entfernen, Konsolenmenü vereinfachen · ✓

### Dokumentation

- [DG-6](../backlog.md) Kopfkommentare in allen übrigen Dateien, architecture.md auf den erreichten Stand · ✓
