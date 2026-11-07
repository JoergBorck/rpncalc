/// Aufgabe: die Ausschnitte der Anzeige: welche Texte in den sichtbaren Zeilen von Eingabe und Stack stehen,
/// das offene Token über x, Blättern im Verlauf und im Stack, seitliches Schieben langer Zeilen und was die
/// Pfeile des Cursorkreuzes im gewählten Bereich bewirken.
///
/// Abgrenzung: Wie viel Platz eine Zeile hat, setzt die Anzeige (platzEingabe, platzStack im Kern); gezeichnet
/// wird in display/calc_page.dart. Im Hilfe-Modus gehören die Pfeile help_mode.dart.
///
/// Siehe auch: doc/app.md 3.3 und 3.5, display/calc_page.dart.
part of 'model.dart';

/// Ausschnitte der Anzeige und Pfeile.
mixin _Ausschnitt on ModellKern {
  /// Text der sichtbaren Eingabezeile [r]: 0 ist die aktuelle Zeile, danach der Verlauf.
  @override
  String eingabeText(int r) {
    if (r == 0) return "$zeile${rueckstrich ? r"\" : ""}".replaceAll("\n", "↵"); // ein wartendes \ dahinter
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
  @override
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
  @override
  int stackPosition(int r) => stackVersatz + r - (offenesToken == null ? 0 : 1);

  /// Erstes sichtbares Zeichen der Zeile [r]; ohne Schieben bei der aktuellen Zeile das Ende.
  int eingabeVon(int r) => _von(eingabeText(r), _platz(platzEingabe, r), _eingabeGeschoben[r] ?? (r == 0 ? 1 << 30 : 0));
  int stackVon(int r) => _von(stackText(r), _platz(platzStack, r), _stackGeschoben[r] ?? 0);

  static int _platz(List<int> platz, int r) => r < platz.length ? platz[r] : 1 << 30;
  static int _maxVon(String text, int platz) => text.length > platz ? text.length - platz : 0;
  static int _von(String text, int platz, int gewuenscht) => gewuenscht.clamp(0, _maxVon(text, platz));

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

  /// Wischen bzw. Mausrad in Eingabe oder Stack (doc/app.md 3.3): wählt den Bereich wie ein Tipp und schiebt den
  /// Inhalt um [zeilen], positiv nach oben (ältere Zeilen bzw. tiefere Werte). Liefert, ob sich etwas bewegt hat;
  /// am Anfang und am Ende nicht, dann hält der Nachlauf an. Im Hilfe-Modus tut es nichts.
  bool schiebeZeilen(Bereich b, int zeilen) {
    if (hilfeModus || zeilen == 0 || (b != Bereich.eingabe && b != Bereich.stack)) return false;
    final vorher = (bereich, verlaufVersatz, stackVersatz);
    bereich = b;
    // in der Eingabe zeigt ▲ ältere Zeilen, im Stack ▼ tiefere Werte
    final richtung = (b == Bereich.eingabe) == (zeilen > 0) ? AxisDirection.up : AxisDirection.down;
    for (var i = 0; i < zeilen.abs(); i++) {
      _pfeilRechnen(richtung);
    }
    final bewegt = (verlaufVersatz, stackVersatz) != (vorher.$2, vorher.$3);
    if (!bewegt && vorher.$1 != b) notifyListeners(); // nur der Bereich ist neu
    return bewegt;
  }

  /// Ein Pfeil des Cursorkreuzes oder der Tastatur; was er bewirkt, entscheidet der aktive Bedienmodus.
  void pfeil(AxisDirection richtung) => modus.pfeil(richtung);

  /// Im Bedienmodus Rechnen blättern ▲ ▼ und schieben ◄ ► im gewählten Bereich.
  void _pfeilRechnen(AxisDirection richtung) {
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
        // der unterste Wert darf bis in die Zeile hochkommen, die auch die kleinste Anzeige noch ganz zeigt
        final rest = platzStack.length.clamp(1, RechnerModell.stackMinZeilen);
        if (richtung == AxisDirection.down && stackVersatz + rest < zustand.tiefe) stackVersatz++;
        if (richtung == AxisDirection.up && stackVersatz > 0) stackVersatz--;
        if (_stackZeilen > zustand.stack.length && zustand.stack.length < zustand.tiefe) zustand = api.zustand(zeilen: _stackZeilen); // tiefere Werte holen
        if (seitlich == 0) _stackGeschoben.clear(); // nach dem Blättern stehen andere Werte in den Zeilen
        if (seitlich != 0) _schieben(seitlich);
      case Bereich.funktionen:
        // ◄ ► im Kreis und waagrecht wie das Wischen, ▲ ▼ begrenzt und senkrecht wie das Mausrad (VA-14)
        funktionenSenkrecht = seitlich == 0;
        _blaettere(seitlich != 0 ? seitlich : (richtung == AxisDirection.down ? 1 : -1), begrenzt: seitlich == 0);
    }
    notifyListeners();
  }
}
