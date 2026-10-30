import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'anzeige.dart';
import 'farben.dart';
import 'modell.dart';
import 'tastenfeld.dart';

void main() => runApp(const RpnApp());

class RpnApp extends StatelessWidget {
  const RpnApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "RPN-Rechner",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: Farben.gehaeuse, useMaterial3: true),
    home: const RechnerSeite(),
  );
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
              ListTile(
                title: Text(d, style: Schrift.monospace(15, Farben.anzeigeText)),
                trailing: d == modell.domaene ? const Icon(Icons.check, color: Farben.anzeigeText) : null,
                onTap: () {
                  modell.waehleDomaene(d);
                  Navigator.pop(context);
                },
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: ListenableBuilder(
              listenable: modell,
              builder: (context, _) => LayoutBuilder(
                builder: (context, platz) {
                  // zwei Tasten des oberen Blocks breit, die Unterkante auf Höhe von R1
                  final taste = (platz.maxWidth - 5 * (Tastenfeld.obenAbstand - 1)) / 6;
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
          ),
        ),
      ),
    );
  }

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
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      modell.tastaturReturn();
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
