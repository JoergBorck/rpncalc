/// Aufgabe: der Hilfeschirm, der im Hilfe-Modus über den Seiten der Anzeige liegt: die Einträge einer Hilfeseite
/// mit Titel, Verwendungen, Text und den Verweisen als Knöpfe. Im Inspekt-Modus lässt er Tipps zur Anzeige
/// darunter durch, außer auf einen Verweis.
///
/// Abgrenzung: Welche Seite gezeigt wird und die Folge der Seiten verwaltet das Modell (Hilfe-Modus); die Texte
/// kommen aus help_texts.dart und der Hilfe des Rechners.
///
/// Siehe auch: doc/app.md Kapitel 5.2, help_texts.dart.
library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rpncalc/rpnapi.dart';

import '../colors.dart';
import '../help_texts.dart';
import '../model/model.dart';

/// Der Hilfeschirm über der Anzeige (doc/app.md 5.2): je Eintrag Titel und Verwendungen, nach MENÜ die
/// Einzelheiten, unten die Verweise zum Antippen. Ein Tipp daneben schließt ihn.
class Hilfeschirm extends StatelessWidget {
  final RechnerModell m;
  final List<Hilfe> seite;
  /// Ohne [scrollen] so hoch wie der Inhalt, z.B. für die Bilder des Prüfwerkzeugs (tool/hilfe.dart).
  final bool scrollen;
  const Hilfeschirm(this.m, this.seite, {super.key, this.scrollen = true});

  @override
  Widget build(BuildContext context) {
    final titel = Schrift.monospace(14, Farben.hilfe, gewicht: FontWeight.w700);
    final stil = Schrift.monospace(12, Farben.anzeigeText);
    final blass = Schrift.monospace(11, Farben.anzeigeBlass);
    final verweise = <String>[];
    for (final h in seite) {
      for (final v in h.verweise) {
        if (!verweise.contains(v)) verweise.add(v);
      }
    }
    final einzelheiten = seite.any((h) => h.text.isNotEmpty);
    // im Inspekt-Modus lässt der Schirm Tipps durch, außer auf die Verweise: ein Tipp in die Anzeige zeigt die Hilfe
    // des Elements darunter; blättern gehört zum Lese-Modus (doc/app.md 5.2)
    return _NurVerweise(
      aktiv: m.hilfeModus && !m.hilfeLesen,
      child: Container(
        color: Farben.anzeige.withValues(alpha: 0.97),
        child: ListView(
          controller: scrollen ? m.hilfeScroll : null,
          shrinkWrap: !scrollen,
          physics: scrollen ? null : const NeverScrollableScrollPhysics(),
          // unten Platz, damit sich das Ende über das Cursorkreuz hinaus nach oben scrollen lässt; es ragt in die Anzeige
          padding: EdgeInsets.fromLTRB(12, 6, 12, scrollen ? 110 : 10),
          children: [
            for (final h in seite) ...[
              Text(h.titel, style: titel),
              const SizedBox(height: 2),
              for (final v in h.verwendungen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: v.schreibweise,
                          style: stil.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (v.stack.isNotEmpty) TextSpan(text: "  ${v.stack}", style: stil), // Orange ist Shift (5.1)
                        if (v.argumente.isNotEmpty) TextSpan(text: "  ${v.argumente}", style: blass),
                        TextSpan(text: "  ${v.kurz}", style: stil),
                      ],
                    ),
                  ),
                ),
              if (m.hilfeDetails && h.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(h.textMit((k) => AppHilfe.titel(m.api, k)), style: stil.copyWith(height: 1.4)),
                ),
              const SizedBox(height: 8),
            ],
            if (verweise.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final (i, v) in verweise.indexed)
                    _Verweis(child: ActionChip(
                      label: Text(AppHilfe.titel(m.api, v), style: Schrift.monospace(11, Farben.anzeigeText)),
                      backgroundColor: const Color(0xFF14211B),
                      // im Lese-Modus ist der mit TAB gewählte Verweis hervorgehoben
                      side: i == m.hilfeVerweis
                          ? const BorderSide(color: Farben.hilfe, width: 2)
                          : const BorderSide(color: Color(0xFF2C4A3C)),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => m.folgeVerweis(v),
                    )),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              [
                if (m.hilfeLesen) ...["▲ ▼ blättern", "TAB Verweis, ENTER folgen", "◄ zurück", "ANFANG", "ALPHA: Inspekt"]
                else ...[if (einzelheiten) "LESEN (ALPHA): ganzer Text", "Tipp in die Anzeige: deren Hilfe", "◄ zurück", "BEENDEN"],
              ].join(" · "),
              style: blass,
            ),
          ],
        ),
      ),
    );
  }
}

/// Lässt, solange [aktiv], alle Tipps durch außer denen auf einen [_Verweis] darin (Inspekt-Modus, doc/app.md 5.2).
class _NurVerweise extends SingleChildRenderObjectWidget {
  final bool aktiv;
  const _NurVerweise({required this.aktiv, super.child});

  @override
  _RenderNurVerweise createRenderObject(BuildContext context) => _RenderNurVerweise(aktiv);

  @override
  void updateRenderObject(BuildContext context, _RenderNurVerweise renderObject) => renderObject.aktiv = aktiv;
}

class _RenderNurVerweise extends RenderProxyBox {
  bool aktiv;
  _RenderNurVerweise(this.aktiv);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!aktiv) return super.hitTest(result, position: position);
    // erst zur Probe: trifft der Tipp einen Verweis, gilt er, sonst geht er an die Anzeige darunter
    final probe = BoxHitTestResult();
    if (!super.hitTest(probe, position: position)) return false;
    if (!probe.path.any((e) => e.target is _RenderVerweis)) return false;
    return super.hitTest(result, position: position);
  }
}

/// Markiert einen Verweis für [_NurVerweise].
class _Verweis extends SingleChildRenderObjectWidget {
  const _Verweis({super.child});

  @override
  RenderProxyBox createRenderObject(BuildContext context) => _RenderVerweis();
}

class _RenderVerweis extends RenderProxyBox {}
