# Backlog

Oben das Konkrete, in der Mitte das Diffuse, am Ende das Log. Regeln am Ende der Datei, Arbeitsweise in
[workflow.md](workflow.md).

## In Arbeit

## Bereit

## Erforderlich

## Geplant

### RA-2 Cursorkreuz und TAB: Nutzen prüfen und ein sauberes Konzept für Navigation und Bereiche finden
Recherche · App · mittel · von Jörg · angelegt 2026-11-22 · Details: requirements/research/RA-2.md · Reife 2
Das Cursorkreuz belegt viel Platz im Tastenfeld, bringt beim Rechnen aber wenig (Wischen, Mausrad, Tipp und die
Pfeiltasten am PC können dasselbe). Bestandsaufnahme aller Wirkungen von ◄ ▲ ► ▼ und TAB, künftige Aufgaben (Cursor
mit Undo, Auswahl im Stack, Hilfe, Menü), Varianten mit Platzbedarf; daraus eigene Einträge. Hängt mit RA-1 zusammen.

### VA-17 Feste Farbwerte außerhalb von colors.dart als Rollen in `Farben` aufnehmen
Verbesserung · App · klein · von Claude · angelegt 2026-11-16 · Reife 5
Rund 13 Stellen schreiben `Color(0x…)` direkt, die meisten in display/menu_page.dart (Linien, Rahmen der Karte,
blasse Texte). Jede bekommt einen Rollennamen in `Farben` (gleiche Töne zusammenfassen), danach gibt es außerhalb
von colors.dart keine festen Farbwerte mehr. Ohne sichtbare Änderung. Vorarbeit, falls später ein zweites
Farbschema kommt (ThemeExtension statt Konstanten).

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

### FW-1 Browser-Version installierbar und offline nutzbar (PWA)
Feature · Web · mittel · von Jörg · angelegt 2026-11-11 · Details: requirements/FW-1.md · Reife 5
Manifest aufräumen (noch Flutters Platzhalter), eigener Service Worker beim Veröffentlichen mit --web, CanvasKit
selbst ausliefern; neue Versionen still. Entscheidungen 2026-11-11 in der Datei.

## Zurückgestellt

## Angedacht

### FA-33 Menü am PC: Fokus mit den Pfeiltasten, Leertaste drückt
Feature · App · klein · von Jörg · angelegt 2026-11-21 · nach FA-32 · Reife 3
Im Menü tun die Pfeiltasten bisher nichts. Ein Fokus (dünn umrandet) wandert mit ihnen über die Funktionstasten des
offenen Bereichs, die Leertaste drückt die Taste, Umschalt+Leertaste wie Shift; Enter bleibt OK. Nur im Menü:
außerhalb blättern ↑ ↓ die Seiten, und die Leertaste ist ENTER. Ergänzt die Buchstaben f–p (FA-32). Offen: wo der
Fokus beim Öffnen steht, ob er auch durch das Hauptmenü auf dem Ziffernblock läuft.

### FR-15 Winkelfunktionen: Familien, Kehrwerte und weitere Winkelmodi auf sin, cos, tan (Diskussion)
Feature · Rechner · groß · von Jörg · angelegt 2026-11-20 · Details: requirements/FR-15.md · Reife 2
Reiner Diskussions-Eintrag. Präfixe `~` Umkehrung, `|` Kehrwert (csc, sec, cot); Familien Kreis, hyperbolisch,
sinc, versin, elliptisch (Modul als Argument `u 0.5:sn`); Winkelmodi MIL, PRAD, TURN mit Reduktion in der eigenen
Einheit. Eindeutige Namen in der Sprache, die Tasten zeigen die Funktion der Familie.

### FR-14 Komplexe Zahlen: Eingabe, Zerlegen, Fokus und Rechnen (Diskussion)
Feature · Rechner · groß · von Jörg · angelegt 2026-11-20 · erster Werttyp für FR-11 · braucht FS-5 · Details: requirements/FR-14.md · Reife 2
Reiner Diskussions-Eintrag. Aufbau mit `4 6ⅈ+` bzw. `10 30∠`, eine Taste ⅈ mit Präfixen, `~|` für z̄, Zerlegen
mit `|` und `|°`, Fokus `@φ` (auch `45 @=φ`, `@φ'x`), allgemein für Teile von Werten. Offen: Taste, Funktionen, Anzeige.

