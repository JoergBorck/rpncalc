import 'dart:convert';

import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// Hilfe im Rechner, siehe doc/api.md Kapitel 8.
void main() {
  final api = RpnApi();

  test('Vollständigkeit: jeder Operator, jede Funktion und jeder Stackbefehl hat eine Hilfe', () {
    final fehlt = <String>[];
    for (final token in [...api.calculator.operatoren.keys, ...api.calculator.funktionen.keys, ...api.calculator.befehle.keys]) {
      final h = api.hilfe(token);
      // Kontrollstrukturen stehen mit ihrem Block da: {dann}if, n:{code}times
      bool passt(Verwendung v) => v.schreibweise == token || v.schreibweise.endsWith("}$token");
      if (h == null || !h.verwendungen.any(passt)) fehlt.add(token);
    }
    expect(fehlt, isEmpty, reason: "ohne Hilfe bzw. ohne eigene Verwendung");
    for (final praefix in ["~", "|", "'", ":"]) {
      expect(api.hilfe(praefix), isNotNull, reason: praefix);
    }
  });

  test('jeder Verweis hat ein Ziel, und von der Startseite ist alles erreichbar', () {
    final erreicht = <String>{};
    final offen = ["#"];
    while (offen.isNotEmpty) {
      final k = offen.removeLast();
      if (!erreicht.add(k)) continue;
      final h = api.hilfe(k);
      expect(h, isNotNull, reason: "Verweis auf $k");
      offen.addAll(h!.verweise);
    }
    for (final k in api.hilfeKennungen()) {
      expect(api.hilfe(k)!.titel, isNotEmpty, reason: k);
      expect(erreicht.contains(k), isTrue, reason: "$k ist von der Startseite aus nicht erreichbar");
    }
  });

  test('ein Zeichen mit mehreren Bedeutungen: ! ist Fakultät, Variable und Konstante', () {
    final h = api.hilfe("!")!;
    expect([for (final v in h.verwendungen) v.schreibweise], ["!", "'!x", "'!!x"]);
    expect(h.verwendungen.first.stack, "x → x!");
    expect(h.verweise, contains("#variablen"));
  });

  test('Schreibweisen und Aliase führen zum Eintrag', () {
    expect(api.hilfe("~²")!.kennung, "²");
    expect(api.hilfe("asin")!.kennung, "sin");
    expect(api.hilfe("}")!.kennung, "{");
    expect(api.hilfe("'C")!.kennung, "C");
    expect(api.hilfe("gibtsnicht"), isNull);
  });

  test('Startseite und Übersicht', () {
    expect(api.hilfe("#")!.verweise, containsAll(["#stack", "#alle"]));
    final alle = api.hilfe("#alle")!;
    expect(alle.verweise, containsAll(["!", "sin", "S", "#tags"]));
  });

  test('eigene Namen: Funktion, Variable, Konstante und Tag mit ihrem Inhalt', () {
    final a = RpnApi()..eingabe("{1+}':inc_7'!a_9.81'!!g_1 2 3 3:'!v_5'|t");
    expect(a.hilfe("inc")!.text, contains("{1+}"));
    expect(a.hilfe("inc")!.verweise, ["#funktionen"]);
    expect(a.hilfe("a")!.titel, "Variable a");
    expect(a.hilfe("a")!.text, contains("Inhalt: 7"));
    expect(a.hilfe("g")!.titel, "Konstante g");
    expect([for (final v in a.hilfe("g")!.verwendungen) v.schreibweise], isNot(contains("'=g")), reason: "nur lesen");
    expect(a.hilfe("v")!.text, contains("Inhalt: 3 2 1"), reason: "Element 0 ist der Tos, ohne [ ]");
    expect(a.hilfe("t")!.titel, "Tag t");
    expect(a.hilfe("t")!.verweise, ["#tags"]);
    expect(a.hilfe("sin")!.titel, "Sinus", reason: "eingebaute Namen gehen vor");
  });

  test('Hilfe verändert den Rechner nicht', () {
    final a = RpnApi()..eingabe("1 2");
    final vorher = jsonEncode(a.zustand().toJson());
    a.hilfe("!");
    a.hilfe("#alle");
    expect(jsonEncode(a.zustand().toJson()), vorher);
  });

  test('JSON hin und zurück', () {
    final h = api.hilfe("%")!;
    final zurueck = Hilfe.fromJson(jsonDecode(jsonEncode(h.toJson())) as Map<String, Object?>);
    expect(jsonEncode(zurueck.toJson()), jsonEncode(h.toJson()));
    expect(zurueck.verwendungen.length, 4);
  });

  test('Verweise im Text ersetzen', () {
    final h = api.hilfe("#enter")!;
    final text = h.textMit((k) => api.hilfe(k)!.titel);
    expect(text, contains("Trenner"));
    expect(text, isNot(contains("[[")));
  });
}
