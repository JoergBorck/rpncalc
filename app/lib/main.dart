import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'anzeige.dart';
import 'farben.dart';
import 'hilfe.dart';
import 'modell.dart';
import 'tastenfeld.dart';
import 'tipp.dart';

void main() => runApp(const RpnApp());

class RpnApp extends StatelessWidget {
  const RpnApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "RPN-Rechner",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: Farben.gehaeuse, useMaterial3: true),
    // ganz außen, damit Tooltips, Menü und Dialoge mitwachsen
    builder: (context, kind) => _zoom(context, kind!),
    home: const RechnerSeite(),
  );

  static const double breite = 400; // mit dieser Breite rechnet die App, das Fenster vergrößert oder verkleinert
  static const double minAnzeige = 240; // so viel Höhe braucht die Anzeige mindestens
  static const double maxDehnung = 1.5; // so viel breiter werden die Tasten, bevor links und rechts Rand bleibt

  /// Zoom (doc/app.md Punkt 5): alles um Fensterbreite / [breite], höchstens so viel, dass Tastenfeld und eine
  /// Anzeige von [minAnzeige] in die Höhe passen. Höher ziehen gibt der Anzeige mehr Zeilen.
  static Widget _zoom(BuildContext context, Widget kind) => LayoutBuilder(builder: (context, platz) {
        final minHoehe = Tastenfeld.hoehe + minAnzeige + 22; // 22: Rand oben und unten
        final faktor = (platz.maxWidth / breite).clamp(0.0, platz.maxHeight / minHoehe);
        if (faktor <= 0) return kind;
        final mq = MediaQuery.of(context);
        final logisch = Size(platz.maxWidth / faktor, platz.maxHeight / faktor);
        return FittedBox(
          child: SizedBox.fromSize(
            size: logisch,
            child: MediaQuery(
              data: mq.copyWith(
                size: logisch,
                padding: mq.padding / faktor,
                viewPadding: mq.viewPadding / faktor,
                viewInsets: mq.viewInsets / faktor,
              ),
              child: kind,
            ),
          ),
        );
      });
}

/// Die einzige Seite: Anzeige oben, Tastenfeld unten, das Cursorkreuz dazwischen (doc/app.md Kapitel 1).
class RechnerSeite extends StatefulWidget {
  const RechnerSeite({super.key});

  @override
  State<RechnerSeite> createState() => _RechnerSeiteState();
}

class _RechnerSeiteState extends State<RechnerSeite> {
  final modell = RechnerModell();

  @override
  void dispose() {
    modell.dispose();
    super.dispose();
  }

