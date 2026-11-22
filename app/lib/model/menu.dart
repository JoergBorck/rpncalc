/// Aufgabe: das Menü auf dem Tastenfeld (doc/app.md 3.6): Öffnen und Abbrechen mit MENÜ, das Hauptmenü auf dem
/// Ziffernblock, der Bereich Bibliotheken mit den Schaltern und der Bereich Modi mit den Auswahlfeldern auf den
/// Funktionstasten, die Rahmen der Tasten, der Satz, was OK bewirkt, und das Übernehmen. Der Bedienmodus
/// [_MenueModus] bekommt alle Bedienungen, solange das Menü offen ist.
///
/// Abgrenzung: Laden und Entladen und die Seiten der Funktionstasten danach stehen in assignment.dart
/// (uebernimmAuswahl); gezeichnet werden Menü und Menüseite in keypad/ und display/menu_page.dart. Das allgemeine
/// Menü-Modell im Kern (Backlog RG-5) kommt später; bis dahin steht der Menübaum als Daten in menu_tree.dart.
///
/// Siehe auch: doc/app.md 3.6, process/requirements/FA-30.md, FA-32.md und FA-6.md, modes.dart.
part of 'model.dart';

/// Erklärung je Winkelmodus für die Zeile unter der Karte der Menüseite.
const Map<String, String> _winkelErklaerung = {
  "Deg": "Grad, 90° = ein rechter Winkel",
  "Rad": "Bogenmaß, 90° = π/2",
  "Grd": "Gon, 90° = 100 gon",
};

