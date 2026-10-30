# rpncalc

Ein RPN-Rechner für die Konsole mit eigener, über eine Grammatik konfigurierbarer Syntax.

## Aufbau

| Ordner          | Inhalt |
|-----------------|--------|
| `lib/`          | der Rechner als Bibliothek: DEA, Grammatik, Parser, Calculator, Stack und `RpnApi` (Fassade) |
| `lib/console/`  | die Konsolen-Oberfläche: Menü, Eingabe, `Anzeige`, Zwischenablage |
| `lib/server/`   | der Socket-Server, ein eigener Rechner pro Client |
| `lib/client/`   | der Client für den Socket-Server |
| `lib/protocol.dart` | Nachrichten zwischen Client und Server (JSON, `doc/api.md` 6.1) |
| `lib/selftest/` | Testfälle für DEA, Parser und Rechner, startbar über das Menü und mit `dart test` |
| `bin/`          | Startpunkte: `rpncalc.dart` (Konsole mit Menü), `server.dart` (Socket-Server), `client.dart` |
| `app/`          | die Flutter-App für das Smartphone (`doc/app.md`), nutzt `RpnApi` per Pfad |
| `library/`      | Funktionsbibliotheken in der Sprache des Rechners (Schwingungen, Statistik) |
| `test/`         | Tests für `dart test`, nutzen die Testfälle aus `lib/selftest/` |
| `doc/`          | Sprachreferenz (`reference.md`) mit EBNF-Diagramm, API-Spezifikation (`api.md`), Architektur, Anforderungen, Demo |
| `scratchpad/`   | private Übungen mit KI-Unterstützung; `outdated/` enthält den alten Client mit Textprotokoll |

## Starten und testen

```
dart run bin/rpncalc.dart     # Konsole mit Menü
dart run bin/server.dart      # Socket-Server auf Port 4040, Ende mit Strg+C
dart run bin/client.dart      # Client, in einem zweiten Terminal
dart test
```
