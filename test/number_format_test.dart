import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc/src/number_format.dart' show formatiere;
import 'package:test/test.dart';

/// Das Anzeigeformat (FR-3, lib/src/number_format.dart): die Beispiele aus process/requirements/FR-3.md.
void main() {
  const std = Anzeigeformat.standard;
  String z(num w, [Anzeigeformat f = std]) {
    return formatiere(w, f).text;
  }

  Anzeigeformat fmt(Zahlformat format, [int stellen = 4, Bruch bruch = Bruch.off, Trenner trenner = Trenner.none]) =>
      Anzeigeformat(format: format, stellen: stellen, bruch: bruch, trenner: trenner);

  test('Std wie bisher, der Exponent mit ê und Minuszeichen; 0.1+0.2 ist nicht gerundet, 1/3 schon', () {
    expect([z(1.5), z(42), z(-3), z(0.1 + 0.2), z(1 / 3)], ["1.5", "42", "-3", "0.3", "0.333333333333…"]);
    expect([z(1.5e21), z(1e-20)], ["1.5ê21", "1ê−20"]);
  });

  test('Eingabe mit ê ist der nächste double: 1ê23 zeigt 1ê23, nicht 1.0000000000000001ê23', () {
    final api = RpnApi();
    for (final (ein, wert) in [("1ê23", 1e23), ("12.345ê3", 12345.0), ("0.000123", 0.000123), ("1.1ê300", 1.1e300)]) {
      expect(api.eingabe("$ein ").stack.first.wert, wert, reason: ein);
    }
    expect(z(1e23), "1ê23");
  });

  test('höchstens 15 gültige Ziffern auch bei Sci und Eng; große Exponenten ohne Überlauf', () {
    expect([z(1e23, fmt(Zahlformat.fix, 15)), z(1e23, fmt(Zahlformat.sci, 15)), z(1e23, fmt(Zahlformat.eng, 15))],
        ["1.00000000000000…ê23", "1.00000000000000…ê23", "100.000000000000…ê21"], reason: "nicht 9.999…ê22");
    expect([z(0, fmt(Zahlformat.sci, 15)), z(1.5e20, fmt(Zahlformat.eng, 3)), z(1.5e20, fmt(Zahlformat.si, 3))],
        ["0.00000000000000ê0", "150.0ê18", "150.0 E"]);
  });

  test('Fix n: n Nachkommastellen, kaufmännisch, höchstens 15 gültige Ziffern', () {
    expect([z(2.5, fmt(Zahlformat.fix, 0)), z(-2.5, fmt(Zahlformat.fix, 0)), z(1 / 3, fmt(Zahlformat.fix, 4))],
        ["3…", "-3…", "0.3333…"]);
    expect([z(2, fmt(Zahlformat.fix, 2)), z(-0.001, fmt(Zahlformat.fix, 2))], ["2.00", "0.00…"]);
    expect(z(12345678.9, fmt(Zahlformat.fix, 12)), "12345678.9000000…", reason: "15 gültige Ziffern");
    expect(z(1.5e20, fmt(Zahlformat.fix, 2)), "1.50ê20", reason: "zu groß für Fix: wie Sci");
  });

  test('Sci, Eng, SI', () {
    expect([z(1234567, fmt(Zahlformat.sci, 3)), z(0.01234, fmt(Zahlformat.sci, 3))], ["1.235…ê6", "1.234ê−2"]);
    expect([z(1234567, fmt(Zahlformat.eng, 3)), z(0.01234, fmt(Zahlformat.eng, 3)), z(12.5, fmt(Zahlformat.eng, 3))],
        ["1.235…ê6", "12.34ê−3", "12.50"]);
    expect([z(12300, fmt(Zahlformat.si, 2)), z(0.01234, fmt(Zahlformat.si, 3)), z(1e-21, fmt(Zahlformat.si, 2))],
        ["12.3 k", "12.34 m", "1.00ê−21"]);
    expect(z(999999, fmt(Zahlformat.eng, 2)), "1.00…ê6", reason: "nach dem Runden wieder zwischen 1 und 999");
  });

  test('Trenner in Dreiergruppen vor dem Punkt, nicht im Exponenten', () {
    expect(z(1234567.891, fmt(Zahlformat.fix, 2, Bruch.off, Trenner.apos)), "1'234'567.89…");
    expect(z(1234.5, Anzeigeformat(trenner: Trenner.comma)), "1,234.5");
    expect(z(1e21, Anzeigeformat(trenner: Trenner.space)), "1ê21");
    expect(z(-12345, Anzeigeformat(trenner: Trenner.space)), "-12 345");
  });

  test('Bruch: Grundregel und echte Stellen (Beispiele aus FR-3)', () {
    const gemischt = Anzeigeformat(bruch: Bruch.mixed), unecht = Anzeigeformat(bruch: Bruch.improper);
    expect([z(1.5, gemischt), z(1.5, unecht), z(0.75, gemischt), z(0.125, gemischt), z(1 / 3, gemischt)],
        ["1 1/2", "3/2", "3/4", "1/8", "1/3"]);
    expect([z(100.1, gemischt), z(1234.56, gemischt), z(0.05, gemischt), z(-2.25, gemischt), z(7, gemischt)],
        ["100.1", "1234.56", "1/20", "-2 1/4", "7"]);
    expect(z(2 / 3, fmt(Zahlformat.fix, 2, Bruch.mixed)), "2/3", reason: "Fix: ein Bruch findet sich");
    expect(z(0.3, fmt(Zahlformat.fix, 1, Bruch.mixed)), "0.3", reason: "3/10: Zehnerpotenz im Nenner");
    expect(z(123.4567, fmt(Zahlformat.si, 3, Bruch.mixed)), "123.5…", reason: "1/2 ist nicht genauer als .5");
    expect([z(3.14159265, fmt(Zahlformat.fix, 2, Bruch.mixed)), z(3.14159265, fmt(Zahlformat.fix, 1, Bruch.mixed))],
        ["3.14…", "3 1/7…"], reason: "gerundet: der Bruch muss um eine Stelle genauer sein");
  });

  test('Bruch bei Sci, Eng und SI (Tabelle in FR-3)', () {
    Anzeigeformat b(Zahlformat f) => fmt(f, 5, Bruch.mixed);
    expect([z(1.234e6, b(Zahlformat.sci)), z(1.234e6, b(Zahlformat.eng)), z(1.234e6, b(Zahlformat.si))],
        ["1234ê3", "1.23400ê6", "1.23400 M"]);
    expect([z(1234.56, b(Zahlformat.sci)), z(1234.56, b(Zahlformat.eng)), z(1234.56, b(Zahlformat.si))],
        ["1.23456ê3", "1.23456ê3", "1.23456 k"]);
    expect([z(0.01234, b(Zahlformat.sci)), z(0.01234, fmt(Zahlformat.eng, 3, Bruch.mixed)), z(0.01234, fmt(Zahlformat.si, 3, Bruch.mixed))],
        ["617/5ê4", "12.34ê−3", "12.34 m"]);
    expect([z(1 / 3, b(Zahlformat.eng)), z(1500, fmt(Zahlformat.si, 1, Bruch.mixed))], ["1/3", "1.5 k"]);
  });

  test('Befehle: rpn.format.*, rpn.sep.*, rpn.frac.*; Stellen als Argument, ohne die bisherigen', () {
    final api = RpnApi();
    var z = api.eingabe("2:rpn.format.fix rpn.sep.apos rpn.frac.mixed");
    expect([z.fehler, z.anzeige], [null, const Anzeigeformat(format: Zahlformat.fix, stellen: 2, trenner: Trenner.apos, bruch: Bruch.mixed)]);
    z = api.eingabe("rpn.format.sci");
    expect([z.anzeige.format, z.anzeige.stellen], [Zahlformat.sci, 2], reason: "ohne Argument die bisherigen Stellen");
    z = api.eingabe("16:rpn.format.fix");
    expect([z.fehler?.code, z.anzeige.format], ["stellen", Zahlformat.sci]);
    expect(api.formatiere(1234.5).zahl, "1.23ê3");
    expect(api.formatiere(1234.5, Anzeigeformat.standard).zahl, "1234.5", reason: "Vorschau in einem anderen Format");
    api.reset();
    expect(api.zustand().anzeige, Anzeigeformat.standard);
  });

  test('Setter ohne die offene Zeile zu berühren; JSON und Session mit dem Format', () {
    final api = RpnApi();
    api.taste("7");
    api.anzeigeformat = const Anzeigeformat(format: Zahlformat.eng, stellen: 3, trenner: Trenner.space);
    final z = api.zustand();
    expect([z.zeile, z.anzeige.format], ["7", Zahlformat.eng]);
    expect(Zustand.fromJson(z.toJson()).anzeige, z.anzeige);
    final skript = api.exportieren().text;
    expect(skript, contains("3:rpn.format.eng_rpn.sep.space"));
    final neu = RpnApi()..importieren(skript);
    expect(neu.zustand().anzeige, z.anzeige);
    expect(RpnApi().exportieren().text, isNot(contains("rpn.")), reason: "Standard wird nicht geschrieben");
  });
}
