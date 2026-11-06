# Backlog

Oben das Konkrete, in der Mitte das Diffuse, am Ende das Log. Regeln am Ende der Datei, Arbeitsweise in
[workflow.md](workflow.md).

## In Arbeit

## Bereit

### RG-1 Architektur-Review vor dem Menü: passt der Aufbau zu dem, was in „Angedacht“ steht?
Recherche · Gesamt · mittel · von Claude · angelegt 2026-11-03 · Reife 5
1. Aufteilung des Modells der App: `modell.dart` ist groß geworden.
2. Grenze zwischen API und Oberfläche: z.B. sind `parser` und `calculator` öffentlich (VR-2).
3. Wohin die Modi des Tastenfelds kommen (Menue.md 3.1).
4. Ob der Aufbau schon zu Menü, Fachbereichen, Querformat und Sitzungen passt (FA-5 bis FA-8).
Jörgs Vorschläge: (a) jede Datei bekommt einen Kopfkommentar: Aufgabe (~10 Zeilen), Abgrenzung zu anderen
Dateien (2–5), Verweise auf Dateien, die man zum Verständnis braucht (2–5); (b) Dateien über 500 Zeilen auf
Teilung prüfen (Stand: app/lib/modell.dart 967, anzeige.dart 871, tastenfeld.dart 621); (c) vage: Liste der
Klassen und welche Klassen sie benutzen, getrennt nach Rechner, App, Konsole; doc/architecture.md ist älter.
Dazu: die gemeinsame Speicherschicht der App, siehe RG-2.
Dazu die Frage aus RR-3: Sondertasten in der API als eigene Methoden oder als Steuerzeichen in taste()?

## Erforderlich

## Geplant

### FA-24 Senkrechtes Wischen in Eingabe und Stack scrollt zeilenweise mit dem Finger, mit Nachlauf
Verbesserung · App · klein · von Jörg · angelegt 2026-11-06 · Reife 5
Der Inhalt folgt dem Finger in Zeilenschritten: je Weg einer Zeilenhöhe eine Zeile (Höhe der 3. Zeile von oben,
da die Zeilen nach unten kleiner werden; pixelgenau passt nicht zu den wachsenden Schriftgrößen). Nach einer
schnellen Bewegung läuft es nach und bremst ab (Physik wie bei Android-Listen), an Anfang und Ende Halt.
Seitliches Wischen, langes Drücken und Doppeltipp bleiben. Am PC das Mausrad ebenso. Das Wischen wählt den
Bereich wie ein Tipp (entschieden 2026-11-06).

### VA-4 Am PC färbt sich der Block der Funktionstasten leicht orange, solange die Maus darüber steht
Verbesserung · App · klein · von Claude · angelegt 2026-11-06 · zu FA-3 · Reife 5
Zeigt, dass Mausrad (und Wischen) dort die Seiten blättern, auch ohne markierten Bereich. Am Handy bleibt der
kurze orange Rahmen beim Wischen. Entschieden 2026-11-06: nur der Hintergrund, ganz leicht orange (eigene Rolle
in farben.dart).

### FA-23 Im Hilfe-Modus die Seite Funktionen mit dem Mausrad scrollen können
Verbesserung · App · klein · von Jörg · angelegt 2026-11-06 · gefunden bei DG-1 · Reife 5
Heute fängt der Hilfe-Modus die Gesten ab. Nur das Mausrad scrollt die Liste, ein Tipp zeigt weiter die Hilfe.

### FL-2 Einzelne Funktionen einer Bibliothek als intern kennzeichnen (z.B. Hilfsfunktionen wie rw, osz)
Feature · Bibliotheken · mittel · von Jörg · angelegt 2026-11-03 · Reife 5
Interne Funktionen haben nur keine Funktionstaste; in der Liste der Seite Funktionen (dort kursiv) und in der
Hilfe stehen sie wie alle anderen. Gekennzeichnet mit dem Befehl `rpnintern` hinter der Funktion:
`{…}':rw rpnintern`. Er bezieht sich auf die zuletzt abgelegte Funktion (ohne eine: Fehler) und läuft nur beim
Laden, der Code der Funktion bleibt unverändert. „Funktionen speichern“ und der Export schreiben `rpnintern` mit;
wird die Funktion mit `'::` ersetzt, verliert sie die Markierung, außer es folgt wieder `rpnintern`.

### FK-1 Verweise in der Hilfe der Konsole mit Nummern wählen, Backspace zurück, Esc verlässt
Feature · Konsole · mittel · von Jörg · angelegt 2026-11-03 · alt: api.md 10 · Reife 4

### RG-2 Persistenz in allen Umgebungen: was wird wo gespeichert, und was folgt daraus?
Recherche · Gesamt · mittel · von Jörg · angelegt 2026-11-04 · Reife 4 · Grundlage für FA-8, FA-12
Umgebungen: Windows-App, Browser, Handy (Android, später iOS), Konsole und Socket-Server. Was gespeichert wird:
Sitzung und letzter Stand, hinzugefügte Bibliotheken, eigene Funktionen, Einstellungen (Winkel, Format,
Sprache), Zustand der App (Domäne, Prüfstatus der Hilfe?). Je Umgebung: Ort, Format (Skriptformat, JSON,
.rpnlib), Grenzen (localStorage etwa 5 MB, privater Ordner am Handy), Plugins und ihre Folgen (Entwicklermodus
beim Bauen), Export und Import zwischen Geräten, Verhalten bei Updates und beim Löschen der App. Ergebnis: eine
gemeinsame Speicherschicht der App und eigene Einträge.

### RS-1 Version des Skriptformats: was passiert mit Code aus einer älteren Sprachversion?
Recherche · Sprache · mittel · von Claude · angelegt 2026-11-03 · alt: api.md 6 · Reife 4

### RS-2 Felder: Reihenfolge der Elemente (heute ist Element 0 der damalige Tos)
Recherche · Sprache · klein · von Jörg · angelegt 2026-11-03 · alt: api.md 12 · Reife 4

