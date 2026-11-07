/// Aufgabe: die Tür zur Konsole für bin/rpncalc.dart und bin/client.dart: Menü, zeilen- und zeichenweise
/// Eingabe (UI, Bildschirm), Darstellung, Konsolenhilfe, Bibliotheken laden, Terminal-Einstellungen und die
/// Selbsttests, die das Menü startet.
///
/// Abgrenzung: Der Rechner selbst kommt über rpnapi.dart, Server und Client über net.dart.
///
/// Siehe auch: doc/architecture.md 3, doc/api.md Kapitel 7.
library;

export 'src/console/display.dart';
export 'src/console/help.dart';
export 'src/console/library.dart';
export 'src/console/menu.dart';
export 'src/console/screen.dart';
export 'src/console/terminal.dart';
export 'src/console/ui.dart';
export 'src/selftest/test_calculator.dart';
export 'src/selftest/test_dea.dart';
export 'src/selftest/test_parser.dart';
