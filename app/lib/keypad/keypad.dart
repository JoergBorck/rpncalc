/// Aufgabe: das Tastenfeld: oben R1 mit SHIFT, ALPHA, TAB und MENÜ, darunter R2–R5 mit den Funktionstasten in
/// R3 und R4, unten R6–R9 mit Ziffern und Rechenzeichen. Dazu der orange Rahmen um die Funktionstasten mit dem
/// Namen der Seite, Wischen und Mausrad zum Blättern und die beiden kleinen Ecken neben dem Cursorkreuz
/// (rechts Maximieren). Die Blöcke R1, R2–R5 und R6–R9 entstehen einzeln, damit das Querformat (FA-5) sie nur
/// anders anordnen muss.
///
/// Abgrenzung: Eine einzelne Taste zeichnet key_widget.dart, das Cursorkreuz cursor_cross.dart (die Seite legt
/// es über R1). Welche Tasten es gibt, steht in keys.dart; die Belegung der Funktionstasten liefert das Modell.
///
/// Siehe auch: doc/app.md Kapitel 3, keys.dart, main.dart (Anordnung von Anzeige, Tastenfeld und Cursorkreuz).
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../help_texts.dart';
import '../keys.dart';
import '../model/model.dart';
import '../tooltip.dart';
import 'function_block.dart';
import 'key_widget.dart';

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

  /// Breite ohne Dehnung (doc/app.md 1.1): 400 Punkte abzüglich des Rands der Seite; breiter werden nur die
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
    // die Plätze der zehn Funktionstasten mit ihren Buchstaben für Alpha, nach Platz 0–9
    final plaetze = [for (final r in obereTasten) ...r.where((t) => t.funktion != null)]
      ..sort((a, b) => a.funktion!.compareTo(b.funktion!));
    // hat die Liste der Seite Funktionen bzw. Variablen den Rahmen, gibt ein Tipp auf eine Taste ihn dem Block und
    // gibt nichts ein (VA-15); beim Schreiben von Buchstaben und Namen (Alpha, ') bleiben es Tasten
    final wechselt = m.tastenblockHinterlegt && !m.alpha && !m.apostroph;
    final beiDruck = wechselt ? m.waehleTastenblock : null;
    Widget funktionsTaste(int platz, Taste? belegt) {
      final t = plaetze[platz];
      if (belegt == null) {
        return TasteWidget(Taste("", reserviert: true, buchstabe: t.buchstabe), m,
            hoehe: obenHoehe, funktion: true, beiDruck: beiDruck);
      }
      // die Belegung kommt aus der Domäne, der Buchstabe bleibt der des Platzes
      return TasteWidget(belegt, m, hoehe: obenHoehe, funktion: true, buchstabe: t.buchstabe, beiDruck: beiDruck);
    }

    Widget oben(Taste t) {
      // ⌫ ist im Lese-Modus BEENDEN und dann blau wie MENÜ: Blau sind die Tasten mit einer Aufgabe in der Hilfe
      if (t.aktion == Aktion.loeschen) {
        return TasteWidget(t, m, hoehe: obenHoehe, an: m.hilfeLesen, anFarbe: Farben.hilfe);
      }
      if (t.funktion == null) return TasteWidget(t, m, hoehe: obenHoehe);
      return const SizedBox(height: obenHoehe); // die Funktionstasten zeichnet der FunktionsBlock darüber (VA-10)
    }

    // Rahmen um die zehn Funktionstasten (R3 und R4, Spalten 2 bis 6), wenn der Tastenblock den Rahmen hat (VA-15)
    // nach Wischen oder Mausrad auch kurz ohne gewählten Bereich (doc/app.md 3.3)
    // im Hilfe-Modus immer: ein Klick in den Rahmen zeigt die Hilfe zur Seite (doc/app.md 5.2)
    final funktionenGewaehlt = m.tastenblockGewaehlt || m.funktionenHinweis || m.hilfeModus;
    List<Widget> rahmen(double breite) {
      final taste = (breite - 5 * (obenAbstand - 1)) / 6;
      final links = taste + obenAbstand - 1 - 4, oben = randOben + 2 * (obenHoehe + obenAbstand) - 4;
      final hoch = 2 * obenHoehe + obenAbstand + 8, weit = 5 * taste + 4 * (obenAbstand - 1) + 8;
      final variablen = m.variablenAufTasten;
      Widget pfeil(IconData icon) => Container(color: Farben.gehaeuse, child: Icon(icon, size: 18, color: Farben.shift));
      return [
        if (funktionenGewaehlt) ...[
          Positioned(
            left: links,
            width: weit,
            top: oben,
            height: hoch,
            // unten eine Lücke für den Namen, damit er ohne eigenen Hintergrund auf dem Rahmen stehen kann
            child: IgnorePointer(child: CustomPaint(painter: _Rahmen(luecke: (10, 10 + 6 + _breite(m.seitenName, _nameStil))))),
          ),
          // der Name des Bereichs unten auf dem Rahmen, mit Tooltip (doc/app.md 7, Punkt 12)
          Positioned(
            left: links + 10,
            top: oben + hoch - 7,
            child: GestureDetector(
              onTap: m.hilfeModus ? m.hilfeZurSeite : null,
              child: tipp(
                [
                  for (final v in AppHilfe.eintraege[variablen ? "app:variablen" : "app:funktionen"]!.verwendungen)
                    "${v.schreibweise}  ${v.kurz}",
                ].join("\n"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  // die Seite statt „Funktionen“: Grundfunktionen, schwingungen 2/3, Eigene (doc/app.md 3.3)
                  child: Text(m.seitenName, style: _nameStil),
                ),
              ),
            ),
          ),
          // mehr als eine Seite: Pfeile, wohin geschoben wird; am PC oben und unten (Mausrad), sonst links und rechts
          if (!variablen && m.funktionsSeiten > 1)
            if (_amPc) ...[
              Positioned(left: links + weit / 2 - 9, top: oben - 9, child: IgnorePointer(child: pfeil(Icons.arrow_drop_up))),
              Positioned(left: links + weit / 2 - 9, top: oben + hoch - 9, child: IgnorePointer(child: pfeil(Icons.arrow_drop_down))),
            ] else ...[
              Positioned(left: links - 9, top: oben + hoch / 2 - 9, child: IgnorePointer(child: pfeil(Icons.arrow_left))),
              Positioned(left: links + weit - 9, top: oben + hoch / 2 - 9, child: IgnorePointer(child: pfeil(Icons.arrow_right))),
            ],
        ],
      ];
    }

    return SizedBox(
      height: hoehe,
      child: LayoutBuilder(
        builder: (context, platz) => Stack(
          clipBehavior: Clip.none,
          children: [
            // leicht orange: die Maus steht darüber (VA-4), oder der Block gehört zur Liste mit dem Rahmen (VA-15)
            if ((m.mausUeberFunktionen && m.funktionenBlaetterbar) || m.tastenblockHinterlegt) _mausHintergrund(platz.maxWidth),
            // unter den Tasten: ein Klick in die Lücken und auf den Rahmen zeigt im Hilfe-Modus die Hilfe zur Seite
            if (m.hilfeModus) _rahmenFlaeche(platz.maxWidth, m.hilfeZurSeite),
            // hat die Liste den Rahmen, gibt ein Klick in die Lücken ihn dem Tastenblock (VA-15)
            if (wechselt) _rahmenFlaeche(platz.maxWidth, m.waehleTastenblock),
            _bloecke(m, reihe, oben),
            _funktionsBlock(m, platz.maxWidth, funktionsTaste),
            ...rahmen(platz.maxWidth),
          ],
        ),
      ),
    );
  }

  /// Am PC (auch im Browser auf einem PC) zeigt der Rahmen ▲ ▼, weil das Mausrad senkrecht schiebt (VA-10).
  static bool get _amPc => const {TargetPlatform.windows, TargetPlatform.linux, TargetPlatform.macOS}.contains(defaultTargetPlatform);

  /// Die zehn Funktionstasten über ihren leeren Plätzen in R3 und R4; die Maus darüber färbt den Hintergrund (VA-4).
  Widget _funktionsBlock(RechnerModell m, double breite, Widget Function(int, Taste?) baue) {
    final taste = (breite - 5 * (obenAbstand - 1)) / 6;
    return Positioned(
      // fester Schlüssel: die Hinterlegung davor kommt und geht mit der Maus, der Block (Lage, Einrasten) bleibt
      key: const ValueKey("funktionsblock"),
      left: taste + obenAbstand - 1,
      top: randOben + 2 * (obenHoehe + obenAbstand),
      width: 5 * taste + 4 * (obenAbstand - 1),
      height: 2 * obenHoehe + obenAbstand,
      child: MouseRegion(
        opaque: false,
        onEnter: (e) => m.mausFunktionen(e.kind == PointerDeviceKind.mouse),
        onExit: (_) => m.mausFunktionen(false),
        child: FunktionsBlock(m, taste: taste, spalte: obenAbstand - 1, hoehe: obenHoehe, reihe: obenAbstand, baue: baue),
      ),
    );
  }

  /// Fläche des Rahmens um die zehn Funktionstasten, unter den Tasten; Klicks auf eine Taste erreichen die Taste.
  Widget _rahmenFlaeche(double breite, VoidCallback beiKlick) {
    final taste = (breite - 5 * (obenAbstand - 1)) / 6;
    return Positioned(
      left: taste + obenAbstand - 1 - 4,
      top: randOben + 2 * (obenHoehe + obenAbstand) - 4,
      width: 5 * taste + 4 * (obenAbstand - 1) + 8,
      height: 2 * obenHoehe + obenAbstand + 8,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: beiKlick),
    );
  }

  /// Leicht oranger Hintergrund hinter den zehn Funktionstasten, solange die Maus darüber steht oder der Block zur
  /// Liste mit dem Rahmen gehört (doc/app.md 3.3).
  Widget _mausHintergrund(double breite) {
    final taste = (breite - 5 * (obenAbstand - 1)) / 6;
    return Positioned(
      left: taste + obenAbstand - 1 - 4,
      top: randOben + 2 * (obenHoehe + obenAbstand) - 4,
      width: 5 * taste + 4 * (obenAbstand - 1) + 8,
      height: 2 * obenHoehe + obenAbstand + 8,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(color: Farben.funktionenMaus, borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  /// Die Blöcke untereinander: R1, darunter R2–R5, mit Abstand R6–R9. Im Querformat (FA-5) werden dieselben
  /// Blöcke nur anders angeordnet.
  Widget _bloecke(RechnerModell m, Widget Function(List<Widget>, double) reihe, Widget Function(Taste) oben) {
    return Column(
      children: [
        const SizedBox(height: randOben),
        _r1(m, reihe),
        ..._obererBlock(reihe, oben),
        const SizedBox(height: blockAbstand),
        ..._untererBlock(m, reihe),
      ],
    );
  }

  /// R1: SHIFT, ALPHA, die beiden Ecken neben dem Cursorkreuz, TAB und MENÜ.
  Widget _r1(RechnerModell m, Widget Function(List<Widget>, double) reihe) {
    return reihe([
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
    ], obenAbstand);
  }

  /// R2–R5: die oberen Tasten mit den Funktionstasten in R3 und R4.
  List<Widget> _obererBlock(Widget Function(List<Widget>, double) reihe, Widget Function(Taste) oben) => [
        for (final r in obereTasten) ...[
          const SizedBox(height: obenAbstand),
          reihe([for (final t in r) oben(t)], obenAbstand),
        ],
      ];

  /// R6–R9: Ziffern, Rechenzeichen und ENTER.
  List<Widget> _untererBlock(RechnerModell m, Widget Function(List<Widget>, double) reihe) => [
        for (int i = 0; i < untereTasten.length; i++) ...[
          if (i > 0) const SizedBox(height: untenAbstand),
          reihe([for (final t in untereTasten[i]) TasteWidget(t, m, hoehe: untenHoehe, gross: true)], untenAbstand),
        ],
      ];
}

/// Kleine Taste in der unteren Außenecke neben dem Cursorkreuz (doc/app.md 3.5): rechts Maximieren,
/// links ein Platzhalter. Das Cursorkreuz lässt Tipps auf diese Ecken durch.
class _Ecke extends StatelessWidget {
  final RechnerModell m;
  final bool rechts;
  const _Ecke(this.m, {required this.rechts});

  @override
  Widget build(BuildContext context) {
    // zeigt, was ein Druck bewirkt: geteilt → maximieren □, maximiert → wieder teilen ◫
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
              ? tipp(m.maximiert ? "◫ 2 Seiten" : "□ Vollbild für die markierte Seite", taste(platz.maxWidth))
              : taste(platz.maxWidth),
        ),
      ),
    );
  }
}

const _nameStil = TextStyle(fontSize: 10, height: 1.1, fontWeight: FontWeight.w600, color: Farben.shift);

double _breite(String text, TextStyle stil) =>
    (TextPainter(text: TextSpan(text: text, style: stil), textDirection: TextDirection.ltr)..layout()).width;

/// Der orange Rahmen um die Funktionstasten, unten mit einer Lücke von x = luecke.$1 bis luecke.$2 für den Namen.
class _Rahmen extends CustomPainter {
  final (double, double) luecke;
  const _Rahmen({required this.luecke});

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius((Offset.zero & size).deflate(1), const Radius.circular(12));
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRRect(
      r,
      Paint()
        ..color = Farben.shift
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // die Lücke ausradieren: nur im eigenen Layer, die Tasten darunter bleiben
    canvas.drawRect(Rect.fromLTRB(luecke.$1, size.height - 4, luecke.$2, size.height), Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Rahmen alt) => alt.luecke != luecke;
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
