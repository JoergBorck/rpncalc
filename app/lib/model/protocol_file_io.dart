/// Aufgabe: die Protokolldatei auf dem Entwicklungsrechner (PA-1): beim Start neu, jede Zeile sofort angehängt,
/// bei etwa [maxBytes] auf die zweite Hälfte gekürzt. Ein Fehler beim Schreiben schaltet die Datei still ab, die
/// App läuft weiter.
///
/// Siehe auch: protocol.dart, protocol_file_stub.dart (Browser).
library;

import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;

class ProtokollDatei {
  static const int maxBytes = 5 * 1024 * 1024;

  final File _datei;
  int _bytes = 0;
  bool _aus = false;

  ProtokollDatei._(this._datei);

  String get pfad => _datei.path;

  void schreibe(String zeile) {
    if (_aus) return;
    try {
      final text = "$zeile\n";
      _datei.writeAsStringSync(text, mode: FileMode.append, flush: true);
      _bytes += text.length;
      if (_bytes > maxBytes) _kuerzen();
    } on FileSystemException catch (e) {
      _aus = true;
      debugPrint("Tastenprotokoll: Datei abgeschaltet ($e)");
    }
  }

  void _kuerzen() {
    final alles = _datei.readAsStringSync();
    final rest = alles.substring(alles.indexOf("\n", alles.length ~/ 2) + 1);
    _datei.writeAsStringSync(rest, flush: true);
    _bytes = rest.length;
  }
}

ProtokollDatei? protokollDateiOeffnen(String pfad) {
  try {
    final datei = File(pfad).absolute;
    datei.parent.createSync(recursive: true);
    datei.writeAsStringSync("", flush: true);
    debugPrint("Tastenprotokoll: ${datei.path}");
    return ProtokollDatei._(datei);
  } on FileSystemException catch (e) {
    debugPrint("Tastenprotokoll: keine Datei ($e)");
    return null;
  }
}
