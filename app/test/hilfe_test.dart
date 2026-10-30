import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc_app/hilfe.dart';
import 'package:rpncalc_app/main.dart';
import 'package:rpncalc_app/modell.dart';
import 'package:rpncalc_app/tasten.dart';

/// Hilfe in der App: Tooltips, Hilfe-Modus und Einträge der App (doc/app.md Kapitel 5).
void main() {
  late RechnerModell m;
  setUp(() => m = RechnerModell());

  final alle = [
    ...[...obereTasten, ...untereTasten].expand((r) => r).where((t) => t.funktion == null),
    ...domaenen.values.expand((l) => l).whereType<Taste>(),
  ];
  Taste taste(String text) => alle.firstWhere((t) => t.text == text);
  const shift = Taste("SHIFT", aktion: Aktion.shift), menue = Taste("MENÜ", aktion: Aktion.menue);
  const loeschen = Taste("⌫", aktion: Aktion.loeschen);

  test('jede Taste mit Belegung hat einen Tooltip mit allen Belegungen', () {
    for (final t in alle) {
      if (t.reserviert || t.text.isEmpty) continue;
      expect(AppHilfe.kurztexte(m.api, t), isNotEmpty, reason: "Taste ${t.text}");
    }
    expect(AppHilfe.kurztexte(m.api, taste("x²")), ["²  x → x²  Quadrat", "~²  x → √x  Quadratwurzel"]);
    expect(AppHilfe.kurztexte(m.api, taste("÷")).length, 3, reason: "/, ~/ und |/");
    // sinh gibt es im Rechner noch nicht (doc/app.md 7), also auch keine Zeile dafür
    expect(AppHilfe.kurztexte(m.api, taste("sin")).map((z) => z.split("  ").first), ["sin", "~sin"]);
  });

  test('jede Bedientaste hat einen Eintrag, jeder Verweis der App ein Ziel', () {
    for (final a in [Aktion.shift, Aktion.alpha, Aktion.tab, Aktion.menue, Aktion.loeschen, Aktion.enter, Aktion.maximieren]) {
      expect(AppHilfe.fuerTaste(m.api, Taste("x", aktion: a)), isNotEmpty, reason: "$a");
    }
    for (final h in AppHilfe.eintraege.values) {
      for (final v in h.verweise) {
        expect(AppHilfe.nachschlagen(m.api, v), isNotEmpty, reason: "${h.kennung} → $v");
      }
    }
  });

  test('App und Rechner zusammen: erst die App, dann der Rechner (api.md 8.4)', () {
    expect([for (final h in AppHilfe.fuerTaste(m.api, taste("~"))) h.titel], ["Die Taste ~", "Vorzeichen, Umkehrung, Entfernen"]);
    expect([for (final h in AppHilfe.nachschlagen(m.api, "#")) h.titel], ["Hilfe zur App", "Hilfe zum RPN-Rechner"]);
    expect([for (final h in AppHilfe.fuerTaste(m.api, taste("x²"))) h.kennung], ["²"], reason: "x² und √x stehen beide bei ²");
  });

  test('Hilfe-Modus: Shift+MENÜ, Tasten zeigen ihre Hilfe ohne Eingabe, MENÜ, ◄ und ⌫', () {
    m.druecke(taste("7"));
    m.druecke(shift);
    m.druecke(menue);
    expect([m.hilfeModus, m.shift], [true, false]);
    expect(m.hilfeSeite, isNull, reason: "die Anzeige bleibt, bis man etwas auswählt");
    m.druecke(taste("!"));
    expect(m.hilfeSeite!.first.kennung, "!");
    m.druecke(taste("sin"));
    expect(m.hilfeSeite!.first.kennung, "sin");
    expect(m.zeile, "7", reason: "im Hilfe-Modus wird nichts eingegeben");
    m.druecke(menue);
    expect(m.hilfeDetails, isTrue);
    m.pfeil(AxisDirection.left);
    expect(m.hilfeSeite!.first.kennung, "!", reason: "◄ geht zurück");
    m.folgeVerweis("#variablen");
    expect(m.hilfeSeite!.first.kennung, "#variablen");
    m.hilfeSchliessen();
    expect([m.hilfeModus, m.hilfeSeite], [true, null], reason: "ein Tipp schließt den Schirm, der Modus bleibt");
    m.druecke(menue);
    expect(m.hilfeSeite!.first.titel, "Hilfe zur App", reason: "MENÜ ohne Eintrag zeigt die Startseite");
    m.druecke(shift);
    expect([m.shift, m.hilfeSeite!.first.kennung], [false, "app:shift"], reason: "Shift schaltet nicht um");
    m.druecke(loeschen);
    expect([m.hilfeModus, m.hilfeSeite, m.zeile], [false, null, "7"]);
  });

  test('Hilfe zu Elementen: Stack-Wert mit Position und Tags, Zeile im Verlauf', () {
    m.api.eingabe("5'|t_8");
    final s = m.api.zustand().stack;
    final wert = AppHilfe.stackWert(m.api, s[1]);
    expect(wert.first.titel, "Stack-Wert an Position 1");
    expect([for (final v in wert.first.verwendungen) v.schreibweise], ["5", "'t"]);
    expect(wert.last.kennung, "#stack");
    expect(AppHilfe.zeile("1 2+").first.verwendungen.single.schreibweise, "1 2+");
  });

  testWidgets('Tooltips: Cursorkreuz, Maximieren, Elemente der Anzeige, Rahmen (doc/app.md 7, Punkte 10 bis 12)', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    for (final t in [
      "ältere Zeilen", // ▲ im Bereich Eingabe
      "[ ] Vollbild für die markierte Seite",
      "Winkelmodus = 360°",
      "Seiten: Rechnen, Variablen und Tags, Funktionen\nWechsel durch Wischen oder mit TAB",
      "▲ ▼  blättern im Verlauf\n◄ ►  schieben lange Zeilen seitlich\nWechsel mit TAB oder durch Antippen", // Rahmen
    ]) {
      expect(find.byTooltip(t), findsWidgets, reason: t); // der Seiten-Tooltip hängt an Name und Punkten
    }
    expect(find.byTooltip("Umschalter: Buchstaben (für Funktionen und Befehle)"), findsNothing);
    await tester.tap(find.text("ALPHA"));
    await tester.pump();
    expect(find.byTooltip("Umschalter: Buchstaben (für Funktionen und Befehle)"), findsOneWidget);
    expect(find.text("ABC"), findsWidgets, reason: "im Alpha-Modus heißt SHIFT „ABC“");
  });

  testWidgets('ein Tipp in die Anzeige wählt den Bereich, der Name steht außen am Rahmen', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    expect(find.text("Eingabe"), findsOneWidget, reason: "nur noch am Rahmen, nicht in der Statuszeile");
    final eingabe = tester.getRect(find.text("Eingabe"));
    await tester.tapAt(Offset(eingabe.right + 260, eingabe.top - 80)); // rechte Spalte, oberhalb des Cursorkreuzes
    await tester.pump();
    final stack = tester.getRect(find.text("Stack"));
    expect(find.text("Eingabe"), findsNothing);
    expect(stack.left, greaterThan(eingabe.right + 100), reason: "der Name des Stacks steht rechts außen");
  });

  testWidgets('Hilfe-Modus in der Oberfläche: Marke, Hilfeschirm, Verweis, schließen', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    await tester.tap(find.text("SHIFT"));
    await tester.pump();
    await tester.tap(find.text("HILFE").first); // MENÜ zeigt mit Shift „HILFE“
    await tester.pump();
    expect(find.text("HILFE"), findsWidgets, reason: "Marke in der Statuszeile");
    await tester.tap(find.text("x²"));
    await tester.pump();
    expect(find.text("Quadrat und Quadratwurzel"), findsOneWidget);
    await tester.tap(find.text("⌫"));
    await tester.pump();
    expect(find.text("Quadrat und Quadratwurzel"), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
