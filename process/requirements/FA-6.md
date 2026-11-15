# FA-6 Menü auf dem Tastenfeld: Hauptmenü auf 1–9, Einträge auf den Funktionstasten, Aktionen auf den Rechentasten

Feature · App · groß · Reife 3 · Stand: Angedacht

## Ziel
Ein Menü, das ganz auf dem Tastenfeld liegt, statt eines Auswahlfensters: dieselben Tasten, dieselben Plätze, mit
Maus, Finger und PC-Tastatur gleich bedienbar. Man kann sich alles in Ruhe anschauen, erst eine Aktionstaste
ändert etwas. Es ersetzt das heutige Menü der Domänen und wird der Ort für Modi, Einstellungen, Bibliotheken,
eigenen Code und später Sitzungen, Fachbereiche und Module.

Das Menü wird so gebaut, dass später ein Dokumenten-System als zweiter Menübaum ohne Umbau dazukommen kann.

## Heute
- MENÜ öffnet ein Auswahlfenster mit den eingebauten Domänen und allen Bibliotheken (doc/app.md 3.4); die Wahl
  legt fest, welche Seiten die Funktionstasten zeigen. Shift+MENÜ schaltet den Hilfe-Modus ein.
- Die Bedienmodi sind schon eigene Objekte (VA-9, app/lib/model/modes.dart): ein Modus liefert die Beschriftung
  und behandelt die Tasten selbst. Das Menü wird ein weiterer Modus (doc/architecture.md 4.3).
- AC löscht Eingabe und Stack, nicht aber Variablen und eigene Funktionen; die sollen über das Menü gelöscht
  werden (FA-18, doc/app.md 3.1).

## Grundgedanke: Menübäume, die durch die Reihen des Tastenfelds laufen
Reihen wie in doc/app.md 3.1: R1 mit MENÜ, R2 `'` `( )` `[ ]` `{ }` CL ⌫, R3–R4 der Funktionsblock (F1–F10),
R5 `!` … `%`, darunter der Ziffernblock mit den Rechentasten ÷ × − + und ENTER.

- Ein Menübaum ist eine Folge von Ebenen. Jede Ebene liegt auf einem **Bereich des Tastenfelds** (eine Reihe, der
  Funktionsblock, der Ziffernblock); die nächste Ebene erscheint im nächsten Bereich. Man sieht so den ganzen Weg
  auf einmal und kann auf jeder Ebene neu wählen.
- Die Rechentasten (÷ × − + ENTER) sind in jedem Baum die Aktionen; ENTER schließt ab.
- Es gibt zwei Einstiege mit entgegengesetzter Richtung:
  - **Hauptmenü** (Rechner): beginnt **unten** auf dem Ziffernblock (Tasten 1–9) und läuft nach oben zum
    Funktionsblock.
  - **Dokumenten-System** (später, siehe unten): beginnt **oben** in R2 und läuft nach unten bis zum Ziffernblock.
- **Kontext:** Das Hauptmenü ist das Kontextmenü des ganzen Rechners (der Anwendung). Das Dokumenten-System hat
  eigene Ebenen: Ordner, Dokument, Problem, Seite, Bereich. Das Hauptmenü gehört zu keiner davon.
- Folge für die Umsetzung: Menüeinträge, Ebenen und die Zuordnung Ebene → Bereich des Tastenfelds sind Daten; der
  Menü-Modus kennt keine feste Reihe. Dann ist das Dokumenten-System ein weiterer Baum, kein Umbau.

## Verhalten (Vorschlag)

### Hauptmenü auf den Tasten 1–9
- MENÜ öffnet das Hauptmenü, ein zweiter Druck auf MENÜ schließt es.
- Die Tasten 1–9 zeigen die Bereiche, jeder mit Symbol:

  ```
  7 8 9   Hamburger-Menü   Modi      Einstellungen      allgemeine Themen
  4 5 6   Bibliotheken     Code      Sitzungen          nachladbare Komponenten
  1 2 3   Fachbereiche     Module    Ansicht            professionelles Arbeiten
  ```
  Die Dokumente sind hier nicht mehr dabei; sie bekommen einen eigenen Einstieg (siehe unten). Dazu kommt
  **Connect** auf `.` (siehe unterste Reihe).
