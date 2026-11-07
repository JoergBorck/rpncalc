import 'dart:math' as math;

import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// sinh, cosh, tanh und ihre Umkehrungen (doc/reference.md 6.2).
void main() {
  Zustand rechne(String eingabe) => RpnApi().eingabe(eingabe);
  num tos(String eingabe) => rechne(eingabe).stack.first.wert;

  test('Werte', () {
    expect(tos("1 sinh_"), closeTo(1.1752011936438014, 1e-15));
    expect(tos("1 cosh_"), closeTo(1.5430806348152437, 1e-15));
    expect(tos("0.5 tanh_"), closeTo(0.46211715726000974, 1e-15));
    expect(tos("~2 sinh_"), closeTo(-3.626860407847019, 1e-14));
    expect(tos("0 cosh_"), 1);
    expect(tos("50 tanh_"), 1, reason: "kein Überlauf bei großen x");
  });

  test('kleine x ohne Auslöschung', () {
    for (final f in ["sinh", "tanh", "~sinh", "~tanh"]) {
      expect(tos("1ê~10 ${f}_") / 1e-10, closeTo(1, 1e-12), reason: f);
    }
  });

  test('Umkehrungen, auch als asinh, acosh, atanh', () {
    for (final (f, x) in [("sinh", 2.5), ("cosh", 2.5), ("tanh", 0.7), ("sinh", -1.5), ("tanh", -0.3)]) {
      final z = x < 0 ? "~${-x}" : "$x"; // das Vorzeichen ist ~, - subtrahiert
      expect(tos("$z ${f}_~${f}_"), closeTo(x, 1e-12), reason: "~$f nach $f");
      expect(tos("$z ${f}_a${f}_"), closeTo(x, 1e-12), reason: "a$f nach $f");
    }
    expect(tos("1 ~cosh_"), 0);
    expect(tos("2 ~cosh_"), closeTo(math.log(2 + math.sqrt(3)), 1e-15), reason: "der Wert ≥ 0");
  });

  test('unabhängig vom Winkelmodus', () {
    expect(tos("rad 1 sinh_"), tos("deg 1 sinh_"));
    expect(tos("grd 0.5 ~tanh_"), tos("deg 0.5 ~tanh_"));
  });

  test('außerhalb des Definitionsbereichs NaN bzw. unendlich wie bei ~sin (doc/reference.md 2)', () {
    expect(tos("0.5 ~cosh_").isNaN, isTrue);
    expect(tos("~1.5 ~tanh_").isNaN, isTrue);
    expect(tos("1 ~tanh_"), double.infinity);
    expect(tos("1000 cosh_"), double.infinity);
    expect(rechne("0.5 ~cosh_").fehler, isNull, reason: "kein Fehler, wie 2 ~sin");
  });
}
