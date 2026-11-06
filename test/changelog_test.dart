import 'dart:io';

import 'package:test/test.dart';

import '../tool/changelog.dart';

/// CHANGELOG.md aus dem Backlog (DG-2, tool/changelog.dart).
void main() {
  const pubspec = "name: rpncalc\nversion: 0.3.0\n";
  String backlog(String erledigt) => "# Backlog\n\n## Geplant\n\n### FA-9 offen\nFeature · App\n\n"
      "## Erledigt\n\n$erledigt\n## Abgelehnt\n\n### FA-8 nein\nFeature · App\nEN: never\n";

  test('je Version die Zeilen „EN:“ der sichtbaren Einträge, ohne Hashes; der Anfang steht am Ende', () {
    final r = changelog(
        backlog("### Version 0.3.0\n\n"
            "### FA-2 Neu\nFeature · App · Reife 5\nEN: New thing.\nErledigt 2026-11-07, abc1234\n\n"
            "### TA-2 Test\nTest · App · Reife 5\nErledigt 2026-11-07, abc1234\n\n"
            "### DG-7 Hilfe\nDoku · Gesamt · sichtbar · Reife 5\nEN: Better help.\nErledigt 2026-11-07, abc1234\n\n"
            "### Version 0.2.0\n\n"
            "### BA-1 Fehler\nBug · App · Reife 5\nEN: Fixed.\nErledigt 2026-11-03, def5678\n\n"),
        pubspec);
    expect(r.fehler, isEmpty);
    expect(r.text, "# Changelog\n\n## 0.3.0\n\n- New thing.\n- Better help.\n\n## 0.2.0\n\n- Fixed.\n\n"
        "## 0.1.0\n\n- Initial version.\n");
  });

  test('ohne „EN:“ bei einem sichtbaren Eintrag und bei falscher Version bricht es ab', () {
    final r = changelog(backlog("### Version 0.2.0\n\n### VA-3 Schrift\nVerbesserung · App\nErledigt 2026-11-07, abc\n\n"),
        pubspec);
    expect(r.fehler, [
      "VA-3: Zeile „EN: …“ fehlt",
      "die neueste Version im Backlog (0.2.0) passt nicht zu pubspec.yaml (0.3.0)",
    ]);
  });

  test('CHANGELOG.md ist aktuell (sonst: dart run tool/changelog.dart)', () {
    final r = changelog(File("process/backlog.md").readAsStringSync(), File("pubspec.yaml").readAsStringSync());
    expect(r.fehler, isEmpty);
    expect(File("CHANGELOG.md").readAsStringSync().replaceAll("\r\n", "\n"), r.text);
  });
}