/// Das Menü.
mixin _Menue on ModellKern, _Belegung, _Ablage {

  /// Wo im Menü man ist, null: zu.
  MenueBereich? menueBereich;

  @override
  bool get menueOffen => menueBereich != null;

  /// Im Bereich Bibliotheken: die eingeschalteten Einträge, wie sie ENTER übernehmen würde.
  Set<String> menueAuswahl = {};

  /// Im Bereich Modi: der gewählte Wert je Modus (Index in [ModusFeld.werte]), wie ihn OK übernehmen würde.
  Map<String, int> menueWerte = {};

  /// Im Bereich Modi: die Werte beim Öffnen, also die eingestellten.
  Map<String, int> _werteVorher = {};

  /// Im Bereich Modi: die Stellen für Fix, Sci, Eng und SI, wie OK sie übernehmen würde, und die beim Öffnen.
  int menueStellen = Anzeigeformat.standard.stellen;
  int _stellenVorher = Anzeigeformat.standard.stellen;

  /// Der zuletzt gedrückte Schalter bzw. Modus; die Menüseite beschreibt ihn.
  String? menueGewaehlt;

  /// Die Seite der Funktionstasten vor dem Menü; Abbrechen kehrt zu ihr zurück.
  int _seiteVorMenue = 0;

  /// Kurzinfo je Bibliothek: bibliotheksInfo lädt sie dafür in einen Probe-Rechner, also nur einmal.
  final Map<String, BibliotheksInfo?> _infos = {};

  @override
  List<Taste?>? get _menueSchalter => switch (menueBereich) {
        MenueBereich.bibliotheken => [for (final e in menueEintraege) Taste(e, aktion: Aktion.menueEintrag)],
        MenueBereich.modi => [for (final f in modusFelder) f == null ? null : Taste(f.name, aktion: Aktion.menueModus)],
        _ => null,
      };

  @override
  void _menueOeffnen() {
    _seiteVorMenue = funktionsSeite;
    menueBereich = MenueBereich.haupt;
    menueAuswahl = {};
    menueWerte = {};
    menueGewaehlt = null;
    shift = alpha = false; // im Menü gibt es keine Buchstaben
    modus = _modusMenue;
  }

  void _menueSchliessen({bool seiteZurueck = true}) {
    if (seiteZurueck) funktionsSeite = _seiteVorMenue;
    menueBereich = null;
    menueGewaehlt = null;
    shift = false;
    modus = _modusRechnen;
  }

  /// Öffnet den Bereich [b] aus dem Hauptmenü.
  void _bereichOeffnen(MenueBereich b) {
    menueBereich = b;
    menueGewaehlt = null;
    funktionsSeite = 0;
    if (b == MenueBereich.bibliotheken) menueAuswahl = eingeschalteteEintraege.toSet(); // was gerade eingeschaltet ist
    if (b == MenueBereich.modi) {
      _werteVorher = _eingestellteWerte;
      menueWerte = {..._werteVorher};
      menueStellen = _stellenVorher = zustand.anzeige.stellen;
    }
  }

  /// Die eingestellten Werte der Modi; was noch nicht wirkt, steht auf seinem ersten Wert.
  Map<String, int> get _eingestellteWerte => {
        for (final f in modusFelder.nonNulls) f.name: 0,
        "Winkel": switch (zustand.winkel) { AngleMode.deg => 0, AngleMode.rad => 1, AngleMode.grad => 2 },
        "Format": zustand.anzeige.format.index,
        "Trenner": zustand.anzeige.trenner.index,
        "Bruch": zustand.anzeige.bruch.index,
      };

  /// Das Anzeigeformat, das OK einstellen würde.
  Anzeigeformat get menueAnzeige => Anzeigeformat(
        format: Zahlformat.values[menueWerte["Format"] ?? 0],
        stellen: menueStellen,
        trenner: Trenner.values[menueWerte["Trenner"] ?? 0],
        bruch: Bruch.values[menueWerte["Bruch"] ?? 0],
      );

  /// Die Beschriftung eines Modus: der Wert, bei Format mit Stellen („Fix 4“).
  String modusBeschriftung(String name) {
    final w = modusWert(name);
    return name == "Format" && w != "Std" ? "$w $menueStellen" : w;
  }

  /// Grundregel „Zahlen im Menü“ (FA-32): steht Format auf Fix, Sci, Eng oder SI und ist Format gewählt, zeigt der
  /// Ziffernblock Ziffern; sie setzen die Stellen.
  bool get menueZiffern => menueBereich == MenueBereich.modi && menueGewaehlt == "Format" && modusWert("Format") != "Std";

  /// Die Stellen, die die Taste [t] im Ziffernblock setzt: 0–9, ê (links neben 0) 12, „.“ (rechts) die größte
  /// Stellenzahl; sonst null.
  int? menueZiffer(Taste t) {
    if (t.aktion != Aktion.schreiben) return null;
    if (RegExp(r"^[0-9]$").hasMatch(t.text)) return int.parse(t.text);
    return switch (t.text) { "ê" => 12, "." => Anzeigeformat.maxStellen, _ => null };
  }

  void _setzeStellen(int n) {
    menueStellen = n.clamp(0, Anzeigeformat.maxStellen);
  }

  void _schalte(String eintrag) {
    if (!menueAuswahl.remove(eintrag)) menueAuswahl.add(eintrag);
    menueGewaehlt = eintrag;
  }

  /// Ein Modus: schaltet zum nächsten Wert, mit Shift zum vorigen, am Ende wieder von vorn. Ein Platzhalter wird nur
  /// gewählt, damit die Menüseite sagt, womit er kommt. Format, das nicht auf Std steht, wählt der erste Druck nur
  /// aus, damit man die Stellen ändern kann, ohne dass das Format wechselt.
  void _schalteModus(String name, {bool rueckwaerts = false}) {
    final f = modusFeld(name);
    if (f == null) return;
    final nurWaehlen = name == "Format" && menueGewaehlt != name && modusWert(name) != "Std";
    menueGewaehlt = name;
    if (!f.aktiv || nurWaehlen) return;
    final n = f.werte.length;
    menueWerte[name] = ((menueWerte[name] ?? 0) + (rueckwaerts ? n - 1 : 1)) % n;
  }

  /// Der gewählte Wert des Modus [name] als Text, z.B. „Rad“.
  String modusWert(String name) {
    final f = modusFeld(name)!;
    return f.werte[(menueWerte[name] ?? 0).clamp(0, f.werte.length - 1)];
  }

  /// Ob der Wert des Modus [name] von dem beim Öffnen abweicht (grün).
  bool modusGeaendert(String name) =>
      (menueWerte[name] ?? 0) != (_werteVorher[name] ?? 0) ||
      (name == "Format" && modusWert("Format") != "Std" && menueStellen != _stellenVorher);

  /// ENTER: im Bereich übernehmen, im Hauptmenü nur schließen.
  void _menueUebernehmen() {
    switch (menueBereich) {
      case MenueBereich.bibliotheken:
        final auswahl = menueAuswahl;
        _menueSchliessen(seiteZurueck: false); // zuerst schließen: danach zählen wieder die Seiten der Funktionen
        final fehler = uebernimmAuswahl(auswahl);
        if (fehler.isNotEmpty) _melde("Nicht geladen: ${fehler.join("; ")}");
      case MenueBereich.modi:
        if (modusGeaendert("Winkel")) api.winkel = [AngleMode.deg, AngleMode.rad, AngleMode.grad][menueWerte["Winkel"]!];
        if (["Format", "Trenner", "Bruch"].any(modusGeaendert)) api.anzeigeformat = menueAnzeige;
        zustand = api.zustand(zeilen: _stackZeilen);
        _menueSchliessen();
      default:
        _menueSchliessen();
    }
  }

  /// Der Rahmen eines Schalters im Bereich Bibliotheken bzw. eines Modus im Bereich Modi (doc/app.md 3.6).
  MenueRahmen menueRahmen(String eintrag) {
    if (menueBereich == MenueBereich.modi) {
      if (!(modusFeld(eintrag)?.aktiv ?? false)) return MenueRahmen.keiner;
      if (eintrag == menueGewaehlt) return MenueRahmen.gewaehlt;
      return modusGeaendert(eintrag) ? MenueRahmen.laden : MenueRahmen.geladen;
    }
    final an = menueAuswahl.contains(eintrag), geladen = eingeschaltet(eintrag);
    if (!an) return geladen ? MenueRahmen.entladen : MenueRahmen.keiner;
    if (eintrag == menueGewaehlt) return MenueRahmen.gewaehlt;
    return geladen ? MenueRahmen.geladen : MenueRahmen.laden;
  }

  /// Kurzinfo zu einem Eintrag; Programm ist eingebaut und hat keine Bibliothek dahinter.
  BibliotheksInfo? menueInfo(String eintrag) => eintrag == _Belegung.programm
      ? (
          beschreibung: "Programmieren: X führt einen Block aus, dazu if, ifel, loop und times.",
          version: "eingebaut",
          funktionen: domaenen[_Belegung.programm]!.whereType<Taste>().length,
          taste: null,
          symbol: const [],
        )
      : _infos.putIfAbsent(eintrag, () => api.bibliotheksInfo(eintrag));

  /// Was OK (ENTER) im Bereich insgesamt bewirkt, als Satz für die Menüseite.
  String get menueWirkung {
    if (menueBereich == MenueBereich.modi) {
      final namen = _geaenderteModi;
      return namen.isEmpty ? "OK ändert nichts." : "OK ändert ${_aufzaehlung(namen)}.";
    }
    final teile = _menueAenderungen;
    return teile.isEmpty ? "OK ändert nichts." : "OK ${teile.join(", ")}.";
  }

  /// Ob OK im Bereich etwas ändern würde; dann liegt ein dünner oranger Rahmen um OK (doc/app.md 3.6).
  bool get menueAendert => switch (menueBereich) {
        MenueBereich.bibliotheken => _menueAenderungen.isNotEmpty,
        MenueBereich.modi => _geaenderteModi.isNotEmpty,
        _ => false,
      };

  /// Die Modi, deren Wert OK ändern würde, in der Reihenfolge der Tasten.
  List<String> get _geaenderteModi => [for (final f in modusFelder.nonNulls) if (modusGeaendert(f.name)) f.name];

  /// Die Teile des Satzes, was OK bewirkt: lädt …, entlädt …, schaltet Programm ein bzw. aus.
  List<String> get _menueAenderungen {
    final eintraege = menueEintraege;
    bool an(String e) => menueAuswahl.contains(e);
    final laden = [for (final e in eintraege) if (e != _Belegung.programm && an(e) && !eingeschaltet(e)) e];
    final entladen = [for (final e in eintraege) if (e != _Belegung.programm && !an(e) && eingeschaltet(e)) e];
    final programm = an(_Belegung.programm) == programmAn ? null : (an(_Belegung.programm) ? "ein" : "aus");
    return [
      if (laden.isNotEmpty) "lädt ${_aufzaehlung(laden)}",
      if (entladen.isNotEmpty) "entlädt ${_aufzaehlung(entladen)}",
      if (programm != null) "schaltet Programm $programm",
    ];
  }

  static String _aufzaehlung(List<String> namen) =>
      namen.length == 1 ? namen.single : "${namen.sublist(0, namen.length - 1).join(", ")} und ${namen.last}";

  /// Im Bereich Modi die Zeile zum gedrückten Modus: „Winkel Rad · Bogenmaß, 90° = π/2“; ein Platzhalter sagt, womit
  /// er kommt. Ohne gedrückten Modus null.
  ({String wert, String erklaerung})? get modusZeile {
    final name = menueGewaehlt;
    final f = name == null || menueBereich != MenueBereich.modi ? null : modusFeld(name);
    if (f == null) return null;
    if (!f.aktiv) return (wert: f.name, erklaerung: "kommt mit ${f.spaeter}");
    final wert = modusWert(f.name);
    // Format, Trenner, Bruch: eine Beispielzahl im neuen Format, mit allem, was OK einstellen würde
    String beispiel(num w) {
      final r = api.formatiere(w, menueAnzeige);
      return "$w → ${r.text}";
    }
    return (
      wert: "${f.name} ${modusBeschriftung(f.name)}",
      erklaerung: switch (f.name) {
        "Winkel" => _winkelErklaerung[wert] ?? "",
        "Format" || "Trenner" => beispiel(1234.56789),
        "Bruch" => beispiel(1.375),
        _ => "",
      },
    );
  }

  /// Der Pfad für den Kopf der Menüseite: MENÜ › Bibliotheken › statistik, MENÜ › Modi › Winkel.
  String get menuePfad => [
        "MENÜ",
        for (final p in menueHauptpunkte) if (p.bereich == menueBereich) p.name,
        if (menueBereich != MenueBereich.haupt && menueGewaehlt != null) menueGewaehlt!,
      ].join(" › ");

  /// Ob eine Taste im Menü etwas tut (sonst ist sie leer): MENÜ, SHIFT, ENTER, die Bereiche des Hauptmenüs, in den
  /// Bereichen die Schalter bzw. Modi (doc/app.md 3.6).
  bool wirktImMenue(Taste t) =>
      const {Aktion.menue, Aktion.shift, Aktion.enter, Aktion.menueEintrag, Aktion.menueModus}.contains(t.aktion) ||
      (t.aktion == Aktion.schreiben && menuePunktAuf(t.text) != null) ||
      (menueZiffern && menueZiffer(t) != null);

  /// In einem Bereich ist seine Taste orange umrandet wie MENÜ: der Pfad (doc/app.md 3.6).
  bool imMenuePfad(Taste t) =>
      t.aktion == Aktion.schreiben && menueBereich != MenueBereich.haupt && menuePunktAuf(t.text)?.bereich == menueBereich;

  /// Die Hilfe zu einer Taste im Menü (Hilfe-Modus): eine Bibliothek zeigt ihre Übersicht, ein Modus seine Hilfe,
  /// ein Bereich seine Hilfe, OK (ENTER) `menue:ok`, leere Tasten die zum Hauptmenü; null für MENÜ und SHIFT, die
  /// ihre eigene Hilfe haben.
  @override
  String? menueHilfe(Taste t) {
    if (t.aktion == Aktion.menueEintrag) return t.text == _Belegung.programm ? "menue:programm" : "#${t.text}";
    if (t.aktion == Aktion.menueModus) return "menue:modus:${t.text.toLowerCase().replaceAll("ö", "oe")}";
    if (menueZiffern && menueZiffer(t) != null) return "menue:modus:format";
    final punkt = t.aktion == Aktion.schreiben ? menuePunktAuf(t.text) : null;
    if (punkt != null) return punkt.hilfe;
    if (t.aktion == Aktion.enter) return "menue:ok";
    if (const {Aktion.menue, Aktion.shift}.contains(t.aktion)) return null;
    return "menue:hauptmenue";
  }
}

