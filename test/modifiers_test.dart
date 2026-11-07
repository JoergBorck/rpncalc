import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

import 'internals.dart';

/// Einfache und doppelte Modifikatoren und der Schutz von Funktionen, siehe doc/reference.md 8.2, 10.2 und 10.6.
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

  /// Eine kleine Bibliothek mit Versionsangabe und den Funktionen [namen] (jede legt 1 auf den Stack).
  String bib(String name, List<String> namen) => [
        "{",
        '{{"version":{"name":"$name","bibliothek":"1.0.0"}}}rpnjson',
        for (final n in namen) "{1}':$n",
        "}",
      ].join("\n");

  group('Füllen und um 1 ändern', () {
    test("'==x schreibt den Tos in alle Elemente, er bleibt auf dem Stack", () {
      final z = nach(apiMitEinblick(), ["1 2 3 3:'!v", "7'==v", "0:3:'v"]);
      expect(z.fehler, isNull);
      expect(werte(z), [7, 7, 7, 7]);
    });

    test("'==x füllt auch die Zellen eines Tags", () {
      final z = nach(apiMitEinblick(), ["1 2 2:'|t", "0'==t"]);
      expect(z.fehler, isNull);
      expect(werte(z), [0, 0, 0]);
    });

    test("'++x und '--x ändern um 1, mit n:m auch mehrere Elemente", () {
      expect(werte(nach(apiMitEinblick(), ["5'!x", "'++x", "'x"])), [6]);
      expect(werte(nach(apiMitEinblick(), ["5'!x", "'--x", "'--x", "'x"])), [3]);
      final z = nach(apiMitEinblick(), ["1 2 3 3:'!v", "1:2:'++v", "0:3:'v"]);
      expect(werte(z), [2, 3, 3], reason: "Element 0 ist die 3, die Elemente 1 und 2 (2 und 1) werden erhöht");
    });

    test("'**x, '//x und gemischte Paare erkennt die Grammatik, der Rechner meldet sie", () {
      for (final mod in ["**", "//", "+-", "=+", "~+", "!=", "-~"]) {
        expect(nach(apiMitEinblick(), ["5'!x", "2'${mod}x"]).fehler?.code, "varOp", reason: mod);
      }
    });

    test("Grammatikfehler: drei Modifikatoren, : gemischt, Operatoren außerhalb von ! = + - * / ~", () {
      for (final eingabe in ["5'!!!x", "'~~~x", "':=f", "'+:x", "':::f"]) {
        expect(apiMitEinblick().eingabe(eingabe).fehler?.code, "A", reason: eingabe);
      }
      for (final eingabe in ["'^x", "'%x", "'<x", "'&x"]) {
        expect(apiMitEinblick().eingabe(eingabe).fehler?.code, "9", reason: eingabe);
      }
    });
  });

  group('Eigene Funktionen ablegen und ersetzen', () {
    test("':name legt neu an, ein zweites ':name ist ein Fehler", () {
      final api = apiMitEinblick();
      expect(api.eingabe("{1}':f").fehler, isNull);
      final z = api.eingabe("{2}':f");
      expect(z.fehler?.code, "fktDa");
      expect(z.fehler?.text, "Funktion f gibt es schon, ersetzen mit '::f");
      expect(werte(api.eingabe("f")), [1], reason: "die alte Funktion bleibt");
    });

    test("'::name ersetzt eine vorhandene und legt eine neue an", () {
      final api = apiMitEinblick();
      expect(nach(api, ["{1}':f", "{2}'::f"]).fehler, isNull);
      expect(werte(api.eingabe("f")), [2]);
      expect(nach(api, ["{3}'::g", "C", "g"]).fehler, isNull);
      expect(werte(api.zustand()), [3]);
    });
  });

  group('Entfernen mit ~ und ~~', () {
    final faelle = [
      (ziel: "Variable", anlegen: "5'!x", geschuetzt: false),
      (ziel: "Konstante", anlegen: "5'!!x", geschuetzt: true),
      (ziel: "Tag", anlegen: "5'|x", geschuetzt: false),
      (ziel: "Tag mit Schreibschutz", anlegen: "5'||x", geschuetzt: true),
      (ziel: "eigene Funktion", anlegen: "{1}':x", geschuetzt: false),
    ];
    for (final f in faelle) {
      final richtig = f.geschuetzt ? "'~~x" : "'~x";
      final falsch = f.geschuetzt ? "'~x" : "'~~x";
      test("${f.ziel}: $richtig entfernt, $falsch ist ein Fehler", () {
        final api = apiMitEinblick()..eingabe(f.anlegen);
        final z = api.eingabe(falsch);
        expect(z.fehler?.code, f.geschuetzt ? "geschuetzt" : "ungeschuetzt");
        expect(z.fehler?.text, contains(richtig), reason: "die Meldung nennt die richtige Form");
        expect(api.eingabe(richtig).fehler, isNull);
        expect(api.eingabe(richtig).fehler?.code, "var?", reason: "danach ist x weg");
      });
    }

    test("'~~x auf einen unbekannten Namen", () {
      expect(apiMitEinblick().eingabe("'~~x").fehler?.code, "var?");
    });
  });

  group('Funktionen aus Bibliotheken', () {
    test('gehören zur Bibliothek und sind geschützt', () {
      final api = apiMitEinblick();
      expect(api.bibliothekHinzufuegen("meine", bib("meine", ["eins", "zwei"])), isNull);
      expect(api.ladeBibliothek("meine"), isNull);
      expect(api.calculator.herkunft, {"eins": "meine", "zwei": "meine"});
      expect(api.geladeneBibliotheksFunktionen, {"eins", "zwei"});
      expect(api.eingabe("{2}':eins").fehler?.code, "bibFkt");
      expect(api.eingabe("{2}'::eins").fehler?.text, "Funktion gehört zu einer Bibliothek: eins (meine)");
      expect(api.eingabe("'~eins").fehler?.code, "geschuetzt");
    });

    test("'~~name entfernt eine Funktion, erneutes Laden bringt sie zurück", () {
      final api = apiMitEinblick();
      api.bibliothekHinzufuegen("meine", bib("meine", ["eins", "zwei"]));
      api.ladeBibliothek("meine");
      expect(api.eingabe("'~~eins").fehler, isNull);
      expect(api.calculator.eigeneFunktionen.keys, ["zwei"]);
      expect(api.geladeneBibliotheksFunktionen, {"zwei"});
      expect(api.ladeBibliothek("meine"), isNull, reason: "dieselbe Bibliothek erneut laden ist kein Konflikt");
      expect(api.calculator.herkunft.keys, containsAll(["eins", "zwei"]));
    });

    test('Namenskonflikt mit einer eigenen Funktion: die Bibliothek wird nicht geladen', () {
      final api = apiMitEinblick()..eingabe("{7}':zwei");
      api.bibliothekHinzufuegen("meine", bib("meine", ["eins", "zwei"]));
      expect(api.ladeBibliothek("meine"), "Name ist schon vergeben: zwei (eigene Funktion)");
      expect(api.calculator.eigeneFunktionen.keys, ["zwei"], reason: "auch eins ist nicht geladen");
      expect(werte(api.eingabe("zwei")), [7]);
    });

    test('Namenskonflikt zwischen zwei Bibliotheken', () {
      final api = apiMitEinblick();
      api.bibliothekHinzufuegen("a", bib("a", ["f"]));
      api.bibliothekHinzufuegen("b", bib("b", ["g", "f"]));
      expect(api.ladeBibliothek("a"), isNull);
      expect(api.ladeBibliothek("b"), "Name ist schon vergeben: f (Bibliothek a)");
      expect(api.calculator.herkunft, {"f": "a"});
    });

    test('auch ohne die API: der Block bricht beim Konflikt ab', () {
      final api = apiMitEinblick()..eingabe("{7}':zwei");
      expect(api.importieren(bib("meine", ["eins", "zwei"]), ersetzen: false), isNull);
      final z = api.eingabe("X");
      expect(z.fehler?.text, contains("Name ist schon vergeben: zwei (eigene Funktion)"));
    });

    test('nach dem Block legt man wieder eigene Funktionen ab', () {
      final api = apiMitEinblick();
      api.bibliothekHinzufuegen("meine", bib("meine", ["eins"]));
      api.ladeBibliothek("meine");
      expect(api.eingabe("{2}':drei").fehler, isNull);
      expect(api.calculator.herkunft.containsKey("drei"), isFalse);
      expect(api.eingabe("'~drei").fehler, isNull);
    });

    test('eine Bibliothek ohne Versionsangabe legt eigene Funktionen ab', () {
      final api = apiMitEinblick();
      api.bibliothekHinzufuegen("alt", "{{1}':eins}");
      api.ladeBibliothek("alt");
      expect(api.calculator.herkunft, isEmpty);
      expect(api.eingabe("'~eins").fehler, isNull);
    });

    test('reset vergisst die Herkunft', () {
      final api = apiMitEinblick();
      api.bibliothekHinzufuegen("meine", bib("meine", ["eins"]));
      api.ladeBibliothek("meine");
      api.reset();
      expect(api.calculator.herkunft, isEmpty);
      expect(api.calculator.aktuelleBibliothek, isNull);
    });
  });
}
