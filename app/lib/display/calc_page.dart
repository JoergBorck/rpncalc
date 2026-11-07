/// Aufgabe: die Seite Rechnen der Anzeige: links die Eingabe mit Verlauf, rechts der Stack, die Schriftgröße
/// nach unten kleiner; Pfeile zeigen, dass es seitlich oder nach oben und unten weitergeht. Antippen wählt den
/// Bereich, im Hilfe-Modus zeigt es die Hilfe zur Zeile; Rechtsklick bzw. langes Drücken öffnet das Kontextmenü.
///
/// Abgrenzung: Ausschnitte, Versatz und Schieben berechnet das Modell (model/model.dart); diese Datei zeichnet
/// nur. Das Kontextmenü steht in context_menu.dart.
///
/// Siehe auch: doc/app.md Kapitel 2 und 3, context_menu.dart.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rpncalc/rpnapi.dart';

import '../colors.dart';
import '../help_texts.dart';
import '../model/model.dart';
import '../tooltip.dart';
import 'context_menu.dart';

/// Seite „Rechnen“: links die Eingabezeilen, rechts der Stack, oben die aktuelle Zeile neben dem Tos,
/// nach unten mit kleinerer Schrift. Lange Zeilen zeigen einen Ausschnitt, den ◄ und ► verschieben.
class RechnenSeite extends StatelessWidget {
  final RechnerModell m;
  const RechnenSeite(this.m, {super.key});

  static const _groessen = <double>[24, 21, 19, 17, 15.5, 14, 13, 12, 11.5, 11, 10.5, 10, 10, 10];
  static const _zeichenBreite = 0.55; // Breite eines Zeichens der Monospace-Schrift relativ zur Größe
  static const _luecke = 14.0; // zwischen Eingabe und Stack
  // Tooltips der beiden Bereiche, auf jeder Zeile und auf dem Namen am Rahmen (doc/app.md 5.1)
  static const _wechsel = [("TAB", "wählt den Bereich, ebenso Antippen")];
  static final _tippEingabe = AppHilfe.tippEintrag("app:eingabe", "Eingabe", zusatz: _wechsel);
  static final _tippStack = AppHilfe.tippEintrag("app:stack", "Stack", zusatz: _wechsel);

  static const _nummer = 24.0;
  static const _nameUnten = 10.0; // Platz unter den Zeilen, damit der Name am Rahmen die Maus annimmt // Breite der Namen der Stack-Positionen am rechten Rand

  static int _zeichen(double breite, double g) => (breite / (g * _zeichenBreite)).floor().clamp(1, 999);

  @override
  Widget build(BuildContext context) {
    // beim Maximieren gleiten die Spalten auf ihre neue Breite (doc/app.md 3.5)
    return LayoutBuilder(
      builder: (context, platz) => TweenAnimationBuilder<double>(
        tween: Tween(end: m.anteilEingabe),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        builder: (context, anteil, _) => _inhalt(platz, anteil),
      ),
    );
  }

