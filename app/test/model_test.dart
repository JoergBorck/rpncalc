import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc_app/display/display.dart';
import 'package:rpncalc_app/help_texts.dart';
import 'package:rpncalc_app/colors.dart';
import 'package:rpncalc_app/main.dart';
import 'package:rpncalc_app/model/model.dart';
import 'package:rpncalc_app/tooltip.dart';
import 'package:rpncalc_app/keys.dart';
import 'package:rpncalc_app/keypad/function_block.dart';
import 'package:rpncalc_app/keypad/keypad.dart';

/// Verhalten der Oberfläche über dem Rechner, siehe doc/app.md.
void main() {
  late RechnerModell m;
  setUp(() => m = RechnerModell()..zeichenProZeile = 20);

  Taste taste(String text) => [...obereTasten, ...untereTasten].expand((r) => r).firstWhere((t) => t.text == text);
  Taste fn(String text) => domaenen.values.expand((l) => l).firstWhere((t) => t?.text == text)!;
  void tippe(List<String> tasten) {
    for (final t in tasten) {
      m.druecke(switch (t) { "SHIFT" => const Taste("SHIFT", aktion: Aktion.shift),
                             "ALPHA" => const Taste("ALPHA", aktion: Aktion.alpha),
                             "TAB" => const Taste("TAB", aktion: Aktion.tab),
                             _ => taste(t) });
    }
  }
  List<num> stack() => [for (final s in m.zustand.stack) s.wert];

  test('Ziffern, ENTER und Operatoren', () {
    tippe(["3", "ENTER", "4", "+"]);
    expect(stack(), [7]);
    expect(m.zeile, "3 4+");
  });

  test('Präfix ~ schaltet die Beschriftung um und schreibt vor die Taste', () {
    tippe(["9"]);
    m.druecke(taste("~"));
    expect(m.tilde, isTrue);
    expect(m.beschriftung(taste("x²")).text, "√x");
    expect(m.beschriftung(taste("D")).gedimmt, isFalse, reason: "D bleibt bedienbar, ~ wirkt dann allein");
    tippe(["x²"]);
    expect(stack(), [3]);
    expect(m.tilde, isFalse);
    expect(m.zeile, "9~²");
  });

  test('Vergleiche auf Shift der Rechenspalte, ~ kehrt auch die Shift-Funktion um (doc/app.md 3.1)', () {
    tippe(["3", "ENTER", "3", "SHIFT", "+"]);
    expect(m.zeile, "3 3=");
    expect(stack(), [1]);
    tippe(["ENTER", "2"]);
    m.druecke(taste("~"));
    expect(m.beschriftung(taste("+")).art, Beschriftungsart.normal, reason: "~+ hat keine Bedeutung");
    tippe(["SHIFT"]);
    expect([for (final t in ["÷", "×", "−", "+"]) m.beschriftung(taste(t)).text], ["≤", "oder", "≥", "≠"]);
    tippe(["+"]);
    expect(m.zeile.endsWith("2≠"), isTrue, reason: "die Taste schreibt das Zeichen statt ~=: ${m.zeile}");
    expect(stack().last, 1, reason: "1 ist ungleich 2");
    tippe(["SHIFT"]);
    expect([for (final t in ["÷", "×", "−"]) m.beschriftung(taste(t)).text], [">", "&", "<"]);
  });

  test('Präfix vor einer Taste ohne Wirkung: der Präfix wirkt allein, mit Trenner (doc/app.md 3.2)', () {
    for (final (tasten, zeile, grund) in [
      (["3", "~", "D"], "3~ D", "3~D wäre die Umkehrung von D"),
      (["2", "~", "+"], "2~ +", "~+ hat keine Bedeutung"),
      (["5", "ENTER", "~", "1"], "5 ~1", "~ vor einer Ziffer ist eine negative Zahl"),
      (["3", ".", "7", "|", "D"], "3.7| D", "| wirkt allein: Ganzzahl- und Nachkommateil"),
    ]) {
      m = RechnerModell()..zeichenProZeile = 20;
      tippe(tasten);
      expect(m.zeile, zeile, reason: grund);
      expect(m.zustand.fehler, isNull, reason: zeile);
    }
  });

  test('Hyperbelfunktionen auf Shift von sin cos tan, ~ Shift ist ihre Umkehrung (doc/reference.md 6.2)', () {
    tippe(["2", "SHIFT"]);
    m.druecke(fn("sin"));
    expect(m.zeile, "2sinh_");
    expect(stack().last, closeTo(3.626860407847019, 1e-14));
    tippe(["~", "SHIFT"]);
    expect(m.beschriftung(fn("sin")).text, "asinh");
    m.druecke(fn("sin"));
    expect(m.zeile.endsWith("~sinh_"), isTrue, reason: m.zeile);
    expect(stack().last, closeTo(2, 1e-12));
  });

  test('~ und | zusammen, || ist der Betrag', () {
    tippe(["2", "0", "0", "ENTER", "1", "5"]);
    m.druecke(taste("~"));
    m.druecke(taste("|"));
    expect(m.beschriftung(taste("%")).text, "~|%");
    expect(m.beschriftung(taste(":")).text, "~|:");
    m.druecke(RechnerModell().beschriftung(taste("%")).text == "%" ? taste("%") : taste("%"));
    expect(m.zeile, "200 15~|%");
    final b = RechnerModell();
    for (final t in ["3", "~"]) {
      b.druecke(taste(t));
    }
    b.druecke(taste("|")); // ~ zählt hier als Vorzeichen-Präfix, || folgt
    b.druecke(taste("|"));
    expect(b.zeile, "3~||");
  });

  test('Shift gilt für einen Tastendruck: Shift+ENTER ist der Trenner, Shift+⌫ ist C', () {
    tippe(["1", "SHIFT", "ENTER", "2"]);
    expect(m.shift, isFalse);
    expect(stack(), [1]);
    expect(m.zustand.offen, "2", reason: "die 2 ist noch offen, _ hat nur getrennt");
    tippe(["SHIFT", "⌫"]);
    expect(m.zustand.tiefe, 0);
  });

  test('Funktionsnamen werden getrennt und gleich ausgeführt', () {
    tippe(["9", "0"]);
    m.druecke(fn("sin"));
    expect(stack().single, 1);
    m.druecke(fn("π"));
    m.druecke(fn("ln"));
    expect(m.zeile, "90sin_pi_ln_", reason: "_ nur zwischen zwei Namen nötig, aber hinter jedem Namen");
    expect(stack().last, 1);
    m.druecke(taste("~"));
    expect(m.beschriftung(fn("cos")).text, "acos");
    m.druecke(fn("cos"));
    expect(m.verlauf.first.text, "90sin_pi_ln_~cos_", reason: "über 80 %, nach der Operation umgebrochen");
  });

  test('Alpha: Kleinbuchstaben bis ALPHA, ein Großbuchstabe mit SHIFT beendet Alpha (doc/app.md 7, Punkt 8)', () {
    tippe(["5", "'", "!", "ALPHA"]);
    expect(m.beschriftung(taste("( )")).text, "a");
    expect(m.beschriftung(taste("⌫")).text, "⌫", reason: "⌫ bleibt in Alpha");
    tippe(["( )", "[ ]"]);
    expect(m.alpha, isTrue);
    tippe(["ENTER"]); // ⏎ im Alpha-Modus: Zeilenende von Hand
    expect(m.verlauf.single.text, "5'!ab");
    expect(m.zustand.speicher.single.name, "ab");
    expect(m.alpha, isTrue, reason: "⏎ zählt wie ein Buchstabe");
    tippe(["ALPHA"]);
    expect(m.alpha, isFalse, reason: "ALPHA a b ALPHA");
    // ALPHA SHIFT J: ein Großbuchstabe, dann ist Alpha beendet
    tippe(["2", "ALPHA", "SHIFT"]);
    expect([m.alpha, m.gross], [true, true]);
    expect(m.beschriftung(taste("S")).text, "K", reason: "die Tasten zeigen Großbuchstaben");
    tippe(["D"]); // e
    expect([m.alpha, m.shift, m.zeile], [false, false, "2E"]);
    // Shift+ALPHA: ebenfalls ein Großbuchstabe
    tippe(["SHIFT", "ALPHA", "S"]);
    expect([m.alpha, m.zeile], [false, "2EK"]);
  });

  test('Shift im Alpha-Modus wirkt nur auf Buchstaben, ⌫ löscht zeichenweise und lässt Alpha an', () {
    tippe(["ALPHA", "SHIFT"]);
    expect(m.beschriftung(taste("⌫")).text, "⌫", reason: "nicht C");
    expect(m.beschriftung(taste("ENTER")).text, "⏎");
    expect(m.beschriftung(taste("D")).text, "E", reason: "Buchstaben groß");
    expect(m.beschriftung(taste("D")).gedimmt, isFalse);
    tippe(["SHIFT"]); // zurück zu Kleinbuchstaben
    tippe(["( )", "[ ]", "{ }"]); // abc
    tippe(["SHIFT", "⌫"]);
    expect([m.zeile, m.alpha, m.zustand.tiefe], ["ab", true, 0], reason: "⌫ statt C, Alpha bleibt an");
    tippe(["⌫", "( )"]);
    expect(m.zeile, "aa");
    tippe(["SHIFT", "ALPHA"]);
    expect([m.alpha, m.shift], [false, false], reason: "ALPHA beendet Alpha auch mit Shift");
  });

  test("' zeigt die Variablen auf den Funktionstasten", () {
    tippe(["7", "'", "!", "ALPHA", "( )", "7"]); // 7'!a, die zweite 7 beendet Alpha
    m.druecke(taste("'"));
    expect(m.seitenName, "Variablen");
    final a = m.funktionstasten.first!;
    expect(a.text, "a");
    m.druecke(a);
    expect(m.zeile, endsWith("'a_"));
    expect(stack().take(2), [7, 7]);
  });

  test('Umbruch ab 80 % nach einer Operation, nicht mitten in einer Zahl', () {
    tippe("1 ENTER 2 + 3 + 4 + 5 + 6 + 7".split(" ")); // "1 2+3+4+5+6+7" = 13 Zeichen
    expect(m.verlauf, isEmpty);
    tippe(["8", "8", "8", "8"]);
    expect(m.verlauf, isEmpty, reason: "eine Zahl bricht nicht um");
    tippe(["+"]);
    expect(m.verlauf.single.text, "1 2+3+4+5+6+78888+");
    expect(m.zeile, "");
    expect(stack(), [21 + 78888]);
  });

  test('Umbruch im Code beim Leerzeichen', () {
    tippe(["{ }"]);
    for (final c in "1 2 3 4 5 6 7 8 9 1".split("")) {
      tippe([c == " " ? "ENTER" : c]);
    }
    expect(m.verlauf.single.text, "{1 2 3 4 5 6 7 8 9", reason: "18 Zeichen, mehr als 80 % von 20");
    expect(m.zeile, "1");
    expect(m.zustand.codeOffen, isTrue);
  });

  test('Umbruch nach ENTER erst ab 90 %', () {
    tippe("1 ENTER 2 ENTER 3 ENTER 4 ENTER 5 ENTER 6 ENTER 7 ENTER 8 ENTER".split(" ")); // 16 Zeichen = 80 %
    expect(m.verlauf, isEmpty);
    tippe(["1", "0", "ENTER"]); // 19 Zeichen, mehr als 90 % von 20
    expect(m.verlauf.single.text, "1 2 3 4 5 6 7 8 10 ");
    tippe(["1"]);
    expect(m.zustand.tiefe, 9, reason: "die 1 ist noch offen");
  });

  test('Ausschnitt: abgeschnittene Enden als …, gleich lang wie der Platz', () {
    expect(RechnerModell.ausschnitt("12345", 0, 9), "12345");
    expect(RechnerModell.ausschnitt("123456789", 0, 5), "1234…");
    expect(RechnerModell.ausschnitt("123456789", 2, 5), "…456…");
    expect(RechnerModell.ausschnitt("123456789", 4, 5), "…6789");
    expect(RechnerModell.ausschnitt("123", 0, 0), "", reason: "kein Platz, z.B. bei maximiertem Stack");
  });

  test('◄ und ► schieben jede Zeile für sich, die aktuelle Zeile zeigt zuerst ihr Ende', () {
    m.platzEingabe = [5, 5];
    m.verlauf.add((text: "abcdefgh", fehler: null));
    tippe(["1", "2", "3", "4", "5", "6", "7"]);
    expect([m.eingabeVon(0), m.eingabeVon(1)], [2, 0]);
    expect(m.kannSchieben(true), isTrue, reason: "die alte Zeile hat rechts noch etwas");
    m.pfeil(AxisDirection.right);
    m.pfeil(AxisDirection.right);
    m.pfeil(AxisDirection.right);
    m.pfeil(AxisDirection.right);
    expect([m.eingabeVon(0), m.eingabeVon(1)], [2, 3], reason: "jede bis zu ihrem Ende");
    expect(m.kannSchieben(true), isFalse);
    m.pfeil(AxisDirection.left);
    expect([m.eingabeVon(0), m.eingabeVon(1)], [1, 2], reason: "nach links bewegen sich alle sofort");
    tippe(["8"]);
    expect(m.eingabeVon(0), 3, reason: "eine Eingabe zeigt wieder das Ende");
  });

  test('▲ und ▼ blättern in der Eingabe durch den Verlauf', () {
    m.platzEingabe = [20, 20, 20];
    for (final t in ["c", "b", "a"]) {
      m.verlauf.add((text: t, fehler: null)); // neueste zuerst: c, b, a
    }
    expect(m.eingabeText(1), "c");
    m.pfeil(AxisDirection.up);
    expect([m.eingabeText(1), m.eingabeText(2)], ["b", "a"]);
    m.pfeil(AxisDirection.up);
    expect(m.verlaufVersatz, 1, reason: "nicht weiter, als bis die älteste Zeile unten steht");
    m.pfeil(AxisDirection.down);
    expect(m.eingabeText(1), "c");
  });

  test('offenes Token grau über dem Tos, die Werte eine Zeile tiefer (doc/app.md Kapitel 2)', () {
    tippe(["1", "ENTER", "2", "2", "ENTER", "3", "3", "3"]);
    expect(m.offenesToken, "333");
    expect([m.stackText(0), m.stackText(1), m.stackText(2)], ["333", "22", "1"]);
    expect(m.stackZeile(1)!.position, 0, reason: "der Tos steht in der zweiten Zeile");
    tippe(["+"]);
    expect(m.offenesToken, isNull, reason: "ohne offenes Token keine Zeile, auch keine leere");
    expect(m.stackText(0), "355");
    tippe(["4", "ENTER"]);
    expect(m.offenesToken, isNull, reason: "ein vorgemerktes Enter allein ist kein offenes Token");
  });

  test('Maximieren: der gewählte Bereich bekommt die ganze Breite und bleibt es beim Wechsel (doc/app.md 3.5)', () {
    const maximieren = Taste("", aktion: Aktion.maximieren);
    expect(m.anteilEingabe, 0.5, reason: "normal je die Hälfte");
    m.druecke(maximieren);
    expect([m.maximiert, m.anteilEingabe], [true, 1.0], reason: "Eingabe maximiert");
    tippe(["TAB"]);
    expect(m.anteilEingabe, 0.0, reason: "nach Tab ist der Stack maximiert");
    tippe(["TAB"]); // Funktionen: dort wirkt die Taste nicht
    m.druecke(maximieren);
    expect(m.maximiert, isTrue);
    tippe(["SHIFT", "TAB"]);
    m.druecke(maximieren);
    expect([m.maximiert, m.anteilEingabe], [false, 0.5]);
  });

  test('Tab wechselt den Bereich, Shift+Tab rückwärts', () {
    tippe(["TAB"]);
    expect(m.bereich, Bereich.stack);
    tippe(["TAB", "TAB"]);
    expect(m.bereich, Bereich.variablen);
    tippe(["SHIFT", "TAB"]);
    expect(m.bereich, Bereich.funktionen);
  });

  testWidgets('die Oberfläche baut und rechnet', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    for (final t in ["3", "ENTER", "4", "+"]) {
      await tester.tap(find.text(t).first);
      await tester.pump();
    }
    expect(find.text("7"), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nach ~ tragen die Tasten, auf die es wirkt, einen dünnen Rand (doc/app.md 3.2)', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    BorderSide rand(String text) =>
        ((tester.widget<Material>(find.ancestor(of: find.text(text), matching: find.byType(Material)).first).shape
                as RoundedRectangleBorder)
            .side);
    expect(rand("x²"), BorderSide.none);
    // die Taste ~ selbst, nicht die kleinen ~ rechts oben auf anderen Tasten
    await tester.tap(find.byWidgetPredicate((w) => w is Material && w.color == Farben.tildeTaste));
    await tester.pump();
    expect([rand("√x").color, rand("√x").width], [Farben.tilde, 1], reason: "~ wirkt: dünner Rand in Teal");
    expect(rand("D"), BorderSide.none, reason: "D bleibt normal");
  });

  testWidgets('~ und | zeigen ihre Rechenfunktion, im Alpha-Modus nicht (doc/app.md 3.1)', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    final rechenfunktion =
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter.runtimeType.toString() == "_Rechenfunktion");
    expect(rechenfunktion, findsNWidgets(2), reason: "± auf ~, □|.□ auf |");
    await tester.tap(find.text("ALPHA"));
    await tester.pump();
    expect(rechenfunktion, findsNothing, reason: "im Alpha-Modus ausgeblendet wie die anderen kleinen Hinweise");
  });

  testWidgets('Wischen und Mausrad über den Funktionstasten blättern ihre Seiten (doc/app.md 3.3)', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    await tester.tap(find.text("MENÜ")); // Schwingungen hat drei Seiten
    await tester.pumpAndSettle();
    await tester.tap(find.text("schwingungen"));
    await tester.pumpAndSettle();
    expect(find.text("F: schwingungen 1/3"), findsOneWidget);
    final modell = tester.widget<Anzeige>(find.byType(Anzeige)).modell;
    int pfeile() => find.byIcon(Icons.arrow_left).evaluate().length + find.byIcon(Icons.arrow_right).evaluate().length;
    final vorher = pfeile(); // ohne gewählten Bereich Funktionen kein Rahmen (andere Pfeile gibt es woanders)
    final mitte = tester.getCenter(find.text("omega")); // auf anderen Seiten steht dort eine andere Taste
    await tester.flingFrom(mitte, const Offset(150, 0), 800); // nach rechts wischen: vorige Seite
    await tester.pumpAndSettle();
    expect(find.text("F: Grundfunktionen"), findsOneWidget, reason: "vor der Domäne stehen die Grundfunktionen");
    expect(pfeile(), vorher + 2, reason: "der Rahmen erscheint kurz, mehr als eine Seite: Pfeile am Rahmen");
    expect(find.text("Rechnen"), findsOneWidget, reason: "die Anzeige bleibt, der Bereich wird nicht gewählt");
    expect(find.text("Grundfunktionen"), findsOneWidget, reason: "der Name der Seite unten am Rahmen");
    final maus = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(maus.hover(mitte));
    Future<void> rad(int rasten, double dy) async {
      for (var i = 0; i < rasten; i++) {
        await tester.sendEventToBinding(maus.scroll(Offset(0, dy)));
        await tester.pump();
      }
    }
    await rad(3, -40);
    expect(find.text("F: Grundfunktionen"), findsOneWidget, reason: "das Mausrad hält an der ersten Seite an");
    await rad(1, 40);
    expect(find.text("F: Grundfunktionen"), findsOneWidget, reason: "eine Raste schiebt eine drittel Seite (VA-10)");
    await rad(1, 40);
    expect(find.text("F: schwingungen 1/3"), findsOneWidget, reason: "mehr als die Hälfte der nächsten Seite zu sehen");
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(modell.funktionsSeite, 1, reason: "noch keine halbe Sekunde Ruhe: noch nicht eingerastet (VA-13)");
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.text("F: schwingungen 1/3"), findsOneWidget, reason: "zwei Rasten und Ruhe: rastet auf ihr ein");
    await rad(1, 40);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text("F: schwingungen 2/3"), findsOneWidget, reason: "eine Raste und Ruhe: in Drehrichtung weiter (VA-13)");
    await rad(2, 40);
    await rad(1, -40);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text("F: schwingungen 2/3"), findsOneWidget, reason: "zuletzt nach oben gedreht: zurück");
    expect(find.text("Rechnen"), findsOneWidget);
    await tester.pump(const Duration(seconds: 2)); // Pause der Tooltips und Hinweis-Rahmen ablaufen lassen
    expect(pfeile(), vorher, reason: "der Rahmen verschwindet wieder");
  });

  testWidgets('Doppelklick in Eingabe oder Stack wechselt zwischen [ ] und [|] (doc/app.md 3.5)', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    Future<void> doppelklick(Offset o) async {
      await tester.tapAt(o);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(o);
      await tester.pumpAndSettle();
    }

    final stackNamen = find.text("y").evaluate().length; // y steht nur am Stack und auf der Taste −
    await doppelklick(const Offset(60, 120)); // in die Eingabe
    expect(find.text("y").evaluate().length, stackNamen - 1, reason: "Eingabe maximiert, der Stack ist weg");
    await doppelklick(const Offset(60, 120));
    expect(find.text("y").evaluate().length, stackNamen, reason: "wieder geteilt");
    await doppelklick(const Offset(340, 120)); // in den Stack
    expect(find.text("Eingabe"), findsNothing, reason: "Stack maximiert, die Eingabe ist weg");
    expect(find.text("Stack"), findsOneWidget);
  });

  testWidgets('Zoom:breiter vergrößert alles, höher nur die Anzeige, niedrig erst breitere Tasten (doc/app.md 1.1)', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    // der Zoom als Höhe des Tastenfelds (sie hängt nur vom Faktor ab), dazu die Größe der Anzeige
    Future<(double, Rect)> messe(Size fenster) async {
      tester.view.physicalSize = fenster;
      await tester.pumpWidget(const RpnApp());
      expect(tester.takeException(), isNull, reason: "kein Überlauf bei $fenster");
      return (tester.getRect(find.byType(Tastenfeld)).height / Tastenfeld.hoehe, tester.getRect(find.byType(Anzeige)));
    }

    final (f1, a1) = await messe(const Size(400, 860));
    expect([f1, a1.width], [closeTo(1, 0.001), closeTo(376, 0.5)]);
    final (f2, a2) = await messe(const Size(800, 1720));
    expect(f2, closeTo(2, 0.001), reason: "doppelt so breit: alles doppelt so groß");
    expect(a2.height, closeTo(2 * a1.height, 1));
    final (f3, a3) = await messe(const Size(400, 1200));
    expect(f3, closeTo(1, 0.001), reason: "höher: gleiche Größe");
    expect(a3.height, greaterThan(a1.height + 300), reason: "höher: mehr Anzeige");
    final (f4, _) = await messe(const Size(300, 860));
    expect(f4, closeTo(0.75, 0.001), reason: "schmaler als 400: kleiner");
    final (f5, a5) = await messe(const Size(1600, 860));
    expect(f5, lessThan(1.2), reason: "breit, aber niedrig: die Höhe begrenzt");
    expect(a5.width / f5, closeTo(1.5 * 400 - 24, 0.5), reason: "erst 50 % breitere Tasten, dann Rand");
    final (f6, a6) = await messe(const Size(500, 860));
    expect(a6.width, closeTo(500 - 24 * f6, 0.5), reason: "etwas zu niedrig: gedehnt, ohne Rand");
  });

  testWidgets('maximierter Stack und maximierte Eingabe lassen sich zeichnen, auch beim Tippen', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    final maximieren = find.byWidgetPredicate((w) => w is CustomPaint && w.painter.runtimeType.toString() == "_Layout");
    for (final t in ["TAB", "MAX", "1", "2", "ENTER", "3", "+", "SHIFT", "TAB", "4", "MAX"]) {
      await tester.tap(t == "MAX" ? maximieren : find.text(t).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: "nach $t");
    }
  });

  testWidgets('jede Umschaltung lässt sich zeichnen, auch zusammen', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    // ~ und | haben dann einen Rahmen, Alpha ändert alle Beschriftungen
    for (final t in ["ALPHA", "~", "|", "SHIFT", "TAB", "SHIFT", "'"]) {
      await tester.tap(find.text(t).first);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: "nach $t");
    }
  });

  testWidgets('Maus über den Funktionstasten: Hintergrund leicht orange, nur wenn das Mausrad blättert (VA-4)',
      (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    bool orange() => tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .any((b) => b.decoration is BoxDecoration && (b.decoration as BoxDecoration).color == Farben.funktionenMaus);
    expect(orange(), isFalse);
    final maus = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(maus.removePointer);
    await maus.addPointer(location: Offset.zero);
    await maus.moveTo(tester.getCenter(find.text("sin")));
    await tester.pump();
    expect(orange(), isTrue, reason: "Maus über sin");
    await tester.tap(find.text("'")); // die Tasten zeigen Variablen: das Mausrad blättert nicht
    await tester.pump();
    expect(orange(), isFalse, reason: "nach '");
    await tester.tap(find.text("⌫"));
    await tester.tap(find.text("ALPHA")); // die Tasten zeigen Buchstaben (BA-7)
    await tester.pump();
    expect(orange(), isFalse, reason: "im Alpha-Modus");
    await tester.tap(find.text("ALPHA"));
    await maus.moveTo(Offset.zero);
    await tester.pump();
    expect(orange(), isFalse, reason: "Maus weg");
    // ein Finger färbt nicht (Handy)
    final finger = await tester.startGesture(tester.getCenter(find.text("sin")), kind: PointerDeviceKind.touch);
    await tester.pump();
    expect(orange(), isFalse, reason: "Touch");
    await finger.up();
    await tester.pump(const Duration(seconds: 2)); // Tooltip-Sperre läuft ab
  });

  test('Wischen und Mausrad blättern nicht, solange die Funktionstasten etwas anderes zeigen (BA-7)', () {
    for (final (name, taste) in [
      ("Alpha", const Taste("ALPHA", aktion: Aktion.alpha)),
      ("'", const Taste("'", aktion: Aktion.apostroph)),
    ]) {
      final r = RechnerModell()..druecke(taste);
      addTearDown(r.dispose);
      final seite = r.funktionsSeite;
      r.zeigeFunktionsSeite(seite + 1); // so melden Wischen und Mausrad eine neue Seite (VA-10)
      expect(r.funktionsSeite, seite, reason: name);
      expect(r.funktionenHinweis, isFalse, reason: "$name: kein Rahmen");
    }
  });

  testWidgets('im Alpha-Modus haben die Funktionstasten keine eigene Farbe, belegt oder nicht (BA-8)', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    Color? farbe(String buchstabe) =>
        tester.widget<Material>(find.ancestor(of: find.text(buchstabe), matching: find.byType(Material)).first).color;
    await tester.tap(find.text("ALPHA"));
    await tester.pump();
    // f liegt auf einer belegten Funktionstaste (sin), k neben dem Block, l auf einer Funktionstaste
    expect({for (final b in ["f", "g", "l", "m", "k"]) b: farbe(b)}, {for (final b in ["f", "g", "l", "m", "k"]) b: Farben.taste});
  });

  testWidgets('Hilfe-Modus: Rahmen um die Funktionstasten, Mausrad blättert, Klick in den Rahmen zeigt die Hilfe zur Seite (FA-23)',
      (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    final api = RpnApi();
    String titel(String kennung) => api.hilfe(kennung)!.titel;
    await tester.tap(find.text("MENÜ"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("schwingungen"));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();
    expect(find.text("schwingungen 1/3"), findsOneWidget, reason: "der Rahmen mit Seitenname ist im Hilfe-Modus da");

    // Klick auf den Seitennamen: die Übersicht der Bibliothek
    await tester.tap(find.text("schwingungen 1/3"));
    await tester.pumpAndSettle();
    expect(find.text(titel("#schwingungen")), findsOneWidget, reason: "Seitenname");

    // Mausrad blättert: drei Rasten je Seite, am Anfang hält es an
    final maus = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(maus.hover(tester.getCenter(find.text("schwingungen 1/3")) - const Offset(0, 20)));
    Future<void> rad(int rasten, double dy) async {
      for (var i = 0; i < rasten; i++) {
        await tester.sendEventToBinding(maus.scroll(Offset(0, dy)));
        await tester.pump();
      }
    }
    await rad(3, 100);
    expect(find.text("schwingungen 2/3"), findsOneWidget, reason: "Mausrad nach unten");
    await rad(9, -100);
    expect(find.text("Grundfunktionen"), findsOneWidget, reason: "Mausrad nach oben bis zur ersten Seite");

    // Klick in die Lücke zwischen sin und cos: die Hilfe zur Seite
    Rect taste(String t) => tester.getRect(find.ancestor(of: find.text(t), matching: find.byType(Material)).first);
    final sin = taste("sin"), cos = taste("cos");
    await tester.tapAt(Offset((sin.right + cos.left) / 2, sin.center.dy));
    await tester.pumpAndSettle();
    expect(find.text(AppHilfe.eintraege["app:funktionen"]!.titel), findsOneWidget, reason: "Lücke im Rahmen (BA-9)");

    // ein Klick auf die Taste zeigt weiter ihre Hilfe
    await tester.tap(find.text("cos"));
    await tester.pumpAndSettle();
    expect(find.text(titel("cos")), findsWidgets, reason: "Taste cos");
    await tester.pump(const Duration(seconds: 2));
  });

  test('Hilfe zur Seite der Funktionstasten: Bibliothek, Eigene, sonst app:funktionen (FA-23, BA-9)', () {
    expect(m.seitenHilfe, "app:funktionen", reason: "Grundfunktionen (BA-9)");
    m.zustand = m.api.eingabe("{1+}':inc");
    m.funktionsSeite = m.funktionsSeiten - 1;
    expect([m.seitenName, m.seitenHilfe], ["Eigene", "#funktionen"], reason: "Eigene: das Thema des Rechners (BA-9)");
    m.waehleDomaene("schwingungen");
    expect(m.seitenHilfe, "#schwingungen");
    m.hilfeZurSeite();
    expect(m.hilfeSeite?.first.kennung, "#schwingungen");
  });

  test('Wischen und Mausrad in Eingabe und Stack: Bereich wählen, zeilenweise schieben, an den Enden halten (FA-24)', () {
    m.platzEingabe = [20, 20, 20];
    m.platzStack = [20, 20, 20];
    for (final t in ["c", "b", "a"]) {
      m.verlauf.add((text: t, fehler: null));
    }
    expect(m.schiebeZeilen(Bereich.eingabe, 1), isTrue);
    expect([m.bereich, m.verlaufVersatz], [Bereich.eingabe, 1], reason: "nach oben: ältere Zeilen");
    expect(m.schiebeZeilen(Bereich.eingabe, 1), isFalse, reason: "die älteste Zeile steht unten: Halt");
    expect(m.schiebeZeilen(Bereich.eingabe, -5), isTrue);
    expect(m.verlaufVersatz, 0);
    m.zustand = m.api.eingabe("1 2 3 4 5 6 7 8 9 10");
    expect(m.schiebeZeilen(Bereich.stack, 2), isTrue);
    expect([m.bereich, m.stackVersatz], [Bereich.stack, 2], reason: "nach oben: tiefere Werte, wählt den Stack");
    expect(m.schiebeZeilen(Bereich.stack, 50), isTrue);
    expect(m.stackVersatz, 10 - RechnerModell.stackMinZeilen.clamp(1, 3), reason: "bis der unterste Wert unten steht");
    m.tastaturHilfe();
    expect(m.schiebeZeilen(Bereich.stack, -1), isFalse, reason: "im Hilfe-Modus nicht");
  });

  testWidgets('Wischen im Stack: folgt dem Finger zeilenweise, läuft nach, Mausrad je Raste eine Zeile (FA-24)',
      (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    final modell = tester.widget<Anzeige>(find.byType(Anzeige)).modell;
    modell.zustand = modell.api.eingabe([for (var i = 1; i <= 60; i++) "$i"].join(" "));
    modell.waehleBereich(Bereich.eingabe);
    await tester.pump();
    final stack = tester.getCenter(find.byType(Anzeige)) + const Offset(80, -40);
    // langsam um gut zwei Zeilen (je etwa 25 Pixel) nach oben
    final g = await tester.startGesture(stack);
    for (var i = 0; i < 10; i++) {
      await g.moveBy(const Offset(0, -6));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await g.up();
    await tester.pumpAndSettle();
    expect(modell.bereich, Bereich.stack, reason: "Wischen wählt den Bereich");
    expect(modell.stackVersatz, 2, reason: "60 Pixel langsam: zwei Zeilen, kein Nachlauf");
    // schnell: läuft nach
    await tester.fling(find.byType(Anzeige), const Offset(0, -80), 2000);
    await tester.pumpAndSettle();
    expect(modell.stackVersatz, greaterThan(2 + 4), reason: "Nachlauf über den Weg hinaus");
    // zurück bis zum Anfang und Halt
    await tester.fling(find.byType(Anzeige), const Offset(0, 300), 5000);
    await tester.pumpAndSettle();
    expect(modell.stackVersatz, 0);
    // Mausrad: eine Raste nach unten, eine Zeile
    final maus = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(maus.hover(stack));
    await tester.sendEventToBinding(maus.scroll(const Offset(0, 100)));
    await tester.pump();
    expect(modell.stackVersatz, 1);
    expect(TippSperre.gesperrt.value, isTrue, reason: "nach dem Mausrad kein Tooltip, wie nach dem Kontextmenü (BA-11)");
    await tester.pump(const Duration(seconds: 2));
  });

  test('CL leert die Zeile ohne Wirkung auf den Stack, leer die Zeile darunter; AC dazu Verlauf, Stack, Tags (FA-25)', () {
    const cl = Taste("CL", aktion: Aktion.zeileLoeschen, shift: "AC", buchstabe: "d");
    m.zustand = m.api.eingabe("5'!v");
    tippe(["1", "ENTER", "2", "+", "ENTER", "3", "4"]);
    m.druecke(cl);
    expect([m.zeile, m.zustand.offen, stack()], ["", "", [3]],
        reason: "1 2+ bleibt ausgeführt, 34 ist verworfen");
    expect(m.verlauf, isEmpty, reason: "die verworfene Zeile kommt nicht in den Verlauf");
    for (final t in ["b", "a"]) {
      m.verlauf.insert(0, (text: t, fehler: null));
    }
    m.druecke(cl);
    expect([for (final v in m.verlauf) v.text], ["b"], reason: "leere Zeile: die darunter wird gelöscht");
    m.zustand = m.api.eingabe("1 2 3 2:'|t");
    m.waehleBereich(Bereich.funktionen);
    m.druecke(const Taste("SHIFT", aktion: Aktion.shift));
    m.druecke(cl);
    expect([m.verlauf, m.zustand.tiefe, m.zustand.speicher.map((s) => s.name)], [isEmpty, 0, ["v"]],
        reason: "AC: Verlauf, Stack und Tags weg, die Variable bleibt");
    expect(m.bereich, Bereich.eingabe, reason: "AC kehrt zur Seite Rechnen zurück (VA-16)");
    tippe(["7", "8"]);
    m.tastaturEsc();
    expect([m.zeile, m.zustand.tiefe], ["", 0], reason: "Esc wie CL");
    m.druecke(const Taste("ALPHA", aktion: Aktion.alpha));
    m.druecke(cl);
    expect(m.zustand.offen, "d", reason: "im Alpha-Modus schreibt die Taste d");
  });

  testWidgets('Funktionstasten verschieben: Wischen in Spaltenschritten, eingerastet auf ganzen Seiten; am PC ▲ ▼ (VA-10, BA-10)',
      (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    await tester.tap(find.text("MENÜ"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("schwingungen"));
    await tester.pumpAndSettle();
    final modell = tester.widget<Anzeige>(find.byType(Anzeige)).modell;
    final zweite = modell.funktionstastenAuf(2).whereType<Taste>().first.text;
    expect(find.text(zweite), findsNothing, reason: "die Nachbarseite ist erst beim Schieben da");
    // langsam um gut eine Spalte nach links: die Tasten folgen dem Finger, die nächste Seite schaut herein
    final g = await tester.startGesture(tester.getCenter(find.text("omega")));
    for (var i = 0; i < 10; i++) {
      await g.moveBy(const Offset(-8, 0));
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(find.text(zweite), findsOneWidget, reason: "die nächste Seite schaut herein");
    expect(modell.seitenName, "schwingungen 1/3", reason: "weniger als die Hälfte: die Seite gilt noch");
    expect(find.text("schwingungen 1/3"), findsOneWidget, reason: "der Rahmen ist beim Schieben zu sehen");
    await g.up();
    await tester.pumpAndSettle();
    expect([find.text(zweite).evaluate().length, modell.seitenName], [0, "schwingungen 1/3"],
        reason: "langsam losgelassen: rastet auf der Seite ein, von der mehr als die Hälfte zu sehen ist (BA-10)");
    // mit Schwung: auf einer ganzen Seite
    await tester.fling(find.text("omega"), const Offset(-60, 0), 1500);
    await tester.pumpAndSettle();
    expect(modell.seitenName, "schwingungen 2/3");
    expect(find.text("omega"), findsNothing, reason: "ganz auf der zweiten Seite, keine Nachbarseite");
    // langsam über die Hälfte: rastet auf der nächsten Seite ein
    final breite = tester.getSize(find.byType(FunktionsBlock)).width;
    final h = await tester.startGesture(tester.getCenter(find.byType(FunktionsBlock)));
    for (var i = 0; i < 20; i++) {
      await h.moveBy(Offset(-breite * 0.65 / 20, 0));
      await tester.pump(const Duration(milliseconds: 40));
    }
    await h.up();
    await tester.pumpAndSettle();
    expect(modell.seitenName, "schwingungen 3/3", reason: "langsam über die Hälfte (BA-10)");
    await tester.pump(const Duration(seconds: 2));

    // am PC zeigt der Rahmen ▲ ▼ statt ◄ ►
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await tester.tap(find.text("TAB"));
    await tester.tap(find.text("TAB"));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey("funktionsblock"))); // gibt dem Tastenblock den Rahmen (VA-15)
    await tester.pumpAndSettle();
    int imTastenfeld(IconData i) => find.descendant(of: find.byType(Tastenfeld), matching: find.byIcon(i)).evaluate().length;
    expect([for (final i in [Icons.arrow_drop_up, Icons.arrow_drop_down, Icons.arrow_left, Icons.arrow_right]) imTastenfeld(i)],
        [1, 1, 0, 0]);
    debugDefaultTargetPlatformOverride = null;
    await tester.pump(const Duration(seconds: 2));
  });
}
