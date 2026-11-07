/// Aufgabe: eine Taste des Tastenfelds: groß die aktuelle Beschriftung (je nach Präfix und Alpha), klein links
/// oben die Shift-Belegung, rechts oben die erlaubten Präfixe, rechts unten der Buchstabe für Alpha; dazu
/// Leuchten bei der PC-Tastatur, gedimmt, reserviert und der Tooltip mit der Hilfe zur Taste.
///
/// Abgrenzung: Was die Taste bewirkt und wie sie beschriftet ist, entscheidet das Modell (druecke,
/// beschriftung); die Anordnung der Tasten steht in keypad.dart.
///
/// Siehe auch: doc/app.md Kapitel 3 und 7, keys.dart, help_texts.dart (Tooltips).
library;


import 'package:flutter/material.dart';

import '../colors.dart';
import '../help_texts.dart';
import '../keys.dart';
import '../model/model.dart';
import '../tooltip.dart';

/// Eine Taste: groß die aktuelle Beschriftung, klein links oben Shift, rechts oben die erlaubten Präfixe,
/// rechts unten der Buchstabe für Alpha.
class TasteWidget extends StatelessWidget {
  final Taste taste;
  final RechnerModell m;
  final double hoehe;
  final bool gross, funktion, an;
  final bool bedienung; // oberste Reihe: in der Farbe des Cursorkreuzes, damit sie gut lesbar ist
  final Color? farbe;   // feste Hintergrundfarbe (SHIFT, ALPHA); aktiv zeigt dann ein Rahmen
  final Color? anFarbe;
  final String? buchstabe;
  final VoidCallback? beiDruck;