  /// Die Seite bei einem Anteil der Eingabe an der Breite von 0 (Stack maximiert) bis 1 (Eingabe maximiert).
  Widget _inhalt(BoxConstraints platz, double anteil) {
    final innen = platz.maxWidth - 24;
    final luecke = _luecke * (4 * anteil * (1 - anteil)).clamp(0.0, 1.0); // maximiert ohne Lücke
    final links = (innen - luecke) * anteil;
    final rechts = innen - luecke - links;
    final z = m.zustand;

    // zuerst feststellen, wie viele Zeilen passen, damit das Modell den Platz je Zeile kennt
    final fehler = z.fehler != null && !z.zeileFertig;
    final groessen = <double>[];
    double hoehe = fehler ? 14 : 0;
    // nach der Liste geht es mit der kleinsten Größe weiter, bis die Höhe gefüllt ist (doc/app.md Punkt 23)
    final maxZeilen = platz.maxHeight.isFinite ? 200 : _groessen.length;
    for (var i = 0; i < maxZeilen; i++) {
      final g = _groessen[i.clamp(0, _groessen.length - 1)];
      // 8 oben für ENTER↑ auf dem Rahmen, unten der Platz für den Namen am Rahmen
      if (hoehe + g * 1.3 > platz.maxHeight - 12 - _nameUnten) break;
      hoehe += g * 1.3;
      groessen.add(g);
    }
    final enter = z.enterVorgemerkt && !z.zeileFertig;
    // der Umbruch richtet sich immer nach der halben Breite, auch wenn eine Spalte maximiert ist
    m.zeichenProZeile = _zeichen((innen - _luecke) / 2, _groessen[0]);
    m.platzEingabe = [
      for (int r = 0; r < groessen.length; r++) _zeichen(links, groessen[r]) - (r == 0 ? 1 : 0), // der Cursor
    ];
    m.platzStack = [for (final g in groessen) _zeichen(rechts - _nummer - 10, g)];

    final zeilen = <Widget>[];
    for (int r = 0; r < groessen.length; r++) {
      final g = groessen[r];
      zeilen.add(
        SizedBox(
          height: g * 1.3,
          child: Row(
            children: [
              // ein Tipp wählt den Bereich, ein Doppelklick maximiert bzw. teilt (3.5); im Hilfe-Modus zeigt er die
              // Hilfe zu Zeile bzw. Wert (doc/app.md 3.3, 5.3); volle Zeilenhöhe, damit auch leere Zeilen den Tipp
              // annehmen
              tippTabelle(
                _tippEingabe,
                langesDruecken: false, // langes Drücken öffnet das Kontextmenü (doc/app.md 2.1)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => m.hilfeModus ? m.zeigeHilfe(_hilfeEingabe(r)) : m.tippeBereich(Bereich.eingabe),
                  child: Kontextmenue(
                    m,
                    stack: false,
                    zeile: r,
                    hilfe: () => _hilfeEingabe(r),
                    child: SizedBox(
                      width: links,
                      height: g * 1.3,
                      child: r == 0 ? _aktuelleZeile(z, g) : _alteZeile(r, g),
                    ),
                  ),
                ),
              ),
              SizedBox(width: luecke),
              tippTabelle(
                _tippStack,
                langesDruecken: false,
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => m.hilfeModus ? m.zeigeHilfe(_hilfeStack(r)) : m.tippeBereich(Bereich.stack),
                  child: Kontextmenue(
                    m,
                    stack: true,
                    zeile: r,
                    hilfe: () => _hilfeStack(r),
                    child: SizedBox(
                      width: rechts,
                      height: g * 1.3,
                      child: rechts < _nummer + 12 ? null : _stackZeile(r, g), // zu schmal: leer
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      if (r == 0 && fehler) {
        zeilen.add(
          SizedBox(
            height: 14,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "^ ${z.fehler!.text}",
                style: Schrift.monospace(10, Farben.fehler),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }
    }

    // der gewählte Bereich (Eingabe oder Stack) bekommt einen Rahmen, Pfeile zeigen, wohin ◄ und ► schieben
    final rahmen = switch (m.bereich) {
      Bereich.eingabe => (links: 0.0, breite: links, name: "Eingabe", hilfe: "app:eingabe", aussenLinks: true),
      Bereich.stack => (links: links + luecke, breite: rechts, name: "Stack", hilfe: "app:stack", aussenLinks: false),
      _ => null,
    };
    Widget pfeil(IconData icon) => Container(
      color: Farben.anzeige,
      child: Icon(icon, size: 18, color: Farben.shift),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // unten etwas Platz, damit der Name auf dem Rahmen ganz im Bereich liegt und die Maus annimmt
          // senkrecht wischen und das Mausrad schieben Eingabe bzw. Stack zeilenweise (doc/app.md 3.3)
          _Wischen(
            m,
            grenze: links + luecke / 2,
            zeile: (groessen.length > 2 ? groessen[2] : _groessen[2]) * 1.3,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...zeilen, const SizedBox(height: _nameUnten)]),
          ),
          // ein vorgemerktes Enter steht rechts oben auf dem Rahmen der Eingabe, nicht in der Zeile
          if (enter)
            Positioned(
              right: innen - links + 2,
              top: -7,
              child: tipp(
                "Enter vorgemerkt: das nächste Token entscheidet, ob kopiert wird",
                Container(
                  color: Farben.anzeige,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text("ENTER↑", style: Schrift.monospace(10, Farben.anzeigeText, gewicht: FontWeight.w600)),
                ),
              ),
            ),
          if (rahmen != null) ...[
            Positioned(
              left: rahmen.links - 5,
              width: rahmen.breite + 10,
              top: 0,
              height: hoehe + 2,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Farben.shift.withValues(alpha: 0.7), width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            // der Name des Bereichs unten auf dem Rahmen, mit Tooltip (doc/app.md 7, Punkt 12)
            Positioned(
              left: rahmen.aussenLinks ? rahmen.links + 4 : null,
              right: rahmen.aussenLinks ? null : innen - rahmen.links - rahmen.breite + 4,
              top: hoehe + 2 - 7,
              child: tippTabelle(
                AppHilfe.tippEintrag(rahmen.hilfe, rahmen.name, zusatz: _wechsel),
                Container(
                  color: Farben.anzeige,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(rahmen.name, style: Schrift.monospace(10, Farben.shift, gewicht: FontWeight.w600)),
                ),
              ),
            ),
            if (m.kannSchieben(false))
              Positioned(
                left: rahmen.links - 14,
                top: hoehe / 2 - 9,
                child: tipp("mit ◄ nach rechts schieben, zum Anfang", pfeil(Icons.arrow_left)),
              ),
            if (m.kannSchieben(true))
              Positioned(
                left: rahmen.links + rahmen.breite - 4,
                top: hoehe / 2 - 9,
                child: tipp("mit ► nach links schieben, zum Ende", pfeil(Icons.arrow_right)),
              ),
          ],
        ],
      ),
    );
  }

  /// Hilfe zu einer Zeile der Eingabe: eine alte Zeile ganz, sonst die Hilfe zur Anzeige „Eingabe“.
  List<Hilfe> _hilfeEingabe(int r) {
    final text = m.eingabeText(r);
    return r > 0 && text.isNotEmpty ? AppHilfe.zeile(text) : AppHilfe.nachschlagen(m.api, "app:eingabe");
  }

  /// Hilfe zu einer Zeile des Stacks: der Wert, das offene Token oder die Hilfe zur Anzeige „Stack“.
  List<Hilfe> _hilfeStack(int r) {
    if (r == 0 && m.offenesToken != null) return AppHilfe.nachschlagen(m.api, "app:stack");
    final s = m.stackZeile(r);
    return s == null ? AppHilfe.nachschlagen(m.api, "app:stack") : AppHilfe.stackWert(m.api, s);
  }

  /// Die aktuelle Zeile mit Fehlermarkierung und Cursor.
  Widget _aktuelleZeile(Zustand z, double g) {
    final text = m.eingabeText(0);
    final von = m.eingabeVon(0);
    final sicht = RechnerModell.ausschnitt(text, von, m.platzEingabe[0]);
    final stil = Schrift.monospace(g, Farben.anzeigeText);
    final f = z.zeileFertig ? null : z.fehler;
    final spans = <InlineSpan>[];
    if (f != null && f.start >= 0 && f.start <= text.length) {
      // Stellen im Ausschnitt: der Ausschnitt beginnt bei von und ist Zeichen für Zeichen gleich lang
      int stelle(int i) => (i - (text.length <= m.platzEingabe[0] ? 0 : von)).clamp(0, sicht.length);
      final a = stelle(f.start), e = stelle(f.start + f.token.length);
      spans.addAll([
        TextSpan(text: sicht.substring(0, a)),
        TextSpan(
          text: sicht.substring(a, e),
          style: const TextStyle(backgroundColor: Farben.fehler, color: Color(0xFF200000)),
        ),
        TextSpan(
          text: sicht.substring(e),
          style: const TextStyle(color: Farben.anzeigeBlass),
        ),
      ]);
    } else {
      spans.add(TextSpan(text: sicht));
    }
    spans.add(
      const TextSpan(
        text: "▌",
        style: TextStyle(color: Farben.shift),
      ),
    );
    return Text.rich(
      TextSpan(style: stil, children: spans),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
    );
  }

  Widget _alteZeile(int r, double g) {
    final text = m.eingabeText(r);
    return Text(
      RechnerModell.ausschnitt(text, m.eingabeVon(r), m.platzEingabe[r]),
      style: Schrift.monospace(g, Farben.anzeigeText),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
    );
  }

  /// Position links, der Wert rechtsbündig; kleinere Zeilen rücken so nach rechts. Der Tos ist hinterlegt.
  /// Ein offenes Token steht grau mit `>:` in der obersten Zeile, die Werte darunter (doc/app.md Kapitel 2).
  Widget _stackZeile(int r, double g) {
    final offen = r == 0 && m.offenesToken != null;
    final s = offen ? null : m.stackZeile(r);
    final position = m.stackPosition(r);
    // x bis ₆ haben auch leer ihren Namen, damit der Übergang von t zu ₄ klar ist (doc/app.md Kapitel 2)
    if (!offen && s == null && (position < 0 || position > 6)) return const SizedBox();
    final tos = s != null && s.position == 0;
    final sicht = RechnerModell.ausschnitt(m.stackText(r), m.stackVon(r), m.platzStack[r]);
    final wert = Text(
      sicht,
      style: Schrift.monospace(
        g,
        offen
            ? Farben.anzeigeBlass
            : tos
            ? Farben.tosText
            : Farben.anzeigeText,
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
    );
    final name = SizedBox(
      width: _nummer,
      child: tipp(
        offen ? "aktuelle Eingabe, liegt noch nicht auf dem Stack" : "",
        Text(
          offen ? ">:" : positionsName(position, symbol: false),
          textAlign: TextAlign.left,
          style: Schrift.monospace(g * 0.7, Farben.anzeigeBlass),
        ),
      ),
    );
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: tos
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(color: Farben.tosHinten, borderRadius: BorderRadius.circular(3)),
                    child: wert,
                  )
                : Padding(padding: const EdgeInsets.only(right: 4), child: wert),
          ),
        ),
        name, // die Namen x y z t … stehen am rechten Rand (doc/app.md Kapitel 2)
      ],
    );
  }
}

/// Senkrechtes Wischen und Mausrad in Eingabe und Stack (doc/app.md 3.3): der Inhalt folgt dem Finger in
/// Zeilenschritten von [zeile] Pixeln, nach einer schnellen Bewegung läuft er nach (Physik wie bei Listen am Handy)
/// und hält am Anfang bzw. Ende an. Links von [grenze] ist die Eingabe, rechts der Stack.
class _Wischen extends StatefulWidget {
  final RechnerModell m;
  final double grenze, zeile;
  final Widget child;
  const _Wischen(this.m, {required this.grenze, required this.zeile, required this.child});

