/// Aufgabe: die zehn Funktionstasten als verschiebbarer Block (VA-10). [FunktionsBlock] zeichnet die Tasten der
/// gezeigten Seite und, beim Schieben, die der Nachbarseite in einem beschnittenen Bereich, dazwischen eine
/// Trennlinie. Am Handy schiebt Wischen waagrecht: die Tasten folgen dem Finger in Spaltenschritten und rasten beim
/// Loslassen auf der Seite ein, von der mehr als die Hälfte zu sehen ist; mit Schwung laufen sie bis zur nächsten
/// Seite nach, im Kreis. Am PC schiebt das Mausrad senkrecht, je Raste eine drittel Seite, und rastet auf einer
/// ganzen Seite ein; an der ersten und letzten Seite hält es an.
///
/// Abgrenzung: Welche Taste auf welcher Seite liegt und welche Seite gilt, weiß das Modell (assignment.dart,
/// `funktionstastenAuf`, `zeigeFunktionsSeite`); eine Taste zeichnet key_widget.dart, den Rahmen keypad.dart.
///
/// Siehe auch: doc/app.md 3.3, keypad.dart, model/assignment.dart.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../colors.dart';
import '../keys.dart';
import '../model/model.dart';
import '../tooltip.dart';

/// Die zehn Funktionstasten (zwei Reihen zu fünf), verschiebbar mit Wischen und Mausrad.
class FunktionsBlock extends StatefulWidget {
  final RechnerModell m;

  /// Breite einer Taste, Abstand zwischen zwei Tasten einer Reihe, Höhe einer Taste und Abstand der Reihen.
  final double taste, spalte, hoehe, reihe;

  /// Baut die Taste für den Platz [platz] (0–9) mit der Belegung [belegt].
  final Widget Function(int platz, Taste? belegt) baue;

  const FunktionsBlock(this.m,
      {required this.taste,
      required this.spalte,
      required this.hoehe,
      required this.reihe,
      required this.baue,
      super.key});

  /// So weit schiebt eine Raste des Mausrads, in Seiten.
  static const double rasteMausrad = 1 / 3;

  /// So lange muss das Mausrad ruhen, bis die Tasten auf einer Seite einrasten (VA-13).
  static const ruheMausrad = Duration(milliseconds: 500);

  @override
  State<FunktionsBlock> createState() => _FunktionsBlockState();
}

class _FunktionsBlockState extends State<FunktionsBlock> with SingleTickerProviderStateMixin {
  /// Die Lage in Seiten: 0 ist die erste Seite, 1,5 zeigt die zweite halb und die dritte halb. Beim Wischen
  /// zählt sie über das Ende hinaus weiter (im Kreis), beim Mausrad bleibt sie zwischen erster und letzter Seite.
  double _lage = 0;
  bool _senkrecht = false; // zuletzt mit dem Mausrad geschoben
  late final AnimationController _lauf = AnimationController.unbounded(vsync: this)..addListener(_beimLauf);
  Timer? _ruhe;
  double _start = 0; // Lage beim Beginn des Wischens
  double _finger = 0; // Weg des Fingers in Seiten seit Beginn; die Lage folgt ihm in Spaltenschritten

  /// Ziel, wenn die Tasten gleiten, weil das Modell eine Seite gewählt hat (◄ ► ▲ ▼); solange melden sie keine
  /// Seite zurück, und ein weiterer Tastendruck rechnet von hier aus weiter (VA-14).
  double? _ziel;

  /// Die Seite, die das Modell zuletzt gezeigt hat, und woran man eine neue Domäne erkennt.
  int _seite = 0;
  (String, int) _inhalt = ("", 0);

  RechnerModell get m => widget.m;
  int get _seiten => m.funktionsSeiten;
  double get _breiteSeite => 5 * (widget.taste + widget.spalte); // eine Seite weiter: auch die Lücke danach
  double get _hoeheSeite => 2 * (widget.hoehe + widget.reihe);

  @override
  void initState() {
    super.initState();
    _seite = m.funktionsSeite;
    _lage = _seite.toDouble();
    _inhalt = (m.domaene, _seiten);
  }

  @override
  void dispose() {
    _ruhe?.cancel();
    _lauf.dispose();
    super.dispose();
  }

