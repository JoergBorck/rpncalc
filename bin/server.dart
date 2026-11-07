/// Aufgabe: Socket-Server auf Port 4040: jeder Client bekommt einen eigenen Rechner (doc/api.md 6.1).
/// Strg+C beendet ihn geordnet: die Clients werden benachrichtigt, dann werden die Verbindungen geschlossen.
/// Ein anderer Port lässt sich als Argument angeben: dart run bin/server.dart 4042
///
/// Abgrenzung: Server und Protokoll selbst stehen in lib/src/net (über net.dart); diese Datei startet und
/// stoppt ihn nur. Das Menü von bin/rpncalc.dart kann denselben Server ebenfalls starten.
///
/// Siehe auch: bin/client.dart, doc/api.md 6.1, doc/architecture.md 3.
library;

import 'dart:io';

import 'package:rpncalc/net.dart';

Future<void> main(List<String> argumente) async {
  final strgC = ProcessSignal.sigint.watch().listen((_) async {
    print("\nStrg+C: Server wird beendet …");
    await stoppeMultiClientSocketInterface();
  });
  await starteMultiClientSocketInterface(port: argumente.isEmpty ? 4040 : int.parse(argumente.first));
  await strgC.cancel();
}