- **Ansicht** (Taste 3) ist für schnelle Umschaltungen während der Arbeit, die sofort wirken, z.B. Hoch- und
  Querformat (FA-5) oder Maximieren der Anzeige (doc/app.md 3.5): MENÜ, 3, Funktionstaste, also drei Tastendrücke.
  Klassische Einstellungen wie Sprache und Theme stehen in den Einstellungen (Taste 9).
- **Seiten der Anzeige** (unter Ansicht): welche Seiten die Anzeige zeigt und in welcher Reihenfolge.
  - Der Funktionsblock zeigt die Liste der Seiten; ein Druck schaltet eine Seite ein oder aus (Toggle).
  - **Der Stack bleibt immer drin**; alle anderen Seiten, auch die Eingabezeile, lassen sich abwählen.
  - Die Tasten `!` … `%` (R5) sind Auswahlfelder, z.B. Hoch- und Querformat.
  - Während man umschaltet, zeigt die Anzeige eine Vorschau, z.B. die gewählten Seiten als Leiste.
  - Die zuletzt eingeschaltete Seite ist markiert. Eine andere markiert man, indem man sie zweimal drückt (aus
    und wieder an).
  - Die Tasten + und − verschieben die markierte Seite nach hinten bzw. vorne.
  - Neu eingeschaltete Seiten kommen an ihren festen Platz in einer vorgegebenen Grundreihenfolge (Stack,
    Eingabe, Funktionen, Variablen …); verschoben wird danach mit + und −. Zweimal drücken ändert den Platz nicht
    und ist deshalb eindeutig nur markieren.
  - ÷ schaltet um, ob man nach dem Übernehmen gleich in die markierte Seite springt (wie sonst ÷ = umschalten).
  - ENTER übernimmt alles auf einmal, MENÜ bricht ab.
  - Ist die Eingabezeile abgewählt, steht die aktuelle Eingabe klein über dem Stack (FA-29).
  - Gespeichert als globale Einstellung der App; im Dokumenten-System bis zur Ebene Problem überschreibbar.
- **Connect** (künftig, FA-28): Anbindung von Clients, z.B. VS Code als Entwicklungsumgebung, mehrere Benutzer am
  selben Dokument (der Rechenkern läuft dann im Server, die App wird Client), Chat, Eingabe von Sensordaten, ein
  Big-Screen-Client im Vollbild (z.B. für Vorlesungen).
- Die Anzeige zeigt einen Infoschirm: Winkel, Format, eingeschaltete Fachbereiche, geladene Bibliotheken; ist
  Platz, auch die Namen der Bereiche.

### Zweite Ebene auf den Funktionstasten
- Wählt man einen Bereich, liegen seine Einträge auf F1–F10, mit Symbol, wo es geht; Wischen und ◄ ► blättern
  wie heute bei den Funktionen.
- Die Anzeige zeigt zum gewählten Eintrag den vollen Namen und eine Beschreibung.
- **Die Auswahl allein ändert nichts.**

### Aktionen
Erst eine dieser Tasten löst etwas aus; sie wirken auf den gewählten Eintrag, je nach seiner Art:

| Taste | bei einem Wert             | bei einer Liste (Bibliotheken, Code) |
|-------|----------------------------|--------------------------------------|
| ÷     | umschalten (an/aus)        | „dauerhaft“ an/aus                   |
| ×     | leeren / zurücksetzen      | alle entladen (mit Rückfrage)        |
| −     | herunterzählen             | entladen / entfernen                 |
| +     | hochzählen                 | laden, im Menü bleiben               |
| ENTER | übernehmen, Menü schließen | laden, Menü schließen                |

- Die Bedeutungen gelten für alle Listen im Menü gleich, auch im Dokumenten-System. Shift-Belegungen der
  Aktionstasten sind möglich.
