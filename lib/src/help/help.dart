/// Hilfetexte zur Sprache des Rechners, siehe doc/api.md Kapitel 8.
///
/// Ein Eintrag gehört zu einem Zeichen, einem Namen oder einem Thema (`#…`) und beschreibt alle Verwendungen.
/// Die Texte selbst stehen in library/system/hilfe.de.rpnlib, im selben Format wie die Hilfe von Bibliotheken
/// (`{json}rpnjson`, doc/reference.md 10.5); hier nur die Klassen, ohne Abhängigkeit von anderen Teilen des
/// Rechners. Das Nachschlagen in der eingebauten Hilfe steht in api/builtin_help.dart. Die ausführliche
/// Beschreibung bleibt doc/reference.md.
library;

/// Ein Argument einer Verwendung (doc/api.md 8.1), z.B. das Ziel bei `4:S`.
class Argument {
  final String name;     // kurzer Name für die Kurzform
  final String vorgabe;  // Wert, wenn das Argument fehlt
  final String beispiel; // Zahl für das Beispiel
  final String wirkung;  // ein Satz, was das Argument mit der Beispielzahl bewirkt
  final String stack;    // Wirkung auf den Stack mit diesem Argument, leer wenn keine oder zu lang

  const Argument(this.name, this.vorgabe, this.beispiel, this.wirkung, {this.stack = ""});

  Map<String, Object?> toJson() =>
      {"name": name, "vorgabe": vorgabe, "beispiel": beispiel, "wirkung": wirkung, if (stack.isNotEmpty) "stack": stack};

  factory Argument.fromJson(Map<String, Object?> j) => Argument(j["name"] as String? ?? "", j["vorgabe"] as String? ?? "",
      j["beispiel"] as String? ?? "", j["wirkung"] as String? ?? "", stack: j["stack"] as String? ?? "");
}

/// Eine Verwendung eines Zeichens oder Namens, z.B. `'!x` bei `!`.
class Verwendung {
  final String schreibweise; // wie man es schreibt
  final String kurz;         // ein Satz, was es ohne Argumente tut; passt in einen Tooltip
  final String stack;        // Wirkung auf den Stack ohne Argumente, leer wenn keine
  final List<Argument> argumentListe;
  final String beispiel;     // was das Beispiel mit allen Argumenten tut
  final String beispielStack; // Wirkung des Beispiels auf den Stack, leer wenn zu lang
  final String _argumentText; // bisheriges Format ("n (1)"), wenn es keine Liste gibt

  const Verwendung(this.schreibweise, this.kurz,
      {this.stack = "", String argumente = "", this.argumentListe = const [], this.beispiel = "", this.beispielStack = ""})
      : _argumentText = argumente;

  /// Die Kurzform der Argumente, z.B. `ziel:quelle:anzahl (1:0:1)`, ohne Vorgaben nur die Namen (`m:k`);
  /// leer, wenn es keine gibt.
  String get argumente {
    if (argumentListe.isEmpty) return _argumentText;
    final namen = argumentListe.map((a) => a.name).join(":");
    if (argumentListe.every((a) => a.vorgabe.isEmpty)) return namen;
    return "$namen (${argumentListe.map((a) => a.vorgabe).join(":")})";
  }

  /// Die Eingabe des Beispiels, z.B. `4:1:2:S`.
  String get beispielEingabe => [for (final a in argumentListe) a.beispiel, schreibweise].join(":");

  Map<String, Object?> toJson() => {
        "schreibweise": schreibweise,
        "kurz": kurz,
        "stack": stack,
        "argumente": argumentListe.isEmpty ? _argumentText : [for (final a in argumentListe) a.toJson()],
        if (beispiel.isNotEmpty) "beispiel": beispiel,
        if (beispielStack.isNotEmpty) "beispielStack": beispielStack,
      };

  /// `argumente` ist eine Liste (doc/api.md 8.1) oder im bisherigen Format ein Text.
  factory Verwendung.fromJson(Map<String, Object?> j) {
    final a = j["argumente"];
    return Verwendung(j["schreibweise"] as String, j["kurz"] as String,
        stack: j["stack"] as String? ?? "",
        argumente: a is String ? a : "",
        argumentListe: a is List ? [for (final e in a) Argument.fromJson((e as Map).cast<String, Object?>())] : const [],
        beispiel: j["beispiel"] as String? ?? "",
        beispielStack: j["beispielStack"] as String? ?? "");
  }
}

/// Ein Hilfeeintrag. Der [text] darf mit `[[kennung]]` auf andere Einträge verweisen.
class Hilfe {
  final String kennung;
  final String titel;
  final List<Verwendung> verwendungen;
  final String text;
  final List<String> weitere; // Verweise, die nicht im Text stehen (Feld „verweise“, doc/api.md 8.3)

  const Hilfe(this.kennung, this.titel, this.verwendungen, [this.text = "", this.weitere = const []]);

  static final RegExp _verweis = RegExp(r"\[\[(.+?)\]\]");

  /// Die Kennungen aller Verweise: erst die im Text in ihrer Reihenfolge, dann die weiteren, ohne Wiederholungen.
  List<String> get verweise => <String>{for (final m in _verweis.allMatches(text)) m[1]!, ...weitere}.toList();

  /// Der Text mit [darstellung] für jeden Verweis, z.B. dem Titel des Ziels.
  String textMit(String Function(String kennung) darstellung) => text.replaceAllMapped(_verweis, (m) => darstellung(m[1]!));

  Map<String, Object?> toJson() => {
        "kennung": kennung,
        "titel": titel,
        "verwendungen": [for (final v in verwendungen) v.toJson()],
        "text": text,
        if (weitere.isNotEmpty) "verweise": weitere,
      };

  /// Fehlen Titel oder Verwendungen (z.B. bei einem Thema), gelten die Kennung bzw. keine.
  factory Hilfe.fromJson(Map<String, Object?> j) => Hilfe(
        j["kennung"] as String,
        j["titel"] as String? ?? j["kennung"] as String,
        [for (final v in j["verwendungen"] as List? ?? const []) Verwendung.fromJson((v as Map).cast<String, Object?>())],
        j["text"] as String? ?? "",
        [for (final v in j["verweise"] as List? ?? const []) v as String],
      );
}
