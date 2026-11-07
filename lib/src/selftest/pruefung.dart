/// Aufgabe: das gemeinsame Gerüst der Selbsttests. [Pruefung] ist das Ergebnis eines Testfalls (Eingabe,
/// erwartet, erhalten), [ausgeben] schreibt alle Prüfungen für den Menüpunkt „Test …“ und zählt die Fehler.
///
/// Abgrenzung: Die Testfälle stehen in test_dea.dart, test_parser.dart und test_calculator.dart; `dart test`
/// prüft dieselben Fälle über die Dateien in test/.
///
/// Siehe auch: test/dea_test.dart, test/parser_test.dart, test/calculator_test.dart, bin/rpncalc.dart.
library;

/// Ergebnis eines einzelnen Testfalls. Wird vom Menü und von `dart test` gleichermaßen genutzt.
class Pruefung {
  final String id;
  final String eingabe;
  final String erwartet;
  final String ergebnis;
  const Pruefung(this.id, this.eingabe, this.erwartet, this.ergebnis);

  bool get ok => erwartet == ergebnis;
}

/// Gibt alle Prüfungen aus (Fehler ausführlich) und zum Schluss eine Zusammenfassung.
/// Liefert true, wenn alle Prüfungen bestanden wurden.
bool ausgeben(String titel, List<Pruefung> pruefungen) {
  int fehler = 0;
  for (Pruefung p in pruefungen) {
    String eingabe = p.eingabe.replaceAll('\n', r'\n');
    if (p.ok) {
      print('Test ${p.id}: ok "$eingabe" => "${p.ergebnis}"');
    } else {
      fehler++;
      print('Test ${p.id}: FEHLER "$eingabe"\n'
            '   erwartet: "${p.erwartet}"\n'
            '   erhalten: "${p.ergebnis}"');
    }
  }
  print("=== $titel: ${pruefungen.length} Tests, $fehler Fehler ===");
  return fehler == 0;
}
