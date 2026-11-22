# PR-1 Spur einer Eingabe durch den Rechner: Zeichen, DEA, Tokens, Ausführung und Stack als Text

Prozess · Rechner · mittel · Reife 5 · Stand: Erledigt

Erste Stufe aus RG-4 (Logging für die Fehlersuche).

## Ziel
Claude (und Jörg) können einen Fehler im Rechner selbst nachstellen und Schritt für Schritt lesen, statt aus dem
Code zu raten: welches Zeichen welchen Übergang im DEA auslöst, welche Tokens entstehen, was der Calculator damit
macht und wie der Stack danach aussieht. Die Spur ist Text, lässt sich ohne Terminal starten und kostet nichts,
solange sie aus ist.

## Verhalten
- **Aufruf ohne Terminal:** `dart run tool/trace.dart "3 4+"` rechnet die Eingabe wie die zeilenweise Eingabe
  (Zeichen für Zeichen, am Ende ein Zeilenende) und schreibt die Spur nach stdout. Danach endet das Programm.
  - `--lib <name>` lädt vorher eine mitgelieferte Bibliothek (mehrfach möglich).
  - `--session <datei>` lädt vorher eine gespeicherte Session.
  - `--nur <kategorien>` beschränkt die Ausgabe, z.B. `--nur token,stack`.
  - Mehrere Eingaben als mehrere Argumente sind mehrere Zeilen hintereinander.
- **Eine Zeile je Ereignis**, Felder durch Tabulator getrennt, vorn die Kategorie:

  | Kategorie | Inhalt |
  |---|---|
  | `zeichen` | Position und Zeichen der Eingabe |
  | `dea` | Zustand, Symbolgruppe, Folgezustand, Ausgabe des Übergangs (auch Epsilon-Übergänge) |
  | `token` | Typ, Name und Argumente eines fertigen Tokens (Schreibweise wie in test_parser.dart, z.B. `F‖rpn.fix`) |
  | `rechner` | was der Calculator ausführt: Funktion, Operator, Zahl, Variable, Tag, Code; bei Code die Schachtelungstiefe |
  | `stack` | Stack nach jedem ausgeführten Token, in der Schreibweise des Rechners |
  | `fehler` | Fehlercode, Text, Position |
  | `hinweis` | Hinweise des Rechners (z.B. rpn-Name belegt) |

- **Programme:** Beim Ausführen von Code (eigene Funktionen, Bibliotheken, `loop`, `times`, `if`) sind die Zeilen
  nach der Tiefe eingerückt; die Zeichen des Codes laufen in derselben Spur (Kategorie `dea`/`token` mit Tiefe).
- **Ohne Spur unverändert:** Rechner, App, Konsole und Server verhalten sich genau wie vorher; der Haken ist eine
  optionale Funktion (`Spur?`), die nur aufgerufen wird, wenn sie gesetzt ist.
- **Auch in Tests:** Ein Test kann die Spur einschalten und die Zeilen prüfen oder bei einem Fehlschlag ausgeben.

## Entscheidungen
- 2026-11-21: Logging zuerst als Spur einer Eingabe, die man gezielt einschaltet, nicht als Log, das immer
  mitläuft; Ausgabe als Text mit festen Feldern (Jörg, Vorschlag Claude).
- 2026-11-21: Eigenes Werkzeug `tool/trace.dart` statt eines Schalters im Konsolenmenü, weil es ohne Terminal und
  ohne Rohmodus laufen muss (Claude). Kein Paket `logging`: ein Callback reicht und hält den Kern ohne
  Abhängigkeit (Claude).

## Offen

## Bezüge
RG-4 (Ergebnis), PA-1 (Tastenprotokoll der App), PA-2 (Debug-Verbindung), VG-3 (alte `verbosity` entfernt),
lib/src/language/dea.dart (`step`), parser.dart (`taste`, `_kommando`), engine/interpreter.dart,
engine/calculator.dart (`on…`, `codeAusfuehren`), selftest/test_parser.dart (Schreibweise der Tokens).

## Umsetzung und Tests
- lib/src/trace.dart (`Spur`, `Spur.liste`, `spurKategorien`); Haken in dea.dart (`step`, auch Epsilon und Fehler
  XY/XZ), parser.dart (`_zeichen`, `_kommando`, Fehler in `feed`), calculator.dart (`_schritt`, `onTrenner`,
  `codeAusfuehren` mit Tiefe); `RpnApi.spur` als Tür (doc/api.md 2), doc/architecture.md 2.
- tool/trace.dart mit `--lib`, `--session`, `--nur` (und `--max`, PR-2); nach jeder Zeile eine Zeile `ende` mit Stack und erstem
  Fehler (immer, auch bei `--nur`). Ein Leerzeichen als Trenner steht als „␣“, ein leerer Stack als „leer“.
- test/trace_test.dart: Reihenfolge der Kategorien, Filter, Einrückung im Code, Argumente, Fehler aus Grammatik und
  Rechner, ohne Spur unverändert. dart test 806 bestanden, dart analyze und flutter analyze ohne Befund.
- Schon beim ersten Lauf sichtbar: Nach `{1 2+}':f ` legt das vorgemerkte Enter vor `5` auf dem leeren Stack eine 0
  ab (`[0.0] [5.0]`); das ist so beschrieben (doc/reference.md: „Enter auf dem leeren Stack legt eine 0 ab“).