  void _menue() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Farben.anzeige,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(
                "DOMÄNE FÜR DIE FUNKTIONSTASTEN",
                style: Schrift.monospace(12, Farben.anzeigeBlass, gewicht: FontWeight.w600),
              ),
            ),
            for (final d in modell.domaenenNamen)
              // Bibliotheken zeigen im Tooltip, wofür sie gedacht sind (doc/app.md 5.1)
              tippTabelle(
                AppHilfe.tippBibliothek(modell.api, d),
                ListTile(
                  title: Text(d, style: Schrift.monospace(15, Farben.anzeigeText)),
                  trailing: d == modell.domaene ? const Icon(Icons.check, color: Farben.anzeigeText) : null,
                  onTap: () {
                    modell.waehleDomaene(d);
                    Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // eine echte Tastatur bedient die App wie die Knöpfe (doc/app.md Kapitel 6)
    return Focus(
      autofocus: true,
      onKeyEvent: _taste,
      child: Scaffold(
        body: SafeArea(
          child: _handyFormat(Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: ListenableBuilder(
              listenable: modell,
              builder: (context, _) => LayoutBuilder(
                builder: (context, platz) {
                  // zwei Tasten des oberen Blocks breit, die Unterkante auf Höhe von R1; bei gedehnten Tasten so
                  // groß wie ohne Dehnung, sonst ragt es zu weit in die Anzeige
                  final normal = platz.maxWidth.clamp(0.0, Tastenfeld.normalBreite);
                  final taste = (normal - 5 * (Tastenfeld.obenAbstand - 1)) / 6;
                  final breite = 2 * taste + Tastenfeld.obenAbstand + 14;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          Expanded(child: Anzeige(modell)),
                          Tastenfeld(modell, menue: _menue),
                        ],
                      ),
                      Positioned(
                        left: (platz.maxWidth - breite) / 2,
                        bottom: Tastenfeld.hoehe - Tastenfeld.r1Unten + 2,
                        child: Cursorkreuz(modell, breite: breite),
                      ),
                    ],
                  );
                },
              ),
            ),
          )),
        ),
      ),
    );
  }

  /// Begrenzt die Höhe den Zoom, werden die Tasten bis [RpnApp.maxDehnung] breiter, erst danach bleibt Rand
  /// (RpnApp._zoom). Reicht die Höhe trotzdem nicht (z.B. wegen der Ränder eines Handys), wird die Seite
  /// verkleinert statt abgeschnitten.
  Widget _handyFormat(Widget seite) => LayoutBuilder(builder: (context, platz) {
        final breite = platz.maxWidth.clamp(0.0, RpnApp.breite * RpnApp.maxDehnung);
        final minHoehe = Tastenfeld.hoehe + RpnApp.minAnzeige + 22; // 22: Rand oben und unten
        if (platz.maxHeight >= minHoehe) {
          return Center(child: SizedBox(width: breite, child: seite));
        }
        return Center(
          child: FittedBox(child: SizedBox(width: breite, height: minHoehe, child: seite)),
        );
      });

  /// Tasten der echten Tastatur: Sondertasten auf die Aktionen der App, alle anderen Zeichen wie getippt.
  /// Mit Strg gedrückte Tasten bleiben dem System (später Strg+C und Strg+V). AltGr meldet Windows als Strg+Alt;
  /// das muss durch, sonst fehlen auf der deutschen Tastatur | ~ { } und ².
  KeyEventResult _taste(FocusNode knoten, KeyEvent e) {
    if (e is KeyUpEvent) return KeyEventResult.ignored;
    final tastatur = HardwareKeyboard.instance;
    final altGr = tastatur.isControlPressed && tastatur.isAltPressed;
    if ((tastatur.isControlPressed && !altGr) || tastatur.isMetaPressed) return KeyEventResult.ignored;
    final k = e.logicalKey;
    final umschalt = tastatur.isShiftPressed;
    if (k == LogicalKeyboardKey.numpadEnter) {
      modell.tastaturReturn(); // ENTER und Zeilenumbruch
    } else if (k == LogicalKeyboardKey.enter) {
      modell.tastaturZeilenumbruch(); // Return: nur Zeilenumbruch, wie ALPHA ⏎
    } else if (k == LogicalKeyboardKey.backspace) {
      modell.tastaturLoeschen();
    } else if (k == LogicalKeyboardKey.tab) {
      modell.tastaturTab(rueckwaerts: umschalt);
    } else if (k == LogicalKeyboardKey.arrowUp) {
      modell.pfeil(AxisDirection.up);
    } else if (k == LogicalKeyboardKey.arrowDown) {
      modell.pfeil(AxisDirection.down);
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      modell.pfeil(AxisDirection.left);
    } else if (k == LogicalKeyboardKey.arrowRight) {
      modell.pfeil(AxisDirection.right);
    } else if (k == LogicalKeyboardKey.f1) {
      modell.tastaturHilfe();
    } else if (k == LogicalKeyboardKey.escape) {
      modell.tastaturEsc();
    } else {
      final c = e.character;
      if (c == null || c.isEmpty || c.codeUnitAt(0) < 32 || c.codeUnitAt(0) == 127) return KeyEventResult.ignored;
      modell.tippeZeichen(c);
    }
    return KeyEventResult.handled;
  }
}
