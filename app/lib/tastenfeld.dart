import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'farben.dart';
import 'hilfe.dart';
import 'modell.dart';
import 'tasten.dart';
import 'tipp.dart';

/// Das Tastenfeld: oben 5 Reihen zu 6 Tasten, unten 4 Reihen zu 5 Tasten (doc/app.md Kapitel 3).
/// In R1 bleiben die Spalten 3 und 4 frei für das Cursorkreuz, das die Seite darüberlegt.
class Tastenfeld extends StatelessWidget {
  final RechnerModell modell;
  final VoidCallback menue;
  const Tastenfeld(this.modell, {required this.menue, super.key});

  static const double obenHoehe = 44, obenAbstand = 7, untenHoehe = 54, untenAbstand = 9;
  static const double randOben = 10, blockAbstand = 12, randUnten = 4;

  /// Gesamthöhe, damit die Seite das Cursorkreuz richtig über R1 setzen kann.
  static const double hoehe =
      randOben + 5 * obenHoehe + 4 * obenAbstand + blockAbstand + 4 * untenHoehe + 3 * untenAbstand + randUnten;

  /// Breite ohne Dehnung (doc/app.md Punkt 5): 400 Punkte abzüglich des Rands der Seite; breiter werden nur die
  /// Tasten, das Cursorkreuz behält seine Größe, die beiden kleinen Tasten darunter füllen den Platz neben ihm.
  static const double normalBreite = 376;

  /// Spaltenbreite des oberen Blocks ohne Dehnung.
  static const double normalSpalte = (normalBreite - 5 * (obenAbstand - 1)) / 6;

  /// Unterkante von R1, gemessen von der Oberkante des Tastenfelds.
  static const double r1Unten = randOben + obenHoehe;

  @override
  Widget build(BuildContext context) {
    final m = modell;
    Widget reihe(List<Widget> tasten, double abstand) => Row(
      children: [
        for (int i = 0; i < tasten.length; i++) ...[
          if (i > 0) SizedBox(width: abstand - 1),
          Expanded(child: tasten[i]),
        ],
      ],
    );
    final fk = m.funktionstasten;
    Widget oben(Taste t) {
      // ⌫ ist im Lese-Modus BEENDEN und dann blau wie MENÜ: Blau sind die Tasten mit einer Aufgabe in der Hilfe
      if (t.aktion == Aktion.loeschen) {
        return TasteWidget(t, m, hoehe: obenHoehe, an: m.hilfeLesen, anFarbe: Farben.hilfe);
      }
      if (t.funktion == null) return TasteWidget(t, m, hoehe: obenHoehe);
      final belegt = fk[t.funktion!];
      if (belegt == null) {
        return TasteWidget(Taste("", reserviert: true, buchstabe: t.buchstabe), m, hoehe: obenHoehe, funktion: true);
      }
      // die Belegung kommt aus der Domäne, der Buchstabe bleibt der des Platzes
      return TasteWidget(belegt, m, hoehe: obenHoehe, funktion: true, buchstabe: t.buchstabe);
    }

    // Rahmen um die zehn Funktionstasten (R3 und R4, Spalten 2 bis 6), wenn sie der gewählte Bereich sind
    final funktionenGewaehlt = m.bereich == Bereich.funktionen || m.bereich == Bereich.variablen;
    List<Widget> rahmen(double breite) {
      final taste = (breite - 5 * (obenAbstand - 1)) / 6;
      final links = taste + obenAbstand - 1 - 4, oben = randOben + 2 * (obenHoehe + obenAbstand) - 4;
      final hoch = 2 * obenHoehe + obenAbstand + 8;
      final variablen = m.bereich == Bereich.variablen;
      return [
        Positioned(
          left: links,
          width: 5 * taste + 4 * (obenAbstand - 1) + 8,
          top: oben,
          height: hoch,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Farben.shift, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // der Name des Bereichs unten auf dem Rahmen, mit Tooltip (doc/app.md 7, Punkt 12)
        Positioned(
          left: links + 10,
          top: oben + hoch - 7,
          child: tipp(
            [
              for (final v in AppHilfe.eintraege[variablen ? "app:variablen" : "app:funktionen"]!.verwendungen)
                "${v.schreibweise}  ${v.kurz}",
            ].join("\n"),
            Container(
              color: Farben.gehaeuse,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                variablen ? "Variablen" : "Funktionen",
                style: const TextStyle(fontSize: 10, height: 1.1, fontWeight: FontWeight.w600, color: Farben.shift),
              ),
            ),
          ),
        ),
      ];
    }

    return SizedBox(
      height: hoehe,
      child: LayoutBuilder(
        builder: (context, platz) => Stack(
          clipBehavior: Clip.none,
          children: [_bloecke(m, reihe, oben), if (funktionenGewaehlt) ...rahmen(platz.maxWidth)],
        ),
      ),
    );
  }