  const TasteWidget(
    this.taste,
    this.m, {
    required this.hoehe,
    this.gross = false,
    this.funktion = false,
    this.bedienung = false,
    this.farbe,
    this.an = false,
    this.anFarbe,
    this.buchstabe,
    this.beiDruck,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = taste;
    final b = m.beschriftung(t);
    final alphaBuchstabe = buchstabe ?? t.buchstabe;
    // ein auf der Tastatur getippter Buchstabe leuchtet auf seiner Taste und zeigt ihn dabei (doc/app.md 6)
    final buchstabeLeuchtet = alphaBuchstabe != null && m.leuchtetBuchstabe(alphaBuchstabe);
    final alphaAn = (m.alpha || buchstabeLeuchtet) && alphaBuchstabe != null;
    final text = buchstabeLeuchtet && !m.alpha
        ? m.getippterBuchstabe(alphaBuchstabe) // so, wie er auf der Tastatur getippt wurde
        : alphaAn
        ? (m.gross ? alphaBuchstabe.toUpperCase() : alphaBuchstabe)
        : b.text;
    final art = alphaAn ? Beschriftungsart.alpha : b.art;

    // Ziffern, Punkt und ê hell mit dunkler Schrift, damit sie sich vom Rest absetzen
    final ziffer = gross && RegExp(r"^[0-9.ê]$").hasMatch(t.text);
    Color hinten = ziffer
        ? Farben.zifferHell
        : gross
        ? Farben.ziffer
        : funktion || bedienung
        ? Farben.funktion
        : Farben.taste;
    Color vorne = ziffer ? Farben.zifferText : Farben.tasteText;
    if (t.aktion == Aktion.tilde) hinten = Farben.tildeTaste;
    if (t.aktion == Aktion.strich) hinten = Farben.strichTaste;
    if (t.reserviert) {
      hinten = Farben.reserviert;
      vorne = const Color(0xFF5B606D);
    }
    // im Alpha-Modus sind die Funktionstasten Buchstaben wie die anderen: keine eigene Farbe, belegt oder nicht
    if (funktion && m.alpha && alphaBuchstabe != null) {
      hinten = Farben.taste;
      vorne = Farben.tasteText;
    }
    if (an && anFarbe != null) {
      hinten = anFarbe!;
      vorne = Farben.anzeige;
    }
    if (b.gedimmt && !alphaAn) vorne = ziffer ? Farben.zifferGedimmt : Farben.gedimmt;
    vorne = switch (art) {
      Beschriftungsart.shift => Farben.shift,
      Beschriftungsart.tilde => Farben.tilde,
      Beschriftungsart.strich => Farben.strich,
      Beschriftungsart.alpha => Farben.alpha,
      Beschriftungsart.normal => vorne,
    };
    if (farbe != null) {
      hinten = farbe!;
      vorne = Farben.anzeige; // dunkle Schrift auf Orange bzw. Hellgrün, nie ausgegraut
    }
    final aktiv = (t.aktion == Aktion.tilde && m.tilde) || (t.aktion == Aktion.strich && m.strich) ||
        (farbe != null && an);
    // getippt auf der Tastatur: die passende Taste leuchtet kurz auf (doc/app.md Kapitel 6)
    final leuchtet = m.leuchtetTaste(t) || buchstabeLeuchtet;
    if (leuchtet) hinten = Color.lerp(hinten, Farben.tasteText, 0.45)!;
    final lang = text.length > 4;
    // das Wort ENTER klein, das ⏎ im Alpha-Modus groß (das Zeichen ist in der Schrift sehr klein)
    final enterTaste = t.aktion == Aktion.enter;
    final groesse = gross
        ? (enterTaste ? (art == Beschriftungsart.alpha ? 30.0 : 14.0) : 21.0)
        : (lang ? 12.0 : 16.0);
    final zeigeKlein = !m.alpha;
    // ~ und | zeigen unter dem Zeichen, was sie allein tun: ± bzw. □|.□ (doc/app.md 3.1)
    final rechenfunktion = zeigeKlein && (t.aktion == Aktion.tilde || t.aktion == Aktion.strich);

    final knopf = Material(
      color: hinten,
      // nur shape, nicht zusätzlich borderRadius: beides zusammen verbietet Material
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        // nach ~ bzw. | ein dünner Rand in der Farbe des Präfixes auf den Tasten, auf die er wirkt (doc/app.md 3.2)
        side: aktiv
            ? const BorderSide(color: Farben.tasteText, width: 2)
            : farbe == null && art == Beschriftungsart.tilde
                ? const BorderSide(color: Farben.tilde, width: 1)
                : farbe == null && art == Beschriftungsart.strich
                    ? const BorderSide(color: Farben.strich, width: 1)
                    : BorderSide.none,
      ),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: t.reserviert && !alphaAn
            ? null
            : (beiDruck ?? () => m.druecke(alphaAn ? _alphaTaste(t, alphaBuchstabe) : t)),
        child: SizedBox(
          height: hoehe,
          child: Stack(
            children: [
              // im Hilfe-Modus ohne Shift-Hinweis: MENÜ, ALPHA und ⌫ tragen dort ihre Aufgabe (doc/app.md 5.2)
              if (zeigeKlein && t.shift != null && !(m.shift) && !m.hilfeModus)
                Positioned(
                  left: 6,
                  top: t.aktion == Aktion.tab ? -3 : 3,
                  child: Text(
                    t.shift!,
                    // auf farbigen Tasten dunkel; das ⇤ von TAB größer, damit es zu sehen ist
                    style: _klein(farbe != null ? Farben.anzeige : Farben.shift)
                        .copyWith(fontSize: t.aktion == Aktion.tab ? 22 : null),
                  ),
                ),
              if (zeigeKlein && (t.erlaubtTilde || t.erlaubtStrich))
                Positioned(
                  right: 6,
                  top: 3,
                  child: Row(
                    children: [
                      if (t.erlaubtTilde) Text("~", style: _klein(Farben.tilde, mono: true)),
                      if (t.erlaubtTilde && t.erlaubtStrich) const SizedBox(width: 3),
                      if (t.erlaubtStrich) Text("|", style: _klein(Farben.strich, mono: true)),
                    ],
                  ),
                ),
              if (zeigeKlein && alphaBuchstabe != null)
                Positioned(
                  right: 5,
                  bottom: 2,
                  child: Text(alphaBuchstabe, style: _klein(Farben.alpha, mono: true).copyWith(fontSize: 9)),
                ),
              if (rechenfunktion)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 5,
                  height: 9,
                  child: CustomPaint(
                    painter: _Rechenfunktion(
                      vorzeichen: t.aktion == Aktion.tilde,
                      farbe: Farben.tasteText.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment(0, rechenfunktion ? -0.4 : 0.45),
                child: t.aktion == Aktion.tab
                    // TAB mit großem Zeichen: ⇥ vorwärts, mit Shift ⇤ rückwärts
                    // (auf schmalen Bildschirmen verkleinert, statt überzulaufen)
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("TAB", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: vorne)),
                            const SizedBox(width: 4),
                            Text(m.shiftWirkt ? "⇤" : "⇥", style: TextStyle(fontSize: 24, height: 1, color: vorne)),
                          ],
                        ),
                      )
                    // lange Wörter (INSPEKT, BEENDEN) nie umbrechen: ist die Schrift breiter (Handy), wird es kleiner;
                    // seitlich Abstand, damit der Rand einer hervorgehobenen Taste nichts verdeckt
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          text,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: groesse,
                            fontWeight: FontWeight.w600,
                            color: vorne,
                            letterSpacing: lang ? 0.3 : 0,
                          ),
                        ),
                      ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
    // Tooltip mit den Kurztexten aller Belegungen (doc/app.md 5.1): am PC beim Darüberfahren, am Handy
    // bei langem Drücken
    // SHIFT und MENÜ öffnen die Hilfe; auf ihnen ruht der Zeiger dabei, ihr Tooltip soll nicht als angeschaut gelten
    final merken = t.aktion != Aktion.shift && t.aktion != Aktion.menue;
    return tippTabelle(AppHilfe.tippBereiche(m.api, t), knopf, beiAnzeige: merken ? () => m.tooltipGezeigt(t) : null);
  }

