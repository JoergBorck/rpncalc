/// Aufgabe: das Menü auf dem Tastenfeld (doc/app.md 3.6): Öffnen und Abbrechen mit MENÜ, das Hauptmenü auf dem
/// Ziffernblock, der Bereich Bibliotheken mit den Schaltern auf den Funktionstasten, die Rahmen der Schalter, der
/// Satz, was ENTER bewirkt, und das Übernehmen. Der Bedienmodus [_MenueModus] bekommt alle Bedienungen, solange
/// das Menü offen ist.
///
/// Abgrenzung: Laden und Entladen und die Seiten der Funktionstasten danach stehen in assignment.dart
/// (uebernimmAuswahl); gezeichnet werden Menü und Menüseite in keypad/ und display/menu_page.dart. Das allgemeine
/// Menü-Modell im Kern (Backlog RG-5) kommt erst mit dem nächsten Bereich; bis dahin hält die App den Menübaum
/// hier als Daten ([menueHauptpunkte]).
///
/// Siehe auch: doc/app.md 3.6, process/requirements/FA-30.md und FA-6.md, modes.dart.
part of 'model.dart';

/// Wo im Menü man ist; null heißt: das Menü ist zu.
enum MenueBereich { haupt, bibliotheken }

/// Wie ein Schalter im Bereich Bibliotheken umrandet ist: was ENTER bewirken wird (doc/app.md 3.6).
enum MenueRahmen {
  /// nicht geladen und bleibt so, auch wenn gewählt
  keiner,
  /// gewählt (zuletzt gedrückt) und geladen bzw. wird geladen: orange, breiter
  gewaehlt,
  /// wird geladen, nicht gewählt: grün
  laden,
  /// wird entladen, auch wenn gewählt: rot mit schrägem Strich
  entladen,
  /// geladen und bleibt, nicht gewählt: weiß
  geladen,
}

/// Ein Bereich des Hauptmenüs: seine Taste im Ziffernblock, Name, Symbol (Asset der App) und Hilfe-Kennung.
typedef MenuePunkt = ({String taste, String name, String symbol, String hilfe});

/// Die Bereiche des Hauptmenüs; bisher nur die Bibliotheken auf 4 (FA-30). Die übrigen Tasten bleiben leer.
const List<MenuePunkt> menueHauptpunkte = [
  (taste: "4", name: "Bibliotheken", symbol: "assets/icons/bibliothek.svg", hilfe: "menue:bibliotheken"),
];

/// Der Bereich des Hauptmenüs auf der Taste [text], sonst null.
MenuePunkt? menuePunktAuf(String text) => menueHauptpunkte.where((p) => p.taste == text).firstOrNull;

