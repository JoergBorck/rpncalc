/// Aufgabe: die Tasten, die es nur im Menü gibt (doc/app.md 3.6): [MenueBereichTaste] ist ein Bereich des
/// Hauptmenüs auf dem Ziffernblock (Symbol füllt die Taste, die Ziffer groß darüber), [MenueSchalter] eine
/// Bibliothek auf den Funktionstasten mit Symbol, Tastenname oder Name und dem Rahmen, der zeigt, was ENTER bewirkt.
/// [symbolBild] zeichnet das Symbol einer Bibliothek aus seinen Pfaddaten.
///
/// Abgrenzung: Was ein Druck bewirkt und welcher Rahmen gilt, entscheidet das Modell (model/menu.dart); wo die
/// Tasten liegen und welche leer sind, keypad.dart.
///
/// Siehe auch: doc/app.md 3.6, doc/api.md 9.1 (Symbol), process/requirements/FA-30.md.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rpncalc/rpnapi.dart';

import '../colors.dart';
import '../help_texts.dart';
import '../keys.dart';
import '../model/model.dart';
import '../tooltip.dart';

/// Das Symbol einer Bibliothek: die Pfaddaten (vom Rechner geprüft, doc/api.md 9.1) als SVG im Raster 24 × 24, in
/// der Farbe [farbe].
Widget symbolBild(List<SymbolPfad> pfade, Color farbe, double groesse) {
  final svg = StringBuffer('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
      'stroke="#000" stroke-linecap="round" stroke-linejoin="round">');
  for (final p in pfade) {
    svg.write('<path d="${p.d}" stroke-width="${p.breite}"${p.fuellen ? ' fill="#000"' : ''}/>');
  }
  svg.write("</svg>");
  return SvgPicture.string(svg.toString(),
      width: groesse, height: groesse, colorFilter: ColorFilter.mode(farbe, BlendMode.srcIn));
}

/// Ein Bereich des Hauptmenüs auf dem Ziffernblock: hell wie eine Ziffer, das Symbol füllt die Taste, die Ziffer
/// steht groß oben links darüber (ein Stack); im Bereich selbst orange umrandet wie MENÜ (der Pfad).
class MenueBereichTaste extends StatelessWidget {
  final Taste taste;
  final MenuePunkt punkt;
  final RechnerModell m;
  final double hoehe;
  const MenueBereichTaste(this.taste, this.punkt, this.m, {required this.hoehe, super.key});

  @override
  Widget build(BuildContext context) {
    final imPfad = m.imMenuePfad(taste);
    final knopf = Material(
      color: Farben.zifferHell,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: imPfad ? const BorderSide(color: Farben.shift, width: 2.5) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => m.druecke(taste),
        child: SizedBox(
          height: hoehe,
          child: Stack(
            children: [
              // das Symbol unten bündig und etwas nach rechts: der Giebel lässt die Ecke oben links frei
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(left: hoehe * 0.3, top: 2),
                  child: SvgPicture.asset(punkt.symbol,
                      colorFilter: const ColorFilter.mode(Farben.zifferText, BlendMode.srcIn)),
                ),
              ),
              Positioned(
                left: 7,
                top: 1,
                child: Text(taste.text,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Farben.zifferText)),
              ),
            ],
          ),
        ),
      ),
    );
    return tipp("${punkt.name}: Bibliotheken ein- und ausschalten", knopf);
  }
}

/// Eine Bibliothek im Bereich Bibliotheken: ein Schalter auf einer Funktionstaste (doc/app.md 3.6).
class MenueSchalter extends StatelessWidget {
  final Taste taste;
  final RechnerModell m;
  final double hoehe;
  const MenueSchalter(this.taste, this.m, {required this.hoehe, super.key});

  @override
  Widget build(BuildContext context) {
    final name = taste.text;
    final info = m.menueInfo(name);
    final rahmen = m.menueRahmen(name);
    final (farbe, breite) = switch (rahmen) {
      MenueRahmen.gewaehlt => (Farben.shift, 3.5),
      MenueRahmen.laden => (Farben.rahmenGruen, 2.0),
      MenueRahmen.entladen => (Farben.rahmenRot, 2.0),
      MenueRahmen.geladen => (Farben.rahmenWeiss, 2.0),
      MenueRahmen.keiner => (Colors.transparent, 0.0),
    };
    // Beschriftung: das Symbol, sonst der Tastenname, sonst der Name (FittedBox verkleinert, was nicht passt)
    final symbol = info?.symbol ?? const [];
    final Widget inhalt = symbol.isNotEmpty
        ? symbolBild(symbol, Farben.tasteText, hoehe * 0.68)
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(info?.taste ?? name,
                  maxLines: 1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Farben.tasteText)),
            ),
          );
    final knopf = Material(
      color: Farben.funktion,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: breite > 0 ? BorderSide(color: farbe, width: breite) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => m.druecke(taste),
        child: SizedBox(
          height: hoehe,
          child: Stack(
            children: [
              Center(child: inhalt),
              // wird entladen: ein schräger roter Strich über der Taste, damit es nicht nur an der Farbe hängt
              if (rahmen == MenueRahmen.entladen)
                const Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _Strich()))),
            ],
          ),
        ),
      ),
    );
    final tippZeilen = AppHilfe.tippBibliothek(m.api, name);
    return tippZeilen.isEmpty ? tipp(info?.beschreibung ?? name, knopf) : tippTabelle(tippZeilen, knopf);
  }
}

/// Der schräge Strich über einer Bibliothek, die entladen wird: von links unten nach rechts oben.
class _Strich extends CustomPainter {
  const _Strich();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(4, size.height - 4),
      Offset(size.width - 4, 4),
      Paint()
        ..color = Farben.rahmenRot
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_Strich alt) => false;
}
