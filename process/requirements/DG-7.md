# DG-7 Tastentabelle: jede Taste mit Funktion und Beschriftung je Präfix und Modus

Doku · Gesamt · mittel · Reife 5 · Stand: Bereit

## Ziel
Eine Tabelle aller Tasten zeigt auf einen Blick, was jede Taste tut und was sie zeigt: normal, mit Shift, nach
`~`, `|`, `~|`, mit Shift und Präfix, im Alpha-Modus, im Hilfe-Modus. Das hilft beim Planen (wo ist noch Platz,
passt eine neue Funktion zum Muster der Nachbarn) und dem Nutzer als Übersicht zum Nachschlagen.

## Heute
- Die Belegung steht verteilt: im Code (app/lib/keys.dart: `text`, `shift`, `tilde`, `shiftTilde`, `strich`,
  `beide`, `buchstabe`), in doc/app.md 3.1 (Tabelle der Reihen, nur Grund- und Shift-Belegung), in den Tooltips
  und in der Hilfe je Taste.
- Jörg hat in scratchpad/ideas.md, Abschnitt „neue Rechenfunktionen“, eine Tabelle begonnen: je Taste die
  Spalten -, ~, |, ~| und dieselben mit Shift, nach Blöcken getrennt, mit geplanten Funktionen (z.B. asin auf
  ~sin, csc auf |sin, ggT und kgV auf Shift+:, Primfaktoren auf |x).

