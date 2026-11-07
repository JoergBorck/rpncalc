# Backlog

Oben das Konkrete, in der Mitte das Diffuse, am Ende das Log. Regeln am Ende der Datei, Arbeitsweise in
[workflow.md](workflow.md).

## In Arbeit

## Bereit

## Erforderlich

## Geplant

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
In RG-1 (2026-11-07) nur Platz freigehalten: architecture.md 6; die Speicherschicht kommt später unter model/.

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

### RG-4 Logging, um Laufzeitfehler zu finden
Recherche · Gesamt · mittel · von Jörg · angelegt 2026-11-07 · aus RG-3 · Reife 2
Bisher gab es nur `verbosity` in Parser, DEA und Kern mit einzelnen print-Ausgaben (entfernt mit VG-3).
Offen: was geloggt wird (Tokens, Übergänge des DEA, Ausführung im Calculator, Bedienung der App), wohin (Konsole,
Datei, in der App eine Ansicht oder Export), wie man es einschaltet (Befehl, Menü, Startparameter), Stufen, und
ob es ein Paket wie `logging` sein soll. Ergebnis: Entscheidung und Einträge.

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

### FK-2 Konsolenmenü zum Benutzen statt zum Testen überarbeiten
Feature · Konsole · mittel · von Jörg · angelegt 2026-11-07 · Reife 2
Das Menü (console/menu.dart, bin/rpncalc.dart) ist zum Ausprobieren entstanden: Nummern eintippen, Meldungen wie
„… wurde ausgewählt!“, ein Untermenü „Test“ mit Beispiel-Einträgen und Selbsttests, die Eingabearten als eigene
Einträge, der Server als Menüpunkt. Ziel: ein Menü, mit dem man die Konsole wirklich benutzt. Offene Fragen:
welche Einträge (Sitzung, Bibliotheken, Einstellungen, Hilfe; Selbsttests nur noch als Startparameter?), ob es
aus der laufenden Eingabe erreichbar ist (z.B. mit einem `\`-Befehl), Bedienung (Pfeiltasten, Esc, Kürzel),
Nähe zum Menü der App (FA-6, scratchpad/Menue.md), Hilfe zu den Einträgen.

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

### VG-2 Englische Bezeichner auf Deutsch
Verbesserung · Gesamt · klein · von Claude · angelegt 2026-11-07 · aus VG-1 · Reife 3
Nach workflow.md heißen Bezeichner deutsch. Englisch sind noch Namen in net/server.dart, console/menu.dart,
selftest/ und `times` (helper.dart). Offen: ob sich das lohnt; die Grundbausteine (push, pull, drop, stack)
bleiben englisch wie in der Sprache.

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

### Version 0.3.0

### BA-13 Zweimal schnell ▼ im Bereich Funktionen blättert nur eine Seite
Bug · App · klein · von Jörg · angelegt 2026-11-07 · gefunden beim Test von VA-14 am PC · Reife 5
Während die Tasten zur neuen Seite glitten, meldete der Block die Zwischenseite ans Modell zurück und setzte die
Seite des zweiten Drucks zurück; man musste langsam drücken.
Umgesetzt: function_block.dart (`_ziel`: beim Gleiten zu einer Seite des Modells keine Meldung, ein weiterer
Druck rechnet vom Ziel aus), Test.
EN: –
Erledigt 2026-11-07, a8ee2ce

### VA-14 Im Bereich Funktionen blättern die Pfeiltasten mit ◄ ►, passend wäre ▲ ▼
Verbesserung · App · klein · von Jörg · angelegt 2026-11-07 · gefunden beim Test von VA-10 am PC · Reife 5
Seit VA-10 schiebt das Mausrad die Funktionstasten senkrecht, und der Rahmen zeigt am PC ▲ ▼; die Pfeiltasten
blätterten aber nur mit ◄ ►. Entschieden (Jörg): ▲ ▼ blättern wie das Mausrad (▼ nächste Seite, begrenzt,
senkrecht); ◄ ► bleiben, im Kreis und waagrecht wie das Wischen.
Umgesetzt: viewport.dart, `funktionenSenkrecht` im Kern, function_block.dart, app.md 3.3, Hilfe, Test.
EN: In the functions area, the up and down arrow keys page the function keys like the mouse wheel
Erledigt 2026-11-07, 141f697

### BA-12 Mausrad über den Funktionstasten: einzelne Rasten gehen verloren, das Einrasten fällt aus
Bug · App · klein · von Claude · angelegt 2026-11-07 · gefunden bei VA-13 · Reife 5
Über den Lücken zwischen den Tasten kam das Mausrad nicht an (der Listener reagierte nur über einem Kind); in
Zwischenlagen gingen so Rasten verloren. Kam oder ging die orange Hinterlegung davor, baute Flutter den Block neu
auf, Lage und Zeitgeber fürs Einrasten gingen verloren. Aufgefallen, weil ein Test nie einrastete.
Umgesetzt: Listener `translucent`, fester Schlüssel am Block (keypad.dart).
EN: –
Erledigt 2026-11-07, 77deb45

### VA-13 Mausrad über den Funktionstasten: beim langsamen Drehen rastet es zu schnell ein
Verbesserung · App · klein · von Jörg · angelegt 2026-11-07 · gefunden beim Test von VA-10 am PC · Reife 5
Wer langsam dreht, weil er eine Funktion sucht, sieht nach einer Raste ein Drittel der nächsten Seite; nach
150 ms rastet es auf der Seite ein, von der mehr als die Hälfte zu sehen ist, also meist zurück. So kommt man
mit einzelnen Rasten nie weiter, und das Verhalten ist nicht nachvollziehbar.
Vorschlag (Claude): (a) einrasten erst nach längerer Ruhe, etwa 800 ms (wie früher das Zeitfenster der drei
Rasten), und (b) in Drehrichtung: eine angefangene Seite wird in der Richtung vollendet, in die zuletzt gedreht
wurde. Eine Raste und warten blättert dann genau eine Seite, schnelles Drehen bleibt wie jetzt. Offen: (a), (b)
oder beides; Dauer der Ruhe.
Entschieden 2026-11-07 (Jörg): Ruhe 500 ms und Einrasten in Drehrichtung (Vorschlag b): eine angefangene Seite
wird in der Richtung vollendet, in die zuletzt gedreht wurde; eine Raste blättert genau eine Seite. Zuerst war die
Grenze bei einem Drittel umgesetzt (eine Raste zurück, zwei weiter); das fühlte sich nicht gut an.
Umgesetzt: function_block.dart (`ruheMausrad`; der Code steckt mit in 77deb45), app.md 3.3, Test.
EN: –
Erledigt 2026-11-07, ddcf5bd

### BA-11 Nach dem Mausrad über Eingabe oder Stack erscheint ein Tooltip und bleibt beim Weiterscrollen stehen
Bug · App · klein · von Jörg · angelegt 2026-11-07 · gefunden beim Test am PC · Reife 5
Kurz nach dem Loslassen kam der Tooltip der Zeile und ging beim Weiterscrollen nicht weg. Richtig (Jörg): wie
nach einem Rechtsklick (Kontextmenü) ruhen die Tooltips, bis die Maus ein anderes Element betritt.
Umgesetzt: calc_page.dart ruft `TippSperre.bisMausWechselt` mit der Mausposition (die Verfolgung beginnt erst mit
dem ersten Aufruf), app.md 3.3, Test.
EN: –
Erledigt 2026-11-07, 88f3fd9

### BA-10 Nach langsamem Wischen bleiben die Funktionstasten zwischen zwei Seiten stehen
Bug · App · klein · von Jörg · angelegt 2026-11-07 · gefunden beim Test von VA-10 am A33 · Reife 5
„Spaltenweise“ war als Ruhelage umgesetzt: nach langsamem Wischen standen Spalten zweier Seiten nebeneinander,
der Trennbalken blieb stehen. Gemeint war: die Tasten folgen dem Finger in Spaltenschritten und ruhen immer auf
einer ganzen Seite (der, von der mehr als die Hälfte zu sehen ist).
Umgesetzt: function_block.dart, app.md 3.3, Tests.
EN: –
Erledigt 2026-11-07, 7cac4e0

### VA-10 Mausrad schiebt die Funktionstasten sichtbar wie Text, beim Loslassen rasten sie ein
Verbesserung · App · mittel · von Jörg · angelegt 2026-11-07 · gefunden bei FA-23 · Reife 5
Heute wechselt erst jede dritte Raste die Seite: wenig Rückmeldung, dann ein plötzlicher Wechsel. Stattdessen
verschiebt jede Raste die Tastenreihen ein Stück nach oben bzw. unten, sie werden wie Text aus dem Block
herausgeschoben und die nächsten hereingeschoben; ruht das Rad (etwa 150 ms), rasten sie auf die nächste Lage ein.
Entschieden 2026-11-07 (Jörg): Wischen bleibt waagrecht, mit derselben Logik: die Tasten folgen dem Finger
spaltenweise und rasten ein; mit Schwung läuft es nach und blättert seitenweise, langsam geschoben spaltenweise.
Mausrad: seitenweise, zwischen zwei Seiten eine Trennlinie; es rastet immer auf einer ganzen Seite ein
(entschieden 2026-11-07). Gilt ausdrücklich auch für das Wischen am Handy (Jörg nach dem Test am A33). Am PC
zeigen statt der kleinen Pfeile ◄ ► am Rahmen zwei Pfeile ▲ ▼, weil das Mausrad senkrecht dreht. Einzelheiten entschieden 2026-11-07 (Jörg, Vorschlag Claude): Wischen am Handy schiebt waagrecht, das Mausrad
am PC senkrecht. Schwung wie FA-24 (Nachlauf ab 100 px/s, Physik der Android-Listen). Tooltips aus, solange
geschoben wird, wie heute beim Mausrad. Der Rahmen bleibt sichtbar; der Seitenname wechselt, sobald mehr als die
Hälfte der neuen Seite zu sehen ist (dort rastet es auch ein). Trennlinie orange, dünn, halb durchsichtig wie der
Rahmen.
Aufwand (Schätzung Claude): mittel. Die Tasten der Nachbarseiten mitbauen, in einem beschnittenen Bereich
verschieben, Einrasten mit Animation; das Modell braucht einen Versatz in Pixeln neben der Seite.
Umgesetzt: keypad/function_block.dart (FunktionsBlock), im Raster bleiben die Plätze leer; Modell
`funktionstastenAuf`, `zeigeFunktionsSeite`; app.md 3.3, architecture.md 4.4; Tests. Abweichung nach dem Bauen:
ein Wisch mit Schwung geht genau eine Seite weiter (nicht so weit, wie der Schwung trägt), weil das Tempo zwischen
seiten- und spaltenweise entscheidet und bei wenigen Seiten sonst leicht zwei auf einmal kommen. Am Handy prüfen.
EN: The function keys slide visibly: swiping follows the finger column by column and snaps to a page (a quick swipe turns one page); the mouse wheel slides them vertically and snaps to a page
Erledigt 2026-11-07, 5ede1b2

### VA-12 Werte aus dem Stack mit „Text einfügen“ in der Schreibweise des Rechners einsetzen, mit Leerzeichen statt ;
Verbesserung · App · klein · von Jörg · angelegt 2026-11-07 · gefunden beim Test von FA-24 (process/testing/protocols/2026-11-07_fa-24_phone.md) · Reife 5
Kopieren aus dem Stack schreibt das Format für ein deutsches Excel (Dezimalkomma, `;`). „Text einfügen“ tippt das
Zeichen für Zeichen; schon das erste `;` ist ein Fehler, alles danach hängt als Tasten nach dem Fehler in der
Zeile. Stattdessen: Entschieden 2026-11-07 (Jörg): nach dem Inhalt, nicht nach der Herkunft. Besteht der Text in der Zwischenablage
nur aus Zahlen im Excel-Format (Dezimalkomma; getrennt durch `;`, Tab oder Zeilenumbruch), setzt „Text
einfügen“ sie so ein, wie man sie tippen würde: Dezimalpunkt, `~` für negative Zahlen, `ê` für den Exponenten,
Leerzeichen dazwischen. Das hilft auch bei Zahlen aus Excel. Jeder andere Text, auch kopierte Zeilen aus dem
Verlauf, wird wie bisher Zeichen für Zeichen getippt; `\v` und „Werte einfügen“ bleiben unverändert.
Umgesetzt: `nurZahlen()` in lib/src/format.dart (exportiert), clipboard.dart nutzt dafür `ausExcel`; Tests.
EN: Pasting numbers as text (from the stack or from Excel) writes them as you would type them, separated by spaces
Erledigt 2026-11-07, 813bf60

### FA-25 Taste CL (Zeile löschen) auf der freien Taste d, mit Shift AC (Eingabe und Stack mit Tags löschen)
Feature · App · mittel · von Jörg · angelegt 2026-11-07 · gefunden beim Test von FA-24 (process/testing/protocols/2026-11-07_fa-24_phone.md) · Reife 5
Neu gefasst 2026-11-07 (Jörg): Die freie Taste rechts neben `{ }` (Alpha `d`) wird CL, Clear Line: löscht die
aktuelle Zeile; ist sie leer, löscht sie die Zeile darunter im Verlauf und schiebt die Eingabeliste hoch. Mit
Shift AC: löscht Eingabe (aktuelle Zeile und Verlauf) und Stack mit Tags, nicht aber Variablen und eigene
Funktionen; die werden über das Menü gelöscht (FA-6). Dass ⌫ nach einem Fehler erst alle Tasten danach
zurücknimmt, ist VR-7.
Entschieden 2026-11-07 (Jörg): CL leert nur den Eingabebereich, ohne Wirkung auf den Stack. Schon ausgeführte
Token der Zeile bleiben wirksam (ohne Undo); verworfen werden das offene Token, ein vorgemerktes Enter und die
Tasten nach einem Fehler (im Rechner eine Methode `verwerfen()`, api.md 5), die Zeile kommt nicht in den
Verlauf. Am PC löst Esc CL aus (im Rechnen bisher ohne Wirkung). Tooltip und Hilfe zu CL und AC, app.md 3.1.
Umgesetzt: `RpnApi.verwerfen()`, Taste CL/AC mit `Aktion.zeileLoeschen`, Esc im Rechnen wie CL, Hilfe `app:cl`
(Prüfseite: neu), Tests in keystroke_test und model_test.
EN: New key CL clears the input line without touching the stack (empty line: removes the line below); Shift+CL (AC) also clears the history, the stack and its tags; Esc works like CL
Erledigt 2026-11-07, 32e6a58

### VR-7 Löschen nach einem Fehler nimmt alle Tasten danach auf einmal zurück
Verbesserung · Rechner · klein · von Jörg · angelegt 2026-11-07 · aus FA-25 · Reife 5
Bisher nahm ⌫ nach einem Fehler die nicht ausgeführten Tasten einzeln zurück; nach einem eingefügten Text mit
500 Werten war das nicht machbar. Jetzt nimmt das erste ⌫ alle auf einmal zurück, das nächste wie bisher die
auslösende Taste (api.md 5.6). Gilt für App und Konsole.
Umgesetzt: Parser `tastenNachFehler`, Interpreter `loeschen`, Tests.
EN: After an error, backspace first removes all keys typed after it at once
Erledigt 2026-11-07, 4027953

### FA-24 Senkrechtes Wischen in Eingabe und Stack scrollt zeilenweise mit dem Finger, mit Nachlauf
Verbesserung · App · klein · von Jörg · angelegt 2026-11-06 · Reife 5
Der Inhalt folgt dem Finger in Zeilenschritten: je Weg einer Zeilenhöhe eine Zeile (Höhe der 3. Zeile von oben,
da die Zeilen nach unten kleiner werden; pixelgenau passt nicht zu den wachsenden Schriftgrößen). Nach einer
schnellen Bewegung läuft es nach und bremst ab (Physik wie bei Android-Listen), an Anfang und Ende Halt.
Seitliches Wischen, langes Drücken und Doppeltipp bleiben. Am PC das Mausrad ebenso. Das Wischen wählt den
Bereich wie ein Tipp (entschieden 2026-11-06).
Umgesetzt: `schiebeZeilen` im Modell (viewport.dart), Widget `_Wischen` auf der Seite Rechnen mit Nachlauf
(ClampingScrollSimulation) und Mausrad (je Raste eine Zeile); der Weg zählt ab dem Aufsetzen. app.md 3.3, Hilfe
zu Eingabe und Stack (auf der Prüfseite ✎), Tests. Am Handy noch von Hand prüfen.
EN: Swiping vertically in the input and stack columns scrolls line by line and keeps moving after a fast swipe; the mouse wheel scrolls one line per notch
Erledigt 2026-11-07, 52e3f06

### VA-11 Der Name interner Funktionen ist auf der Seite Funktionen kaum von den anderen zu unterscheiden
Verbesserung · App · klein · von Jörg · angelegt 2026-11-07 · gefunden bei FL-2 · Reife 5
Kursiv allein ist kaum zu erkennen. Der Funktionsname wird zusätzlich ausgegraut (Farbe wie der Code daneben).
Umgesetzt: list_page.dart, app.md 2, Widget-Test.
EN: –
Erledigt 2026-11-07, e8d8826

### FL-2 Einzelne Funktionen einer Bibliothek als intern kennzeichnen (z.B. Hilfsfunktionen wie rw, osz)
Feature · Bibliotheken · mittel · von Jörg · angelegt 2026-11-03 · Reife 5
Interne Funktionen haben nur keine Funktionstaste; in der Liste der Seite Funktionen (dort kursiv) und in der
Hilfe stehen sie wie alle anderen. Gekennzeichnet mit dem Befehl `rpnintern` hinter der Funktion:
`{…}':rw rpnintern`. Er bezieht sich auf die zuletzt abgelegte Funktion (ohne eine: Fehler) und läuft nur beim
Laden, der Code der Funktion bleibt unverändert. „Funktionen speichern“ und der Export schreiben `rpnintern` mit;
wird die Funktion mit `'::` ersetzt, verliert sie die Markierung, außer es folgt wieder `rpnintern`.
Umgesetzt: Befehl `rpnintern` mit Fehler `intern` ohne abgelegte Funktion; `Speicher.intern` (JSON optional),
`bibliotheksFunktionen(name, ohneIntern: true)`; App ohne Tasten für interne Funktionen, kursiv in der Liste;
schwingungen 1.2.0 mit rw, wr, osz, fpol intern; Hilfeeintrag rpnintern (auf der Prüfseite neu, dazu ✎ #alle
und der Tooltip von schwingungen). Beim nächsten Erhöhen der Version: `rechner` in schwingungen auf die Version
setzen, die rpnintern kennt (heute 0.1.0, ein älterer Rechner meldet sonst „Unbekannte Funktion“).
EN: Libraries can mark helper functions as internal (rpnintern): they get no function key; schwingungen hides rw, wr, osz and fpol
Erledigt 2026-11-07, ddf4970

### BA-9 Klick in den Rahmen bei Grundfunktionen zeigt die Hilfe zu eigenen Funktionen
Bug · App · klein · von Jörg · angelegt 2026-11-07 · gefunden bei FA-23 · Reife 5
Die Zuordnung aus FA-23 war vertauscht: `#funktionen` ist beim Rechner das Thema „Eigene Funktionen“.
Umgesetzt: „Eigene“ zeigt `#funktionen`, Grundfunktionen und die übrigen Seiten `app:funktionen` (app.md 5.2).
EN: –
Erledigt 2026-11-07, aa363c6

### FA-23 Im Hilfe-Modus blättern Mausrad und Wischen die Funktionstasten, ein Klick in den Rahmen zeigt die Hilfe zur Seite
Verbesserung · App · klein · von Jörg · angelegt 2026-11-06 · gefunden bei DG-1 · Reife 5
Neu gefasst 2026-11-07 (Jörg): Im Hilfe-Modus blättern Mausrad und Wischen die Seiten der Funktionstasten wie
sonst, unter der Maus ist der Block hinterlegt (VA-4); ein Klick auf eine Taste zeigt weiter ihre Hilfe. Der
orange Rahmen mit dem Seitennamen ist im Hilfe-Modus immer zu sehen, als wäre der Bereich gewählt. Ein Klick in
den Rahmen, aber nicht auf eine Taste, oder auf den Seitennamen zeigt die Hilfe zur Seite: bei einer Bibliothek
ihre Übersicht (`#name`), bei „Eigene“ `app:funktionen`, sonst `#funktionen`. Die Seite Funktionen der Anzeige
bleibt unter dem Hilfeschirm (früherer Wunsch: sie mit dem Mausrad scrollen).
Umgesetzt: Sperre für den Hilfe-Modus in `funktionenBlaetterbar` entfernt, Rahmen im Hilfe-Modus immer, eine
Klickfläche unter den Tasten und der Seitenname rufen `hilfeZurSeite` (Kennung aus `seitenHilfe`); Tests.
EN: Help mode: the mouse wheel and swiping page the function keys; clicking inside their frame shows help on the page (e.g. the library)
Erledigt 2026-11-07, 3544c7b

### BA-8 Im Alpha-Modus sind die Funktionstasten heller bzw. dunkler als die anderen Buchstaben
Bug · App · klein · von Jörg · angelegt 2026-11-07 · gefunden bei BA-7 · Reife 5
Belegte Funktionstasten behielten im Alpha-Modus ihre hellere Farbe, unbelegte die dunkle Farbe für reservierte
Tasten; je nach Belegung sahen die Buchstaben verschieden aus. Richtig: im Alpha-Modus keine eigene Farbe.
Umgesetzt: key_widget.dart, app.md 3.2, Widget-Test.
EN: In alpha mode, the function keys look like all other letter keys
Erledigt 2026-11-07, 79060dd

### BA-7 Im Alpha-Modus blättern Mausrad und Wischen die Funktionstasten unsichtbar weiter
Bug · App · klein · von Jörg · angelegt 2026-11-07 · gefunden bei VA-4 · Reife 5
Im Alpha-Modus zeigen die Funktionstasten Buchstaben. Trotzdem wurde der Block unter der Maus hinterlegt (VA-4),
das Mausrad zeichnete den Rahmen und blätterte die Seiten im Hintergrund weiter. Richtig: wie bei den Variablen
kein Blättern, kein Rahmen, keine Färbung (app.md 3.3).
Umgesetzt: `funktionenBlaetterbar` schließt Alpha ein; Tests für Alpha und ' (Blättern, Rahmen, Färbung).
EN: In alpha mode, the mouse wheel and swiping no longer page the function keys in the background
Erledigt 2026-11-07, 9dceeff

### VA-4 Am PC färbt sich der Block der Funktionstasten leicht orange, solange die Maus darüber steht
Verbesserung · App · klein · von Claude · angelegt 2026-11-06 · zu FA-3 · Reife 5
Zeigt, dass Mausrad (und Wischen) dort die Seiten blättern, auch ohne markierten Bereich. Am Handy bleibt der
kurze orange Rahmen beim Wischen. Entschieden 2026-11-06: nur der Hintergrund, ganz leicht orange (eigene Rolle
in farben.dart).
Umgesetzt: Rolle `Farben.funktionenMaus` (Gehäuse mit 10 % Orange), nur mit der Maus und nur, wenn das Mausrad
dort blättert (`funktionenBlaetterbar`); app.md 3.3, Widget-Test in model_test.dart.
EN: On the PC, the function key block turns slightly orange while the mouse is over it (the mouse wheel pages there)
Erledigt 2026-11-07, 4f8d811

### VG-3 Aufräumen nach RG-3: Logging-Reste und obsolete Felder entfernen, Konsolenmenü vereinfachen
Verbesserung · Gesamt · klein · von Claude · angelegt 2026-11-07 · aus RG-3 · Reife 5
Nach process/testing/reviews/2026-11-07_rg-3_dead_code.md, ohne Verhaltensänderung:
- entfernen: `verbosity` in parser.dart, dea.dart und core.dart samt Ausgaben, `errorNichtImplementiert`
  (dea.dart); `hasExponent`, `isTag`, `matissensPuffer`, `exponentenPuffer` (token.dart)
- Kommentar: `nocmd`, `noparam`, `nyi`, `resultSuccess`, `resultPending` sind Rückfall-Werte bei Fehlern im Code;
  `eingabe` im Client ist für Clients, die ganze Zeilen schicken
- console/ui.dart: `_laden` liefert nichts mehr
- console/menu.dart: `isAction` in `call()` statt `subMenu == null` (ein leeres Untermenü liefe sonst endlos),
  `call([MenuItem? start])` ohne den Zweig für einen Text, `testmenu` heißt `hauptmenue`
Umgesetzt wie beschrieben. Die Grammatik setzt die Flags e und t weiter; RpnToken nimmt sie an, ohne etwas zu
merken. Menü von Hand geprüft (Untermenüs, zurück, Beenden).
EN: Internal restructuring, no visible change
Erledigt 2026-11-07, c6c125d

### RG-3 Toter Code: was ist wirklich unbenutzt, was ist Platz für später, was fliegt raus?
Recherche · Gesamt · klein · von Jörg · angelegt 2026-11-07 · aus VG-1 · Reife 4
Kandidaten aus DG-6: parser.dart (`nocmd`, `noparam`, `nyi`, `resultSuccess`, `resultPending`), dea.dart
(`verbosity`, `errorNichtImplementiert`), token.dart (`hasExponent`, `isTag`, `matissensPuffer`,
`exponentenPuffer`), stack.dart (`ausgabe`, `x`/`y`/`z`/`t`, Standardgröße 20), net/client.dart (`eingabe`),
console/ui.dart (Ergebnis von `_laden`), menu.dart (Test-Einträge, Start-Text in `call`, `isAction`). Je
Kandidat: wer ihn benutzt (auch Tests, Werkzeuge, Selbsttest), ob er eine Naht für Angedachtes ist, Empfehlung
behalten oder entfernen. Dazu eine Suche nach weiteren Stellen (z.B. öffentliche Bezeichner ohne Aufrufer).
Ergebnis: Liste mit Entscheidung, das Entfernen wird ein V-Eintrag.
Ergebnis: process/testing/reviews/2026-11-07_rg-3_dead_code.md, entschieden mit Jörg. Daraus VG-3 (Aufräumen)
und RG-4 (Logging). Die allgemeine Suche nach weiteren unbenutzten Bezeichnern ist nicht gemacht, eher mit einem
Werkzeug. Erledigt 2026-11-07, 3983be0

### VA-9 Bedienmodi: Rechnen und Hilfe als eigene Objekte, statt hilfeModus an jeder Stelle abzufragen
Verbesserung · App · mittel · von Claude · angelegt 2026-11-07 · aus RG-1 · Reife 5
Nach architecture.md 4.3: ein Modus hat `druecke`, `tippeZeichen`, `pfeil`, `tab`, `esc`; das Modell gibt an den
aktiven Modus weiter. Grundlage für das Menü (FA-6).
Umgesetzt: model/modes.dart mit `Bedienmodus` (dazu `zeilenende`, `hilfe` für F1 und `beschriftung`) und den
Modi Rechnen und Hilfe; die öffentlichen Methoden des Modells geben an `modus` weiter, `hilfeModus` ist abgeleitet.
Die Logik von Tasten, Zeichen und Pfeilen in der Hilfe steht jetzt im Modus Hilfe. Wischen und Mausrad über den
Funktionstasten fragen `hilfeModus` noch selbst ab (keine Bedienung des Rechnens, kann mit dem Menü kommen).
EN: Internal restructuring, no visible change
Erledigt 2026-11-07, 774d8d9

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
Vorgehen (2026-11-06 abgestimmt): 1. Bestandsaufnahme (Dateien, Klassen, Abhängigkeiten, Zuständigkeiten in
modell.dart); 2. Zielbild als Vorschlag (Schichten, RpnApi als einzige Tür, lib/src, Teilmodelle der App, Regeln
≤ 400–500 Zeilen und Kopfkommentar), Gegenprobe mit dem Backlog; 3. doc/architecture.md neu, Umbau als kleine
Einträge; 4. Umbau ohne Verhaltensänderung, Tests grün, ein Commit je Schritt, zuerst die Kopfkommentare.
Ergebnis (2026-11-07): Zielbild in doc/architecture.md. Entschieden: für RG-2 nur Platz freihalten; RR-3 eigene
Methoden; englische Dateinamen auch in der App. Reihenfolge: erst teilen, dann die übrigen Kopfkommentare; jeder
Teilungsschritt schreibt die Kopfkommentare seiner neuen Dateien gleich mit. Umbau in VR-4, VR-5, VA-6 bis VA-9
und DG-6, in dieser Reihenfolge; RG-1 ist erledigt, wenn sie es sind. Hilfe und Bibliotheken in getrennten
Verzeichnissen (Jörg). CHANGELOG: alle Umbauschritte bekommen dieselbe Zeile „EN: Internal restructuring, no
visible change“; tool/changelog.dart schreibt gleiche Zeilen je Version nur einmal (kommt mit VR-4).
Abgeschlossen mit VA-9: alle Schritte aus architecture.md 8 erledigt (VR-4, VR-5, VA-6 bis VA-9, DG-6), dazu
VG-1, VR-6 und PG-3. Erledigt 2026-11-07, 774d8d9

### RR-3 Sondertasten in der API: eigene Methoden oder Steuerzeichen in taste()?
Recherche · Rechner · klein · von Claude · angelegt 2026-11-03 · alt: api.md 9 (Sondertasten) · Reife 4
Entschieden in RG-1 (2026-11-07): eigene Methoden wie heute (`zeilenende`, `loeschen`); geht mit RG-1 nach
„Erledigt“.
Erledigt 2026-11-07 mit RG-1, ohne eigenen Commit (nichts zu ändern).

### VR-6 RpnApi wird reine Tür: die Verarbeitung kommt in einen Interpreter, Daten, Bibliotheken und Hilfe in lib/src
Verbesserung · Rechner · mittel · von Claude · angelegt 2026-11-07 · aus VG-1 · Reife 5
Heute steuert RpnApi selbst (rpnapi.dart, 447 Zeilen): führt Zeile und ersten Fehler, bricht mehrzeiligen Text
nach einem Fehler ab, stimmt beim Löschen Parser und Enter-Logik ab, verwaltet Bibliotheken, baut Hilfen und den
Zustand; `parser` und `calculator` sind öffentlich. Ziel (Jörg, 2026-11-07): die API ist nur Schnittstelle.
- `lib/src/engine/interpreter.dart`: Klasse `Interpreter` hält Parser und Calculator, führt Zeile und Fehler;
  `taste`, `zeilenende`, `loeschen`, `eingabe` (mehrzeilig mit Abbruch), `reset`, `importieren`.
- `lib/src/api/state.dart`: Zustand, StackZeile, Speicher, SpeicherArt, Fehler mit JSON, dazu das Erzeugen eines
  Zustands aus dem Interpreter; über rpnapi.dart exportiert.
- `lib/src/libraries/`: anmelden, laden mit Prüfung auf Namenskonflikte, Info, Herkunft, Export als Bibliothek.
- `lib/src/help/`: Hilfe nachschlagen (eingebaut, aus Bibliotheken, zu eigenen Namen).
- `RpnApi` behält alle öffentlichen Methoden als Einzeiler, die weitergeben; die Kommentare beschreiben den
  Vertrag (was passiert, z.B. dass ein Fehler den restlichen Text abbricht), das Wie steht beim Code.
- `parser` und `calculator` sind nicht mehr öffentlich. Tests, die hineinschauen (etwa 40 Stellen in 14 Dateien,
  dazu builtin_help.dart und app/tool/hilfe_test.dart), benutzen den Interpreter direkt; test/ darf lib/src
  importieren, die Architekturtests bleiben für app/lib und bin/.
Keine Verhaltensänderung, Schnittstelle für App und Konsole gleich, alle Tests grün; Kopfkommentare der neuen
Dateien, doc/architecture.md (2 und 6) und doc/api.md nachziehen. Name: Interpreter oder Controller (Jörg),
gewählt Interpreter, weil Controller nach der Steuerung einer Oberfläche klingt.
Umgesetzt: interpreter.dart (130 Zeilen) mit eigenem Fehlertyp `Eingabefehler`, damit engine/ nichts über sich
kennt. Bibliotheken, Hilfesuche und die eingebaute Hilfe liegen nicht in libraries/ und help/, sondern mit
state.dart in `lib/src/api/`: sie brauchen den Interpreter, libraries/ und help/ bleiben ohne Abhängigkeiten
(architecture.md 5). rpnapi.dart 141 Zeilen, nur Weitergabe. Tests über `apiMitEinblick()` in
test/internals.dart, dafür `RpnApi.mit(Interpreter)`; app/tool liest die Hilfen einer Bibliothek selbst.
EN: Internal restructuring, no visible change
Erledigt 2026-11-07, bdd9461

### PG-3 Ein Ordner für die Ergebnisse von Tests und Reviews
Prozess · Gesamt · klein · von Claude · angelegt 2026-11-07 · Reife 5
Heute verstreut: Testprotokolle in scratchpad/ (nicht committet), die Prüfseite in app/build/hilfe, die
Symbolvorschau von app/tool/symbol_test.dart in einem festen Pfad einer alten Sitzung, Review-Ergebnisse in
Backlog-Einträgen. Vorschlag: `process/testing/` mit `protocols/` (Testprotokolle, committet), `reviews/`
(Ergebnisse von Reviews wie RG-1 und RG-3, committet) und `preview/` (erzeugte Seiten: Prüfseite,
Symbolvorschau; in .gitignore). symbol_test.dart schreibt dorthin und importiert colors.dart, statt die Farben zu
kopieren. Entschieden 2026-11-07 (Jörg): protocols/ und reviews/ werden mit veröffentlicht, es ist ein
Lernprojekt; die Testprotokolle aus scratchpad/ ziehen dorthin um.
Umgesetzt: process/testing/ mit README, protocols/ (die beiden Protokolle als 2026-11-06_ta-1_phone.md und
2026-11-06_dg-1_help_pages.md), reviews/ (ab RG-3) und preview/ in .gitignore. Prüfseite und Symbolvorschau
schreiben dorthin, symbol_test.dart nimmt die Farben aus colors.dart. Regel in workflow.md „Tests und Reviews“.
Erledigt 2026-11-07, eb3fd21

### VG-1 Aufräumen nach DG-6: veraltete Kommentare, rpnGramma, help_texts.dart nach Sprache teilen
Verbesserung · Gesamt · mittel · von Claude · angelegt 2026-11-07 · gefunden bei DG-6 · Reife 5
Entschieden 2026-11-07 (Jörg): von den Funden nur die veralteten Kommentare und `rpnGramma`; aus help_texts.dart
alles Sprachabhängige in eine eigene Datei mit „de“ im Namen. Den toten Code untersucht RG-3, rpnapi.dart VR-6,
die übrigen Namen VG-2.
Umgesetzt: Kommentare in calculator, code_stack, stack, core, parser (Konzept-Block von früher entfernt, steht
heute in architecture.md), dea, console/help, protocol, tooltip, colors, help_texts. `rpnGramma` heißt
`rpnGrammatik`. help_texts_de.dart (195 Zeilen) hält Einträge, Tabellen der Tooltips und kurze Beschriftungen;
help_texts.dart (257) setzt sie zusammen, `AppHilfe.eintraege` bleibt.
EN: Internal restructuring, no visible change
Erledigt 2026-11-07, 5f53c7d

### BK-1 Der Menütext beim Start des Servers nennt „exit“, der Server endet aber mit {"stopp":true}
Bug · Konsole · klein · von Claude · angelegt 2026-11-07 · gefunden bei DG-6 · Reife 5
bin/rpncalc.dart, Menüpunkt „Socket Multi-Client“: „bis ein Client "exit" schickt“. Nach lib/src/net/server.dart
und doc/api.md 6.1 beendet `{"stopp":true}` den Server. Text anpassen.
Umgesetzt: Der Text nennt `{"stopp":true}` (doc/api.md 6) und dass Strg+C dort das ganze Programm beendet.
Der Konsolen-Client selbst kann den Server nicht beenden; das bleibt so (zum Ausprobieren gedacht).
EN: Console menu: the note on starting the server names the message that stops it
Erledigt 2026-11-07, 5f53c7d

### DG-6 Kopfkommentare in allen übrigen Dateien, architecture.md auf den erreichten Stand
Doku · Gesamt · mittel · von Claude · angelegt 2026-11-07 · aus RG-1 · Reife 5
Nach der Vorlage in architecture.md 7: Aufgabe, Abgrenzung, Siehe auch, vor `library;`. Gilt für lib/, app/lib,
bin/ und tool/. Dazu die Testdateien mit englischen Namen (z.B. modell_test → model_test), entschieden 2026-11-07.
Umgesetzt: Kopfkommentare in 46 Dateien (lib/, app/lib, app/tool, bin/, tool/), 20 Testdateien englisch benannt,
architecture.md auf den erreichten Stand. Funde beim Lesen in BK-1 und VG-1.
Erledigt 2026-11-07, 990daa7

### VA-8 modell.dart über part-Dateien teilen: Kern und Mixins nach Aufgaben
Verbesserung · App · mittel · von Claude · angelegt 2026-11-07 · aus RG-1 · Reife 5
`modell.dart` (989 Zeilen) nach architecture.md 4.2, wie beim Calculator: ein Kern mit dem gemeinsamen Zustand,
Mixins für Eingabe, Belegung, Hilfe-Modus, Zwischenablage, Ausschnitt, Tastatur. Die öffentliche Schnittstelle
von `RechnerModell` bleibt, die Tests bleiben unverändert. Das enum `Modus` (Präfix der Beschriftung) bekommt
einen Namen, der nicht mit den Bedienmodi verwechselt wird.
Umgesetzt: model.dart (229 Zeilen: RechnerModell, ModellKern, Enums) und die Mixins input (129), assignment (185),
help_mode (158), clipboard (140), viewport (108), keyboard (170). Der Kern deklariert abstrakt, was ein Teil vom
anderen braucht (13 Einträge). Das Cursorkreuz im Hilfe-Modus ist jetzt eine eigene Methode `_hilfePfeil`.
`Modus` heißt `Beschriftungsart`, das Feld der Beschriftung `art`.
EN: Internal restructuring, no visible change
Erledigt 2026-11-07, af54c7a

### VA-7 tastenfeld.dart teilen: Tastenfeld aus Blöcken, Taste, Cursorkreuz, Zeichnungen
Verbesserung · App · klein · von Claude · angelegt 2026-11-07 · aus RG-1 · Reife 5
`tastenfeld.dart` (631 Zeilen) nach architecture.md 4.4; die Blöcke so geschnitten, dass FA-5 sie nur anders
anordnen muss. Neue Dateien mit Kopfkommentar.
Umgesetzt: keypad.dart (311 Zeilen, Blöcke als _r1, _obererBlock, _untererBlock), key_widget.dart (278),
cursor_cross.dart (105); die Zeichnungen bleiben privat bei ihrem Widget. Nebenbei die Imports in lib/ und
app/lib alphabetisch sortiert.
EN: Internal restructuring, no visible change
Erledigt 2026-11-07, f1151b3

### VA-6 App: englische Dateinamen, Ordner model/, display/, keypad/, anzeige.dart teilen
Verbesserung · App · mittel · von Claude · angelegt 2026-11-07 · aus RG-1 · Reife 5
Umbenennen nach architecture.md 4.1; `anzeige.dart` (876 Zeilen) teilen in Seitenrahmen mit Statuszeile,
Rechnen-Seite, Listen, Hilfeschirm, Kontextmenü. Neue Dateien mit Kopfkommentar.
Umgesetzt: farben → colors, tasten → keys, hilfe → help_texts, tipp → tooltip, modell → model/model.dart,
tastenfeld → keypad/keypad.dart; anzeige.dart geteilt in display/display.dart, status_line, calc_page, list_page,
help_screen, context_menu (größte Datei 348 Zeilen). Öffentlich wurden Statuszeile, RechnenSeite, ListenSeite und
Kontextmenue.
EN: Internal restructuring, no visible change
Erledigt 2026-11-07, 2f1fba9

### VR-5 Rechner nach lib/src mit englischen Dateinamen, Türen console.dart und net.dart
Verbesserung · Rechner · mittel · von Claude · angelegt 2026-11-07 · aus RG-1 · Reife 5
Aufbau nach architecture.md 2 und 3: `language/`, `engine/` (bisher `calc/`), `help/`, `libraries/`, `console/`, `net/`;
`gramma` → `grammar`, `rpntoken` → `token`, `hilfe` → `help`, `bibliotheken.g` → `libraries.g` (tool/bibliotheken.dart
zieht mit). Der Kreis Hilfe → RpnApi wird aufgelöst. Doppelte Namen (`Anzeige`, `Bereich` der Konsole) bekommen
eindeutige Namen. Tests dürfen `src` weiter importieren.
Umgesetzt: Die Hilfe-Klassen (help/help.dart) hängen von nichts ab; das Nachschlagen in der eingebauten Hilfe
(builtin_help.dart) gehört zur Tür, weil es zum Laden einen ganzen Rechner braucht. Konsole: `Anzeige` heißt
`Darstellung`, `Bereich` heißt `KonsolenBereich`. bin/ benutzt nur die Türen (Test in test/architektur_test.dart).
EN: Internal restructuring, no visible change
Erledigt 2026-11-07, 0d1b123

### VR-4 Excel-Format aus der Konsole lösen: die App importiert nur noch rpnapi.dart
Verbesserung · Rechner · klein · von Claude · angelegt 2026-11-07 · aus RG-1 · Reife 5
`fuerExcel` und `ausExcel` ziehen aus `console/display.dart` in eine gemeinsame Datei (Ziel `lib/src/format.dart`),
die `rpnapi.dart` exportiert. Heute holt `app/lib/modell.dart` sie aus der Konsole (architecture.md 5).
EN: Internal restructuring, no visible change
Erledigt 2026-11-07, af1d6a8

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
Am 2026-11-06 auf dem A33 geprüft (process/testing/protocols/2026-11-06_ta-1_phone.md); Funde (Tooltip ohne Maus, Tastenbeschriftung, □) behoben.
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
Am 2026-11-06 von Jörg durchgesehen, Funde im Protokoll
(process/testing/protocols/2026-11-06_dg-1_help_pages.md); daraus DG-4, DG-5, TP-1, FA-23. Erledigt 2026-11-06, 537d325

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
  „EN: –“ heißt bewusst nichts: für Fehler und Verbesserungen an etwas, das es in der letzten veröffentlichten
  Version noch nicht gab (widerspricht es der Zeile des Features, wird diese angepasst; process/workflow.md).
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
