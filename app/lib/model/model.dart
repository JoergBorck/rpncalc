/// Aufgabe: der Zustand der App über dem Rechner, ohne Widgets. [RechnerModell] ist die einzige Klasse, die die
/// Widgets kennen: Umschaltungen (Shift, Präfixe, Alpha), gewählter Bereich, Verlauf und Zeilenumbruch, Belegung
/// der Funktionstasten, Hilfe-Modus, Zwischenablage, Ausschnitte der Anzeige und die PC-Tastatur. Wie der
/// Calculator ist es nach Aufgaben geteilt: [ModellKern] hält den gemeinsamen Zustand und schreibt in den Rechner,
/// je ein Mixin in einer part-Datei übernimmt eine Aufgabe.
///
/// Abgrenzung: Gerechnet wird nur im Rechner (RpnApi); die Widgets in display/ und keypad/ zeichnen nur, was das
/// Modell sagt. Die Tasten selbst stehen in keys.dart, die Hilfetexte der App in help_texts.dart.
///
/// Siehe auch: doc/architecture.md 4.2, doc/app.md, die part-Dateien unten.
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rpncalc/rpnapi.dart';

import '../help_texts.dart';
import '../keys.dart';

part 'assignment.dart';
part 'clipboard.dart';
part 'help_mode.dart';
part 'input.dart';
part 'keyboard.dart';
part 'modes.dart';
part 'viewport.dart';

/// Die Bereiche, zwischen denen Tab wechselt (doc/app.md 3.3).
enum Bereich { eingabe, stack, funktionen, variablen }

/// Wie eine Taste gerade beschriftet ist.
enum Beschriftungsart { normal, shift, tilde, strich, alpha }

/// Was das Kontextmenü der Anzeige kopiert (doc/app.md 2.1).
enum Kopie { wert, stackAb, stack, zeile, zeilenAb, verlauf }

typedef Beschriftung = ({String text, Beschriftungsart art, bool gedimmt});

/// Eine abgeschlossene Zeile im Verlauf.
typedef Verlaufszeile = ({String text, Fehler? fehler});

/// Der Zustand der Oberfläche über dem Rechner; die Teile stehen in den Mixins (doc/architecture.md 4.2).
class RechnerModell extends ModellKern with _Eingabe, _Belegung, _HilfeModus, _Ablage, _Ausschnitt, _Tastatur {
  @override
  late final Bedienmodus _modusRechnen = _Rechnen(this), _modusHilfe = _Hilfe(this);

  /// Version der App (MAJOR.MINOR.PATCH wie in pubspec.yaml); der Rechner prüft damit die Angabe `app` von
  /// Bibliotheken (doc/api.md 9.1).
  static const String appVersion = "0.3.0";

  static const int verlaufMax = 100;

  /// So viele Stackzeilen zeigt auch die kleinste Anzeige vollständig (RpnApp.minAnzeige); bis dahin lässt sich der
  /// unterste Wert hochblättern.
  static const int stackMinZeilen = 7;

  /// Ausschnitt ab [von] mit höchstens [platz] Zeichen; abgeschnittene Enden werden zu "…".
  /// Der Ausschnitt ist so lang wie der Platz, damit Stellen darin (Fehler) einfach umzurechnen sind.
  static String ausschnitt(String text, int von, int platz) {
    if (platz <= 0) return ""; // z.B. die Eingabespalte, wenn der Stack maximiert ist
    if (text.length <= platz) return text;
    final s = text.substring(von, von + platz).split("");
    if (von > 0) s[0] = "…";
    if (von + platz < text.length) s[s.length - 1] = "…";
    return s.join();
  }

  /// Ein Tipp in die Anzeige wählt den Bereich (doc/app.md 3.3); die Funktionstasten wählen keinen.
  void waehleBereich(Bereich b) {
    if (bereich == b) return;
    bereich = b;
    notifyListeners();
  }

