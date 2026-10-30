import 'dart:io';

import 'package:rpncalc/console/library.dart';
import 'package:test/test.dart';

/// Suche nach Bibliotheken (.rpnlib), siehe doc/api.md Kapitel 7.
void main() {
  late Directory basis;
  void datei(String pfad) => (File("${basis.path}/$pfad")..createSync(recursive: true)).writeAsStringSync("{{1}':f}");

  setUp(() {
    basis = Directory.systemTemp.createTempSync("rpnlib_test");

    datei("a/library/statistik.rpnlib");
    datei("b/statistik.rpnlib");               // gleicher Name in einem anderen Verzeichnis
    datei("a/schwingungen.rpnlib");
    datei("a/session.rpn");                    // Session, keine Bibliothek
    datei(".git/versteckt.rpnlib");            // versteckte Verzeichnisse werden übersprungen
    datei("build/gebaut.rpnlib");
    datei("node_modules/fremd.rpnlib");
    datei("1/2/3/4/5/zu_tief.rpnlib");         // Ebene 6
    datei("1/2/3/4/tief_genug.rpnlib");        // Ebene 5
  });

  tearDown(() => basis.deleteSync(recursive: true));

  test('findet .rpnlib, sortiert, gleiche Namen mit Verzeichnis', () {
    datei("c/statistik.rpnlib"); // derselbe Name in einem zweiten Verzeichnis
    final titel = [for (final b in findeBibliotheken(start: basis)) b.titel];
    expect(titel, ["schwingungen", "statistik (b)", "statistik (c)", "tief_genug"]);
  });

  test('die Datei gehört zum Titel, gefundene Dateien sind nicht mitgeliefert', () {
    final b = findeBibliotheken(start: basis).firstWhere((b) => b.titel == "statistik");
    expect(b.datei!.path.replaceAll("\\", "/"), endsWith("b/statistik.rpnlib"));
    expect(b.mitgeliefert, isFalse);
  });

  test('das Verzeichnis library wird übersprungen, die mitgelieferten kommen aus dem Rechner', () {
    final titel = [for (final b in findeBibliotheken(start: basis)) b.titel];
    expect(titel.where((t) => t.contains("library")), isEmpty);
    expect(const Bibliothek("statistik").mitgeliefert, isTrue);
  });

  test('ohne Bibliotheken eine leere Liste', () {
    expect(findeBibliotheken(start: Directory("${basis.path}/leer")..createSync()), isEmpty);
  });
}
