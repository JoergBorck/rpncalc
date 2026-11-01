import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rpncalc/helper.dart' show zahl;
import 'package:rpncalc/rpnapi.dart';

import 'hilfe.dart';
import 'tasten.dart';

/// Die Bereiche, zwischen denen Tab wechselt (doc/app.md 3.3).
enum Bereich { eingabe, stack, funktionen, variablen }

/// Wie eine Taste gerade beschriftet ist.
enum Modus { normal, shift, tilde, strich, alpha }

typedef Beschriftung = ({String text, Modus modus, bool gedimmt});

/// Eine abgeschlossene Zeile im Verlauf.
typedef Verlaufszeile = ({String text, Fehler? fehler});

/// Der Zustand der Oberfläche über dem Rechner: Umschaltungen, Bereich, Verlauf und Zeilenumbruch.
class RechnerModell extends ChangeNotifier {
  /// Version der App (MAJOR.MINOR.PATCH wie in pubspec.yaml); der Rechner prüft damit die Angabe `app` von
  /// Bibliotheken (doc/api.md 9.1).
  static const String appVersion = "0.1.0";

  final RpnApi api = RpnApi()..appVersion = appVersion;
  late Zustand zustand = api.zustand(zeilen: _stackZeilen);

  bool shift = false, tilde = false, strich = false, apostroph = false, alpha = false;

  /// Im Alpha-Modus macht Shift den nächsten Buchstaben groß, danach endet Alpha (doc/app.md 3.2).
  bool get gross => alpha && shift;

  /// Shift für alles außer Buchstaben: im Alpha-Modus wirkt Shift nur auf Buchstaben, alle anderen Tasten
  /// behalten ihre normale Belegung (sonst würde ⌫ zu C, MENÜ zu HILFE, TAB rückwärts).
  bool get shiftWirkt => shift && !alpha;
  Bereich bereich = Bereich.eingabe;
  String domaene = "Grundfunktionen";
  int funktionsSeite = 0;   // 0 = Domäne, 1… = eigene Funktionen
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

  static const int _stackZeilen = 40;
  static const int verlaufMax = 100;

  /// Anteil der Eingabe an der Breite der Seite „Rechnen“: halb, maximiert ganz oder gar nicht (doc/app.md 3.5).
  double get anteilEingabe => !maximiert
      ? 0.5
      : switch (bereich) { Bereich.eingabe => 1.0, Bereich.stack => 0.0, _ => 0.5 };

  /// Die aktuelle Eingabezeile; nach einem Umbruch leer.
  String get zeile => zustand.zeileFertig ? "" : zustand.zeile;

  // ---------- Beschriftung ----------

  /// Die Belegung der zehn Funktionstasten für den gewählten Bereich bzw. nach `'`.
  List<Taste?> get funktionstasten {
    if (apostroph || bereich == Bereich.variablen) return _seiten(_variablen);
    final d = _domaenenSeiten;
    if (funktionsSeite < d.length) return d[funktionsSeite];
    return _seiten(_eigene, funktionsSeite - d.length);
  }

  /// Name der Seite, die die Funktionstasten zeigen.
  String get seitenName {
    if (apostroph || bereich == Bereich.variablen) return "Variablen";
    final d = _domaenenSeiten.length;
    if (funktionsSeite < d) return d > 1 ? "$domaene ${funktionsSeite + 1}/$d" : domaene;
    final e = funktionsSeite - d + 1;
    return "Eigene${e > 1 ? " $e" : ""}";
  }

  int get _eigeneSeiten => (_eigene.length / 10).ceil().clamp(1, 99);

  /// Die Seiten der Funktionstasten je Bibliothek, einmal erzeugt: bibliotheksFunktionen lädt die Bibliothek
  /// dafür in einen Probe-Rechner, und das Aufleuchten erkennt eine Taste an ihrer Identität.
  final Map<String, List<List<Taste?>>> _bibliotheksSeiten = {};

  /// Die Domänen im Menü: die eingebauten, dann die Bibliotheken des Rechners (doc/app.md 3.4).
  List<String> get domaenenNamen => [...domaenen.keys, for (final b in api.bibliotheken()) b.name];

