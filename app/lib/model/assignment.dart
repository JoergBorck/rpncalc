/// Aufgabe: Belegung und Beschriftung der Tasten: welche Funktionen die zehn Funktionstasten gerade zeigen
/// (Grundfunktionen, die eingeschalteten Bibliotheken und Programm, eigene Funktionen, nach ' die Variablen, im
/// Menü die Bibliotheken als Schalter), Seiten und Blättern (Wischen, Mausrad, Cursorkreuz), das Übernehmen der
/// Auswahl aus dem Menü und wie jede Taste in den aktuellen Umschaltungen beschriftet ist.
///
/// Abgrenzung: Die festen Tasten und die eingebauten Seiten stehen in keys.dart; die Funktionen einer Bibliothek
/// liefert der Rechner. Was ein Druck bewirkt, steht in input.dart, das Menü selbst in menu.dart.
///
/// Siehe auch: doc/app.md 3.3, 3.4 und 3.6, keys.dart.
part of 'model.dart';

/// Eine Seite der Funktionstasten: Name (unten am Rahmen), die Bibliothek, zu der sie gehört, ihr Platz unter den
/// Seiten dieser Bibliothek (0 = erste) und die zehn Tasten.
typedef _Seite = ({String name, String? bibliothek, int teil, List<Taste?> tasten});