  /// Tipp in Eingabe oder Stack: wählt den Bereich sofort; ein zweiter Tipp kurz danach (Doppelklick) wirkt wie
  /// die Taste □ / ◫ (doc/app.md 3.5). Selbst erkannt, damit der erste Tipp nicht auf den zweiten wartet.
  void tippeBereich(Bereich b) {
    final jetzt = DateTime.now();
    final letzter = _letzterTipp;
    final doppelt = letzter != null && letzter.$1 == b && jetzt.difference(letzter.$2) < const Duration(milliseconds: 400);
    _letzterTipp = doppelt ? null : (b, jetzt);
    if (!doppelt) return waehleBereich(b);
    bereich = b;
    druecke(const Taste("", aktion: Aktion.maximieren));
  }

  (Bereich, DateTime)? _letzterTipp;

  @override
  void dispose() {
    for (final t in _leuchtend.values) {
      t.cancel();
    }
    hilfeScroll.dispose();
    meldung.dispose();
    _hinweisUhr?.cancel();
    super.dispose();
  }
}

/// Der gemeinsame Zustand aller Teile des Modells und das Schreiben in den Rechner: Zeichen an RpnApi geben,
/// die Zeile umbrechen, wenn sie voll ist, den Verlauf führen.
abstract class ModellKern extends ChangeNotifier {
  final RpnApi api = RpnApi()..appVersion = RechnerModell.appVersion;
  late Zustand zustand = api.zustand(zeilen: _stackZeilen);

  bool shift = false, tilde = false, strich = false, apostroph = false, alpha = false;

  /// Im Alpha-Modus macht Shift den nächsten Buchstaben groß, danach endet Alpha (doc/app.md 3.2).
  bool get gross => alpha && shift;

  /// Shift für alles außer Buchstaben: im Alpha-Modus wirkt Shift nur auf Buchstaben, alle anderen Tasten
  /// behalten ihre normale Belegung (sonst würde ⌫ zu C, MENÜ zu HILFE, TAB rückwärts).
  bool get shiftWirkt => shift && !alpha;
  Bereich bereich = Bereich.eingabe;
  bool maximiert = false;   // Eingabe bzw. Stack haben die ganze Breite (doc/app.md 3.5)
  int stackVersatz = 0;     // erste angezeigte Stack-Position
  int verlaufVersatz = 0;   // so viele Zeilen ist der Verlauf zurückgeblättert

  /// Abgeschlossene Zeilen, die neueste zuerst.
  final List<Verlaufszeile> verlauf = [];

  /// So viele Zeichen passen in eine Eingabezeile; die Anzeige setzt das nach ihrer Breite.
  int zeichenProZeile = 20;

  /// Platz in Zeichen je sichtbarer Zeile der Eingabe- und der Stackspalte; setzt die Anzeige.
  List<int> platzEingabe = const [], platzStack = const [];

  /// Seitlich geschoben, je sichtbarer Zeile; ohne Eintrag zeigt die aktuelle Zeile ihr Ende, alle
  /// anderen ihren Anfang. Jede Eingabe setzt das zurück.
  final Map<int, int> _eingabeGeschoben = {}, _stackGeschoben = {};

  /// So viele Stackwerte holt die App vom Rechner: mindestens 40, beim Blättern bis zur untersten sichtbaren Zeile.
  int get _stackZeilen => (stackVersatz + platzStack.length + 1).clamp(40, 1 << 30);

  /// Anteil der Eingabe an der Breite der Seite „Rechnen“: halb, maximiert ganz oder gar nicht (doc/app.md 3.5).
  double get anteilEingabe => !maximiert
      ? 0.5
      : switch (bereich) { Bereich.eingabe => 1.0, Bereich.stack => 0.0, _ => 0.5 };

  /// Die aktuelle Eingabezeile; nach einem Umbruch leer.
  String get zeile => zustand.zeileFertig ? "" : zustand.zeile;

  /// Der aktive Bedienmodus (modes.dart): bekommt jede Bedienung. Am Anfang Rechnen.
  late Bedienmodus modus = _modusRechnen;
  Bedienmodus get _modusRechnen;
  Bedienmodus get _modusHilfe;

  /// Der Hilfe-Modus (help_mode.dart): Shift+MENÜ (F1) schaltet ihn ein, BEENDEN aus. Solange er an ist, wird
  /// nichts eingegeben.
  bool get hilfeModus => identical(modus, _modusHilfe);

