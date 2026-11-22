import 'dart:io';

import 'package:test/test.dart';

import '../tool/requirements.dart';

/// Das Inhaltsverzeichnis der Anforderungen (PT-2, tool/requirements.dart).
void main() {
  const backlog = "# Backlog\n\n## In Arbeit\n\n### FA-1 Zoom: die App skaliert\nFeature · App\n\n"
      "## Angedacht\n\n### FR-2 Brüche\nFeature · Rechner\n\n"
      "## Abgelehnt\n\n### FA-3 Nein\nFeature · App\n\n"
      "## Einträge\n\n### FA-0 (Beispiel) nur ein Beispiel\n```\n### FA-9 im Code\n```\n";
  const done = "# Erledigt\n\n## Erledigt\n\n### Nächste Version\n\n### BA-4 Fehler\nBug · App\n\n"
      "### PG-5 Backlog teilen\nProzess · Gesamt\n\n";

  test('Zeilen bekommen Link, Titel und Status; eine nackte ID wird ergänzt; die Gliederung bleibt', () {
    const readme = "# Anforderungen\n\nEinleitung.\n\n## Teil\n\n### A\n\n- FA-1\n- [FR-2](alt) alter Titel · Geplant\n\n"
        "### B\n\n(noch keine)\n\n### C\n\n- FA-3\n- PG-5\n";
    final r = anforderungen(readme: readme, backlog: backlog, done: done, dateien: {"FA-1.md"});
    expect(r.meldungen, isEmpty);
    expect(r.text, "# Anforderungen\n\nEinleitung.\n\n## Teil\n\n### A\n\n"
        "- [FA-1](FA-1.md) Zoom: die App skaliert · In Arbeit\n"
        "- [FR-2](../backlog.md#fr-2-brüche) Brüche · Angedacht\n\n"
        "### B\n\n(noch keine)\n\n### C\n\n"
        "- [FA-3](../backlog.md#fa-3-nein) Nein · ✗ abgelehnt\n"
        "- [PG-5](../done.md#pg-5-backlog-teilen) Backlog teilen · ✓\n");
  });

  test('erledigte Bugs, Recherchen und Tests fallen weg; ein leerer Teil bekommt „(noch keine)“', () {
    const readme = "## Teil\n\n### A\n\n- BA-4\n\n### B\n\n- FA-1\n- FR-2\n- FA-3\n- PG-5\n";
    final r = anforderungen(readme: readme, backlog: backlog, done: done, dateien: {});
    expect(r.meldungen, isEmpty);
    expect(r.text, startsWith("## Teil\n\n### A\n\n(noch keine)\n\n### B\n\n"));
  });

  test('gemeldet: fehlende, doppelte und unbekannte IDs; Beispiele und Codeblöcke zählen nicht', () {
    const readme = "## Teil\n\n- FA-1\n- FA-1\n- FX-7\n";
    final r = anforderungen(readme: readme, backlog: backlog, done: done, dateien: {});
    expect(r.meldungen, [
      "FA-1 steht mehrfach in der README",
      "FX-7 steht in der README, aber weder im Backlog noch in done.md",
      "FR-2 fehlt in der README (backlog.md: Angedacht)",
      "FA-3 fehlt in der README (backlog.md: ✗ abgelehnt)",
      "PG-5 fehlt in der README (done.md: ✓)",
    ]);
  });

  test('Anker wie GitHub: klein, ohne Satzzeichen, Umlaute bleiben', () {
    expect(anker("PT-1 `--exe` für tool/veroeffentlichen.dart: Windows-Version bauen"),
        "pt-1---exe-für-toolveroeffentlichendart-windows-version-bauen");
    expect(anker("FA-33 Menü am PC: Fokus mit den Pfeiltasten, Leertaste drückt"),
        "fa-33-menü-am-pc-fokus-mit-den-pfeiltasten-leertaste-drückt");
  });

  test('process/requirements/README.md ist aktuell (sonst: dart run tool/requirements.dart)', () {
    final readme = File("process/requirements/README.md").readAsStringSync();
    final r = anforderungen(
      readme: readme,
      backlog: File("process/backlog.md").readAsStringSync(),
      done: File("process/done.md").readAsStringSync(),
      dateien: vorhandeneDateien(),
    );
    expect(r.meldungen, isEmpty);
    expect(readme.replaceAll("\r\n", "\n"), r.text);
  });
}
