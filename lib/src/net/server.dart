/// Aufgabe: der Socket-Server auf localhost. Jede Verbindung bekommt einen eigenen Rechner (RpnApi) und gleich
/// ihren ersten Zustand; jede Zeile des Clients beantwortet `beantworte` aus protocol.dart.
/// [starteMultiClientSocketInterface] startet und wartet bis zum Ende, [stoppeMultiClientSocketInterface]
/// schickt allen Clients {"ende":…} und schließt die Verbindungen.
///
/// Abgrenzung: Was eine Nachricht bedeutet, steht in protocol.dart; die Gegenseite ist net/client.dart.
/// Gestartet wird über bin/server.dart oder aus dem Menü von bin/rpncalc.dart.
///
/// Siehe auch: doc/api.md 6.1, net/protocol.dart, bin/server.dart.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../rpnapi.dart';
import 'protocol.dart';

ServerSocket? laufenderServerSocket;

/// Die verbundenen Clients, jeder mit seinem eigenen Rechner.
final Map<Socket, RpnApi> activeSessions = {};

/// Wird erfüllt, wenn der Server beendet ist.
Completer<void>? _beendet;

/// Startet den Server und wartet, bis er beendet wird (Strg+C in bin/server.dart oder {"stopp":true}).
Future<void> starteMultiClientSocketInterface({int port = 4040, bool leise = false}) async {
  if (laufenderServerSocket != null) {
    print('[Info] Der Server läuft bereits.');
    return;
  }
  void log(String text) {
    if (!leise) print(text);
  }

  laufenderServerSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
  _beendet = Completer<void>();
  log('--- Multi-Client RPN Server läuft auf Port $port ---');
  log('Beenden mit Strg+C oder mit {"stopp":true} von einem Client.\n');

  laufenderServerSocket!.listen((Socket clientSocket) {
    final clientId = "${clientSocket.remoteAddress.address}:${clientSocket.remotePort}";
    log('[Server] Neuer Client verbunden: $clientId');
    final api = RpnApi();
    activeSessions[clientSocket] = api;
    clientSocket.write("${Nachricht.zustand(api.zustand())}\n"); // damit der Client gleich etwas anzeigen kann

    clientSocket.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter()).listen(
      (String zeile) async {
        log('[Empfangen von $clientId]: $zeile');
        final antwort = beantworte(api, zeile);
        if (antwort.stopp) {
          await stoppeMultiClientSocketInterface(grund: "Server wird beendet (stopp von $clientId)");
          return;
        }
        clientSocket.write("${antwort.zeile}\n");
      },
      onError: (err) => log('[Server Fehler] Fehler bei Verbindung $clientId: $err'),
      onDone: () {
        log('[Server] Client $clientId hat die Verbindung getrennt.');
        activeSessions.remove(clientSocket);
      },
    );
  });

  await _beendet!.future;
  log('Server beendet');
}

/// Beendet den Server geordnet: jeder Client bekommt {"ende":…}, dann werden alle Verbindungen geschlossen.
Future<void> stoppeMultiClientSocketInterface({String grund = "Server wird beendet"}) async {
  final server = laufenderServerSocket;
  if (server == null) return;
  laufenderServerSocket = null; // ein zweites stopp während des Beendens tut nichts mehr
  for (final socket in List.of(activeSessions.keys)) {
    try {
      socket.write("${Nachricht.ende(grund)}\n");
      await socket.flush();
      await socket.close();
    } catch (e) {
      // Socket ist schon geschlossen, nichts mehr zu tun
    }
  }
  activeSessions.clear();
  await server.close();
  _beendet?.complete();
}