  @override
  State<_Wischen> createState() => _WischenState();
}

class _WischenState extends State<_Wischen> with SingleTickerProviderStateMixin {
  late final Ticker _uhr = createTicker(_nachlauf);
  Bereich _bereich = Bereich.eingabe;
  double _rest = 0; // Weg seit dem letzten Zeilenschritt in Pixeln, positiv nach oben
  Simulation? _lauf;
  double _gelaufen = 0;

  Bereich _bereichBei(Offset p) => p.dx < widget.grenze ? Bereich.eingabe : Bereich.stack;

  /// Schiebt um [weg] Pixel; liefert false, wenn ein Zeilenschritt fällig war, aber nichts mehr ging (Ende).
  bool _schiebe(double weg) {
    _rest += weg;
    final schritte = (_rest / widget.zeile).truncate();
    if (schritte == 0) return true;
    _rest -= schritte * widget.zeile;
    return widget.m.schiebeZeilen(_bereich, schritte);
  }

  void _nachlauf(Duration zeit) {
    final lauf = _lauf;
    if (lauf == null) return _uhr.stop();
    final t = zeit.inMicroseconds / 1e6;
    final x = lauf.x(t);
    final weiter = _schiebe(x - _gelaufen);
    _gelaufen = x;
    if (!weiter || lauf.isDone(t)) _uhr.stop();
  }

