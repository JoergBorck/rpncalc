import 'dart:async';

import 'package:flutter/material.dart';

import 'farben.dart';
import 'hilfe.dart';

/// Tooltip als abgerundeter hellgelber Kasten oberhalb des Elements (doc/app.md 7, Punkt 14). Gelb kommt sonst
/// nirgends vor, so hebt er sich klar von der dunklen Oberfläche ab. Am PC erscheint er beim Darüberfahren, am
/// Handy bei langem Drücken. Passt oben kein Platz, steht er darunter.
/// Mit [unten] steht er unterhalb und etwas weiter weg, damit er nicht unter dem Mauszeiger liegt; für die
/// Elemente ganz oben (Statuszeile), über denen kein Platz ist.
Widget tipp(String nachricht, Widget kind, {bool unten = false}) {
  if (nachricht.isEmpty) return kind;
  return _tooltip(kind, message: nachricht, unten: unten);
}

/// Tooltip einer Taste als Tabelle (doc/app.md 5.1): Spalten Schreibweise, Stack, Beschreibung; innerhalb eines
/// Bereichs wechselt der Hintergrund zwischen Gelb und Hellgelb, zwischen zwei Bereichen steht eine dunklere Linie.
/// [beiAnzeige] meldet, dass der Tooltip erschienen ist (die Hilfe startet dann mit seiner Seite, doc/app.md 5.2).
Widget tippTabelle(List<List<TippZeile>> bereiche, Widget kind, {VoidCallback? beiAnzeige}) {
  if (bereiche.isEmpty) return kind;
  // verlässt die Maus das Element, ruhen die Tooltips kurz, damit sie nicht von Taste zu Taste springen
  return MouseRegion(
    onExit: (_) => TippSperre.sperren(),
    child: ValueListenableBuilder<bool>(
      valueListenable: TippSperre.gesperrt,
      builder: (context, gesperrt, kind) => TooltipVisibility(visible: !gesperrt, child: kind!),
      child: _tooltip(kind, rich: WidgetSpan(child: _TippTabelle(bereiche)), beiAnzeige: beiAnzeige, beiLangemDruck: beiAnzeige),
    ),
  );
}

/// Kurze Pause der Tooltips nach dem Verlassen einer Taste. Ohne sie zeigt Flutter den Tooltip der Nachbartaste
/// sofort, weil der vorige noch als offen gilt; so wartet er wieder die übliche Zeit.
abstract final class TippSperre {
  static const dauer = Duration(seconds: 1);
  static final ValueNotifier<bool> gesperrt = ValueNotifier(false);
  static Timer? _uhr;

  static void sperren() {
    gesperrt.value = true;
    _uhr?.cancel();
    _uhr = Timer(dauer, () => gesperrt.value = false);
  }
}

/// Nur die Tabelle, ohne Tooltip, z.B. für Tests oder eine Vorschau.
Widget tippTabelleInhalt(List<List<TippZeile>> bereiche) => _TippTabelle(bereiche);