- Bei − und + steht „hoch“ unter „herunter“; die Tasten behalten trotzdem ihre Plätze.
- Grundsatz: Tasten mit demselben Symbol stehen, wo immer es geht, an derselben Stelle.
- Zwischen zwei Ansichten einer Liste (z.B. verfügbare und geladene Bibliotheken) wechselt eine eigene Taste
  (siehe Offen 1).

### Unterste Reihe des Ziffernblocks (ê 0 .)
- Exportieren und Importieren liegen nicht mehr hier, sondern im Hamburger-Menü unter Datei.
- ê öffnet künftige **Power-Funktionen**; daraus wird vielleicht ein Prompter für Chat und KI.
- `.` öffnet **Connect**: Login, Steuerung der Clients bzw. des Servers.
- 0 öffnet das **Scratchpad**: eine Rechenseite für kurze Rechnungen nebenher. Solange es kein
  Dokumenten-System gibt, ist das die heutige Rechenseite; mit FA-27 wird sie zum Scratchpad neben den
  Dokumenten (siehe „Später“).

### Power-Funktionen und wohin die Ideen gehören
Vorschläge vom 2026-11-14 (Claude) mit Jörgs Einordnung. Was später ins Dokumenten-System (FA-27) soll, liegt
vorerst unter den Power-Funktionen, damit es einen Platz hat.

| Idee | gehört zu | vorerst |
|------|-----------|---------|
| Prompter für Chat und KI (Frage → RPN-Code als Vorschlag, Fehler erklären, Formel aus Foto, Spracheingabe) | Power-Funktionen | Power-Funktionen |
| Stapelverarbeitung (eine Funktion auf jede Zeile einer CSV-Datei) | Power-Funktionen oder Import | Power-Funktionen |
| Solver (Nullstelle, nach einer Variablen auflösen) | normaler Funktionsumfang oder Dokumenten-System | Power-Funktionen |
| Numerik auf Funktionen (Integral, Ableitung, Minimum/Maximum) | normaler Funktionsumfang oder Dokumenten-System | Power-Funktionen |
| Parameter-Sweep (Funktion über eine Reihe von Werten, als Tabelle oder Graph) | normaler Funktionsumfang oder Dokumenten-System | Power-Funktionen |
| Formel nach RPN; im Dokumenten-System wird vor allem RPN nach Formel gebraucht | Dokumenten-System | Power-Funktionen |
| Rechenweg als Dokument (Verlauf, Stack, Variablen als Markdown, LaTeX, PDF) | Dokumenten-System | Power-Funktionen |
| Regression und Fit (Messwerte hinein, Kurve und Parameter heraus) | Dokumenten-System | Power-Funktionen |
| Makro-Rekorder (Tastenfolge als eigene Funktion speichern) | Code (Taste 5) | Code |
| Debugger und Schrittmodus (FR-6) | Code (Taste 5) | Code |
| Tests für eigene Funktionen (Beispiele mit erwartetem Ergebnis) | Code (Taste 5) | Code |

### Hamburger-Menü
Für Dinge, die man sonst schlecht einordnen kann, aber ab und zu braucht; gegliedert wie die Menüleiste eines
Programms, grob nach dem Vorbild von VS Code:
- **Datei:** Neu (alles löschen wie nach einem Neustart), Laden / Importieren, Speichern / Exportieren (für ein
  Objekt wie eine Bibliothek, eine Funktionsgruppe, eine Sitzung, und die Gesamtsicherung).
- **Bearbeiten:** künftig komplexere Aktionen, z.B. Suchen in Dateien.
- **Ansicht:** seltene oder ungewöhnliche Dinge rund um die Darstellung (in VS Code z.B. Suchen, allgemeines
  Aussehen), keine klassischen Einstellungen; die schnellen Umschaltungen stehen unter Ansicht im Hauptmenü.
- **Ausführen:** noch offen.
- **Hilfe:** Info (Verweise auf Homepages), Infoschirm mit Version, Kontakt, Rückmeldung bzw. Kommentar auf GitHub.

### Werte eingeben
- **Zahlen:** Der Ziffernblock überdeckt das Hauptmenü für die Dauer der Eingabe.
- **Text:** NumAlpha. Die Anzeige zeigt Alpha; der Modus endet nicht bei einer Ziffer, sondern mit ALPHA, ENTER
  (übernimmt), MENÜ (bricht ab) oder ⌫ auf der leeren Eingabe (bricht ab). Danach ist man wieder in der zweiten
  Ebene.

