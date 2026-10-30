import 'dart:convert';

import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// Zustand als JSON, siehe doc/api.md Kapitel 6.
void main() {
  /// Hin und zurück über den Text, wie über einen Socket.
  Zustand ueberJson(Zustand z) => Zustand.fromJson(jsonDecode(jsonEncode(z)) as Map<String, Object?>);

  test('Beispiel aus der Spezifikation', () {
    final api = RpnApi();
    for (final c in "3 4+".split("")) {
      api.taste(c);
    }
    expect(jsonEncode(api.zustand()),
        '{"stack":[{"position":0,"wert":7,"tags":[]}],"tiefe":1,"speicher":[],"argumente":[],'
        '"winkel":"deg","seed":null,"fehler":null,"codeOffen":false,"codeStack":[],'
        '"offen":"","enterVorgemerkt":false,"zeile":"3 4+","zeileFertig":false}');
  });

  test('ein voller Zustand bleibt auf dem Weg über JSON erhalten', () {
    final api = RpnApi();
    for (final zeile in [
      "grd 5seed",
      "{1+\n2*}':f",            // Code mit Zeilenumbruch
      "9.81'!!g 1 2 3 3:'!v",   // Konstante und Vektor
      "7'||t_~1~²_10_400^",    // Tag mit Schreibschutz, NaN und unendlich
      "{3}{4}2:",               // Code-Stack und offenes Argument
    ]) {
      expect(api.eingabe(zeile).fehler, isNull, reason: zeile);
    }
    for (final c in "q 2".split("")) {
      api.taste(c); // Fehler, offene Zeile
    }
    final z = api.zustand();
    expect(z.fehler, isNotNull);
    final text = jsonEncode(z);
    expect(text, isNot(contains("\n")), reason: "eine Zeile pro Zustand");
    expect(text, contains('"NaN"'));
    expect(text, contains('"Infinity"'));

    final zurueck = ueberJson(z);
    expect(jsonEncode(zurueck), text);
    expect(zurueck.winkel, AngleMode.grad);
    expect(zurueck.stack[0].wert, double.infinity);
    expect(zurueck.stack[1].wert.isNaN, isTrue);
    expect(zurueck.speicher.firstWhere((s) => s.name == "f").code, "1+\n2*");
    expect(zurueck.speicher.firstWhere((s) => s.name == "t").schreibschutz, isTrue);
    expect(zurueck.fehler!.token, z.fehler!.token);
  });

  test('der zurückgelesene Zustand ist unveränderlich wie das Original', () {
    final z = ueberJson(RpnApi().eingabe("1 2 3"));
    expect(() => z.stack.add(z.stack.first), throwsUnsupportedError);
    expect(() => z.argumente.add(1), throwsUnsupportedError);
  });
}
