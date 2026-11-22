/// Aufgabe: die Tasten, die es nur im Menü gibt (doc/app.md 3.6): [MenueBereichTaste] ist ein Bereich des
/// Hauptmenüs auf dem Ziffernblock (Symbol füllt die Taste, die Ziffer groß darüber), [MenueSchalter] eine
/// Bibliothek auf den Funktionstasten mit Symbol, Tastenname oder Name und dem Rahmen, der zeigt, was ENTER bewirkt,
/// [MenueModusTaste] ein Modus im Bereich Modi (FA-32).
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
    return tipp(punkt.bereich == MenueBereich.modi ? "${punkt.name}: Format, Winkel und weitere Einstellungen" : "${punkt.name}: Bibliotheken ein- und ausschalten", knopf);
  }
}

/// Eine Bibliothek im Bereich Bibliotheken: ein Schalter auf einer Funktionstaste (doc/app.md 3.6).
class MenueSchalter extends StatelessWidget {
  final Taste taste;
  final RechnerModell m;
  final double hoehe;
  /// der Buchstabe des Platzes, mit dem man die Taste am PC drückt (f–j, l–p)
  final String? buchstabe;
  const MenueSchalter(this.taste, this.m, {required this.hoehe, this.buchstabe, super.key});

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
              if (buchstabe != null) Positioned(left: 5, top: 2, child: _buchstabe(buchstabe!)),
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

/// Ein Modus im Bereich Modi: eine Auswahl auf einer Funktionstaste (doc/app.md 3.6, FA-32). Grundform Symbol mit
/// dem Wert darunter; Bruch zeigt ein Bild je Wert, Trenner die Zahl 1000 im gewählten Format, Klasse „∈“ vor dem
/// Wert. Ein Platzhalter ist ausgegraut und ohne Rahmen.
class MenueModusTaste extends StatelessWidget {
  final Taste taste;
  final RechnerModell m;
  final double hoehe;
  /// der Buchstabe des Platzes, mit dem man die Taste am PC drückt (f–j, l–p)
  final String? buchstabe;
  const MenueModusTaste(this.taste, this.m, {required this.hoehe, this.buchstabe, super.key});

  @override
  Widget build(BuildContext context) {
    final feld = modusFeld(taste.text)!;
    final wert = m.modusWert(feld.name);
    final rahmen = m.menueRahmen(feld.name);
    final (rahmenFarbe, breite) = switch (rahmen) {
      MenueRahmen.gewaehlt => (Farben.shift, 3.5),
      MenueRahmen.laden => (Farben.rahmenGruen, 2.0),
      MenueRahmen.geladen => (Farben.rahmenWeiss, 2.0),
      _ => (Colors.transparent, 0.0),
    };
    final farbe = feld.aktiv ? Farben.tasteText : Farben.gedimmt;
    Widget bild(String asset, double groesse) => SvgPicture.asset(asset,
        width: groesse, height: groesse, colorFilter: ColorFilter.mode(farbe, BlendMode.srcIn));
    final Widget inhalt = switch (feld.name) {
      "Bruch" => bild(bruchBilder[wert]!, hoehe * 0.68),
      "Trenner" => Text(wert, maxLines: 1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: farbe)),
      _ => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            bild(feld.symbol, hoehe * 0.46),
            Text(feld.name == "Klasse" ? "∈ $wert" : m.modusBeschriftung(feld.name),
                maxLines: 1, style: TextStyle(fontSize: 10, height: 1.1, fontWeight: FontWeight.w600, color: farbe)),
          ],
        ),
    };
    final knopf = Material(
      color: Farben.funktion,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: breite > 0 ? BorderSide(color: rahmenFarbe, width: breite) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => m.druecke(taste),
        child: SizedBox(
          height: hoehe,
          child: Stack(
            children: [
              Center(child: FittedBox(fit: BoxFit.scaleDown, child: Padding(padding: const EdgeInsets.all(2), child: inhalt))),
              if (buchstabe != null) Positioned(left: 5, top: 2, child: _buchstabe(buchstabe!)),
            ],
          ),
        ),
      ),
    );
    return tipp(
        feld.aktiv
            ? "${feld.name}: ${feld.werte.join(", ")} · Taste${buchstabe == null ? "" : " oder $buchstabe"} schaltet weiter, "
                "Shift${buchstabe == null ? "" : " bzw. ${buchstabe!.toUpperCase()}"} zurück"
            : "${feld.name}: kommt mit ${feld.spaeter}",
        knopf);
  }
}

/// Eine Ziffer im Bereich Modi, solange Format gewählt ist (Grundregel „Zahlen im Menü“, FA-32): hell wie eine
/// Ziffer, sie setzt die Stellen. ê zeigt 12, „.“ die größte Stellenzahl. Die eingestellte Zahl ist dunkel
/// umrandet; auf 8 steht klein das Symbol der Modi auf orangem Kasten, damit der Pfad nicht abreißt.
class MenueZifferTaste extends StatelessWidget {
  final Taste taste;
  final RechnerModell m;
  final double hoehe;
  const MenueZifferTaste(this.taste, this.m, {required this.hoehe, super.key});

  @override
  Widget build(BuildContext context) {
    final n = m.menueZiffer(taste)!;
    final gewaehlt = n == m.menueStellen;
    final pfad = m.imMenuePfad(taste);
    final knopf = Material(
      color: Farben.zifferHell,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: gewaehlt ? const BorderSide(color: Farben.zifferText, width: 3) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => m.druecke(taste),
        child: SizedBox(
          height: hoehe,
          child: Stack(
            children: [
              Center(
                child: Text("$n",
                    style: TextStyle(fontSize: n > 9 ? 17 : 21, fontWeight: FontWeight.w600, color: Farben.zifferText)),
              ),
              if (pfad)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 19,
                    height: 19,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Farben.shift, borderRadius: BorderRadius.circular(4)),
                    child: SvgPicture.asset("assets/icons/modi.svg",
                        colorFilter: const ColorFilter.mode(Farben.zifferText, BlendMode.srcIn)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return tipp(n > 9 ? "$n Stellen" : "$n Stellen; am PC die Ziffer tippen", knopf);
  }
}

/// Der Buchstabe einer Funktionstaste im Menü, klein oben links in der Farbe von Alpha: so drückt man sie am PC.
Widget _buchstabe(String b) =>
    Text(b, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, height: 1, color: Farben.alpha));

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