  /// Übernimmt eine Seite, die das Modell von sich aus gewählt hat (◄ ►, neue Domäne).
  void _vomModell() {
    final inhalt = (m.domaene, _seiten);
    if (inhalt != _inhalt || !m.funktionenBlaetterbar) {
      // neue Domäne oder andere Zahl von Seiten: ohne Bewegung an die neue Stelle
      _inhalt = inhalt;
      _lauf.stop();
      _seite = m.funktionsSeite;
      _lage = _seite.toDouble();
      return;
    }
    if (m.funktionsSeite == _seite) return;
    // ▲ ▼ schieben senkrecht wie das Mausrad, ◄ ► waagrecht wie das Wischen (VA-14)
    if (m.funktionenSenkrecht != _senkrecht) {
      _senkrecht = m.funktionenSenkrecht;
      _lage = ((_lage.round() % _seiten + _seiten) % _seiten).toDouble();
      _ziel = null;
    }
    // zur neuen Seite auf dem kürzesten Weg, im Kreis: von der letzten mit ► vorwärts zur ersten; gleiten die
    // Tasten schon, vom Ziel aus, damit schnell hintereinander gedrückte Tasten alle zählen
    final n = _seiten;
    final von = _ziel ?? _lage.roundToDouble();
    var ziel = von + ((m.funktionsSeite - von.round()) % n + n) % n;
    if (ziel - von > n / 2) ziel -= n;
    _seite = m.funktionsSeite;
    _ziel = ziel;
    // nicht während build: die Animation ruft setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _laufZu(ziel);
    });
  }

  void _laufZu(double ziel, {Duration dauer = const Duration(milliseconds: 180)}) {
    if (ziel != _ziel) _ziel = null; // vom Benutzer (Mausrad, Wischen): die Seite wird unterwegs gemeldet
    _lauf.value = _lage;
    _lauf.animateTo(ziel, duration: dauer, curve: Curves.easeOut).whenComplete(() {
      _ziel = null;
      if (mounted) _rahmen(); // der Rahmen bleibt nach dem Einrasten noch kurz
    });
  }

  /// Zeigt den Rahmen, solange geschoben wird (doc/app.md 3.3); das Modell blendet ihn danach aus.
  void _rahmen() => m.zeigeFunktionsSeite(m.funktionsSeite);

  void _beimLauf() {
    setState(() => _lage = _lauf.value);
    if (_ziel == null) _melden();
  }

  /// Sagt dem Modell, welche Seite gilt: die, von der mehr als die Hälfte zu sehen ist.
  void _melden() {
    final n = _seiten;
    final s = (_lage.round() % n + n) % n;
    if (s == _seite) return;
    _seite = s;
    m.zeigeFunktionsSeite(s);
  }

  void _schiebe(double seiten, {required bool begrenzt}) {
    _lauf.stop();
    _ziel = null; // Mausrad oder Wischen unterbrechen ein Gleiten zu einer Seite des Modells
    TippSperre.sperren(); // keine Tooltips der Tasten, solange geschoben wird
    setState(() {
      _lage += seiten;
      if (begrenzt) _lage = _lage.clamp(0, (_seiten - 1).toDouble());
    });
    _melden();
    if (!m.funktionenHinweis) _rahmen();
  }

  void _mausrad(PointerSignalEvent e) {
    if (e is! PointerScrollEvent || e.scrollDelta.dy == 0 || !m.funktionenBlaetterbar) return;
    if (!_senkrecht) {
      _senkrecht = true;
      // eine spaltenweise Lage vom Wischen gilt beim Mausrad als ganze Seite, im Kreis zurückgerechnet
      _lage = ((_lage.round() % _seiten + _seiten) % _seiten).toDouble();
    }
    final nachUnten = e.scrollDelta.dy > 0;
    _schiebe(nachUnten ? FunktionsBlock.rasteMausrad : -FunktionsBlock.rasteMausrad, begrenzt: true);
    // ruht das Rad eine halbe Sekunde, rastet es ein, und zwar in Drehrichtung: eine angefangene Seite wird in der
    // Richtung vollendet, in die zuletzt gedreht wurde; eine Raste blättert so genau eine Seite (VA-13)
    _ruhe?.cancel();
    _ruhe = Timer(FunktionsBlock.ruheMausrad, () {
      if (mounted) _laufZu(nachUnten ? _lage.ceilToDouble() : _lage.floorToDouble());
    });
  }

  void _wischenEnde(DragEndDetails d) {
    if (!m.funktionenBlaetterbar) return;
    final v = -d.velocity.pixelsPerSecond.dx; // nach links wischen: die nächste Seite kommt
    double ziel;
    if (v.abs() > 100) {
      // mit Schwung: läuft nach bis zur nächsten ganzen Seite in Richtung des Wischens, eine Seite weiter als beim
      // Beginn (wie beim Startbildschirm am Handy; das Tempo entscheidet zwischen seiten- und spaltenweise)
      ziel = v > 0 ? math.max(_start + 1, _lage.ceilToDouble()) : math.min(_start - 1, _lage.floorToDouble());
    } else {
      ziel = _lage.roundToDouble(); // langsam losgelassen: die Seite, von der mehr als die Hälfte zu sehen ist
    }
    final dauer = Duration(milliseconds: (150 + 120 * (ziel - _lage).abs()).clamp(150, 600).round());
    _laufZu(ziel, dauer: dauer);
  }

  @override
  Widget build(BuildContext context) {
    _vomModell();
    final n = _seiten;
    final blaettert = m.funktionenBlaetterbar && n > 1;
    final ganz = blaettert ? _lage.floorToDouble() : 0.0;
    final anteil = blaettert ? _lage - ganz : 0.0;
    final erste = blaettert ? ganz.toInt() : m.funktionsSeite;

    Widget seite(int s) {
      final belegt = m.funktionstastenAuf(s);
      return Stack(children: [
        for (int i = 0; i < 10; i++)
          Positioned(
            left: (i % 5) * (widget.taste + widget.spalte),
            top: (i ~/ 5) * (widget.hoehe + widget.reihe),
            width: widget.taste,
            height: widget.hoehe,
            child: widget.baue(i, belegt[i]),
          ),
      ]);
    }

    final schritt = _senkrecht ? Offset(0, _hoeheSeite) : Offset(_breiteSeite, 0);
    return Listener(
      behavior: HitTestBehavior.translucent, // das Mausrad auch über den Lücken, z.B. mitten im Schieben
      onPointerSignal: _mausrad,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent, // Tipps in die Lücken gehen an die Fläche darunter (Hilfe-Modus)
        onHorizontalDragStart: blaettert ? (_) {
          _lauf.stop();
          _ruhe?.cancel();
          _senkrecht = false;
          _start = _lage.roundToDouble();
          _lage = _start;
          _finger = 0;
        } : null,
        onHorizontalDragUpdate: blaettert
            ? (d) {
                // der Finger zählt genau, gezeigt wird in ganzen Spalten (BA-10)
                _finger += -d.delta.dx / _breiteSeite;
                final ziel = _start + (_finger * 5).roundToDouble() / 5;
                if (ziel != _lage) _schiebe(ziel - _lage, begrenzt: false);
              }
            : null,
        onHorizontalDragEnd: blaettert ? _wischenEnde : null,
        child: ClipRect(
          child: Stack(
            children: [
              Positioned.fill(child: Transform.translate(offset: schritt * -anteil, child: seite(erste))),
              if (anteil > 0) ...[
                Positioned.fill(child: Transform.translate(offset: schritt * (1 - anteil), child: seite(erste + 1))),
                // die Trennlinie zwischen den beiden Seiten, mitten in der Lücke
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _Trennlinie(
                        _senkrecht
                            ? _hoeheSeite * (1 - anteil) - widget.reihe / 2
                            : _breiteSeite * (1 - anteil) - widget.spalte / 2,
                        senkrecht: _senkrecht,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Die Trennlinie zwischen zwei Seiten: dünn, orange, halb durchsichtig wie der Rahmen.
class _Trennlinie extends CustomPainter {
  final double lage;
  final bool senkrecht; // die Seiten liegen übereinander, die Linie ist waagrecht
  const _Trennlinie(this.lage, {required this.senkrecht});

  @override
  void paint(Canvas canvas, Size size) {
    final stift = Paint()
      ..color = Farben.shift.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    if (senkrecht) {
      canvas.drawLine(Offset(0, lage), Offset(size.width, lage), stift);
    } else {
      canvas.drawLine(Offset(lage, 0), Offset(lage, size.height), stift);
    }
  }

  @override
  bool shouldRepaint(_Trennlinie alt) => alt.lage != lage || alt.senkrecht != senkrecht;
}