  @override
  void dispose() {
    _uhr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // das Mausrad: je Raste eine Zeile, nach unten gedreht wie nach oben gewischt
      onPointerSignal: (e) {
        if (e is! PointerScrollEvent || e.scrollDelta.dy == 0) return;
        _uhr.stop();
        // wie nach dem Kontextmenü: kein Tooltip, bis die Maus ein anderes Element betritt (BA-11)
        TippSperre.bisMausWechselt(e.position);
        widget.m.schiebeZeilen(_bereichBei(e.localPosition), e.scrollDelta.dy > 0 ? 1 : -1);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        dragStartBehavior: DragStartBehavior.down, // der Weg zählt ab dem Aufsetzen: der Inhalt folgt dem Finger
        onVerticalDragStart: (d) {
          _uhr.stop();
          _rest = 0;
          _bereich = _bereichBei(d.localPosition);
          if (!widget.m.hilfeModus) widget.m.waehleBereich(_bereich); // wählt den Bereich wie ein Tipp
        },
        onVerticalDragUpdate: (d) => _schiebe(-d.delta.dy),
        onVerticalDragEnd: (d) {
          final v = -d.velocity.pixelsPerSecond.dy;
          if (v.abs() < 100 || widget.m.hilfeModus) return;
          _lauf = ClampingScrollSimulation(position: 0, velocity: v);
          _gelaufen = 0;
          _uhr.start();
        },
        child: widget.child,
      ),
    );
  }
}