  /// Die Seiten der Funktionstasten für die gewählte Domäne; eine Bibliothek zeigt ihre Funktionen in der
  /// Reihenfolge der Datei, zehn je Seite.
  List<List<Taste?>> get _domaenenSeiten {
    final eingebaut = domaenen[domaene];
    if (eingebaut != null) return [eingebaut];
    return _bibliotheksSeiten.putIfAbsent(domaene, () {
      final tasten = [for (final f in api.bibliotheksFunktionen(domaene)) Taste(f, name: true)];
      return [for (int s = 0; s * 10 < tasten.length || s == 0; s++) _seiten(tasten, s)];
    });
  }

  List<Taste> get _variablen => [
        for (Speicher s in zustand.speicher)
          if (s.art != SpeicherArt.funktion) Taste(s.name, eingabe: apostroph ? s.name : "'${s.name}", name: true),
      ];

  /// Eigene Funktionen ohne die aus Bibliotheken; die stehen auf den Seiten ihrer Domäne.
  List<Taste> get _eigene => [
        for (Speicher s in zustand.speicher)
          if (s.art == SpeicherArt.funktion && !api.geladeneBibliotheksFunktionen.contains(s.name))
            Taste(s.name, name: true),
      ];

  static List<Taste?> _seiten(List<Taste> alle, [int seite = 0]) =>
      [for (int i = 0; i < 10; i++) seite * 10 + i < alle.length ? alle[seite * 10 + i] : null];

  /// Beschriftung einer Taste in den aktuellen Umschaltungen.
  Beschriftung beschriftung(Taste t) {
    // im Hilfe-Modus tragen MENÜ, ALPHA und ⌫ ihre Aufgabe dort (doc/app.md 5.2)
    if (hilfeModus) {
      final text = switch (t.aktion) {
        Aktion.menue => hilfeLesen ? "ANFANG" : "BEENDEN",
        Aktion.alpha => hilfeLesen ? "INSPEKT" : "LESEN",
        Aktion.loeschen when hilfeLesen => "BEENDEN",
        _ => null,
      };
      if (text != null) return (text: text, modus: Modus.normal, gedimmt: false);
    }
    if (alpha && t.buchstabe != null) return (text: gross ? t.buchstabe!.toUpperCase() : t.buchstabe!, modus: Modus.alpha, gedimmt: false);
    if (alpha && t.aktion == Aktion.enter) return (text: "⏎", modus: Modus.alpha, gedimmt: false);
    // ~ wirkt auch auf die Shift-Funktion: ~ ⇧ ÷ ist ≤ (geschrieben ~>)
    if (shiftWirkt && tilde && t.shiftTilde != null) return (text: t.shiftTilde!, modus: Modus.tilde, gedimmt: false);
    if (shiftWirkt && t.shift != null) return (text: t.shift!, modus: Modus.shift, gedimmt: false);
    if (tilde && strich) return t.beide != null ? (text: t.beide!, modus: Modus.tilde, gedimmt: false) : _gedimmt(t);
    if (tilde) {
      if (t.tilde != null) return (text: t.tilde!, modus: Modus.tilde, gedimmt: false);
      return RegExp(r"^[0-9.ê]$").hasMatch(t.text) ? _normal(t) : _gedimmt(t); // ~3 ist eine negative Zahl
    }
    if (strich) {
      if (t.strich != null) return (text: t.strich!, modus: Modus.strich, gedimmt: false);
      return _gedimmt(t);
    }
    return shiftWirkt ? _gedimmt(t) : _normal(t);
  }

  static Beschriftung _normal(Taste t) => (text: t.text, modus: Modus.normal, gedimmt: false);
  static Beschriftung _gedimmt(Taste t) => (text: t.text, modus: Modus.normal, gedimmt: true);

  // ---------- Tasten ----------

  // ---------- Hilfe-Modus (doc/app.md 5.2) ----------

  /// Shift+MENÜ (F1) schaltet ihn ein, BEENDEN aus. Solange er an ist, wird nichts eingegeben.
  bool hilfeModus = false;

  /// Lese-Modus: Tasten lösen keine Hilfe aus, die Seite zeigt den vollen Text; sonst der Inspekt-Modus.
  bool hilfeLesen = false;

