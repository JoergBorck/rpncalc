import 'dart:async';
import 'dart:convert';

import 'package:rpncalc/src/net/client.dart';
import 'package:rpncalc/src/console/screen.dart';
import 'package:rpncalc/src/net/protocol.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc/src/net/server.dart';
import 'package:test/test.dart';

import 'internals.dart';

/// Protokoll zwischen Client und Server, siehe doc/api.md 6.1.
void main() {
  group('Nachrichten ohne Netz', () {
    late RpnApi api;
    setUp(() => api = apiMitEinblick());

    Map<String, Object?> antwort(String zeile) => jsonDecode(beantworte(api, zeile).zeile!) as Map<String, Object?>;
    num tos(Map<String, Object?> a) => ((a["zustand"] as Map)["stack"] as List).first["wert"] as num;

    test('Tasten, Zeilenende und Löschen wie bei der API', () {
      for (final c in "3 4".split("")) {
        antwort(Nachricht.taste(c));
      }
      antwort(Nachricht.loeschen());
      antwort(Nachricht.taste("5+"));
      expect(tos(antwort(Nachricht.zeilenende())), 8);
      expect(tos(antwort(Nachricht.eingabe("2*"))), 16);
      expect(tos(antwort(Nachricht.zustandAbfragen())), 16);
    });

    test('zeilen begrenzt den Stack im Zustand', () {
      api.eingabe("1 2 3 4 5");
      final stack = (antwort(Nachricht.zustandAbfragen(zeilen: 2))["zustand"] as Map)["stack"] as List;
      expect(stack.length, 2);
    });

    test('Hilfe abfragen: der Eintrag oder null, der Rechner bleibt unverändert (doc/api.md 8.2)', () {
      api.eingabe("7 8");
      final h = antwort(Nachricht.hilfeAbfragen("!"))["hilfe"] as Map<String, Object?>;
      expect(Hilfe.fromJson(h).verwendungen.length, 3);
      expect(antwort(Nachricht.hilfeAbfragen("gibtsnicht")), {"hilfe": null});
      expect(tos(antwort(Nachricht.zustandAbfragen())), 8);
    });

    test('Bibliotheken abfragen und laden (doc/api.md 9.1)', () {
      final liste = antwort(Nachricht.bibliothekenAbfragen())["bibliotheken"] as List;
      expect(liste.first, {"name": "schwingungen", "mitgeliefert": true});
      final z = antwort(Nachricht.ladeBibliothek("statistik"))["zustand"] as Map;
      expect([for (final s in z["speicher"] as List) s["name"]], contains("mean"));
      expect(antwort(Nachricht.ladeBibliothek("gibtsnicht")).keys, ["protokollfehler"]);
    });

    test('Rechenfehler stehen im Zustand, nicht im Protokoll', () {
      final a = antwort(Nachricht.eingabe("1q"));
      expect((a["zustand"] as Map)["fehler"], isNotNull);
    });

    test('ungültige Nachrichten sind Protokollfehler und ändern nichts', () {
      api.eingabe("7");
      for (final zeile in ['kein json', '[1,2]', '{"taste":"1","loeschen":true}', '{"foo":1}', '{"taste":5}', '{}']) {
        expect(antwort(zeile).keys, ["protokollfehler"], reason: zeile);
      }
      expect(api.calculator.stack[0], 7);
      expect(api.zustand().tiefe, 1);
    });

    test('stopp hat keine Antwortzeile', () {
      final a = beantworte(api, Nachricht.stopp());
      expect(a.stopp, isTrue);
      expect(a.zeile, isNull);
    });
  });

  test('TastenStrom: Bytes der Reihe nach, nach dem Abbruch -1', () async {
    final tasten = StreamController<List<int>>();
    final abbruch = Completer<void>();
    final strom = TastenStrom(tasten.stream, abbruch: abbruch.future);
    expect(tasten.hasListener, isFalse); // erst beim ersten Lesen, wenn der Rohmodus an ist
    tasten.add([65, 66]);
    expect(await strom.naechstes(), 65);
    expect(await strom.naechstes(), 66);
    final wartet = strom.naechstes(); // noch keine Taste da
    abbruch.complete();               // z.B. {"ende":…} vom Server
    expect(await wartet, -1);
    expect(await strom.naechstes(), -1);
    await tasten.close();
  });

  group('Server und Client über den Socket', () {
    const port = 4041;
    late Future<void> server;

    setUp(() async {
      server = starteMultiClientSocketInterface(port: port, leise: true);
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() async {
      await stoppeMultiClientSocketInterface();
      await server;
    });

    test('jeder Client hat seinen eigenen Rechner', () async {
      final a = await EntfernterRechner.verbinden("127.0.0.1", port);
      final b = await EntfernterRechner.verbinden("127.0.0.1", port);
      for (final c in "3 4+".split("")) {
        await a.taste(c);
      }
      expect((await a.zeilenende()).stack.first.wert, 7);
      expect((await b.eingabe("10")).stack.first.wert, 10);
      expect((await a.zustand()).tiefe, 1);
      await a.schliessen();
      await b.schliessen();
    });

    test('stopp beendet den Server, alle Clients bekommen ende', () async {
      final a = await EntfernterRechner.verbinden("127.0.0.1", port);
      final b = await EntfernterRechner.verbinden("127.0.0.1", port);
      a.stopp();
      expect(await b.ende.future, contains("Server wird beendet"));
      expect(await a.ende.future, contains("Server wird beendet"));
      await server;
      expect(laufenderServerSocket, isNull);
    });
  });
}
