/// Aufgabe: hält die Tastentabelle doc/keys.md aktuell (DG-7). Die Tabellen kommen aus app/lib/keys.dart und
/// app/lib/menu_tree.dart, Geplantes aus doc/keys_planned.txt; der Text dazwischen steht von Hand in doc/keys.md.
/// Ersetzt werden nur die Blöcke zwischen `<!-- erzeugt: name -->` und `<!-- ende -->`.
///
///   dart run tool/keytable.dart     doc/keys.md neu schreiben; Meldungen nach stderr, bei Fehlern Fehlercode 1
///
/// Blöcke: anordnung, rechnen-oben, rechnen-unten, domaenen, modi, menue-haupt, menue-modi.
///
/// Abgrenzung: Das Werkzeug ändert keys.dart nicht; test/keytable_test.dart prüft bei jedem Testlauf, dass doc/keys.md
/// dem entspricht, was [tastentabelle] erzeugt. Vorbild ist tool/requirements.dart.
///
/// Siehe auch: process/requirements/DG-7.md, doc/keys.md, doc/keys_planned.txt.
library;

// app/lib ist ein eigenes Flutter-Paket; keys.dart und menu_tree.dart sind reines Dart und werden direkt gelesen
// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import '../app/lib/key_table.dart';
import '../app/lib/keys.dart';

const _doc = "doc/keys.md";
const _geplant = "doc/keys_planned.txt";

void main() {
  final ergebnis = tastentabelle(doc: File(_doc).readAsStringSync(), geplant: File(_geplant).readAsStringSync());
  File(_doc).writeAsStringSync(ergebnis.text);
  for (final m in ergebnis.meldungen) {
    stderr.writeln(m);
  }
  if (ergebnis.meldungen.any((m) => m.startsWith("Fehler"))) exit(1);
  print("keys.md geschrieben");
}


/// Eine Zeile der Tabelle (aus key_table.dart), dazu die geplanten Zellen mit ihrem Eintrag.
class _Zeile {
  final String taste;
  final Map<String, String> zellen;
  final Map<String, (String, String)> geplant = {}; // Spalte → (Text, Eintrag)
  _Zeile(this.taste, this.zellen);
  _Zeile.von(Tastenzeile z) : this(z.taste, {...z.zellen});
}

/// Ein Modus aus doc/keys_planned.txt: `modus hyp = Trig: HYPR (FR-15)`.
typedef _Modus = ({String kennung, String gruppe, String titel, String eintrag});

