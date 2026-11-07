/// Aufgabe: Start der App. [RpnApp] setzt das Thema und den Zoom (alles wächst mit der Fensterbreite, begrenzt
/// durch die Höhe), [RechnerSeite] ist die einzige Seite: Anzeige oben, Tastenfeld unten, das Cursorkreuz
/// dazwischen. Sie hält das [RechnerModell], zeigt seine Meldungen, öffnet das Menü der Domänen und gibt die
/// Tasten der PC-Tastatur (Sondertasten, Strg+C/V, sonst Zeichen) an das Modell weiter.
///
/// Abgrenzung: Welches Zeichen welche Taste des Tastenfelds trifft, entscheidet model/keyboard.dart; Anzeige und
/// Tastenfeld liegen in display/ und keypad/. Hier wird nicht gerechnet.
///
/// Siehe auch: doc/app.md 1.1 (Zoom), Kapitel 6 (Tastatur), 2.1 (Kontextmenü, Zwischenablage), doc/architecture.md 4.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'display/display.dart';
import 'help_texts.dart';
import 'keypad/cursor_cross.dart';
import 'keypad/keypad.dart';
import 'model/model.dart';
import 'tooltip.dart';

void main() {
  // im Browser das eigene Kontextmenü der App statt dem des Browsers (doc/app.md 2.1); das geht erst, wenn
  // Flutter läuft, deshalb zuerst ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) BrowserContextMenu.disableContextMenu();
  runApp(const RpnApp());
}

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

  /// Zoom (doc/app.md 1.1): alles um Fensterbreite / [breite], höchstens so viel, dass Tastenfeld und eine
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
  void initState() {
    super.initState();
    modell.meldung.addListener(_zeigeMeldung);
  }

  /// Meldungen des Modells (z.B. nach dem Kopieren) kurz unten anzeigen (doc/app.md 2.1).
  void _zeigeMeldung() {
    final text = modell.meldung.value;
    if (text == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text, style: Schrift.monospace(13, Farben.anzeigeText)),
        backgroundColor: Farben.anzeige,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

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
    TippSperre.bisMausWechselt(); // wer tippt, braucht keinen Tooltip unter der Maus (doc/app.md 5.1)
    final tastatur = HardwareKeyboard.instance;
    final altGr = tastatur.isControlPressed && tastatur.isAltPressed;
    final k = e.logicalKey;
    final umschalt = tastatur.isShiftPressed;
    // Strg+C kopiert x, mit Umschalt den Stack; Strg+V fügt im Stack Werte ein, sonst Text (doc/app.md 2.1)
    if ((tastatur.isControlPressed && !altGr) || tastatur.isMetaPressed) {
      if (k == LogicalKeyboardKey.keyC) {
        modell.kopiere(umschalt ? Kopie.stack : Kopie.wert);
      } else if (k == LogicalKeyboardKey.keyV) {
        modell.fuegeEin(werte: modell.bereich == Bereich.stack);
      } else {
        return KeyEventResult.ignored;
      }
      return KeyEventResult.handled;
    }
    // die ENTER-Taste im Ziffernblock: manche Browser melden sie als Return, erkennbar nur an der physischen Taste
    if (k == LogicalKeyboardKey.numpadEnter || e.physicalKey == PhysicalKeyboardKey.numpadEnter) {
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