  Widget _bloecke(RechnerModell m, Widget Function(List<Widget>, double) reihe, Widget Function(Taste) oben) {
    return Column(
      children: [
        const SizedBox(height: randOben),
        reihe([
          // SHIFT orange und ALPHA hellgrün wie ihre Hinweise, aktiv mit hellem Rahmen (doc/app.md 7, Punkt 7);
          // im Alpha-Modus zeigt SHIFT, was ein Druck bewirkt: einen Großbuchstaben
          TasteWidget(
            // zeigt, was ein Druck bewirkt: im Alpha-Modus Großbuchstabe (ABC) bzw. zurück zu klein (abc)
            Taste(m.alpha ? (m.shift ? "abc" : "ABC") : "SHIFT", aktion: Aktion.shift),
            m,
            hoehe: obenHoehe,
            farbe: Farben.shift,
            an: m.shift,
          ),
          TasteWidget(
            const Taste("ALPHA", shift: "ABC", aktion: Aktion.alpha),
            m,
            hoehe: obenHoehe,
            farbe: Farben.alpha,
            an: m.alpha || m.hilfeLesen, // im Hilfe-Modus: Lese-Modus
          ),
          _Ecke(m, rechts: false), // Platzhalter rechts neben ALPHA
          _Ecke(m, rechts: true), // Maximieren links neben TAB
          TasteWidget(const Taste("TAB", shift: "⇤", aktion: Aktion.tab), m, hoehe: obenHoehe, bedienung: true),
          TasteWidget(
            const Taste("MENÜ", shift: "HILFE", aktion: Aktion.menue),
            m,
            hoehe: obenHoehe,
            bedienung: true,
            an: m.hilfeModus,
            anFarbe: Farben.hilfe,
            // Shift+MENÜ und MENÜ im Hilfe-Modus gehören zur Hilfe, MENÜ allein öffnet die Domänen
            beiDruck: () => m.shiftWirkt || m.hilfeModus ? m.druecke(const Taste("MENÜ", aktion: Aktion.menue)) : menue(),
          ),
        ], obenAbstand),
        for (final r in obereTasten) ...[
          const SizedBox(height: obenAbstand),
          reihe([for (final t in r) oben(t)], obenAbstand),
        ],
        const SizedBox(height: blockAbstand),
        for (int i = 0; i < untereTasten.length; i++) ...[
          if (i > 0) const SizedBox(height: untenAbstand),
          reihe([for (final t in untereTasten[i]) TasteWidget(t, m, hoehe: untenHoehe, gross: true)], untenAbstand),
        ],
      ],
    );
  }
}

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
    final modus = alphaAn ? Modus.alpha : b.modus;

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
    if (an && anFarbe != null) {
      hinten = anFarbe!;
      vorne = Farben.anzeige;
    }
    if (b.gedimmt && !alphaAn) vorne = ziffer ? Farben.zifferGedimmt : Farben.gedimmt;
    vorne = switch (modus) {
      Modus.shift => Farben.shift,
      Modus.tilde => Farben.tilde,
      Modus.strich => Farben.strich,
      Modus.alpha => Farben.alpha,
      Modus.normal => vorne,
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
        ? (enterTaste ? (modus == Modus.alpha ? 30.0 : 14.0) : 21.0)
        : (lang ? 12.0 : 16.0);
    final zeigeKlein = !m.alpha;

    final knopf = Material(
      color: hinten,
      // nur shape, nicht zusätzlich borderRadius: beides zusammen verbietet Material
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: aktiv ? const BorderSide(color: Farben.tasteText, width: 2) : BorderSide.none,
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
              Align(
                alignment: const Alignment(0, 0.45),
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
                    : Text(
                  text,
                  style: TextStyle(
                    fontSize: groesse,
                    fontWeight: FontWeight.w600,
                    color: vorne,
                    letterSpacing: lang ? 0.3 : 0,
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

/// Kleine Taste in der unteren Außenecke neben dem Cursorkreuz (doc/app.md 3.5): rechts Maximieren,
/// links ein Platzhalter. Das Cursorkreuz lässt Tipps auf diese Ecken durch.
class _Ecke extends StatelessWidget {
  final RechnerModell m;
  final bool rechts;
  const _Ecke(this.m, {required this.rechts});

  @override
  Widget build(BuildContext context) {
    // zeigt, was ein Druck bewirkt: geteilt → maximieren [ ], maximiert → wieder teilen [|]
    final wirkt = rechts && (m.bereich == Bereich.eingabe || m.bereich == Bereich.stack);
    // bei gedehnten Tasten wächst die Spalte, das Cursorkreuz nicht: die Taste füllt den zusätzlichen Platz
    Widget taste(double spalte) => Material(
      color: Farben.funktion, // wie das Cursorkreuz; der Platzhalter bleibt ohne Beschriftung
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: wirkt || (rechts && m.hilfeModus) ? () => m.druecke(const Taste("", aktion: Aktion.maximieren)) : null,
        child: SizedBox(
          width: 30 + math.max(0, spalte - Tastenfeld.normalSpalte),
          height: 22,
          child: rechts
              ? CustomPaint(painter: _Layout(geteilt: m.maximiert, farbe: wirkt ? Farben.tasteText : Farben.gedimmt))
              : null,
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, platz) => SizedBox(
        height: Tastenfeld.obenHoehe,
        child: Align(
          alignment: rechts ? Alignment.bottomRight : Alignment.bottomLeft,
          // zeigt, was ein Druck bewirkt (doc/app.md 7, Punkt 10)
          child: rechts
              ? tipp(m.maximiert ? "[|] 2 Seiten" : "[ ] Vollbild für die markierte Seite", taste(platz.maxWidth))
              : taste(platz.maxWidth),
        ),
      ),
    );
  }
}

/// Die Zeichen von VS Code: ein Rahmen, bei [geteilt] mit einem Strich in der Mitte.
class _Layout extends CustomPainter {
  final bool geteilt;
  final Color farbe;
  const _Layout({required this.geteilt, required this.farbe});

  @override
  void paint(Canvas canvas, Size size) {
    final stift = Paint()
      ..color = farbe
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final r = Rect.fromCenter(center: size.center(Offset.zero), width: 16, height: 11);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(1.5)), stift);
    if (geteilt) canvas.drawLine(Offset(r.center.dx, r.top), Offset(r.center.dx, r.bottom), stift);
  }

  @override
  bool shouldRepaint(_Layout alt) => alt.geteilt != geteilt || alt.farbe != farbe;
}