/// Menü: nur MENÜ, SHIFT, ENTER (heißt hier OK), die Bereiche, die Schalter und die Modi wirken; alles andere tut
/// nichts (doc/app.md 3.6).
class _MenueModus extends Bedienmodus {
  final RechnerModell m;
  _MenueModus(this.m);

  @override
  void druecke(Taste t) {
    _taste(t);
    m._geaendert();
  }

  void _taste(Taste t) {
    switch (t.aktion) {
      case Aktion.shift:
        m.shift = !m.shift;
        return;
      case Aktion.menue:
        // Shift+MENÜ: Hilfe, auch im Menü; MENÜ allein bricht ab
        if (m.shift) {
          m._hilfeStarten();
          return;
        }
        m._menueSchliessen();
      case Aktion.enter:
        m._menueUebernehmen();
      case Aktion.menueEintrag when m.menueBereich == MenueBereich.bibliotheken:
        m._schalte(t.text);
      case Aktion.menueModus when m.menueBereich == MenueBereich.modi:
        m._schalteModus(t.text, rueckwaerts: m.shift);
      case Aktion.schreiben when m.menueZiffern && m.menueZiffer(t) != null:
        m._setzeStellen(m.menueZiffer(t)!); // Ziffern setzen die Stellen, auch 4 und 8 (FA-32)
      case Aktion.schreiben when menuePunktAuf(t.text) != null:
        m._bereichOeffnen(menuePunktAuf(t.text)!.bereich);
      default:
    }
    m.shift = false;
  }

