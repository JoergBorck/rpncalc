# RPN-Rechner – Hinweise für Claude

Kurz gehalten (PG-6); die Regeln der Zusammenarbeit stehen in [process/workflow.md](process/workflow.md), die
Aufgaben in [process/backlog.md](process/backlog.md), Erledigtes in [process/done.md](process/done.md); Lessons Learned
in [process/lessons.md](process/lessons.md) (Team) und [process/lessons-claude.md](process/lessons-claude.md), gelesen beim Prozess-Review.
Antworten auf Deutsch.

## Wo was liegt

| Ordner | Inhalt |
|---|---|
| `lib/` | der Rechner in Dart; einzige Tür für Oberflächen ist `lib/rpnapi.dart` (`RpnApi`) |
| `lib/src/language/` | Grammatik (DEA-Tabelle in `grammar.dart`), DEA, Parser, Tokens |
| `lib/src/engine/` | Interpreter, Calculator mit den Mixins (Funktionen, Operatoren, Speicher …), Stack |
| `lib/src/api/`, `console/`, `net/` | Zustand und Bibliotheken hinter der Tür; Konsole; Socket-Server |
| `bin/` | Konsole mit Menü (`rpncalc.dart`), Server, Client |
| `app/` | Flutter-App: `lib/model/` (Zustand ohne Widgets), `lib/display/`, `lib/keypad/`, `lib/keys.dart` |
| `library/` | mitgelieferte Bibliotheken `*.rpnlib`, in `system/` die eingebaute Hilfe |
| `doc/` | Spezifikation: `reference.md` (Sprache), `api.md`, `app.md`, `keys.md` (Tastenfeld), `architecture.md` |
| `process/` | Backlog, done.md, workflow.md, `requirements/` (eine Datei je Eintrag), `testing/` |
| `tool/` | Werkzeuge: changelog, requirements, veroeffentlichen, bibliotheken, hilfe, trace |
| `scratchpad/` | Jörgs Notizen – lesen ja, **nie committen** |

Jede Dart-Datei beginnt mit einem Kopfkommentar „Aufgabe / Abgrenzung / Siehe auch“: erst den lesen, dann
entscheiden, ob man den Rest braucht.

## Befehle

| Zweck | Befehl |
|---|---|
| Tests Rechner | `dart test -r failures-only` (im Wurzelordner) |
| Tests App | `flutter test -r failures-only` (in `app/`) |
| Analyse | `dart analyze`; in `app/` `flutter analyze` |
| Spur einer Eingabe | `dart run tool/trace.dart --nur token,rechner,stack,fehler "3 4+"` (PR-1; `--max` begrenzt, Standard 2000) |
| Tastenprotokoll der App | Datei `process/testing/logs/protokoll.txt` (aus „RPN App (Windows)“); abspielen in `app/`: `flutter test test/replay_test.dart --dart-define=RPN_ABSPIELEN=../process/testing/logs/protokoll.txt` (PA-1) |
| Nach Änderung an `library/*.rpnlib` | `dart run tool/bibliotheken.dart` |
| Nach Änderung an Tasten oder Menübaum (`app/lib/keys.dart`, `menu_tree.dart`, `doc/keys_planned.txt`) | `dart run tool/keytable.dart` (DG-7) |
| Nach einem Eintrag in done.md | `dart run tool/changelog.dart` |
| Nach jeder Änderung an Backlog oder done.md | `dart run tool/requirements.dart` (neuer Eintrag: Zeile `- ID` in process/requirements/README.md) |

## Konventionen

- Bezeichner und Kommentare deutsch, Datei- und Ordnernamen englisch.
- Kein `dart format` (die Ausrichtung im Code ist gewollt).
- Erst die Spezifikation (doc/, process/requirements/), dann der Code.
- Committen und pushen nur auf Wunsch; veröffentlicht wird nur mit `tool/veroeffentlichen.dart` und nur auf
  Wunsch. `app/.metadata` und `scratchpad/` nie committen.
- Commit-Nachrichten enden mit `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Erledigt: Eintrag mit Commit-Hash nach done.md (Folge-Commit), sichtbare F/B/V mit Zeile `EN: …`.
- Lokale Server nur auf 127.0.0.1.

## Fehlersuche

- Rechner: zuerst die Spur (`tool/trace.dart`), mit `--nur` knapp halten.
- App: zuerst das Tastenprotokoll lesen bzw. abspielen; ein Protokoll unter `app/test/protocols/*.txt` wird
  zum Regressionstest.
