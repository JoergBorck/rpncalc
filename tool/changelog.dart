import 'dart:io';

/// Erzeugt CHANGELOG.md aus dem Abschnitt „Erledigt“ des Backlogs (DG-2, process/backlog.md):
/// je „### Version …“ eine Liste auf Englisch, aus den Zeilen „EN: …“ der Einträge, ohne Commit-Hashes.
///
///   dart run tool/changelog.dart        CHANGELOG.md schreiben
///
/// Aufgenommen wird, was im Produkt sichtbar ist: Feature, Bug, Verbesserung (F, B, V), Einträge mit „· sichtbar“
/// und jeder Eintrag mit einer Zeile „EN:“. Fehlt einem aufgenommenen Eintrag die Zeile, bricht es ab, ebenso
/// wenn die neueste Version nicht zur Version in pubspec.yaml passt. tool/veroeffentlichen.dart prüft, dass
/// CHANGELOG.md aktuell und committet ist.
void main() {
  final ergebnis = changelog(File("process/backlog.md").readAsStringSync(), File("pubspec.yaml").readAsStringSync());
  if (ergebnis.fehler.isNotEmpty) {
    stderr.writeln("CHANGELOG.md nicht geschrieben:");
    for (final f in ergebnis.fehler) {
      stderr.writeln("  $f");
    }
    exit(1);
  }
  File("CHANGELOG.md").writeAsStringSync(ergebnis.text);
  print("CHANGELOG.md geschrieben");
}

/// Der Stand vor dem Backlog; steht immer am Ende.
const _anfang = "## 0.1.0\n\n- Initial version.\n";

/// Der Inhalt von CHANGELOG.md und was dagegen spricht, ihn zu schreiben.
({String text, List<String> fehler}) changelog(String backlog, String pubspec) {
  final fehler = <String>[];
  final start = backlog.indexOf("\n## Erledigt");
  if (start < 0) return (text: "", fehler: ["kein Abschnitt „Erledigt“ im Backlog"]);
  final ende = backlog.indexOf("\n## ", start + 1);
  final erledigt = backlog.substring(start, ende < 0 ? backlog.length : ende);

  final versionen = <String, List<String>>{};
  String? version;
  for (final block in erledigt.split("\n### ").skip(1)) {
    final zeilen = block.split("\n");
    final kopf = zeilen.first.trim();
    final v = RegExp(r"^Version (\d+\.\d+\.\d+)$").firstMatch(kopf);
    if (v != null) {
      version = v[1]!;
      versionen[version] = [];
      continue;
    }
    final id = RegExp(r"^([A-Z]{2})-\d+").firstMatch(kopf);
    if (id == null || version == null) continue;
    final merkmale = zeilen.length > 1 ? zeilen[1] : "";
    final en = zeilen.where((z) => z.startsWith("EN:")).map((z) => z.substring(3).trim()).firstOrNull;
    final sichtbar = "FBV".contains(id[1]![0]) || merkmale.contains("· sichtbar");
    if (en == null) {
      if (sichtbar) fehler.add("${kopf.split(" ").first}: Zeile „EN: …“ fehlt");
      continue;
    }
    versionen[version]!.add(en);
  }

  final neueste = versionen.keys.firstOrNull;
  final paket = RegExp(r"^version:\s*(\S+)", multiLine: true).firstMatch(pubspec)?[1];
  if (neueste != null && paket != neueste) {
    fehler.add("die neueste Version im Backlog ($neueste) passt nicht zu pubspec.yaml ($paket)");
  }

  final text = StringBuffer("# Changelog\n\n");
  for (final e in versionen.entries) {
    if (e.value.isEmpty) continue;
    text.write("## ${e.key}\n\n");
    for (final z in e.value) {
      text.write("- $z\n");
    }
    text.write("\n");
  }
  text.write(_anfang);
  return (text: text.toString(), fehler: fehler);
}