### Übernehmen, abbrechen, zurück
- ENTER übernimmt.
- MENÜ, ein anderer Eintrag der zweiten Ebene oder ein anderer Bereich brechen die Auswahl ab.
- ⌫ bewirkt im Menü selbst nichts, weil das Hauptmenü immer sichtbar bleibt. In einer Eingabe löscht es Zeichen
  für Zeichen, auf der leeren Eingabe bricht es ab. Gibt es mehr als zwei Ebenen, führt ⌫ eine Ebene zurück.

### Hilfe
- Shift+MENÜ auf einem Eintrag zeigt seine Hilfe, wie heute bei den Tasten.
- Menüeinträge haben einen eigenen Namensraum, z.B. `menue:modi`, wie heute `app:` und `konsole:`.
- Der Tooltip von MENÜ zeigt das Hauptmenü so, wie es auf dem Ziffernblock liegt; bis das Menü umgesetzt ist,
  bleibt der heutige Text.

### PC-Tastatur
- 1–9 wählen den Bereich; `/` umschalten, `*` leeren, `-` und `+` zählen, Enter übernimmt.
- Die Pfeiltasten gehören der Anzeige; im Funktionsblock bewegen deshalb **W A S D** eine Markierung. Weil die
  Auswahl nichts ändert, ist die Markierung schon die Auswahl; Enter führt aus. In NumAlpha sind W A S D
  Buchstaben.
- F2–F10 bleiben frei; falls nötig, ginge Strg+1 … Strg+0 für die Funktionstasten.

### Einträge als Daten
Ein Eintrag beschreibt sich selbst: Kennung, Symbol, Name, Beschreibung, Hilfe-Kennung; Art (Schalter, Zahl,
Auswahl aus Werten, Text, Aktion, Liste, Untermenü); Lesen und Setzen des Werts. Die Aktionstasten wirken je nach
Art; Hilfe, Tooltips und Übersetzungen ergeben sich aus den Daten. Menüaktionen gehen direkt an die API, nicht als
getippter Text durch die Eingabezeile.

## Später: Dokumenten-System (FA-27, nicht Teil von FA-6)
Nur so weit beschrieben, wie es das Menü bestimmt. Es ist kein Unterpunkt des Hauptmenüs, sondern ein eigener
Einstieg in R2 (`'` `( )` `[ ]` `{ }` CL ⌫) mit eigenem Menübaum, der von oben nach unten läuft. Beispiel „neue
Seite mit einem Graphen“:

| Reihe | Inhalt |
|-------|--------|
| R1 | MENÜ |
| R2 | „Neue Seite“ gewählt |
| R3–R4 (Funktionsblock) | Minibilder der Seiten des aktuellen Problems; man sieht, dass die Seite eingefügt wurde |
| R5 (`!` … `%`) | Auswahlfelder, z.B. „Graph“ |
| Ziffernblock | Kontextmenü der eben angelegten Seite mit Graph, z.B. Art des Graphen |
| Rechentasten | Aktionen wie im Hauptmenü; ENTER schließt die Erstellung ab und wechselt in die Seite mit dem Graphen |

**Scratchpad im Dokumenten-System:**
- Eigener Stack, eigene Variablen usw., getrennt vom Dokument, damit dort nichts durcheinander gerät.
- Der Inhalt bleibt erhalten (persistent), wie der der Dokumente.
- Das Doc-Menü (R2) hat im Scratchpad eigene Einträge: zurück zur aktuellen Seite; Inhalt des Scratchpads in die
  Seite übernehmen; umgekehrt Variablen, Stack usw. der aktuellen Seite ins Scratchpad übernehmen.
- Ein Druck auf „Übernehmen“ legt eine Auswahl auf die Funktionstasten (z.B. einzelne Variablen, Stack); man
  wählt aus und bestätigt mit ENTER. In beide Richtungen gleich. Was genau übernommen werden kann, ist noch
  genauer anzuschauen.
