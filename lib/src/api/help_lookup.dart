/// Aufgabe: das Nachschlagen der Hilfe (doc/api.md Kapitel 8). [HilfeSuche] sucht eine Kennung in dieser
/// Reihenfolge: eingebaute Einträge ([Hilfetexte]), mit `rpnjson` abgelegte Hilfen (z.B. aus einer geladenen
/// Bibliothek), ein erzeugter Eintrag zu einer eigenen Funktion, Variablen, Konstanten oder einem Tag, zuletzt
/// die Hilfen der verfügbaren, nicht geladenen Bibliotheken. Verändert den Rechner nicht.
///
/// Abgrenzung: Die Klassen der Hilfe stehen in help/help.dart, die eingebauten Einträge in builtin_help.dart,
/// die Hilfen der Bibliotheken liest libraries.dart. Öffentlich ist das über `RpnApi.hilfe`.
///
/// Siehe auch: doc/api.md 8.4, builtin_help.dart, lib/rpnapi.dart.
library;

import '../engine/interpreter.dart';
import '../help/help.dart';
import '../helper.dart';
import 'builtin_help.dart';
import 'libraries.dart';
import 'state.dart';

/// Hilfe zu einem Zeichen, Namen oder Thema aus allen Quellen eines Rechners.
class HilfeSuche {
  final Interpreter _rechner;
  final Bibliotheksverwaltung _bibliotheken;
  HilfeSuche(this._rechner, this._bibliotheken);

  /// Der Eintrag zu [kennung] oder null.
  Hilfe? suche(String kennung) {
    final eingebaut = Hilfetexte.suche(kennung);
    if (eingebaut != null) return eingebaut;
    final eigen = _rechner.calculator.eigeneHilfen[kennung]; // mit rpnjson abgelegt, z.B. aus einer Bibliothek
    if (eigen != null) return Hilfe.fromJson(eigen);
    final erzeugt = _eigeneHilfe(kennung);
    if (erzeugt != null) return erzeugt;
    final ausBibliothek = _bibliotheken.hilfe(kennung);
    return ausBibliothek == null ? null : Hilfe.fromJson(ausBibliothek);
  }

  /// Ein Eintrag mit dem Inhalt einer eigenen Funktion, Variablen, Konstanten oder eines Tags.
  Hilfe? _eigeneHilfe(String name) {
    final s = speicherVon(_rechner.calculator).where((s) => s.name == name).firstOrNull;
    if (s == null) return null;
    if (s.art == SpeicherArt.funktion) {
      return Hilfe(name, "Eigene Funktion $name", [
        Verwendung(name, "ruft die Funktion auf"),
        Verwendung("'~$name", "entfernt die Funktion"),
      ], "Code: {${s.code}}\nSiehe [[#funktionen]].");
    }
    final inhalt = s.werte.map(zahl).join(" "); // Felder ohne [ ], die sind für Einheiten reserviert
    final tag = s.art == SpeicherArt.tag;
    final art = tag ? (s.schreibschutz ? "Tag mit Schreibschutz" : "Tag") : (s.schreibschutz ? "Konstante" : "Variable");
    return Hilfe(name, "$art $name", [
      Verwendung("'$name", "kopiert Elemente auf den Stack", argumente: "n:m (0:1)"),
      if (tag || !s.schreibschutz) Verwendung("'=$name", "schreibt Werte vom Stack hinein", argumente: "n:m:k (0:1:0)"),
      Verwendung("'~$name", tag ? "entfernt den Tag, die Werte bleiben auf dem Stack" : "entfernt ${s.schreibschutz ? "die Konstante" : "die Variable"}"),
    ], "Inhalt: $inhalt\nSiehe [[${tag ? "#tags" : "#variablen"}]].");
  }
}
