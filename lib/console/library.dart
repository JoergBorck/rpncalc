import 'dart:io';

/// Eine Bibliothek im Menü: mitgeliefert aus dem Rechner (ohne [datei], doc/api.md 9.1) oder eine selbst
/// gespeicherte .rpnlib-Datei von der Festplatte.
class Bibliothek {
  final String titel; // Name ohne Endung, bei gleichen Namen mit Verzeichnis
  final File? datei;
  const Bibliothek(this.titel, [this.datei]);

  bool get mitgeliefert => datei == null;
}

/// Verzeichnisse, die bei der Suche übersprungen werden (dazu alle, die mit "." beginnen). Die Dateien in
/// library/ sind die Quelle der mitgelieferten Bibliotheken; die kommen aus dem Rechner (doc/api.md 9.1).
const Set<String> _uebersprungen = {"build", "node_modules", "library"};

/// Sucht alle selbst gespeicherten .rpnlib-Dateien unterhalb von [start] (Standard: das Elternverzeichnis des
/// Startverzeichnisses), höchstens [tiefe] Ebenen tief, sortiert nach Titel.
List<Bibliothek> findeBibliotheken({Directory? start, int tiefe = 5}) {
  start ??= Directory.current.absolute.parent;
  List<File> dateien = [];
  void suche(Directory d, int ebene) {
    List<FileSystemEntity> eintraege;
    try {
      eintraege = d.listSync(followLinks: false);
    } on FileSystemException {
      return; // kein Zugriff, überspringen
    }
    for (final e in eintraege) {
      final name = e.uri.pathSegments.where((s) => s.isNotEmpty).last;
      if (e is File && name.endsWith(".rpnlib")) dateien.add(e);
      if (e is Directory && ebene < tiefe && !name.startsWith(".") && !_uebersprungen.contains(name)) {
        suche(e, ebene + 1);
      }
    }
  }

  suche(start, 1);
  String name(File f) {
    final n = f.uri.pathSegments.last;
    return n.substring(0, n.length - ".rpnlib".length);
  }

  final anzahl = <String, int>{};
  for (final f in dateien) {
    anzahl[name(f)] = (anzahl[name(f)] ?? 0) + 1;
  }
  final liste = [
    for (final f in dateien)
      Bibliothek(anzahl[name(f)]! > 1 ? "${name(f)} (${_relativ(f.parent, start)})" : name(f), f),
  ]..sort((a, b) => a.titel.compareTo(b.titel));
  return liste;
}

String _relativ(Directory d, Directory basis) {
  final p = d.absolute.path, b = basis.absolute.path;
  if (!p.startsWith(b)) return p;
  final r = p.substring(b.length).replaceAll("\\", "/").replaceFirst(RegExp("^/"), "");
  return r.isEmpty ? "." : r;
}
