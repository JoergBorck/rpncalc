import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:rpncalc_app/display/display.dart';
import 'package:rpncalc_app/display/menu_page.dart';
import 'package:rpncalc_app/help_texts.dart';
import 'package:rpncalc_app/keypad/menu_keys.dart';
import 'package:rpncalc_app/keys.dart';
import 'package:rpncalc_app/main.dart';
import 'package:rpncalc_app/model/model.dart';

/// Der Bereich Modi des Menüs (doc/app.md 3.6, FA-32): zuerst wirkt nur Winkel, die übrigen sind Platzhalter.
void main() {
  late RechnerModell m;
  setUp(() => m = RechnerModell());
  tearDown(() => m.dispose());

  const menue = Taste("MENÜ", shift: "HILFE", aktion: Aktion.menue);
  const acht = Taste("8");
  const enter = Taste("ENTER", eingabe: " ", shift: "_", aktion: Aktion.enter);
  const shift = Taste("SHIFT", aktion: Aktion.shift);
  Taste modus(String name) => Taste(name, aktion: Aktion.menueModus);

  void oeffnen() {
    m.druecke(menue);
    m.druecke(acht);
  }

  test('8 öffnet die Modi: Format, Winkel, Trig, Klasse, –, Trenner, Bruch, Domain, Auflösung, –', () {
    oeffnen();
    expect([m.menueBereich, m.seitenName, m.menuePfad], [MenueBereich.modi, "Modi", "MENÜ › Modi"]);
    expect([for (final t in m.funktionstasten) t?.text],
        ["Format", "Winkel", "Trig", "Klasse", null, "Trenner", "Bruch", "Domain", "Auflösung", null]);
    expect([m.imMenuePfad(acht), m.imMenuePfad(const Taste("4"))], [true, false]);
    expect([for (final f in modusFelder.nonNulls) if (f.aktiv) f.name], ["Format", "Winkel", "Trenner", "Bruch"]);
  });

  test('Winkel schaltet der Reihe nach, Shift zurück; Rahmen und Satz zu OK', () {
    oeffnen();
    expect([m.modusWert("Winkel"), m.menueRahmen("Winkel"), m.menueWirkung, m.menueAendert],
        ["Deg", MenueRahmen.geladen, "OK ändert nichts.", false]);
    m.druecke(modus("Winkel"));
    expect([m.modusWert("Winkel"), m.menueRahmen("Winkel"), m.menuePfad], ["Rad", MenueRahmen.gewaehlt, "MENÜ › Modi › Winkel"]);
    expect([m.menueWirkung, m.menueAendert], ["OK ändert Winkel.", true]);
    expect(m.modusZeile, (wert: "Winkel Rad", erklaerung: "Bogenmaß, 90° = π/2"));
    m.druecke(modus("Winkel"));
    m.druecke(modus("Winkel"));
    expect([m.modusWert("Winkel"), m.menueAendert], ["Deg", false], reason: "am Ende wieder von vorn");
    m.druecke(shift);
    m.druecke(modus("Winkel"));
    expect(m.modusWert("Winkel"), "Grd", reason: "Shift: zum vorigen Wert");
    m.druecke(modus("Format"));
    expect(m.menueRahmen("Winkel"), MenueRahmen.laden, reason: "geändert, nicht mehr gewählt: grün");
  });

  test('Platzhalter: ohne Wirkung und ohne Rahmen, die Zeile sagt, womit sie kommen', () {
    oeffnen();
    for (final name in ["Trig", "Klasse", "Domain", "Auflösung"]) {
      m.druecke(modus(name));
      expect([m.modusWert(name), m.menueRahmen(name), m.menueAendert], [modusFeld(name)!.werte.first, MenueRahmen.keiner, false]);
    }
    m.druecke(modus("Trig"));
    expect(m.modusZeile, (wert: "Trig", erklaerung: "kommt mit FR-15"));
  });

  test('OK stellt den Winkel ein, ohne die offene Zeile zu berühren; MENÜ bricht ab', () {
    m.tippeZeichen("1");
    m.tippeZeichen("2");
    oeffnen();
    m.druecke(modus("Winkel"));
    m.druecke(enter);
    expect([m.menueOffen, m.zustand.winkel, m.zeile], [false, AngleMode.rad, "12"]);
    oeffnen();
    expect(m.modusWert("Winkel"), "Rad", reason: "beim Öffnen der eingestellte Wert");
    m.druecke(modus("Winkel"));
    m.druecke(menue);
    expect(m.zustand.winkel, AngleMode.rad);
  });

  test('Hilfe: Bereich und jeder Modus haben einen Eintrag', () {
    oeffnen();
    expect(m.menueHilfe(acht), "menue:modi");
    for (final f in modusFelder.nonNulls) {
      final kennung = m.menueHilfe(modus(f.name))!;
      expect(AppHilfe.eintraege[kennung], isNotNull, reason: kennung);
    }
  });

  test('PC-Tastatur: 8 öffnet die Modi, die Buchstaben der Funktionstasten drücken sie, groß wie Shift', () {
    expect(funktionsBuchstaben.join(), "fghijlmnop");
    m.druecke(menue);
    m.tippeZeichen("g");
    expect(m.menueBereich, MenueBereich.haupt, reason: "im Hauptmenü tun Buchstaben nichts");
    m.tippeZeichen("8");
    expect(m.menueBereich, MenueBereich.modi);
    m.tippeZeichen("g");
    expect([m.modusWert("Winkel"), m.menueGewaehlt], ["Rad", "Winkel"]);
    m.tippeZeichen("G");
    m.tippeZeichen("G");
    expect([m.modusWert("Winkel"), m.shift], ["Grd", false], reason: "G schaltet zurück, Shift bleibt nicht stehen");
    m.tippeZeichen("j");
    m.tippeZeichen("x");
    expect([m.menueGewaehlt, m.zeile], ["Winkel", ""], reason: "leere Taste und andere Buchstaben tun nichts");
    m.tastaturReturn();
    expect(m.zustand.winkel, AngleMode.grad);
  });

  test('PC-Tastatur: auch bei den Bibliotheken drückt der Buchstabe die Taste', () {
    m.druecke(menue);
    m.tippeZeichen("4");
    final erste = m.funktionstasten.first!.text;
    m.tippeZeichen("f");
    expect([m.menueAuswahl, m.menueGewaehlt], [{erste}, erste]);
  });

  test('Format: Fix mit Stellen über den Ziffernblock, auch 4 und 8; ê 12, „.“ 15; OK stellt das Format ein', () {
    m.zustand = m.api.eingabe("1234.56789");
    oeffnen();
    expect(m.menueZiffern, isFalse, reason: "Std: keine Ziffern");
    m.druecke(modus("Format"));
    expect([m.modusBeschriftung("Format"), m.menueZiffern, m.wirktImMenue(const Taste("7"))], ["Fix 4", true, true]);
    m.druecke(acht);
    expect([m.menueBereich, m.menueStellen], [MenueBereich.modi, 8], reason: "8 ist hier eine Ziffer");
    m.druecke(const Taste("ê"));
    expect(m.menueStellen, 12);
    m.druecke(const Taste("."));
    expect(m.menueStellen, 15);
    m.tippeZeichen("2");
    expect([m.menueStellen, m.modusZeile?.wert], [2, "Format Fix 2"]);
    expect(m.modusZeile?.erklaerung, "1234.56789 → 1234.57…");
    m.druecke(modus("Trenner"));
    m.druecke(modus("Trenner"));
    expect(m.modusZeile?.erklaerung, "1234.56789 → 1'234.57…", reason: "die Beispielzahl mit allem, was OK einstellen würde");
    expect(m.menueZiffern, isFalse, reason: "Trenner gewählt: wieder das Hauptmenü auf dem Ziffernblock");
    expect(m.menueWirkung, "OK ändert Format und Trenner.");
    m.druecke(enter);
    expect(m.zustand.anzeige, const Anzeigeformat(format: Zahlformat.fix, stellen: 2, trenner: Trenner.apos));
    oeffnen();
    m.druecke(modus("Format"));
    expect([m.modusWert("Format"), m.menueZiffern], ["Fix", true], reason: "nicht Std: der erste Druck wählt nur aus");
    m.tippeZeichen("5");
    m.druecke(modus("Format"));
    expect([m.modusWert("Format"), m.menueStellen], ["Sci", 5], reason: "erst der nächste Druck schaltet weiter");
    m.druecke(menue);
    expect(m.stackText(0), "1'234.57…", reason: "der Stack im neuen Format");
    expect(m.stackTeile(0)?.gerundet, (8, 9));
  });

  test('Bruch und SI in der Anzeige: SI-Vorsatz abgesetzt, Bruch statt Dezimalzahl', () {
    m.api.anzeigeformat = const Anzeigeformat(format: Zahlformat.si, stellen: 2, bruch: Bruch.mixed);
    m.zustand = m.api.eingabe("12300 0.75");
    expect([m.stackText(0), m.stackText(1)], ["3/4", "12.3 k"]);
    expect(m.stackTeile(1)?.vorsatz, (4, 6));
    m.zustand = m.api.eingabe("123456.7");
    expect([m.stackText(0), m.stackTeile(0)?.gerundet, m.stackTeile(0)?.vorsatz], ["123… k", (3, 4), (4, 6)],
        reason: "„…“ vor dem Vorsatz");
  });

  test('ein zu langer Wert behält seinen Exponenten; ◄ ► schieben die Mantisse', () {
    m.platzStack = [10, 10];
    m.zustand = m.api.eingabe("1ê23 3/ 1234567");
    expect(m.stackText(1), "3.333333333333333ê22");
    expect(m.stackSicht(1).$1, "3.3333…ê22", reason: "der Exponent bleibt rechts");
    expect(m.stackSicht(1).$2, [0, 1, 2, 3, 4, 5, -1, 17, 18, 19]);
    expect(m.stackSicht(0).$1, "1234567", reason: "passt: unverändert");
    m.bereich = Bereich.stack;
    for (var i = 0; i < 3; i++) {
      m.pfeil(AxisDirection.right);
    }
    expect(m.stackSicht(1).$1, "…33333…ê22");
    for (var i = 0; i < 9; i++) {
      m.pfeil(AxisDirection.right);
    }
    expect(m.stackSicht(1).$1, "…333333ê22", reason: "am Ende der ganze Exponent ohne Einschub");
    m.api.anzeigeformat = const Anzeigeformat(format: Zahlformat.fix, stellen: 15);
    m.zustand = m.api.eingabe("_1ê23");
    m.platzStack = [18];
    expect(m.stackText(0), "1.00000000000000…ê23", reason: "„…“ für gerundet vor dem Exponenten");
    expect(m.stackSicht(0).$1, "1.000000000000…ê23", reason: "gekürzt: nur ein „…“");
    m.platzStack = [25];
    expect([m.stackTeile(0)?.gerundet, m.stackTeile(0)?.exponent], [(16, 17), (17, 20)]);
  });

  testWidgets('Menüseite und Tastenfeld: Karte 2 × 5, Modi auf den Funktionstasten, OK übernimmt', (tester) async {
    tester.view.physicalSize = const Size(400 * 3, 860 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    final modell = tester.widget<Anzeige>(find.byType(Anzeige)).modell;
    await tester.tap(find.text("MENÜ"));
    await tester.pumpAndSettle();
    expect(find.text("Modi"), findsOneWidget, reason: "die Karte des Hauptmenüs");
    await tester.tap(find.byWidgetPredicate((w) => w is MenueBereichTaste && w.punkt.name == "Modi"));
    await tester.pumpAndSettle();
    expect(find.text("MENÜ › Modi"), findsOneWidget);
    expect(find.byType(MenueModusTaste), findsNWidgets(8));
    await tester.tap(find.byWidgetPredicate((w) => w is MenueModusTaste && w.taste.text == "Winkel"));
    await tester.pumpAndSettle();
    expect(find.text("OK ändert Winkel."), findsOneWidget);
    expect(find.descendant(of: find.byType(MenueSeite), matching: find.text("Rad")), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
    expect([find.byType(MenueSeite).evaluate().length, modell.zustand.winkel], [0, AngleMode.rad]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('schmale Anzeige: Karte und Tasten ohne Überlauf', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const RpnApp());
    await tester.tap(find.text("MENÜ"));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((w) => w is MenueBereichTaste && w.punkt.name == "Modi"));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate((w) => w is MenueModusTaste && w.taste.text == "Trig"));
    await tester.pumpAndSettle();
    expect(find.text("OK ändert nichts."), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
