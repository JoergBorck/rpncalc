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

  /// Die Schreibweisen der Zeilen, je Bereich eine Liste.
  List<List<String>> schreibweisen(Taste t) =>
      [for (final b in AppHilfe.tippBereiche(m.api, t)) [for (final z in b) z.schreibweise]];

  test('jede Taste mit Belegung hat einen Tooltip, gegliedert in Bereiche (doc/app.md 5.1)', () {
    for (final t in alle) {
      if (t.reserviert || t.text.isEmpty) continue;
      expect(AppHilfe.tippBereiche(m.api, t), isNotEmpty, reason: "Taste ${t.text}");
    }
    final quadrat = AppHilfe.tippBereiche(m.api, taste("x²")).first;
    expect([for (final z in quadrat) (z.schreibweise, z.stack, z.text)],
        [("²", "x → x²", "Quadrat"), ("~²", "x → √x", "Quadratwurzel")]);
    expect(schreibweisen(taste("x²")).reversed.take(2), [["PC-Tastatur"], ["Alpha"]],
        reason: "Alpha als eigener Bereich, zuletzt die PC-Tastatur");
    expect(schreibweisen(taste("÷")).first, ["/", "~/", "|/"]);
    // sinh gibt es im Rechner noch nicht (doc/app.md 7), also auch keine Zeile dafür
    expect(schreibweisen(taste("sin")).first, ["sin", "~sin"]);
  });

  test('Bereiche: Präfix vorweg, Shift mit seinen Varianten, Bedientasten nach Umschaltung', () {
    final strich = untereTasten.expand((r) => r).firstWhere((t) => t.aktion == Aktion.strich);
    expect(schreibweisen(strich), [["|/ |% |: …"], ["|", "||"], ["'|name", "'||name"], ["3:'|name"], ["Hinweis"], ["PC-Tastatur"]],
        reason: "Formen mit ' als eigener Bereich, ihre Argumente ebenso");
    final s = taste("S");
    final bereiche = AppHilfe.tippBereiche(m.api, s);
    expect([for (final z in bereiche[1]) z.schreibweise], ["4:S", "▢:1:S", "▢:▢:2:S", "4:1:2:S"],
        reason: "Argumente als eigener Bereich, zuletzt das ganze Beispiel (doc/api.md 8.1)");
    expect(bereiche[1].last.text, "tauscht y mit ≡₄ und z mit ≡₅");
    expect([for (final z in bereiche[2]) z.schreibweise], ["R", "~R"], reason: "~R kehrt die Shift-Funktion um");
    expect(bereiche[2].every((z) => z.art == ZeilenArt.shift), isTrue);
    expect([for (final z in bereiche.last) z.text], ["k / K"]);
    expect(schreibweisen(loeschen), [["⌫"], ["C", "'C"], ["PC-Tastatur"]], reason: "Shift ergibt C, 'C als eigene Zeile");
    expect(schreibweisen(taste("7")), [["7"]]);
  });

  test('Seite Bibliotheken: von der Startseite erreichbar, je Bibliothek ein Verweis mit Ziel', () {
    expect(AppHilfe.eintraege["#"]!.verweise, contains("app:bibliotheken"));
    final seite = AppHilfe.nachschlagen(m.api, "app:bibliotheken").single;
    expect([for (final v in seite.verwendungen) v.schreibweise], ["schwingungen", "statistik"]);
    expect(seite.verweise, containsAll(["#statistik", "#schwingungen", "#"]));
    for (final v in seite.verweise) {
      expect(AppHilfe.nachschlagen(m.api, v), isNotEmpty, reason: v);
    }
    expect(AppHilfe.titel(m.api, "app:bibliotheken"), "Bibliotheken");
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

  test('Inspekt-Modus: Start mit der Startseite, Tasten zeigen ihre Hilfe, BEENDEN (doc/app.md 5.2)', () {
    m.druecke(taste("7"));
    m.druecke(shift);
    m.druecke(menue);
    expect([m.hilfeModus, m.hilfeLesen, m.shift], [true, false, false]);
    expect(m.hilfeSeite!.first.titel, "Hilfe zur App", reason: "ohne frischen Tooltip die Startseite");
    expect(m.beschriftung(menue).text, "BEENDEN");
    m.druecke(taste("!"));
    expect(m.hilfeSeite!.first.kennung, "!");
    m.druecke(loeschen);
    expect([m.hilfeModus, m.hilfeSeite!.first.kennung], [true, "app:loeschen"], reason: "⌫ zeigt seine Hilfe, auch zu C");
    m.druecke(shift);
    expect([m.shift, m.hilfeSeite!.first.kennung], [false, "app:shift"], reason: "SHIFT zeigt seine Hilfe");
    expect(m.zeile, "7", reason: "im Hilfe-Modus wird nichts eingegeben");
    m.pfeil(AxisDirection.left);
    expect(m.hilfeSeite!.first.kennung, "app:loeschen", reason: "◄ geht zurück");
    m.hilfeSchliessen();
    expect([m.hilfeModus, m.hilfeSeite], [true, null], reason: "ein Tipp schließt den Schirm, der Modus bleibt");
    m.druecke(menue);
    expect([m.hilfeModus, m.hilfeSeite, m.zeile], [false, null, "7"], reason: "BEENDEN");
  });

  test('Lese-Modus: ◄ lässt die erste Seite stehen, ► ohne Auswahl wählt den ersten Verweis (doc/app.md 5.2)', () {
    m.druecke(shift);
    m.druecke(menue);
    m.hilfeSchliessen();
    m.druecke(const Taste("ALPHA", aktion: Aktion.alpha));
    expect([m.hilfeLesen, m.hilfeSeite!.first.titel], [true, "Hilfe zur App"], reason: "LESEN ohne Schirm: Startseite");
    m.pfeil(AxisDirection.left);
    expect(m.hilfeSeite!.first.titel, "Hilfe zur App", reason: "◄ auf der ersten Seite bleibt stehen");
    m.pfeil(AxisDirection.right);
    expect([m.hilfeVerweis, m.hilfeSeite!.first.titel], [0, "Hilfe zur App"], reason: "► wählt erst den ersten Verweis");
    final ziel = m.hilfeVerweise.first;
    m.pfeil(AxisDirection.right);
    expect(m.hilfeSeite!.first.kennung, ziel, reason: "► folgt ihm dann");
    m.pfeil(AxisDirection.left);
    expect([m.hilfeSeite!.first.titel, m.hilfeVerweis], ["Hilfe zur App", -1]);
  });

  test('Lese-Modus: ALPHA, Verweise mit TAB und ENTER, ANFANG, ⌫ beendet (doc/app.md 5.2)', () {
    m.druecke(shift);
    m.druecke(menue);
    m.druecke(const Taste("ALPHA", aktion: Aktion.alpha));
    expect([m.hilfeLesen, m.hilfeDetails, m.beschriftung(menue).text], [true, true, "ANFANG"]);
    expect(m.beschriftung(loeschen).text, "BEENDEN");
    final ziel = m.hilfeVerweise.first;
    m.druecke(const Taste("TAB", aktion: Aktion.tab));
    expect(m.hilfeVerweis, 0);
    m.druecke(taste("!"));
    expect(m.hilfeSeite!.first.titel, "Hilfe zur App", reason: "im Lese-Modus lösen Tasten keine Hilfe aus");
    m.druecke(const Taste("ENTER", aktion: Aktion.enter));
    expect(m.hilfeSeite!.first.kennung, ziel, reason: "ENTER folgt dem gewählten Verweis");
    m.druecke(menue);
    expect(m.hilfeSeite!.first.kennung, "#", reason: "ANFANG zeigt die Startseite");
    m.druecke(const Taste("ALPHA", aktion: Aktion.alpha));
    expect(m.hilfeLesen, isFalse, reason: "ALPHA zurück in den Inspekt-Modus");
    m.druecke(const Taste("ALPHA", aktion: Aktion.alpha));
    m.druecke(loeschen);
    expect(m.hilfeModus, isFalse, reason: "⌫ beendet im Lese-Modus");
  });

  test('die Hilfe startet mit der Seite des letzten Tooltips, wenn er frisch ist (doc/app.md 5.2)', () {
    m.tooltipGezeigt(taste("S"));
    m.druecke(shift);
    m.druecke(menue);
    expect(m.hilfeSeite!.first.kennung, "S");
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
    ]) {
      expect(find.byTooltip(t), findsWidgets, reason: t); // der Seiten-Tooltip hängt an Name und Punkten
    }
    // Eingabe und Stack: Tabelle auf jeder Zeile und auf dem Namen am Rahmen
    final tabellen = find.byWidgetPredicate((w) => w is Tooltip && w.richMessage != null && w.message == null);
    expect(tabellen.evaluate().length, greaterThan(40), reason: "Tasten, Zeilen der Anzeige und Rahmen");
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

  testWidgets('Inspekt-Modus: ein Tipp in die Anzeige geht durch den Hilfeschirm (doc/app.md 5.2)', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    await tester.tap(find.text("SHIFT"));
    await tester.pump();
    await tester.tap(find.text("HILFE").last); // mit Shift trägt MENÜ die Beschriftung HILFE
    await tester.pump();
    expect(find.text("Hilfe zur App"), findsOneWidget, reason: "die Hilfe startet mit der Startseite");
    await tester.tapAt(const Offset(60, 120)); // in die Eingabe, unter dem Hilfeschirm
    await tester.pump();
    expect(find.text("Anzeige: Eingabe"), findsOneWidget, reason: "gleich der erste Tipp zeigt die Hilfe der Eingabe");
    await tester.tap(find.widgetWithText(ActionChip, "Anzeige: Stack"));
    await tester.pump();
    // jetzt die Seite des Stacks (ihre Verweise liegen außerhalb des sichtbaren Teils)
    expect(find.text("Anzeige: Stack"), findsOneWidget, reason: "ein Verweis gilt auch im Inspekt-Modus");
    expect(find.text("Anzeige: Eingabe"), findsNothing);
  });
}
