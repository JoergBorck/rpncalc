/// Aufgabe: Konsolen-Client für den Socket-Server (doc/api.md 6.1): liest die Tastatur, schickt jede Taste an den
/// Server und zeigt den Zustand, den er zurückschickt. Bedienung wie bei der zeichenweisen Eingabe.
/// Ein anderer Port lässt sich als Argument angeben: dart run bin/client.dart 4042
/// Läuft noch kein Server, versucht es der Client weiter, bis einer antwortet.
///
/// Abgrenzung: Verbindung und Protokoll ([EntfernterRechner]) kommen aus net.dart, Bildschirm und Tasten
/// ([Bildschirm], [TastenStrom]) aus console.dart; gerechnet wird im Server.
///
/// Siehe auch: bin/server.dart, doc/api.md 6.1, doc/architecture.md 3.
library;

import 'dart:io';

import 'package:rpncalc/console.dart';
import 'package:rpncalc/net.dart';

Future<void> main(List<String> argumente) async {
  const host = "127.0.0.1";
  final port = argumente.isEmpty ? 4040 : int.parse(argumente.first);
  if (!stdin.hasTerminal) {
    print("Der Client braucht ein Terminal (z.B. das Terminal in VS Code).");
    return;
  }
  // wie im Menüprogramm: ein früher abgebrochener Rohmodus könnte noch aktiv sein
  stdin.lineMode = true;
  stdin.echoMode = true;
  virtuellesTerminalSetzen(false); // sonst kämen Pfeiltasten in readLineSync als ^[[A an
  stdout.write("\x1B[?25h");

  print("Verbinde mit dem RPN-Server $host:$port …");
  EntfernterRechner? rechner;
  // Kurze Versuche: ein Server auf demselben Rechner antwortet in Millisekunden, ohne Timeout würde Windows
  // einen Versuch ohne Server erst nach 2 Sekunden ablehnen. So geht es los, sobald der Server bereit ist.
  while (rechner == null) {
    try {
      rechner = await EntfernterRechner.verbinden(host, port, timeout: const Duration(milliseconds: 500));
    } on SocketException {
      stdout.write("\rWarte auf den Server … (Abbruch mit Strg+C) ");
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }
  print("\nVerbunden. Enter schließt ab, Backspace löscht, \\c kopiert den Tos, \\s den Stack, "
        "\\v fügt Zahlen ein, \\q beendet den Client.");

  final tasten = TastenStrom(stdin, abbruch: rechner.ende.future);
  await Bildschirm(rechner, tasten.naechstes).eingabe();
  print(rechner.ende.isCompleted ? await rechner.ende.future : "Client beendet");
  await rechner.schliessen();
  exit(0); // stdin ist noch abonniert und hielte das Programm sonst am Leben
}