  /// Der volle Text (Einzelheiten) gehört zum Lese-Modus.
  bool get hilfeDetails => hilfeLesen;

  /// Im Lese-Modus der mit TAB gewählte Verweis der gezeigten Seite, sonst -1.
  int hilfeVerweis = -1;

  /// Blättert den Hilfeschirm im Lese-Modus (▲ ▼).
  final ScrollController hilfeScroll = ScrollController();

  /// Die gezeigten Hilfeseiten, die letzte ist sichtbar; ◄ geht zurück. Leer: kein Hilfeschirm.
  final List<List<Hilfe>> _hilfeSeiten = [];

  /// Die sichtbare Hilfeseite oder null, wenn kein Hilfeschirm offen ist.
  List<Hilfe>? get hilfeSeite => _hilfeSeiten.isEmpty ? null : _hilfeSeiten.last;

  /// Die Verweise der sichtbaren Seite in ihrer Reihenfolge, jeder nur einmal.
  List<String> get hilfeVerweise => <String>{for (final h in hilfeSeite ?? const <Hilfe>[]) ...h.verweise}.toList();

  /// Der letzte Tooltip einer Taste: mit seiner Seite startet die Hilfe, wenn er höchstens 10 s her ist.
  (Taste, DateTime)? _letzterTooltip;
  void tooltipGezeigt(Taste t) => _letzterTooltip = (t, DateTime.now());

  void _neueSeite(List<Hilfe> seite) {
    if (seite.isEmpty) return;
    _hilfeSeiten.add(seite);
    hilfeVerweis = -1;
    if (hilfeScroll.hasClients) hilfeScroll.jumpTo(0);
  }

  /// Zeigt eine Hilfeseite, z.B. zu einem Element der Anzeige oder einem Verweis.
  void zeigeHilfe(List<Hilfe> seite) {
    _neueSeite(seite);
    notifyListeners();
  }

  /// Zeigt die Seite zu einem Verweis.
  void folgeVerweis(String kennung) => zeigeHilfe(AppHilfe.nachschlagen(api, kennung));

  /// Ein Tipp auf den Hilfeschirm schließt ihn, der Hilfe-Modus bleibt.
  void hilfeSchliessen() {
    _hilfeSeiten.clear();
    hilfeVerweis = -1;
    notifyListeners();
  }

  /// Startet die Hilfe im Inspekt-Modus mit der Seite des letzten Tooltips (höchstens 10 s her) oder der Startseite.
  void _hilfeStarten() {
    hilfeModus = true;
    hilfeLesen = shift = false;
    _hilfeSeiten.clear();
    final letzter = _letzterTooltip;
    if (letzter != null && DateTime.now().difference(letzter.$2) <= const Duration(seconds: 10)) {
      _neueSeite(AppHilfe.fuerTaste(api, letzter.$1));
    }
    if (_hilfeSeiten.isEmpty) _neueSeite(AppHilfe.nachschlagen(api, "#"));
  }

  void _hilfeBeenden() {
    hilfeModus = hilfeLesen = false;
    hilfeVerweis = -1;
    _hilfeSeiten.clear();
  }

  void _waehleVerweis({bool rueckwaerts = false}) {
    final n = hilfeVerweise.length;
    if (n == 0) return;
    hilfeVerweis = hilfeVerweis < 0 ? (rueckwaerts ? n - 1 : 0) : (hilfeVerweis + (rueckwaerts ? n - 1 : 1)) % n;
  }

  void _folgeGewaehltem() {
    final v = hilfeVerweise;
    if (hilfeVerweis >= 0 && hilfeVerweis < v.length) _neueSeite(AppHilfe.nachschlagen(api, v[hilfeVerweis]));
  }

