/// Aufgabe: die Spur einer Eingabe durch den Rechner (Backlog PR-1). [Spur] nimmt Ereignisse aus DEA, Parser und
/// Calculator entgegen und macht daraus je eine Textzeile: vorn die Kategorie, dann die Felder, durch Tabulator
/// getrennt; Ereignisse in ausgeführtem Code sind nach der Aufruftiefe eingerückt.
///
/// Abgrenzung: Die Haken sitzen in language/dea.dart (`step`), language/parser.dart (Zeichen, Tokens, Fehler) und
/// engine/calculator.dart (Ausführung, Stack, Tiefe). Ohne gesetzte Spur ruft dort niemand etwas auf. Das Werkzeug,
/// das die Zeilen ausgibt, ist tool/trace.dart.
///
/// Siehe auch: process/requirements/PR-1.md.
library;

/// Kategorien der Spur, in der Reihenfolge, in der sie für ein Zeichen meist vorkommen.
const List<String> spurKategorien = ["zeichen", "dea", "token", "rechner", "stack", "fehler", "hinweis"];

/// Nimmt Ereignisse entgegen und gibt sie als Zeilen an [ausgabe] weiter.
class Spur {
  /// Bekommt jede fertige Zeile.
  final void Function(String zeile) ausgabe;

  /// Nur diese Kategorien ausgeben; null heißt alle.
  final Set<String>? nur;

  /// Aufruftiefe beim Ausführen von Code; der Calculator zählt sie hoch und runter.
  int tiefe = 0;

  Spur(this.ausgabe, {this.nur});

  /// Sammelt die Zeilen in einer Liste, z.B. für Tests.
  factory Spur.liste(List<String> zeilen, {Set<String>? nur}) => Spur(zeilen.add, nur: nur);

  /// Ein Ereignis der [kategorie] mit seinen Feldern.
  void call(String kategorie, List<Object?> felder) {
    if (nur != null && !nur!.contains(kategorie)) return;
    ausgabe(["${"  " * tiefe}$kategorie", ...felder.map(_feld)].join("\t"));
  }

  /// Zeilenende und Tabulator sichtbar machen, damit jede Zeile eine Zeile bleibt und die Felder getrennt.
  /// Ein Backslash bleibt, wie er ist (lesbarer; mehrdeutig nur bei einem echten „\n“ in der Eingabe).
  static String _feld(Object? f) => "$f".replaceAll("\n", "\\n").replaceAll("\t", "\\t");
}
