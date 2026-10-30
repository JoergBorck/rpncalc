import 'dart:io';

import 'package:rpncalc/server/server.dart';

/// Socket-Server auf Port 4040: jeder Client bekommt einen eigenen Rechner (doc/api.md 6.1).
/// Strg+C beendet ihn geordnet: die Clients werden benachrichtigt, dann werden die Verbindungen geschlossen.
/// Ein anderer Port lässt sich als Argument angeben: dart run bin/server.dart 4042
Future<void> main(List<String> argumente) async {
  final strgC = ProcessSignal.sigint.watch().listen((_) async {
    print("\nStrg+C: Server wird beendet …");
    await stoppeMultiClientSocketInterface();
  });
  await starteMultiClientSocketInterface(port: argumente.isEmpty ? 4040 : int.parse(argumente.first));
  await strgC.cancel();
}
