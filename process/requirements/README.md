# Anforderungen

Inhaltsverzeichnis aller Einträge des [Backlogs](../backlog.md), geordnet nach den Fähigkeiten des Produkts. Jede
ID steht genau einmal, dort, wo sie hauptsächlich hingehört; Querbezüge stehen in der Datei des Eintrags unter
„Bezüge“. Hinter dem Titel steht der Abschnitt im Backlog, ✓ heißt erledigt. Bugs, Recherchen und Tests stehen
nur hier, solange sie offen sind; ihre Dateien liegen in [bugs/](bugs/), [research/](research/) und
[tests/](tests/) und bleiben als Nachweis erhalten. Link, Titel und Status schreibt `dart run tool/requirements.dart`
(PT-2); für einen neuen Eintrag reicht eine Zeile `- ID` unter der passenden Überschrift.

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

- [FR-3](FR-3.md) Anzeigeformat als Einstellung des Rechners: Format mit Stellen, Trenner, Bruch · ✓
- [FR-9](FR-9.md) Einstellungen des Rechners als ein Objekt im Zustand, mit einem einzigen Setter · Angedacht
- [FR-11](../backlog.md#fr-11-werttypen-domain-r-c-klasse-r-d-q-z-und-auflösung-simple-high-max) Werttypen: Domain (R, C), Klasse (R, D, Q, Z) und Auflösung (simple, high, max) · Angedacht
- [FR-12](FR-12.md) Punkt in Namen: Namensräume wie rpn.fix · ✓
- [FR-13](FR-13.md) Import von Namensräumen: Namen wie rpn.fix kurz verfügbar machen · Angedacht
- [FR-14](FR-14.md) Komplexe Zahlen: Eingabe, Zerlegen, Fokus und Rechnen (Diskussion) · Angedacht

### Funktionen

- [FR-1](../done.md#fr-1-sinh-cosh-und-tanh-im-rechner-die-tasten-zeigen-sie-schon-auf-shift) sinh, cosh und tanh im Rechner (die Tasten zeigen sie schon auf Shift) · ✓
- [FR-15](FR-15.md) Winkelfunktionen: Familien, Kehrwerte und weitere Winkelmodi auf sin, cos, tan (Diskussion) · Angedacht
- [DG-8](DG-8.md) Funktionsübersicht: jedes Token mit Stackwirkung, Argumenten und Varianten · Angedacht
- [DG-9](../backlog.md#dg-9-argumente-und-stackwirkung-in-der-hilfe-vervollständigen) Argumente und Stackwirkung in der Hilfe vervollständigen · Angedacht

### Variablen und Tags

(noch keine)

### Programmierung

- [FR-5](../backlog.md#fr-5-print-und-input-programme-geben-text-aus-und-fragen-werte-ab) print und input: Programme geben Text aus und fragen Werte ab · Angedacht
- [VR-2](../backlog.md#vr-2-grenze-für-loop-und-times-einstellbar-danach-parser-und-calculator-privat) Grenze für loop und times einstellbar, danach parser und calculator privat · Angedacht
- [RR-4](../backlog.md#rr-4-unbenannte-code-blöcke-wie-geht-der-nutzer-mit-blöcken-auf-dem-code-stapel-um-die-keinen-namen-haben) Unbenannte Code-Blöcke: wie geht der Nutzer mit Blöcken auf dem Code-Stapel um, die keinen Namen haben? · Angedacht
- [FR-6](../backlog.md#fr-6-code-debugger) Code-Debugger · Angedacht
- [FR-7](FR-7.md) loop mit Argumenten als Zählschleife (bis:von:step) statt times, dazu break und next · Angedacht
- [FR-8](../backlog.md#fr-8-weitere-verzweigungen-ifsgn-drei-fälle-nach-dem-vorzeichen-und-try-fehler-abfangen) Weitere Verzweigungen: ifsgn (drei Fälle nach dem Vorzeichen) und try (Fehler abfangen) · Angedacht
- [FG-1](FG-1.md) Offene Argumente: in der App sichtbar, ein Befehl legt sie zurück auf den Stack · Angedacht

### Fehler und Undo

- [RR-1](../backlog.md#rr-1-einheitliche-fehlercodes-für-grammatik-und-rechner-zb-x1) Einheitliche Fehlercodes für Grammatik und Rechner (z.B. X1)? · Angedacht
- [RR-2](../backlog.md#rr-2-verwerfen-nach-einem-fehler-braucht-es-neben-return-eine-eigene-taste) Verwerfen nach einem Fehler: braucht es neben Return eine eigene Taste? · Angedacht
- [VR-7](../done.md#vr-7-löschen-nach-einem-fehler-nimmt-alle-tasten-danach-auf-einmal-zurück) Löschen nach einem Fehler nimmt alle Tasten danach auf einmal zurück · ✓
- [FR-4](../backlog.md#fr-4-undo-über-ein-änderungsprotokoll-journal) Undo über ein Änderungsprotokoll (Journal) · Angedacht

## Sprache

### Grammatik

- [DS-1](../done.md#ds-1-ebnf-in-referencemd-auf-den-stand-der-sprache-bringen) EBNF in reference.md auf den Stand der Sprache bringen · ✓
- [RS-2](../backlog.md#rs-2-felder-reihenfolge-der-elemente-heute-ist-element-0-der-damalige-tos) Felder: Reihenfolge der Elemente (heute ist Element 0 der damalige Tos) · Geplant

### Zeichen und Namen

- [FS-4](../backlog.md#fs-4-alle-buchstaben-außer-az-gelten-wie-kleinbuchstaben-auch-in-namen-ä-ß-ẋ-ω-) Alle Buchstaben außer A–Z gelten wie Kleinbuchstaben, auch in Namen (ä, ß, ẋ, ω …) · Angedacht

### Sonderzeichen

- [FS-5](FS-5.md) Symbolschreibweise: `\name ` bis einschließlich Leerzeichen wird vor dem DEA durch ein Zeichen ersetzt · Angedacht

### Skriptformat

- [RS-1](../backlog.md#rs-1-version-des-skriptformats-was-passiert-mit-code-aus-einer-älteren-sprachversion) Version des Skriptformats: was passiert mit Code aus einer älteren Sprachversion? · Geplant

## Bibliotheken

### Domänen

- [FA-7](../backlog.md#fa-7-fachbereiche-statt-domänen-bibliotheken-und-programme-ein--und-ausschalten) Fachbereiche statt Domänen: Bibliotheken und Programme ein- und ausschalten · Angedacht
- [FL-2](../done.md#fl-2-einzelne-funktionen-einer-bibliothek-als-intern-kennzeichnen-zb-hilfsfunktionen-wie-rw-osz) Einzelne Funktionen einer Bibliothek als intern kennzeichnen (z.B. Hilfsfunktionen wie rw, osz) · ✓
- [VA-11](../done.md#va-11-der-name-interner-funktionen-ist-auf-der-seite-funktionen-kaum-von-den-anderen-zu-unterscheiden) Der Name interner Funktionen ist auf der Seite Funktionen kaum von den anderen zu unterscheiden · ✓

### Bibliotheken laden

- [FA-12](../backlog.md#fa-12-bibliotheken-zur-laufzeit-hinzufügen-download-datei-öffnen-mit-) Bibliotheken zur Laufzeit hinzufügen: Download, Datei, „Öffnen mit …“ · Angedacht
- [FR-10](FR-10.md) Herkunft der Funktionen: Bibliotheken entladen, verfügbar und geladen, gezielt löschen · Angedacht

### Einheiten

- [FS-1](../backlog.md#fs-1-einheiten-in--) Einheiten in [ ] · Angedacht

### Konstanten

(noch keine)

## Bedienung

### App: Anzeige

- [FA-19](../backlog.md#fa-19-die-aktuelle-eingabezeile-bleibt-beim-blättern-im-verlauf-stehen-und-bekommt-dafür-einen-eigenen-hintergrund) Die aktuelle Eingabezeile bleibt beim Blättern im Verlauf stehen und bekommt dafür einen eigenen Hintergrund · Angedacht
- [FA-20](FA-20.md) Mausrad in den Bereichen der Anzeige: Verlauf, Stack, Variablen, Funktionen, Hilfe · Angedacht
- [FA-24](../done.md#fa-24-senkrechtes-wischen-in-eingabe-und-stack-scrollt-zeilenweise-mit-dem-finger-mit-nachlauf) Senkrechtes Wischen in Eingabe und Stack scrollt zeilenweise mit dem Finger, mit Nachlauf · ✓

### App: Tastenfeld

- [FA-1](../done.md#fa-1-rechenfunktion-klein-unter-dem-zeichen-von---und---zwei-kästen-für-ganzzahl--und-nachkommateil) Rechenfunktion klein unter dem Zeichen von ~ (±) und | (□|.□, zwei Kästen für Ganzzahl- und Nachkommateil) · ✓
- [VA-2](../done.md#va-2-nach--bzw--die-tasten-mit-einem-dünnen-rand-markieren-die-dann-eine-andere-bedeutung-haben) Nach `~` bzw. `|` die Tasten mit einem dünnen Rand markieren, die dann eine andere Bedeutung haben · ✓
- [FA-10](../backlog.md#fa-10-shift-taste-mit-dem-zeichen--vielleicht-nur-das-zeichen) SHIFT-Taste mit dem Zeichen ⇧, vielleicht nur das Zeichen · Angedacht
- [FA-18](../backlog.md#fa-18-freie-taste-in-r2-buchstabe-d-mit-ac-und-eingabebereich-löschen-belegen) Freie Taste in R2 (Buchstabe d) mit AC und „Eingabebereich löschen“ belegen · ✗ abgelehnt
- [FA-25](../done.md#fa-25-taste-cl-zeile-löschen-auf-der-freien-taste-d-mit-shift-ac-eingabe-und-stack-mit-tags-löschen) Taste CL (Zeile löschen) auf der freien Taste d, mit Shift AC (Eingabe und Stack mit Tags löschen) · ✓
- [VA-16](../done.md#va-16-ac-kehrt-zur-seite-rechnen-zurück-und-wählt-die-eingabe) AC kehrt zur Seite Rechnen zurück und wählt die Eingabe · ✓
- [FA-21](../done.md#fa-21-enter-und-return-auf-der-pc-tastatur-und-alpha--wirken-mehrmals-hintereinander) ENTER und Return auf der PC-Tastatur (und Alpha ⏎) wirken mehrmals hintereinander · ✓
- [FA-11](../backlog.md#fa-11-verhalten-der-enter-taste-einstellbar-nur-leerzeichen-oder-leerzeichen-und-zeilenumbruch) Verhalten der Enter-Taste einstellbar: nur Leerzeichen oder Leerzeichen und Zeilenumbruch · Angedacht
- [FA-14](../backlog.md#fa-14-f2f10-mit-eigenen-funktionen-belegen) F2–F10 mit eigenen Funktionen belegen · ✗ abgelehnt
- [RA-2](research/RA-2.md) Cursorkreuz und TAB: Nutzen prüfen und ein sauberes Konzept für Navigation und Bereiche finden · Geplant
- [DG-7](DG-7.md) Tastentabelle: jede Taste mit Funktion und Beschriftung je Präfix und Modus · ✓

### App: Funktionstasten

- [FA-3](../done.md#fa-3-wischen-und-mausrad-über-die-funktionstasten-blättern-durch-ihre-seiten) Wischen und Mausrad über die Funktionstasten blättern durch ihre Seiten · ✓
- [FA-23](../done.md#fa-23-im-hilfe-modus-blättern-mausrad-und-wischen-die-funktionstasten-ein-klick-in-den-rahmen-zeigt-die-hilfe-zur-seite) Im Hilfe-Modus blättern Mausrad und Wischen die Funktionstasten, ein Klick in den Rahmen zeigt die Hilfe zur Seite · ✓
- [FA-26](FA-26.md) Variablen auf den Funktionstasten blättern: mehr als zehn, mit Mausrad, Wischen und Pfeilen · Angedacht
- [VA-15](VA-15.md) Funktionen und Variablen: Liste der Anzeige und Tastenblock als zwei Bereiche, Klick wechselt · ✓
- [VA-4](../done.md#va-4-am-pc-färbt-sich-der-block-der-funktionstasten-leicht-orange-solange-die-maus-darüber-steht) Am PC färbt sich der Block der Funktionstasten leicht orange, solange die Maus darüber steht · ✓
- [VA-10](../done.md#va-10-mausrad-schiebt-die-funktionstasten-sichtbar-wie-text-beim-loslassen-rasten-sie-ein) Mausrad schiebt die Funktionstasten sichtbar wie Text, beim Loslassen rasten sie ein · ✓
- [VA-13](../done.md#va-13-mausrad-über-den-funktionstasten-beim-langsamen-drehen-rastet-es-zu-schnell-ein) Mausrad über den Funktionstasten: beim langsamen Drehen rastet es zu schnell ein · ✓
- [VA-14](../done.md#va-14-im-bereich-funktionen-blättern-die-pfeiltasten-mit---passend-wäre--) Im Bereich Funktionen blättern die Pfeiltasten mit ◄ ►, passend wäre ▲ ▼ · ✓

### App: Alpha und Symbole

- [FA-2](../backlog.md#fa-2-alpha-ohne-abc-oben-links-in-orange-später-das-symbol-von-shiftalpha-zb-symbol) ALPHA ohne „ABC“: oben links in Orange später das Symbol von Shift+ALPHA (z.B. „Symbol“) · Angedacht
- [FA-9](../backlog.md#fa-9-shiftalpha-stellt-die-zeichen-bereit-aus-denen-man-symbole-baut--------mit-vorschau) Shift+ALPHA stellt die Zeichen bereit, aus denen man Symbole baut (\ ^ . - < …), mit Vorschau · Angedacht
- [FA-15](../backlog.md#fa-15-punkte-über-buchstaben-im-alpha-modus-shift-setzt--ä-ö-ü-ẍ-shift-setzt--ẋ) Punkte über Buchstaben im Alpha-Modus: Shift+: setzt ¨ (ä ö ü ẍ), Shift+. setzt ˙ (ẋ) · Angedacht

### App: Zwischenablage

- [FA-4](../done.md#fa-4-zwischenablage-in-der-app-kontextmenü-in-der-anzeige-strgcv-und-c-s-v) Zwischenablage in der App: Kontextmenü in der Anzeige, Strg+C/V und `\c \s \v` · ✓
- [VA-12](../done.md#va-12-werte-aus-dem-stack-mit-text-einfügen-in-der-schreibweise-des-rechners-einsetzen-mit-leerzeichen-statt-) Werte aus dem Stack mit „Text einfügen“ in der Schreibweise des Rechners einsetzen, mit Leerzeichen statt ; · ✓

### App: Tooltips

- [FA-22](../done.md#fa-22-ein-tastendruck-auf-der-pc-tastatur-blendet-die-tooltips-aus-bis-die-maus-auf-ein-anderes-element-wechselt) Ein Tastendruck auf der PC-Tastatur blendet die Tooltips aus, bis die Maus auf ein anderes Element wechselt · ✓
- [VA-1](../done.md#va-1-tooltip-von--auch-mit-als-präfix--wie-bei--und-) Tooltip von ' auch mit „als Präfix: …“ wie bei ~ und | · ✓

### App: Menü und Einstellungen

- [FA-6](FA-6.md) Menü auf dem Tastenfeld: Hauptmenü auf 1–9, Einträge auf den Funktionstasten, Aktionen auf den Rechentasten · Angedacht
- [FA-30](FA-30.md) Menü-Grundgerüst mit dem Bereich Bibliotheken: Ziffernblock, Funktionstasten, Menüseite · ✓
- [FA-31](../backlog.md#fa-31-hamburger-menü-zuerst-hilfe--info-mit-version-und-lizenz) Hamburger-Menü, zuerst Hilfe → Info mit Version und Lizenz · Angedacht
- [FA-32](FA-32.md) Menübereich Modi (Taste 8): Format, Winkel, Trig, Trenner und Bruch auf den Funktionstasten · ✓
- [FA-33](../backlog.md#fa-33-menü-am-pc-fokus-mit-den-pfeiltasten-leertaste-drückt) Menü am PC: Fokus mit den Pfeiltasten, Leertaste drückt · Angedacht
- [RG-5](research/RG-5.md) Menü-Modell im Kern: Beschreibung der Einträge für App und Konsole, mehrere Rechner nebeneinander · Angedacht
- [FA-27](../backlog.md#fa-27-dokumenten-system-ordner-dokumente-probleme-seiten-zb-mit-graph-mit-eigenem-menübaum-ab-r2) Dokumenten-System: Ordner, Dokumente, Probleme, Seiten (z.B. mit Graph) mit eigenem Menübaum ab R2 · Für die Zukunft
- [FA-28](../backlog.md#fa-28-connect-clients-anbinden-vs-code-mehrere-benutzer-chat-sensordaten-big-screen) Connect: Clients anbinden (VS Code, mehrere Benutzer, Chat, Sensordaten, Big Screen) · Für die Zukunft
- [FA-29](../backlog.md#fa-29-ohne-eingabezeile-die-aktuelle-eingabe-steht-klein-über-dem-stack) Ohne Eingabezeile: die aktuelle Eingabe steht klein über dem Stack · Angedacht
- [FA-16](../backlog.md#fa-16-zeilenmodus-zuschaltbar-erst-bei-enter-rechnen-frühere-zeilen-übernehmen-und-korrigieren) Zeilenmodus (zuschaltbar): erst bei ENTER rechnen, frühere Zeilen übernehmen und korrigieren · Angedacht
- [RA-1](../backlog.md#ra-1-welche-tasten-wirken-auf-welcher-seite-der-anzeige) Welche Tasten wirken auf welcher Seite der Anzeige? · Angedacht

### App: Layout und Schrift

- [FA-5](../backlog.md#fa-5-querformat-anzeige-oben-über-die-volle-breite-darunter-drei-tastenfelder) Querformat: Anzeige oben über die volle Breite, darunter drei Tastenfelder · Angedacht
- [VA-3](VA-3.md) JuliaMono als mitgelieferte Monospace-Schrift, auf die benötigten Zeichen beschnitten · Vorgeschlagen
- [VA-17](../backlog.md#va-17-feste-farbwerte-außerhalb-von-colorsdart-als-rollen-in-farben-aufnehmen) Feste Farbwerte außerhalb von colors.dart als Rollen in `Farben` aufnehmen · Geplant

### Hilfe

- [DG-1](../done.md#dg-1-hilfetexte-und-tooltips-auf-der-prüfseite-durchgehen-und-abhaken) Hilfetexte und Tooltips auf der Prüfseite durchgehen und abhaken · ✓
- [RG-6](../backlog.md#rg-6-benutzerhandbuch-gut-lesbar-ohne-dieselbe-information-an-mehreren-stellen) Benutzerhandbuch: gut lesbar, ohne dieselbe Information an mehreren Stellen · Angedacht
- [DG-3](../backlog.md#dg-3-hilfetexte-so-überarbeiten-dass-sie-zeigen-wie-man-mit-dem-rechner-arbeitet) Hilfetexte so überarbeiten, dass sie zeigen, wie man mit dem Rechner arbeitet · Angedacht
- [DG-4](../done.md#dg-4-hilfetexte-funde-aus-dg-1-protokoll-vom-2026-11-06-einarbeiten) Hilfetexte: Funde aus DG-1 (Protokoll vom 2026-11-06) einarbeiten · ✓
- [DG-5](../done.md#dg-5-startseite-der-hilfe-und-alle-zeichen-und-namen-neu-gliedern) Startseite der Hilfe und „Alle Zeichen und Namen“ neu gliedern · ✓
- [VA-5](../backlog.md#va-5-verweise-einer-hilfeseite-in-gruppen-mit-kleiner-überschrift-zeichen-funktionen-und-befehle-themen) Verweise einer Hilfeseite in Gruppen mit kleiner Überschrift („Zeichen“, „Funktionen und Befehle“, „Themen“) · Angedacht
- [FA-17](../backlog.md#fa-17-hilfe-zu-einem-beliebigen-namen-in-der-app-wie-name-in-der-konsole) Hilfe zu einem beliebigen Namen in der App, wie `\?name` in der Konsole · Angedacht
- [FK-1](../backlog.md#fk-1-verweise-in-der-hilfe-der-konsole-mit-nummern-wählen-backspace-zurück-esc-verlässt) Verweise in der Hilfe der Konsole mit Nummern wählen, Backspace zurück, Esc verlässt · Geplant

### Mehrsprachigkeit

- [FA-13](../backlog.md#fa-13-mehrsprachigkeit-der-oberfläche-mit-flutter_localizations) Mehrsprachigkeit der Oberfläche mit flutter_localizations · Angedacht
- [FR-2](../backlog.md#fr-2-mehrsprachigkeit-der-texte-des-rechners-hilfe-und-meldungen-je-sprache) Mehrsprachigkeit der Texte des Rechners: Hilfe und Meldungen je Sprache · Angedacht
- [VR-3](../backlog.md#vr-3-texte-der-oberflächen-und-fehlermeldungen-auslagern-wie-die-hilfe-des-rechners) Texte der Oberflächen und Fehlermeldungen auslagern wie die Hilfe des Rechners · Angedacht

### Konsole

- [FK-2](FK-2.md) Konsolenmenü zum Benutzen statt zum Testen überarbeiten · Angedacht

### Socket und CLI

(noch keine)

## Daten

### Persistenz

- [RG-2](../backlog.md#rg-2-persistenz-in-allen-umgebungen-was-wird-wo-gespeichert-und-was-folgt-daraus) Persistenz in allen Umgebungen: was wird wo gespeichert, und was folgt daraus? · Geplant
- [FA-8](../backlog.md#fa-8-sitzungen-letzter-stand-automatisch-benannte-sitzungen-mit-verlauf) Sitzungen: letzter Stand automatisch, benannte Sitzungen mit Verlauf · Angedacht

### Import und Export

- [VR-1](../backlog.md#vr-1-import-fehler-als-daten-mit-zeilennummer-damit-die-app-die-stelle-markieren-kann) Import-Fehler als Daten mit Zeilennummer, damit die App die Stelle markieren kann · Geplant

## Plattformen

### Windows

- [PT-1](PT-1.md) `--exe` für tool/veroeffentlichen.dart: Windows-Version bauen und als Release hochladen · ✓

### Browser

- [FW-1](FW-1.md) Browser-Version installierbar und offline nutzbar (PWA) · Geplant

### Android

(noch keine)

## Für später

### Zahlen mit hoher Genauigkeit

- [FL-1](../backlog.md#fl-1-bibliothek-für-hohe-genauigkeit-zahlen-mit-viel-mehr-stellen-statt-num) Bibliothek für hohe Genauigkeit: Zahlen mit viel mehr Stellen statt num · Für die Zukunft

### Komplexe Zahlen

- [FS-3](../backlog.md#fs-3-komplexe-zahlen-als-eigener-zahlentyp) Komplexe Zahlen als eigener Zahlentyp · Für die Zukunft

### Multidimensionale Objekte

- [FS-2](../backlog.md#fs-2-vektoren-matrizen-und-tabellen-in--) Vektoren, Matrizen und Tabellen in ( ) · Angedacht

### Lua

- [FS-6](../backlog.md#fs-6-lua-unterstützung-lua-code-im-rpncalc-code-lua-bibliotheken-ein--und-ausgabe-mit-plots) Lua-Unterstützung: Lua-Code im rpncalc-Code, Lua-Bibliotheken, Ein- und Ausgabe mit Plots · Für die Zukunft

### Chronos, Finanz, Strings

(noch keine)

## Projekt

### Prozess

- [PG-5](../done.md#pg-5-backlog-teilen-erledigt-in-eine-eigene-datei-processdonemd) Backlog teilen: „Erledigt“ in eine eigene Datei process/done.md · ✓
- [PG-6](../done.md#pg-6-claudemd-eine-seite-mit-projektkarte-befehlen-und-konventionen) CLAUDE.md: eine Seite mit Projektkarte, Befehlen und Konventionen · ✓
- [PG-7](../done.md#pg-7-erzeugte-dateien-aus-der-suche-nehmen-ignore-für-ripgrep) Erzeugte Dateien aus der Suche nehmen: `.ignore` für ripgrep · ✓
- [PR-2](../done.md#pr-2-spur-begrenzen---max-zeilen-für-tooltracedart) Spur begrenzen: `--max <zeilen>` für tool/trace.dart · ✓
- [PG-1](../done.md#pg-1-backlog-und-arbeitsregeln-in-process-einführen-offene-punkte-aus-appmd-und-apimd-übernehmen) Backlog und Arbeitsregeln in process/ einführen, offene Punkte aus app.md und api.md übernehmen · ✓
- [PG-2](../done.md#pg-2-reifegrad-05-für-alle-offenen-einträge-als-gate-in-arbeit-und-bereit-5-erforderlich-und-geplant-ab-4) Reifegrad 0–5 für alle offenen Einträge, als Gate: In Arbeit und Bereit 5, Erforderlich und Geplant ab 4 · ✓
- [PG-3](../done.md#pg-3-ein-ordner-für-die-ergebnisse-von-tests-und-reviews) Ein Ordner für die Ergebnisse von Tests und Reviews · ✓
- [PG-4](../done.md#pg-4-anforderungen-in-processrequirements-eine-datei-je-eintrag-inhaltsverzeichnis-nach-fähigkeiten) Anforderungen in process/requirements/: eine Datei je Eintrag, Inhaltsverzeichnis nach Fähigkeiten · ✓

### Werkzeuge

- [DG-2](../done.md#dg-2-changelogmd-aus-erledigt-erzeugen-für-das-öffentliche-repository-und-den-text-eines-releases) CHANGELOG.md aus „Erledigt“ erzeugen, für das öffentliche Repository und den Text eines Releases · ✓
- [PT-2](PT-2.md) tool/requirements.dart: Inhaltsverzeichnis der Anforderungen aus Gliederung und Backlog erzeugen · ✓

### Architektur und Code

- [PR-1](PR-1.md) Spur einer Eingabe durch den Rechner: Zeichen, DEA, Tokens, Ausführung und Stack als Text · ✓
- [PA-1](PA-1.md) Tastenprotokoll der App mit Wiederabspielen, Ausnahmen mit Stacktrace · ✓
- [PA-2](../backlog.md#pa-2-debug-verbindung-zur-laufenden-app-tasten-schicken-zustand-lesen) Debug-Verbindung zur laufenden App: Tasten schicken, Zustand lesen · Angedacht
- [VA-6](../done.md#va-6-app-englische-dateinamen-ordner-model-display-keypad-anzeigedart-teilen) App: englische Dateinamen, Ordner model/, display/, keypad/, anzeige.dart teilen · ✓
- [VA-7](../done.md#va-7-tastenfelddart-teilen-tastenfeld-aus-blöcken-taste-cursorkreuz-zeichnungen) tastenfeld.dart teilen: Tastenfeld aus Blöcken, Taste, Cursorkreuz, Zeichnungen · ✓
- [VA-8](../done.md#va-8-modelldart-über-part-dateien-teilen-kern-und-mixins-nach-aufgaben) modell.dart über part-Dateien teilen: Kern und Mixins nach Aufgaben · ✓
- [VA-9](../done.md#va-9-bedienmodi-rechnen-und-hilfe-als-eigene-objekte-statt-hilfemodus-an-jeder-stelle-abzufragen) Bedienmodi: Rechnen und Hilfe als eigene Objekte, statt hilfeModus an jeder Stelle abzufragen · ✓
- [VR-4](../done.md#vr-4-excel-format-aus-der-konsole-lösen-die-app-importiert-nur-noch-rpnapidart) Excel-Format aus der Konsole lösen: die App importiert nur noch rpnapi.dart · ✓
- [VR-5](../done.md#vr-5-rechner-nach-libsrc-mit-englischen-dateinamen-türen-consoledart-und-netdart) Rechner nach lib/src mit englischen Dateinamen, Türen console.dart und net.dart · ✓
- [VR-6](../done.md#vr-6-rpnapi-wird-reine-tür-die-verarbeitung-kommt-in-einen-interpreter-daten-bibliotheken-und-hilfe-in-libsrc) RpnApi wird reine Tür: die Verarbeitung kommt in einen Interpreter, Daten, Bibliotheken und Hilfe in lib/src · ✓
- [VG-1](../done.md#vg-1-aufräumen-nach-dg-6-veraltete-kommentare-rpngramma-help_textsdart-nach-sprache-teilen) Aufräumen nach DG-6: veraltete Kommentare, rpnGramma, help_texts.dart nach Sprache teilen · ✓
- [VG-2](../backlog.md#vg-2-englische-bezeichner-auf-deutsch) Englische Bezeichner auf Deutsch · ✗ abgelehnt
- [VG-3](../done.md#vg-3-aufräumen-nach-rg-3-logging-reste-und-obsolete-felder-entfernen-konsolenmenü-vereinfachen) Aufräumen nach RG-3: Logging-Reste und obsolete Felder entfernen, Konsolenmenü vereinfachen · ✓

### Dokumentation

- [DG-6](../done.md#dg-6-kopfkommentare-in-allen-übrigen-dateien-architecturemd-auf-den-erreichten-stand) Kopfkommentare in allen übrigen Dateien, architecture.md auf den erreichten Stand · ✓