- Heute sieht das Scratchpad die eigenen Funktionen und alle Bibliotheken. Mit dem Dokumenten-System wählt man
  über das Doc-Menü, welche Einstellungen gelten: die eines Problems (dessen Fachbereiche, geladene
  Bibliotheken). Wichtig, wenn Probleme unterschiedliche Fachbereiche oder spezielle Bibliotheken haben.

## Entscheidungen
- 2026-10-31: Modi des Tastenfelds statt wachsender Fallunterscheidungen (umgesetzt mit VA-9) (Jörg).
- 2026-10-31: Menüeinträge als Daten (Jörg).
- 2026-10-31: Eigener Hilfe-Namensraum für Menüeinträge (Jörg).
- 2026-10-31: Alle Listen im Menü haben dieselben Aktionen; ENTER führt aus und schließt (Jörg).
- 2026-10-31: Im Browser soll das Menü genauso gehen; die Ablage dahinter ist Sache von RG-2 (Jörg).
- 2026-11-01: Der Tooltip von MENÜ zeigt das Hauptmenü wie auf dem Ziffernblock (Jörg).
- 2026-11-01: F2–F10 werden nicht belegt (Jörg).
- 2026-11-13: Die Belegung des Menüs wird als Tabelle nach demselben Konzept wie DG-7 beschrieben (erzeugt, mit
  einer Liste des Geplanten), aber getrennt von der Tastentabelle (Jörg).
- 2026-11-14: Das Dokumenten-System wird kein Bereich des Hauptmenüs, sondern ein eigener Einstieg in R2 mit
  eigenem Menübaum von oben nach unten; das Hauptmenü beginnt unten. Das Hauptmenü ist das Kontextmenü des ganzen
  Rechners, nicht eines Ordners, Dokuments, Problems, einer Seite oder eines Bereichs (Jörg).
- 2026-11-14: Das Menü wird jetzt so entworfen, dass das Dokumenten-System später ohne Umbau dazukommt (Jörg).
- 2026-11-14: ê in der untersten Reihe öffnet künftige Power-Funktionen (Jörg).
- 2026-11-14: Das Hamburger-Menü sammelt Seltenes, gegliedert in Datei, Bearbeiten, Ansicht, Ausführen, Hilfe,
  grob nach dem Vorbild von VS Code (Jörg).
- 2026-11-14: Zwei Ansichten: im Hauptmenü (Taste 3) die schnellen Umschaltungen, im Hamburger-Menü seltene oder
  ungewöhnliche Dinge. Sprache und Theme sind klassische Einstellungen und stehen in den Einstellungen (Jörg).
- 2026-11-14: Exportieren und Importieren kommen aus dem Hauptmenü ins Hamburger-Menü (Datei); dafür kommen
  Ansicht und Connect ins Hauptmenü, die Dokumente entfallen dort (Jörg).
- 2026-11-14: Connect liegt auf `.`; Power-Funktionen bleiben auf ê und etwas Eigenes (vielleicht später ein
  Prompter für Chat und KI), Connect ist für Login und die Steuerung von Clients und Server (Jörg).
- 2026-11-14: Ideen, die später ins Dokumenten-System gehören, liegen vorerst unter den Power-Funktionen;
  Makro-Rekorder, Debugger und Tests gehören zu Code (Jörg).
- 2026-11-15: 0 in der untersten Reihe öffnet das Scratchpad, mit eigenem, persistentem Zustand; Übernehmen in
  beide Richtungen über eine Auswahl auf den Funktionstasten; Funktionen und Bibliotheken später über das
  Doc-Menü auf die Einstellungen eines Problems abbildbar (Jörg).
- 2026-11-15: Unter Ansicht wählt man die Seiten der Anzeige: Toggle im Funktionsblock, Auswahlfelder auf R5,
  Vorschau in der Anzeige, ENTER übernimmt. Nur der Stack bleibt immer drin, die Eingabezeile ist abwählbar.
  Die Tasten + und − verschieben die markierte Seite. Global gespeichert, im Dokumenten-System bis zum Problem
  überschreibbar (Jörg).