/// Belegung der Funktionstasten und Beschriftung.
mixin _Belegung on ModellKern {
  int funktionsSeite = 0;   // Seite der Funktionstasten: Grundfunktionen, Einträge des Menüs, eigene Funktionen

  /// Programm ist ein eingebauter Eintrag im Bereich Bibliotheken des Menüs; beim Start aus (doc/app.md 3.4).
  bool programmAn = false;

  static const programm = "Programm";

  /// Die Einträge im Bereich Bibliotheken des Menüs in ihrer Reihenfolge: mitgelieferte Bibliotheken nach Namen,
  /// hinzugefügte nach Namen, zuletzt Programm (doc/app.md 3.6). In dieser Reihenfolge stehen auch ihre Seiten.
  List<String> get menueEintraege => [for (final b in api.bibliotheken()) b.name, programm];

  /// Ein Eintrag ist eingeschaltet: Programm, wenn es an ist, eine Bibliothek, wenn sie geladen ist.
  bool eingeschaltet(String eintrag) => eintrag == programm ? programmAn : api.bibliotheksVersion(eintrag) != null;

  /// Die eingeschalteten Einträge in der Reihenfolge des Menüs.
  List<String> get eingeschalteteEintraege => [for (final e in menueEintraege) if (eingeschaltet(e)) e];

  /// Die Belegung der zehn Funktionstasten für den gewählten Bereich bzw. nach `'`.
  @override
  List<Taste?> get funktionstasten => funktionstastenAuf(_seite);

  /// Die Belegung der Seite [seite] (im Kreis gezählt), z.B. für die Nachbarseite beim Schieben (VA-10); nach `'`
  /// und im Bereich Variablen immer die Variablen.
  List<Taste?> funktionstastenAuf(int seite) {
    if (variablenAufTasten) return _seiten(_variablen);
    final liste = _seitenListe, n = liste.length;
    return liste[(seite % n + n) % n].tasten;
  }

  /// Name der Seite, die die Funktionstasten zeigen.
  String get seitenName => variablenAufTasten ? "Variablen" : _seitenListe[_seite].name;

  /// Die Bibliothek, deren Seite die Funktionstasten gerade zeigen, sonst null (Grundfunktionen, Programm,
  /// Eigene). Die Seite Funktionen der Anzeige scrollt zu ihrem Abschnitt (doc/app.md 2).
  String? get seitenBibliothek => variablenAufTasten ? null : _seitenListe[_seite].bibliothek;

  /// Wohin die Seite Funktionen scrollt: auf der ersten Seite einer Bibliothek ihr Abschnitt, auf weiteren
  /// Seiten deren erste Funktion, damit die Funktionen der Tasten zu sehen sind; sonst null (nach oben).
  ({String bibliothek, String? funktion})? get seitenZiel {
    if (variablenAufTasten) return null;
    final s = _seitenListe[_seite];
    if (s.bibliothek == null) return null;
    return (bibliothek: s.bibliothek!, funktion: s.teil == 0 ? null : s.tasten.first?.text);
  }

  /// Alle Seiten der Funktionstasten: die Grundfunktionen (immer vorn, doc/app.md 3.3), die Seiten der
  /// eingeschalteten Einträge in der Reihenfolge des Menüs, die eigenen Funktionen. Im Bereich Bibliotheken des
  /// Menüs stattdessen die Schalter der Bibliotheken.
  List<_Seite> get _seitenListe {
    final schalter = _menueSchalter;
    if (schalter != null) {
      final n = (schalter.length / 10).ceil().clamp(1, 1 << 20);
      return [
        for (int s = 0; s < n; s++)
          (name: n > 1 ? "Bibliotheken ${s + 1}/$n" : "Bibliotheken", bibliothek: null, teil: s, tasten: _seiten(schalter, s)),
      ];
    }
    final eigene = _eigene, e = (eigene.length / 10).ceil();
    return [
      (name: _grund, bibliothek: null, teil: 0, tasten: domaenen[_grund]!),
      for (final eintrag in eingeschalteteEintraege)
        if (eintrag == programm)
          (name: programm, bibliothek: null, teil: 0, tasten: domaenen[programm]!)
        else
          for (final (i, tasten) in _bibliotheksSeitenVon(eintrag).indexed)
            (
              name: _bibliotheksSeitenVon(eintrag).length > 1 ? "$eintrag ${i + 1}/${_bibliotheksSeitenVon(eintrag).length}" : eintrag,
              bibliothek: eintrag,
              teil: i,
              tasten: tasten,
            ),
      // ohne eigene Funktionen gibt es keine Seite „Eigene“, sonst wäre sie leer
      for (int s = 0; s < e; s++) (name: "Eigene${s > 0 ? " ${s + 1}" : ""}", bibliothek: null, teil: s, tasten: _seiten(eigene, s)),
    ];
  }

  /// Im Bereich Bibliotheken des Menüs: je Eintrag eine Taste, die ihn ein- und ausschaltet; sonst null (menu.dart).
  List<Taste>? get _menueSchalter;

  static const _grund = "Grundfunktionen";

  /// Die gezeigte Seite; eine Seite „Eigene“, deren Funktionen inzwischen entfernt sind, gibt es nicht mehr.
  int get _seite => funktionsSeite.clamp(0, funktionsSeiten - 1);

  /// Die Seiten der Funktionstasten je Bibliothek, einmal erzeugt: bibliotheksFunktionen lädt die Bibliothek
  /// dafür in einen Probe-Rechner, und das Aufleuchten erkennt eine Taste an ihrer Identität.
  final Map<String, List<List<Taste?>>> _bibliotheksSeiten = {};

  /// Die Seiten einer Bibliothek: ihre Funktionen in der Reihenfolge der Datei, zehn je Seite.
  List<List<Taste?>> _bibliotheksSeitenVon(String name) => _bibliotheksSeiten.putIfAbsent(name, () {
        // interne Funktionen (rpnintern) bekommen keine Taste (doc/app.md 3.4)
        final tasten = [for (final f in api.bibliotheksFunktionen(name, ohneIntern: true)) Taste(f, name: true)];
        return [for (int s = 0; s * 10 < tasten.length || s == 0; s++) _seiten(tasten, s)];
      });

  /// Ändert sich, wenn sich die Seiten der Funktionstasten ändern (anderer Inhalt, nicht nur eine andere gezeigte
  /// Seite); der Block der Funktionstasten springt dann ohne Bewegung.
  String get belegungsStand => [for (final s in _seitenListe) s.name].join("|");

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

  /// Zahl der Seiten der Funktionstasten.
  int get funktionsSeiten => _seitenListe.length;

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
  /// (doc/app.md 5.2), im Menü nur im Bereich Bibliotheken (doc/app.md 3.6).
  bool get funktionenBlaetterbar => !(alpha || variablenAufTasten) && (!menueOffen || _menueSchalter != null);


  /// Die Funktionstasten zeigen die Variablen: nach ' und im Bereich Variablen, dort aber nur, wenn es welche gibt;
  /// sonst bleiben die Funktionen stehen (VA-15). Im Menü nie.
  bool get variablenAufTasten =>
      !menueOffen && (apostroph || (bereich == Bereich.variablen && _variablen.isNotEmpty));

  /// Der Tastenblock gehört zur Liste der Seite Funktionen bzw. Variablen, wenn er etwas aus ihr zeigen kann:
  /// Variablen bzw. Tags, Funktionen mit Taste (nicht nur interne). Nur dann wird er hinterlegt und lässt sich als
  /// eigener Bereich wählen (VA-15).
  bool get tastenblockVerbunden => switch (bereich) {
        Bereich.variablen => _variablen.isNotEmpty,
        Bereich.funktionen => zustand.speicher.any((s) => s.art == SpeicherArt.funktion && !s.intern),
        _ => false,
      };

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

  /// Übernimmt die Auswahl aus dem Bereich Bibliotheken des Menüs: entlädt die ausgeschalteten Bibliotheken,
  /// lädt die eingeschalteten, schaltet Programm. Danach zeigen die Funktionstasten die erste Seite des ersten neu
  /// eingeschalteten Eintrags, sonst die bisherige Seite, wenn es sie noch gibt, sonst die Grundfunktionen
  /// (doc/app.md 3.6). Liefert die Fehler beim Laden; eine solche Bibliothek bleibt aus.
  List<String> uebernimmAuswahl(Set<String> an) {
    final vorher = eingeschalteteEintraege.toSet();
    final bisher = seitenName;
    final fehler = <String>[];
    // zuerst entladen, damit frei gewordene Namen für die neuen Bibliotheken zur Verfügung stehen
    for (final e in menueEintraege) {
      if (e != programm && !an.contains(e) && eingeschaltet(e)) api.entladeBibliothek(e);
    }
    for (final e in menueEintraege) {
      if (e == programm) {
        programmAn = an.contains(e);
      } else if (an.contains(e) && !eingeschaltet(e)) {
        final f = api.ladeBibliothek(e);
        if (f != null) {
          fehler.add("$e: $f");
          if (eingeschaltet(e)) api.entladeBibliothek(e); // halb geladen: wieder heraus
        }
      }
    }
    zustand = api.zustand(zeilen: _stackZeilen);
    final liste = _seitenListe;
    final neu = eingeschalteteEintraege.where((e) => !vorher.contains(e)).firstOrNull;
    final ziel = neu != null
        ? liste.indexWhere((s) => s.name == neu || s.name.startsWith("$neu 1/"))
        : liste.indexWhere((s) => s.name == bisher);
    funktionsSeite = ziel < 0 ? 0 : ziel;
    return fehler;
  }
}