### VR-1 Import-Fehler als Daten mit Zeilennummer, damit die App die Stelle markieren kann
Verbesserung · Rechner · klein · von Claude · angelegt 2026-11-03 · alt: api.md 2 · Reife 4

## Zurückgestellt

## Angedacht

### VA-5 Verweise einer Hilfeseite in Gruppen mit kleiner Überschrift („Zeichen“, „Funktionen und Befehle“, „Themen“)
Verbesserung · App · klein · von Claude · angelegt 2026-11-06 · zu DG-5 · Reife 4
Die Hilfe kennt heute nur eine flache Reihe von Verweisen. Darstellung in App (Überschrift über den Knöpfen)
und Konsole (eine Zeile je Gruppe); zuerst für die Startseite und „Alle Zeichen und Namen“.

### FA-19 Die aktuelle Eingabezeile bleibt beim Blättern im Verlauf stehen und bekommt dafür einen eigenen Hintergrund
Verbesserung · App · klein · von Jörg · angelegt 2026-11-04 · Reife 4
Beim Blättern mit ▲▼ steht die aktuelle Zeile immer oben, der Verlauf läuft darunter durch. Ein leicht anderer
Hintergrund zeigt, dass sie nicht zum Verlauf gehört.

### FA-20 Mausrad in den Bereichen der Anzeige: Verlauf, Stack, Variablen, Funktionen, Hilfe
Feature · App · klein · von Jörg · angelegt 2026-11-04 · Reife 4
Wie ▲▼ im jeweiligen Bereich: in der Eingabe durch den Verlauf, im Stack zu tieferen Werten; die Listen und der
Hilfeschirm blättern ohnehin schon. Ob das Mausrad den Bereich auch wählt, beim Umsetzen festlegen.

### FS-4 Alle Buchstaben außer A–Z gelten wie Kleinbuchstaben, auch in Namen (ä, ß, ẋ, ω …)
Feature · Sprache · mittel · von Jörg · angelegt 2026-11-03 · Voraussetzung für FA-15, hängt mit FS-5 zusammen · Reife 4
Nur A–Z bleiben Befehle. Regel für die Grammatik: Unicode-Buchstaben außer A–Z wie `kbu`, nachgestellte Akzente
gehören zum Buchstaben; vor dem Zerlegen auf fertige Zeichen umstellen (ẋ statt x + ˙), damit `ẋ` immer derselbe
Name ist. Operatorzeichen (² ³ ° ≤ ≥ ≠) bleiben Operatoren. Konsole und PC-Tastatur müssen die Zeichen tippen können.

### RR-1 Einheitliche Fehlercodes für Grammatik und Rechner (z.B. X1)?
Recherche · Rechner · klein · von Claude · angelegt 2026-11-03 · alt: api.md 1 · Reife 4

### RR-2 Verwerfen nach einem Fehler: braucht es neben Return eine eigene Taste?
Recherche · Rechner · klein · von Claude · angelegt 2026-11-03 · alt: api.md 8 · Reife 4

### RR-3 Sondertasten in der API: eigene Methoden oder Steuerzeichen in taste()?
Recherche · Rechner · klein · von Claude · angelegt 2026-11-03 · alt: api.md 9 (Sondertasten) · Reife 4

### FA-5 Querformat: Anzeige oben über die volle Breite, darunter drei Tastenfelder
Feature · App · groß · von Jörg · angelegt 2026-11-03 · alt: app.md 4 · Details: app.md 1.1 · Reife 3
Links R2–R5, Mitte Cursorkreuz und R1 als 2×3, rechts R6–R9. Zoom nach der Höhe, Tasten werden breiter.
Umschalten mit der freien Taste unter dem Kreuz; im Fenster nur das Layout, am Handy die Lage festlegen.

### FA-6 Menü auf dem Tastenfeld nach scratchpad/Menue.md
Feature · App · groß · von Jörg · angelegt 2026-11-03 · Details: scratchpad/Menue.md · Reife 3
Offen: Frage A (`~` als Präfix oder als Taste für die Ansicht).

### FA-15 Punkte über Buchstaben im Alpha-Modus: Shift+: setzt ¨ (ä ö ü ẍ), Shift+. setzt ˙ (ẋ)
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · gehört zu FA-9, braucht FS-4 · Reife 3
Nachgestellt wie in RPN und wie in Unicode: a, dann Shift+: ergibt ä, man schreibt einfach weiter; die App stellt
auf das fertige Zeichen um. Im Alpha-Modus steht ¨ bzw. ˙ orange oben links auf : und . Offen: wohin ß kommt.

### FA-10 SHIFT-Taste mit dem Zeichen ⇧, vielleicht nur das Zeichen
Feature · App · klein · von Jörg · angelegt 2026-11-03 · alt: app.md 22 · Reife 3

### FR-2 Mehrsprachigkeit der Texte des Rechners: Hilfe und Meldungen je Sprache
Feature · Rechner · groß · von Jörg · angelegt 2026-11-03 · alt: api.md 14 · Reife 3
`hilfe.en.rpnlib` mit denselben Kennungen, Einstellung `sprache`, Fehlermeldungen über `meldungen` in rpnjson.

### FR-4 Undo über ein Änderungsprotokoll (Journal)
Feature · Rechner · groß · von Jörg · angelegt 2026-11-03 · alt: api.md 7 · Details: api.md 9.2 · Reife 3
Offen: ein Schritt je Token der Eingabe oder je ausgeführtem Token im Code; Zufallsgenerator zurücksetzbar.

### FA-18 Freie Taste in R2 (Buchstabe d) mit AC und „Eingabebereich löschen“ belegen
Feature · App · klein · von Jörg · angelegt 2026-11-03 · Reife 3
Variante 1: d = AC, Shift+d = Eingabebereich löschen. Variante 2: d = AC, Shift+d = C (heute Shift+⌫),
Shift+⌫ = Eingabebereich löschen. AC löscht Stack, Variablen und Tags; eigene Funktionen und Verlauf bleiben,
die zu löschen gehört ins Burger-Menü. Offen: ob AC eine Rückfrage braucht, solange es kein Undo gibt (FR-4).