  /// Inspekt-Modus: jede Taste zeigt ihre Hilfe (auch ⌫ und SHIFT), BEENDEN (MENÜ) beendet, LESEN (ALPHA) wechselt
  /// in den Lese-Modus. Lese-Modus: TAB wählt einen Verweis, ENTER folgt ihm, ANFANG (MENÜ) zeigt die Startseite,
  /// BEENDEN (⌫) beendet, ALPHA geht zurück; andere Tasten tun nichts.
  void _hilfeTaste(Taste t) {
    if (hilfeLesen) {
      switch (t.aktion) {
        case Aktion.alpha:
          hilfeLesen = false;
          hilfeVerweis = -1;
        case Aktion.menue:
          _neueSeite(AppHilfe.nachschlagen(api, "#"));
        case Aktion.loeschen:
          _hilfeBeenden();
        case Aktion.shift:
          shift = !shift; // für Shift+TAB
          return;
        case Aktion.tab:
          _waehleVerweis(rueckwaerts: shift);
        case Aktion.enter:
          _folgeGewaehltem();
        default:
      }
      shift = false;
      return;
    }
    switch (t.aktion) {
      case Aktion.alpha:
        hilfeLesen = true;
        hilfeVerweis = -1;
        if (_hilfeSeiten.isEmpty) _neueSeite(AppHilfe.nachschlagen(api, "#")); // Schirm war mit einem Tipp geschlossen
      case Aktion.menue:
        _hilfeBeenden();
      default:
        _neueSeite(AppHilfe.fuerTaste(api, t));
    }
  }

  void druecke(Taste t) {
    if (hilfeModus) {
      _hilfeTaste(t);
      notifyListeners();
      return;
    }
    if (t.reserviert && !(alpha && t.buchstabe != null)) return; // reserviert, aber in Alpha ein Buchstabe
    switch (t.aktion) {
      case Aktion.shift:
        shift = !shift; // im Alpha-Modus: der nächste Buchstabe groß
      case Aktion.alpha:
        // ALPHA schaltet um; Shift+ALPHA: Alpha an, Shift bleibt für einen großen Buchstaben
        // (eine eigene Belegung ist noch offen, doc/app.md 7, Punkt 6)
        alpha = !alpha;
        if (!alpha) shift = false;
      case Aktion.tab:
        final n = Bereich.values.length;
        bereich = Bereich.values[(bereich.index + (shiftWirkt ? n - 1 : 1)) % n];
        shift = false;
      case Aktion.menue:
        // Shift+MENÜ ist die Hilfe; MENÜ allein öffnet die Oberfläche (Domänen)
        if (shiftWirkt) _hilfeStarten();
      case Aktion.maximieren:
        // nur Eingabe und Stack; die Seiten Funktionen und Variablen haben schon die ganze Breite
        if (bereich == Bereich.eingabe || bereich == Bereich.stack) maximiert = !maximiert;
        shift = false;
      case Aktion.tilde:
        _ende(alphaAus: true);
        _schreibe("~");
        tilde = true;
      case Aktion.strich:
        _ende(alphaAus: true);
        final doppelt = strich; // || ist der Betrag
        _schreibe("|");
        strich = !doppelt;
        if (doppelt) tilde = false;
      // ⌫ löscht auch im Alpha-Modus zeichenweise und lässt ihn an (z.B. beim Programmieren)
      case Aktion.loeschen when !shiftWirkt:
        zustand = api.loeschen(zeilen: _stackZeilen);
        tilde = strich = apostroph = shift = false;
        _zurueckschieben();
      case Aktion.apostroph when !alpha:
        _schreibe("'");
        apostroph = true;
      default:
        _schreibeTaste(t);
    }
    notifyListeners();
  }

  void _schreibeTaste(Taste t) {
    if (alpha && t.buchstabe != null) {
      if (shift) {
        // ein Großbuchstabe ist ein Befehl aus genau einem Zeichen: danach endet Alpha (wie in der Grammatik)
        _schreibe(t.buchstabe!.toUpperCase());
        shift = alpha = false;
        return;
      }
      _schreibe(t.buchstabe!);
      return; // Kleinbuchstaben: Alpha bleibt an
    }
    if (alpha && t.aktion == Aktion.enter) {
      _schreibe("\n");
      shift = false;
      return;
    }
    final shiftWirkt = this.shiftWirkt; // vor _ende, das Alpha beendet
    final String text;
    if (shiftWirkt && tilde && t.shiftTildeEingabe != null) {
      zustand = api.loeschen(zeilen: _stackZeilen); // das offene ~ weicht dem Zeichen (≤ statt ~>)
      text = t.shiftTildeEingabe!;
    } else if (shiftWirkt && t.shift != null) {
      text = t.shiftEingabe!;
    } else if (tilde && t.tildeEingabe != null) {
      text = t.tildeEingabe!;
    } else {
      text = t.eingabe;
    }
    final name = t.name || (shiftWirkt && t.shift != null && t.funktion == null && RegExp(r"^[a-z]{2,}").hasMatch(text));
    _ende(alphaAus: true);
    if (name) {
      _schreibeName(text);
    } else {
      _schreibe(text);
    }
  }

