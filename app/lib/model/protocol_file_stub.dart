/// Aufgabe: Ersatz für die Protokolldatei, wo es kein Dateisystem gibt (Browser); siehe protocol_file_io.dart.
library;

abstract class ProtokollDatei {
  String get pfad;
  void schreibe(String zeile);
}

ProtokollDatei? protokollDateiOeffnen(String pfad) => null;
