/// Aufgabe: die Bibliotheken eines Rechners. [Bibliotheksverwaltung] kennt die mitgelieferten und die zur
/// Laufzeit hinzugefügten, lädt eine Bibliothek in den Interpreter (nur, wenn keiner ihrer Namen schon anders
/// belegt ist) und entlädt sie wieder, liest Kurzinfo (mit Tastenname und Symbol), Funktionen und Hilfen einer
/// Bibliothek in einem eigenen Probe-Interpreter, ohne sie zu laden, und exportiert die eigenen Funktionen als
/// Bibliothek. [ladeAlsBibliothek] führt den Text einer Bibliothek aus.
///
/// Abgrenzung: Die Texte der mitgelieferten Bibliotheken stehen in libraries/libraries.g.dart; was `rpnjson`
/// (Version, Hilfe) bewirkt, steht im Calculator (engine/functions.dart). Öffentlich ist das über RpnApi.
///
/// Siehe auch: doc/api.md 9.1, doc/reference.md 10.6, library/*.rpnlib, lib/rpnapi.dart.
library;

import '../engine/interpreter.dart';
import '../engine/session.dart';
import '../libraries/libraries.g.dart';
import '../version.dart';

/// Ein Pfad im Symbol einer Bibliothek: Pfaddaten eines SVG im Raster 24 × 24, Strichstärke, gefüllt oder nicht
/// (doc/api.md 9.1).
typedef SymbolPfad = ({String d, double breite, bool fuellen});

/// Kurzinfo zu einer Bibliothek für Menüs und Tooltips; [taste] ist null und [symbol] leer, wenn sie keine angibt.
typedef BibliotheksInfo = ({String beschreibung, String version, int funktionen, String? taste, List<SymbolPfad> symbol});

/// Nur die Zeichen von Pfaddaten: Befehle, Zahlen, Leerzeichen und Kommas. So kann ein Symbol nichts anderes
/// enthalten als Linien, auch wenn die Oberfläche es als SVG zeichnet.
final _pfaddaten = RegExp(r"^[MmLlHhVvCcSsQqTtAaZz0-9eE.,+\- ]+$");

/// Liest `symbol` aus dem version-Eintrag: ein Text (ein Pfad) oder eine Liste von Pfaden; null, wenn es ungültig
/// ist.
List<SymbolPfad>? symbolAus(Object? s) {
  if (s == null) return const [];
  SymbolPfad? pfad(Object? p) {
    if (p is String) p = {"d": p};
    if (p is! Map<String, Object?>) return null;
    final (d, breite, fuellen) = (p["d"], p["breite"] ?? 1.5, p["fuellen"] ?? false);
    if (d is! String || !_pfaddaten.hasMatch(d) || breite is! num || breite <= 0 || fuellen is! bool) return null;
    return (d: d, breite: breite.toDouble(), fuellen: fuellen);
  }
  final liste = [for (final p in s is List ? s : [s]) pfad(p)];
  return liste.isEmpty || liste.contains(null) ? null : [for (final p in liste) p!];
}

/// Eine Bibliothek ist ein Block, der mit X ausgeführt wird: erst importieren, dann X (doc/api.md 9.1).
/// Liefert null oder den Fehler.
String? ladeAlsBibliothek(Interpreter i, String text) {
  final fehler = i.importieren(text, ersetzen: false);
  if (fehler != null) return fehler;
  i.eingabe("X");
  return i.fehler?.text;
}

/// Mitgelieferte und hinzugefügte Bibliotheken; geladen wird in [_rechner].
class Bibliotheksverwaltung {
  final Interpreter _rechner;
  Bibliotheksverwaltung(this._rechner);

  final Map<String, String> _hinzugefuegt = {};

  /// Die Hilfen der Bibliotheken, je Bibliothek einmal in einem Probe-Interpreter gelesen.
  final Map<String, Map<String, Map<String, Object?>>> _hilfen = {};

  /// Alle Bibliotheken, mitgelieferte zuerst, jeweils nach Namen.
  List<({String name, bool mitgeliefert})> alle() => [
        for (final n in mitgelieferteBibliotheken.keys.toList()..sort()) (name: n, mitgeliefert: true),
        for (final n in _hinzugefuegt.keys.toList()..sort()) (name: n, mitgeliefert: false),
      ];

  /// Der Text einer Bibliothek oder null.
  String? text(String name) => mitgelieferteBibliotheken[name] ?? _hinzugefuegt[name];

  /// Meldet eine Bibliothek an, nachdem sie sich in einem Probe-Interpreter fehlerfrei laden ließ.
  String? hinzufuegen(String name, String text) {
    if (mitgelieferteBibliotheken.containsKey(name)) return "Eine mitgelieferte Bibliothek heißt schon so: $name";
    final fehler = ladeAlsBibliothek(Interpreter(), text); // prüfen, ohne diesen Rechner zu verändern
    if (fehler != null) return fehler;
    _hinzugefuegt[name] = text;
    _hilfen.remove(name);
    return null;
  }