  /// Schreibt einen Namen: bei Bedarf ein "_" davor, damit er nicht mit dem vorigen verschmilzt,
  /// und ein "_" dahinter, damit er gleich ausgeführt wird (doc/app.md 4.1).
  void _schreibeName(String name) {
    final z = zeile;
    if (z.isNotEmpty && RegExp(r"[A-Za-z]$").hasMatch(z) && !RegExp(r"'[!|=+\-*/~]*$").hasMatch(z)) {
      _schreibe("_");
    }
    _schreibe(name);
    _schreibe("_");
  }

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
        _umbrechen();
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

  void _umbrechen() {
    final text = zeile;
    zustand = api.zeilenende(zeilen: _stackZeilen);
    if (text.isEmpty) return;
    verlauf.insert(0, (text: text, fehler: null));
    if (verlauf.length > verlaufMax) verlauf.removeLast();
  }

  // ---------- Cursorkreuz und Menü ----------

  // ---------- Ausschnitte der Anzeige ----------

  /// Text der sichtbaren Eingabezeile [r]: 0 ist die aktuelle Zeile, danach der Verlauf.
  String eingabeText(int r) {
    if (r == 0) return zeile.replaceAll("\n", "↵");
    final i = verlaufVersatz + r - 1;
    return i < verlauf.length ? verlauf[i].text.replaceAll("\n", "↵") : "";
  }

  /// Text der sichtbaren Stackzeile [r]: Wert und Tags.
  String stackText(int r) {
    if (r == 0 && offenesToken != null) return offenesToken!;
    final s = stackZeile(r);
    if (s == null) return "";
    return "${zahl(s.wert)}${s.tags.isEmpty ? "" : " ${s.tags.join(",")}"}";
  }

  /// Das offene Token, das grau über dem Tos steht (doc/app.md Kapitel 2); null, wenn keins offen ist,
  /// nach einem Fehler und wenn der Stack zurückgeblättert ist.
  String? get offenesToken {
    final z = zustand;
    if (z.offen.isEmpty || z.fehler != null || z.zeileFertig || stackVersatz > 0) return null;
    return z.offen.replaceAll("\n", "↵");
  }

  /// Der Stack-Wert in der sichtbaren Zeile [r]; ein offenes Token belegt die oberste Zeile.
  StackZeile? stackZeile(int r) {
    final p = stackPosition(r);
    return p >= 0 && p < zustand.stack.length ? zustand.stack[p] : null;
  }

  /// Die Stackposition, die in Zeile [r] steht (auch wenn sie leer ist); -1 für die Zeile des offenen Tokens.
  int stackPosition(int r) => stackVersatz + r - (offenesToken == null ? 0 : 1);

  /// Erstes sichtbares Zeichen der Zeile [r]; ohne Schieben bei der aktuellen Zeile das Ende.
  int eingabeVon(int r) => _von(eingabeText(r), _platz(platzEingabe, r), _eingabeGeschoben[r] ?? (r == 0 ? 1 << 30 : 0));
  int stackVon(int r) => _von(stackText(r), _platz(platzStack, r), _stackGeschoben[r] ?? 0);

  static int _platz(List<int> platz, int r) => r < platz.length ? platz[r] : 1 << 30;
  static int _maxVon(String text, int platz) => text.length > platz ? text.length - platz : 0;
  static int _von(String text, int platz, int gewuenscht) => gewuenscht.clamp(0, _maxVon(text, platz));

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

