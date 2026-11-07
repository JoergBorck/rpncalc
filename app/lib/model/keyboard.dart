/// Aufgabe: die PC-Tastatur: getippte Zeichen gehen so an den Rechner, wie sie getippt wurden; Return, Enter,
/// Backspace, Tab, F1 und Esc haben eigene Aufgaben. Die passende Taste des Tastenfelds leuchtet kurz auf, ein
/// fertig getippter Name auf seiner Funktionstaste.
///
/// Abgrenzung: Welche Taste der Tastatur welche Methode aufruft, steht in main.dart; Knöpfe des Tastenfelds
/// gehen über input.dart. Jede Bedienung geht an den aktiven Bedienmodus (modes.dart); hier steht, was sie im
/// Rechnen bewirkt.
///
/// Siehe auch: doc/app.md Kapitel 6, main.dart.
part of 'model.dart';

/// PC-Tastatur und Leuchten.
mixin _Tastatur on ModellKern {
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
    _leuchte(c);
    modus.tippeZeichen(c);
  }

  /// Ein getipptes Zeichen im Bedienmodus Rechnen.
  void _tippeRechnen(String c) {
    final vorher = zustand.offen;
    shift = false; // die Umschalttaste der Tastatur steckt schon im Zeichen
    if (_rueckstrichBefehl(c)) {
      notifyListeners();
      return;
    }
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
    _leuchteAuf(_enter, _kurz);
    modus.zeilenende(text);
  }

  void _zeilenendeRechnen(String text) {
    final vorher = zustand.offen;
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

  /// Tab und Umschalt+Tab wechseln den Bereich (in der Hilfe: siehe modes.dart).
  void tastaturTab({bool rueckwaerts = false}) => modus.tab(rueckwaerts: rueckwaerts);

  void _tabRechnen({bool rueckwaerts = false}) {
    final n = Bereich.values.length;
    bereich = Bereich.values[(bereich.index + (rueckwaerts ? n - 1 : 1)) % n];
    notifyListeners();
  }

  /// F1 schaltet den Hilfe-Modus an und aus.
  void tastaturHilfe() => modus.hilfe();

  /// Esc beendet die Hilfe.
  void tastaturEsc() => modus.esc();

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
}
