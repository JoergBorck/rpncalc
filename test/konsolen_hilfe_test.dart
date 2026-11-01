import 'package:rpncalc/console/help.dart';
import 'package:rpncalc/console/screen.dart';
import 'package:rpncalc/hilfe.dart';
import 'package:rpncalc/rpnapi.dart';
import 'package:test/test.dart';

/// Hilfe in der Konsole mit \? (doc/api.md Kapitel 7 und 8.4).
void main() {
  final rechner = LokalerRechner(RpnApi());
  Future<List<String>> zeilen(String kennung) async =>
      KonsolenHilfe.zeilen(await KonsolenHilfe.nachschlagen(rechner, kennung), kennung, farbe: false);

  test('Ausgabe wie in api.md: Titel, Verwendungen als Tabelle, Text, Siehe auch mit Aufruf', () async {
    final z = await zeilen("!");
    expect(z.first, "!  Fakultät, Variablen und Konstanten anlegen");
    expect(z[1], matches(RegExp(r"^   !\s+x → x!\s+Fakultät$")));
    expect(z[2], matches(RegExp(r"^   '!name\s+x → –\s+anzahl \(1\)\s+legt die Variable name")));
    expect(z[1].indexOf("Fakultät"), z[2].indexOf("legt"), reason: "die Spalten stehen untereinander");
    expect(z.join(" ").replaceAll(RegExp(" +"), " "),
        contains("Siehe auch: Namen: Variablen, Konstanten, Tags (\\?'), Variablen und Konstanten (\\?#variablen)"));
  });

  test('Text und Verweise werden an Wortgrenzen auf die Fensterbreite umgebrochen', () async {
    final hilfen = await KonsolenHilfe.nachschlagen(rechner, "#");
    final z = KonsolenHilfe.zeilen(hilfen, "#", farbe: false, breite: 50);
    final text = z.where((l) => !l.startsWith("   \\?")); // Verwendungen sind Tabellenzeilen
    expect(text.every((l) => l.length <= 50), isTrue, reason: text.firstWhere((l) => l.length > 50, orElse: () => ""));
    expect(z.where((l) => l.startsWith("   Siehe auch:")).length, 1);
    expect(z.join("\n"), isNot(contains("[[")), reason: "Verweise im Text sind durch Titel ersetzt");
  });

  test('Startseite: zuerst die der Konsole, dann die des Rechners', () async {
    final z = await zeilen("");
    expect(z.first, startsWith("#  Hilfe in der Konsole"));
    expect(z.where((l) => l.startsWith("#  ")).toList(), ["#  Hilfe in der Konsole", "#  Hilfe zum RPN-Rechner"]);
  });

  test('Einträge der Konsole und unbekannte Kennungen', () async {
    expect((await zeilen("konsole:v")).first, "konsole:v  Einfügen");
    expect((await zeilen(r"\")).first, r"\  Befehle der Konsole");
    expect(await zeilen("gibtsnicht"), ["Keine Hilfe zu gibtsnicht. \\? zeigt die Startseite."]);
  });

  test('jeder Verweis der Konsole hat ein Ziel', () {
    for (final h in KonsolenHilfe.eintraege.values) {
      for (final v in h.verweise) {
        expect(KonsolenHilfe.eintraege[v] ?? Hilfetexte.suche(v), isNotNull, reason: "${h.kennung} → $v");
      }
    }
  });

  test('eigene Namen kommen vom Rechner', () async {
    final api = RpnApi()..eingabe("{1+}':inc");
    final z = KonsolenHilfe.zeilen(await KonsolenHilfe.nachschlagen(LokalerRechner(api), "inc"), "inc", farbe: false);
    expect(z.first, "inc  Eigene Funktion inc");
    expect(z.join("\n"), contains("Code: {1+}"));
  });
}
