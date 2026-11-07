import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

import 'internals.dart';

/// Laden und Speichern: der Zustand als RPN-Skript.
void main() {
  RpnApi mit(List<String> zeilen) {
    final api = apiMitEinblick();
    for (final z in zeilen) {
      expect(api.eingabe(z).fehler, isNull, reason: z);
    }
    return api;
  }

  test('Export einer Session im Skript-Format', () {
    final api = mit(["rad_42seed", "{1 2+}':f", "~3_1.5ê~7_2_3:'!v", "1_2_3_2:'|t", "{x}", "5:"]);
    expect(api.exportieren().text,
        "rad_42seed\n"
        "{1 2+}':f\n"
        "~3_1.5ê~7_2_3:'!v\n"
        "1_2_3_2:'|t\n"
        "{x}\n"
        "5:");
  });

  test('Export und Import ergeben denselben Zustand', () {
    final api = mit(["grd 7seed", "{a\nb}':g", "{1+}':inc", "4_'!w", "9_8_7_2:'|blk_6_'|tt", "{p}{q}", "3:4:"]);
    final text = api.exportieren().text;
    final neu = apiMitEinblick();
    expect(neu.importieren(text), isNull);
    expect(neu.exportieren().text, text);
    expect(neu.calculator.eigeneFunktionen["g"], "a\nb");     // mehrzeiliger Code
    expect(neu.zustand().argumente, [3, 4]);                  // offene Argumente
  });

  test('Nur Funktionen exportieren', () {
    final api = mit(["{1 2+}':f", "5'!x", "7"]);
    expect(api.exportieren(nurFunktionen: true).text, "{1 2+}':f");
  });

  test('Nur Funktionen exportieren, ohne die aus Bibliotheken (doc/api.md Kapitel 7)', () {
    final api = mit(["{1 2+}':f", "{2*}':dbl", "{3*}':tri"]);
    expect(api.exportieren(nurFunktionen: true, ohne: {"dbl", "fehlt"}).text, "{1 2+}':f\n{3*}':tri");
    expect(api.exportieren(ohne: {"dbl"}).text, contains("{2*}':dbl"), reason: "die Session bleibt vollständig");
  });

  test('Import ohne ersetzen ergänzt den Zustand', () {
    final api = mit(["5'!x"]);
    expect(api.importieren("{1 2+}':f", ersetzen: false), isNull);
    expect(api.calculator.variablen["x"], [5]);
    expect(api.calculator.eigeneFunktionen["f"], "1 2+");
  });

  test('Fehler beim Import nennt die Zeile', () {
    expect(apiMitEinblick().importieren("1 2+\n'q"), startsWith("Zeile 2:"));
    expect(apiMitEinblick().importieren("{1 2"), contains("nicht abgeschlossen"));
  });

  test('Unendlich lässt sich nicht speichern', () {
    final api = mit(["1 0/"]);
    expect(api.exportieren().warnungen, isNotEmpty);
  });
}
