/// Aufgabe: der Rahmen der Anzeige. [Anzeige] zeigt oben die Statuszeile, darunter die drei Seiten zum Wischen
/// (Rechnen, Variablen und Tags, Funktionen) und unten Seitenname und Seitenpunkte; im Hilfe-Modus liegt der
/// Hilfeschirm über den Seiten. Wählt das Modell einen Bereich, blättert die Anzeige zur passenden Seite.
///
/// Abgrenzung: Die Seiten selbst stehen in calc_page.dart und list_page.dart, die Statuszeile in
/// status_line.dart, der Hilfeschirm in help_screen.dart. Was angezeigt wird, entscheidet das Modell.
///
/// Siehe auch: doc/app.md Kapitel 2, model/model.dart.
library;

import 'package:flutter/material.dart';

import '../colors.dart';
import '../model/model.dart';
import '../tooltip.dart';
import 'calc_page.dart';
import 'help_screen.dart';
import 'list_page.dart';
import 'status_line.dart';

/// Die Anzeige: Statuszeile und drei Seiten zum Wischen (Rechnen, Variablen und Tags, Funktionen),
/// siehe doc/app.md Kapitel 2.
class Anzeige extends StatefulWidget {
  final RechnerModell modell;
  const Anzeige(this.modell, {super.key});

  @override
  State<Anzeige> createState() => _AnzeigeState();
}

class _AnzeigeState extends State<Anzeige> {
  final _seiten = PageController();
  int _seite = 0;
  Bereich? _bereich;

  static const _namen = ["Rechnen", "Variablen und Tags", "Funktionen"];
  static const _seitenTipp = "Seiten: Rechnen, Variablen und Tags, Funktionen\nWechsel durch Wischen oder mit TAB";

  /// Tab wischt zur passenden Seite.
  static int _seiteFuer(Bereich b) => switch (b) {
    Bereich.eingabe || Bereich.stack => 0,
    Bereich.variablen => 1,
    Bereich.funktionen => 2,
  };

  @override
  void dispose() {
    _seiten.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.modell;
    if (_bereich != m.bereich) {
      _bereich = m.bereich;
      final ziel = _seiteFuer(m.bereich);
      if (ziel != _seite && _seiten.hasClients) {
        _seiten.animateToPage(ziel, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    }
    return Container(
      decoration: BoxDecoration(color: Farben.anzeige, borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Statuszeile(m),
          Expanded(
            child: Stack(
              children: [
                PageView(
                  controller: _seiten,
                  onPageChanged: (i) => setState(() => _seite = i),
                  children: [RechnenSeite(m), ListenSeite.variablen(m), ListenSeite.funktionen(m)],
                ),
                if (m.hilfeSeite != null) Positioned.fill(child: Hilfeschirm(m, m.hilfeSeite!)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: Row(
              children: [
                tipp(_seitenTipp, Text(_namen[_seite], style: Schrift.monospace(10, Farben.anzeigeBlass))),
                const Spacer(),
                tipp(
                  _seitenTipp,
                  Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _seite ? Farben.anzeigeText : const Color(0xFF2C3D35),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
