import 'dart:io';

import 'package:rpncalc/console/library.dart';
import 'package:rpncalc/console/menu.dart';
import 'package:rpncalc/console/terminal.dart';
import 'package:rpncalc/console/ui.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc/selftest/test_calculator.dart';
import 'package:rpncalc/selftest/test_dea.dart';
import 'package:rpncalc/selftest/test_parser.dart';
import 'package:rpncalc/server/server.dart';

void main(List<String> arguments) async {
  RpnApi api = RpnApi();
  UI ui = UI(api);

  Menu menu = Menu(testmenu);

  // Falls ein früherer Lauf im Rohmodus abgebrochen wurde (z.B. mit Strg+C), ist das Terminal noch
  // ohne Echo, ohne Zeilenmodus und ohne Cursor. Deshalb beim Start immer zurücksetzen.
  if (stdin.hasTerminal) {
    stdin.lineMode = true;
    stdin.echoMode = true;
    virtuellesTerminalSetzen(false); // sonst kämen Pfeiltasten in readLineSync als ^[[A an
    stdout.write("\x1B[?25h"); // auch der Cursor könnte noch ausgeblendet sein
  }

  // Leert das Terminal-Fenster (funktioniert auf Windows, Mac und Linux)
  stdout.write('\x1B[2J\x1B[3J\x1B[H'); 
  
  // Menü „Bibliotheken“ vor „Beenden“; der Inhalt wird vor jeder Auswahl neu gesucht,
  // damit eben gespeicherte Funktionen (.rpnlib) gleich erscheinen
  MenuItem bibliothekenMenue = MenuItem("Bibliotheken", []);
  testmenu.subMenu!.insert(testmenu.subMenu!.length - 1, bibliothekenMenue);
  Map<MenuItem, Bibliothek> bibliotheken = {};

  while (true) {
    // zuerst die mitgelieferten aus dem Rechner, dann die selbst gespeicherten von der Festplatte
    bibliotheken = {
      for (final b in api.bibliotheken())
        if (b.mitgeliefert) MenuItem(b.name): Bibliothek(b.name),
      for (final b in findeBibliotheken()) MenuItem(b.titel): b,
    };
    bibliothekenMenue.subMenu!
      ..clear()
      ..addAll(bibliotheken.isEmpty ? [MenuItem("Keine Bibliotheken (.rpnlib) gefunden")] : bibliotheken.keys);
    MenuItem? item = menu.call();  
    if (item == null) return;
    Bibliothek? bibliothek = bibliotheken[item];
    if (bibliothek != null) {
      ui.ladeBibliothek(bibliothek);
      continue;
    }
    switch (item.title) {
      case "Beenden": 
        await stoppeMultiClientSocketInterface(); 
        return;
      case "Test Dea":
        UnittestDea().test();
      case "Test Parser":
        UnittestParser().test();
      case "Test Rechner":
        UnittestCalculator().test();
      case "Zeilenweise Eingabe":
        await ui.zeilenweiseEingabe();
      case "Zeilenweise Eingabe mit Übersicht":
        await ui.zeilenweiseEingabe(uebersicht: true);
      case "Zeichenweise Eingabe":
        await ui.zeichenweiseEingabe();
      case "Zeichenweise Eingabe mit Übersicht":
        await ui.zeichenweiseEingabe(uebersicht: true);
      case "Session speichern":
        ui.speichern();
      case "Session laden":
        ui.laden();
      case "Funktionen speichern":
        ui.speichern(nurFunktionen: true);
      case "Socket Multi-Client":
        // Der Server ist ein eigenes Programm (bin/server.dart), der Menüpunkt nur eine Abkürzung.
        print("Der Socket-Server ist ein eigenes Programm und läuft am besten in einem eigenen Terminal:\n"
              "  dart run bin/server.dart\n"
              "oder in VS Code über die Startkonfiguration \"RPN Server\" bzw. \"Server & Client gleichzeitig\".\n"
              "Hier im Menü gestartet, ist das Menü blockiert, bis ein Client \"exit\" schickt.");
        stdout.write("Server jetzt hier starten? (j/N) ");
        if ((stdin.readLineSync() ?? "").trim().toLowerCase() == "j") {
          await starteMultiClientSocketInterface();
        }
    }
  }
}

