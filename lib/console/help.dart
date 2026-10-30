import '../hilfe.dart';
import 'screen.dart';

/// Hilfe in der Konsole mit `\?` (doc/api.md Kapitel 7 und 8.4): eigene Einträge für die Bedienung,
/// Nachschlagen zusammen mit dem Rechner und die Ausgabe als Textzeilen.
abstract final class KonsolenHilfe {
  /// Einträge der Konsole. Unter einer Kennung des Rechners (`#`, `\`) ergänzen sie dessen Eintrag.
  static const Map<String, Hilfe> eintraege = {
    "#": Hilfe("#", "Hilfe in der Konsole", [
      Verwendung(r"\?x", "zeigt die Hilfe zu einem Zeichen, Namen oder Thema, z.B. \\?! oder \\?#tags"),
      Verwendung(r"\?", "zeigt diese Startseite"),
    ], r"Bedienung der Konsole: [[konsole:q]], [[konsole:c]], [[konsole:v]], [[konsole:tab]], [[konsole:hilfe]]"),
    r"\": Hilfe(r"\", "Befehle der Konsole", [
      Verwendung(r"\q", "zurück zum Menü"),
      Verwendung(r"\c", "kopiert den Tos in die Zwischenablage"),
      Verwendung(r"\s", "kopiert den ganzen Stack in die Zwischenablage"),
      Verwendung(r"\v", "fügt die Zahlen aus der Zwischenablage ein"),
      Verwendung(r"\?", "Hilfe"),
    ], "Ein \\ wartet auf das nächste Zeichen. Alle anderen Folgen bleiben für spätere Sonderzeichen frei."),
    "konsole:q": Hilfe("konsole:q", "Zurück zum Menü", [Verwendung(r"\q", "beendet die Eingabe und führt zurück zum Menü")],
        "Strg+C beendet unter Windows das ganze Programm, deshalb gibt es \\q."),
    "konsole:c": Hilfe("konsole:c", "Kopieren", [
      Verwendung(r"\c", "kopiert den Tos, für ein deutsches Excel mit Dezimalkomma"),
      Verwendung(r"\s", "kopiert den Stack, der tiefste Wert zuerst, getrennt mit ;"),
    ], "Ein offenes Token wird vorher abgeschlossen: Nach 2.25 kopiert \\c also 2,25. Siehe [[konsole:v]]."),
    "konsole:v": Hilfe("konsole:v", "Einfügen", [Verwendung(r"\v", "fügt alle Zahlen aus der Zwischenablage ein")],
        "Erkannt werden deutsche und englische Schreibweise (3,4 3.4 -2 1e5), alles andere wird übersprungen. "
        "Die erste Zahl kommt zuerst auf den Stack, die letzte ist der Tos. Siehe [[konsole:c]]."),
    "konsole:tab": Hilfe("konsole:tab", "Bereiche und Pfeiltasten", [
      Verwendung("Tab", "wechselt den Bereich: Stack, Verlauf, Variablen, Funktionen"),
      Verwendung("↑ ↓", "blättern im gewählten Bereich"),
      Verwendung("← →", "schieben lange Zeilen seitlich"),
    ], "Gilt für die zeichenweise Eingabe und den Client. Siehe [[#stack]]."),
    "konsole:hilfe": Hilfe("konsole:hilfe", "Hilfe", [
      Verwendung(r"\?x", "Hilfe zu x und Enter"),
      Verwendung("Backspace", "löscht ein Zeichen der Kennung, direkt nach \\? bricht es ab"),
    ], "In der zeichenweisen Eingabe steht die Hilfe unter der Eingabe, bis zur nächsten Taste. In der "
        "zeilenweisen Eingabe ist sie nie gekürzt. Startseite: [[#]]."),
  };

  /// Die Einträge zu einer Kennung: zuerst der Konsole, dann des Rechners (doc/api.md 8.4).
  static Future<List<Hilfe>> nachschlagen(Rechner rechner, String kennung) async {
    final k = kennung.isEmpty ? "#" : kennung;
    final eigene = eintraege[k];
    final vomRechner = k.startsWith("konsole:") ? null : await rechner.hilfe(k);
    return [?eigene, ?vomRechner];
  }

  /// Titel eines Verweisziels; eingebaute Einträge kennt die Konsole auch ohne Rechner.
  static String _titel(String kennung) => eintraege[kennung]?.titel ?? Hilfetexte.suche(kennung)?.titel ?? kennung;

  /// Die Hilfe als Textzeilen wie in doc/api.md Kapitel 7: Titel, Verwendungen als Tabelle, Text und
  /// „Siehe auch“ mit dem Aufruf jedes Verweises.
  /// Bricht [text] an Wortgrenzen so um, dass jede Zeile mit [einzug] höchstens [breite] Zeichen hat.
  static List<String> _umbrechen(String text, int breite, String einzug) {
    final aus = <String>[];
    var zeile = "";
    for (final wort in text.split(" ")) {
      if (zeile.isNotEmpty && einzug.length + zeile.length + 1 + wort.length > breite) {
        aus.add("$einzug$zeile");
        zeile = wort;
      } else {
        zeile = zeile.isEmpty ? wort : "$zeile $wort";
      }
    }
    if (zeile.isNotEmpty) aus.add("$einzug$zeile");
    return aus;
  }

  static List<String> zeilen(List<Hilfe> hilfen, String kennung, {bool farbe = true, int breite = 79}) {
    String fett(String s) => farbe ? "\x1B[1m$s\x1B[0m" : s;
    String blass(String s) => farbe ? "\x1B[2m$s\x1B[0m" : s;
    if (hilfen.isEmpty) return ["Keine Hilfe zu $kennung. \\? zeigt die Startseite."];
    final aus = <String>[];
    final verweise = <String>[];
    for (final h in hilfen) {
      aus.add("${fett(h.kennung == " " ? "␣" : h.kennung)}  ${h.titel}");
      int spalte(String Function(Verwendung) feld) =>
          h.verwendungen.fold(0, (m, v) => feld(v).length > m ? feld(v).length : m);
      final b1 = spalte((v) => v.schreibweise), b2 = spalte((v) => v.stack), b3 = spalte((v) => v.argumente);
      for (final v in h.verwendungen) {
        aus.add([
          "   ${v.schreibweise.padRight(b1)}",
          if (b2 > 0) v.stack.padRight(b2),
          if (b3 > 0) blass(v.argumente.padRight(b3)),
          v.kurz,
        ].join("  ").trimRight());
      }
      if (h.text.isNotEmpty) {
        for (final z in h.textMit(_titel).split("\n")) {
          aus.addAll(_umbrechen(z, breite, "   "));
        }
      }
      for (final v in h.verweise) {
        if (!verweise.contains(v)) verweise.add(v);
      }
    }
    if (verweise.isNotEmpty) {
      final siehe = "Siehe auch: ${[for (final v in verweise) "${_titel(v)} (\\?$v)"].join(", ")}";
      aus.addAll([for (final z in _umbrechen(siehe, breite, "   ")) blass(z)]);
    }
    return aus;
  }
}
