/// Aufgabe: das Cursorkreuz aus vier schräg gestellten Tasten über R1: blättert und schiebt im gewählten
/// Bereich, im Hilfe-Modus zurück zum vorigen Eintrag; der Tooltip sagt, was ein Pfeil gerade bewirkt.
///
/// Abgrenzung: Die Wirkung der Pfeile steht im Modell (pfeil); wo das Kreuz liegt, bestimmt main.dart.
///
/// Siehe auch: doc/app.md 3.3, keypad/keypad.dart.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../colors.dart';
import '../model/model.dart';
import '../tooltip.dart';

/// Das Cursorkreuz aus vier schräg gestellten Tasten (doc/app.md 3.3).
class Cursorkreuz extends StatelessWidget {
  final RechnerModell modell;
  final double breite;
  const Cursorkreuz(this.modell, {required this.breite, super.key});

  /// Was ein Pfeil im gewählten Bereich bewirkt, für den Tooltip (doc/app.md 7, Punkt 10).
  String _wirkung(AxisDirection r) {
    final hoch = r == AxisDirection.up, runter = r == AxisDirection.down, links = r == AxisDirection.left;
    if (modell.hilfeModus) return links ? "zurück zum vorigen Eintrag" : "Hilfe zum Cursorkreuz";
    return switch (modell.bereich) {
      Bereich.eingabe => hoch ? "ältere Zeilen" : runter ? "neuere Zeilen" : links ? "Zeilen nach rechts schieben (Anfang)" : "Zeilen nach links schieben (Ende)",
      Bereich.stack => hoch ? "Richtung Tos" : runter ? "tiefere Werte" : links ? "Werte nach rechts schieben (Anfang)" : "Werte nach links schieben (Ende)",
      Bereich.funktionen => links ? "Seite zurück" : r == AxisDirection.right ? "nächste Seite" : "",
      Bereich.variablen => "",
    };
  }

  @override
  Widget build(BuildContext context) {
    final seite = breite / math.sqrt2;
    Widget knopf(AxisDirection r, IconData zeichen, BorderRadius rund) => tipp(_wirkung(r), Material(
      color: Farben.funktion,
      shape: RoundedRectangleBorder(
        borderRadius: rund,
        side: const BorderSide(color: Color(0xFF4C5466)),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: rund),
        onTap: () => modell.pfeil(r),
        child: Center(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scaleByDouble(1, 1 / 0.78, 1, 1)
              ..rotateZ(-math.pi / 4),
            child: Icon(zeichen, color: Farben.tasteText, size: 26),
          ),
        ),
      ),
    ));
    const r = Radius.circular(4), gross = Radius.circular(14);
    return SizedBox(
      width: breite,
      height: breite * 0.78,
      child: Center(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scaleByDouble(1, 0.78, 1, 1)
            ..rotateZ(math.pi / 4),
          child: SizedBox(
            width: seite,
            height: seite,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                knopf(
                  AxisDirection.up,
                  Icons.arrow_drop_up,
                  const BorderRadius.only(topLeft: gross, topRight: r, bottomLeft: r, bottomRight: r),
                ),
                knopf(
                  AxisDirection.right,
                  Icons.arrow_right,
                  const BorderRadius.only(topLeft: r, topRight: gross, bottomLeft: r, bottomRight: r),
                ),
                knopf(
                  AxisDirection.left,
                  Icons.arrow_left,
                  const BorderRadius.only(topLeft: r, topRight: r, bottomLeft: gross, bottomRight: r),
                ),
                knopf(
                  AxisDirection.down,
                  Icons.arrow_drop_down,
                  const BorderRadius.only(topLeft: r, topRight: r, bottomLeft: r, bottomRight: gross),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
