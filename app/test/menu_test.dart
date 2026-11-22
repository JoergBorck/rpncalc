import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc_app/display/display.dart';
import 'package:rpncalc_app/display/menu_page.dart';
import 'package:rpncalc_app/keypad/keypad.dart';
import 'package:rpncalc_app/keypad/menu_keys.dart';
import 'package:rpncalc_app/keys.dart';
import 'package:rpncalc_app/main.dart';
import 'package:rpncalc_app/model/model.dart';

import 'menu_helper.dart';

/// Das Menü auf dem Tastenfeld mit dem Bereich Bibliotheken (doc/app.md 3.6, FA-30).
void main() {
  late RechnerModell m;
  setUp(() => m = RechnerModell());
  tearDown(() => m.dispose());

  const menue = Taste("MENÜ", shift: "HILFE", aktion: Aktion.menue);
  const vier = Taste("4");
  const enter = Taste("ENTER", eingabe: " ", shift: "_", aktion: Aktion.enter);
  const shift = Taste("SHIFT", aktion: Aktion.shift);
  Taste schalter(String name) => Taste(name, aktion: Aktion.menueEintrag);

  test('MENÜ öffnet das Hauptmenü, ein zweiter Druck bricht ab; andere Tasten tun nichts', () {
    m.druecke(menue);
    expect([m.menueOffen, m.menueBereich, m.menuePfad], [true, MenueBereich.haupt, "MENÜ"]);
    m.druecke(const Taste("7"));
    m.tippeZeichen("x");
    expect(m.zeile, "", reason: "im Menü wird nichts eingegeben");
    expect([m.wirktImMenue(vier), m.wirktImMenue(const Taste("7")), m.wirktImMenue(enter)], [true, false, true]);
    m.druecke(menue);
    expect(m.menueOffen, isFalse);
  });

  test('4 öffnet die Bibliotheken: die Funktionstasten werden Schalter, eingeschaltet ist, was geladen ist', () {
    einschalten(m, "statistik");
    m.druecke(menue);
    m.druecke(vier);
    expect([m.menueBereich, m.seitenName, m.menueAuswahl], [MenueBereich.bibliotheken, "Bibliotheken", {"statistik"}]);
    expect([for (final t in m.funktionstasten.whereType<Taste>()) t.text], ["schwingungen", "statistik", "Programm"]);
    expect(m.imMenuePfad(vier), isTrue, reason: "4 ist orange umrandet wie MENÜ");
  });

  test('Schalter und Rahmen: was ENTER bewirken wird (doc/app.md 3.6)', () {
    einschalten(m, "statistik");
    m.druecke(menue);
    m.druecke(vier);
    expect([m.menueRahmen("statistik"), m.menueRahmen("schwingungen")], [MenueRahmen.geladen, MenueRahmen.keiner]);
    expect([m.menueWirkung, m.menueAendert], ["OK ändert nichts.", false]);
    m.druecke(schalter("schwingungen"));
    expect([m.menueRahmen("schwingungen"), m.menuePfad], [MenueRahmen.gewaehlt, "MENÜ › Bibliotheken › schwingungen"]);
    m.druecke(schalter("Programm"));
    expect([m.menueRahmen("schwingungen"), m.menueRahmen("Programm")], [MenueRahmen.laden, MenueRahmen.gewaehlt]);
    m.druecke(schalter("statistik"));
    expect(m.menueRahmen("statistik"), MenueRahmen.entladen, reason: "rot, auch wenn gewählt");
    expect([m.menueWirkung, m.menueAendert], ["OK lädt schwingungen, entlädt statistik, schaltet Programm ein.", true]);
    expect([m.beschriftung(enter).text, m.menueHilfe(enter)], ["OK", "menue:ok"], reason: "ENTER heißt im Menü OK");
    for (final e in ["schwingungen", "statistik", "Programm"]) {
      m.druecke(schalter(e));
    }
    expect(m.menueAendert, isFalse, reason: "alles wie beim Öffnen: kein Rahmen um OK");
    expect(m.zustand.speicher.any((s) => s.name == "omega"), isFalse, reason: "geladen wird erst mit ENTER");
  });

  test('ENTER übernimmt: lädt, entlädt, die Tasten zeigen die erste neu eingeschaltete Seite', () {
    einschalten(m, "statistik");
    m.druecke(menue);
    m.druecke(vier);
    m.druecke(schalter("statistik"));
    m.druecke(schalter("schwingungen"));
    m.druecke(enter);
    expect(m.menueOffen, isFalse);
    expect(m.eingeschalteteEintraege, ["schwingungen"]);
    expect(m.zustand.speicher.any((s) => s.name == "mean"), isFalse, reason: "statistik ist entladen");
    expect(m.seitenName, "schwingungen 1/3");
  });

  test('Abbrechen ändert nichts, die Seite der Funktionstasten bleibt', () {
    einschalten(m, "schwingungen");
    m.funktionsSeite = 2;
    m.druecke(menue);
    m.druecke(vier);
    m.druecke(schalter("schwingungen"));
    m.druecke(menue);
    expect([m.eingeschalteteEintraege, m.seitenName], [["schwingungen"], "schwingungen 2/3"]);
  });

  test('Programm: eine eigene Seite nach den Bibliotheken, zu Beginn aus', () {
    expect(m.funktionsSeiten, 1, reason: "nur Grundfunktionen");
    einschalten(m, "Programm");
    expect([m.seitenName, m.funktionstasten.first?.text], ["Programm", "X"]);
    einschalten(m, "statistik");
    expect([for (var i = 0; i < m.funktionsSeiten; i++) (m..funktionsSeite = i).seitenName],
        ["Grundfunktionen", "statistik", "Programm"]);
  });

  test('lässt sich eine Bibliothek nicht laden, bleibt sie aus; der Rest wird übernommen, mit Meldung', () {
    m.zustand = m.api.eingabe("{1}':mean"); // eigene Funktion mit einem Namen aus statistik
    String? meldung;
    m.meldung.addListener(() => meldung ??= m.meldung.value);
    m.druecke(menue);
    m.druecke(vier);
    m.druecke(schalter("statistik"));
    m.druecke(schalter("Programm"));
    m.druecke(enter);
    expect(m.eingeschalteteEintraege, ["Programm"]);
    expect(meldung, startsWith("Nicht geladen: statistik:"));
  });

  test('Shift+MENÜ im Menü: Hilfe; eine Bibliothek zeigt ihre Übersicht, BEENDEN führt zurück ins Menü', () {
    m.druecke(menue);
    m.druecke(vier);
    m.druecke(shift);
    m.druecke(menue);
    expect([m.hilfeModus, m.menueOffen], [true, true]);
    m.druecke(schalter("statistik"));
    expect(m.hilfeSeite?.first.kennung, "#statistik");
    m.druecke(vier);
    expect(m.hilfeSeite?.first.kennung, "menue:bibliotheken");
    m.druecke(menue); // BEENDEN
    expect([m.hilfeModus, m.menueBereich], [false, MenueBereich.bibliotheken]);
    expect(m.menueAuswahl, isEmpty, reason: "die Hilfe hat nichts geschaltet");
  });

  test('PC-Tastatur: F10 öffnet das Menü und bricht ab wie MENÜ', () {
    m.tastaturMenue();
    expect([m.menueOffen, m.menueBereich], [true, MenueBereich.haupt]);
    m.tippeZeichen("8");
    m.tastaturMenue();
    expect(m.menueOffen, isFalse);
  });

  test('PC-Tastatur: 4 öffnet die Bibliotheken, Enter übernimmt, Esc bricht ab', () {
    m.druecke(menue);
    m.tippeZeichen("4");
    expect(m.menueBereich, MenueBereich.bibliotheken);
    m.druecke(schalter("statistik"));
    m.tastaturReturn();
    expect([m.menueOffen, m.eingeschalteteEintraege], [false, ["statistik"]]);
    m.druecke(menue);
    m.tastaturEsc();
    expect(m.menueOffen, isFalse);
  });

  testWidgets('Menüseite und Tastenfeld: Karte, leere Tasten, Schalter mit Symbol und Rahmen', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    final modell = tester.widget<Anzeige>(find.byType(Anzeige)).modell;
    await tester.tap(find.text("MENÜ"));
    await tester.pumpAndSettle();
    expect(find.byType(MenueSeite), findsOneWidget);
    expect(find.text("Bibliotheken"), findsOneWidget, reason: "die Karte des Hauptmenüs");
    expect(find.text("Hauptmenü"), findsWidgets, reason: "Kopf der Menüseite und Name am Rahmen um den Ziffernblock");
    expect(find.text("TAB"), findsNothing, reason: "leer im Menü");
    expect(find.descendant(of: find.byType(Tastenfeld), matching: find.text("7")), findsNothing,
        reason: "Ziffern ohne Bedeutung sind leer");
    await tester.tap(find.byWidgetPredicate((w) => w is MenueBereichTaste && w.punkt.name == "Bibliotheken"));
    await tester.pumpAndSettle();
    expect(find.text("MENÜ › Bibliotheken"), findsOneWidget);
    expect(find.byType(MenueSchalter), findsNWidgets(3));
    await tester.tap(find.byWidgetPredicate((w) => w is MenueSchalter && w.taste.text == "statistik"));
    await tester.pumpAndSettle();
    expect(find.text("OK lädt statistik."), findsOneWidget);
    expect(find.text("wird geladen"), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
    expect([find.byType(MenueSeite).evaluate().length, modell.seitenName], [0, "statistik"]);
  });
}