  /// Ob sich im gewählten Bereich etwas nach links bzw. rechts schieben lässt (für die Pfeile am Rahmen).
  bool kannSchieben(bool rechts) {
    final (platz, text, von) = _spalte;
    for (int r = 0; r < platz.length; r++) {
      final v = von(r);
      if (rechts ? v < _maxVon(text(r), platz[r]) : v > 0) return true;
    }
    return false;
  }

  (List<int>, String Function(int), int Function(int)) get _spalte => bereich == Bereich.stack
      ? (platzStack, stackText, stackVon)
      : bereich == Bereich.eingabe ? (platzEingabe, eingabeText, eingabeVon) : (const <int>[], (_) => "", (_) => 0);

  /// Schiebt jede sichtbare Zeile für sich um ein Zeichen, bis zu ihrem Anfang bzw. Ende.
  void _schieben(int schritt) {
    final (platz, text, von) = _spalte;
    final geschoben = bereich == Bereich.stack ? _stackGeschoben : _eingabeGeschoben;
    for (int r = 0; r < platz.length; r++) {
      geschoben[r] = (von(r) + schritt).clamp(0, _maxVon(text(r), platz[r]));
    }
  }

  void pfeil(AxisDirection richtung) {
    if (hilfeModus) {
      // ◄ geht zurück, die erste Seite bleibt; im Lese-Modus blättern ▲ ▼ und ► folgt dem gewählten Verweis
      // (ohne Auswahl wählt er den ersten), sonst Hilfe zum Cursorkreuz
      if (richtung == AxisDirection.left) {
        if (_hilfeSeiten.length > 1) _hilfeSeiten.removeLast();
        hilfeVerweis = -1;
      } else if (!hilfeLesen) {
        _neueSeite(AppHilfe.nachschlagen(api, "app:cursorkreuz"));
      } else if (richtung == AxisDirection.right) {
        hilfeVerweis < 0 ? _waehleVerweis() : _folgeGewaehltem();
      } else if (hilfeScroll.hasClients) {
        final p = hilfeScroll.position;
        final ziel = (p.pixels + (richtung == AxisDirection.down ? 80 : -80)).clamp(0.0, p.maxScrollExtent);
        hilfeScroll.animateTo(ziel, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
      }
      notifyListeners();
      return;
    }
    final seitlich = switch (richtung) { AxisDirection.left => -1, AxisDirection.right => 1, _ => 0 };
    switch (bereich) {
      case Bereich.variablen:
        break;
      case Bereich.eingabe: // ▲ zeigt ältere Zeilen; kein Cursor in der Zeile, solange es kein Undo gibt
        final sichtbar = (platzEingabe.length - 1).clamp(1, 99);
        if (richtung == AxisDirection.up && verlaufVersatz + sichtbar < verlauf.length) verlaufVersatz++;
        if (richtung == AxisDirection.down && verlaufVersatz > 0) verlaufVersatz--;
        if (seitlich == 0) _eingabeGeschoben.removeWhere((r, _) => r > 0); // nach dem Blättern andere Zeilen
        if (seitlich != 0) _schieben(seitlich);
      case Bereich.stack:
        if (richtung == AxisDirection.down && stackVersatz + platzStack.length < zustand.tiefe) stackVersatz++;
        if (richtung == AxisDirection.up && stackVersatz > 0) stackVersatz--;
        if (seitlich == 0) _stackGeschoben.clear(); // nach dem Blättern stehen andere Werte in den Zeilen
        if (seitlich != 0) _schieben(seitlich);
      case Bereich.funktionen:
        final n = _domaenenSeiten.length + _eigeneSeiten;
        if (richtung == AxisDirection.right) funktionsSeite = (funktionsSeite + 1) % n;
        if (richtung == AxisDirection.left) funktionsSeite = (funktionsSeite + n - 1) % n;
    }
    notifyListeners();
  }

  // ---------- Tastatur (doc/app.md Kapitel 6) ----------

  /// Tasten, die gerade kurz aufleuchten, weil ihr Zeichen auf der Tastatur getippt wurde; Buchstaben als
  /// "buchstabe:x" (die Taste zeigt dann den Buchstaben). Jede mit eigenem Zeitgeber.
  final Map<Object, Timer> _leuchtend = {};

  bool leuchtetTaste(Taste t) => _leuchtend.containsKey(t);
  bool leuchtetBuchstabe(String b) => _leuchtend.containsKey("buchstabe:$b");

  /// Wie der aufleuchtende Buchstabe getippt wurde (groß oder klein), damit die Taste ihn so zeigt.
  final Map<String, String> _getippterBuchstabe = {};
  String getippterBuchstabe(String b) => _getippterBuchstabe[b] ?? b;

  /// Zeichen leuchten kurz, Funktionen und Operatoren länger.
  static const _kurz = Duration(milliseconds: 250), _lang = Duration(milliseconds: 600);

  static const _enter = Taste("ENTER", eingabe: " ", shift: "_", aktion: Aktion.enter);
  static const _loeschen = Taste("⌫", aktion: Aktion.loeschen, shift: "C");

  /// Ein auf der Tastatur getipptes Zeichen: geht so an den Rechner, wie es getippt wurde, ohne die Automatik
  /// für Namen; Präfixe schalten die Beschriftung um wie ihr Knopf. Im Hilfe-Modus zeigt es die Hilfe.
  void tippeZeichen(String c) {
    final vorher = zustand.offen;
    _leuchte(c);
    if (hilfeModus) {
      if (hilfeLesen) return; // im Lese-Modus tun getippte Zeichen nichts
      final kennung = RegExp(r"^[0-9]$").hasMatch(c) ? "#zahlen" : c;
      final t = tasteFuer(c);
      _neueSeite(t != null && t.buchstabe != c.toLowerCase() ? AppHilfe.fuerTaste(api, t) : AppHilfe.nachschlagen(api, kennung));
      notifyListeners();
      return;
    }
    shift = false; // die Umschalttaste der Tastatur steckt schon im Zeichen
    switch (c) {
      case "~":
        _schreibe("~");
        tilde = true;
      case "|":
        final doppelt = strich; // || ist der Betrag
        _schreibe("|");
        strich = !doppelt;
        if (doppelt) tilde = false;
      case "'":
        _schreibe("'");
        apostroph = true;
      // ~> ~< ~= getippt: das offene ~ weicht dem besser lesbaren Zeichen (doc/app.md Kapitel 6)
      case ">" || "<" || "=" when tilde && !strich:
        zustand = api.loeschen(zeilen: _stackZeilen);
        tilde = false;
        _schreibe(const {">": "≤", "<": "≥", "=": "≠"}[c]!);
      default:
        _schreibe(c);
    }
    _nameFertig(vorher);
    notifyListeners();
  }

  /// Enter auf dem Ziffernblock tut, was sein Name sagt: ENTER (Leerzeichen), dann bricht es die Zeile um. Das
  /// Enter bleibt am Zeilenende vorgemerkt, das erste Token der nächsten Zeile entscheidet: „5 Enter +“ ergibt 10,
  /// „5 Enter 3 +“ ergibt 8 (doc/app.md Kapitel 6).
  void tastaturReturn() => _zeilenende(" \n");

  /// Return bricht nur die Zeile um, wie ALPHA ⏎ (doc/app.md Kapitel 6).
  void tastaturZeilenumbruch() => _zeilenende("\n");

  void _zeilenende(String text) {
    final vorher = zustand.offen;
    _leuchteAuf(_enter, _kurz);
    if (hilfeModus) return druecke(_enter);
    shift = false;
    _schreibe(text);
    _nameFertig(vorher);
    notifyListeners();
  }

  /// Backspace auf der Tastatur ist ⌫.
  void tastaturLoeschen() {
    _leuchteAuf(_loeschen, _kurz);
    shift = false;
    druecke(_loeschen);
  }

  /// Tab und Umschalt+Tab wechseln den Bereich.
  void tastaturTab({bool rueckwaerts = false}) {
    if (hilfeModus && hilfeLesen) {
      _waehleVerweis(rueckwaerts: rueckwaerts);
      return notifyListeners();
    }
    if (hilfeModus) return druecke(const Taste("TAB", aktion: Aktion.tab));
    final n = Bereich.values.length;
    bereich = Bereich.values[(bereich.index + (rueckwaerts ? n - 1 : 1)) % n];
    notifyListeners();
  }

  /// F1 schaltet den Hilfe-Modus an und aus.
  void tastaturHilfe() {
    hilfeModus ? _hilfeBeenden() : _hilfeStarten();
    notifyListeners();
  }

  /// Esc beendet die Hilfe.
  void tastaturEsc() {
    if (!hilfeModus) return;
    _hilfeBeenden();
    notifyListeners();
  }

  /// Der Knopf, der einem getippten Zeichen entspricht, oder null (z.B. bei `<`).
  Taste? tasteFuer(String c) {
    if (c == " " || c == "_") return _enter;
    final alle = [...obereTasten, ...untereTasten].expand((r) => r);
    for (final t in alle) {
      if (t.funktion == null && !t.reserviert && t.text.isNotEmpty && (t.eingabe == c || t.text == c)) return t;
    }
    // Zeichen auf Shift und ~ Shift der Rechenspalte: < > = & und ≤ ≥ ≠
    for (final t in alle) {
      if (t.shift != null && (t.shiftEingabe == c || t.shiftTildeEingabe == c)) return t;
    }
    // Buchstaben: die Taste, die ihn im Alpha-Modus schreibt
    for (final t in alle) {
      if (t.buchstabe != null && t.buchstabe == c.toLowerCase()) return t;
    }
    return null;
  }

  /// Leuchtet für ein getipptes Zeichen auf: ein Buchstabe auf seiner Alpha-Taste, sonst die passende Taste.
  void _leuchte(String c) {
    final t = tasteFuer(c);
    // ein Großbuchstabe mit eigener Taste ist ein Befehl (D, S, R …): diese Taste, wie ein Operator
    if (RegExp(r"^[A-Z]$").hasMatch(c) && t?.text == c) return _leuchteAuf(t!, _lang);
    if (RegExp(r"^[a-zA-Z]$").hasMatch(c)) {
      _getippterBuchstabe[c.toLowerCase()] = c;
      return _leuchteAuf("buchstabe:${c.toLowerCase()}", _kurz);
    }
    if (t != null) _leuchteAuf(t, RegExp(r"^[0-9.ê ]$").hasMatch(c) ? _kurz : _lang);
  }

  /// Ist mit dem letzten Zeichen ein Name fertig geworden (z.B. sin in "30sin*"), leuchtet seine Funktionstaste.
  void _nameFertig(String vorher) {
    final name = RegExp(r"^['~|!=+\-*/]*([a-z]+)$").firstMatch(vorher)?.group(1);
    if (name == null) return;
    final o = zustand.offen;
    if (o.length > vorher.length && o.startsWith(vorher)) return; // der Name wächst noch
    for (final t in funktionstasten) {
      if (t != null && (t.eingabe == name || t.eingabe == "'$name" || t.shiftEingabe == name)) _leuchteAuf(t, _lang);
    }
  }

  void _leuchteAuf(Object schluessel, Duration dauer) {
    _leuchtend[schluessel]?.cancel();
    _leuchtend[schluessel] = Timer(dauer, () {
      _leuchtend.remove(schluessel);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    for (final t in _leuchtend.values) {
      t.cancel();
    }
    hilfeScroll.dispose();
    super.dispose();
  }

  /// Ein Tipp in die Anzeige wählt den Bereich (doc/app.md 3.3); die Funktionstasten wählen keinen.
  void waehleBereich(Bereich b) {
    if (bereich == b) return;
    bereich = b;
    notifyListeners();
  }

  /// Tipp in Eingabe oder Stack: wählt den Bereich sofort; ein zweiter Tipp kurz danach (Doppelklick) wirkt wie
  /// die Taste `[ ]` / `[|]` (doc/app.md 3.5). Selbst erkannt, damit der erste Tipp nicht auf den zweiten wartet.
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

  /// Wählt die Domäne der Funktionstasten; eine Bibliothek wird dabei einmal geladen.
  void waehleDomaene(String name) {
    domaene = name;
    funktionsSeite = 0;
    if (!domaenen.containsKey(name) && api.bibliotheksVersion(name) == null) {
      api.ladeBibliothek(name);
      zustand = api.zustand(zeilen: _stackZeilen);
    }
    notifyListeners();
  }
}
