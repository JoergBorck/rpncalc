import 'dart:io';

import 'package:rpncalc/src/libraries/libraries.g.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc/src/engine/session.dart';
import 'package:rpncalc/src/version.dart';
import 'package:test/test.dart';

import 'internals.dart';
import '../tool/bibliotheken.dart';

/// Bibliotheken, Versionen und rpnjson (doc/api.md 9.1, doc/reference.md 10.5).
void main() {
  test('Wächter: lib/src/libraries/libraries.g.dart passt zu library/*.rpnlib', () {
    expect(File("lib/src/libraries/libraries.g.dart").readAsStringSync().replaceAll("\r\n", "\n"), erzeugen(Directory("library")),
        reason: "nach einer Änderung an einer Bibliothek: dart run tool/bibliotheken.dart");
  });

  test('die Version des Rechners steht auch in pubspec.yaml', () {
    expect(File("pubspec.yaml").readAsStringSync(), contains("version: $rechnerVersion"));
    expect(RpnApi.version, rechnerVersion);
  });

  test('Versionen: MAJOR gleich, MINOR.PATCH mindestens so hoch', () {
    expect(versionPasst("0.2.0", "0.1.9"), isTrue);
    expect(versionPasst("0.2.5", "0.2.5"), isTrue);
    expect(versionPasst("0.2.4", "0.2.5"), isFalse);
    expect(versionPasst("1.0.0", "0.9.0"), isFalse, reason: "MAJOR muss gleich sein");
    expect(versionPasst("0.1", "0.1.0"), isNull, reason: "keine gültige Angabe");
  });

  group('rpnjson', () {
    String? lade(RpnApi api, String text) => api.bibliothekHinzufuegen("probe", text) ?? api.ladeBibliothek("probe");

    test('Versionsangabe: passt, passt nicht, App nur wenn bekannt', () {
      final api = apiMitEinblick();
      expect(lade(api, '{{{"version":{"name":"p","bibliothek":"1.0.0","rechner":"0.1.0","app":"9.9.9"}}}rpnjson}'), isNull,
          reason: "ohne App-Version wird app übergangen");
      expect(api.bibliotheksVersion("p")!["bibliothek"], "1.0.0");
      final app = apiMitEinblick()..appVersion = "0.1.0";
      final z = app.eingabe('{{"version":{"name":"p","app":"0.2.0"}}}rpnjson');
      expect(z.fehler!.text, "Version passt nicht: p braucht die App 0.2.0, vorhanden ist 0.1.0");
    });

    test('passt die Version nicht, wird vom Rest des Blocks nichts angelegt', () {
      final api = apiMitEinblick();
      final fehler = lade(api, '{\n{{"version":{"name":"neu","rechner":"0.9.0"}}}rpnjson\n{1+}\':inc\n}');
      expect(fehler, contains("Version passt nicht"));
      expect(api.calculator.eigeneFunktionen, isEmpty);
    });

    test('Hilfe: eigene Einträge, Klammern im Text, unbekannte Schlüssel als Hinweis', () {
      final api = apiMitEinblick();
      final z = api.eingabe('{~:~:-}\':sub_{{"hilfe":[{"kennung":"sub","titel":"Differenz","verwendungen":'
          '[{"schreibweise":"a:b:sub","stack":"→ a−b","kurz":"zieht b ab \\u007b"}],"text":"Siehe [[#funktionen]]."}],'
          '"theme":{"farbe":"rot"}}}rpnjson');
      expect(z.fehler, isNull);
      final h = api.hilfe("sub")!;
      expect([h.titel, h.verwendungen.single.kurz, h.verweise], ["Differenz", "zieht b ab {", ["#funktionen"]]);
      expect(api.hinweise(), ["Unbekannter Schlüssel in rpnjson: theme"]);
      expect(api.hinweise(), isEmpty, reason: "nach dem Abruf leer");
      expect(api.hilfe("sin")!.titel, "Sinus", reason: "eingebaute Einträge gehen vor");
    });

    test('ungültiges JSON ist ein Fehler', () {
      expect(apiMitEinblick().eingabe('{{kein json}}rpnjson').fehler!.text, startsWith("Ungültiges JSON"));
      expect(apiMitEinblick().eingabe('{[1,2]}rpnjson').fehler!.text, startsWith("Ungültiges JSON"));
    });

    test('Namen mit rpn am Anfang sind reserviert', () {
      expect(apiMitEinblick().eingabe("{1}':rpnwert").fehler!.text, startsWith("Namen mit rpn am Anfang"));
    });
  });

  group('Hilfe der mitgelieferten Bibliotheken', () {
    // was ein Beispiel voraussetzt: die Statistik eine leere Messreihe und fünf Wertepaare auf dem Stack
    const vorbereitung = {"statistik": "sclr_2 1 4 2 5 3 4 4 5 5_"};
    for (final name in mitgelieferteBibliotheken.keys) {
      test('$name: jede Funktion hat eine Hilfe, jedes Beispiel läuft ohne Fehler', () {
        final api = apiMitEinblick()..ladeBibliothek(name);
        for (final f in api.bibliotheksFunktionen(name)) {
          final h = api.hilfe(f);
          expect(h?.verwendungen, isNotEmpty, reason: "Hilfe zu $f");
          for (final v in h!.verwendungen.where((v) => v.argumentListe.isNotEmpty)) {
            final probe = apiMitEinblick()..ladeBibliothek(name);
            final z = probe.eingabe("${vorbereitung[name] ?? ""}${v.beispielEingabe}");
            expect(z.fehler, isNull, reason: "${v.beispielEingabe}: ${z.fehler?.text}");
            expect(z.stack, isNotEmpty, reason: "${v.beispielEingabe} liefert ein Ergebnis");
          }
        }
      });
    }

    test('jede Funktion verweist auf ihre Übersicht, jeder Verweis hat ein Ziel', () {
      for (final name in mitgelieferteBibliotheken.keys) {
        final api = apiMitEinblick()..ladeBibliothek(name);
        expect(api.hilfe("#$name"), isNotNull, reason: "Übersicht #$name");
        for (final k in api.calculator.eigeneHilfen.keys) {
          final h = api.hilfe(k)!;
          for (final v in h.verweise) {
            expect(api.hilfe(v), isNotNull, reason: "$k → $v");
          }
          if (!k.startsWith("#")) expect(h.verweise, contains("#$name"), reason: "$k verweist auf die Bibliothek");
        }
      }
    });

    test('die Hilfe einer Bibliothek lässt sich lesen, bevor sie geladen ist', () {
      final api = apiMitEinblick();
      expect(api.hilfe("#statistik")?.titel, "Bibliothek: Statistik");
      expect(api.hilfe("eigen")?.verwendungen.single.beispielEingabe, "0.5:200:eigen");
      expect(api.calculator.eigeneFunktionen, isEmpty, reason: "nur gelesen, nicht geladen");
      expect(api.eingabe("0.5:200:eigen").fehler?.code, "fkt?", reason: "benutzen geht erst nach dem Laden");
    });

    test('Kurzinfo für Menüs und Tooltips, ohne die Bibliothek zu laden', () {
      final api = apiMitEinblick();
      final info = api.bibliotheksInfo("schwingungen")!;
      expect(info.beschreibung, startsWith("Mechanische Schwingungen"));
      expect([info.version, info.funktionen], ["1.2.0", 25]);
      expect(api.calculator.eigeneFunktionen, isEmpty, reason: "nur gefragt, nicht geladen");
      expect(api.bibliotheksInfo("gibtsnicht"), isNull);
    });

    test('die Werte in den Beispielen stimmen (Schwingungen)', () {
      num tos(String eingabe) => (apiMitEinblick()..ladeBibliothek("schwingungen")).eingabe(eingabe).stack.first.wert;
      expect(tos("0.5:200:eigen"), closeTo(20, 1e-9));
      expect(tos("0.05:20:0:0.1:ha"), closeTo(8.323, 1e-3));
      expect(tos("1pendel"), closeTo(3.132, 1e-3));
      expect(tos("0.05:0:20:2:0.5:dx"), closeTo(-0.01684, 1e-5));
      expect(tos("1:0.5:20:2:15:1:fx"), closeTo(-0.005489, 1e-6));
    });
  });

  group('Bibliotheken des Rechners', () {
    test('mitgeliefert, laden, Funktionen in der Reihenfolge der Datei', () {
      final api = apiMitEinblick();
      expect(api.bibliotheken(), [(name: "schwingungen", mitgeliefert: true), (name: "statistik", mitgeliefert: true)]);
      expect(mitgelieferteBibliotheken.keys, containsAll(["statistik", "schwingungen"]));
      expect(api.bibliotheksFunktionen("statistik").take(3), ["sclr", "sadd", "sall"]);
      expect(api.calculator.eigeneFunktionen, isEmpty, reason: "nur gefragt, nicht geladen");
      expect(api.ladeBibliothek("statistik"), isNull);
      expect(api.calculator.eigeneFunktionen.keys, contains("mean"));
      expect(api.bibliotheksVersion("statistik")!["bibliothek"], "1.1.0");
      expect(api.geladeneBibliotheksFunktionen, contains("mean"));
      expect(api.ladeBibliothek("gibtsnicht"), "Unbekannte Bibliothek: gibtsnicht");
    });

    test('hinzufügen: nicht unter dem Namen einer mitgelieferten, nur gültige Texte', () {
      final api = apiMitEinblick();
      expect(api.bibliothekHinzufuegen("statistik", "{}"), contains("mitgelieferte"));
      expect(api.bibliothekHinzufuegen("kaputt", "{1q}"), isNotNull);
      expect(api.bibliothek("kaputt"), isNull);
      expect(api.bibliothekHinzufuegen("meine", "{{1+}':inc}"), isNull);
      expect(api.bibliotheken().last, (name: "meine", mitgeliefert: false));
      expect(api.calculator.eigeneFunktionen, isEmpty, reason: "Hinzufügen lädt nicht");
      expect(api.ladeBibliothek("meine"), isNull);
      expect(api.geladeneBibliotheksFunktionen, isEmpty, reason: "nur mitgelieferte werden beim Speichern ausgelassen");
    });

    test('exportieren als Bibliothek und wieder laden, mit Version und Hilfe', () {
      final api = apiMitEinblick()..eingabe('{2*}\':dbl_{{"hilfe":[{"kennung":"dbl","titel":"Doppelt {x}"}]}}rpnjson');
      final text = api.exportiereBibliothek("meine", version: "1.2.0").text;
      expect(text.split("\n").first, "{");
      expect(text, contains(r"Doppelt \u007bx\u007d"), reason: "Klammern im Text maskiert");
      final neu = apiMitEinblick();
      expect(neu.bibliothekHinzufuegen("meine", text), isNull);
      expect(neu.ladeBibliothek("meine"), isNull);
      expect(neu.eingabe("4dbl").fehler, isNull);
      expect(neu.hilfe("dbl")!.titel, "Doppelt {x}");
      expect(neu.bibliotheksVersion("meine")!["bibliothek"], "1.2.0");
    });

    test('eine Session schreibt eigene Hilfen mit', () {
      final api = apiMitEinblick()..eingabe('{2*}\':dbl_{{"hilfe":[{"kennung":"dbl","titel":"Doppelt"}]}}rpnjson');
      final neu = apiMitEinblick();
      expect(neu.importieren(api.exportieren().text), isNull);
      expect(neu.hilfe("dbl")!.titel, "Doppelt");
    });

    test('JSON für einen Block: Klammern nur in Texten maskiert', () {
      expect(jsonFuerBlock({"a": "{x}", "b": [1]}), r'{"a":"\u007bx\u007d","b":[1]}');
      expect(jsonFuerBlock({"a": r'say "{"'}), r'{"a":"say \"\u007b\""}');
    });
  });
}
