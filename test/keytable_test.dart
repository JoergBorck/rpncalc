import 'dart:io';

import 'package:test/test.dart';

import '../tool/keytable.dart';

/// Die Tastentabelle (DG-7, tool/keytable.dart).
void main() {
  const doc = "# T\n\nvon Hand\n\n<!-- erzeugt: domaenen -->\nalt\n<!-- ende -->\n\nnoch von Hand\n\n"
      "<!-- erzeugt: modi -->\n<!-- ende -->\n";

  test('doc/keys.md ist aktuell (sonst: dart run tool/keytable.dart)', () {
    final r = tastentabelle(doc: File("doc/keys.md").readAsStringSync(), geplant: File("doc/keys_planned.txt").readAsStringSync());
    expect(r.meldungen.where((m) => m.startsWith("Fehler")), isEmpty);
    expect(r.text, File("doc/keys.md").readAsStringSync());
  });

  test('nur die Blöcke werden ersetzt; Geplantes kursiv mit Eintrag, die Spalte Modi verlinkt die Gruppe', () {
    const geplant = "# Kommentar\nmodus hyp = Trig: HYPR (FR-15)\nsin.strich = csc (FR-15)\nsin.hyp.normal = sinh\n";
    final r = tastentabelle(doc: doc, geplant: geplant);
    expect(r.text, startsWith("# T\n\nvon Hand\n\n<!-- erzeugt: domaenen -->\n### Grundfunktionen\n"));
    expect(r.text, contains("\nnoch von Hand\n"));
    expect(r.text, contains("| sin | [Trig](#trig) | sin | asin | *csc (FR-15)* |"));
    expect(r.text, contains("### Trig\n\n#### Trig: HYPR (FR-15)\n"));
    expect(r.text, contains("| sin |  | *sinh* |"));
    expect(r.meldungen.where((m) => !m.contains("fehlt")), isEmpty);
  });

  test('Meldungen: unbekannte Taste, Spalte und Modus; Kollision; umgesetzt', () {
    const geplant = "xyz.shift = a\nsin.links = b\nsin.foo.tilde = c\nsin.shift = d\nsin.tilde = asin\n";
    final m = tastentabelle(doc: doc, geplant: geplant).meldungen.where((m) => !m.contains("fehlt")).toList();
    expect(m, [
      "Fehler: doc/keys_planned.txt:1: unbekannte Taste „xyz“",
      "Fehler: doc/keys_planned.txt:2: unbekannte Spalte „links“",
      "Fehler: doc/keys_planned.txt:3: unbekannter Modus „foo“ (erst `modus foo = Gruppe: Titel` anlegen)",
      "Warnung: doc/keys_planned.txt:4: „sin.shift“ ist schon belegt mit „sinh“",
      "Hinweis: doc/keys_planned.txt:5: „sin.tilde = asin“ ist umgesetzt, die Zeile kann aus der Liste",
    ]);
  });

  test('Tasten mit Punkt (. und :) und Zeichen, die Markdown schützt', () {
    final r = tastentabelle(doc: "<!-- erzeugt: rechnen-unten -->\n<!-- ende -->\n", geplant: "..tilde = ~.\n:.shift = ggT (FR-99)\n");
    expect(r.text, contains("| . |  | . | *~.* |"));
    expect(r.text, contains("| : |  | : | ~: | \\|: | ~\\|: | *ggT (FR-99)* |"));
    expect(r.text, contains("| × |  | × (\\*) |"));
  });
}
