import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc_app/colors.dart';
import 'package:rpncalc_app/main.dart';
import 'package:rpncalc_app/model/model.dart';
import 'package:rpncalc_app/keys.dart';

/// Kontextmenü und Zwischenablage (doc/app.md 2.1).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RechnerModell m;
  String? ablage; // die simulierte Zwischenablage

  setUp(() {
    m = RechnerModell()..zeichenProZeile = 40;
    ablage = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform,
        (aufruf) async {
      if (aufruf.method == "Clipboard.setData") ablage = (aufruf.arguments as Map)["text"] as String?;
      if (aufruf.method == "Clipboard.getData") return ablage == null ? null : {"text": ablage};
      return null;
    });
  });

  Taste taste(String text) => [...obereTasten, ...untereTasten].expand((r) => r).firstWhere((t) => t.text == text);
  void tippe(String zeichen) {
    for (final c in zeichen.split("")) {
      m.tippeZeichen(c);
    }
  }
  List<num> stack() => [for (final s in m.zustand.stack) s.wert];

  test('Werte: x, ab der angeklickten Zeile, ganzer Stack; ein offenes Token wird vorher abgeschlossen', () {
    tippe("1 2 2.25"); // 2.25 ist noch offen und steht in Zeile 0, darunter x = 2, y = 1
    expect(m.kopierText(Kopie.wert, 0), "2,25", reason: "für ein deutsches Excel");
    expect(m.zustand.offen, isEmpty, reason: "das Token ist jetzt abgeschlossen");
    expect(m.kopierText(Kopie.wert, 1), "2");
    expect(m.kopierText(Kopie.stackAb, 1), "2;2,25", reason: "vom angeklickten Wert bis x, der tiefste zuerst");
    expect(m.kopierText(Kopie.stack), "1;2;2,25");
    expect(RechnerModell().kopierText(Kopie.stack), isNull, reason: "leerer Stack");
  });

  test('Zeilen: die angeklickte, ab hier bis zur aktuellen, der ganze Verlauf', () {
    tippe("1 2+");
    m.tastaturZeilenumbruch();
    tippe("3 4*");
    m.tastaturZeilenumbruch();
    tippe("5");
    expect(m.kopierText(Kopie.zeile, 0), "5");
    expect(m.kopierText(Kopie.zeile, 1), "3 4*");
    expect(m.kopierText(Kopie.zeilenAb, 1), "3 4*\n5", reason: "die älteste zuerst");
    expect(m.kopierText(Kopie.verlauf), "1 2+\n3 4*\n5");
  });

  test('kopieren schreibt in die Zwischenablage und meldet es', () async {
    tippe("1.5");
    await m.kopiere(Kopie.wert);
    expect(ablage, "1,5");
    expect(m.meldung.value, "Kopiert: 1,5");
    tippe(" 2 3_");
    await m.kopiere(Kopie.stack);
    expect(m.meldung.value, "3 Werte kopiert", reason: "mehrere Werte: die Anzahl statt der Liste");
  });

  test('Werte einfügen: alle Zahlen aus dem Text, die letzte wird x; nichts wird ausgeführt', () async {
    ablage = "Länge;1,5\nBreite;2\tFaktor 3e2 +";
    await m.fuegeEin(werte: true);
    expect(stack(), [300, 2, 1.5]);
    expect(m.meldung.value, "3 Zahlen eingefügt");
  });

  test('lehnt der Browser das Lesen ab, meldet es sich, statt still nichts zu tun (BA-4)', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform,
        (aufruf) async => aufruf.method == "Clipboard.getData" ? throw PlatformException(code: "paste_fail") : null);
    await m.fuegeEin(werte: true, nachMenue: true);
    expect(m.meldung.value, "Die Zwischenablage lässt sich nicht lesen");
  });

  test('Text einfügen: Zeichen für Zeichen, als wäre er getippt', () async {
    ablage = "3 4+\r\n2*";
    await m.fuegeEin(werte: false);
    expect(stack(), [14]);
  });

  test('Text einfügen: nur Zahlen (aus dem Stack, aus Excel) so, wie man sie tippen würde (VA-12)', () async {
    ablage = "1,5;-2;3E-20";
    await m.fuegeEin(werte: false);
    expect(m.zeile, "1.5 ~2 3ê~20", reason: "Leerzeichen statt ;");
    expect(m.zustand.fehler, isNull);
    tippe("_");
    expect(stack().sublist(1), [-2, 1.5], reason: "Tos zuerst");
    expect(stack().first, closeTo(3e-20, 1e-30));
  });

  test(r'\c, \s und \v wie in der Konsole; das \ wartet, ⌫ nimmt es zurück', () async {
    tippe("1 2 3_");
    tippe(r"\");
    expect(m.eingabeText(0).endsWith(r"\"), isTrue, reason: "das wartende \\ ist zu sehen");
    tippe("s");
    await pumpEventQueue();
    expect(ablage, "1;2;3");
    expect(m.eingabeText(0).endsWith(r"\"), isFalse);
    tippe(r"\");
    m.druecke(taste("⌫"));
    expect(m.rueckstrich, isFalse);
    expect(stack(), [3, 2, 1], reason: "⌫ hat nur das \\ zurückgenommen");
    ablage = "7";
    tippe(r"\v");
    await pumpEventQueue();
    expect(stack().first, 7);
  });

  testWidgets('Rechtsklick in den Stack öffnet das Kontextmenü, Kopieren meldet sich unten', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    for (final t in ["4", "2"]) {
      await tester.tap(find.text(t).last);
      await tester.pump();
    }
    // auf den offenen Wert in der Stackspalte (rechts von der Eingabe, in der er auch steht)
    final wert = find.textContaining("42").evaluate().map((e) => tester.getCenter(find.byWidget(e.widget))).reduce(
          (a, b) => a.dx > b.dx ? a : b,
        );
    await tester.tapAt(wert, buttons: kSecondaryMouseButton);
    await tester.pumpAndSettle();
    expect(find.text("Werte einfügen"), findsOneWidget);
    expect(find.text("Zeile kopieren"), findsNothing, reason: "das gehört zur Eingabe");
    await tester.tap(find.text("Wert kopieren"));
    await tester.pumpAndSettle();
    expect(ablage, "42");
    expect(find.text("Kopiert: 42"), findsOneWidget);
  });

  testWidgets('langes Drücken in der Eingabe öffnet das Kontextmenü, Hilfe öffnet den Lese-Modus', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    await tester.longPressAt(const Offset(60, 120)); // in die Eingabespalte
    await tester.pumpAndSettle();
    expect(find.text("Zeile kopieren"), findsOneWidget);
    expect(find.text("Text einfügen"), findsOneWidget);
    await tester.tap(find.text("Hilfe"));
    await tester.pumpAndSettle();
    expect(find.text("Anzeige: Eingabe"), findsOneWidget);
    expect(find.text("HILFE · LESEN"), findsOneWidget);
  });

  testWidgets('die Zeile ist markiert, solange das Menü offen ist; ohne Wert ist Kopieren ausgegraut', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    final markiert = find.byWidgetPredicate((w) => w is ColoredBox && w.color == Farben.kontextZeile);
    expect(markiert, findsNothing);
    await tester.tapAt(const Offset(340, 160), buttons: kSecondaryMouseButton); // leerer Stack
    await tester.pumpAndSettle();
    expect(markiert, findsOneWidget);
    bool an(String text) => tester.widget<PopupMenuItem<void>>(find.widgetWithText(PopupMenuItem<void>, text)).enabled;
    expect([an("Wert kopieren"), an("Ganzen Stack kopieren"), an("Werte einfügen")], [false, false, true]);
    await tester.tapAt(const Offset(20, 20)); // daneben schließt das Menü
    await tester.pumpAndSettle();
    expect(markiert, findsNothing);
  });
}
