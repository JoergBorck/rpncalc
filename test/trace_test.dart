import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// Spur einer Eingabe durch den Rechner (process/requirements/PR-1.md).
void main() {
  List<String> spur(String eingabe, {Set<String>? nur, List<String> vorher = const []}) {
    final api = RpnApi();
    for (final v in vorher) {
      api.eingabe(v);
    }
    final zeilen = <String>[];
    api.spur = Spur.liste(zeilen, nur: nur);
    api.eingabe(eingabe);
    return zeilen;
  }

  test('Zeichen, DEA, Token, Ausführung und Stack in dieser Reihenfolge', () {
    final z = spur("3 4+");
    expect(z.first, "zeichen\t0\t3");
    expect(z[1], startsWith("dea\tq0\t"));
    expect(z, containsAllInOrder([
      "token\tZ‖3.0", "rechner\tzahl\t3.0", "stack\t[3.0]<tos",
      "token\tO‖+", "rechner\toperator\t+", "stack\t[7.0]<tos",
    ]));
    expect(z, contains("zeichen\t4\t\\n")); // Zeilenende sichtbar, die Zeile bleibt eine Zeile
  });

  test('nur ausgewählte Kategorien', () {
    final z = spur("3 4+", nur: {"token"});
    expect(z, ["token\tZ‖3.0", "token\tT‖_", "token\tZ‖4.0", "token\tO‖+", "token\tT‖\\n"]);
  });

  test('Code eigener Funktionen ist eingerückt', () {
    final z = spur("f", nur: {"token", "rechner"}, vorher: ["{1 2+}':f"]);
    expect(z, containsAllInOrder(["token\tF‖f", "rechner\tcode\tf\t1 2+", "  token\tZ‖1.0", "  token\tO‖+"]));
    expect(z.last, isNot(startsWith(" "))); // nach dem Code wieder außen
  });

  test('Argumente stehen beim Token', () {
    final z = spur("4:rpn.fix", nur: {"rechner"});
    expect(z.any((s) => s.contains("args=4.0")), isTrue);
  });

  test('Fehler mit Code und Text', () {
    expect(spur("x.5", nur: {"fehler"}), ["fehler\tC\tBuchstabe nach Punkt im Namen erwartet"]);
    expect(spur("1 0|/", nur: {"fehler"}), ["fehler\tdiv0\tDivision durch 0"]);
  });

  test('ohne Spur bleibt alles still und gleich', () {
    final api = RpnApi();
    api.spur = Spur((_) => fail("keine Ausgabe erwartet"), nur: {});
    expect(api.eingabe("3 4+").stack.first.wert, 7);
    api.spur = null;
    expect(api.eingabe("2*").stack.first.wert, 14);
  });
}