### VR-3 Texte der Oberflächen und Fehlermeldungen auslagern wie die Hilfe des Rechners
Verbesserung · Rechner · mittel · von Claude · angelegt 2026-11-03 · alt: api.md 11 · Vorstufe zu FR-2, FA-13 · Reife 3

### FA-12 Bibliotheken zur Laufzeit hinzufügen: Download, Datei, „Öffnen mit …“
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · alt: app.md 18 · Reife 3
Nur lesbare Textdateien (.rpnlib): eine Bibliothek kann nur rechnen, nicht auf Dateien, Netz oder System
zugreifen. Download über das Paket http (reines Dart, kein Plugin); vor dem Hinzufügen zeigt die App sie an
(Beschreibung, Funktionen, Code). Bei jedem Start mit bibliothekHinzufuegen anmelden.
Ablage: Windows mit dart:io unter %APPDATA%, Browser im localStorage, Handy im privaten Ordner der App über
path_provider. Das ist ein Plugin: beim Bauen unter Windows braucht es symbolische Links, also einmal den
Entwicklermodus auf dem Rechner, auf dem gebaut wird (nicht bei den Nutzern). Offen: eine gemeinsame
Speicherschicht mit den Sitzungen (FA-8), siehe RG-2.

### FA-7 Fachbereiche statt Domänen: Bibliotheken und Programme ein- und ausschalten
Feature · App · groß · von Jörg · angelegt 2026-11-03 · Details: Menue.md 3.7, 4.1 · Reife 2