### FR-13 Import von Namensräumen: Namen wie rpn.fix kurz verfügbar machen
Feature · Rechner · mittel · von Jörg · angelegt 2026-11-16 · nach FR-12 · Details: requirements/FR-13.md · Reife 5
`{rpn.angle}rpn.use` macht Namen kurz verfügbar (`deg` für `rpn.angle.deg`), für die Sitzung, im Skript
gespeichert; `rpn.angle` voreingestellt. Bibliotheken als `lib.<name>.<funktion>`, beim Laden gleich freigeschaltet
(abschaltbar). Konflikte: im Scratchpad Fehler, sonst innere bzw. eigene Namen zuerst; Auflösung beim Aufruf, lexikalisch.

### PA-2 Debug-Verbindung zur laufenden App: Tasten schicken, Zustand lesen
Prozess · App · groß · von Jörg · angelegt 2026-11-21 · aus RG-4 · nach PA-1 · Reife 1
Claude stellt Fehler der App selbst nach und prüft Korrekturen selbst, z.B. über einen Socket wie beim Server
(nur 127.0.0.1, nur im Debug-Modus). Idee, noch nicht ausgearbeitet.

### FR-11 Werttypen: Domain (R, C), Klasse (R, D, Q, Z) und Auflösung (simple, high, max)
Feature · Rechner · groß · von Jörg · angelegt 2026-11-16 · Platzhalter in FA-32 · Reife 1
Domain bestimmt, was erlaubt ist und ob die Funktionen für komplexe Zahlen erscheinen. Klasse: 𝔻 Dezimalzahlen
(Festkomma, ein Int mit festem Komma; ℤ ⊂ 𝔻 ⊂ ℚ ⊂ ℝ), ℚ Brüche, ℤ reine Integer-Arithmetik. Auflösung:
Genauigkeit (z.B. double, qdReal, BigInt); sie bestimmt auch die größte Stellenzahl im Menü Format (FA-32).
Braucht eigene Werttypen statt `num` (value.dart).

### VA-5 Verweise einer Hilfeseite in Gruppen mit kleiner Überschrift („Zeichen“, „Funktionen und Befehle“, „Themen“)
Verbesserung · App · klein · von Claude · angelegt 2026-11-06 · zu DG-5 · Reife 4
Die Hilfe kennt heute nur eine flache Reihe von Verweisen. Darstellung in App (Überschrift über den Knöpfen)
und Konsole (eine Zeile je Gruppe); zuerst für die Startseite und „Alle Zeichen und Namen“.

### FA-19 Die aktuelle Eingabezeile bleibt beim Blättern im Verlauf stehen und bekommt dafür einen eigenen Hintergrund
Verbesserung · App · klein · von Jörg · angelegt 2026-11-04 · Reife 4
Beim Blättern mit ▲▼ steht die aktuelle Zeile immer oben, der Verlauf läuft darunter durch. Ein leicht anderer
Hintergrund zeigt, dass sie nicht zum Verlauf gehört.

### FA-20 Mausrad in den Bereichen der Anzeige: Verlauf, Stack, Variablen, Funktionen, Hilfe
Feature · App · klein · von Jörg · angelegt 2026-11-04 · Details: requirements/FA-20.md · Reife 4
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

### RG-5 Menü-Modell im Kern: Beschreibung der Einträge für App und Konsole, mehrere Rechner nebeneinander
Recherche · Gesamt · mittel · von Claude · angelegt 2026-11-15 · Details: requirements/research/RG-5.md · Reife 4
Entwurf der Datenstruktur für Menüeinträge im Kern, geprüft an Modi, Bibliotheken und Code; dazu, ob zwei RpnApi
unabhängig sind (Scratchpad). Vor FA-6 und FK-2, wie RG-1; für FA-30 vorgezogen, zunächst nur Bibliotheken.

### FA-26 Variablen auf den Funktionstasten blättern: mehr als zehn, mit Mausrad, Wischen und Pfeilen
Feature · App · klein · von Jörg · angelegt 2026-11-08 · aus FA-20 · Details: requirements/FA-26.md · Reife 3
Heute zeigen die Funktionstasten nur die ersten zehn Variablen, und nichts blättert dort.

