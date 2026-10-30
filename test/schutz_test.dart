import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// Konstanten ('!!x) und Tags mit Schreibschutz ('||x), siehe doc/reference.md 8.1 und 9.4.
void main() {
  /// Führt die Zeilen aus und liefert den Zustand nach der letzten.
  Zustand nach(RpnApi api, List<String> zeilen) {
    late Zustand z;
    for (final l in zeilen) {
      z = api.eingabe(l);
    }
    return z;
  }

  List<num> werte(Zustand z) => [for (final s in z.stack.reversed) s.wert];

  group('Konstanten', () {
    test('anlegen und lesen', () {
      final api = RpnApi();
      final z = nach(api, ["9.81'!!g", "'g"]);
      expect(z.fehler, isNull);
      expect(werte(z), [9.81]);
      expect(z.speicher.single.schreibschutz, isTrue);
    });

    test('Vektor als Konstante', () {
      final z = nach(RpnApi(), ["1 2 3 3:'!!v", "0:3:'v"]);
      expect(werte(z), [1, 2, 3]);
    });

    for (final op in ["=", "+", "-", "*", "/"]) {
      test("'${op}x ist ein Fehler", () {
        final z = nach(RpnApi(), ["5'!!g", "2'${op}g"]);
        expect(z.fehler?.code, "konst");
        expect(nach(RpnApi(), ["5'!!g", "2'${op}g", "'g"]).stack.first.wert, 5);
      });
    }

    test("'~x entfernt die Konstante", () {
      final z = nach(RpnApi(), ["5'!!g", "'~g"]);
      expect(z.fehler, isNull);
      expect(z.speicher, isEmpty);
    });

    test("'!x ersetzt die Konstante durch eine Variable", () {
      final z = nach(RpnApi(), ["5'!!g", "7'!g", "1'+g", "'g"]);
      expect(z.fehler, isNull);
      expect(z.stack.first.wert, 8);
      expect(z.speicher.single.schreibschutz, isFalse);
    });

    test("'!!x ersetzt eine Variable", () {
      final z = nach(RpnApi(), ["5'!g", "7'!!g", "1'=g"]);
      expect(z.fehler?.code, "konst");
    });

    test("'|x ersetzt die Konstante durch einen Tag", () {
      final z = nach(RpnApi(), ["5'!!g", "7'|g", "1'=g"]);
      expect(z.fehler, isNull);
      expect(z.speicher.single.art, SpeicherArt.tag);
    });

    test("'!!! ist ein Fehler der Grammatik", () {
      expect(nach(RpnApi(), ["5'!!!g"]).fehler?.code, "A");
    });

    test('! bleibt sonst die Fakultät', () {
      expect(werte(nach(RpnApi(), ["4!"])), [24]);
    });
  });

  group('Tags mit Schreibschutz', () {
    test('anlegen und über den Namen ändern', () {
      final z = nach(RpnApi(), ["5'||t", "2'+t_D", "'t"]);
      expect(z.fehler, isNull);
      expect(werte(z), [7, 7]);
      expect(z.speicher.single.schreibschutz, isTrue);
      expect(z.speicher.single.art, SpeicherArt.tag);
    });

    test("'=x ist erlaubt", () {
      final z = nach(RpnApi(), ["5'||t", "9'=t_D"]);
      expect(z.fehler, isNull);
      expect(werte(z), [9]);
    });

    test('S, R und ~R sind ein Fehler', () {
      // der Block t liegt auf den Positionen 2 bis 4
      for (final befehl in ["2:S", "R", "~R", "3:S", "4:5:S"]) {
        final z = nach(RpnApi(), ["1 2 3 4_3:'||t", "5 6", befehl]);
        expect(z.fehler?.code, "schutz", reason: befehl);
        expect(werte(z), [1, 2, 3, 4, 5, 6], reason: befehl);
      }
    });

    test('S und R außerhalb der geschützten Zelle sind erlaubt', () {
      final z = nach(RpnApi(), ["1'||t", "2 3 4", "R"]);
      expect(z.fehler, isNull);
      expect(werte(z), [1, 3, 4, 2]);
    });

    test('~ auf der geschützten Zelle ist ein Fehler', () {
      final z = nach(RpnApi(), ["5'||t", "~"]);
      expect(z.fehler?.code, "schutz");
      expect(werte(z), [5]);
    });

    test("'S und 'R verschieben Wert und Tag gemeinsam", () {
      final z = nach(RpnApi(), ["1'||t", "2", "'S"]);
      expect(z.fehler, isNull);
      expect(werte(z), [2, 1]);
      expect(z.stack.first.tags, ["t"]);
    });

    test("'|x hebt den Schreibschutz auf", () {
      final z = nach(RpnApi(), ["5'||t", "'|t", "~"]);
      expect(z.fehler, isNull);
      expect(werte(z), [-5]);
    });

    test("'D und '~x entfernen den Tag samt Schutz", () {
      expect(nach(RpnApi(), ["5'||t", "'D"]).speicher, isEmpty);
      final z = nach(RpnApi(), ["5'||t", "'~t", "~"]);
      expect(z.fehler, isNull);
      expect(werte(z), [-5]);
    });

    test('ein gewöhnlicher Tag bleibt änderbar', () {
      final z = nach(RpnApi(), ["1'|t", "2", "S"]);
      expect(z.fehler, isNull);
      expect(werte(z), [2, 1]);
    });
  });

  test('Export und Import erhalten den Schreibschutz', () {
    final api = RpnApi();
    nach(api, ["9.81'!!g", "1'!v", "2 3 2:'||b", "4'|t"]);
    final text = api.exportieren().text;
    expect(text, contains("9.81_'!!g"));
    expect(text, contains("2:'||b"));
    expect(text, contains("'|t"));
    final neu = RpnApi();
    expect(neu.importieren(text), isNull);
    expect(neu.exportieren().text, text);
  });
}
