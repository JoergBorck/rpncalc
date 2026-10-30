import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc_app/main.dart';
import 'package:rpncalc_app/modell.dart';
import 'package:rpncalc_app/tasten.dart';

/// Bedienung mit einer echten Tastatur (doc/app.md Kapitel 6).
void main() {
  late RechnerModell m;
  setUp(() => m = RechnerModell());
  tearDown(() => m.dispose());

  void tippe(String text) {
    for (final c in text.split("")) {
      m.tippeZeichen(c); // die Leertaste ist ENTER
    }
  }

  Taste taste(String text) => [...obereTasten, ...untereTasten].expand((r) => r).firstWhere((t) => t.text == text);
  Taste fn(String text) => m.funktionstasten.firstWhere((t) => t?.text == text)!;

  test('Zeichen gehen wie getippt an den Rechner, ohne Automatik für Namen', () {
    tippe("3 4+");
    expect(m.zustand.stack.single.wert, 7);
    tippe("pisin");
    expect(m.zustand.offen, "pisin", reason: "wer tippt, setzt _ selbst; pisin ist ein Name");
  });

  test('Return bricht die Zeile um, _ wird direkt getippt, Backspace löscht', () {
    tippe("1_2");
    expect(m.zeile, "1_2");
    m.tastaturLoeschen();
    expect(m.zeile, "1_");
    tippe("2");
    m.tastaturReturn();
    expect([m.verlauf.single.text, m.zeile], ["1_2 ", ""], reason: "Enter: Leerzeichen, dann Zeilenumbruch");
  });

  test('Enter wie beim HP: das Enter bleibt vorgemerkt, das nächste Token entscheidet', () {
    tippe("5");
    m.tastaturReturn();
    tippe("+");
    expect(m.zustand.stack.single.wert, 10, reason: "5 Enter + verdoppelt");
    final n = RechnerModell();
    addTearDown(n.dispose);
    n.tippeZeichen("5");
    n.tastaturReturn();
    for (final c in "3+".split("")) {
      n.tippeZeichen(c);
    }
    expect(n.zustand.stack.single.wert, 8, reason: "5 Enter 3 +: die 3 ersetzt die Kopie");
  });

  test('ein Präfix behält seinen Rahmen, solange sein Token offen ist', () {
    tippe("30~");
    expect(m.tilde, isTrue);
    tippe("si");
    expect(m.tilde, isTrue, reason: "~sin ist noch nicht fertig");
    tippe("n ");
    expect(m.tilde, isFalse);
    tippe("~3");
    expect(m.tilde, isFalse, reason: "eine negative Zahl ist kein Präfix für die Tasten");
  });

  test('Buchstaben ändern den Alpha-Zustand nicht', () {
    tippe("2 sin");
    expect(m.alpha, isFalse);
    m.druecke(const Taste("ALPHA", aktion: Aktion.alpha));
    tippe("7");
    expect(m.alpha, isTrue);
  });

  test('Tab, F1 und Esc', () {
    m.tastaturTab();
    expect(m.bereich, Bereich.stack);
    m.tastaturTab(rueckwaerts: true);
    expect(m.bereich, Bereich.eingabe);
    m.tastaturHilfe();
    expect(m.hilfeModus, isTrue);
    tippe("!");
    expect(m.hilfeSeite!.first.kennung, "!", reason: "im Hilfe-Modus zeigt eine Taste ihre Hilfe");
    expect(m.zeile, "", reason: "eingegeben wird nichts");
    m.tastaturEsc();
    expect([m.hilfeModus, m.hilfeSeite], [true, null], reason: "erstes Esc schließt den Schirm");
    m.tastaturEsc();
    expect(m.hilfeModus, isFalse, reason: "zweites Esc beendet die Hilfe");
  });

  test('Aufleuchten: Buchstaben auf ihrer Taste, ein fertiger Name auf seiner Funktionstaste', () {
    expect(m.tasteFuer("/")!.text, "÷");
    expect(m.tasteFuer("²")!.text, "x²");
    expect(m.tasteFuer(" ")!.text, "ENTER");
    expect(m.tasteFuer("<"), isNull, reason: "für < gibt es keinen Knopf");
    tippe("3 30s");
    expect(m.leuchtetBuchstabe("s"), isTrue);
    expect(m.leuchtetTaste(fn("sin")), isFalse, reason: "sin ist noch nicht fertig");
    tippe("in*");
    expect(m.leuchtetTaste(fn("sin")), isTrue, reason: "beim * ist sin fertig");
    expect(m.leuchtetTaste(taste("×")), isTrue, reason: "beide leuchten gleichzeitig");
    tippe("K");
    expect([m.leuchtetBuchstabe("k"), m.getippterBuchstabe("k")], [true, "K"], reason: "groß, wie getippt");
    tippe("D");
    expect(m.leuchtetTaste(taste("D")), isTrue, reason: "D ist ein Befehl mit eigener Taste");
    expect(m.leuchtetBuchstabe("d"), isFalse);
  });

  testWidgets('echte Tastendrücke in der Oberfläche', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3, character: "3");
    await tester.sendKeyEvent(LogicalKeyboardKey.space, character: " ");
    await tester.sendKeyEvent(LogicalKeyboardKey.digit4, character: "4");
    await tester.sendKeyEvent(LogicalKeyboardKey.numpadAdd, character: "+");
    await tester.pump(const Duration(milliseconds: 700)); // Aufleuchten vorbei
    expect(find.text("7"), findsWidgets);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD, character: "d");
    await tester.pump();
    // groß beschriftet (nicht der kleine Hinweis rechts unten und nicht die Eingabezeile)
    final grossesD = find.byWidgetPredicate((w) => w is Text && w.data == "d" && w.style?.fontSize == 16);
    expect(grossesD, findsOneWidget, reason: "die Taste D zeigt beim Aufleuchten ihren Buchstaben");
    await tester.pump(const Duration(milliseconds: 300));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.text("Stack"), findsOneWidget, reason: "Tab wählt den Stack");
    expect(tester.takeException(), isNull);
  });
}
