/// Aufgabe: Belegung und Beschriftung der Tasten: welche Funktionen die zehn Funktionstasten gerade zeigen
/// (Grundfunktionen, gewählte Domäne oder Bibliothek, eigene Funktionen, nach ' die Variablen), Seiten und Blättern
/// (Wischen, Mausrad, Cursorkreuz), die Wahl der Domäne und wie jede Taste in den aktuellen Umschaltungen
/// beschriftet ist.
///
/// Abgrenzung: Die festen Tasten und die eingebauten Domänen stehen in keys.dart; die Funktionen einer Bibliothek
/// liefert der Rechner. Was ein Druck bewirkt, steht in input.dart.
///
/// Siehe auch: doc/app.md 3.3 und 3.4, keys.dart.
part of 'model.dart';

/// Belegung der Funktionstasten und Beschriftung.
mixin _Belegung on ModellKern {
  String domaene = "Grundfunktionen";
  int funktionsSeite = 0;   // Seite der Funktionstasten: Grundfunktionen, gewählte Domäne, eigene Funktionen

  /// Die Belegung der zehn Funktionstasten für den gewählten Bereich bzw. nach `'`.
  @override
  List<Taste?> get funktionstasten => funktionstastenAuf(_seite);

  /// Die Belegung der Seite [seite] (im Kreis gezählt), z.B. für die Nachbarseite beim Schieben (VA-10); nach `'`
  /// und im Bereich Variablen immer die Variablen.
  List<Taste?> funktionstastenAuf(int seite) {
    if (apostroph || bereich == Bereich.variablen) return _seiten(_variablen);
    final n = funktionsSeiten, s = (seite % n + n) % n;
    final d = [..._grundSeiten, ..._domaenenSeiten];
    if (s < d.length) return d[s];
    return _seiten(_eigene, s - d.length);
  }

  /// Name der Seite, die die Funktionstasten zeigen.
  String get seitenName {
    if (apostroph || bereich == Bereich.variablen) return "Variablen";
    final g = _grundSeiten.length, d = _domaenenSeiten.length;
    if (_seite < g) return _grund;
    if (_seite < g + d) return d > 1 ? "$domaene ${_seite - g + 1}/$d" : domaene;
    final e = _seite - g - d + 1;
    return "Eigene${e > 1 ? " $e" : ""}";
  }

  /// Die Bibliothek, deren Seite die Funktionstasten gerade zeigen, sonst null (Grundfunktionen, eingebaute
  /// Domäne, Eigene). Die Seite Funktionen der Anzeige scrollt zu ihrem Abschnitt (doc/app.md 2).
  String? get seitenBibliothek {
    final g = _grundSeiten.length;
    final aufDomaene = _seite >= g && _seite < g + _domaenenSeiten.length;
    return aufDomaene && !domaenen.containsKey(domaene) ? domaene : null;
  }

  /// Wohin die Seite Funktionen scrollt: auf der ersten Seite einer Bibliothek ihr Abschnitt, auf weiteren
  /// Seiten deren erste Funktion, damit die Funktionen der Tasten zu sehen sind; sonst null (nach oben).
  ({String bibliothek, String? funktion})? get seitenZiel {
    final b = seitenBibliothek;
    if (b == null) return null;
    final erste = _seite - _grundSeiten.length == 0 ? null : funktionstasten.first?.text;
    return (bibliothek: b, funktion: erste);
  }

  /// Die Grundfunktionen stehen immer vorn, auch wenn eine andere Domäne gewählt ist (doc/app.md 3.3).
  static const _grund = "Grundfunktionen";
  List<List<Taste?>> get _grundSeiten => domaene == _grund ? const [] : [domaenen[_grund]!];

  /// Ohne eigene Funktionen gibt es keine Seite „Eigene“, sonst wäre sie leer.
  int get _eigeneSeiten => (_eigene.length / 10).ceil();

  /// Die gezeigte Seite; eine Seite „Eigene“, deren Funktionen inzwischen entfernt sind, gibt es nicht mehr.
  int get _seite => funktionsSeite.clamp(0, funktionsSeiten - 1);

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
      // interne Funktionen (rpnintern) bekommen keine Taste (doc/app.md 3.4)
      final tasten = [for (final f in api.bibliotheksFunktionen(domaene, ohneIntern: true)) Taste(f, name: true)];
      return [for (int s = 0; s * 10 < tasten.length || s == 0; s++) _seiten(tasten, s)];
    });
  }

  List<Taste> get _variablen => [
        for (Speicher s in zustand.speicher)
          if (s.art != SpeicherArt.funktion) Taste(s.name, eingabe: apostroph ? s.name : "'${s.name}", name: true),
      ];

  /// Eigene Funktionen ohne die aus Bibliotheken (die stehen auf den Seiten ihrer Domäne) und ohne interne.
  List<Taste> get _eigene => [
        for (Speicher s in zustand.speicher)
          if (s.art == SpeicherArt.funktion && !s.intern && !api.geladeneBibliotheksFunktionen.contains(s.name))
            Taste(s.name, name: true),
      ];

  static List<Taste?> _seiten(List<Taste> alle, [int seite = 0]) =>
      [for (int i = 0; i < 10; i++) seite * 10 + i < alle.length ? alle[seite * 10 + i] : null];

  /// Beschriftung einer Taste in den aktuellen Umschaltungen.
  Beschriftung beschriftung(Taste t) {
    // der Bedienmodus kann eine eigene Beschriftung haben, z.B. die Hilfe für MENÜ, ALPHA und ⌫
    final eigene = modus.beschriftung(t);
    if (eigene != null) return eigene;
    if (alpha && t.buchstabe != null) return (text: gross ? t.buchstabe!.toUpperCase() : t.buchstabe!, art: Beschriftungsart.alpha, gedimmt: false);
    if (alpha && t.aktion == Aktion.enter) return (text: "⏎", art: Beschriftungsart.alpha, gedimmt: false);
    // ~ wirkt auch auf die Shift-Funktion: ~ ⇧ ÷ ist ≤ (geschrieben ~>)
    if (shiftWirkt && tilde && t.shiftTilde != null) return (text: t.shiftTilde!, art: Beschriftungsart.tilde, gedimmt: false);
    if (shiftWirkt && t.shift != null) return (text: t.shift!, art: Beschriftungsart.shift, gedimmt: false);
    // Tasten ohne Wirkung des Präfixes bleiben normal: vor ihnen wirkt der Präfix allein (doc/app.md 3.2)
    if (tilde && strich) return t.beide != null ? (text: t.beide!, art: Beschriftungsart.tilde, gedimmt: false) : _normal(t);
    if (tilde) return t.tilde != null ? (text: t.tilde!, art: Beschriftungsart.tilde, gedimmt: false) : _normal(t);
    if (strich) return t.strich != null ? (text: t.strich!, art: Beschriftungsart.strich, gedimmt: false) : _normal(t);
    return shiftWirkt ? _gedimmt(t) : _normal(t);
  }

  static Beschriftung _normal(Taste t) => (text: t.text, art: Beschriftungsart.normal, gedimmt: false);
  static Beschriftung _gedimmt(Taste t) => (text: t.text, art: Beschriftungsart.normal, gedimmt: true);

  /// Zahl der Seiten der Funktionstasten: die Domäne und die eigenen Funktionen.
  int get funktionsSeiten => _grundSeiten.length + _domaenenSeiten.length + _eigeneSeiten;

  /// Blättert um [schritt] Seiten im Kreis (◄ ► im Bereich Funktionen) oder [begrenzt] auf die erste und letzte
  /// Seite (▲ ▼, wie das Mausrad).
  @override
  void _blaettere(int schritt, {bool begrenzt = false}) {
    final n = funktionsSeiten;
    funktionsSeite = begrenzt ? (_seite + schritt).clamp(0, n - 1) : (_seite + schritt + n) % n;
  }

  /// Nach Wischen oder Mausrad zeigt das Tastenfeld kurz den Rahmen um die Funktionstasten, ohne den Bereich zu
  /// wählen: die Anzeige bleibt, wo sie ist (doc/app.md 3.3).
  bool funktionenHinweis = false;
  Timer? _hinweisUhr;

  void _zeigeHinweis() {
    funktionenHinweis = true;
    _hinweisUhr?.cancel();
    _hinweisUhr = Timer(const Duration(milliseconds: 1500), () {
      funktionenHinweis = false;
      notifyListeners();
    });
  }

  /// Ob Wischen und Mausrad die Seiten der Funktionstasten blättern: nicht, solange die Tasten etwas anderes zeigen
  /// (Variablen nach ' oder im Bereich Variablen, Buchstaben im Alpha-Modus). Im Hilfe-Modus blättern sie auch
  /// (doc/app.md 5.2).
  bool get funktionenBlaetterbar => !(alpha || apostroph || bereich == Bereich.variablen);

  /// Die Kennung der Hilfe zur gezeigten Seite der Funktionstasten: eine Bibliothek, die eigenen Funktionen oder
  /// die übrigen Seiten (doc/app.md 5.2).
  @override
  String get seitenHilfe {
    final b = seitenBibliothek;
    if (b != null) return "#$b";
    if (seitenName == "Variablen") return "app:variablen";
    // „#funktionen“ ist beim Rechner das Thema „Eigene Funktionen“; zu den übrigen Seiten erklärt die App die Anzeige
    return seitenName.startsWith("Eigene") ? "#funktionen" : "app:funktionen";
  }

  /// Die Maus steht über den Funktionstasten (am PC); der Block wird dann leicht orange (doc/app.md 3.3).
  bool mausUeberFunktionen = false;

  void mausFunktionen(bool darueber) {
    if (mausUeberFunktionen == darueber) return;
    mausUeberFunktionen = darueber;
    notifyListeners();
  }

  /// Wischen und Mausrad über den Funktionstasten (keypad/function_block.dart) zeigen die Seite [seite], im Kreis
  /// gezählt; dazu kurz der Rahmen (doc/app.md 3.3). Nur, wenn die Tasten blättern.
  void zeigeFunktionsSeite(int seite) {
    if (!funktionenBlaetterbar) return;
    final n = funktionsSeiten;
    funktionsSeite = (seite % n + n) % n;
    _zeigeHinweis();
    notifyListeners();
  }

  /// Wählt die Domäne der Funktionstasten; eine Bibliothek wird dabei einmal geladen.
  void waehleDomaene(String name) {
    domaene = name;
    funktionsSeite = _grundSeiten.length; // die erste Seite der Domäne, davor stehen die Grundfunktionen
    if (!domaenen.containsKey(name) && api.bibliotheksVersion(name) == null) {
      api.ladeBibliothek(name);
      zustand = api.zustand(zeilen: _stackZeilen);
    }
    notifyListeners();
  }
}
