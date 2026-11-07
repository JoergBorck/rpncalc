import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc_app/colors.dart';
import 'package:rpncalc_app/main.dart';
import 'package:rpncalc_app/model/model.dart';
import 'package:rpncalc_app/keys.dart';

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
    expect(m.api.zustand().speicher.any((s) => s.art == SpeicherArt.funktion && s.name == "sclr"), isFalse);
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
    final zweite = RpnApi().bibliotheksFunktionen("schwingungen", ohneIntern: true)[10]; // wie auf den Tasten
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text(zweite).first).dy, closeTo(oben, 5), reason: "$zweite oben");
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft); // die Tasten zurück zu den Grundfunktionen
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text("EIGENE FUNKTIONEN")).dy, closeTo(oben, 5), reason: "wieder nach oben");
  });

  test('interne Funktionen (rpnintern) bekommen keine Funktionstaste, auch nicht auf „Eigene“ (FL-2)', () {
    m.waehleDomaene("schwingungen");
    final tasten = <String>{};
    for (var i = 0; i < m.funktionsSeiten; i++) {
      m.funktionsSeite = i;
      tasten.addAll([for (final t in m.funktionstasten.whereType<Taste>()) t.text]);
    }
    expect(tasten, containsAll(["omega", "dx"]));
    expect(tasten.intersection({"rw", "wr", "osz", "fpol"}), isEmpty);
    m.zustand = m.api.eingabe("{1+}':inc rpnintern_{2+}':plus");
    m.funktionsSeite = m.funktionsSeiten - 1;
    expect([m.seitenName, for (final t in m.funktionstasten.whereType<Taste>()) t.text], ["Eigene", "plus"]);
  });

  testWidgets('Seite Funktionen: interne Funktionen kursiv und ausgegraut (FL-2, VA-11)', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    await tester.tap(find.text("MENÜ"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("schwingungen"));
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text("TAB"));
      await tester.pumpAndSettle();
    }
    TextStyle? stil(String name) => tester.widget<Text>(find.text(name).last).style;
    expect([stil("rw")?.fontStyle, stil("rw")?.color], [FontStyle.italic, Farben.anzeigeBlass], reason: "VA-11");
    expect([stil("omega")?.fontStyle, stil("omega")?.color], isNot(contains(Farben.anzeigeBlass)));
  });

  test('Bereich Funktionen: ▲ ▼ blättern begrenzt und senkrecht wie das Mausrad, ◄ ► im Kreis (VA-14)', () {
    m.waehleDomaene("schwingungen");
    m.waehleBereich(Bereich.funktionen);
    m.funktionsSeite = 0;
    m.pfeil(AxisDirection.up);
    expect([m.seitenName, m.funktionenSenkrecht], ["Grundfunktionen", true], reason: "▲ hält an der ersten Seite");
    m.pfeil(AxisDirection.down);
    expect(m.seitenName, "schwingungen 1/3");
    for (var i = 0; i < 5; i++) {
      m.pfeil(AxisDirection.down);
    }
    expect(m.seitenName, "schwingungen 3/3", reason: "▼ hält an der letzten Seite");
    m.pfeil(AxisDirection.right);
    expect([m.seitenName, m.funktionenSenkrecht], ["Grundfunktionen", false], reason: "► im Kreis, waagrecht");
  });

  testWidgets('schnell zweimal ▼: beide Tastendrücke zählen, auch während die Tasten noch gleiten (VA-14)', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    await tester.tap(find.text("MENÜ"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("schwingungen"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("TAB"));
    await tester.tap(find.text("TAB"));
    await tester.pumpAndSettle();
    expect(find.text("schwingungen 1/3"), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump(const Duration(milliseconds: 30));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text("schwingungen 3/3"), findsOneWidget, reason: "zwei Drücke, zwei Seiten");
    await tester.pump(const Duration(seconds: 2));
  });
}
