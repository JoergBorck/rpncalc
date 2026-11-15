/// Aufgabe: die Menüseite der Anzeige (doc/app.md 3.6). Solange das Menü offen ist, liegt sie über den Seiten:
/// oben der Pfad und der Hinweis zur Bedienung, im Hauptmenü der Ziffernblock als Karte mit Symbol und Name je Bereich, im Bereich Bibliotheken
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
    final klein = Schrift.monospace(11, Farben.anzeigeBlass);
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
              Text(bibliotheken ? "${m.eingeschalteteEintraege.where((e) => e != "Programm").length} geladen" : "Hauptmenü",
                  style: klein),
            ],
          ),
          Text(
            "${bibliotheken ? "Taste schaltet um" : "Bereich wählen"} · MENÜ bricht ab · OK übernimmt",
            overflow: TextOverflow.ellipsis,
            style: klein,
          ),
          Container(
            margin: const EdgeInsets.only(top: 3, bottom: 6),
            height: 1,
            color: const Color(0xFF1F2E27),
          ),
          Expanded(child: bibliotheken ? _bibliotheken(m) : _karte(m)),
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
