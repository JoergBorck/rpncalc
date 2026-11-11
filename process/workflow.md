# Arbeitsweise

Wie Jörg und Claude am RPN-Rechner zusammenarbeiten. Die Aufgaben stehen in [backlog.md](backlog.md).

## Ablauf einer Aufgabe

- **Spezifikation zuerst:** reference.md (Sprache), api.md (Schnittstelle), app.md (App), dann die Umsetzung.
  Größere Spezifikationen sieht Jörg vorher durch.
- **Anforderungen:** Braucht ein Eintrag mehr als seine Zeilen im Backlog, bekommt er eine eigene Datei
  `process/requirements/ID.md` (z.B. `FA-20.md`, Vorlage in [requirements/template.md](requirements/template.md)):
  Ziel, Verhalten, Entscheidungen mit Datum, offene Fragen, Bezüge, Umsetzung und Tests. Spätestens vor „Bereit“
  (Reife 5) ist sie da und ihr Abschnitt „Offen“ leer. Der Backlog bleibt der Index, die Spezifikation
  (reference.md, api.md, app.md) beschreibt den aktuellen Stand; die Datei hält fest, wie es dazu kam.
  Committet und veröffentlicht.
  - **Inhaltsverzeichnis:** [requirements/README.md](requirements/README.md) ordnet die Einträge nach den
    Fähigkeiten des Produkts, jeden genau einmal.
  - **Bugs, Recherchen und Tests** (B, R, T) dienen dem Nachweis, nicht der Beschreibung des Systems: Ihre Dateien
    liegen in `requirements/bugs/`, `requirements/research/` und `requirements/tests/`, und sobald sie erledigt
    oder abgelehnt sind, fallen sie aus dem Inhaltsverzeichnis. Die Datei bleibt erhalten.
  - **Frage und Ergebnis getrennt:** Die Datei unter `requirements/` beschreibt die Frage bzw. was geprüft wird;
    die datierten Ergebnisse (Protokolle, Reviews) liegen unter `process/testing/` (siehe „Tests und Reviews“),
    die Datei verweist darauf. Ein Eintrag kann so mehrere Läufe haben, z.B. Handy und PC.
- **Fertig** ist eine Aufgabe nach der Definition of Done im Backlog; erst dann kommt sie mit Commit nach
  „Erledigt“.
- **Vorschläge:** Claude bringt Verbesserungen von sich aus ein (Features, Code, Prozess, Struktur) und trägt sie
  unter „Vorgeschlagen“ ein; Jörg bremst, wenn es zu viel wird.
- Endet eine Nachricht mit „...“, kommt noch mehr: erst nach der letzten antworten.

## Abläufe für wiederkehrende Fälle

Muster, auf die ein Eintrag im Backlog verweisen kann („Ablauf: Zeitbox“), statt sie jedes Mal neu zu planen.

- **Fund beim Testen:** Jeder Fund wird ein eigener Eintrag (B oder V) mit „gefunden bei …“; der Test selbst ist
  erledigt, wenn alles geprüft ist, nicht erst, wenn alle Funde behoben sind.
- **Zeitbox (Bug mit unklarer Ursache):** Statt eines Recherche-Eintrags bekommt der Bug eine Zeitbox, z.B.
  „Ursache suchen, höchstens 1 h“. Damit ist der erste Schritt klar: Reife 5, er kann nach „Bereit“. Danach einer
  von drei Ausgängen:
  1. Ursache gefunden und behebbar: gleich beheben, wie jeden Bug.
  2. Grenze der Plattform (Browser, Betriebssystem): als Hinweis in die Spezifikation (z.B. app.md), der Bug ist
     damit erledigt.
  3. Größer als gedacht: das Ergebnis in den Eintrag schreiben, die Lösung wird ein eigener Eintrag mit Reife;
     der Bug wird erledigt oder verweist darauf.
- **Recherche (R):** für offene Fragen, aus denen mehrere Einträge entstehen oder die eine Entscheidung brauchen.
  Ergebnis ist eine Entscheidung und neue Einträge, kein Code.

## Code

- Verzeichnisse und Dateien heißen englisch, Bezeichner im Code deutsch.
- Die App in `app/` schreiben wir gemeinsam. Jörgs Flutter-Übungen außerhalb dieses Projekts fasst Claude nicht an.
- Die Prüfseite der Hilfetexte: `dart run tool/hilfe.dart` (Ergebnis in `process/testing/preview/hilfe/index.html`).

## Tests und Reviews

- Protokolle von Tests von Hand kommen nach `process/testing/protocols/`, Ergebnisse von Reviews und Recherchen
  nach `process/testing/reviews/`, beide committet und veröffentlicht (Lernprojekt). Dateiname:
  `JJJJ-MM-TT_id_thema.md`, z.B. `2026-11-06_ta-1_phone.md`; der Backlog-Eintrag verweist darauf, ebenso seine
  Datei unter `process/requirements/`, wenn es eine gibt.
- Erzeugte Vorschauen (Prüfseite, App-Symbol) landen in `process/testing/preview/`, nicht committet.

## Commit und Push

- Committet und gepusht wird nur, wenn Jörg darum bittet.
- Commit-Nachrichten auf Deutsch, am Ende `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- **Nie committen:** `scratchpad/nextsteps.md`.
- `origin` ist das Akademie-Repository (privat, mit der ganzen Historie).

## Veröffentlichen

- Nur über `dart run tool/veroeffentlichen.dart [--web] [--push]` und nur auf Jörgs Wunsch. Der öffentliche
  Stand (JoergBorck/rpncalc) lässt `scratchpad/` und `spec/` weg.
- **Gate:** Das Werkzeug bricht ab, solange im Backlog ein Eintrag mit „· Gate“ offen ist oder unter „Erforderlich“ steht.
- **CHANGELOG.md** entsteht mit `dart run tool/changelog.dart` aus „Erledigt“ (englisch, je Version, aus den Zeilen
  „EN: …“); beim Verschieben nach „Erledigt“ neu erzeugen und mitcommitten. Das Werkzeug veröffentlicht nur, wenn
  er aktuell und committet ist, und die neueste Version muss zu `pubspec.yaml` passen. Erledigtes ohne neue
  Versionsnummer kommt unter „### Nächste Version“ (im CHANGELOG „Unreleased“); beim Erhöhen der Version wird
  daraus „### Version x.y.z“. Gleiche EN-Zeilen stehen je Version nur einmal.
- **Nur, was Nutzer kennen:** Ein Fehler oder eine Verbesserung an etwas, das es in der letzten veröffentlichten
  Version noch nicht gab, kommt nicht in den CHANGELOG; der Eintrag bekommt „EN: –“. Widerspricht die Änderung der
  Zeile des Features, wird stattdessen diese Zeile angepasst: Ein Feature hat genau eine Zeile im CHANGELOG.
- `--web` legt die Browser-Version auf `gh-pages` (https://joergborck.github.io/rpncalc/).
- Die Windows-Version: `flutter build windows --release` in `app/`, den Ordner `build/windows/x64/runner/Release`
  als Zip; Jörg lädt sie unter Releases hoch (ohne GitHub CLI geht es nicht automatisch, siehe PT-1).
