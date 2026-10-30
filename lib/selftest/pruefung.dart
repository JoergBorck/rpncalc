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
