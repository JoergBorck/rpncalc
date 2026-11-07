/// Aufgabe: die Bibliotheken eines Rechners. [Bibliotheksverwaltung] kennt die mitgelieferten und die zur
/// Laufzeit hinzugefügten, lädt eine Bibliothek in den Interpreter (nur, wenn keiner ihrer Namen schon anders
/// belegt ist), liest Kurzinfo, Funktionen und Hilfen einer Bibliothek in einem eigenen Probe-Interpreter, ohne
/// sie zu laden, und exportiert die eigenen Funktionen als Bibliothek. [ladeAlsBibliothek] führt den Text einer
/// Bibliothek aus.
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

  /// Satz aus `beschreibung`, Version und Zahl der Funktionen, auch wenn die Bibliothek nicht geladen ist.
  ({String beschreibung, String version, int funktionen})? info(String name) {
    final text = this.text(name);
    if (text == null) return null;
    final probe = Interpreter();
    if (ladeAlsBibliothek(probe, text) != null) return null;
    final v = probe.calculator.versionen.values.firstOrNull ?? const <String, Object?>{};
    return (
      beschreibung: v["beschreibung"] as String? ?? "",
      version: v["bibliothek"] as String? ?? "",
      funktionen: probe.calculator.eigeneFunktionen.length,
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