### FA-2 ALPHA ohne „ABC“: oben links in Orange später das Symbol von Shift+ALPHA (z.B. „Symbol“)
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · alt: app.md 17 · gehört zu FA-9 · Reife 2
Großbuchstaben brauchen keinen Hinweis auf ALPHA. Im Alpha-Modus zeigen die Tasten des Ziffernblocks oben links
in Orange Zeichen, die man in Texten braucht (wie am PC über den Ziffern, aber mit anderen Zeichen, z.B. ? " # @).

### FA-11 Verhalten der Enter-Taste einstellbar: nur Leerzeichen oder Leerzeichen und Zeilenumbruch
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · alt: app.md 16 · Reife 2
Offen: wohin der Trenner `_` kommt, wenn Shift+ENTER frei werden muss; wo die Einstellung liegt.

### FA-13 Mehrsprachigkeit der Oberfläche mit flutter_localizations
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · alt: app.md 19 · hängt mit FR-2 zusammen · Reife 2

### FR-3 Anzeigeformat (z.B. FIX) als Einstellung des Rechners
Feature · Rechner · mittel · von Jörg · angelegt 2026-11-03 · alt: api.md 5 · Reife 2
Entschieden: im Skript gespeichert, im Zustand gemeldet, die Oberflächen formatieren danach. Noch zu spezifizieren.

### FS-5 Symbolschreibweise: `\name ` bis einschließlich Leerzeichen wird vor dem DEA durch ein Zeichen ersetzt
Feature · Sprache · groß · von Jörg · angelegt 2026-11-03 · Details: requirements.md „Sonderzeichen“, reference.md 14.2 · Reife 2
Eigene kleine Ersetzungsstufe im Rechner vor dem Haupt-DEA, damit sie auch in Skripten, Socket und Konsole gilt.
Synonyme (`\oo`, `\inf`, `\infinity` → ∞; `\<`, `\rad` → ∠), Indizes (`\.1` → ₁), Hochstellung (`\^2` → ²),
nachgestellte Akzente (`x\. ` → ẋ, `a\.. ` → ä), Umkehrung mit `~\` (Zeichen → Namen). Eine Tabelle als Daten
(z.B. library/system/zeichen.rpnlib) legt je Zeichen fest, ob es ein Name oder ein Operator wird; Zeichen ohne
Bedeutung melden einen Fehler. Offen: Kollisionen Zeichengruppe für Zeichengruppe durchgehen; `\` + ein
Kleinbuchstabe und `\?` bleiben den Befehlen der Oberflächen (`\q \c \s \v`). Auch `~>` → `≤` gehört hierher.

### VR-2 Grenze für loop und times einstellbar, danach parser und calculator privat
Verbesserung · Rechner · mittel · von Claude · angelegt 2026-11-03 · alt: api.md 3 · Reife 2

### RR-4 Unbenannte Code-Blöcke: wie geht der Nutzer mit Blöcken auf dem Code-Stapel um, die keinen Namen haben?
Recherche · Rechner · mittel · von Jörg · angelegt 2026-11-04 · Reife 2
Beobachtet bei TK-1: jede abgelehnte Definition (z.B. {1}':mean auf eine Bibliotheksfunktion) lässt ihren Block
auf dem Code-Stapel, die Anzeige zählt „Code 1, 2, 3“ hoch. Vielleicht gewollt: man könnte sie mit \c und \v
oder später im Zeilenmodus (FA-16) auswählen, einem Namen geben oder ausführen. Offen: anzeigen, auswählen,
ausführen, verwerfen, und ob ein Fehler den Block liegen lassen soll.

### FA-8 Sitzungen: letzter Stand automatisch, benannte Sitzungen mit Verlauf
Feature · App · groß · von Jörg · angelegt 2026-11-03 · alt: app.md 3, api.md 9 · Details: Menue.md 4.3 · Reife 1
Offen: Frage B (trägt der Vorschlag?).

### FA-9 Shift+ALPHA stellt die Zeichen bereit, aus denen man Symbole baut (\ ^ . - < …), mit Vorschau
Feature · App · groß · von Jörg · angelegt 2026-11-03 · alt: app.md 6 · baut auf FS-5 · Reife 1
Die Zeichen stehen klein unten links auf den Tasten; ALPHA, dann Shift ergibt weiter Großbuchstaben. Beim Tippen
von `\oo` zeigt die Anzeige als Vorschau, was daraus wird (∞), ggf. die passenden Zeichen zur Auswahl.

### FR-5 print und input: Programme geben Text aus und fragen Werte ab
Feature · Rechner · mittel · von Jörg · angelegt 2026-11-03 · alt: api.md 9 · braucht Rückrufe in die Oberfläche · Reife 1

### FA-16 Zeilenmodus (zuschaltbar): erst bei ENTER rechnen, frühere Zeilen übernehmen und korrigieren
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · braucht ein eigenes Konzept · Reife 1
Wie die zeilenweise Eingabe der Konsole: mit ▲▼ eine frühere Zeile wählen, ändern und noch einmal ausführen;
vor dem Ausführen überall in der Zeile korrigieren. Heute rechnet die App Zeichen für Zeichen und bricht
automatisch um, beides stört dabei. Hängt mit Undo zusammen (FR-4).

### FA-17 Hilfe zu einem beliebigen Namen in der App, wie `\?name` in der Konsole
Feature · App · klein · von Jörg · angelegt 2026-11-03 · zusammen mit den Symbolen angehen (FA-9, FS-5) · Reife 1
Heute kommt man nur über Tasten, Elemente der Anzeige und Verweise zu einer Seite.

### FS-2 Vektoren, Matrizen und Tabellen in ( )
Feature · Sprache · groß · von Jörg · angelegt 2026-11-03 · die Taste ( ) ist dafür reserviert · Details: Menue.md 4.2 · Reife 1
Tabellen sind ein Grund für das Querformat (FA-5).

### DG-3 Hilfetexte so überarbeiten, dass sie zeigen, wie man mit dem Rechner arbeitet
Doku · Gesamt · groß · von Jörg · angelegt 2026-11-04 · abgespalten aus DG-1 · Reife 1
Die Tooltips sind schon fast ein Tutorial; die Hilfeseiten sollen eher anleiten, wie man mit dem Rechner
arbeitet. Die kurzen Übersichten sind noch zu knapp und wenig beschreibend. Offen: Konzept und Aufbau.

### FS-1 Einheiten in [ ]
Feature · Sprache · groß · von Jörg · angelegt 2026-11-03 · die Taste [ ] ist dafür reserviert · Reife 0

## Vorgeschlagen

### PT-1 `--exe` für tool/veroeffentlichen.dart: Windows-Version bauen und als Release hochladen
Prozess · Werkzeuge · klein · von Claude · angelegt 2026-11-03 · Reife 4
Braucht die GitHub CLI (`winget install GitHub.cli`, einmal `gh auth login`).

### VA-1 Tooltip von ' auch mit „als Präfix: …“ wie bei ~ und |
Verbesserung · App · klein · von Claude · angelegt 2026-11-03 · Reife 4

### VA-3 JuliaMono als mitgelieferte Monospace-Schrift, auf die benötigten Zeichen beschnitten
Verbesserung · App · mittel · von Claude · angelegt 2026-11-04 · Reife 3
Heute nimmt die App die Monospace-Schrift des Systems; Zeichen wie ₙ fehlen in Consolas, am Handy und im Browser
springt eine andere Schrift ein. JuliaMono (SIL Open Font License) hat die mathematischen Zeichen, Griechisch,
Hoch- und Tiefstellungen und setzt Akzente sauber (passt zu FS-4, FS-5). Für Anzeige, Tooltips und Hilfe; die
Beschriftung der Tasten bleibt. Offen: Zeichenumfang beim Beschneiden (je Schnitt sonst 3,2 MB; Regular,
SemiBold, Bold, später Italic für FL-2), etwa 5 % mehr Breite und das kleine „…“ am Zeilenende nach dem
Umstellen prüfen. Vergleichsbild mit Consolas am 2026-11-04 gemacht.

## Für die Zukunft

### FL-1 Bibliothek für hohe Genauigkeit: Zahlen mit viel mehr Stellen statt num
Feature · Bibliotheken · groß · von Jörg · angelegt 2026-11-03 · Machbarkeit offen · Reife 0

### FS-3 Komplexe Zahlen als eigener Zahlentyp
Feature · Sprache · groß · von Jörg · angelegt 2026-11-03 · Reife 0

### FS-6 Lua-Unterstützung: Lua-Code im rpncalc-Code, Lua-Bibliotheken, Ein- und Ausgabe mit Plots
Feature · Sprache · groß · von Jörg · angelegt 2026-11-06 · Machbarkeit offen · Reife 1
- Parameter über den Stack übergeben (hin und zurück)
- Lua-Code in rpncalc-Code einbetten
- Lua-Bibliotheken laden, z.B. luacas, lua-plot oder SciLua
- Ein- und Ausgabe, auch Plot-Funktionen
Zu klären: welcher Lua-Interpreter für Dart (Konsole, App, Web), wie Plots in der App erscheinen; SciLua setzt
LuaJIT voraus.

## Erledigt

### Version 0.2.0

### DG-2 CHANGELOG.md aus „Erledigt“ erzeugen, für das öffentliche Repository und den Text eines Releases
Doku · Gesamt · klein · von Claude · angelegt 2026-11-03 · Reife 5
Heute steht dort noch „1.0.0 – Initial version“. Entschieden 2026-11-06:
- Englisch; je Version nur die Liste der Änderungen, ohne Commit-Hashes (das öffentliche Repository hat eine
  eigene Geschichte).
- Aufgenommen wird, was im Produkt sichtbar ist: F, B, V und Einträge, die Hilfetexte ändern (Merkmal „· sichtbar“).
- Da die Einträge deutsch sind, bekommt jeder aufgenommene Eintrag beim Verschieben nach „Erledigt“ eine Zeile
  „EN: …“ mit dem englischen Text; das Werkzeug nimmt diese Zeile.
- tool/veroeffentlichen.dart erzeugt CHANGELOG.md beim Veröffentlichen aus „Erledigt“, gegliedert nach
  „### Version …“; die neueste Version muss zur Version in pubspec.yaml passen, sonst bricht es ab.
Erledigt 2026-11-06, af664a7

### BA-3 Werte einfügen deutet Kommas falsch: aus „4,5,6,7“ werden 4.5 und 6.7 statt 4 5 6 7
Bug · Rechner · klein · von Jörg · angelegt 2026-11-04 · gefunden bei TW-1 · Reife 5
Heute zählt jedes Komma zwischen Ziffern als Dezimalkomma (deutsches Excel). Vorschlag: mehrere Kommas in einer
Folge (4,5,6,7) sind Trennzeichen; kommt im Text ein Dezimalpunkt vor, sind Kommas Trennzeichen; nur ein
einzelnes Komma zwischen Ziffern (4,5;6 aus Excel) ist ein Dezimalkomma. Gilt für App und Konsole (`\v`).
Vorschlag am 2026-11-06 angenommen.
EN: Pasting values: commas in a row (4,5,6,7) or next to a decimal point separate numbers.
Erledigt 2026-11-06, af664a7

### BA-4 Firefox: „Werte einfügen“ und „Text einfügen“ im Kontextmenü tun nichts
Bug · App · klein · von Jörg · angelegt 2026-11-04 · gefunden bei TW-1 · Ablauf: Zeitbox 1 h · Reife 5
Strg+V geht (Firefox fragt mit einem kleinen „Einfügen“ nach, das bleibt so), Kopieren im Menü auch. Vermutung:
Das Schließen des Menüs nimmt Firefox die Nutzeraktion bzw. verdrängt die Rückfrage. Ursache suchen, höchstens
1 h; danach einer der drei Ausgänge aus workflow.md.
EN: Firefox: pasting from the context menu works; if the browser refuses, the app says so.
Erledigt 2026-11-06, af664a7

### FA-21 ENTER und Return auf der PC-Tastatur (und Alpha ⏎) wirken mehrmals hintereinander
Verbesserung · App · klein · von Jörg · angelegt 2026-11-04 · gefunden bei TW-1 · Reife 5
Heute wirkt nur der erste Druck: Leere Zeilen kommen nicht in den Verlauf (`_umbrechen`), und ENTER ohne
Eingabe tut nichts. Entschieden 2026-11-04: Jeder weitere Return gibt eine leere Zeile im Verlauf; ENTER ohne
Eingabe verdoppelt x wie bei HP.
Hilfe: in `app:enter` (hilfe.dart) und app.md 6 ergänzen, dass weitere ENTER x verdoppeln und weitere Return
leere Zeilen geben; reference.md 3.4 gilt schon (`"1  2"` → `[1 1 2]`).
EN: ENTER and Return work repeatedly: ENTER duplicates x, Return adds empty lines; the keypad Enter is recognized in browsers.
Erledigt 2026-11-06, af664a7

### TA-1 APK neu bauen und die App auf dem Handy von Hand prüfen
Test · App · klein · von Claude · angelegt 2026-11-03 · Gate · Reife 5
Der Stand auf dem Handy ist veraltet; Zoom, Doppeltipp und Hilfe-Modus am echten Gerät ansehen.
Am 2026-11-06 auf dem A33 geprüft; Funde (Tooltip ohne Maus, Tastenbeschriftung, □) behoben.
EN: Fixes for phones: tooltips on long press, key labels no longer wrap.
Erledigt 2026-11-06, bdf67f1

### DG-4 Hilfetexte: Funde aus DG-1 (Protokoll vom 2026-11-06) einarbeiten
Doku · Gesamt · mittel · von Jörg · angelegt 2026-11-06 · gefunden bei DG-1 · sichtbar · Gate · Reife 5
Nummern wie auf der Prüfseite (bN):
- b39, b40 rnd, round: Tooltip ohne die Varianten mit Argumenten (n:rnd, a:b:rnd; stellen:art)
- b41 dms: Stackspalte zu lang, „Grad Minuten Sekunden“ bricht in die nächste Zeile
- b91–b95 Bereiche der Bibliothek: „Bibliothek: Bibliothek: Schwingungen“ doppelt
- b108 und ähnliche: „Weiter mit“ streichen; vor „Zur Übersicht“ ein Zeilenumbruch
- b135 nach ␣ das Wort „Leertaste“; b136 zweimal „Trenner“ als Verweis (_ und #trenner)
- b137 „Die Positionen (gezählt ab 0) heißen …“, Tos als „Top of Stack“ erklären; b139 „bestehen“ statt „heißen“
- b140 „mit mehreren nennt man sie ein Feld“; „'++name '--name“ nicht umbrechen
- b141 „siehe die Taste …“ klein (Titel mitten im Satz); b143 statt „ausführen mit Code ausführen“ auf die
  Verweise zeigen
- b159, b160 „kleiner gleich“ statt „kleiner oder gleich“
- b168 Klammern im Block: { { } } erlaubt, { { } und }{ nicht
- b176 ê statt „Exponent“; b189 round: Stellen mit beiden Beispielen, Art als Tabelle mit Beispielen
- b138 entschieden: in den Texten x; „Tos“ nur einmal auf der Seite Stack erklärt (Top of Stack).
EN: Help texts revised after review: arguments for rnd and round, rounding modes as a table, clearer wording.
Erledigt 2026-11-06, 6cde5b1

### DG-5 Startseite der Hilfe und „Alle Zeichen und Namen“ neu gliedern
Doku · App · klein · von Jörg · angelegt 2026-11-06 · gefunden bei DG-1 · sichtbar · Reife 5
- b132: oben „Hilfe zur Hilfe“ (Shift+MENÜ, LESEN, ◄, BEENDEN, „Tipp in die Anzeige: deren Hilfe“), darunter
  „Hilfe zur App“ ab „Die Anzeigen …“, dann „Hilfe zum RPN-Rechner“. Die Konsole ebenso: oben „Hilfe in der
  Konsole“, darunter der Rechner.
- Listen von Verweisen stehen nur einmal, als Verweise (in der Konsole als „Siehe auch“), nicht zusätzlich als
  Fließtext („Themen: …“); Fließtext nur für Erklärungen. Gilt für die Startseite und b133.
- Gruppen mit Überschriften zwischen den Verweisen kommen später (VA-5).
EN: Help start page in three parts: help on help, help on the app, help on the calculator.
Erledigt 2026-11-06, 6cde5b1

### TP-1 Prüfseite der Hilfe: doppelte Seiten und „app:app:“
Test · Werkzeuge · klein · von Claude · angelegt 2026-11-06 · gefunden bei DG-1 · Reife 5
Ab b195 zeigt die Prüfseite app:#, app:~, app:|, app:' noch einmal; die App zeigt für sie dieselbe Seite wie
für rechner:# usw. (b132, b154, b155, b163). Doppelte Bilder nur einmal zeigen, mit beiden Kennungen; die
Kennungen der App-Seiten heißen „app:app:shift“ statt „app:shift“.
Erledigt 2026-11-06, 6cde5b1

### DG-1 Hilfetexte und Tooltips auf der Prüfseite durchgehen und abhaken
Doku · Gesamt · groß · von Jörg · angelegt 2026-11-03 · alt: app.md 13 · Details: app.md 5, tool/hilfe.dart · Gate · Reife 5
Prüfseite mit `dart run tool/hilfe.dart`; Stand 2026-11-01: ✓ 38, ○ 180. Das Überarbeiten der Texte ist DG-3.
Am 2026-11-06 von Jörg durchgesehen, Funde im Protokoll; daraus DG-4, DG-5, TP-1, FA-23. Erledigt 2026-11-06, 537d325

### DS-1 EBNF in reference.md auf den Stand der Sprache bringen
Doku · Sprache · mittel · von Jörg · angelegt 2026-11-03 · Details: reference.md, Kurzreferenz und EBNF · Gate · Reife 5
Dazu am 2026-11-04: `'0` … `'9` aus dem Automaten entfernt (Argumente mit `~:`), damit EBNF und Grammatik passen.
Diagramm (doc/EBNF.png) von Jörg überarbeitet, Text-EBNF ohne `Argument`. Erledigt 2026-11-04, 67c87ba (Diagramm), die Zeile im Commit danach

### TW-1 Zwischenablage und Kontextmenü im Browser testen (Strg+C/V, Rechtsklick, Rückfrage beim Lesen)
Test · Web · klein · von Jörg · angelegt 2026-11-03 · gehört zu FA-4 · Gate · Reife 5
Mit einer lokal gebauten Browser-Version auf localhost (veröffentlichen geht erst ohne „Erforderlich“), in Chrome
und Firefox; Firefox liest die Zwischenablage teils nur über das Einfügen-Ereignis.
In Chrome und Firefox getestet; Funde als BA-4, BA-5, BA-6, FA-21, FA-22. Erledigt 2026-11-04, 67c87ba

### BA-5 Stack blättern läuft über das Ende hinaus, und nur 39 von 118 Werten sind zu sehen
Bug · App · klein · von Jörg · angelegt 2026-11-04 · gefunden bei TW-1 · Reife 5
Nach `\v` mit 118 Werten zeigt die Stackspalte nur bis Ebene 39; ▼ zählt intern weiter, ▲ braucht genauso viele
Schritte zurück. Die Position soll am letzten Wert stehen bleiben, und alle Werte sollen erreichbar sein.
EN: Stack scrolling reaches the deepest value and stops there.
Erledigt 2026-11-04, 67c87ba

### BA-6 Tooltips legen sich über das offene Kontextmenü
Bug · App · klein · von Jörg · angelegt 2026-11-04 · gefunden bei TW-1 · Reife 5
Solange das Kontextmenü offen ist, erscheinen keine Tooltips. Zusammen mit FA-22 umsetzen.
EN: No tooltips over an open context menu.
Erledigt 2026-11-04, 67c87ba

### FA-22 Ein Tastendruck auf der PC-Tastatur blendet die Tooltips aus, bis die Maus auf ein anderes Element wechselt
Verbesserung · App · klein · von Jörg · angelegt 2026-11-04 · gefunden bei TW-1 · Reife 5
Wer tippt, schaut nicht auf die Taste unter der Maus. Bleibt die Maus liegen, kommt dort kein Tooltip mehr, bis
sie das Element einmal verlassen hat.
EN: Typing on the PC keyboard hides tooltips until the mouse moves to another element.
Erledigt 2026-11-04, 67c87ba

### TK-1 Konsole von Hand prüfen: F-08, F-09 und die Positionsnamen x y z t ₄ …
Test · Konsole · klein · von Claude · angelegt 2026-11-03 · Gate · Reife 5
Bestanden ohne Änderung (F-08, F-09, Positionsnamen); erledigt 2026-11-04, ad336f9

### BA-2 Seite „Funktionen“: Abschnitte „Eigene Funktionen“ und je geladener Bibliothek, mit ihrem Code
Verbesserung · App · mittel · von Claude · angelegt 2026-11-03 · war ein Bug: Bibliotheksfunktionen standen unter „Eigene“ · Reife 5
Abschnitte wie heute „EIGENE FUNKTIONEN“, darunter „BIBLIOTHEK SCHWINGUNGEN“ usw.; der Code bleibt sichtbar (Lerneffekt).
Blättern die Funktionstasten, scrollt die Liste zum passenden Abschnitt (Eigene: nach oben); umgekehrt ändert
Scrollen in der Liste die Tasten nicht.
EN: Functions page with sections for your own functions and each loaded library; it scrolls along with the function keys.
Erledigt 2026-11-03, 4160150

### PG-2 Reifegrad 0–5 für alle offenen Einträge, als Gate: In Arbeit und Bereit 5, Erforderlich und Geplant ab 4
Prozess · Gesamt · klein · von Jörg · angelegt 2026-11-03 · Reife 5
Stufen: 0 Idee in einem Satz, 1 Richtung und Nutzen klar, 2 offene Fragen benannt, 3 die meisten entschieden,
Aufwand schätzbar, 4 alle fachlichen Fragen entschieden, 5 ohne Rückfrage umsetzbar. In der Merkmalszeile als
„Reife 3“ (nicht RG, das ist eine ID-Gruppe). „Angedacht“ nach Reife sortiert, von hoch nach tief; die
Einstufung legt Claude zur Durchsicht vor.
Erledigt 2026-11-03, 3a86798

### FA-4 Zwischenablage in der App: Kontextmenü in der Anzeige, Strg+C/V und `\c \s \v`
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · alt: app.md 25
Kontextmenü mit Rechtsklick (PC, Browser) bzw. langem Drücken (Handy) in Stack und Eingabe; die Tasten behalten
das lange Drücken für ihren Tooltip, im Browser das eigene Kontextmenü abschalten. Einträge im Stack: Wert
kopieren, Stack ab hier kopieren, ganzen Stack kopieren (tiefster Wert zuerst, mit ; und Dezimalkomma wie in
der Konsole), Werte einfügen (Zahlen aus dem Text herauslösen wie `\v`, die letzte wird x), Hilfe. In der
Eingabe: Zeile kopieren, Zeilen ab hier kopieren, ganzen Verlauf kopieren, Text einfügen (Zeichen für Zeichen
wie getippt), Hilfe. „Hilfe“ ersetzt am Handy den Tooltip der Anzeige.
Tastatur: Strg+C kopiert x bzw. die gewählte Zeile, Strg+Shift+C den Stack, Strg+V fügt je nach gewähltem
Bereich Werte oder Text ein; `\c`, `\s`, `\v` wie in der Konsole (auch im Alpha-Modus). Im Browser das Lesen testen.
EN: Clipboard: context menu in the display (right click, long press), Ctrl+C/V and backslash commands.
Erledigt 2026-11-03, 54f4c45

### FA-3 Wischen und Mausrad über die Funktionstasten blättern durch ihre Seiten
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · alt: app.md 15
Der orange Rahmen zeigt beim Wischen kleine Pfeile, wenn es in diese Richtung weitere Seiten gibt.
EN: Swiping and the mouse wheel over the function keys turn their pages.
Erledigt 2026-11-03, 54f4c45

### BA-1 Nach `~` sind Tasten ausgegraut, auf die `~` nicht anwendbar ist; dort sollte `~` als ± wirken
Bug · App · klein · von Jörg · angelegt 2026-11-03
Beispiel: `3~D` lässt sich nicht tippen. Weil D keine Umkehrung hat, bleibt die Taste wählbar: `~` ist dann der
Vorzeichenwechsel, danach wirkt D. Die App setzt dafür einen Trenner (`3~ D`), denn `3~D` meldet im Rechner einen
Fehler (keine Umkehrung von D). Gleiches für `|` prüfen (`3.7|D` geht schon).
EN: After ~, keys it does not apply to no longer turn grey; ~ then acts as ±.
Erledigt 2026-11-03, e7b83b3

### VA-2 Nach `~` bzw. `|` die Tasten mit einem dünnen Rand markieren, die dann eine andere Bedeutung haben
Verbesserung · App · klein · von Jörg · angelegt 2026-11-03 · gehört zu BA-1
Statt die anderen auszugrauen; die übrigen Tasten bleiben normal bedienbar. Rand in der Farbe des Präfixes,
dünner als der Rand aktiver Umschalttasten (2), damit er den Bezug zeigt und sich trotzdem unterscheidet.
EN: After ~ or |, keys with a different meaning get a thin border.
Erledigt 2026-11-03, e7b83b3

### FR-1 sinh, cosh und tanh im Rechner (die Tasten zeigen sie schon auf Shift)
Feature · Rechner · klein · von Jörg · angelegt 2026-11-03 · alt: app.md 1
Erst reference.md, dann umsetzen; Hilfe und Tooltips nachziehen.
EN: sinh, cosh, tanh and their inverses.
Erledigt 2026-11-03, e7b83b3

### FA-1 Rechenfunktion klein unter dem Zeichen von ~ (±) und | (□|.□, zwei Kästen für Ganzzahl- und Nachkommateil)
Feature · App · klein · von Jörg · angelegt 2026-11-03 · alt: app.md 20
Mittig unter dem großen Zeichen, helle Tastenschrift etwas zurückgenommen, etwa so groß wie die Shift-Hinweise;
im Alpha-Modus ausgeblendet. Die Kästen gezeichnet wie `[ ]`/`[|]`, nicht aus der Schrift. Spec: app.md 3.1.
EN: The ~ and | keys show their own function (± and □|.□) below the symbol.
Erledigt 2026-11-03, c5968cc

### PG-1 Backlog und Arbeitsregeln in process/ einführen, offene Punkte aus app.md und api.md übernehmen
Prozess · Gesamt · mittel · von Jörg · angelegt 2026-11-03
Dazu die Prüfung von „Erforderlich“ in tool/veroeffentlichen.dart.
Erledigt 2026-11-03, 6d0345c

## Abgelehnt

### FA-14 F2–F10 mit eigenen Funktionen belegen
Feature · App · klein · von Claude · angelegt 2026-11-03 · Menue.md Frage D
Die Tasten bleiben frei für später; brauchen die Funktionstasten einen direkten Zugriff, ginge Strg+1 … Strg+0.

---

# Regeln

## Bereiche

| Bereich | Inhalt |
|---|---|
| In Arbeit | woran wir gerade arbeiten |
| Bereit | der aktuelle Abschnitt (ohne feste Dauer); immer ein paar Einträge zur Auswahl |
| Erforderlich | Sammelplatz für Gate-Einträge, die noch niemand angefangen hat: sie müssen vor dem nächsten Veröffentlichen erledigt sein, behindern aber den Fortschritt nicht; auch Klammer-Aufgaben, deren Teile noch offen sind |
| Geplant | voll ausgefüllt, kann ohne weitere Klärung nach Bereit |
| Zurückgestellt | aus Bereit zurückgenommen, mit Grund |
| Angedacht | Jörgs Ideen: beschlossen, aber noch nicht ausformuliert und zerlegt; bei der Architektur schon mitdenken |
| Vorgeschlagen | Claudes Vorschläge zu Features, Verbesserungen, Prozess und Struktur; Jörg entscheidet |
| Für die Zukunft | Träumen erlaubt: groß, Machbarkeit offen |
| Erledigt | nur mit Commit; je Version eine Überschrift, neue Einträge kommen unter die aktuelle |
| Abgelehnt | mit Grund, damit die Entscheidung nachvollziehbar bleibt |

**Reife:** wie gut ein Eintrag spezifiziert ist; jeder offene Eintrag hat eine. Sie ist das Gate zwischen den
Bereichen: „In Arbeit“ und „Bereit“ nur mit Reife 5, „Erforderlich“ und „Geplant“ ab Reife 4, „Zurückgestellt“,
„Angedacht“, „Vorgeschlagen“ und „Für die Zukunft“ mit jeder Reife. „Angedacht“ ist nach Reife sortiert, von hoch
nach tief.

| Reife | Bedeutung |
|---|---|
| 0 | Idee in einem Satz |
| 1 | Richtung und Nutzen klar |
| 2 | die offenen Fragen sind benannt |
| 3 | die meisten Fragen sind entschieden, der Aufwand lässt sich schätzen |
| 4 | alle fachlichen Fragen sind entschieden, nur Einzelheiten der Umsetzung offen |
| 5 | ohne Rückfrage umsetzbar, die Spezifikation steht oder ergibt sich direkt |

Bei einer Recherche (R) heißt Reife 4: die Frage ist klar gestellt, die Untersuchung kann beginnen.

**Gate:** Einträge, die vor dem Veröffentlichen erledigt sein müssen, tragen in der Merkmalszeile „· Gate“; das
Merkmal bleibt, wenn sie nach „Bereit“ oder „In Arbeit“ wandern. Veröffentlicht wird nur, wenn kein Eintrag mit
diesem Merkmal und keiner unter „Erforderlich“ mehr offen ist; `tool/veroeffentlichen.dart` prüft das und bricht
sonst ab.

## Einträge

```
### FA-0 (Beispiel) Zoom: die App skaliert mit der Fensterbreite, die Höhe gibt der Anzeige mehr Zeilen
Feature · App · mittel · von Jörg · angelegt 2026-10-20 · alt: app.md 5 · Details: app.md 1.1
Ein bis drei Zeilen, was zu tun ist bzw. was offen ist.
Erledigt 2026-11-01, 47fe04a
```

- **ID:** Art + Bereich + laufende Nummer je Paar, z.B. FR-23. Die ID bleibt, auch wenn sich die Art ändert.
  Was schon umgesetzt war, bevor es den Backlog gab, bekommt keine Nummer.
- **Art** und **Bereich:** siehe Kategorien unten.
- **Aufwand:** klein · mittel · groß
- **Titel:** ein ganzer Satz, verständlich ohne die Spezifikation.
- **alt:** die frühere Nummer in app.md bzw. api.md, damit ältere Verweise auffindbar bleiben.
- **Ablauf:** verweist auf ein Muster in [workflow.md](workflow.md), z.B. „Ablauf: Zeitbox 1 h“.
- **sichtbar:** Ein D-Eintrag, der Hilfetexte ändert, kommt in CHANGELOG.md (F, B, V immer).
- **EN:** Beim Verschieben nach „Erledigt“ bekommt jeder Eintrag für CHANGELOG.md eine Zeile „EN: …“ (DG-2).
- **Zerlegen:** Größere Aufgaben werden in Spezifikation, Implementierung, Doku/Hilfe und Test zerlegt.
  Die Klammer liegt in „Erforderlich“, bis alle Teile erledigt sind; die Teile verweisen auf sie.
  Kleine Aufgaben werden nicht zerlegt, für sie gilt die DoD in einem Eintrag.

## Kategorien

Die ID setzt sich aus Art und Bereich zusammen: FR = Feature im Rechner, BA = Bug in der App.

| Art | | Wofür | Beispiel |
|---|---|---|---|
| F | Feature | neue Fähigkeit | FR-1 sinh, cosh, tanh |
| B | Bug | etwas verhält sich falsch | BA-1 `3~D` ging nicht |
| V | Verbesserung | Bestehendes besser machen, auch Umbauten | VA-2 dünner Rand nach `~` |
| D | Doku | Spezifikation, Hilfetexte, README, Beispiele | DS-1 EBNF auf Stand bringen |
| T | Test | automatische und manuelle Tests | TK-1 Konsole von Hand prüfen |
| P | Prozess | Arbeitsweise, Werkzeuge für den Ablauf | PG-1 Backlog einführen |
| R | Recherche / Review | untersuchen, bewerten, entscheiden; Ergebnisse werden eigene Einträge (meist V) | RG-1 Architektur-Review |

| Bereich | | Was dazugehört |
|---|---|---|
| R | Rechner | Kern: Calculator, Parser, API, Fehler, Zustand |
| S | Sprache | Grammatik, DEA, Zeichen, Schreibweisen (reference.md) |
| A | App | Flutter-Oberfläche (app.md) |
| K | Konsole | zeilen- und zeichenweise Eingabe, Menü, Konsolenhilfe |
| W | Web | Browser-Version, GitHub Pages |
| L | Bibliotheken | `.rpnlib`-Dateien und ihre Hilfe |
| T | Werkzeuge | `tool/`: Veröffentlichen, Prüfseite, Generatoren |
| G | Gesamt | betrifft mehrere Bereiche oder das ganze Projekt |

## Definition of Done

- Spezifikation angepasst (reference.md, api.md, app.md)
- Tests grün, Analyzer ohne Meldungen (`dart analyze`, `flutter analyze`)
- Hilfetexte und Tooltips nachgezogen, Prüfseite neu erzeugt
- Dokumentation (Architektur, README) angepasst, wo betroffen
- committet; der Eintrag steht mit Commit in „Erledigt“
