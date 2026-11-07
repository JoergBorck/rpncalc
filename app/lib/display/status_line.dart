/// Aufgabe: die Statuszeile über den Seiten der Anzeige: Marken für Hilfe-Modus, Präfixe und Alpha, der Wert x
/// bei maximierter Eingabe, Einstellungen (Winkel) und der Name der Seite der Funktionstasten, jeweils mit
/// Tooltip (unterhalb, weil darüber kein Platz ist).
///
/// Abgrenzung: Der Rahmen der Anzeige steht in display.dart; die Texte der Tooltips kommen zum Teil aus
/// help_texts.dart.
///
/// Siehe auch: doc/app.md Kapitel 2 und 7, tooltip.dart.
library;

import 'package:flutter/material.dart';
import 'package:rpncalc/rpnapi.dart';

import '../colors.dart';
import '../help_texts.dart';
import '../model/model.dart';
import '../tooltip.dart';

class Statuszeile extends StatelessWidget {
  final RechnerModell m;
  const Statuszeile(this.m, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget marke(String text, Color farbe, String erklaerung) => _tippStatus(
      erklaerung,
      Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(color: farbe, borderRadius: BorderRadius.circular(4)),
        child: Text(text, style: Schrift.monospace(11, Farben.anzeige, gewicht: FontWeight.w700)),
      ),
    );
    final winkel = switch (m.zustand.winkel) {
      AngleMode.deg => ("DEG", "Winkelmodus = 360°"),
      AngleMode.rad => ("RAD", "Winkelmodus = 2π"),
      AngleMode.grad => ("GRD", "Winkelmodus = 400 gon"),
    };
    final klein = Schrift.monospace(11, Farben.anzeigeBlass, gewicht: FontWeight.w600);
    // im leeren Bereich der Statuszeile: die aktuellen Einstellungen (doc/app.md 7, Punkt 11)
    return _tippStatus(
      _einstellungen(winkel.$1),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
        child: Row(
          children: [
            GestureDetector(
              onTap: m.hilfeModus ? () => m.zeigeHilfe(AppHilfe.nachschlagen(m.api, "#winkel")) : null,
              child: _tippStatus(winkel.$2, Text(winkel.$1, style: klein.copyWith(color: Farben.anzeigeText))),
            ),
            if (m.hilfeModus)
              m.hilfeLesen
                  ? marke("HILFE · LESEN", Farben.hilfe, "Lese-Modus: ▲ ▼ blättern, TAB wählt einen Verweis, ENTER folgt ihm")
                  : marke("HILFE", Farben.hilfe, "Inspekt-Modus: Taste oder Element antippen; LESEN (ALPHA) zum Lesen"),
            if (m.shift)
              marke(
                m.alpha ? "ABC" : "SHIFT",
                Farben.shift,
                m.alpha ? "der nächste Buchstabe groß, danach endet Alpha" : "Umschalter: orange Befehle aktiv",
              ),
            if (m.tilde) marke("~", Farben.tilde, "Präfix ~"),
            if (m.strich) marke("|", Farben.strich, "Präfix |"),
            if (m.apostroph)
              marke("'", Farben.anzeigeText, "Präfix ' (Namen): die Funktionstasten zeigen die Variablen"),
            if (m.alpha) marke("abc", Farben.alpha, "Umschalter: Buchstaben (für Funktionen und Befehle)"),
            // Eingabe maximiert: der Stack ist nicht zu sehen, das Ergebnis steht klein hier (doc/app.md 3.5)
            if (m.maximiert && m.bereich == Bereich.eingabe && m.zustand.stack.isNotEmpty)
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: Farben.tosHinten, borderRadius: BorderRadius.circular(3)),
                  child: _tippStatus(
                    "Tos, der Stack ist ausgeblendet",
                    Text(
                      zahl(m.zustand.stack.first.wert),
                      style: Schrift.monospace(11, Farben.tosText, gewicht: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            const Spacer(),
            Flexible(
              child: _tippStatus(
                "Funktionen: ${[for (final t in m.funktionstasten)
                  if (t != null) t.text].join(", ")}",
                Text("F: ${m.seitenName}", style: klein, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _einstellungen(String winkel) => [
    "Winkelmodus: $winkel",
    "Zufall: ${m.zustand.seed == null ? "echte Zufallszahlen" : "Startwert ${m.zustand.seed}"}",
    "Stack: ${m.zustand.tiefe} Werte",
    "Funktionstasten: ${m.domaene}",
  ].join("\n");

}

/// Tooltips der Statuszeile stehen unterhalb, über ihr ist kein Platz (doc/app.md 7, Punkt 14).
Widget _tippStatus(String nachricht, Widget kind) => tipp(nachricht, kind, unten: true);
