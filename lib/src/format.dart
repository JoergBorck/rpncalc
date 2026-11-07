/// Aufgabe: das Excel-Format der Zwischenablage, gemeinsam für App und Konsole. [fuerExcel] schreibt Werte für
/// ein deutsches Excel (Dezimalkomma, getrennt mit „;“), [ausExcel] holt alle Zahlen aus einem kopierten Text und
/// schreibt sie in der Schreibweise des Rechners.
///
/// Abgrenzung: Lesen und Schreiben der Zwischenablage selbst macht jede Oberfläche auf ihre Art
/// (console/clipboard.dart, in der App Flutter). Die Zahl für die Anzeige steht in helper.dart.
///
/// Siehe auch: doc/api.md Kapitel 7 (Zwischenablage, „Einfügen mit `\v`“), rpnapi.dart (exportiert diese Datei).
library;

import 'helper.dart';

/// Werte für die Zwischenablage, passend zu einem deutschen Excel: Dezimalkomma, getrennt mit ";".
/// Bei mehreren Werten steht der tiefste zuerst und der Tos zuletzt, wie in der Anzeige.
String fuerExcel(Iterable<num> werte) => [for (num w in werte) zahl(w).replaceAll(".", ",")].join(";");

/// Alle Zahlen aus einem Text (z.B. aus Excel kopiert) in der Schreibweise des Rechners, siehe doc/api.md 7:
/// Dezimalkomma oder -punkt, Exponent mit e oder E; alles andere wird übersprungen.
/// Ein Minus ist nur ein Vorzeichen, wenn davor keine Ziffer und kein Buchstabe steht.
/// Der Fehlerwert #DIV/0! von Excel liefert keine 0.
/// Ein einzelnes Komma zwischen Ziffern ist ein Dezimalkomma; in einer Folge (4,5,6,7) und in einem Text mit
/// Dezimalpunkt trennen Kommas (BA-3).
List<String> ausExcel(String text) => [
      for (final m in _zahlImText.allMatches(_kommas(text.replaceAll("#DIV/0!", ""))))
        "${m[1] == "-" ? "~" : ""}${m[2]!.replaceAll(",", ".")}"
            "${m[4] == null ? "" : "ê${m[3] == "-" ? "~" : ""}${int.parse(m[4]!)}"}",
    ];

/// Ob [text] nur aus Zahlen besteht, getrennt durch ";", Kommas in einer Folge, Leerzeichen, Tab oder
/// Zeilenumbruch, wie Werte aus dem Stack ([fuerExcel]) oder eine Spalte aus Excel (mindestens eine Zahl).
bool nurZahlen(String text) {
  final t = _kommas(text);
  final rest = t.replaceAll(_zahlImText, "");
  return _zahlImText.hasMatch(t) && RegExp(r"^[\s;]*$").hasMatch(rest);
}

/// Kommas, die trennen, werden zu ";".
String _kommas(String text) {
  if (RegExp(r"\d\.\d").hasMatch(text)) return text.replaceAll(",", ";");
  return text.replaceAllMapped(RegExp(r"\d+(?:,\d+){2,}"), (m) => m[0]!.replaceAll(",", ";"));
}

final RegExp _zahlImText =
    RegExp(r"(?:(?<![\p{L}\d])([+-]))?(\d+(?:[.,]\d+)?)(?:[eE]([+-]?)(\d+))?", unicode: true);