  /// Für die Bedienmodi, die keine Unterklassen von ChangeNotifier sind.
  void _geaendert() => notifyListeners();

  /// Lese-Modus: Tasten lösen keine Hilfe aus, die Seite zeigt den vollen Text; sonst der Inspekt-Modus.
  bool hilfeLesen = false;

  /// Zuletzt mit ▲ ▼ geblättert: die Funktionstasten schieben sich senkrecht, sonst waagrecht (VA-14).
  bool funktionenSenkrecht = false;

  /// Ein getipptes `\` wartet auf das nächste Zeichen: `\c`, `\s` und `\v` sind Befehle wie in der Konsole.
  bool rueckstrich = false;

  // ---------- Schreiben in den Rechner ----------

  /// Nach einer Taste: Shift und Präfixe gelten nur einmal, ein Nicht-Buchstabe beendet Alpha.
  void _ende({bool alphaAus = false}) {
    shift = false;
    if (alphaAus) alpha = false;
  }

  /// Gibt Zeichen an den Rechner und bricht die Zeile um, wenn sie voll genug ist (doc/app.md 4).
  void _schreibe(String text) {
    final praefix = text == "~" || text == "|" || text == "'";
    for (final c in text.split("")) {
      // Alpha+ENTER bricht von Hand um, im Code wird ab 80 % das Leerzeichen zum Zeilenumbruch
      if (c == "\n" || (c == " " && zustand.codeOffen && _voll)) {
        _umbrechen(vonHand: c == "\n");
        continue;
      }
      zustand = api.taste(c, zeilen: _stackZeilen);
    }
    // Präfixe gelten, solange das Token mit ihnen offen ist: ~sin behält den Rahmen um ~, bis sin fertig ist
    if (!praefix) {
      final o = zustand.offen;
      tilde = RegExp(r"^~[a-z]*$").hasMatch(o);
      strich = RegExp(r"^~?\|$").hasMatch(o);
      apostroph = RegExp(r"^'[!=+\-*/~|]*[a-z]*$").hasMatch(o);
    }
    _zurueckschieben();
    // nach einer Operation ab 80 %, nach einem ENTER (vorgemerkt) ab 90 %
    final ruhig = !zustand.codeOffen && zustand.offen.isEmpty && zustand.fehler == null;
    if (ruhig && (zustand.enterVorgemerkt ? _gefuellt(0.9) : _voll)) _umbrechen();
  }

  bool get _voll => _gefuellt(0.8);
  bool _gefuellt(double anteil) => zeile.length > zeichenProZeile * anteil;

  /// Nach einer Eingabe: wieder Tos und neueste Zeilen, nichts seitlich geschoben.
  void _zurueckschieben() {
    stackVersatz = verlaufVersatz = 0;
    _eingabeGeschoben.clear();
    _stackGeschoben.clear();
  }

  /// Schließt die Zeile ab; [vonHand] (Return, Alpha ⏎) legt auch eine leere Zeile in den Verlauf (FA-21).
  void _umbrechen({bool vonHand = false}) {
    final text = zeile;
    zustand = api.zeilenende(zeilen: _stackZeilen);
    if (text.isEmpty && !vonHand) return;
    verlauf.insert(0, (text: text, fehler: null));
    if (verlauf.length > RechnerModell.verlaufMax) verlauf.removeLast();
  }

  // ---------- Was die Teile voneinander brauchen ----------
  // Jeder Teil (Mixin) ruft die anderen nur über diese Deklarationen auf; umgesetzt sind sie im genannten Teil.

  // Eingabe (input.dart)
  void druecke(Taste t);

  // Belegung (assignment.dart)
  List<Taste?> get funktionstasten;
  String get seitenHilfe;
  void _blaettere(int schritt, {bool begrenzt = false});

  // Hilfe-Modus (help_mode.dart)
  void _hilfeStarten();

  // Zwischenablage (clipboard.dart)
  bool _rueckstrichBefehl(String c);

  // Ausschnitt (viewport.dart)
  String eingabeText(int r);
  String? get offenesToken;
  int stackPosition(int r);
}
