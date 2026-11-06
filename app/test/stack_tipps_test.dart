import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpncalc_app/modell.dart';
import 'package:rpncalc_app/tipp.dart';

/// Blättern in einem tiefen Stack (BA-5) und wann Tooltips ruhen (BA-6, FA-22).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ein tiefer Stack lässt sich bis zum untersten Wert blättern, und dort bleibt die Position stehen', () {
    final m = RechnerModell()..zeichenProZeile = 40;
    for (var i = 1; i <= 118; i++) {
      for (final c in "${i}_".split("")) {
        m.tippeZeichen(c);
      }
    }
    m.platzStack = List.filled(5, 20); // fünf sichtbare Zeilen
    m.waehleBereich(Bereich.stack);
    for (var i = 0; i < 200; i++) {
      m.pfeil(AxisDirection.down);
    }
    expect(m.stackVersatz, 118 - 5, reason: "nicht über das Ende hinaus");
    expect(m.stackZeile(4)?.wert, 1, reason: "der unterste Wert ist zu sehen");
    m.pfeil(AxisDirection.up);
    expect(m.stackZeile(4)?.wert, 2, reason: "ein Schritt zurück genügt");
    // eine hohe Anzeige: der unterste Wert kommt bis in die Zeile hoch, die auch die kleinste Anzeige ganz zeigt
    m.platzStack = List.filled(20, 20);
    for (var i = 0; i < 200; i++) {
      m.pfeil(AxisDirection.up);
    }
    for (var i = 0; i < 200; i++) {
      m.pfeil(AxisDirection.down);
    }
    expect(m.stackVersatz, 118 - RechnerModell.stackMinZeilen);
    expect(m.stackZeile(RechnerModell.stackMinZeilen - 1)?.wert, 1);
  });

  test('ENTER und Return wirken mehrmals: ENTER verdoppelt x, Return gibt leere Zeilen (FA-21)', () {
    final m = RechnerModell()..zeichenProZeile = 40;
    m.tippeZeichen("5");
    m.tastaturReturn();
    m.tastaturReturn();
    m.tastaturReturn();
    expect([for (final s in m.zustand.stack) s.wert], [5, 5, 5]);
    final zeilen = m.verlauf.length;
    m.tastaturZeilenumbruch();
    m.tastaturZeilenumbruch();
    expect(m.verlauf.length, zeilen + 2);
    expect(m.verlauf.first.text, "");
  });

  test('wechselt die Maus von einem gezeigten Tooltip auf denselben Inhalt, ruht er nicht', () async {
    TippSperre.uebernimm("Stack");
    await Future<void>.delayed(TippSperre.warten);
    TippSperre.sperren("Stack"); // verlassen, nachdem der Tooltip stand
    expect(TippSperre.gesperrt.value, isTrue);
    expect(TippSperre.uebernimm("Stack"), isTrue);
    expect(TippSperre.gesperrt.value, isFalse);
    TippSperre.sperren("Stack"); // sofort weiter: er gilt als gezeigt
    expect(TippSperre.uebernimm("Eingabe"), isFalse, reason: "anderer Inhalt: die Pause bleibt");
    expect(TippSperre.gesperrt.value, isTrue);
    await Future<void>.delayed(TippSperre.dauer);
    expect(TippSperre.gesperrt.value, isFalse);
  });

  test('Tooltips ruhen, solange das Kontextmenü offen ist, und nach einem Tastendruck bis die Maus wechselt', () {
    expect(TippSperre.gesperrt.value, isFalse);
    TippSperre.menue = true;
    expect(TippSperre.gesperrt.value, isTrue);
    TippSperre.menue = false;
    expect(TippSperre.gesperrt.value, isFalse);
    TippSperre.bisMausWechselt();
    expect(TippSperre.gesperrt.value, isFalse, reason: "ohne Maus (Handy) keine Sperre, die nichts mehr aufhebt");
    final router = GestureBinding.instance.pointerRouter;
    router.route(const PointerHoverEvent(kind: PointerDeviceKind.mouse, position: Offset(5, 5)));
    TippSperre.bisMausWechselt();
    expect(TippSperre.gesperrt.value, isTrue);
    TippSperre.mausGewechselt(const Offset(5, 5));
    expect(TippSperre.gesperrt.value, isTrue, reason: "die Maus hat sich nicht bewegt");
    TippSperre.mausGewechselt(const Offset(40, 5));
    expect(TippSperre.gesperrt.value, isFalse);
    TippSperre.bisMausWechselt();
    router.route(const PointerDownEvent(kind: PointerDeviceKind.touch, position: Offset(40, 5)));
    expect(TippSperre.gesperrt.value, isFalse, reason: "ein Finger hebt die Sperre auf");
  });
}
