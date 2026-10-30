import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// n:{code}times und das Lesen von Argumenten mit ~|:, siehe doc/reference.md 10.3 und 11.
void main() {
  List<num> werte(Zustand z) => [for (final s in z.stack.reversed) s.wert];

  group('times', () {
    test('führt den Block n-mal aus', () {
      expect(werte(RpnApi().eingabe("3:{7}times")), [7, 7, 7]);
    });

    test('der Index ist das einzige Argument', () {
      expect(werte(RpnApi().eingabe("4:{~|:}times")), [0, 1, 2, 3]);
      expect(werte(RpnApi().eingabe("3:{|:}times")), [1, 1, 1]);
    });

    test('ein ungelesener Index wirkt nicht nach außen', () {
      final z = RpnApi().eingabe("2:{1}times");
      expect(z.argumente, isEmpty);
      expect(werte(z), [1, 1]);
    });

    test('0 und negative Anzahl: kein Durchlauf, der Block ist verbraucht', () {
      for (final e in ["0:{1}times", "~2:{1}times"]) {
        final z = RpnApi().eingabe(e);
        expect(z.fehler, isNull, reason: e);
        expect(z.stack, isEmpty, reason: e);
        expect(z.codeStack, isEmpty, reason: e);
      }
    });

    test('Anzahl fehlt oder ist keine ganze Zahl', () {
      for (final e in ["{1}times", "2.5:{1}times"]) {
        final z = RpnApi().eingabe(e);
        expect(z.fehler?.code, "anzahl", reason: e);
        expect(z.codeStack, ["1"], reason: e);
      }
    });

    test('ohne Block ist es ein Fehler', () {
      expect(RpnApi().eingabe("3:times").fehler?.code, "code0");
    });

    test('mehr Durchläufe als erlaubt beginnen gar nicht erst', () {
      final api = RpnApi();
      api.calculator.maxSchleife = 50;
      final z = api.eingabe("51:{1}times");
      expect(z.fehler?.code, "schleife");
      expect(z.stack, isEmpty);
    });

    test('ein Fehler im Block bricht ab', () {
      final z = RpnApi().eingabe("3:{~|: 1~=1 0|/D}times");
      expect(z.fehler?.code, "inCode");
    });

    test('verschachtelt hat jede Ebene ihren eigenen Index', () {
      // äußerer Index * 10 + innerer Index
      final z = RpnApi().eingabe("2:{~|:'!a_2:{'a_10*~|:+}times}times");
      expect(werte(z), [0, 1, 10, 11]);
    });
  });

  group('~|: lässt die Argumente in der Liste', () {
    test('zweimal lesen', () {
      expect(werte(RpnApi().eingabe("{~|:~|:}':f_1:2:f")), [1, 2, 1, 2]);
    });

    test('|: zählt danach weiter', () {
      expect(werte(RpnApi().eingabe("{~|:|:}':g_4:5:g")), [4, 5, 2]);
    });

    test('~: verbraucht weiterhin', () {
      expect(werte(RpnApi().eingabe("{~:~|:}':h_1:2:3:h")), [1, 2, 3]);
      expect(werte(RpnApi().eingabe("{~:|:}':m_1:2:m")), [1, 1]);
    });
  });
}
