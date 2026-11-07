/// Aufgabe: der Client zum Socket-Server. [EntfernterRechner] erfüllt die Schnittstelle `Rechner` der Konsole und
/// schickt jeden Aufruf als Nachricht an den Server; jede Anfrage wartet auf die Antwort, die Anzeige bleibt also
/// synchron. Dazu Verbinden, Stopp des Servers, Protokollfehler und das Ende der Verbindung.
///
/// Abgrenzung: Die Nachrichten selbst baut protocol.dart, die Bedienung ist der `Bildschirm` aus
/// console/screen.dart. Das Programm dazu ist bin/client.dart.
///
/// Siehe auch: doc/api.md 6.1, net/protocol.dart, net/server.dart, bin/client.dart.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../rpnapi.dart';
import '../console/screen.dart';
import 'protocol.dart';

/// Der Rechner auf dem Server, angesprochen über den Socket (doc/api.md 6.1).
/// Jede Anfrage wartet auf die Antwort des Servers, die Anzeige ist also synchron.
class EntfernterRechner implements Rechner {
  final Socket _socket;
  final Completer<Zustand> _erster = Completer();
  Completer<Zustand>? _offen;
  Completer<Hilfe?>? _hilfeOffen;
  Zustand? _letzter;

  /// Wird erfüllt, sobald die Verbindung endet, mit dem Grund (z.B. {"ende":…} vom Server).
  final Completer<String> ende = Completer();

  /// Der letzte Protokollfehler, den der Server gemeldet hat, sonst null.
  String? protokollfehler;

  EntfernterRechner._(this._socket) {
    _socket.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter()).listen(
          _empfangen,
          onDone: () => _beenden("Die Verbindung zum Server ist getrennt"),
          onError: (e) => _beenden("Verbindungsfehler: $e"),
        );
  }

  /// Verbindet sich mit dem Server und wartet auf den ersten Zustand.
  /// Ohne [timeout] lehnt Windows eine Verbindung zu einem Port ohne Server erst nach etwa 2 Sekunden ab.
  static Future<EntfernterRechner> verbinden(String host, int port, {Duration? timeout}) async {
    final r = EntfernterRechner._(await Socket.connect(host, port, timeout: timeout));
    await r._erster.future;
    return r;
  }

  void _empfangen(String zeile) {
    Object? j;
    try {
      j = jsonDecode(zeile);
    } on FormatException {
      return;
    }
    if (j is! Map<String, Object?>) return;
    final zustand = j["zustand"], fehler = j["protokollfehler"], grund = j["ende"];
    if (j.containsKey("hilfe")) {
      final h = j["hilfe"];
      final o = _hilfeOffen;
      _hilfeOffen = null;
      o?.complete(h is Map<String, Object?> ? Hilfe.fromJson(h) : null);
    } else if (zustand is Map<String, Object?>) {
      final z = Zustand.fromJson(zustand);
      _letzter = z;
      _antwort(z);
    } else if (fehler is String) {
      protokollfehler = fehler;
      _antwort(_letzter!);
    } else if (grund is String) {
      _beenden(grund);
    }
    // andere Schlüssel kennt dieser Client noch nicht und überspringt sie
  }

  void _antwort(Zustand z) {
    if (!_erster.isCompleted) {
      _erster.complete(z);
      return;
    }
    final o = _offen;
    _offen = null;
    o?.complete(z);
  }

  void _beenden(String grund) {
    if (ende.isCompleted) return;
    ende.complete(grund);
    if (!_erster.isCompleted) _erster.completeError(SocketException(grund));
    final o = _offen;
    _offen = null;
    if (_letzter != null) o?.complete(_letzter!);
    final h = _hilfeOffen;
    _hilfeOffen = null;
    h?.complete(null);
  }

  Future<Zustand> _senden(String nachricht) {
    if (ende.isCompleted) return Future.value(_letzter!);
    _offen = Completer();
    _socket.write("$nachricht\n");
    return _offen!.future;
  }

  @override
  Future<Zustand> taste(String zeichen) => _senden(Nachricht.taste(zeichen));
  @override
  Future<Zustand> zeilenende() => _senden(Nachricht.zeilenende());
  @override
  Future<Zustand> loeschen() => _senden(Nachricht.loeschen());
  @override
  Future<Zustand> zustand({int zeilen = 8}) => _senden(Nachricht.zustandAbfragen(zeilen: zeilen));
  /// Schickt eine ganze Zeile, für Clients, die zeilenweise arbeiten (der Konsolen-Client schickt Zeichen).
  Future<Zustand> eingabe(String zeile) => _senden(Nachricht.eingabe(zeile));
  @override
  Future<Hilfe?> hilfe(String kennung) {
    if (ende.isCompleted) return Future.value(null);
    _hilfeOffen = Completer();
    _socket.write("${Nachricht.hilfeAbfragen(kennung)}\n");
    return _hilfeOffen!.future;
  }

  /// Bittet den Server, sich zu beenden. Er antwortet allen Clients mit {"ende":…}.
  void stopp() => _socket.write("${Nachricht.stopp()}\n");

  Future<void> schliessen() async {
    await _socket.close();
    _socket.destroy();
  }
}
