import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc_app/main.dart';
import 'package:rpncalc_app/modell.dart';
import 'package:rpncalc_app/tasten.dart';

/// Bibliotheken als Domänen der Funktionstasten (doc/app.md 3.4, doc/api.md 9.1).
void main() {
  late RechnerModell m;
  setUp(() => m = RechnerModell());
  tearDown(() => m.dispose());

  test('die Version der App steht auch in pubspec.yaml', () {
    expect(File("pubspec.yaml").readAsStringSync(), contains("version: ${RechnerModell.appVersion}"));
  });

  test('das Menü zeigt nach den eingebauten Domänen die Bibliotheken des Rechners', () {
    expect(m.domaenenNamen, ["Grundfunktionen", "Programm", "schwingungen", "statistik"]);
  });

  test('eine Bibliothek wird beim Wählen geladen, ihre Funktionen liegen auf den Funktionstasten', () {
    m.waehleDomaene("statistik");
    expect(m.zustand.speicher.map((s) => s.name), contains("mean"));
    expect([for (final t in m.funktionstasten) t?.text], ["sclr", "sadd", "sall", "sq", "mean", "sdev", "corr", "lr", "yhat", "xhat"]);
    expect(m.seitenName, "statistik");
    expect(identical(m.funktionstasten.first, m.funktionstasten.first), isTrue, reason: "für das Aufleuchten");
  });

  test('mehr als zehn Funktionen: mehrere Seiten, ◄ ► blättern; Eigene ohne Bibliotheksfunktionen', () {
    m.waehleDomaene("schwingungen");
    expect(m.seitenName, "schwingungen 1/3");
    m.bereich = Bereich.funktionen;
    m.pfeil(AxisDirection.right);
    expect(m.seitenName, "schwingungen 2/3");
    m.pfeil(AxisDirection.right);
    expect(m.seitenName, "schwingungen 3/3");
    m.pfeil(AxisDirection.right);
    expect(m.seitenName, "Grundfunktionen", reason: "ohne eigene Funktionen keine leere Seite Eigene; im Kreis vorn "
        "die Grundfunktionen, die immer dabei sind");
    m.zustand = m.api.eingabe("{1+}':inc");
    m.pfeil(AxisDirection.left);
    expect(m.seitenName, "Eigene", reason: "nach den Seiten der Domäne die eigenen Funktionen");
    expect([for (final t in m.funktionstasten.whereType<Taste>()) t.text], ["inc"],
        reason: "Bibliotheksfunktionen stehen bei ihrer Domäne");
  });

  test('beim zweiten Wählen wird nicht noch einmal geladen', () {
    m.waehleDomaene("statistik");
    expect(m.api.eingabe("'~~sclr").fehler, isNull); // entfernt sclr aus der Bibliothek
    m.waehleDomaene("Grundfunktionen");
    m.waehleDomaene("statistik");
    expect(m.api.calculator.eigeneFunktionen.containsKey("sclr"), isFalse);
  });

  test('seitenBibliothek: die Bibliothek der gezeigten Seite der Funktionstasten, sonst null', () {
    expect(m.seitenBibliothek, isNull, reason: "Grundfunktionen");
    m.waehleDomaene("schwingungen");
    expect(m.seitenBibliothek, "schwingungen");
    m.bereich = Bereich.funktionen;
    m.pfeil(AxisDirection.left);
    expect([m.seitenName, m.seitenBibliothek], ["Grundfunktionen", null]);
    m.waehleDomaene("Programm");
    expect(m.seitenBibliothek, isNull, reason: "eingebaute Domäne, keine Bibliothek");
  });

  testWidgets('Seite Funktionen: Abschnitte je Bibliothek, scrollt mit den Funktionstasten (doc/app.md 2)',
      (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text("TAB")); // Eingabe → Stack → Funktionen: die Anzeige zeigt die Seite Funktionen
      await tester.pumpAndSettle();
    }
    final oben = tester.getTopLeft(find.text("EIGENE FUNKTIONEN")).dy;
    await tester.tap(find.text("MENÜ"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("schwingungen"));
    await tester.pumpAndSettle();
    expect(find.text("BIBLIOTHEK SCHWINGUNGEN"), findsOneWidget);
    expect(find.text("Noch keine eigenen Funktionen. Anlegen z.B. mit {1+}':inc"), findsOneWidget,
        reason: "omega und Co. stehen nicht mehr unter Eigene");
    expect(tester.getTopLeft(find.text("BIBLIOTHEK SCHWINGUNGEN")).dy, closeTo(oben, 5),
        reason: "die Tasten zeigen schwingungen 1/3: die Liste scrollt zu ihrem Abschnitt");
    // Seite 2/3: ihre erste Funktion steht oben, damit die Funktionen der Tasten zu sehen sind
    final zweite = RpnApi().bibliotheksFunktionen("schwingungen")[10];
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text(zweite).first).dy, closeTo(oben, 5), reason: "$zweite oben");
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft); // die Tasten zurück zu den Grundfunktionen
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text("EIGENE FUNKTIONEN")).dy, closeTo(oben, 5), reason: "wieder nach oben");
  });
}
