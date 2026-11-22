import 'package:test/test.dart';

import '../tool/changelog.dart';
import '../tool/veroeffentlichen.dart';

/// Titel und Text des Releases für `--exe` (PT-1, tool/veroeffentlichen.dart).
void main() {
  const protokoll = "# Changelog\n\n## 0.5.0\n\n- New thing.\n- Fixed.\n\n## 0.4.0\n\n- Old thing.\n\n"
      "## 0.1.0\n\n- Initial version.\n";
  String done(String naechste, String highlights) => "# Erledigt\n\n## Erledigt\n\n### Nächste Version\n\n$naechste"
      "### Version 0.5.0\n$highlights\n### FA-2 Neu\nFeature · App\nEN: New thing.\nErledigt 2026-11-22, abc\n\n"
      "### Version 0.4.0\n\n### FA-1 Alt\nFeature · App\nEN: Old thing.\nErledigt 2026-11-07, def\n";

  test('Titel aus der Kurzfassung, Text aus Highlights, den Zeilen der Version und Download', () {
    final r = releaseText(done("", "Keys and help\n\n- **Keys:** all keys.\n- **Help:** better.\n"), protokoll, "0.5.0");
    expect(r.fehler, isEmpty);
    expect(r.titel, "v0.5.0 – Keys and help");
    expect(r.text, "## Highlights\n\n- **Keys:** all keys.\n- **Help:** better.\n\n"
        "## All changes\n\n- New thing.\n- Fixed.\n\n"
        "## Download\n\n- **Windows:** download `rpncalc-0.5.0-windows.zip`, unpack it anywhere and start "
        "`rpncalc_app.exe`. No installation needed.\n- **Browser:** https://joergborck.github.io/rpncalc/\n");
  });

  test('tool/changelog.dart übergeht die Highlights unter der Version', () {
    final r = changelog(done("", "Keys and help\n\n- **Keys:** all keys.\n"), "version: 0.5.0\n");
    expect(r.fehler, isEmpty);
    expect(r.text, isNot(contains("Keys")));
  });

  test('bricht ab: Erledigtes unter „Nächste Version“, fehlende Highlights, fehlende Version', () {
    expect(releaseText(done("### FA-3 Später\nFeature · App\n\n", "Kurz\n- **A:** b\n"), protokoll, "0.5.0").fehler,
        [contains("Nächste Version")]);
    expect(releaseText(done("", ""), protokoll, "0.5.0").fehler, [contains("Highlights")]);
    expect(releaseText(done("", "Kurz\n"), protokoll, "0.5.0").fehler, [contains("Highlights")]);
    expect(releaseText(done("", "Kurz\n- **A:** b\n"), protokoll, "0.6.0").fehler,
        [contains("### Version 0.6.0"), contains("CHANGELOG")]);
  });
}