  /// ENTER heißt im Menü OK (doc/app.md 3.6).
  @override
  Beschriftung? beschriftung(Taste t) =>
      t.aktion == Aktion.enter ? (text: "OK", art: Beschriftungsart.normal, gedimmt: false) : null;

  /// Auf der Tastatur öffnen 4 und 8 ihre Bereiche; in einem Bereich drückt der Buchstabe einer Funktionstaste
  /// (f–j, l–p) diese Taste, ein Großbuchstabe wie mit Shift. Andere Zeichen tun nichts.
  @override
  void tippeZeichen(String c) {
    // steht der Ziffernblock auf Ziffern, setzen getippte Ziffern die Stellen (FA-32)
    if (m.menueZiffern && RegExp(r"^[0-9]$").hasMatch(c)) {
      m._setzeStellen(int.parse(c));
      m._geaendert();
      return;
    }
    final punkt = menuePunktAuf(c);
    final platz = funktionsBuchstaben.indexOf(c.toLowerCase());
    final taste = m.menueBereich == MenueBereich.haupt || platz < 0 ? null : m.funktionstasten[platz];
    if (punkt != null) {
      m._bereichOeffnen(punkt.bereich);
    } else if (taste != null) {
      m.shift = c != c.toLowerCase();
      _taste(taste);
    } else {
      return;
    }
    m._geaendert();
  }

  /// Return und Enter wie ENTER: übernehmen bzw. schließen.
  @override
  void zeilenende(String text) => druecke(_Tastatur._enter);

  @override
  void pfeil(AxisDirection richtung) {}

  @override
  void tab({bool rueckwaerts = false}) {}

  /// Esc bricht ab wie MENÜ.
  @override
  void esc() {
    m._menueSchliessen();
    m._geaendert();
  }

  @override
  void hilfe() {
    m._hilfeStarten();
    m._geaendert();
  }
}
