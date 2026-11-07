import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc/src/selftest/test_calculator.dart';
import 'package:test/test.dart';

/// Eingabe Zeichen für Zeichen: taste(), zeilenende() und loeschen(), siehe doc/api.md Kapitel 5.
void main() {
  /// Gibt jedes Zeichen einzeln ein, "\n" als Zeilenende, und schließt die Zeile ab.
  Zustand tippen(RpnApi api, String text) {
    for (final c in text.split("")) {
      c == "\n" ? api.zeilenende() : api.taste(c);
    }
    return api.zeilenende();
  }

  List<num> werte(Zustand z) => [for (final s in z.stack.reversed) s.wert];

  group('taste() liefert dasselbe wie eingabe()', () {
    for (final (id, eingabe, _) in UnittestCalculator().data) {
      test('$id: ${eingabe.replaceAll('\n', r'\n')}', () {
        final zeilen = RpnApi();
        Zustand? z1;
        for (final zeile in eingabe.split("\n")) {
          z1 = zeilen.eingabe(zeile);
        }
        final zeichen = RpnApi();
        final z2 = tippen(zeichen, eingabe);
        expect(zeichen.testString(), zeilen.testString());
        expect(z2.fehler?.code, z1!.fehler?.code);
        expect(z2.fehler?.position, z1.fehler?.position);
        expect(z2.codeOffen, z1.codeOffen);
      });
    }
  });

  group('Zustand während der Eingabe', () {
    test('offenes Token und vorgemerktes Enter', () {
      final api = RpnApi();
      var z = api.taste("1");
      z = api.taste("2");
      expect([z.offen, z.enterVorgemerkt, werte(z)], ["12", false, <num>[]]);
      z = api.taste(" ");
      expect([z.offen, z.enterVorgemerkt, werte(z)], ["", true, [12]]);
      z = api.taste("3");
      expect([z.offen, z.enterVorgemerkt, werte(z)], ["3", true, [12]]);
      z = api.taste("+");
      expect([z.offen, z.enterVorgemerkt, werte(z)], ["", false, [15]]);
      expect(z.zeile, "12 3+");
    });

    test('ein Präfix bleibt offen', () {
      final api = RpnApi();
      api.taste("2");
      final z = api.taste("~");
      expect(z.offen, "~");
      expect(werte(z), [2]);
      expect(werte(api.taste("/")), [0.5]);
    });

    test('zeilenende schließt das Token ab, die nächste Taste beginnt eine neue Zeile', () {
      final api = RpnApi();
      api.taste("7");
      var z = api.zeilenende();
      expect([z.offen, z.zeile, werte(z)], ["", "7", [7]]);
      z = api.taste("8");
      expect(z.zeile, "8");
    });

    test('nach einem Fehler wird bis zum Zeilenende nichts mehr ausgeführt, Return hebt die Sperre auf', () {
      final api = RpnApi();
      for (final c in "1q2 3".split("")) {
        api.taste(c);
      }
      var z = api.zustand();
      expect(z.fehler?.code, "fkt?");
      expect(z.fehler?.position, 2);
      expect(werte(z), [1]);
      z = api.zeilenende();
      expect(z.fehler?.code, "fkt?");
      z = api.taste("5");
      expect(z.fehler, isNull);
    });

    test('ein Code-Block wird gesammelt', () {
      final api = RpnApi();
      for (final c in "{1 2".split("")) {
        api.taste(c);
      }
      var z = api.zustand();
      expect([z.offen, z.codeOffen, werte(z)], ["{1 2", true, <num>[]]);
      z = api.taste("}");
      expect(z.codeStack, ["1 2"]);
    });
  });

  group('loeschen()', () {
    test('im offenen Token', () {
      final api = RpnApi();
      for (final c in "123".split("")) {
        api.taste(c);
      }
      var z = api.loeschen();
      expect([z.offen, z.zeile], ["12", "12"]);
      z = api.taste("+");
      expect(werte(z), [12]);
    });

    test('im offenen Code-Block, bis er ganz verschwindet', () {
      final api = RpnApi();
      for (final c in "{1 ".split("")) {
        api.taste(c);
      }
      api.loeschen();
      api.loeschen();
      final z = api.loeschen();
      expect([z.offen, z.codeOffen, z.zeile], ["", false, ""]);
    });

    test('ein vorgemerktes Enter', () {
      final api = RpnApi();
      for (final c in "5 ".split("")) {
        api.taste(c);
      }
      var z = api.loeschen();
      expect([z.enterVorgemerkt, z.zeile], [false, "5"]);
      z = api.taste("*");
      expect(werte(z), [0]); // ohne Enter: 0 * 5
    });

    test('ein Leerzeichen, das schon ein Enter ausgeführt hat, bleibt', () {
      final api = RpnApi();
      for (final c in "5  ".split("")) {
        api.taste(c);
      }
      final z = api.loeschen();
      expect([z.enterVorgemerkt, z.zeile], [true, "5  "]);
    });

    test('ausgeführte Token bleiben (noch kein Undo)', () {
      final api = RpnApi();
      for (final c in "3 4+".split("")) {
        api.taste(c);
      }
      final z = api.loeschen();
      expect([z.zeile, werte(z)], ["3 4+", [7]]);
    });

    test('nach dem Zeilenende passiert nichts', () {
      final api = RpnApi();
      api.taste("1");
      api.zeilenende();
      final z = api.loeschen();
      expect([z.zeile, werte(z)], ["1", [1]]);
    });
  });

  group('Fehler (doc/api.md 5.6 und 5.7)', () {
    Zustand tasten(RpnApi api, String text) {
      for (final c in text.split("")) {
        api.taste(c);
      }
      return api.zustand();
    }

    test('start und token zeigen auf das fehlerhafte Token', () {
      for (final (eingabe, start, position, token) in [
        ("1q2", 1, 2, "q"),
        ("7 3+ 1q2 5", 6, 7, "q"),
        ("1 0|/", 3, 4, "|/"),
        ("5'!!!g", 1, 4, "'!!!"),
        ("1 2 foo 4", 4, 7, "foo"),
      ]) {
        final f = tasten(RpnApi(), eingabe).fehler!;
        expect([f.start, f.position, f.token], [start, position, token], reason: eingabe);
      }
    });

    test('ein Fehler sperrt die Eingabe, die Tasten danach werden nur gesammelt', () {
      final z = tasten(RpnApi(), "7 1q2 5+");
      expect(z.fehler?.code, "fkt?");
      expect(z.zeile, "7 1q2 5+");
      expect(werte(z), [7, 1]);
    });

    test('Löschen nimmt erst alle Tasten danach auf einmal zurück, dann ist das Token wieder offen (VR-7)', () {
      final api = RpnApi();
      tasten(api, "7 1q2 5");
      var z = api.loeschen();
      expect([z.zeile, z.fehler?.code], ["7 1q2", "fkt?"], reason: "' 5' mit einem Löschen");
      z = api.loeschen();
      expect([z.zeile, z.offen, z.fehler], ["7 1q", "q", null]);
      z = api.loeschen();
      expect([z.zeile, z.offen], ["7 1", ""]);
      z = api.taste("+");
      expect(werte(z), [8]);
    });

    test('ein langer Text nach einem Fehler geht mit einem Löschen weg (VR-7)', () {
      final api = RpnApi();
      tasten(api, "1q2${List.filled(200, " 3;4,5").join()}"); // wie ein eingefügter Text nach dem Fehler
      var z = api.loeschen();
      expect([z.zeile, z.fehler?.code], ["1q2", "fkt?"]);
      z = api.loeschen();
      expect([z.zeile, z.offen, z.fehler], ["1q", "q", null]);
    });

    test('verwerfen: offenes Token, vorgemerktes Enter und Tasten nach einem Fehler weg, Ausgeführtes bleibt (FA-25)', () {
      for (final (eingabe, stack) in [("3 4+12", [7]), ("5 ", [5]), ("1q2abc", [1]), ("2 {1 2", [2]), ("", <num>[])]) {
        final api = RpnApi();
        tasten(api, eingabe);
        final z = api.verwerfen();
        expect([werte(z), z.offen, z.fehler, z.enterVorgemerkt, z.codeOffen, z.zeileFertig],
            [stack, "", null, false, false, true], reason: eingabe);
        api.taste("1");
        expect(werte(api.zeilenende()), [...stack, 1], reason: "$eingabe: danach geht es normal weiter");
      }
    });

    test('ein Operator, der selbst scheitert, ist nach dem Reparieren bis auf die letzte Taste offen', () {
      final api = RpnApi();
      tasten(api, "1 0|/");
      final z = api.loeschen();
      expect([z.offen, z.fehler, werte(z)], ["|", null, [1, 0]]);
    });

    test('Return verwirft nach einem Fehler, der Stack bleibt', () {
      final api = RpnApi();
      tasten(api, "7 1q2 5");
      var z = api.zeilenende();
      expect(werte(z), [7, 1]);
      z = api.taste("3");
      expect([z.fehler, z.zeile], [null, "3"]);
    });

    test('ein dup durch das vorgemerkte Enter wird beim Fehler zurückgenommen', () {
      final z = RpnApi().eingabe("1 q");
      expect(werte(z), [1]);
      expect(z.enterVorgemerkt, isTrue);
    });

    test('die Argumente liegen nach einem Fehler wieder bereit', () {
      final api = RpnApi();
      var z = tasten(api, "3:qq ");
      expect([z.fehler?.code, z.argumente], ["fkt?", [3]]);
      api.loeschen();
      api.loeschen();
      z = api.loeschen();
      expect([z.zeile, z.offen, z.argumente], ["3:", "", [3]]);
    });
  });

  test('zeileFertig: eine abgeschlossene Zeile, auch aus eingabe(), lässt sich nicht mehr reparieren', () {
    final api = RpnApi();
    var z = api.eingabe("7 3+ 1q2 5"); // z.B. vorher in der zeilenweisen Eingabe
    expect([z.zeileFertig, z.zeile, z.fehler?.code], [true, "7 3+ 1q2 5", "fkt?"]);
    z = api.loeschen();
    expect([z.zeileFertig, z.zeile], [true, "7 3+ 1q2 5"], reason: "loeschen tut nichts");
    z = api.taste("4");
    expect([z.zeileFertig, z.zeile, z.fehler], [false, "4", null], reason: "neue Zeile");
    z = api.zeilenende();
    expect(z.zeileFertig, isTrue);
    expect(RpnApi().zustand().zeileFertig, isFalse);
  });
}
