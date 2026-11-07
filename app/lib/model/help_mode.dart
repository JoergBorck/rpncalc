/// Aufgabe: der Hilfe-Modus: Inspekt-Modus (jede Taste zeigt ihre Hilfe) und Lese-Modus (Verweise mit TAB wählen,
/// ENTER folgt, ▲ ▼ blättern), die Folge der gezeigten Seiten mit ◄ zurück, der Start mit der Seite des letzten
/// Tooltips.
///
/// Abgrenzung: Die Texte kommen aus help_texts.dart (App) und aus der Hilfe des Rechners; den Hilfeschirm zeichnet
/// display/help_screen.dart. Was Tasten, Zeichen und Pfeile in der Hilfe bewirken, steht im Bedienmodus Hilfe
/// (modes.dart); ob er aktiv ist (hilfeModus) und hilfeLesen stehen im Kern, weil die Anzeige es abfragt.
///
/// Siehe auch: doc/app.md 5.2, help_texts.dart.
part of 'model.dart';

/// Hilfe-Modus.
mixin _HilfeModus on ModellKern {
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

  /// „Hilfe“ im Kontextmenü der Anzeige: öffnet die Hilfe im Lese-Modus mit dieser Seite (doc/app.md 2.1).
  void oeffneHilfe(List<Hilfe> seite) {
    if (!hilfeModus) {
      modus = _modusHilfe;
      hilfeLesen = true;
      shift = false;
      _hilfeSeiten.clear();
    }
    zeigeHilfe(seite);
  }

  /// Klick in den Rahmen der Funktionstasten (nicht auf eine Taste) oder auf den Seitennamen: die Hilfe zur Seite.
  void hilfeZurSeite() => zeigeHilfe(AppHilfe.nachschlagen(api, seitenHilfe));

  /// Zeigt die Seite zu einem Verweis.
  void folgeVerweis(String kennung) => zeigeHilfe(AppHilfe.nachschlagen(api, kennung));

  /// Ein Tipp auf den Hilfeschirm schließt ihn, der Hilfe-Modus bleibt.
  void hilfeSchliessen() {
    _hilfeSeiten.clear();
    hilfeVerweis = -1;
    notifyListeners();
  }

  /// Startet die Hilfe im Inspekt-Modus mit der Seite des letzten Tooltips (höchstens 10 s her) oder der Startseite.
  @override
  void _hilfeStarten() {
    modus = _modusHilfe;
    hilfeLesen = shift = false;
    _hilfeSeiten.clear();
    final letzter = _letzterTooltip;
    if (letzter != null && DateTime.now().difference(letzter.$2) <= const Duration(seconds: 10)) {
      _neueSeite(AppHilfe.fuerTaste(api, letzter.$1));
    }
    if (_hilfeSeiten.isEmpty) _neueSeite(AppHilfe.nachschlagen(api, "#"));
  }

  void _hilfeBeenden() {
    modus = _modusRechnen;
    hilfeLesen = false;
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
}
