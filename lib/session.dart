import 'dart:convert';

import 'calc/value.dart';
import 'calculator.dart';

/// Ergebnis eines Exports: das Skript und Hinweise auf Werte, die sich nicht ausdrücken lassen.
typedef Export = ({String text, List<String> warnungen});

/// Wandelt den Zustand des Rechners in ein RPN-Skript um.
///
/// Das Skript ist selbst eine Eingabe für den Rechner: Laden heißt, es Zeile für Zeile auszuführen.
/// Reihenfolge: Einstellungen, eigene Funktionen, Variablen, Stack mit Tags, Code-Stack und zuletzt
/// die offenen Argumente (sonst würde sie das erste '!x oder '|x beim Laden verbrauchen).
/// Werte werden mit "_" getrennt, damit beim Laden kein ungewolltes Enter entsteht.
class SessionSkript {
  final List<String> _warnungen = [];

  /// Mit [nurFunktionen] nur die eigenen Funktionen, außer denen, deren Name in [ohne] steht.
  Export exportieren(Calculator c, {bool nurFunktionen = false, Set<String> ohne = const {}}) {
    _warnungen.clear();
    List<String> zeilen = [
      if (!nurFunktionen) _einstellungen(c),
      for (var f in c.eigeneFunktionen.entries)
        if (!nurFunktionen || !ohne.contains(f.key)) "{${f.value}}':${f.key}",
      // eigene Hilfen gehen beim Speichern nicht verloren (doc/api.md 9.1)
      if (!nurFunktionen && c.eigeneHilfen.isNotEmpty) "{${jsonFuerBlock({"hilfe": c.eigeneHilfen.values.toList()})}}rpnjson",
      if (!nurFunktionen) ...[
        for (var v in c.variablen.entries) _werte(v.value.reversed, v.key, c.schreibschutz.contains(v.key) ? "!!" : "!"),
        _stack(c),
        c.codeStack.inhalt.reversed.map((b) => "{$b}").join(),
        c.args.offen.map((w) => "${_zahl(w)}:").join(),
      ],
    ];
    return (text: zeilen.where((z) => z.isNotEmpty).join("\n"), warnungen: List.of(_warnungen));
  }

  String _einstellungen(Calculator c) =>
      [c.angleMode == AngleMode.grad ? "grd" : c.angleMode.name, if (c.seed != null) "${_zahl(c.seed!)}seed"].join("_");

  /// Werte (tiefstes zuerst) und danach n:'!name bzw. n:'!!name für Konstanten.
  String _werte(Iterable<Wert> werte, String name, String mod) {
    int n = werte.length;
    return [...werte.map(_zahl), "${n == 1 ? "" : "$n:"}'$mod$name"].join("_");
  }

  /// Stack von unten nach oben. Ein Tag wird gesetzt, sobald seine oberste Zelle auf dem Stack liegt.
  String _stack(Calculator c) {
    final stack = c.stack;
    List<String> teile = [];
    for (int p = stack.tiefe - 1; p >= 0; p--) {
      teile.add(_zahl(stack[p]));
      for (var t in c.tags.entries) {
        if (stack.position(t.value.first) == p) {
          int n = t.value.length;
          teile.add("${n == 1 ? "" : "$n:"}'${c.schreibschutz.contains(t.key) ? "||" : "|"}${t.key}");
        }
      }
    }
    return teile.join("_");
  }

  /// Zahl in der Schreibweise des Rechners: negatives Vorzeichen als ~, Exponent als ê.
  String _zahl(Wert w) {
    if (w.isNaN || w.isInfinite) {
      _warnungen.add("$w lässt sich nicht speichern, statt dessen 0");
      return "0";
    }
    num a = w.abs();
    String s = (a == a.truncateToDouble() && a < 1e15)
        ? a.toInt().toString()                                     // ganze Zahlen ohne ".0"
        : a.toString().replaceAll("e+", "ê").replaceAll("e-", "ê~").replaceAll("e", "ê");
    return w.isNegative ? "~$s" : s;
  }
}

/// JSON für einen Code-Block `{…}rpnjson`: Klammern in Texten werden zu \u007b bzw. \u007d, damit die Klammern
/// des Blocks ausgeglichen bleiben (doc/reference.md 10.5).
String jsonFuerBlock(Object? wert) {
  final json = jsonEncode(wert);
  final aus = StringBuffer();
  bool inText = false, maskiert = false;
  for (final c in json.split("")) {
    if (inText && !maskiert && (c == "{" || c == "}")) {
      aus.write(c == "{" ? r"\u007b" : r"\u007d");
      continue;
    }
    aus.write(c);
    if (maskiert) {
      maskiert = false;
    } else if (c == r"\") {
      maskiert = inText;
    } else if (c == '"') {
      inText = !inText;
    }
  }
  return aus.toString();
}
