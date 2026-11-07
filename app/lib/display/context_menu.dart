/// Aufgabe: das Kontextmenü einer Zeile der Eingabe- bzw. Stackspalte (Rechtsklick am PC, langes Drücken am
/// Handy): Werte oder Zeilen kopieren, Werte oder Text einfügen, Hilfe. Die Zeile bleibt markiert, solange das
/// Menü offen ist; Tooltips ruhen so lange.
///
/// Abgrenzung: Kopieren und Einfügen selbst macht das Modell (Zwischenablage); diese Datei zeigt nur das Menü.
///
/// Siehe auch: doc/app.md Kapitel 2.1, model/model.dart.
library;

import 'package:flutter/material.dart';
import 'package:rpncalc/rpnapi.dart';

import '../colors.dart';
import '../model/model.dart';
import '../tooltip.dart';

/// Kontextmenü einer Zeile der Eingabe- bzw. Stackspalte: Rechtsklick am PC, langes Drücken am Handy
/// (doc/app.md 2.1). Im Hilfe-Modus nicht, dort zeigt ein Tipp die Hilfe.
class Kontextmenue extends StatelessWidget {
  final RechnerModell m;
  final bool stack;
  final int zeile;
  final List<Hilfe> Function() hilfe;
  final Widget child;
  const Kontextmenue(this.m, {super.key, required this.stack, required this.zeile, required this.hilfe, required this.child});

  void _zeige(BuildContext context, Offset ort) {
    if (m.hilfeModus) return;
    m.waehleBereich(stack ? Bereich.stack : Bereich.eingabe);
    m.markiereKontext((stack: stack, zeile: zeile)); // die Zeile ist hervorgehoben, solange das Menü offen ist
    PopupMenuItem<void> eintrag(String text, VoidCallback wirkung, {bool an = true}) => PopupMenuItem(
          height: 36,
          enabled: an, // ausgegraut, wenn es an dieser Stelle nichts zu kopieren gibt
          onTap: wirkung,
          child: Text(text, style: Schrift.monospace(13, an ? Farben.anzeigeText : Farben.anzeigeBlass)),
        );
    bool kann(Kopie k) => m.kannKopieren(k, zeile);
    // die Stelle in den Koordinaten der Ebene, in der das Menü liegt (beim Zoom ist sie vergrößert, doc/app.md 1.1)
    final ebene = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final hier = ebene.globalToLocal(ort);
    TippSperre.menue = true; // keine Tooltips über dem Menü
    showMenu<void>(
      context: context,
      position: RelativeRect.fromRect(hier & Size.zero, Offset.zero & ebene.size),
      // etwas heller als die Anzeige, mit dünnem Rand und Schatten, damit es sich abhebt
      color: Farben.kontext,
      elevation: 12,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Farben.kontextRand),
      ),
      items: [
        if (stack) ...[
          eintrag("Wert kopieren", () => m.kopiere(Kopie.wert, zeile), an: kann(Kopie.wert)),
          eintrag("Stack ab hier kopieren", () => m.kopiere(Kopie.stackAb, zeile), an: kann(Kopie.stackAb)),
          eintrag("Ganzen Stack kopieren", () => m.kopiere(Kopie.stack), an: kann(Kopie.stack)),
          const PopupMenuDivider(),
          eintrag("Werte einfügen", () => m.fuegeEin(werte: true, nachMenue: true)),
        ] else ...[
          eintrag("Zeile kopieren", () => m.kopiere(Kopie.zeile, zeile), an: kann(Kopie.zeile)),
          eintrag("Zeilen ab hier kopieren", () => m.kopiere(Kopie.zeilenAb, zeile), an: kann(Kopie.zeilenAb)),
          eintrag("Ganzen Verlauf kopieren", () => m.kopiere(Kopie.verlauf), an: kann(Kopie.verlauf)),
          const PopupMenuDivider(),
          eintrag("Text einfügen", () => m.fuegeEin(werte: false, nachMenue: true)),
        ],
        const PopupMenuDivider(),
        eintrag("Hilfe", () => m.oeffneHilfe(hilfe())),
      ],
    ).whenComplete(() {
      m.markiereKontext(null);
      TippSperre.menue = false;
      TippSperre.bisMausWechselt(); // erst nach einer Bewegung wieder Tooltips, nicht sofort unter der Maus
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapUp: (d) => _zeige(context, d.globalPosition),
        onLongPressStart: (d) => _zeige(context, d.globalPosition),
        child: ColoredBox(
          color: m.kontext == (stack: stack, zeile: zeile) ? Farben.kontextZeile : Colors.transparent,
          child: child,
        ),
      );
}
