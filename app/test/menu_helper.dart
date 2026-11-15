/// Aufgabe: Helfer für Tests, die Bibliotheken einschalten: über das Menü auf dem Tastenfeld wie ein Mensch
/// (Widget-Tests) oder direkt über das Modell (doc/app.md 3.6).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc_app/keypad/menu_keys.dart';
import 'package:rpncalc_app/model/model.dart';

/// MENÜ, 4, die Bibliothek [name] einschalten, ENTER.
Future<void> bibliothekEinschalten(WidgetTester tester, String name) async {
  await tester.tap(find.text("MENÜ"));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(MenueBereichTaste));
  await tester.pumpAndSettle();
  await tester.tap(find.byWidgetPredicate((w) => w is MenueSchalter && w.taste.text == name));
  await tester.pumpAndSettle();
  await tester.tap(find.text("OK"));
  await tester.pumpAndSettle();
}

/// Schaltet den Eintrag [eintrag] zusätzlich ein, wie MENÜ 4 [eintrag] ENTER.
List<String> einschalten(RechnerModell m, String eintrag) => m.uebernimmAuswahl({...m.eingeschalteteEintraege, eintrag});
