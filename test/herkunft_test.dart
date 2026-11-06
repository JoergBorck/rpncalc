import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// Herkunft einer Funktion (doc/api.md 9.1).
void main() {
  test('herkunft nennt die Bibliothek einer geladenen Funktion, bei eigenen null', () {
    final api = RpnApi();
    expect(api.ladeBibliothek("schwingungen"), isNull);
    api.eingabe("{1+}':inc");
    expect(api.herkunft("omega"), "schwingungen");
    expect(api.herkunft("inc"), isNull);
    expect(api.herkunft("gibtsnicht"), isNull);
  });
}