- 2026-11-15: Feste Grundreihenfolge der Seiten; ÷ schaltet um, ob man nach ENTER in die markierte Seite
  springt (statt ×, das sonst „leeren“ heißt) (Jörg).
- 2026-11-15: Ohne Eingabezeile steht die aktuelle Eingabe klein über dem Stack; eigener Eintrag FA-29 (Jörg).
- 2026-11-15: Regel für Auswahlfelder mit Mehrfachauswahl: die Taste schaltet direkt um, erst ENTER übernimmt;
  das hält „die Auswahl allein ändert nichts“ ein (Jörg).

## Offen
Viele Punkte hängen davon ab, welche Erweiterungen welche Änderungen in der Bedienung bringen; FA-6 bleibt
deshalb vorerst auf Reife 3.

1. **Taste für den Wechsel der Ansicht** (z.B. verfügbare ↔ geladene Bibliotheken): `~` geht nicht, weil es
   überall Präfix ist. TAB wird vielleicht gebraucht, wenn es mehr Text anzuzeigen gibt (z.B. bei einer
   Dateiauswahl). Alternative: `:`.
2. **Ausführen** im Hamburger-Menü: was gehört hinein?
3. **Beginnt unten:** Ist nur die Richtung Ziffernblock → Funktionsblock gemeint, oder auch die Reihenfolge der
   Bereiche (1 zuerst, statt 7)?
4. **Wie öffnet man das Dokumenten-System?** Zeigt MENÜ beide Einstiege zugleich (R2 und den Ziffernblock), oder
   gibt es eine eigene Taste?
5. **Erster Umfang.** Welche Bereiche kommen in die erste Version? Vorschlag: der Rahmen (Hauptmenü, zweite
   Ebene, Aktionen, Hilfe) mit Modi (Winkel), Bibliotheken (laden wie heute über die Domänen, entladen erst mit
   der Herkunft der Funktionen) und Code (Variablen und eigene Funktionen löschen, siehe FA-18).
6. **Was wird aus dem Domänen-Menü?** Vorschlag: Es entfällt; die Wahl der Seiten für die Funktionstasten geht in
   den Bereich Bibliotheken, bis Fachbereiche (FA-7) sie übernehmen.
7. **⌫ lange drücken** löscht die ganze Eingabe, überall in der App (im Alpha-Modus geht Shift+⌫ nicht, weil
   Shift Großbuchstaben macht); an der PC-Tastatur Esc. Gehört das hierher oder in einen eigenen Eintrag?
8. **Noch nicht umgesetzte Bereiche:** sichtbar mit Hinweis „kommt später“ oder ausgeblendet?

## Später: Ideen für einzelne Bereiche
- **Code:** „Speichern“ und „Laden“ für eigene Programme auf `!` und `^` (R5) (Jörg, 2026-11-15).

## Nicht hier
Die Inhalte der Bereiche haben eigene Einträge: Fachbereiche FA-7, Sitzungen FA-8, Bibliotheken hinzufügen FA-12,
Anzeigeformat FR-3, Enter-Verhalten FA-11, Speicher in allen Umgebungen RG-2, Vektoren und Matrizen FS-2,
Dokumenten-System FA-27, erster Schritt FA-30 (Bibliotheken), Hamburger-Menü FA-31, Einstellungen als ein Objekt FR-9, Herkunft der Funktionen FR-10, Menü-Modell im Kern
RG-5, Konsolenmenü FK-2. Noch ohne Eintrag (aus der Diskussionsgrundlage): Funktionsgruppen als eigene
Bibliotheken, eigener Werttyp für Module.

## Bezüge
VA-9 (Bedienmodi), RG-1 (Architektur-Review vor dem Menü), FA-18 (AC und das Menü), DG-7 (Tastentabelle), FK-2
(Konsolenmenü, Nähe zum App-Menü); doc/app.md 3.1 (Reihen), 3.4 (Domänen, MENÜ), doc/architecture.md 4.3
(Modi); Diskussionsgrundlage vom 31.10.2026 in scratchpad/Menue.md (Kapitel 1, 2, 3.1, 3.2, 3.8, Frage A).

## Umsetzung und Tests
