import 'dart:io';

import 'package:rpncalc/bibliotheken.g.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc/session.dart';
import 'package:rpncalc/version.dart';
import 'package:test/test.dart';

import '../tool/bibliotheken.dart';

/// Bibliotheken, Versionen und rpnjson (doc/api.md 9.1, doc/reference.md 10.5).
void main() {
  test('Wächter: lib/bibliotheken.g.dart passt zu library/*.rpnlib', () {
    expect(File("lib/bibliotheken.g.dart").readAsStringSync().replaceAll("\r\n", "\n"), erzeugen(Directory("library")),
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
      final api = RpnApi();
      expect(lade(api, '{{{"version":{"name":"p","bibliothek":"1.0.0","rechner":"0.1.0","app":"9.9.9"}}}rpnjson}'), isNull,
          reason: "ohne App-Version wird app übergangen");
      expect(api.bibliotheksVersion("p")!["bibliothek"], "1.0.0");
      final app = RpnApi()..appVersion = "0.1.0";
      final z = app.eingabe('{{"version":{"name":"p","app":"0.2.0"}}}rpnjson');
      expect(z.fehler!.text, "Version passt nicht: p braucht die App 0.2.0, vorhanden ist 0.1.0");
    });

    test('passt die Version nicht, wird vom Rest des Blocks nichts angelegt', () {
      final api = RpnApi();
      final fehler = lade(api, '{\n{{"version":{"name":"neu","rechner":"0.9.0"}}}rpnjson\n{1+}\':inc\n}');
      expect(fehler, contains("Version passt nicht"));
      expect(api.calculator.eigeneFunktionen, isEmpty);
    });

    test('Hilfe: eigene Einträge, Klammern im Text, unbekannte Schlüssel als Hinweis', () {
      final api = RpnApi();
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
      expect(RpnApi().eingabe('{{kein json}}rpnjson').fehler!.text, startsWith("Ungültiges JSON"));
      expect(RpnApi().eingabe('{[1,2]}rpnjson').fehler!.text, startsWith("Ungültiges JSON"));
    });

    test('Namen mit rpn am Anfang sind reserviert', () {
      expect(RpnApi().eingabe("{1}':rpnwert").fehler!.text, startsWith("Namen mit rpn am Anfang"));
    });
  });

  group('Bibliotheken des Rechners', () {
    test('mitgeliefert, laden, Funktionen in der Reihenfolge der Datei', () {
      final api = RpnApi();
      expect(api.bibliotheken(), [(name: "schwingungen", mitgeliefert: true), (name: "statistik", mitgeliefert: true)]);
      expect(mitgelieferteBibliotheken.keys, containsAll(["statistik", "schwingungen"]));
      expect(api.bibliotheksFunktionen("statistik").take(3), ["sclr", "sadd", "sall"]);
      expect(api.calculator.eigeneFunktionen, isEmpty, reason: "nur gefragt, nicht geladen");
      expect(api.ladeBibliothek("statistik"), isNull);
      expect(api.calculator.eigeneFunktionen.keys, contains("mean"));
      expect(api.bibliotheksVersion("statistik")!["bibliothek"], "1.0.0");
      expect(api.geladeneBibliotheksFunktionen, contains("mean"));
      expect(api.ladeBibliothek("gibtsnicht"), "Unbekannte Bibliothek: gibtsnicht");
    });

    test('hinzufügen: nicht unter dem Namen einer mitgelieferten, nur gültige Texte', () {
      final api = RpnApi();
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
      final api = RpnApi()..eingabe('{2*}\':dbl_{{"hilfe":[{"kennung":"dbl","titel":"Doppelt {x}"}]}}rpnjson');
      final text = api.exportiereBibliothek("meine", version: "1.2.0").text;
      expect(text.split("\n").first, "{");
      expect(text, contains(r"Doppelt \u007bx\u007d"), reason: "Klammern im Text maskiert");
      final neu = RpnApi();
      expect(neu.bibliothekHinzufuegen("meine", text), isNull);
      expect(neu.ladeBibliothek("meine"), isNull);
      expect(neu.eingabe("4dbl").fehler, isNull);
      expect(neu.hilfe("dbl")!.titel, "Doppelt {x}");
      expect(neu.bibliotheksVersion("meine")!["bibliothek"], "1.2.0");
    });

    test('eine Session schreibt eigene Hilfen mit', () {
      final api = RpnApi()..eingabe('{2*}\':dbl_{{"hilfe":[{"kennung":"dbl","titel":"Doppelt"}]}}rpnjson');
      final neu = RpnApi();
      expect(neu.importieren(api.exportieren().text), isNull);
      expect(neu.hilfe("dbl")!.titel, "Doppelt");
    });

    test('JSON für einen Block: Klammern nur in Texten maskiert', () {
      expect(jsonFuerBlock({"a": "{x}", "b": [1]}), r'{"a":"\u007bx\u007d","b":[1]}');
      expect(jsonFuerBlock({"a": r'say "{"'}), r'{"a":"say \"\u007b\""}');
    });
  });
}
