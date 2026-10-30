import 'package:rpncalc/selftest/test_dea.dart';
import 'package:test/test.dart';

/// Führt die Testfälle aus lib/selftest/test_dea.dart mit package:test aus (dart test).
void main() {
  group('DEA', () {
    for (final p in UnittestDea().pruefe()) {
      test('${p.id}: ${p.eingabe.replaceAll('\n', r'\n')}', () {
        expect(p.ergebnis, equals(p.erwartet));
      });
    }
  });
}
