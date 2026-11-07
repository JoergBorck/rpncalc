/// Aufgabe: die eingebaute Hilfe des Rechners. [Hilfetexte] lädt library/system/hilfe.de.rpnlib beim ersten
/// Nachschlagen wie eine Bibliothek in einen eigenen Rechner und sucht darin nach Kennung, Alias oder
/// Schreibweise; dazu die Übersicht „Alle Zeichen und Namen“.
///
/// Abgrenzung: Die Klassen der Hilfe (Hilfe, Verwendung, Argument) stehen in help/help.dart und hängen von
/// nichts ab. Diese Datei liegt in api/, weil sie zum Laden einen eigenen Interpreter braucht; das Nachschlagen
/// über alle Quellen macht help_lookup.dart.
///
/// Siehe auch: doc/api.md Kapitel 8, doc/architecture.md 5, library/system/hilfe.de.rpnlib.
library;

import '../engine/interpreter.dart';
import '../help/help.dart';
import '../libraries/libraries.g.dart';
import 'libraries.dart';

/// Die eingebauten Einträge und das Nachschlagen darin.
abstract final class Hilfetexte {
  /// Namen, die zu einem anderen Eintrag gehören.
  static const Map<String, String> _aliase = {
    "}": "{", "exp": "ln", "asin": "sin", "acos": "cos", "atan": "tan", "asinh": "sinh", "acosh": "cosh", "atanh": "tanh", "rad": "deg", "grd": "deg",
    "codeswap": "codedrop", "codedup": "codedrop", "codeover": "codedrop", "ifel": "if", "?": "#",
  };

  /// Die Einträge aus library/system/hilfe.de.rpnlib, beim ersten Nachschlagen geladen, in der Reihenfolge der
  /// Datei: Startseite und Themen, dann Zeichen, dann Funktionen und Befehle.
  static final Map<String, Hilfe> _eintraege = _laden(systemBibliotheken["hilfe.de"]!);

  /// Lädt eine Hilfedatei wie eine Bibliothek in einen eigenen Rechner und übernimmt dessen abgelegte Hilfen.
  static Map<String, Hilfe> _laden(String text) {
    final rechner = Interpreter();
    final fehler = ladeAlsBibliothek(rechner, text);
    if (fehler != null) throw StateError("Die eingebaute Hilfe lässt sich nicht laden: $fehler");
    return {for (final e in rechner.calculator.eigeneHilfen.entries) e.key: Hilfe.fromJson(e.value)};
  }

  /// Schreibweise einer Verwendung → Eintrag, damit z.B. `~²` den Eintrag `²` findet.
  static final Map<String, String> _schreibweisen = {
    for (final h in _eintraege.values.toList().reversed)
      for (final v in h.verwendungen) v.schreibweise: h.kennung,
  };

  /// Der Eintrag zu einer Kennung, einem Alias oder einer Schreibweise, sonst null.
  static Hilfe? suche(String kennung) {
    if (kennung == "#alle") return _alle();
    final k = _aliase[kennung] ?? kennung;
    return _eintraege[k] ?? _eintraege[_schreibweisen[k]];
  }

  static bool _istThema(String k) => k.startsWith("#") && k != "#";
  static bool _istName(String k) => RegExp(r"^[a-zA-Z]+$").hasMatch(k);

  static Iterable<String> get _themen => _eintraege.keys.where(_istThema);
  static Iterable<String> get _zeichen => _eintraege.keys.where((k) => !k.startsWith("#") && !_istName(k));
  static Iterable<String> get _namen => _eintraege.keys.where(_istName);

  /// Alle eingebauten Kennungen: Startseite und Themen, dann Zeichen und Namen.
  static List<String> get kennungen => ["#", "#alle", ..._themen, ..._zeichen, ..._namen];

  /// Alle Schreibweisen, für den Vollständigkeitstest.
  static Set<String> get schreibweisen => _schreibweisen.keys.toSet();

  /// Die Übersicht aller Zeichen und Namen: nur Verweise, erst die Zeichen, dann Funktionen und Befehle, zuletzt
  /// die Themen (Gruppen mit Überschrift kommen mit VA-5).
  static Hilfe _alle() => Hilfe("#alle", "Alle Zeichen und Namen", const [],
      "Erst die Zeichen, dann Funktionen und Befehle, zuletzt die Themen.", [..._zeichen, ..._namen, ..._themen]);
}
