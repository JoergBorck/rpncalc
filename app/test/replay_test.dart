import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AxisDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc_app/keys.dart';
import 'package:rpncalc_app/model/model.dart';
import 'package:rpncalc_app/model/protocol.dart';

import 'protocol_replay.dart';

/// Tastenprotokoll aufnehmen und abspielen (process/requirements/PA-1.md).
///
/// Ein Protokoll aus einer Fehlermeldung abspielen:
///   flutter test test/replay_test.dart --dart-define=RPN_ABSPIELEN=../process/testing/logs/protokoll.txt
/// Protokolle unter test/protocols/*.txt laufen bei jedem Testlauf als Regressionstests.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  String? ablage;
  setUp(() {
    ablage = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform,
        (aufruf) async {
      if (aufruf.method == "Clipboard.setData") ablage = (aufruf.arguments as Map)["text"] as String?;
      if (aufruf.method == "Clipboard.getData") return ablage == null ? null : {"text": ablage};
      return null;
    });
  });

  RechnerModell neu() => RechnerModell()
    ..protokoll = Protokoll()
    ..zeichenProZeile = 20
    ..platzEingabe = List.filled(6, 20)
    ..platzStack = List.filled(6, 20);
  Taste taste(String text) => [...obereTasten, ...untereTasten].expand((r) => r).firstWhere((t) => t.text == text);

  test('eine Zeile je Bedienung, mit Zustand danach', () {
    final m = neu();
    for (final t in ["3", "ENTER", "4", "+"]) {
      m.druecke(taste(t));
    }
    final zeilen = m.protokoll.text.split("\n");
    expect(zeilen, hasLength(4));
    final letzte = Protokoll.zerlege(zeilen.last)!;
    expect(letzte.art, "taste");
    expect(letzte.felder.first, "+");
    expect(letzte.zustand["stack"], "7");
    expect(letzte.zustand["zeile"], "3 4+");
  });

  test('Bedienungen, die andere aufrufen, stehen nur einmal da', () {
    final m = neu();
    m.tippeZeichen("5");
    m.tastaturLoeschen(); // ruft intern druecke(⌫)
    expect(m.protokoll.text.split("\n").map((z) => Protokoll.zerlege(z)!.art), ["zeichen", "loeschen"]);
  });

  test('der Speicher hält höchstens 1000 Zeilen', () {
    final p = Protokoll();
    for (var i = 0; i < 1005; i++) {
      p.bedienung("zeichen", ["1"], const {});
    }
    expect(p.anzahl, Protokoll.maxZeilen);
    expect(p.text.split("\n").first, startsWith("6\t"));
  });

  test('Ausnahmen mit Stacktrace', () {
    final p = Protokoll();
    p.ausnahme(StateError("kaputt"), StackTrace.current);
    final e = Protokoll.zerlege(p.text)!;
    expect(e.art, "ausnahme");
    expect(e.felder.first, contains("kaputt"));
    expect(e.felder[1], contains("replay_test.dart"));
  });

  test('mit Datei: beim Start neu, jede Zeile sofort angehängt', () {
    final ordner = Directory.systemTemp.createTempSync("rpn_protokoll");
    final pfad = "${ordner.path}/unter/protokoll.txt"; // der Ordner entsteht erst
    File(pfad)
      ..createSync(recursive: true)
      ..writeAsStringSync("alt\n");
    final p = Protokoll(datei: pfad);
    p.bedienung("zeichen", ["1"], const {"zeile": "1"});
    p.bedienung("zeichen", ["2"], const {"zeile": "12"});
    expect(File(pfad).readAsStringSync(), "${p.text}\n");
    expect(p.dateiPfad, isNotNull);
    ordner.deleteSync(recursive: true);
  });

  test('Protokoll kopieren legt den Text in die Zwischenablage', () async {
    final m = neu();
    m.tippeZeichen("7");
    await m.kopiereProtokoll();
    expect(ablage, m.protokoll.text);
  });

  test('aufnehmen und abspielen ergibt denselben Zustand', () {
    final m = neu();
    for (final t in ["3", "ENTER", "4", "+", "~", "⌫"]) {
      m.druecke(taste(t));
    }
    for (final c in "12 5/".split("")) {
      m.tippeZeichen(c);
    }
    m.tastaturReturn();
    m.fuegeTextEin("1;2;3", werte: true);
    m.tastaturTab();
    m.pfeil(AxisDirection.down);
    m.tippeBereichMit(Bereich.stack, doppelt: true); // maximiert
    m.schiebeZeilen(Bereich.stack, 1);
    m.tastaturHilfe();
    m.tastaturEsc();
    m.tippeZeichen("x");
    m.tastaturZeilenumbruch();
    m.tippeZeichen("D");
    final text = m.protokoll.text;
    expect(abspielen(neu(), text), isEmpty);
  });

  test('Abweichungen werden mit Zeile und Feld gemeldet', () {
    final m = neu();
    m.tippeZeichen("3");
    final verfaelscht = m.protokoll.text.replaceFirst("zeile=3", "zeile=4");
    expect(abspielen(neu(), verfaelscht), [contains("zeile erwartet „4“, ist „3“")]);
  });

  final ordner = Directory("test/protocols");
  for (final datei in ordner.existsSync() ? ordner.listSync().whereType<File>().where((f) => f.path.endsWith(".txt")) : <File>[]) {
    test('Regression ${datei.uri.pathSegments.last}', () {
      expect(abspielen(neu(), datei.readAsStringSync()), isEmpty);
    });
  }

  const vonHand = String.fromEnvironment("RPN_ABSPIELEN");
  if (vonHand.isNotEmpty) {
    test('abspielen: $vonHand', () {
      final abweichungen = abspielen(neu(), File(vonHand).readAsStringSync());
      for (final a in abweichungen) {
        printOnFailure(a);
      }
      expect(abweichungen, isEmpty);
    });
  }
}
