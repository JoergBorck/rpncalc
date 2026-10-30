import 'package:rpncalc/selftest/test_parser.dart';
import 'package:test/test.dart';

/// Führt die Testfälle aus lib/selftest/test_parser.dart mit package:test aus (dart test).
void main() {
  group('Parser', () {
    for (final p in UnittestParser().pruefe()) {
      test('${p.id}: ${p.eingabe.replaceAll('\n', r'\n')}', () {
        expect(p.ergebnis, equals(p.erwartet));
      });
    }
  });
}
