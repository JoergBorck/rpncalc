# rpncalc

Ein RPN-Rechner für die Konsole mit eigener, über eine Grammatik konfigurierbarer Syntax.

## Aufbau

| Ordner          | Inhalt |
|-----------------|--------|
| `lib/rpnapi.dart` | die Tür zum Rechner (`RpnApi`, `Zustand`): mehr brauchen App und Konsole nicht |
| `lib/console.dart`, `lib/net.dart` | die Türen zur Konsole und zu Server und Client, für `bin/` |
| `lib/src/`      | das Innere: `language/` (Grammatik, DEA, Parser), `engine/` (Interpreter, Calculator, Stack), `api/` (Zustand, Bibliotheken, Hilfe hinter der Tür), `help/`, `libraries/`, `console/`, `net/`, `selftest/`; Aufbau in `doc/architecture.md` |
| `bin/`          | Startpunkte: `rpncalc.dart` (Konsole mit Menü), `server.dart` (Socket-Server), `client.dart` |
| `app/`          | die Flutter-App für das Smartphone (`doc/app.md`), nutzt `RpnApi` per Pfad |
| `library/`      | Funktionsbibliotheken in der Sprache des Rechners (Schwingungen, Statistik) |
| `test/`         | Tests für `dart test`, nutzen die Testfälle aus `lib/src/selftest/` |
| `process/`      | Arbeitsweise (`workflow.md`), Backlog, Testprotokolle und Reviews unter `testing/` |
| `doc/`          | Sprachreferenz (`reference.md`) mit EBNF-Diagramm, API-Spezifikation (`api.md`), Architektur, Anforderungen, Demo |

## Starten und testen

```
dart run bin/rpncalc.dart     # Konsole mit Menü
dart run bin/server.dart      # Socket-Server auf Port 4040, Ende mit Strg+C
dart run bin/client.dart      # Client, in einem zweiten Terminal
dart test
```

## Lizenz

MIT, siehe [LICENSE](LICENSE).
