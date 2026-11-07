
import 'package:rpncalc/src/engine/value.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

import 'internals.dart';

/// Statistik wie mit Σ+ beim HP-41, nur mit eigenen Funktionen in der Sprache des Rechners
/// (library/statistik.rpnlib, siehe doc/demo.md). ss = [n, Σx, Σx², Σy, Σy², Σxy]

void main() {
  late RpnApi api;
  Wert tos() => api.calculator.stack[0];
  Wert unter() => api.calculator.stack[1];

  setUp(() {
    api = apiMitEinblick();
    expect(api.ladeBibliothek("statistik"), isNull); // mitgeliefert (doc/api.md 9.1)
    for (final zeile in ["sclr", "2 1sadd", "4 2sadd", "5 3sadd", "4 4sadd", "5 5sadd", "C"]) {
      expect(api.eingabe(zeile).fehler, isNull, reason: zeile);
    }
  });

  test('Summen', () => expect(api.calculator.variablen["ss"], [5, 15, 55, 20, 86, 66]));
  test('Mittelwert', () { api.eingabe("mean"); expect(tos(), 3); expect(unter(), 4); });
  test('Standardabweichung', () {
    api.eingabe("sdev");
    expect(tos(), closeTo(1.5811388, 1e-6));
    expect(unter(), closeTo(1.2247449, 1e-6));
  });
  test('Korrelation', () { api.eingabe("corr"); expect(tos(), closeTo(0.7745967, 1e-6)); });
  test('Lineare Regression', () {
    api.eingabe("lr");
    expect(tos(), closeTo(2.2, 1e-9));   // a
    expect(unter(), closeTo(0.6, 1e-9)); // b
  });
  test('Schätzwerte', () {
    api.eingabe("6yhat");
    expect(tos(), closeTo(5.8, 1e-9));
    api.eingabe("C5xhat");
    expect(tos(), closeTo(4.6666667, 1e-6));
  });

  test('Messdaten aus Excel einfügen (\\v) und mit times aufnehmen', () {
    // Spalten y und x, wie sie Excel in die Zwischenablage legt: Tab zwischen den Spalten, Dezimalkomma
    const excel = "y\tx\r\n2\t1\r\n4\t2\r\n5,0\t3\r\n4\t4\r\n5\t5,0\r\n";
    api.eingabe("sclr");
    expect(api.eingabe(ausExcel(excel).join("_")).fehler, isNull);
    expect(api.eingabe("5:sall").fehler, isNull);
    expect(api.calculator.variablen["ss"], [5, 15, 55, 20, 86, 66]);
    expect(api.calculator.stack.tiefe, 1); // nur n
    expect(tos(), 5);
  });

  test('sall ist dasselbe wie sadd in einer Schleife (sadd legt n ab, D entfernt es)', () {
    api.eingabe("sclr");
    expect(api.eingabe("2_1_4_2_5_3_4_4_5_5_5:{sadd_D}times").fehler, isNull);
    expect(api.calculator.variablen["ss"], [5, 15, 55, 20, 86, 66]);
  });
}
