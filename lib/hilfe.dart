/// Hilfetexte zur Sprache des Rechners, siehe doc/api.md Kapitel 8.
///
/// Ein Eintrag gehört zu einem Zeichen, einem Namen oder einem Thema (`#…`) und beschreibt alle Verwendungen.
/// Die Texte selbst stehen in library/system/hilfe.de.rpnlib, im selben Format wie die Hilfe von Bibliotheken
/// (`{json}rpnjson`, doc/reference.md 10.5); hier nur die Klassen und das Nachschlagen. Die ausführliche
/// Beschreibung bleibt doc/reference.md.
library;

import 'bibliotheken.g.dart';
import 'rpnapi.dart';

/// Eine Verwendung eines Zeichens oder Namens, z.B. `'!x` bei `!`.
class Verwendung {
  final String schreibweise; // wie man es schreibt
  final String kurz;         // ein Satz, passt in einen Tooltip
  final String stack;        // Wirkung auf den Stack, leer wenn keine
  final String argumente;    // Argumente mit Vorgabe, leer wenn keine

  const Verwendung(this.schreibweise, this.kurz, {this.stack = "", this.argumente = ""});

  Map<String, Object?> toJson() => {"schreibweise": schreibweise, "kurz": kurz, "stack": stack, "argumente": argumente};

  factory Verwendung.fromJson(Map<String, Object?> j) => Verwendung(j["schreibweise"] as String, j["kurz"] as String,
      stack: j["stack"] as String? ?? "", argumente: j["argumente"] as String? ?? "");
}

/// Ein Hilfeeintrag. Der [text] darf mit `[[kennung]]` auf andere Einträge verweisen.
class Hilfe {
  final String kennung;
  final String titel;
  final List<Verwendung> verwendungen;
  final String text;

  const Hilfe(this.kennung, this.titel, this.verwendungen, [this.text = ""]);

  static final RegExp _verweis = RegExp(r"\[\[(.+?)\]\]");

  /// Die Kennungen aller Verweise im Text, in ihrer Reihenfolge, ohne Wiederholungen.
  List<String> get verweise => <String>{for (final m in _verweis.allMatches(text)) m[1]!}.toList();

  /// Der Text mit [darstellung] für jeden Verweis, z.B. dem Titel des Ziels.
  String textMit(String Function(String kennung) darstellung) => text.replaceAllMapped(_verweis, (m) => darstellung(m[1]!));

  Map<String, Object?> toJson() => {
        "kennung": kennung,
        "titel": titel,
        "verwendungen": [for (final v in verwendungen) v.toJson()],
        "text": text,
      };

  /// Fehlen Titel oder Verwendungen (z.B. bei einem Thema), gelten die Kennung bzw. keine.
  factory Hilfe.fromJson(Map<String, Object?> j) => Hilfe(
        j["kennung"] as String,
        j["titel"] as String? ?? j["kennung"] as String,
        [for (final v in j["verwendungen"] as List? ?? const []) Verwendung.fromJson((v as Map).cast<String, Object?>())],
        j["text"] as String? ?? "",
      );
}

/// Die eingebauten Einträge und das Nachschlagen darin.
abstract final class Hilfetexte {
  /// Namen, die zu einem anderen Eintrag gehören.
  static const Map<String, String> _aliase = {
    "}": "{", "exp": "ln", "asin": "sin", "acos": "cos", "atan": "tan", "rad": "deg", "grd": "deg",
    "codeswap": "codedrop", "codedup": "codedrop", "codeover": "codedrop", "ifel": "if", "?": "#",
  };

  /// Die Einträge aus library/system/hilfe.de.rpnlib, beim ersten Nachschlagen geladen, in der Reihenfolge der
  /// Datei: Startseite und Themen, dann Zeichen, dann Funktionen und Befehle.
  static final Map<String, Hilfe> _eintraege = _laden(systemBibliotheken["hilfe.de"]!);

  /// Lädt eine Hilfedatei wie eine Bibliothek in einen eigenen Rechner und übernimmt dessen abgelegte Hilfen.
  static Map<String, Hilfe> _laden(String text) {
    final api = RpnApi();
    final fehler = api.importieren(text, ersetzen: false) ?? api.eingabe("X").fehler?.text;
    if (fehler != null) throw StateError("Die eingebaute Hilfe lässt sich nicht laden: $fehler");
    return {for (final e in api.calculator.eigeneHilfen.entries) e.key: Hilfe.fromJson(e.value)};
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

  /// Die Übersicht aller Zeichen und Namen, nach Gruppen.
  static Hilfe _alle() {
    String gruppe(String titel, Iterable<String> kennungen) => "$titel: ${[for (final k in kennungen) "[[$k]]"].join(", ")}";
    return Hilfe("#alle", "Alle Zeichen und Namen", const [], [
      gruppe("Zeichen", _zeichen),
      gruppe("Funktionen und Befehle", _namen),
      gruppe("Themen", _themen),
    ].join("\n"));
  }
}
