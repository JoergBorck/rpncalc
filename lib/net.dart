/// Aufgabe: die Tür zum Netz für bin/server.dart, bin/client.dart und bin/rpncalc.dart: der Socket-Server mit
/// einem eigenen Rechner je Client, der Client (EntfernterRechner) und das Protokoll dazwischen (JSON).
///
/// Abgrenzung: Die Bedienung des Clients ist die Konsole (console.dart); der Server rechnet über rpnapi.dart.
///
/// Siehe auch: doc/architecture.md 3, doc/api.md 6.1.
library;

export 'src/net/client.dart';
export 'src/net/protocol.dart';
export 'src/net/server.dart';
