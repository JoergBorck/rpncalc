/// Aufgabe: die Menüseite der Anzeige (doc/app.md 3.6). Solange das Menü offen ist, liegt sie über den Seiten:
/// oben der Pfad und der Hinweis zur Bedienung, im Hauptmenü der Ziffernblock als Karte mit Symbol und Name je
/// Bereich, im Bereich Modi die Karte 2 × 5 wie der Funktionsblock (FA-32), im Bereich Bibliotheken
/// die Liste mit Name, Version und Wirkung, darunter die gewählte Bibliothek und was OK bewirkt. Unten
/// bleibt Platz für das Cursorkreuz, das in die Anzeige ragt.
///
/// Abgrenzung: Was gewählt ist und was OK bewirkt, sagt das Modell (model/menu.dart); die Tasten des Menüs
/// zeichnet keypad/. Über welchen Seiten sie liegt, entscheidet display.dart.
///
/// Siehe auch: doc/app.md 3.6, process/requirements/FA-30.md (Prüfseite).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../colors.dart';
import '../model/model.dart';

/// Die Menüseite: Kopf, Inhalt je Bereich, Hinweis.
class MenueSeite extends StatefulWidget {
  final RechnerModell m;
  const MenueSeite(this.m, {super.key});

  @override
  State<MenueSeite> createState() => _MenueSeiteState();
}

class _MenueSeiteState extends State<MenueSeite> {
  final _liste = ScrollController();
  static const _zeile = 21.0;

  /// So weit ragt das Cursorkreuz von unten in die Menüseite (Spitze über dem Seitennamen, main.dart).
  static const _kreuz = 36.0;

