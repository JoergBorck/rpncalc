# PT-2 tool/requirements.dart: Inhaltsverzeichnis der Anforderungen aus Gliederung und Backlog erzeugen

Prozess · Werkzeuge · klein · Reife 5 · Stand: Erledigt

## Ziel
process/requirements/README.md ordnet jede ID den Fähigkeiten des Produkts zu. Titel, Link und Status pflegt
heute Claude mit Skripten nach, nach jeder Änderung am Backlog. Das Werkzeug übernimmt das: Jörg pflegt nur die
Gliederung, Titel, Link und Status kommen aus Backlog und done.md, und ein Test sorgt dafür, dass die README nie
veraltet.

## Heute
- Die README hat Überschriften (## Fähigkeit, ### Teil) und je Eintrag eine Zeile
  `- [ID](Link) Titel · Status`; leere Teile tragen „(noch keine)“.
- Status ist der Abschnitt im Backlog (In Arbeit, Bereit, Geplant, Angedacht, Vorgeschlagen …), ✓ für erledigt,
  „✗ abgelehnt“ für abgelehnt. Der Link führt auf die eigene Datei (`ID.md`, Bugs, Recherchen und Tests in
  bugs/, research/, tests/), sonst auf den Anker im Backlog bzw. in done.md.

## Verhalten
- **Die Gliederung ist die README selbst:** Überschriften, Reihenfolge und Zuordnung legt Jörg dort fest. Für
  einen neuen Eintrag reicht eine Zeile `- FR-16` unter der passenden Überschrift.
- `dart run tool/requirements.dart` schreibt die README neu: jede Eintragszeile bekommt Link, Titel und Status
  aus process/backlog.md bzw. process/done.md; Überschriften, Einleitung und Reihenfolge bleiben, wie sie sind.
  Ein Teil ohne Einträge bekommt „(noch keine)“.
- **Titel:** wie in der Überschrift des Eintrags. **Link:** die eigene Datei, wenn es sie gibt (auch in bugs/,
  research/, tests/), sonst der Anker im Backlog bzw. in done.md, so wie GitHub Anker aus Überschriften bildet.
  **Status:** der Abschnitt im Backlog, ✓ in done.md, „✗ abgelehnt“ unter „Abgelehnt“.
- **Erledigte Bugs, Recherchen und Tests** (B, R, T): ihre Zeilen löscht das Werkzeug, solange die Einträge in
  done.md stehen, ebenso abgelehnte (sie bleiben unter „Abgelehnt“ im Backlog), wie es process/workflow.md schon
  verlangt; ihre Dateien bleiben als Nachweis.
- **Gemeldet** (mit Fehlercode 1, die README wird trotzdem geschrieben):
  - eine ID aus Backlog oder done.md, die in der README fehlt (außer erledigten B, R, T),
  - eine ID, die in der README mehrfach steht,
  - eine ID in der README, die es weder im Backlog noch in done.md gibt.
- **Test:** test/requirements_test.dart prüft wie test/changelog_test.dart, dass die README dem entspricht, was
  das Werkzeug erzeugen würde, und dass es nichts zu melden gibt.
- Danach fallen die Skripte weg, mit denen Claude die README nachgepflegt hat; workflow.md und CLAUDE.md nennen
  den Befehl (nach jeder Änderung am Backlog, wie tool/changelog.dart nach done.md).

## Entscheidungen
- 2026-11-21: Die Gliederung steht in der README selbst, keine eigene Datei (Vorschlag Claude, Jörg: ja).
- 2026-11-21: Zeilen erledigter Bugs, Recherchen und Tests löscht das Werkzeug, solange sie in done.md stehen
  (Jörg).
- 2026-11-21: IDs, die in der README fehlen, werden gemeldet, nicht unter „Unsortiert“ angehängt (Jörg): die
  Zuordnung bleibt eine bewusste Entscheidung.
- 2026-11-21: Ein Test hält die README aktuell (Jörg).

## Offen

## Bezüge
PT-1 (Werkzeuge), PG-5 (done.md), tool/changelog.dart und test/changelog_test.dart (Vorbild),
process/workflow.md (Anforderungen), process/requirements/README.md.

## Umsetzung und Tests
- 2026-11-21: tool/requirements.dart mit `anforderungen()` und `anker()`; Einträge nur aus den Abschnitten des
  Backlogs mit Einträgen (das Beispiel FA-0 unter „Einträge“ und Codeblöcke zählen nicht). Erster Lauf: VA-17
  fehlte in der README (jetzt unter „App: Layout und Schrift“), RG-4 fiel als erledigte Recherche weg, sonst
  stimmten Anker, Titel und Status mit der von Hand gepflegten Fassung überein. Tests: test/requirements_test.dart.
