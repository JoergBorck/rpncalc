import 'dart:io';

/// Übernimmt die mitgelieferten Bibliotheken aus library/*.rpnlib und die Systemdateien aus
/// library/system/*.rpnlib (z.B. die eingebaute Hilfe) als Konstanten in lib/bibliotheken.g.dart, damit es sie
/// überall gibt, auch in der App und im Browser (doc/api.md 9.1). Nach jeder Änderung an einer dieser Dateien
/// aufrufen: dart run tool/bibliotheken.dart. Ein Test merkt, wenn das vergessen wurde.
void main() {
  File("lib/bibliotheken.g.dart").writeAsStringSync(erzeugen(Directory("library")));
  print("lib/bibliotheken.g.dart geschrieben");
}

/// Der Inhalt von lib/bibliotheken.g.dart zu den .rpnlib-Dateien in [verzeichnis] und seinem Unterverzeichnis
/// system, jeweils nach Namen sortiert.
String erzeugen(Directory verzeichnis) {
  List<String> eintraege(Directory d) {
    if (!d.existsSync()) return const [];
    final dateien = d.listSync().whereType<File>().where((f) => f.path.endsWith(".rpnlib")).toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    return [
      for (final f in dateien)
        '  "${f.uri.pathSegments.last.replaceAll(".rpnlib", "")}": r\'\'\'${f.readAsStringSync().replaceAll("\r\n", "\n")}\'\'\',',
    ];
  }

  return [
    "// Erzeugt von tool/bibliotheken.dart aus library/*.rpnlib, nicht von Hand ändern (doc/api.md 9.1).",
    "",
    "/// Die mitgelieferten Bibliotheken: Name → Text der .rpnlib-Datei.",
    "const Map<String, String> mitgelieferteBibliotheken = {",
    ...eintraege(verzeichnis),
    "};",
    "",
    "/// Systemdateien aus library/system, z.B. die eingebaute Hilfe; sie erscheinen nicht unter den Bibliotheken.",
    "const Map<String, String> systemBibliotheken = {",
    ...eintraege(Directory("${verzeichnis.path}/system")),
    "};",
    "",
  ].join("\n");
}