/// Erzeugt doc/keys.md neu aus [doc] (mit dem Text von Hand) und [geplant]; liefert den Text und Meldungen
/// („Fehler: …“, „Warnung: …“, „Hinweis: …“).
({String text, List<String> meldungen}) tastentabelle({required String doc, required String geplant}) {
  final meldungen = <String>[];
  final oben = [for (final z in obererBlock) _Zeile.von(z)];
  final unten = [for (final z in untererBlock) _Zeile.von(z)];
  final domaenenZeilen = {
    for (final d in domaenenTabellen.entries) d.key: [for (final z in d.value) _Zeile.von(z)],
  };
  final alle = {for (final z in [...oben, ...unten, ...domaenenZeilen.values.expand((l) => l)]) z.taste: z};

  // Geplantes lesen: Modi und Belegungen
  final modi = <String, _Modus>{};
  final modusZeilen = <String, Map<String, _Zeile>>{}; // Modus → Taste → Zeile
  var nr = 0;
  for (final roh in geplant.split("\n")) {
    nr++;
    final zeile = roh.trim();
    if (zeile.isEmpty || zeile.startsWith("#")) continue;
    final m = RegExp(r"^modus\s+(\w+)\s*=\s*([^:]+):\s*(.*?)\s*(?:\(([^)]*)\))?$").firstMatch(zeile);
    if (m != null) {
      modi[m[1]!] = (kennung: m[1]!, gruppe: m[2]!.trim(), titel: m[3]!, eintrag: m[4] ?? "");
      continue;
    }
    final b = RegExp(r"^(.+?)\s*=\s*(.*?)\s*(?:\(([A-Z]{2,3}-\d+)\))?$").firstMatch(zeile);
    if (b == null) {
      meldungen.add("Fehler: $_geplant:$nr: unverständlich: $zeile");
      continue;
    }
    final links = b[1]!, text = b[2]!, eintrag = b[3] ?? "";
    final punkt = links.lastIndexOf(".");
    if (punkt <= 0) {
      meldungen.add("Fehler: $_geplant:$nr: Spalte fehlt: $links");
      continue;
    }
    final spalte = links.substring(punkt + 1);
    var taste = links.substring(0, punkt);
    String? modus;
    final p2 = taste.lastIndexOf(".");
    if (p2 > 0 && RegExp(r"^[a-z]\w*$").hasMatch(taste.substring(p2 + 1)) && !alle.containsKey(taste)) {
      modus = taste.substring(p2 + 1);
      taste = taste.substring(0, p2);
    }
    if (!tastenSpalten.contains(spalte)) {
      meldungen.add("Fehler: $_geplant:$nr: unbekannte Spalte „$spalte“");
      continue;
    }
    final basis = alle[taste];
    if (basis == null) {
      meldungen.add("Fehler: $_geplant:$nr: unbekannte Taste „$taste“");
      continue;
    }
    if (modus != null && !modi.containsKey(modus)) {
      meldungen.add("Fehler: $_geplant:$nr: unbekannter Modus „$modus“ (erst `modus $modus = Gruppe: Titel` anlegen)");
      continue;
    }
    final ziel = modus == null ? basis : modusZeilen.putIfAbsent(modus, () => {}).putIfAbsent(taste, () => _Zeile(taste, {}));
    final vorhanden = ziel.zellen[spalte];
    if (vorhanden == text) {
      meldungen.add("Hinweis: $_geplant:$nr: „$links = $text“ ist umgesetzt, die Zeile kann aus der Liste");
      continue;
    }
    if (vorhanden != null && vorhanden.isNotEmpty) {
      meldungen.add("Warnung: $_geplant:$nr: „$links“ ist schon belegt mit „$vorhanden“");
    }
    ziel.geplant[spalte] = (text, eintrag);
  }

  // die Spalte Modi: die Gruppen, in denen die Taste eine eigene Zeile hat
  String modiVon(String taste) {
    final gruppen = {for (final e in modusZeilen.entries) if (e.value.containsKey(taste)) modi[e.key]!.gruppe};
    return [for (final g in gruppen) "[$g](#${_anker(g)})"].join(", ");
  }

  final bloecke = <String, String>{
    "anordnung": _anordnung(),
    "rechnen-oben": _tabelle(oben, modiVon),
    "rechnen-unten": _tabelle(unten, modiVon),
    "domaenen": [
      for (final d in domaenenZeilen.entries) "### ${d.key}\n\n${_tabelle(d.value, modiVon)}",
    ].join("\n\n"),
    "modi": _modi(modi, modusZeilen),
    "menue-haupt": _einfach(menueHauptTabelle),
    "menue-modi": _einfach(menueModiTabelle),
  };
  return (text: _ersetze(doc, bloecke, meldungen), meldungen: meldungen);
}

/// Ersetzt in [doc] den Inhalt jedes Blocks; unbekannte und fehlende Blöcke werden gemeldet.
String _ersetze(String doc, Map<String, String> bloecke, List<String> meldungen) {
  final gefunden = <String>{};
  final text = doc.replaceAllMapped(
      RegExp(r"<!-- erzeugt: ([\w-]+) -->\n.*?<!-- ende -->", dotAll: true), (m) {
    final name = m[1]!;
    final inhalt = bloecke[name];
    if (inhalt == null) {
      meldungen.add("Fehler: $_doc: unbekannter Block „$name“");
      return m[0]!;
    }
    gefunden.add(name);
    return "<!-- erzeugt: $name -->\n$inhalt\n<!-- ende -->";
  });
  for (final name in bloecke.keys) {
    if (!gefunden.contains(name)) meldungen.add("Warnung: $_doc: Block „$name“ fehlt");
  }
  return text;
}

/// Eine Tabelle mit allen Spalten; Geplantes kursiv mit dem Eintrag.
String _tabelle(List<_Zeile> zeilen, String Function(String) modiVon) {
  final b = StringBuffer()
    ..writeln("| Taste | Modi | ${tastenKoepfe.map(_esc).join(" | ")} |")
    ..writeln("|${List.filled(tastenKoepfe.length + 2, "---").join("|")}|");
  for (final z in zeilen) {
    final zellen = [for (final s in tastenSpalten) _zelle(z, s)];
    b.writeln("| ${_esc(z.taste)} | ${modiVon(z.taste)} | ${zellen.join(" | ")} |");
  }
  return b.toString().trimRight();
}