### FA-5 Querformat: Anzeige oben über die volle Breite, darunter drei Tastenfelder
Feature · App · groß · von Jörg · angelegt 2026-11-03 · alt: app.md 4 · Details: app.md 1.1 · Reife 3
Links R2–R5, Mitte Cursorkreuz und R1 als 2×3, rechts R6–R9. Zoom nach der Höhe, Tasten werden breiter.
Umschalten mit der freien Taste unter dem Kreuz; im Fenster nur das Layout, am Handy die Lage festlegen.

### FA-6 Menü auf dem Tastenfeld: Hauptmenü auf 1–9, Einträge auf den Funktionstasten, Aktionen auf den Rechentasten
Feature · App · groß · von Jörg · angelegt 2026-11-03 · Details: requirements/FA-6.md · Reife 3
Ersetzt das Menü der Domänen; die Auswahl allein ändert nichts, erst ÷ × − + ENTER. Menübäume als Daten, damit
später das Dokumenten-System (eigener Einstieg in R2, von oben nach unten) ohne Umbau dazukommt.
Connect (FA-28) auf `.`. Offen u.a.: Taste für die Ansicht (TAB oder `:`), erster Umfang. Belegung als Tabelle
nach dem Konzept von DG-7.

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

### DG-8 Funktionsübersicht: jedes Token mit Stackwirkung, Argumenten und Varianten
Doku · Gesamt · mittel · von Jörg · angelegt 2026-11-13 · Gegenstück zu DG-7 · Details: requirements/DG-8.md · Reife 5
Alle Tokens (Operatoren, Stackbefehle, Funktionen, Befehle), jedes genau einmal, gegliedert wie reference.md,
erzeugt aus der Hilfe nach doc/functions.md und als Hilfeseite, Geplantes aus einer parallelen Liste.

### FR-7 loop mit Argumenten als Zählschleife (bis:von:step) statt times, dazu break und next
Feature · Rechner · mittel · von Jörg · angelegt 2026-11-13 · Details: requirements/FR-7.md · Reife 5
Ohne Argumente wie bisher, mit Argumenten `100:{…}loop` statt `100:{…}times`, Index mit `~:`; break verlässt,
next überspringt; times bleibt vorerst als zweiter Name.

### FG-1 Offene Argumente: in der App sichtbar, ein Befehl legt sie zurück auf den Stack
Feature · Gesamt · klein · von Jörg · angelegt 2026-11-13 · Details: requirements/FG-1.md · Reife 4
Heute warten mit `:` übergebene Argumente unsichtbar und überleben CL. `rpnargs` legt sie zurück auf den Stack,
Anzeige über dem Stack, CL verwirft die Argumente der Zeile. Offen: Reihenfolge.

### FA-29 Ohne Eingabezeile: die aktuelle Eingabe steht klein über dem Stack
Feature · App · klein · von Jörg · angelegt 2026-11-15 · gehört zu FA-6 (Seiten der Anzeige) · Reife 3
Ist die Eingabezeile unter Ansicht abgewählt, zeigt die Stackseite die aktuelle Eingabe klein über dem Stack, wie
das offene Token (und wie bei FG-1 die offenen Argumente). Offen: wie lange Eingaben umbrechen bzw. gekürzt werden.

### FR-9 Einstellungen des Rechners als ein Objekt im Zustand, mit einem einzigen Setter
Feature · Rechner · mittel · von Claude · angelegt 2026-11-15 · Details: requirements/FR-9.md · Reife 3
Winkel, Format (FR-3), Grenzen (VR-2), Sprache; Socket `{"einstellen":…}`, im Skript als rpnjson-Zeile. Offen:
Winkel später vielleicht bei den Einheiten. Sprache global, nicht im Skript.

### FR-10 Herkunft der Funktionen: Bibliotheken entladen, verfügbar und geladen, gezielt löschen
Feature · Rechner · mittel · von Claude · angelegt 2026-11-15 · Details: requirements/FR-10.md · Reife 3
Herkunft aus dem version-Eintrag der Bibliothek, ohne neue Syntax. Offen: Kennung statt Name für eine spätere
Hierarchie, Abhängigkeiten beim Entladen.

### FK-2 Konsolenmenü zum Benutzen statt zum Testen überarbeiten
Feature · Konsole · mittel · von Jörg · angelegt 2026-11-07 · Details: requirements/FK-2.md · Reife 3
Wie die PC-Tastatur-Bedienung des App-Menüs (FA-6), als Text: dieselben Nummern und Aktionstasten, mit `\m` aus
der Eingabe erreichbar, Einträge aus dem Kern (RG-5), Sprache einstellbar.