/// Das Menü.
mixin _Menue on ModellKern, _Belegung, _Ablage {

  /// Wo im Menü man ist, null: zu.
  MenueBereich? menueBereich;

  @override
  bool get menueOffen => menueBereich != null;

  /// Im Bereich Bibliotheken: die eingeschalteten Einträge, wie sie ENTER übernehmen würde.
  Set<String> menueAuswahl = {};

  /// Der zuletzt gedrückte Schalter; die Menüseite beschreibt ihn.
  String? menueGewaehlt;

  /// Die Seite der Funktionstasten vor dem Menü; Abbrechen kehrt zu ihr zurück.
  int _seiteVorMenue = 0;

  /// Kurzinfo je Bibliothek: bibliotheksInfo lädt sie dafür in einen Probe-Rechner, also nur einmal.
  final Map<String, BibliotheksInfo?> _infos = {};

  @override
  List<Taste>? get _menueSchalter => menueBereich == MenueBereich.bibliotheken
      ? [for (final e in menueEintraege) Taste(e, aktion: Aktion.menueEintrag)]
      : null;

  @override
  void _menueOeffnen() {
    _seiteVorMenue = funktionsSeite;
    menueBereich = MenueBereich.haupt;
    menueAuswahl = {};
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

  void _bibliothekenOeffnen() {
    menueBereich = MenueBereich.bibliotheken;
    menueAuswahl = eingeschalteteEintraege.toSet(); // Voreinstellung: was gerade eingeschaltet ist
    menueGewaehlt = null;
    funktionsSeite = 0;
  }

  void _schalte(String eintrag) {
    if (!menueAuswahl.remove(eintrag)) menueAuswahl.add(eintrag);
    menueGewaehlt = eintrag;
  }

  /// ENTER: im Bereich Bibliotheken übernehmen, im Hauptmenü nur schließen.
  void _menueUebernehmen() {
    if (menueBereich != MenueBereich.bibliotheken) return _menueSchliessen();
    final auswahl = menueAuswahl;
    _menueSchliessen(seiteZurueck: false); // zuerst schließen: danach zählen wieder die Seiten der Funktionen
    final fehler = uebernimmAuswahl(auswahl);
    if (fehler.isNotEmpty) _melde("Nicht geladen: ${fehler.join("; ")}");
  }

  /// Der Rahmen eines Schalters im Bereich Bibliotheken (doc/app.md 3.6).
  MenueRahmen menueRahmen(String eintrag) {
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

  /// Was OK (ENTER) im Bereich Bibliotheken insgesamt bewirkt, als Satz für die Menüseite.
  String get menueWirkung {
    final teile = _menueAenderungen;
    return teile.isEmpty ? "OK ändert nichts." : "OK ${teile.join(", ")}.";
  }

  /// Ob OK im Bereich Bibliotheken etwas ändern würde; dann liegt ein dünner oranger Rahmen um OK (doc/app.md 3.6).
  bool get menueAendert => menueBereich == MenueBereich.bibliotheken && _menueAenderungen.isNotEmpty;

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

  /// Der Pfad für den Kopf der Menüseite: MENÜ › Bibliotheken › statistik.
  String get menuePfad => [
        "MENÜ",
        if (menueBereich == MenueBereich.bibliotheken) "Bibliotheken",
        if (menueBereich == MenueBereich.bibliotheken && menueGewaehlt != null) menueGewaehlt!,
      ].join(" › ");

  /// Ob eine Taste im Menü etwas tut (sonst ist sie leer): MENÜ, SHIFT, ENTER, die Bereiche des Hauptmenüs, im
  /// Bereich Bibliotheken die Schalter (doc/app.md 3.6).
  bool wirktImMenue(Taste t) =>
      const {Aktion.menue, Aktion.shift, Aktion.enter, Aktion.menueEintrag}.contains(t.aktion) ||
      (t.aktion == Aktion.schreiben && menuePunktAuf(t.text) != null);

  /// Im Bereich Bibliotheken ist die Taste des Bereichs orange umrandet wie MENÜ: der Pfad (doc/app.md 3.6).
  bool imMenuePfad(Taste t) =>
      menueBereich == MenueBereich.bibliotheken && t.aktion == Aktion.schreiben && menuePunktAuf(t.text)?.name == "Bibliotheken";

  /// Die Hilfe zu einer Taste im Menü (Hilfe-Modus): eine Bibliothek zeigt ihre Übersicht, ein Bereich seine
  /// Hilfe, OK (ENTER) `menue:ok`, leere Tasten die zum Hauptmenü; null für MENÜ und SHIFT, die ihre eigene Hilfe
  /// haben.
  @override
  String? menueHilfe(Taste t) {
    if (t.aktion == Aktion.menueEintrag) return t.text == _Belegung.programm ? "menue:programm" : "#${t.text}";
    final punkt = t.aktion == Aktion.schreiben ? menuePunktAuf(t.text) : null;
    if (punkt != null) return punkt.hilfe;
    if (t.aktion == Aktion.enter) return "menue:ok";
    if (const {Aktion.menue, Aktion.shift}.contains(t.aktion)) return null;
    return "menue:hauptmenue";
  }
}

/// Menü: nur MENÜ, SHIFT, ENTER (heißt hier OK), die Bereiche und die Schalter wirken; alles andere tut nichts (doc/app.md 3.6).
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
      case Aktion.schreiben when menuePunktAuf(t.text) != null:
        m._bibliothekenOeffnen();
      default:
    }
    m.shift = false;
  }

  /// ENTER heißt im Menü OK (doc/app.md 3.6).
  @override
  Beschriftung? beschriftung(Taste t) =>
      t.aktion == Aktion.enter ? (text: "OK", art: Beschriftungsart.normal, gedimmt: false) : null;

  /// Auf der Tastatur öffnet 4 die Bibliotheken; andere Zeichen tun nichts.
  @override
  void tippeZeichen(String c) {
    if (menuePunktAuf(c) != null) {
      m._bibliothekenOeffnen();
      m._geaendert();
    }
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
