/// Aufgabe: die Zwischenablage: Werte und Zeilen kopieren (für ein deutsches Excel), Werte oder Text einfügen,
/// die Befehle \c, \s und \v wie in der Konsole, die Meldung danach und die Markierung der Zeile, zu der das
/// Kontextmenü offen ist.
///
/// Abgrenzung: Das Format für Excel steht im Rechner (fuerExcel, ausExcel); das Menü zeichnet
/// display/context_menu.dart.
///
/// Siehe auch: doc/app.md 2.1, doc/api.md Kapitel 7.
part of 'model.dart';

/// Zwischenablage.
mixin _Ablage on ModellKern {
  /// Kurze Meldung für die Oberfläche, z.B. nach dem Kopieren; die Seite zeigt sie unten an.
  final ValueNotifier<String?> meldung = ValueNotifier(null);

  void _melde(String text) {
    meldung.value = null; // dieselbe Meldung zweimal hintereinander soll auch zweimal erscheinen
    meldung.value = text;
  }

  /// Schließt ein offenes Token mit `_` ab, wie die Konsole vor dem Kopieren: nach `2.25` kopiert man 2,25.
  /// Geht das nicht, wird das `_` wieder gelöscht. Liefert, ob ein Wert dazugekommen ist.
  bool _tokenAbschliessen() {
    if (zustand.offen.isEmpty || zustand.fehler != null || zustand.zeileFertig) return false;
    zustand = api.taste("_", zeilen: _stackZeilen);
    if (zustand.fehler == null) return true;
    zustand = api.loeschen(zeilen: _stackZeilen);
    return false;
  }

  /// Der Text für die Zwischenablage oder null, wenn es nichts zu kopieren gibt. [r] ist die angeklickte Zeile
  /// der Stack- bzw. Eingabespalte. Werte für ein deutsches Excel wie in der Konsole, der tiefste zuerst; Zeilen
  /// als Text, die älteste zuerst.
  String? kopierText(Kopie art, [int r = 0]) {
    switch (art) {
      case Kopie.wert || Kopie.stackAb || Kopie.stack:
        var p = stackPosition(r);
        final neu = _tokenAbschliessen(); // das offene Token ist jetzt x, alle anderen rücken eine tiefer
        if (art == Kopie.stack) {
          p = 0;
        } else if (neu || p < 0) {
          p++;
        }
        final z = api.zustand(zeilen: zustand.tiefe);
        if (z.stack.isEmpty || p >= z.stack.length) return null;
        // ab hier: vom angeklickten Wert bis x wie in der Eingabe bis zur aktuellen Zeile; der tiefste zuerst
        final auswahl = switch (art) { Kopie.wert => [z.stack[p]], Kopie.stackAb => z.stack.take(p + 1), _ => z.stack };
        final werte = [for (final s in auswahl) s.wert].reversed;
        return fuerExcel(werte);
      case Kopie.zeile || Kopie.zeilenAb || Kopie.verlauf:
        // Index im Verlauf, -1 ist die aktuelle Zeile (oben in der Spalte, auch beim Blättern)
        final i = art == Kopie.verlauf ? verlauf.length - 1 : r == 0 ? -1 : verlaufVersatz + r - 1;
        final zeilen = [
          if (art == Kopie.zeile) (i < 0 ? zeile : i < verlauf.length ? verlauf[i].text : "")
          else ...[for (var k = i.clamp(-1, verlauf.length - 1); k >= 0; k--) verlauf[k].text, zeile],
        ].where((t) => t.isNotEmpty);
        return zeilen.isEmpty ? null : zeilen.join("\n");
    }
  }

  /// Die Zeile, zu der gerade ein Kontextmenü offen ist; die Anzeige hebt sie hervor (doc/app.md 2.1).
  ({bool stack, int zeile})? kontext;

  void markiereKontext(({bool stack, int zeile})? k) {
    kontext = k;
    notifyListeners();
  }

  /// Ob es an dieser Stelle etwas zu kopieren gibt, ohne etwas zu verändern; sonst ist der Eintrag im
  /// Kontextmenü ausgegraut.
  bool kannKopieren(Kopie art, [int r = 0]) => switch (art) {
        Kopie.stack => zustand.tiefe > 0 || zustand.offen.isNotEmpty,
        Kopie.wert || Kopie.stackAb => stackPosition(r) < zustand.tiefe && (stackPosition(r) >= 0 || offenesToken != null),
        Kopie.verlauf => verlauf.isNotEmpty || zeile.isNotEmpty,
        Kopie.zeile || Kopie.zeilenAb => eingabeText(r).isNotEmpty,
      };

  /// Kopiert in die Zwischenablage und meldet, was kopiert wurde.
  Future<void> kopiere(Kopie art, [int r = 0]) async {
    final text = kopierText(art, r);
    notifyListeners(); // ein offenes Token ist jetzt abgeschlossen
    if (text == null) return _melde("An dieser Stelle gibt es nichts zu kopieren");
    await Clipboard.setData(ClipboardData(text: text));
    // ein Wert bzw. eine Zeile zeigt sich selbst, mehrere ihre Anzahl
    final werte = art == Kopie.wert || art == Kopie.stackAb || art == Kopie.stack;
    final teile = text.split(werte ? ";" : "\n");
    if (teile.length > 1) return _melde("${teile.length} ${werte ? "Werte" : "Zeilen"} kopiert");
    _melde("Kopiert: ${text.length > 40 ? "${text.substring(0, 39)}…" : text}");
  }

  /// Fügt aus der Zwischenablage ein: als [werte] alle Zahlen darin (wie `\v`, die letzte wird x), sonst den
  /// Text Zeichen für Zeichen, als wäre er getippt. Mit [nachMenue] wartet es im Browser, bis das Kontextmenü
  /// zu ist: Firefox fragt beim Lesen nach, und das Schließen des Menüs würde die Rückfrage verdrängen (BA-4).
  Future<void> fuegeEin({required bool werte, bool nachMenue = false}) async {
    if (zustand.fehler != null) return _melde("Erst den Fehler beheben (⌫)");
    if (nachMenue && kIsWeb) await Future<void>.delayed(const Duration(milliseconds: 400));
    String? text;
    try {
      text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    } on PlatformException {
      text = null; // der Browser hat das Lesen abgelehnt, z.B. die Rückfrage nicht bestätigt
    }
    if (text == null) return _melde("Die Zwischenablage lässt sich nicht lesen");
    if (werte) {
      final zahlen = ausExcel(text);
      if (zahlen.isEmpty) return _melde("Keine Zahlen in der Zwischenablage");
      _tokenAbschliessen();
      _schreibe("${zahlen.join("_")}_"); // das letzte _ schließt auch die letzte Zahl ab
      _melde(zahlen.length == 1 ? "1 Zahl eingefügt" : "${zahlen.length} Zahlen eingefügt");
    } else if (nurZahlen(text)) {
      // nur Zahlen, z.B. aus dem Stack oder aus Excel: so, wie man sie tippen würde (VA-12)
      _schreibe(ausExcel(text).join(" "));
    } else {
      _schreibe(text.replaceAll("\r", ""));
    }
    notifyListeners();
  }

  /// `\` und das Zeichen danach: `\c` kopiert x, `\s` den Stack, `\v` fügt Werte ein; sonst gehen beide an den
  /// Rechner. Liefert, ob das Zeichen damit erledigt ist.
  @override
  bool _rueckstrichBefehl(String c) {
    if (rueckstrich) {
      rueckstrich = false;
      switch (c) {
        case "c":
          kopiere(Kopie.wert);
          return true;
        case "s":
          kopiere(Kopie.stack);
          return true;
        case "v":
          fuegeEin(werte: true);
          return true;
      }
      _schreibe("\\");
      return false;
    }
    if (c != "\\") return false;
    rueckstrich = true;
    return true;
  }
}