### FA-7 Fachbereiche statt Domänen: Bibliotheken und Programme ein- und ausschalten
Feature · App · groß · von Jörg · angelegt 2026-11-03 · Details: Menue.md 3.7, 4.1 · Reife 2
Idee (2026-11-20, aus FR-15): Funktionstasten grob nach Bereichen trennen – Trigonometrie (sin, cos, tan, π),
Arithmetik, Algebra, Analysis, Geometrie, Kombinatorik, Stochastik, Complex. Vorschlag Claude: auf den
Grundfunktionen die wichtigsten Tasten je Bereich, dazu je Bereich eine Seite mit allem, im Menü einschaltbar.

### FA-2 ALPHA ohne „ABC“: oben links in Orange später das Symbol von Shift+ALPHA (z.B. „Symbol“)
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · alt: app.md 17 · gehört zu FA-9 · Reife 2
Großbuchstaben brauchen keinen Hinweis auf ALPHA. Im Alpha-Modus zeigen die Tasten des Ziffernblocks oben links
in Orange Zeichen, die man in Texten braucht (wie am PC über den Ziffern, aber mit anderen Zeichen, z.B. ? " # @).

### FA-11 Verhalten der Enter-Taste einstellbar: nur Leerzeichen oder Leerzeichen und Zeilenumbruch
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · alt: app.md 16 · Reife 2
Offen: wohin der Trenner `_` kommt, wenn Shift+ENTER frei werden muss; wo die Einstellung liegt.

### FA-13 Mehrsprachigkeit der Oberfläche mit flutter_localizations
Feature · App · mittel · von Jörg · angelegt 2026-11-03 · alt: app.md 19 · hängt mit FR-2 zusammen · Reife 2

### FS-5 Symbolschreibweise: `\name ` bis einschließlich Leerzeichen wird vor dem DEA durch ein Zeichen ersetzt
Feature · Sprache · groß · von Jörg · angelegt 2026-11-03 · Details: requirements/FS-5.md · Reife 2
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

### DG-9 Argumente und Stackwirkung in der Hilfe vervollständigen
Doku · Rechner · mittel · von Jörg · angelegt 2026-11-13 · aus DG-8, braucht DG-8 · Reife 2
In hilfe.de.rpnlib haben erst 16 Verwendungen Argumente; das Werkzeug von DG-8 liefert die Liste der Lücken
(Argumente mit Standardwert, Stackwirkung), daraus wird der Umfang klar.

### FR-8 Weitere Verzweigungen: ifsgn (drei Fälle nach dem Vorzeichen) und try (Fehler abfangen)
Feature · Rechner · mittel · von Jörg · angelegt 2026-11-13 · aus der Idee „if mit Argumenten“ · Reife 2
Eigene Namen statt `n:if`, damit die Zahl der Blöcke nicht vom Argument abhängt. Offen bei `try`: was gefangen
wird, ob der Fehlercode auf den Stack kommt, was mit dem halb veränderten Stack geschieht (FR-4).

### FA-31 Hamburger-Menü, zuerst Hilfe → Info mit Version und Lizenz
Feature · App · klein · von Jörg · angelegt 2026-11-15 · nach FA-30 · Reife 2
Zweiter Bereich auf dem Gerüst von FA-30 (Taste 7), damit Version und Lizenz in der App sichtbar sind. Gliederung
nach FA-6: Datei, Bearbeiten, Ansicht, Ausführen, Hilfe; zuerst nur Hilfe → Info.

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

### RA-1 Welche Tasten wirken auf welcher Seite der Anzeige?
Recherche · App · mittel · von Jörg · angelegt 2026-11-11 · aus VA-15 · Reife 1
Auf den Seiten Funktionen und Variablen ist die Eingabe nicht zu sehen. Für jede Seite klären, was Ziffern,
Operatoren, Funktionstasten, ENTER, ⌫, CL und die Präfixe dort tun (eingeben, umschalten zur Seite Rechnen, nichts).

### FS-1 Einheiten in [ ]
Feature · Sprache · groß · von Jörg · angelegt 2026-11-03 · die Taste [ ] ist dafür reserviert · Reife 0

### FR-6 Code-Debugger
Feature · Rechner · groß · von Jörg · angelegt 2026-11-09 · Reife 0

### RG-6 Benutzerhandbuch: gut lesbar, ohne dieselbe Information an mehreren Stellen
Recherche · Gesamt · mittel · von Jörg · angelegt 2026-11-22 · Reife 1
Ein Handbuch zum Lesen am Stück, ohne dass Texte doppelt gepflegt werden. Wissen liegt heute schon an vielen
Stellen: Hilfetexte und Tooltips (App, library/system), doc/reference.md, doc/app.md, doc/keys.md (DG-7), bald
doc/functions.md (DG-8). Zu klären: Was ist die eine Quelle für welche Information, was wird erzeugt, was
verwiesen; Leser und Aufbau (Einstieg, Anleitung, Nachschlagen); Format (Markdown im Repository, Seite im Browser,
in der App). Hängt mit DG-3 zusammen.

## Vorgeschlagen

### VA-3 JuliaMono als mitgelieferte Monospace-Schrift, auf die benötigten Zeichen beschnitten
Verbesserung · App · mittel · von Claude · angelegt 2026-11-04 · Details: requirements/VA-3.md · Reife 3
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

### FA-27 Dokumenten-System: Ordner, Dokumente, Probleme, Seiten (z.B. mit Graph) mit eigenem Menübaum ab R2
Feature · App · groß · von Jörg · angelegt 2026-11-14 · Details: requirements/FA-6.md (Abschnitt „Später“) · Reife 1
Eigener Einstieg in R2 (`'` … ⌫), der Menübaum läuft von oben nach unten: R2 neue Seite, Funktionsblock
Minibilder der Seiten, R5 Auswahlfelder, Ziffernblock Kontextmenü der Seite, ENTER wechselt in die Seite. FA-6
wird so gebaut, dass das ohne Umbau dazukommt. Scratchpad (MENÜ 0) mit eigenem, persistentem Zustand; Übernehmen
von und zur aktuellen Seite über das Doc-Menü.

### FA-28 Connect: Clients anbinden (VS Code, mehrere Benutzer, Chat, Sensordaten, Big Screen)
Feature · Gesamt · groß · von Jörg · angelegt 2026-11-14 · im Hauptmenü auf `.` (FA-6) · Reife 0
Anwendungsfälle: VS Code als Entwicklungsumgebung; mehrere Benutzer am selben Dokument (Rechenkern im Server,
die App wird Client); Chat in diesem Modus; Eingabe von Sensordaten; Big-Screen-Client im Vollbild (z.B. für
Vorlesungen). Grundlage könnte der Socket-Server der Konsole sein.

## Erledigt

Steht in [done.md](done.md) (PG-5): je Version eine Überschrift, neue Einträge kommen dort unter die aktuelle.

## Abgelehnt

### VG-2 Englische Bezeichner auf Deutsch
Verbesserung · Gesamt · klein · von Claude · angelegt 2026-11-07 · aus VG-1 · Reife 3
Nach workflow.md heißen Bezeichner deutsch. Englisch sind noch Namen in net/server.dart, console/menu.dart,
selftest/ und `times` (helper.dart). Offen: ob sich das lohnt; die Grundbausteine (push, pull, drop, stack)
bleiben englisch wie in der Sprache.
Abgelehnt 2026-11-21 (Jörg): lohnt nicht.

### FA-18 Freie Taste in R2 (Buchstabe d) mit AC und „Eingabebereich löschen“ belegen
Feature · App · klein · von Jörg · angelegt 2026-11-03
Variante 1: d = AC, Shift+d = Eingabebereich löschen. Variante 2: d = AC, Shift+d = C (heute Shift+⌫),
Shift+⌫ = Eingabebereich löschen. AC löscht Stack, Variablen und Tags; eigene Funktionen und Verlauf bleiben,
die zu löschen gehört ins Burger-Menü. Offen: ob AC eine Rückfrage braucht, solange es kein Undo gibt (FR-4).
Aufgegangen in FA-25 (CL auf d, Shift AC; 2026-11-08).

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
| Erledigt | nur mit Commit; in [done.md](done.md), je Version eine Überschrift, neue Einträge kommen unter die aktuelle |
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
| 5 | ohne Rückfrage umsetzbar, die Spezifikation steht oder ergibt sich direkt; eine Datei unter `requirements/` hat keine offenen Fragen mehr |

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
- **Details:** wo mehr steht. Neue Analysen kommen nach `process/requirements/ID.md` („Details:
  requirements/FA-20.md“, process/workflow.md „Anforderungen“); ältere Verweise auf app.md usw. ziehen nach und
  nach um.
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
