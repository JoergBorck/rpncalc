import 'dart:convert';
import 'dart:io';

/// Prüfseite für alle Hilfetexte: Tooltips und Hilfeschirme der App als Bilder, die Hilfe der Konsole als Text,
/// je Eintrag mit Prüfstatus (✓ geprüft, ✎ seit der Prüfung geändert, ○ offen).
///
///   dart run tool/hilfe.dart                        Seite erzeugen: app/build/hilfe/index.html
///   dart run tool/hilfe.dart --geprueft S taste:R5/*  Einträge als geprüft markieren und die Seite erneuern
///
/// Bei --geprueft passt ein Name zur Kennung eines Eintrags (`rechner:S`, `app:#`, `taste:R3/D`) oder zu ihrem
/// Teil nach dem Doppelpunkt bzw. Schrägstrich (`S` trifft `rechner:S` und alle Tasten `S`); ein `*` am Ende
/// nimmt alle Kennungen mit diesem Anfang. Der Status steht in tool/hilfe_geprueft.json (Kennung → Prüfsumme
/// des Inhalts); ändert sich ein Text, gilt er wieder als ungeprüft.
const pruefDatei = "tool/hilfe_geprueft.json";
const manifest = "app/build/hilfe/manifest.json";

void main(List<String> argumente) {
  final i = argumente.indexOf("--geprueft");
  if (i >= 0) {
    erzeugen(); // die Prüfsummen müssen zum aktuellen Stand der Texte passen
    markieren(argumente.sublist(i + 1));
  }
  erzeugen();
}

/// Zeichnet die Seite mit den echten Widgets der App (flutter test im Verzeichnis app).
void erzeugen() {
  final r = Process.runSync("flutter", ["test", "tool/hilfe_test.dart"],
      workingDirectory: "app", runInShell: true, stdoutEncoding: utf8, stderrEncoding: utf8);
  final ausgabe = "${r.stdout}";
  final zeile = ausgabe.split("\n").where((z) => z.contains("Prüfseite:")).firstOrNull;
  if (r.exitCode != 0 || zeile == null) {
    stderr.write(ausgabe);
    stderr.write(r.stderr);
    exit(1);
  }
  print(zeile.trim());
}

void markieren(List<String> namen) {
  final summen = (jsonDecode(File(manifest).readAsStringSync()) as Map).cast<String, String>();
  final datei = File(pruefDatei);
  final geprueft = datei.existsSync() ? (jsonDecode(datei.readAsStringSync()) as Map).cast<String, String>() : <String, String>{};
  bool passt(String id, String name) {
    if (name.endsWith("*")) return id.startsWith(name.substring(0, name.length - 1));
    return id == name || id.endsWith(":$name") || id.endsWith("/$name");
  }

  for (final name in namen) {
    final treffer = summen.keys.where((id) => passt(id, name)).toList();
    if (treffer.isEmpty) print("Kein Eintrag passt zu $name");
    for (final id in treffer) {
      geprueft[id] = summen[id]!;
    }
    if (treffer.isNotEmpty) print("geprüft: ${treffer.join(", ")}");
  }
  final sortiert = Map.fromEntries(geprueft.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  datei.writeAsStringSync("${const JsonEncoder.withIndent("  ").convert(sortiert)}\n");
}
