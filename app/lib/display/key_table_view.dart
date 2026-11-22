/// Aufgabe: die Hilfeseite „Alle Tasten“ (DG-7): die Tabellen aus key_table.dart, breit mit seitlichem Scrollen;
/// Spalten, die in keiner Tabelle belegt sind, fallen weg, die Spalte PC gibt es nur am PC.
///
/// Abgrenzung: Welche Zeilen es gibt, steht in key_table.dart (dieselben wie in doc/keys.md, ohne Geplantes und
/// ohne den Text von Hand); eingebettet wird die Seite vom Hilfeschirm (help_screen.dart) beim Eintrag app:tasten.
///
/// Siehe auch: doc/keys.md, process/requirements/DG-7.md, key_table.dart.
library;

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';

import '../colors.dart';
import '../key_table.dart';

/// Die Tabellen der Tasten untereinander, jede für sich seitlich scrollbar.
class TastenTabellenAnsicht extends StatelessWidget {
  /// Mit der Spalte PC; ohne Angabe nur auf Windows, Linux und macOS (auch im Browser dort).
  final bool? pc;
  const TastenTabellenAnsicht({super.key, this.pc});

  static bool get _amPc => const {TargetPlatform.windows, TargetPlatform.linux, TargetPlatform.macOS}.contains(defaultTargetPlatform);

  /// Die Farbe eines Spaltenkopfs: wie die Hinweise auf den Tasten (Präfixe, Shift, Alpha).
  static Color _kopfFarbe(String spalte) => switch (spalte) {
        "tilde" => Farben.tilde,
        "strich" || "beide" => Farben.strich,
        "shift" || "shiftTilde" || "shiftStrich" || "shiftBeide" => Farben.shift,
        "alpha" => Farben.alpha,
        _ => Farben.anzeigeBlass,
      };

  @override
  Widget build(BuildContext context) {
    final mitPc = pc ?? _amPc;
    final tabellen = <(String, List<Tastenzeile>)>[
      ("Oberer Block", obererBlock),
      ("Unterer Block", untererBlock),
      for (final d in domaenenTabellen.entries) ("Domäne ${d.key}", d.value),
    ];
    // nur Spalten, die irgendwo belegt sind
    final spalten = [
      for (final s in tastenSpalten)
        if ((s != "pc" || mitPc) && tabellen.any((t) => t.$2.any((z) => (z.zellen[s] ?? "").isNotEmpty))) s,
    ];
    final stil = Schrift.monospace(11, Farben.anzeigeText);
    final titel = Schrift.monospace(12, Farben.hilfe, gewicht: FontWeight.w700);
    Widget zelle(String text, TextStyle s) =>
        Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), child: Text(text, style: s, softWrap: false));
    Widget tabelle(List<String> kopf, List<Color> farben, List<List<String>> zeilen) => _Seitlich(
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: const TableBorder(horizontalInside: BorderSide(color: Farben.kontextZeile)),
            children: [
              TableRow(children: [
                for (final (i, k) in kopf.indexed) zelle(k, stil.copyWith(color: farben[i], fontWeight: FontWeight.w700)),
              ]),
              for (final z in zeilen) TableRow(children: [for (final t in z) zelle(t, stil)]),
            ],
          ),
        );
    final kopf = ["Taste", for (final s in spalten) tastenKoepfe[tastenSpalten.indexOf(s)]];
    final farben = [Farben.anzeigeBlass, for (final s in spalten) _kopfFarbe(s)];
    final menueHaupt = menueHauptTabelle, menueModi = menueModiTabelle;
    List<List<String>> ohnePc(({List<String> kopf, List<List<String>> zeilen}) t) =>
        [for (final z in [t.kopf, ...t.zeilen]) mitPc ? z : z.sublist(0, z.length - 1)];
    Widget einfach(({List<String> kopf, List<List<String>> zeilen}) t) {
      final alle = ohnePc(t);
      return tabelle(alle.first, List.filled(alle.first.length, Farben.anzeigeBlass), alle.sublist(1));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, zeilen) in tabellen) ...[
          Text(name, style: titel),
          const SizedBox(height: 2),
          tabelle(kopf, farben, [
            for (final z in zeilen)
              [z.taste, for (final s in spalten) s == "normal" && z.zellen[s] == domaenenVerweis ? "→ Domänen unten" : z.zellen[s] ?? ""],
          ]),
          const SizedBox(height: 10),
        ],
        Text("Menü: Hauptmenü", style: titel),
        const SizedBox(height: 2),
        einfach(menueHaupt),
        const SizedBox(height: 10),
        Text("Menü: Modi", style: titel),
        const SizedBox(height: 2),
        einfach(menueModi),
      ],
    );
  }
}

/// Eine Tabelle, seitlich scrollbar auch am PC (BA-16): mit der Maus ziehen, Umschalt+Mausrad (kann Flutter von
/// selbst) und eine Scrollleiste darunter, die nur erscheint, wenn die Tabelle breiter ist als der Platz.
class _Seitlich extends StatefulWidget {
  final Widget child;
  const _Seitlich({required this.child});

  @override
  State<_Seitlich> createState() => _SeitlichState();
}

class _SeitlichState extends State<_Seitlich> {
  final _steuerung = ScrollController();

  @override
  void dispose() {
    _steuerung.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
        // am Desktop nimmt Flutter das Ziehen mit der Maus sonst nicht als Scrollen
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
        child: Scrollbar(
          controller: _steuerung,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _steuerung,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 10), // Platz für die Scrollleiste unter der letzten Zeile
            child: widget.child,
          ),
        ),
      );
}
