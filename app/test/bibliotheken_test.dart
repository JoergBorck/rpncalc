import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc_app/modell.dart';

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
    m.pfeil(AxisDirection.right);
    expect(m.seitenName, "Eigene", reason: "nach den Seiten der Domäne die eigenen Funktionen");
    expect(m.funktionstasten.whereType<Object>(), isEmpty, reason: "Bibliotheksfunktionen stehen bei ihrer Domäne");
  });

  test('beim zweiten Wählen wird nicht noch einmal geladen', () {
    m.waehleDomaene("statistik");
    expect(m.api.eingabe("'~~sclr").fehler, isNull); // entfernt sclr aus der Bibliothek
    m.waehleDomaene("Grundfunktionen");
    m.waehleDomaene("statistik");
    expect(m.api.calculator.eigeneFunktionen.containsKey("sclr"), isFalse);
  });
}
