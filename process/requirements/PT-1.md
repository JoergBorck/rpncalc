# PT-1 `--exe` für tool/veroeffentlichen.dart: Windows-Version bauen und als Release hochladen

Prozess · Werkzeuge · klein · Reife 5 · Stand: Erledigt

## Ziel
Die Windows-Version entsteht bisher von Hand: bauen, zippen, Release auf GitHub anlegen, Text zusammenstellen.
`--exe` macht das in einem Schritt mit dem Veröffentlichen, immer gleich und ohne vergessene Teile.

## Heute
- Releases von Hand: v0.1.0 und v0.3.0 auf JoergBorck/rpncalc, beide als Pre-release; für v0.4.0 gibt es keines.
- Vorlage v0.3.0: Tag `v0.3.0`, Titel `v0.3.0 – Sliding function keys, line clearing and smoother scrolling`,
  Datei `rpncalc-0.3.0-windows.zip`, Text „## Highlights“ (von Hand, mit Erklärungen) und „## All changes“ (die
  Zeilen aus CHANGELOG.md).
- tool/veroeffentlichen.dart legt den Stand auf dem Zweig `oeffentlich` an und pusht ihn mit `--push`, mit `--web`
  dazu die Browser-Version auf `gh-pages`. Die GitHub CLI ist installiert und als JoergBorck angemeldet
  (`C:\Program Files\GitHub CLI\gh.exe`, 2026-11-21).

## Verhalten
- `dart run tool/veroeffentlichen.dart --exe --push` (auch zusammen mit `--web`): nach dem Push des Stands
  1. die Windows-Version bauen (`flutter build windows --release` in app/),
  2. den Ordner `app/build/windows/x64/runner/Release` als `rpncalc-<version>-windows.zip` packen,
  3. das Release `v<version>` auf JoergBorck/rpncalc anlegen, mit dem Tag auf dem eben gepushten Stand von
     `oeffentlich`, als Pre-release, und die Zip-Datei anhängen.
- **Version:** die aus pubspec.yaml; sie muss eine Überschrift „### Version x.y.z“ in done.md haben. Steht das
  Erledigte noch unter „### Nächste Version“, bricht `--exe` ab (erst die Version erhöhen).
- **Text des Releases** wie die Vorlage: „## Highlights“, dann „## All changes“ mit den Zeilen der Version aus
  CHANGELOG.md, zuletzt „## Download“ (Windows: Zip entpacken, `rpncalc_app.exe` starten; Browser: die Adresse
  der Pages).
- **Zip:** die Dateien des Ordners Release ohne Ordner darüber (wie v0.3.0), gepackt mit `tar -a` von Windows,
  abgelegt in `app/build/`.
- **Highlights:** ein Abschnitt je Version in done.md direkt unter „### Version x.y.z“. Die erste Zeile ist die
  Kurzfassung für den Titel (`v0.5.0 – <Kurzfassung>`), darunter die Punkte wie in der Vorlage
  (`- **Stichwort:** Erklärung`). Fehlt der Abschnitt, bricht `--exe` ab. tool/changelog.dart übergeht ihn.
- **Release gibt es schon** (gleicher Tag): die Zip-Datei ersetzen (`gh release upload --clobber`), Titel und
  Text neu setzen; kein Abbruch.
- **Ohne `--push`** bricht `--exe` ab: das Release braucht den Stand im öffentlichen Repository.
- **Ohne gh** (nicht installiert oder nicht angemeldet) bricht `--exe` vor dem Bauen ab, mit dem Hinweis auf
  `winget install GitHub.cli` und `gh auth login`. Gesucht wird `gh` im PATH, sonst unter
  `C:\Program Files\GitHub CLI\gh.exe`.

## Entscheidungen
- 2026-11-21: Highlights und Titel schreibt kein Werkzeug von selbst: ein Abschnitt je Version in done.md, Claude
  macht den Entwurf, Jörg korrigiert (Vorschlag Claude, Jörg: ja).
- 2026-11-21: Bis 1.0 immer Pre-release, wie bisher (Jörg).
- 2026-11-21: Gibt es das Release schon, wird die Datei ersetzt statt abzubrechen (Jörg).
- 2026-11-21: Keine Signatur; die Warnung von SmartScreen beim ersten Start ist in Ordnung (Jörg).
- 2026-11-21: Name, Tag und Aufbau des Textes wie die Releases von Hand (v0.3.0), damit die Seite einheitlich
  bleibt (Claude).
- 2026-11-22: Auch „## Download“ aus der Vorlage gehört zum Text; abgebrochen wird auch, wenn unter „### Nächste
  Version“ noch Einträge stehen, sonst trüge die Windows-Version die alte Nummer mit neuem Inhalt (Claude).

## Offen

## Bezüge
PT-2 (Werkzeuge), process/workflow.md (Veröffentlichen), tool/changelog.dart (CHANGELOG, Versionen),
tool/veroeffentlichen.dart, doc/architecture.md (Werkzeuge).

## Umsetzung und Tests
- 2026-11-22: tool/veroeffentlichen.dart mit `--exe`: alle Prüfungen (push, Windows, gh, Version, Highlights,
  CHANGELOG) vor dem Stand, damit nichts halb veröffentlicht wird; nach dem Push `windowsRelease` (bauen, packen
  mit tar von Windows, `gh release create` bzw. `upload --clobber` und `edit`). Titel und Text: `releaseText`.
  Tests: test/veroeffentlichen_test.dart (Text, Abbrüche, changelog.dart übergeht die Highlights). Von Hand
  geprüft: Abbruch ohne `--push`, die Zip ist flach wie v0.3.0. Der erste echte Lauf kommt mit der nächsten Version.
