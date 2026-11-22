/// Aufgabe: das Tastenprotokoll der App (Backlog PA-1). [Protokoll] hält die letzten [Protokoll.maxZeilen]
/// Bedienungen als Textzeilen im Speicher, auf allen Plattformen; auf dem Entwicklungsrechner schreibt es sie
/// zusätzlich fortlaufend in eine Datei, wenn die Startkonfiguration `--dart-define=RPN_PROTOKOLL=<pfad>` setzt.
/// Dazu unerwartete Ausnahmen mit Stacktrace.
///
/// Eine Zeile: Nummer, Art, Felder der Bedienung, dann „→“ und der Zustand danach als `name=wert`, alles durch
/// Tabulator getrennt (wie die Spur des Rechners, PR-1). Abgespielt wird ein Protokoll in test/protocol_replay.dart.
///
/// Abgrenzung: Welche Bedienungen protokolliert werden und welcher Zustand dazugehört, entscheidet das Modell
/// (model.dart, `_bedienung`); die Datei schreibt protocol_file_io.dart (im Browser gibt es keine).
///
/// Siehe auch: process/requirements/PA-1.md, test/replay_test.dart.
library;

import 'dart:collection';

import 'protocol_file_stub.dart' if (dart.library.io) 'protocol_file_io.dart';

class Protokoll {
  /// So viele Zeilen hält der Speicher (etwa 100–300 KB).
  static const int maxZeilen = 1000;

  /// Das Protokoll der laufenden App; auch die Fehlerbehandlung in main.dart schreibt hinein.
  static final Protokoll app = Protokoll(datei: const String.fromEnvironment("RPN_PROTOKOLL"));

  final Queue<String> _zeilen = Queue();
  final ProtokollDatei? _datei;
  int _nummer = 0;

  /// Mit [datei] (nicht leer) schreibt es zusätzlich dorthin; die Datei beginnt neu.
  Protokoll({String datei = ""}) : _datei = datei.isEmpty ? null : protokollDateiOeffnen(datei);

  /// Wohin die Datei geschrieben wird, oder null.
  String? get dateiPfad => _datei?.pfad;

  int get anzahl => _zeilen.length;

  /// Alle Zeilen im Speicher, die älteste zuerst.
  String get text => _zeilen.join("\n");

  /// Eine Bedienung der [art] mit ihren [felder]n und dem [zustand] danach.
  void bedienung(String art, List<Object?> felder, Map<String, Object?> zustand) =>
      _schreibe([art, ...felder, "→", for (final e in zustand.entries) "${e.key}=${e.value}"]);

  /// Eine unerwartete Ausnahme mit den ersten Zeilen des Stacktrace.
  void ausnahme(Object fehler, StackTrace? stack) {
    final spur = (stack?.toString() ?? "").split("\n").where((z) => z.trim().isNotEmpty).take(12);
    _schreibe(["ausnahme", "$fehler", spur.join(" | ")]);
  }

  void _schreibe(List<Object?> felder) {
    final zeile = [++_nummer, ...felder.map(_feld)].join("\t");
    _zeilen.add(zeile);
    while (_zeilen.length > maxZeilen) {
      _zeilen.removeFirst();
    }
    _datei?.schreibe(zeile);
  }

  /// Zeilenende und Tabulator sichtbar machen, damit jede Zeile eine Zeile bleibt.
  static String _feld(Object? f) => "$f".replaceAll("\n", "\\n").replaceAll("\t", "\\t").replaceAll("\r", "");

  /// Zerlegt eine Zeile in Nummer, Art, Felder und Zustand; null für Leerzeilen und Kommentare (#).
  static ({int nummer, String art, List<String> felder, Map<String, String> zustand})? zerlege(String zeile) {
    if (zeile.trim().isEmpty || zeile.startsWith("#")) return null;
    final teile = zeile.split("\t");
    final pfeil = teile.indexOf("→");
    final felder = teile.sublist(2, pfeil < 0 ? teile.length : pfeil).map(_zurueck).toList();
    final zustand = <String, String>{
      if (pfeil >= 0)
        for (final t in teile.sublist(pfeil + 1)) t.substring(0, t.indexOf("=")): _zurueck(t.substring(t.indexOf("=") + 1)),
    };
    return (nummer: int.parse(teile[0]), art: teile[1], felder: felder, zustand: zustand);
  }

  static String _zurueck(String f) => f.replaceAll("\\n", "\n").replaceAll("\\t", "\t");
}
