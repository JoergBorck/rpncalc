# RG-3: Toter Code

Stand 2026-11-07. Kandidaten aus den Kopfkommentaren (DG-6), je Kandidat Benutzer, Bewertung und Entscheidung
(Jörg). Umsetzung in VG-3, das Logging untersucht RG-4.

| Kandidat | Wer benutzt ihn | Entscheidung |
|---|---|---|
| `verbosity` in parser.dart, dea.dart und core.dart, dazu `errorNichtImplementiert` (dea.dart) | niemand setzt es; gedacht für ein Logging, um Laufzeitfehler zu finden | entfernen; ein richtiges Logging wird RG-4 |
| `nocmd`, `noparam`, `nyi`, `resultSuccess`, `resultPending` (parser.dart) | Rückfall-Werte, die bei Fehlern im Code (nicht in der Eingabe) greifen | bleiben, mit Kommentar, wozu |
| `hasExponent`, `isTag`, `matissensPuffer`, `exponentenPuffer` (token.dart) | niemand; Reste eines früheren Aufbaus der Zahlen und Tags | entfernen |
| `ausgabe`, `x`/`y`/`z`/`t`, Standardgröße 20 (stack.dart) | zum Teil Tests und Selbsttest | bleibt vorerst |
| `eingabe` (net/client.dart) | test/protocol_test.dart; Gegenstück zur Nachricht `{"eingabe": …}` für Clients, die ganze Zeilen schicken | bleibt, Kommentar ergänzen |
| Rückgabewert von `_laden` (console/ui.dart) | der einzige Aufrufer ignoriert ihn; die Meldung gibt `_laden` selbst aus | entfernen (`void`) |
| `isAction` (console/menu.dart) | niemand; `Menu.call()` prüft stattdessen `subMenu == null`, ein leeres Untermenü liefe endlos | in `call()` benutzen |
| „Test-Einträge“ `testmenu` (console/menu.dart) | Fehlbefund: das echte Hauptmenü, bin/rpncalc.dart benutzt es | umbenennen in `hauptmenue`, Kommentar `// Testdata` weg |
| Text als Start in `call([dynamic start])` (console/menu.dart) | niemand; der Zweig sucht immer das Hauptmenü, egal welcher Text | `call([MenuItem? start])` |

Nicht gemacht: die allgemeine Suche nach weiteren öffentlichen Bezeichnern ohne Aufrufer. Das lohnt sich eher
mit einem Werkzeug (z.B. Analyzer-Regeln für unbenutzte öffentliche Elemente) als von Hand.
