import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// Eingaben über mehrere Zeilen: ein offener Code-Block bleibt über das Zeilenende hinweg erhalten.
void main() {
  test('Code-Block über zwei Zeilen', () {
    final api = RpnApi();
    expect(api.eingabe("{1").codeOffen, isTrue);
    Zustand z = api.eingabe("2}':pq");
    expect(z.codeOffen, isFalse);
    expect(z.fehler, isNull);
    expect(api.calculator.eigeneFunktionen["pq"], "1\n2");   // Inhalt über beide Zeilen
  });

  test('Enter am Zeilenende bleibt vorgemerkt, die nächste Zeile entscheidet', () {
    final api = RpnApi();
    api.eingabe("5 ");
    api.eingabe("+");                        // Operator: das Enter wirkt, 5 + 5
    expect(api.testString(), "Stack: ...[0.0] [0.0] [0.0] [10.0]<tos");
    api.reset();
    api.eingabe("5 ");
    api.eingabe("3");                        // Zahl ␣ Zahl: nur getrennt
    expect(api.testString(), "Stack: ...[0.0] [0.0] [5.0] [3.0]<tos");
  });

  test('loop bricht nach der eingestellten Höchstzahl an Durchläufen ab', () {
    final api = RpnApi();
    api.calculator.maxSchleife = 50;
    expect(api.eingabe("{1}loop").fehler?.code, "schleife");
  });

  test('reset verwirft einen offenen Code-Block', () {
    final api = RpnApi();
    api.eingabe("{1 2");
    api.reset();
    expect(api.zustand().codeOffen, isFalse);
    api.eingabe("3 4+");
    expect(api.testString(), "Stack: ...[0.0] [0.0] [0.0] [7.0]<tos");
  });
}