/// Eine Zelle; Geplantes kursiv mit dem Eintrag, bei einer Kollision mit dem heutigen Wert davor (sinh → *⇄DEG/RAD*).
String _zelle(_Zeile z, String spalte) {
  final text = z.zellen[spalte] ?? "";
  final heute = text == domaenenVerweis ? "[Domänen](#domänen)" : _esc(text);
  final g = z.geplant[spalte];
  if (g == null) return heute;
  final geplant = "*${_esc(g.$1)}${g.$2.isEmpty ? "" : " (${g.$2})"}*";
  return heute.isEmpty ? geplant : "$heute → $geplant";
}

/// Markdown: Zeichen, die in einer Tabellenzelle etwas bedeuten, werden geschützt.
String _esc(String s) => s.replaceAllMapped(RegExp(r"[\\|*_`]"), (m) => "\\${m[0]}");

/// Der Anker einer Überschrift wie bei GitHub.
String _anker(String s) => s.toLowerCase().replaceAll(RegExp(r"[^\p{L}\p{N} -]", unicode: true), "").replaceAll(" ", "-");

/// Das Tastenfeld als Raster: Grundbeschriftung, mit Shift dahinter.
String _anordnung() {
  String feld(Taste t) {
    if (t.funktion != null) return "F${t.funktion! + 1}";
    final text = t.reserviert ? "${t.text} reserviert" : t.text;
    return _esc(t.shift == null ? text : "$text / ${t.shift}");
  }
  final b = StringBuffer("Oberer Block (Beschriftung / Shift):\n\n")
    ..writeln("| | 1 | 2 | 3 | 4 | 5 | 6 |")
    ..writeln("|---|---|---|---|---|---|---|")
    ..writeln("| R1 | ${feld(tasteShift)} | ${feld(tasteAlpha)} | Cursorkreuz, in der Ecke frei | "
        "Cursorkreuz, in der Ecke □ / ◫ | ${feld(tasteTab)} | ${feld(tasteMenue)} |");
  var r = 2;
  for (final reihe in obereTasten) {
    b.writeln("| R${r++} | ${reihe.map(feld).join(" | ")} |");
  }
  b
    ..writeln("\nUnterer Block:\n")
    ..writeln("| | 1 | 2 | 3 | 4 | 5 |")
    ..writeln("|---|---|---|---|---|---|");
  for (final reihe in untereTasten) {
    b.writeln("| R${r++} | ${reihe.map(feld).join(" | ")} |");
  }
  return b.toString().trimRight();
}

/// Je Gruppe eine Überschrift (Ziel der Spalte Modi), je Modus eine Tabelle nur mit den geänderten Tasten.
String _modi(Map<String, _Modus> modi, Map<String, Map<String, _Zeile>> zeilen) {
  if (modi.isEmpty) return "(noch keine)";
  final b = StringBuffer();
  final gruppen = {for (final m in modi.values) m.gruppe};
  for (final g in gruppen) {
    b.writeln("### $g\n");
    for (final m in modi.values.where((m) => m.gruppe == g)) {
      b.writeln("#### $g: ${m.titel}${m.eintrag.isEmpty ? "" : " (${m.eintrag})"}\n");
      final z = zeilen[m.kennung];
      b.writeln(z == null || z.isEmpty ? "(noch keine geänderten Tasten)\n" : "${_tabelle(z.values.toList(), (_) => "")}\n");
    }
  }
  return b.toString().trimRight();
}

/// Eine einfache Tabelle aus Kopf und Zeilen (Menü).
String _einfach(({List<String> kopf, List<List<String>> zeilen}) tab) {
  final b = StringBuffer()
    ..writeln("| ${tab.kopf.join(" | ")} |")
    ..writeln("|${List.filled(tab.kopf.length, "---").join("|")}|");
  for (final z in tab.zeilen) {
    b.writeln("| ${z.map(_esc).join(" | ")} |");
  }
  return b.toString().trimRight();
}