  /// Lädt eine Bibliothek; ist einer ihrer Namen schon eine eigene Funktion oder kommt aus einer anderen
  /// Bibliothek, wird sie gar nicht geladen.
  String? laden(String name) {
    final text = this.text(name);
    if (text == null) return "Unbekannte Bibliothek: $name";
    final probe = Interpreter();
    if (ladeAlsBibliothek(probe, text) == null) {
      final c = _rechner.calculator;
      for (final f in probe.calculator.eigeneFunktionen.keys) {
        if (c.eigeneFunktionen.containsKey(f) && c.herkunft[f] != probe.calculator.herkunft[f]) {
          final von = c.herkunft[f];
          return "${c.errorMsg["konflikt"]}: $f (${von == null ? "eigene Funktion" : "Bibliothek $von"})";
        }
      }
    }
    return ladeAlsBibliothek(_rechner, text);
  }

  /// Entlädt eine Bibliothek: ihre Funktionen, die Hilfen, die sie mitbringt, und ihre Versionsangabe. Variablen,
  /// die sie angelegt hat, bleiben (doc/api.md 9.1).
  String? entladen(String name) {
    final c = _rechner.calculator;
    if (!c.versionen.containsKey(name)) return "Bibliothek ist nicht geladen: $name";
    for (final f in [for (final e in c.herkunft.entries) if (e.value == name) e.key]) {
      c.eigeneFunktionen.remove(f);
      c.herkunft.remove(f);
      c.intern.remove(f);
    }
    final text = this.text(name);
    final probe = Interpreter();
    if (text != null && ladeAlsBibliothek(probe, text) == null) {
      probe.calculator.eigeneHilfen.keys.forEach(c.eigeneHilfen.remove);
    }
    c.versionen.remove(name);
    return null;
  }

  /// Die Namen der Funktionen einer Bibliothek in der Reihenfolge der Datei, mit [ohneIntern] ohne die internen.
  List<String> funktionen(String name, {bool ohneIntern = false}) {
    final text = this.text(name);
    if (text == null) return const [];
    final probe = Interpreter();
    if (ladeAlsBibliothek(probe, text) != null) return const [];
    final c = probe.calculator;
    return [for (final f in c.eigeneFunktionen.keys) if (!ohneIntern || !c.intern.contains(f)) f];
  }

  /// Die Versionsangabe einer geladenen Bibliothek oder null.
  Map<String, Object?>? version(String name) => _rechner.calculator.versionen[name];

  /// Satz aus `beschreibung`, Version, Zahl der Funktionen, Tastenname und Symbol, auch wenn die Bibliothek
  /// nicht geladen ist. Ein ungültiges Symbol wird übergangen und als Hinweis gemeldet.
  BibliotheksInfo? info(String name) {
    final text = this.text(name);
    if (text == null) return null;
    final probe = Interpreter();
    if (ladeAlsBibliothek(probe, text) != null) return null;
    final v = probe.calculator.versionen.values.firstOrNull ?? const <String, Object?>{};
    final symbol = symbolAus(v["symbol"]);
    if (symbol == null) _rechner.calculator.hinweise.add("Ungültiges Symbol in der Bibliothek $name übergangen");
    final taste = v["taste"];
    return (
      beschreibung: v["beschreibung"] as String? ?? "",
      version: v["bibliothek"] as String? ?? "",
      funktionen: probe.calculator.eigeneFunktionen.length,
      taste: taste is String && taste.isNotEmpty ? taste : null,
      symbol: symbol ?? const [],
    );
  }

  /// Funktionen aus geladenen Bibliotheken (mit version-Eintrag).
  Set<String> get geladeneFunktionen => Set.unmodifiable(_rechner.calculator.herkunft.keys);

  /// Die Bibliothek, aus der eine Funktion stammt, oder null bei eigenen Funktionen.
  String? herkunft(String name) => _rechner.calculator.herkunft[name];

  /// Der Hilfe-Eintrag (JSON) zu [kennung] aus einer der verfügbaren Bibliotheken, ohne sie zu laden, oder null.
  Map<String, Object?>? hilfe(String kennung) {
    for (final b in alle()) {
      final hilfen = _hilfen.putIfAbsent(b.name, () {
        final probe = Interpreter();
        return ladeAlsBibliothek(probe, text(b.name)!) == null ? Map.of(probe.calculator.eigeneHilfen) : const {};
      });
      final h = hilfen[kennung];
      if (h != null) return h;
    }
    return null;
  }

  /// Die eigenen Funktionen als Bibliothek: ein Block mit Versionsangabe, Funktionen und eigener Hilfe.
  Export exportiere(String name, {String version = "1.0.0", Set<String> ohne = const {}}) {
    final c = _rechner.calculator;
    final funktionen = [for (final f in c.eigeneFunktionen.entries) if (!ohne.contains(f.key)) f];
    final hilfen = [for (final f in funktionen) ?c.eigeneHilfen[f.key]];
    final zeilen = [
      "{",
      "{${jsonFuerBlock({"version": {"name": name, "bibliothek": version, "rechner": rechnerVersion}})}}rpnjson",
      for (final f in funktionen) "{${f.value}}':${f.key}${c.intern.contains(f.key) ? " rpnintern" : ""}",
      if (hilfen.isNotEmpty) "{${jsonFuerBlock({"hilfe": hilfen})}}rpnjson",
      "}",
    ];
    return (text: zeilen.join("\n"), warnungen: const <String>[]);
  }
}