  @override
  void dispose() {
    _liste.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.m;
    final bibliotheken = m.menueBereich == MenueBereich.bibliotheken;
    final modi = m.menueBereich == MenueBereich.modi;
    final klein = Schrift.monospace(11, Farben.anzeigeBlass);
    final rechts = switch (m.menueBereich) {
      MenueBereich.bibliotheken => "${m.eingeschalteteEintraege.where((e) => e != "Programm").length} geladen",
      MenueBereich.modi => "${[for (final f in modusFelder.nonNulls) if (m.modusGeaendert(f.name)) f].length} geändert",
      _ => "Hauptmenü",
    };
    return Container(
      color: Farben.anzeige,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, _kreuz),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(m.menuePfad,
                    overflow: TextOverflow.ellipsis,
                    style: Schrift.monospace(12, Farben.anzeigeText, gewicht: FontWeight.w600)),
              ),
              Text(rechts, style: klein),
            ],
          ),
          Text(
            "${bibliotheken ? "Taste oder f–p schaltet um" : modi ? "Taste oder f–p schaltet weiter" : "Bereich wählen"} · MENÜ bricht ab · OK übernimmt",
            overflow: TextOverflow.ellipsis,
            style: klein,
          ),
          Container(
            margin: const EdgeInsets.only(top: 3, bottom: 6),
            height: 1,
            color: const Color(0xFF1F2E27),
          ),
          Expanded(child: bibliotheken ? _bibliotheken(m) : modi ? _modi(m) : _karte(m)),
        ],
      ),
    );
  }

  /// Hauptmenü: der Ziffernblock als Karte 3 × 3, je belegtem Bereich Symbol und Name.
  Widget _karte(RechnerModell m) {
    Widget feld(String taste) {
      final punkt = menuePunktAuf(taste);
      return Expanded(
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: punkt == null ? const Color(0xFF1C2A24) : const Color(0xFF3E5A4D)),
          ),
          child: Stack(
            children: [
              Positioned(left: 4, top: 1, child: Text(taste, style: Schrift.monospace(9, Farben.anzeigeBlass))),
              if (punkt != null)
                Center(
                  // auf kleinen Anzeigen verkleinert statt abgeschnitten
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(punkt.symbol,
                            width: 28,
                            height: 28,
                            colorFilter: const ColorFilter.mode(Farben.anzeigeText, BlendMode.srcIn)),
                        const SizedBox(height: 2),
                        Text(punkt.name, style: Schrift.monospace(11, Farben.anzeigeText)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (final reihe in const [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"]])
            Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final t in reihe) feld(t)])),
        ],
      ),
    );
  }

  /// Bereich Bibliotheken: Liste, darunter die gewählte und die Wirkung von OK.
  Widget _bibliotheken(RechnerModell m) {
    final eintraege = m.menueEintraege;
    final gewaehlt = m.menueGewaehlt;
    // die gewählte Zeile bleibt zu sehen, wenn die Liste scrollt
    final index = gewaehlt == null ? -1 : eintraege.indexOf(gewaehlt);
    if (index >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_liste.hasClients) return;
        final p = _liste.position, oben = index * _zeile, unten = oben + _zeile;
        if (oben < p.pixels) _liste.jumpTo(oben);
        if (unten > p.pixels + p.viewportDimension) _liste.jumpTo(unten - p.viewportDimension);
      });
    }
    final info = gewaehlt == null ? null : m.menueInfo(gewaehlt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            controller: _liste,
            itemExtent: _zeile,
            itemCount: eintraege.length,
            itemBuilder: (context, i) => _zeileVon(m, eintraege[i]),
          ),
        ),
        if (gewaehlt != null)
          Container(
            padding: const EdgeInsets.only(top: 6),
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF1F2E27)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [gewaehlt, if (info != null && info.version.isNotEmpty) info.version, if (info != null) "${info.funktionen} Funktionen"]
                      .join(" · "),
                  style: Schrift.monospace(12, Farben.anzeigeText, gewicht: FontWeight.w600),
                ),
                if (info != null && info.beschreibung.isNotEmpty)
                  Text(info.beschreibung,
                      maxLines: 3, overflow: TextOverflow.ellipsis, style: Schrift.monospace(11, const Color(0xFFA9C4B6))),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 3, bottom: 2),
          child: Text(m.menueWirkung, style: Schrift.monospace(11, Farben.shift)),
        ),
      ],
    );
  }

  /// Bereich Modi: Karte 2 × 5 wie der Funktionsblock, darunter die Zeile zum gedrückten Modus und was OK bewirkt
  /// (FA-32).
  Widget _modi(RechnerModell m) {
    final zeile = m.modusZeile;
    return LayoutBuilder(builder: (context, platz) {
      // zwei Reihen, höchstens 66 hoch (Titel und drei Zeilen Werte); darunter bleiben gut 34 für Zeile und Satz zu OK
      final hoehe = ((platz.maxHeight - 34) / 2).clamp(0.0, 66.0);
      return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final reihe in [modusFelder.sublist(0, 5), modusFelder.sublist(5, 10)])
          SizedBox(
            height: hoehe,
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final f in reihe) _modusFeld(m, f)]),
          ),
        const Spacer(),
        if (zeile != null)
          Text.rich(
            TextSpan(children: [
              TextSpan(text: zeile.wert),
              if (zeile.erklaerung.isNotEmpty)
                TextSpan(text: " · ${zeile.erklaerung}", style: const TextStyle(color: Farben.anzeigeBlass)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Schrift.monospace(11.5, Farben.anzeigeText),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Text(m.menueWirkung, style: Schrift.monospace(11, Farben.shift)),
        ),
      ],
      );
    });
  }

  /// Ein Feld der Karte Modi: Symbol und Name, darunter die Werte je zwei nebeneinander, der gewählte fett (weiß
  /// unverändert, grün geändert), die übrigen grau; Bruch mit seinen drei Bildern. Platzhalter ganz ausgegraut, das
  /// zuletzt gedrückte Feld dünn orange umrandet.
  Widget _modusFeld(RechnerModell m, ModusFeld? f) {
    const grau = Color(0xFF4E6359), dunkel = Color(0xFF34463E);
    final rand = f == null
        ? const Color(0xFF16211C)
        : f.name == m.menueGewaehlt
            ? Farben.shift
            : f.aktiv
                ? const Color(0xFF3E5A4D)
                : const Color(0xFF1C2A24);
    Widget? inhalt;
    if (f != null) {
      final gewaehlt = m.modusWert(f.name), geaendert = m.modusGeaendert(f.name);
      Color farbeVon(String w) =>
          !f.aktiv ? dunkel : w != gewaehlt ? grau : geaendert ? Farben.rahmenGruen : Farben.rahmenWeiss;
      final werte = f.name == "Bruch"
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final w in f.werte)
                  SvgPicture.asset(bruchBilder[w]!,
                      width: 17, height: 17, colorFilter: ColorFilter.mode(farbeVon(w), BlendMode.srcIn)),
              ],
            )
          : Wrap(
              children: [
                for (final w in f.werte)
                  FractionallySizedBox(
                    widthFactor: f.name == "Auflösung" ? 1 : 0.5,
                    child: Text(w,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            fontSize: 10,
                            height: 1.25,
                            color: farbeVon(w),
                            fontWeight: f.aktiv && w == gewaehlt ? FontWeight.w700 : FontWeight.w400)),
                  ),
              ],
            );
      inhalt = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SvgPicture.asset(f.symbol,
                  width: 12,
                  height: 12,
                  colorFilter: ColorFilter.mode(f.aktiv ? Farben.anzeigeText : dunkel, BlendMode.srcIn)),
              const SizedBox(width: 2),
              Flexible(
                child: Text(f.name,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: TextStyle(fontSize: 9.5, color: f.aktiv ? Farben.anzeigeText : dunkel)),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: ClipRect(child: werte)),
                // Format: die Stellenzahl groß unten rechts, grün, wenn geändert
                if (f.name == "Format" && gewaehlt != "Std")
                  Positioned(
                    right: 1,
                    bottom: 0,
                    child: Text("${m.menueStellen}",
                        style: TextStyle(
                            fontSize: 17,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            color: geaendert ? Farben.rahmenGruen : Farben.rahmenWeiss)),
                  ),
              ],
            ),
          ),
        ],
      );
    }
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.fromLTRB(3, 3, 3, 2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: rand)),
        child: inhalt,
      ),
    );
  }

  /// Eine Zeile der Liste: Name, Version, Wirkung in Worten und in der Farbe des Rahmens der Taste.
  Widget _zeileVon(RechnerModell m, String e) {
    final an = m.menueAuswahl.contains(e), geladen = m.eingeschaltet(e);
    final programm = e == "Programm";
    final (wirkung, farbe) = switch ((an, geladen)) {
      (true, false) => (programm ? "wird eingeschaltet" : "wird geladen", Farben.rahmenGruen),
      (false, true) => (programm ? "wird ausgeschaltet" : "wird entladen", Farben.rahmenRot),
      (true, true) => (programm ? "an" : "geladen", Farben.rahmenWeiss),
      (false, false) => (programm ? "aus" : "nicht geladen", const Color(0xFF3C5048)),
    };
    final version = m.menueInfo(e)?.version ?? "";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: e == m.menueGewaehlt ? Farben.shift : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(child: Text(e, overflow: TextOverflow.ellipsis, style: Schrift.monospace(12, Farben.anzeigeText))),
          SizedBox(
            width: 64,
            child: Text(version, textAlign: TextAlign.right, style: Schrift.monospace(11, Farben.anzeigeBlass)),
          ),
          SizedBox(
            width: 130,
            child: Text(wirkung,
                textAlign: TextAlign.right, maxLines: 1, softWrap: false, style: Schrift.monospace(12, farbe)),
          ),
        ],
      ),
    );
  }
}
