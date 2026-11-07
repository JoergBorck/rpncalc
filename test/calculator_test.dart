import 'package:rpncalc/src/selftest/test_calculator.dart';
import 'package:test/test.dart';

/// Führt die Testfälle aus lib/src/selftest/test_calculator.dart mit package:test aus (dart test).
void main() {
  group('Rechner', () {
    for (final p in UnittestCalculator().pruefe()) {
      test('${p.id}: ${p.eingabe.replaceAll('\n', r'\n')}', () {
        expect(p.ergebnis, equals(p.erwartet));
      });
    }
  });
}