## Verhalten
doc/keys.md ist die **Spezifikation des Tastenfelds**: welche Taste wo sitzt, was sie zeigt und was sie tut, in
jedem Modus, am Tastenfeld und an der PC-Tastatur. doc/app.md 3.1 verweist darauf statt eine eigene Tabelle zu
führen. Die Tabellen erzeugt `dart run tool/keytable.dart` aus app/lib/keys.dart und app/lib/menu_tree.dart (reines
Dart, ohne Flutter); Änderungen am Tastenfeld kommen zuerst als Geplantes in `doc/keys_planned.txt` (Spezifikation
vor dem Code), dann in den Code.
- **Halb von Hand, halb erzeugt** (wie die README bei PT-2): Was nur als Verhalten im Code steht (Hilfe-Modus, Nur
  am PC, Befehle mit `\`, Querformat), steht von Hand in doc/keys.md; das Werkzeug ersetzt nur die Blöcke zwischen
  `<!-- erzeugt: name -->` und `<!-- ende -->`.

### Aufbau von doc/keys.md
1. **Anordnung:** das Tastenfeld als Raster, je Block (obere Reihe, Funktionstasten, Ziffernblock) mit der
   Grundbeschriftung; zuerst Hochformat.
2. **Rechnen:** die Haupttabelle, unterteilt nach den Blöcken, je Taste eine Zeile im Grundmodus (bei Trig die
   Familie Kreis).
   | Taste | Modi | normal | ~ | \| | ~\| | ⇧ | ⇧~ | ⇧\| | ⇧~\| | Alpha | Symbole | PC |
   Die Spalte **Modi** ist leer, wenn die Taste in jedem Modus gleich ist; sonst steht dort ein Wort als Link auf
   die Tabelle der Modi, z.B. „Trig“ (FR-15), „Komplex“ (FS-3), „Quer“ (FA-5).
   Funktionstasten mit Platz, F1–F10 und Buchstaben; die eingebauten Domänen (Grundfunktionen, Programm, aus
   keys.dart) bekommen je eine Tabelle mit denselben Spalten, Domänen aus Bibliotheken (`*.rpnlib`) nur einen
   Verweis auf ihre Hilfe.
3. **Modi:**
   - **Modi, die einzelne Tasten umbelegen** (Trig, Komplex, Quer): je Modus eine Tabelle mit denselben Spalten,
     nur mit den Tasten, die sich ändern (z.B. „Trig: hyperbolisch“ mit sin, cos, tan).
   - **Modi mit eigenem Verhalten:** je Modus eine kleine Tabelle nur mit den Tasten, die anders wirken, davor ein
     Satz, was für alle übrigen gilt: Hilfe-Modus („jede Taste zeigt ihre Hilfe“; TAB, ENTER, Pfeile, Esc), nach
     `'` (Namen).
4. **Menü:** je Bereich eine Tabelle Taste · Wirkung · PC: Hauptmenü, Bibliotheken, Modi (mit dem Ziffernblock für
   die Stellen); weitere Bereiche mit FA-6.
5. **PC-Tastatur und Befehle:** die Spalte PC in allen Tabellen nennt das direkte Gegenstück (Leertaste für ENTER,
   F10 für MENÜ, AltGr+2 für x², / für ÷). Dazu „Nur am PC“ (Strg+C, Strg+V, Return, Esc, F1, Tottaste ^) und
   die Befehle mit `\` in einer Tabelle mit den Spalten App und Konsole (`\c` `\s` `\v` beide, `\m` App, `\q`
   Konsole). Mehr von der Konsole nicht; ihr Menü steht in ihrer Hilfe.
6. **Querformat (FA-5):** Anordnung im Querformat; geänderte Belegungen als Modus „Quer“ (Punkt 3). Bis FA-5 nur
   die Überschrift mit Verweis.

### Zellen
- In jeder Zelle genau eine Belegung: das, was auf der Taste steht, und, wenn es abweicht, was eingegeben wird
  (z.B. `≤ (~>)`).
- **Fußnoten:** Reicht der Platz in der Zelle nicht, steht dort eine Nummer, z.B. „(4)“, und die ausführliche
  Beschreibung als Fußnote unter der Tabelle: „(4) …“.
- Geplantes ist erkennbar abgesetzt (kursiv und grau, mit Verweis auf den Eintrag), damit dieselbe Tabelle zum
  Planen taugt.

### Hilfeseite „Alle Tasten“
Derselbe Aufbau, breit mit seitlichem Scrollen; die Spalte PC und „Nur am PC“ nur, wo es eine Tastatur gibt
(Windows, Browser), nicht am Handy.

### Liste des Geplanten
`doc/keys_planned.txt`, eine Zeile je geplanter Belegung:
  ```
  sin.tilde = asin
  sin.strich = csc              (FS-3)
  sin.hyp.tilde = arsinh         (FR-15)
  :.shift = ggT
  ..tilde = …
  ```
- Form: `Taste.Spalte = Text` oder `Taste.Modus.Spalte = Text`, dahinter optional der Eintrag in Klammern.
  Gelesen wird von rechts: nach dem letzten Punkt die Spalte, ein Wort davor der Modus, der Rest ist die Taste
  (so gehen auch Tasten wie `.` und `:`). Der Modus kommt in dessen Tabelle (`sin.hyp.tilde = arsinh`, `quer` für
  das Querformat); ein unbekannter Modus ist ein Fehler.
- Taste: die normale Beschriftung (`sin`, `x²`, `ENTER`, `:`).
- Spalten als Wörter wie die Felder in keys.dart: `normal`, `tilde`, `strich`, `beide`, `shift`, `shiftTilde`,
  `shiftStrich`, `shiftBeide`, `alpha`, `symbol`, `pc`. Der Hilfe-Modus hat keine Spalte mehr, er steht von Hand
  in seinem Abschnitt.
- Leere Zeilen und Zeilen mit `#` am Anfang sind Kommentare.

### Das Werkzeug prüft
Unbekannte Taste oder Spalte ist ein Fehler; Geplantes auf einer schon belegten Zelle ist eine Warnung
(Kollision); ist Geplantes inzwischen in keys.dart umgesetzt, kommt der Hinweis, dass die Zeile aus der Liste
kann. Ein Test hält doc/keys.md aktuell wie bei PT-2.

### Spalte PC
Abgeleitet aus der Eingabe der Taste: ein tippbares Zeichen steht direkt (`/` bei ÷, `^` bei yˣ); für die deutsche
Tastatur eine kleine Liste (² AltGr+2, | AltGr+<, ~ AltGr++, ê ^ e); Aktionen mit ihrer Taste (ENTER Leertaste, ⌫
Backspace, MENÜ F10, CL Esc). Die Spalte gilt für die normale Belegung; Shift-Zeichen wie > oder = tippt man, wie
sie auf der Taste stehen.

## Entscheidungen
- 2026-11-13: Aus app/lib/keys.dart erzeugt (Werkzeug unter tool/), Geplantes aus einer zweiten, von Hand
  gepflegten Liste; so veraltet die Tabelle nicht und taugt trotzdem zum Planen (Jörg).
- 2026-11-13: Ort: doc/keys.md (auch auf GitHub lesbar) und eine Hilfeseite „Alle Tasten“ (Jörg).
- 2026-11-13: Die volle, breite Tabelle auch am Handy; man scrollt seitlich (Jörg).
- ~~2026-11-13: Eine Spalte Modus/Variante, damit eine Taste je Modus eine Zeile bekommen kann, z.B. komplexe Zahlen
  kartesisch und polar~~, ersetzt am 2026-11-22 durch die Spalte Modi mit eigenen Tabellen (Jörg).
- 2026-11-13: Eine Spalte Symbole für Shift+ALPHA (FA-9) neben Alpha (Jörg).
- 2026-11-13: Modi in der Tabelle: Alpha, Großbuchstaben, Symbole, Hilfe-Modus, `'`; Domänen der Funktionstasten
  nur als Verweis. Zuerst Deutsch, Englisch mit FA-13 bzw. FR-2 (Jörg).
- 2026-11-13: Geplantes in `doc/keys_planned.txt` im Format `Taste.Variante.Spalte = Text (Eintrag)`, Spalten als
  Wörter; das Werkzeug trägt es ein und meldet Kollisionen (Jörg).
- ~~2026-11-13: Das Menü gehört nicht in diese Tabelle~~, ersetzt am 2026-11-22: Seit FA-32 liegt das Menü auf den
  Tasten und kommt mit hinein (Jörg).
- 2026-11-22: doc/keys.md wird die Spezifikation des Tastenfelds; Änderungen zuerst in keys_planned.txt, doc/app.md
  3.1 verweist darauf (Jörg).
- 2026-11-22: Gegliedert nach Bereichen: Anordnung, Rechnen, Modi mit eigenem Verhalten, Menü, PC-Tastatur und
  Befehle, Querformat (FA-5). Alpha und Symbole bleiben Spalten; eigene Tabellen nur für Modi, die das ganze
  Tastenfeld ändern, und nur mit den abweichenden Tasten (Jörg).
- 2026-11-22: PC-Tastatur als Spalte PC in allen Tabellen plus „Nur am PC“; von der Konsole nur die Befehle mit
  `\`, gemeinsam mit der App in einer Tabelle (Jörg).
- 2026-11-22: Hilfeseite mit demselben Aufbau, ohne PC am Handy (Jörg).
- 2026-11-22: Ein Bereich Querformat (FA-5) ist vorgesehen; Abweichungen als Modus „Quer“ (Jörg).
- 2026-11-22: Statt Zeilen je Variante eine Spalte **Modi** in der Haupttabelle: leer oder ein Wort als Link auf die
  Tabelle der Modi (z.B. „Trig“ für FR-15); je Modus eine eigene Tabelle nur mit den geänderten Tasten. Ersetzt die
  Spalte Modus/Variante vom 2026-11-13 (Jörg).
- 2026-11-22: Je Zelle eine Belegung; reicht der Platz nicht, eine Fußnote „(4) …“ unter der Tabelle (Jörg).
- 2026-11-22: Die eingebauten Domänen bekommen eigene Tabellen (sin, cos, tan liegen auf Funktionstasten, die Spalte
  Modi braucht dort ihre Zeile); Domänen aus Bibliotheken nur als Verweis (Jörg).
- 2026-11-22: doc/keys.md halb von Hand, halb erzeugt, mit markierten Blöcken wie bei PT-2 (Jörg).
- 2026-11-22: Der Menübaum zieht aus model/menu.dart in die reine Dart-Datei app/lib/menu_tree.dart, die Tasten von R1
  (SHIFT, ALPHA, TAB, MENÜ) als benannte Konstanten nach keys.dart: bessere Trennung von Belegung und Oberfläche,
  ein Schritt zu RG-5 (Jörg).
- 2026-11-22: Spalte PC aus der Eingabe abgeleitet, mit einer Liste für die deutsche Tastatur, nur für die normale
  Belegung (Jörg).
- 2026-11-22: Funktionen, die umschalten (Toggle), bekommen ⇄ vor den Namen (Jörg schlug * vor; ⇄, weil * die
  Eingabe von × ist und in Markdown kursiv macht). Bei Funktionen steht in der Spalte PC der Name mit „…“ (sin…),
  wenn alle Belegungen mit ihrem Namen getippt werden (π: pi…); sonst folgen die Ausnahmen („ln…, außer ~ln für
  eˣ“). Eine geplante Belegung auf einer belegten Zelle zeigt den heutigen Wert davor: sinh → *⇄DEG/RAD* (Jörg).

## Offen

## Bezüge
FA-6 (Menü), FA-9 und FA-15 (Alpha, Symbole), FS-3 (komplexe Zahlen), FR-2/FA-13 (Mehrsprachigkeit), DG-3
(Hilfetexte); doc/app.md 3.1 und 3.2, app/lib/keys.dart; Jörgs Entwurf: scratchpad/ideas.md, „neue
Rechenfunktionen“.

## Umsetzung und Tests
- 2026-11-22, erster Teil: app/lib/menu_tree.dart (Menübaum aus model/menu.dart, von model.dart weitergereicht),
  R1-Tasten als Konstanten in keys.dart (`tasteShift`, `tasteAlpha`, `tasteTab`, `tasteMenue`, `tasteMaximieren`),
  tool/keytable.dart mit den Blöcken anordnung, rechnen-oben, rechnen-unten, domaenen, modi, menue-haupt, menue-modi;
  doc/keys.md mit dem Text von Hand, doc/keys_planned.txt mit den Modi Quer und Trig HYPR und den Kehrwerten aus
  FR-15 als Beispiel; doc/app.md 3.1 verweist auf keys.md. Test: test/keytable_test.dart (keys.md aktuell,
  Blöcke, Meldungen, Tasten mit Punkt, Markdown).
- 2026-11-22, Hilfeseite: Die Zeilen der Tabellen kommen aus app/lib/key_table.dart (reines Dart), das Werkzeug
  schreibt daraus Markdown, die App zeigt sie im Eintrag `app:tasten` „Alle Tasten“ (display/key_table_view.dart,
  vom Hilfeschirm eingebettet, nimmt Wischen an wie ein Verweis). Geplantes und der Text von Hand bleiben in
  doc/keys.md; leere Spalten fallen weg, PC nur am PC; Spaltenköpfe in den Farben der Hinweise. Verweis von der
  Startseite der App. Tests: test/help_test.dart (Seite schmal ohne Überlauf, Spalte PC).