  /// Im Alpha-Modus schreibt eine Funktionstaste ihren Buchstaben, nicht ihre Belegung.
  static Taste _alphaTaste(Taste t, String buchstabe) =>
      t.buchstabe == buchstabe ? t : Taste(t.text, buchstabe: buchstabe);

  static TextStyle _klein(Color farbe, {bool mono = false}) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: farbe,
    height: 1,
    fontFamily: mono ? Schrift.mono.first : null,
    fontFamilyFallback: mono ? Schrift.mono.sublist(1) : null,
  );
}

/// Die Rechenfunktion von ~ und | unter ihrem Zeichen (doc/app.md 3.1): ± bzw. □|.□, mittig in der Höhe der
/// Zeichenfläche.
class _Rechenfunktion extends CustomPainter {
  final bool vorzeichen;
  final Color farbe;
  const _Rechenfunktion({required this.vorzeichen, required this.farbe});

  @override
  void paint(Canvas canvas, Size size) {
    final stift = Paint()
      ..color = farbe
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final h = size.height, mitte = size.width / 2;
    if (vorzeichen) {
      // ±: Plus oben, Strich darunter
      canvas.drawLine(Offset(mitte - 3.5, h * 0.35), Offset(mitte + 3.5, h * 0.35), stift);
      canvas.drawLine(Offset(mitte, 0), Offset(mitte, h * 0.7), stift);
      canvas.drawLine(Offset(mitte - 3.5, h), Offset(mitte + 3.5, h), stift);
      return;
    }
    // □|.□: Kasten, Strich, Punkt, Kasten
    const kasten = 6.5, abstand = 2.5;
    final breite = 2 * kasten + 4 * abstand + 1.5;
    var x = mitte - breite / 2;
    final oben = h - kasten;
    canvas.drawRect(Rect.fromLTWH(x, oben, kasten, kasten), stift);
    x += kasten + abstand;
    canvas.drawLine(Offset(x, 0), Offset(x, h), stift);
    x += abstand;
    canvas.drawCircle(Offset(x + 0.75, h - 0.75), 0.9, stift..style = PaintingStyle.fill);
    stift.style = PaintingStyle.stroke;
    x += 1.5 + abstand;
    canvas.drawRect(Rect.fromLTWH(x, oben, kasten, kasten), stift);
  }

  @override
  bool shouldRepaint(_Rechenfunktion alt) => alt.vorzeichen != vorzeichen || alt.farbe != farbe;
}
