# PA-1 Tastenprotokoll der App mit Wiederabspielen, Ausnahmen mit Stacktrace

Prozess · App · mittel · Reife 5 · Stand: Erledigt

Zweite Stufe aus RG-4 (Logging für die Fehlersuche).

## Ziel
Meldet Jörg „nach X passiert Y“, liest Claude das Protokoll, statt nachzufragen, und macht daraus direkt einen
Widget-Test, der den Fehler nachstellt. Unerwartete Ausnahmen gehen nicht mehr unter.

## Verhalten
- **Tastenprotokoll:** Die App merkt sich die letzten 1000 Tasten (Ringpuffer) mit dem Zustand danach:
  Taste mit Präfixen und Shift, Eingabezeile, Stack, Seite und Modus der Anzeige. Eine Zeile je Taste, Felder durch
  Tabulator getrennt, wie in PR-1.
- **Alle Plattformen:** Das Protokoll führt die App überall (Android, Browser, Windows), auch in Release-Builds;
  gerade Fehler, die nur auf dem Handy auftreten, sind sonst kaum nachzustellen.
- **Abholen:** im Kontextmenü der Anzeige ganz unten „Protokoll kopieren“, auf allen Plattformen (im Browser nach einem Klick,
  wie die übrige Zwischenablage); auf dem Handy dann in den Chat einfügen oder per Mail schicken.
- **Entwicklungsrechner:** Startet man die App aus VS Code, schreibt sie fortlaufend in eine feste Datei, z.B.
  process/testing/logs/protokoll.txt (gitignored wie die Prüfseiten). Das Ziel setzt die Startkonfiguration per
  `--dart-define`; ohne diese Angabe schreibt die App keine Datei. So liest Claude das Protokoll selbst, ohne dass
  jemand etwas kopiert.
- **Größe:** Eine Zeile hat etwa 100–300 Byte (Taste, Eingabezeile, die obersten Stack-Werte, Seite, Modus). Der
  Ringpuffer im Speicher hält 1000 Tasten, also etwa 100–300 KB. Die Datei auf dem Entwicklungsrechner wird beim
  Start der App neu begonnen und bei etwa 5 MB auf die zweite Hälfte gekürzt.
- **Wiederabspielen:** Ein Widget-Test liest ein Protokoll, drückt die Tasten der Reihe nach und vergleicht den
  Zustand nach jeder Taste; Abweichungen zeigt er mit der Zeile an. So wird aus einer Meldung ein Regressionstest.
- **Ausnahmen:** `FlutterError.onError` und `runZonedGuarded` schreiben unerwartete Ausnahmen mit Stacktrace und den
  letzten Tasten in dasselbe Protokoll.
- **Kosten:** Der Ringpuffer kostet im Normalbetrieb kaum etwas; in Release-Builds bleibt er an, damit auch Fehler
  auf dem Handy ankommen.

## Entscheidungen
- 2026-11-21: Tastenprotokoll mit Wiederabspielen und Ausnahmen mit Stacktrace als zweite Stufe (Jörg, Vorschlag
  Claude).

- 2026-11-21: Protokoll auf allen Plattformen, Abholen über „Protokoll kopieren“; auf dem Entwicklungsrechner
  fortlaufend in eine Datei unter process/testing/logs/, gesetzt per `--dart-define` aus VS Code (Jörg, Vorschlag
  Claude).

- 2026-11-21: Größe 1000 Tasten im Speicher, Datei bis etwa 5 MB (Jörg).
- 2026-11-21: Die genauen Felder einer Zeile legt Claude bei der Umsetzung fest (Jörg).
- 2026-11-21: „Protokoll kopieren“ steht als unterster Eintrag im Kontextmenü der Anzeige (Jörg).

## Offen

## Bezüge
RG-4, PR-1 (Format der Zeilen), PA-2, app/lib/model/model.dart, doc/app.md (Kontextmenü), app/test/.

## Umsetzung und Tests
- app/lib/model/protocol.dart (`Protokoll`: Ringpuffer, `bedienung`, `ausnahme`, `zerlege`), protocol_file_io.dart
  bzw. protocol_file_stub.dart (Datei, im Browser keine); keys.dart `Taste.toJson`/`fromJson`, damit sich jede
  Taste genau so wieder drücken lässt.
- Protokolliert wird in `ModellKern._bedienung` an jedem Einstieg ins Modell: Taste, Zeichen der PC-Tastatur,
  Return, Umbruch, Backspace, Tab, F1, Esc, Pfeil, Bereich, Tipp (mit dem Ergebnis der Doppelklick-Erkennung),
  Mausrad/Wischen, Seite der Funktionstasten, Auswahl im Menü, Hilfe, Kopieren, Einfügen (mit dem eingefügten
  Text). Ruft eine Bedienung eine andere auf, steht nur die äußere da. Zustand danach: zeile, stack (oberste 4),
  tiefe, fehler, bereich, modus, flags (S A ~ | ' \ M), verlauf, breite, zeilen.
- „Protokoll kopieren“ als unterster Eintrag im Kontextmenü (doc/app.md 2.1); Ausnahmen über
  `FlutterError.onError` und `PlatformDispatcher.onError` (main.dart); app/.vscode/launch.json setzt
  `RPN_PROTOKOLL` für „RPN App (Windows)“; process/testing/logs/ ist gitignored.
- Abweichung von „Verhalten“: Abgespielt wird am Modell, nicht als Widget-Test. Das ist schneller und reicht, weil
  alle Bedienungen über das Modell laufen; die Breite der Anzeige stellt das Abspielen aus dem Protokoll ein.
- app/test/protocol_replay.dart (`abspielen`), app/test/replay_test.dart: Zeilen und Zustand, nur äußere
  Bedienung, 1000 Zeilen, Ausnahme, Datei, Zwischenablage, aufnehmen und abspielen, Abweichungen; dazu jede Datei
  unter app/test/protocols/*.txt als Regressionstest und `--dart-define=RPN_ABSPIELEN=<datei>` für ein einzelnes
  Protokoll. flutter test 108 bestanden, flutter analyze ohne Befund, flutter build web gelingt, dart test 806.
