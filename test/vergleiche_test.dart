import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// ≤ ≥ ≠ sind gleichwertig zu ~> ~< ~= (doc/reference.md 4).
void main() {
  num tos(String eingabe) => RpnApi().eingabe(eingabe).stack.first.wert;

  test('≤ ≥ ≠ rechnen wie ~> ~< ~=', () {
    for (final (y, x) in [(3, 5), (5, 3), (4, 4)]) {
      for (final (zeichen, tilde) in [("≤", "~>"), ("≥", "~<"), ("≠", "~=")]) {
        expect(tos("$y $x$zeichen"), tos("$y $x$tilde"), reason: "$y $x$zeichen");
      }
    }
    expect(tos("3 5≤"), 1);
    expect(tos("3 5≥"), 0);
    expect(tos("4 4≠"), 0);
  });

  test("a a b>* ergibt a, wenn a > b ist, sonst 0 (a zweimal: einmal zum Vergleichen, einmal zum Multiplizieren)", () {
    expect(tos("7_7_3>*"), 7);
    expect(tos("2_2_3>*"), 0);
  });
}