Widget _tooltip(Widget kind,
    {String? message, InlineSpan? rich, bool unten = false, VoidCallback? beiAnzeige, VoidCallback? beiLangemDruck}) {
  // onTriggered meldet nur Antippen und langes Drücken; am PC erscheint der Tooltip beim Darüberfahren. Gemerkt
  // wird er erst, wenn der Zeiger eine Weile auf der Taste ruht, nicht beim bloßen Überfahren (doc/app.md 5.2)
  if (beiAnzeige != null) {
    return _Verweilen(
        beiAnzeige: beiAnzeige,
        child: _tooltip(kind, message: message, rich: rich, unten: unten, beiLangemDruck: beiLangemDruck));
  }
  return Tooltip(
    message: message,
    richMessage: rich,
    onTriggered: beiLangemDruck,
    preferBelow: unten,
    verticalOffset: unten ? 30 : 20,
    waitDuration: const Duration(milliseconds: 600),
    // sofort weg beim Verlassen: sonst gilt er noch als offen, und der Tooltip der Nachbartaste käme ohne Wartezeit
    exitDuration: Duration.zero,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    textStyle: Schrift.monospace(12, Farben.tippText),
    decoration: BoxDecoration(
      color: Farben.tipp,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: kind,
  );
}

class _TippTabelle extends StatelessWidget {
  final List<List<TippZeile>> bereiche;
  const _TippTabelle(this.bereiche);

  static final _text = Schrift.monospace(12, Farben.tippText);

  /// Die Schreibweise mit gefärbten Umschaltzeichen: ~ türkis, | lila, davor ⇧ bzw. die Farbe von Alpha.
  static Widget _schreibweise(TippZeile z) {
    // führende ' und ~ stehen vor Shift, in der Reihenfolge des Tippens: ' ⇧ C, ~ ⇧ ≠, ~ ⇧ seed
    final vorn = z.art == ZeilenArt.shift ? RegExp(r"^['~]*").stringMatch(z.schreibweise)! : "";
    final schreibweise = z.schreibweise.substring(vorn.length);
    final spans = <InlineSpan>[
      for (final c in vorn.split(""))
        TextSpan(text: "$c ", style: c == "~" ? _text.copyWith(color: Farben.tippTilde, fontWeight: FontWeight.w700) : _text),
      // Shift wie auf der Taste: schwarzer Pfeil auf orangem Grund
      if (z.art == ZeilenArt.shift)
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.only(right: 5),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(color: Farben.shift, borderRadius: BorderRadius.circular(3)),
            child: Text("⇧", style: _text.copyWith(color: Farben.tippText, fontWeight: FontWeight.w700)),
          ),
        ),
    ];
    if (z.art == ZeilenArt.alpha && schreibweise.startsWith("Alpha")) {
      // „Alpha“ grün, dahinter die Taste im Alpha-Modus (⏎) kräftig
      spans.add(TextSpan(text: "Alpha", style: _text.copyWith(color: Farben.tippAlpha)));
      spans.add(TextSpan(text: schreibweise.substring(5), style: _text.copyWith(fontWeight: FontWeight.w700)));
    } else if (z.art == ZeilenArt.pc) {
      spans.add(TextSpan(text: schreibweise, style: _text.copyWith(color: Farben.tippKasten)));
    } else {
      for (final c in schreibweise.split("")) {
        final farbe = c == "~" ? Farben.tippTilde : c == "|" ? Farben.tippStrich : c == "▢" ? Farben.tippKasten : null;
        spans.add(TextSpan(text: c, style: farbe == null ? _text : _text.copyWith(color: farbe, fontWeight: FontWeight.w700)));
      }
    }
    return Text.rich(TextSpan(children: spans));
  }

  /// Die Beschreibung; ⏎ kräftig, die Schrift zeichnet es sonst sehr dünn.
  static Widget _beschreibung(String text) {
    if (!text.contains("⏎")) return Text(text, style: _text);
    final teile = text.split("⏎");
    return Text.rich(TextSpan(children: [
      for (var i = 0; i < teile.length; i++) ...[
        if (i > 0) TextSpan(text: "⏎", style: _text.copyWith(fontWeight: FontWeight.w900)),
        TextSpan(text: teile[i], style: _text),
      ],
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final zeilen = <TableRow>[];
    for (var b = 0; b < bereiche.length; b++) {
      for (var i = 0; i < bereiche[b].length; i++) {
        final z = bereiche[b][i];
        final bereichsAnfang = i == 0 && zeilen.isNotEmpty;
        Widget zelle(Widget w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3), child: w);
        zeilen.add(TableRow(
          decoration: BoxDecoration(
            color: i.isOdd ? Farben.tippHell : null,
            border: bereichsAnfang ? const Border(top: BorderSide(color: Farben.tippLinieBereich, width: 1.5)) : null,
          ),
          children: [
            zelle(_schreibweise(z)),
            // lange Stack-Angaben brechen nur nach dem → um, die rechte Seite eingerückt
            zelle(Text(z.stack.length > 20 ? z.stack.replaceFirst(" → ", " →\n   ") : z.stack, style: _text)),
            zelle(_beschreibung(z.text)),
          ],
        ));
      }
    }
    // so breit wie nötig, bei knappem Platz schmaler (dann bricht die Beschreibung um)
    return IntrinsicWidth(child: Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(), // Stack-Angaben sind kurz und sollen nicht umbrechen
        // ist der Platz knapp (schmales Fenster, Handy), wird nur die Beschreibung schmaler und bricht um
        2: MinColumnWidth(IntrinsicColumnWidth(flex: 1), FixedColumnWidth(280)),
      },
      children: zeilen,
    ));
  }
}

/// Meldet [beiAnzeige], wenn der Mauszeiger mindestens [dauer] auf dem Kind ruht.
class _Verweilen extends StatefulWidget {
  final VoidCallback beiAnzeige;
  final Widget child;
  static const dauer = Duration(seconds: 1);
  const _Verweilen({required this.beiAnzeige, required this.child});

  @override
  State<_Verweilen> createState() => _VerweilenState();
}

class _VerweilenState extends State<_Verweilen> {
  Timer? _uhr;

  @override
  void dispose() {
    _uhr?.cancel();
    super.dispose();
  }

  @override
  // ein Klick stoppt die Uhr: wer drückt, schaut nicht mehr (sonst zählte die Taste, auf der die Maus danach liegt)
  Widget build(BuildContext context) => Listener(
        onPointerDown: (_) => _uhr?.cancel(),
        child: MouseRegion(
          onEnter: (_) => _uhr = Timer(_Verweilen.dauer, widget.beiAnzeige),
          onExit: (_) => _uhr?.cancel(),
          child: widget.child,
        ),
      );
}
