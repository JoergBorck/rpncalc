import 'dart:convert';
import 'dart:io';

import '../rpnapi.dart';
import 'display.dart';
import 'help.dart';
import 'library.dart';
import 'screen.dart';

class UI {
  RpnApi api;

  /// Die zeichenweise Eingabe, mit dem Rechner im selben Programm. stdin wird hier mit readByteSync gelesen,
  /// weil das Menü danach wieder mit readLineSync liest (ein Stream ließe sich nur einmal abonnieren).
  late final Bildschirm _bildschirm = Bildschirm(LokalerRechner(api), () async => stdin.readByteSync());

  UI(this.api);

  /// Liest Zeilen und zeigt nach jeder Eingabe den Zustand,
  /// kompakt als eine Zeile oder als [uebersicht] in Spalten.
  Future<void> zeilenweiseEingabe({bool uebersicht = false}) async {
    print("Geben sie die Berechnung ein. \\c kopiert den Tos, \\s den Stack, \\v fügt Zahlen ein, "
          "\\? zeigt die Hilfe, \\q führt zurück zum Menü.");
    Zustand start = api.zustand();
    print(uebersicht ? Anzeige.uebersicht(start) : Anzeige.kompakt(start)); // gleich zeigen, womit man rechnet
    while (true) {
      stdout.write(Anzeige.farbigerPrompt()); // "RPN> " vor der Eingabe
      String? eingabe = stdin.readLineSync(encoding: utf8);
      if (eingabe == null || eingabe.trim() == r"\q") break; // null: Ende der Eingabe, z.B. umgeleitete Datei
      // \? und eine Kennung zeigt die Hilfe, die Zeile wird nicht gerechnet (doc/api.md Kapitel 7)
      if (eingabe.trimLeft().startsWith(r"\?")) {
        final kennung = eingabe.trimLeft().substring(2).trim();
        KonsolenHilfe.zeilen(await KonsolenHilfe.nachschlagen(LokalerRechner(api), kennung), kennung.isEmpty ? "#" : kennung,
                breite: stdout.hasTerminal ? stdout.terminalColumns - 1 : 79)
            .forEach(print);
        continue;
      }
      // \c oder \s am Zeilenende: erst die Zeile davor rechnen, dann kopieren (wie bei der zeichenweisen Eingabe)
      String? kopieren;
      String ende = eingabe.trimRight();
      if (ende.endsWith(r"\c") || ende.endsWith(r"\s")) {
        kopieren = ende[ende.length - 1];
        eingabe = ende.substring(0, ende.length - 2).trimRight();
      }
      if (kopieren != null && eingabe.isEmpty) {
        print(await _bildschirm.kopieren(kopieren));
        continue;
      }
      bool eingefuegt = eingabe.trim() == r"\v";
      if (eingefuegt) {
        final (zahlen, meldung) = await Bildschirm.zahlenEinfuegen();
        print(meldung);
        if (zahlen.isEmpty) continue;
        eingabe = zahlen;
      }
      Zustand z = api.eingabe(eingabe);
      if (z.fehler != null && eingefuegt) {
        print("Fehler: ${z.fehler!.text}"); // die eingefügte Zeile wurde nicht angezeigt, also kein ^
      } else if (z.fehler != null) {
        // ^ unter den Anfang des fehlerhaften Tokens der eben eingegebenen Zeile setzen
        int stelle = z.fehler!.start >= 0 ? z.fehler!.start : z.fehler!.position;
        print("${" " * (Anzeige.prompt.length + stelle)}^ Fehler: ${z.fehler!.text}");
      }
      print(uebersicht ? Anzeige.uebersicht(z) : Anzeige.kompakt(z));
      if (kopieren != null) print(z.fehler == null ? await _bildschirm.kopieren(kopieren) : "Wegen des Fehlers nicht kopiert");
    }
  }

  /// Liest Taste für Taste und zeigt nach jeder Taste den Zustand (doc/api.md Kapitel 5),
  /// siehe Bildschirm.eingabe. \q führt zurück zum Menü. Der Verlauf bleibt bis zum nächsten Mal erhalten.
  Future<void> zeichenweiseEingabe({bool uebersicht = false}) async {
    if (!stdin.hasTerminal) {
      print("Die zeichenweise Eingabe braucht ein Terminal (z.B. das Terminal in VS Code).");
      return;
    }
    print("Zeichenweise Eingabe. Enter schließt ab, Backspace löscht, \\c kopiert den Tos, \\s den Stack, "
          "\\v fügt Zahlen ein, \\? zeigt die Hilfe, \\q führt zurück zum Menü.");
    await _bildschirm.eingabe(uebersicht: uebersicht);
  }

  /// Fragt nach einem Dateinamen; ohne Endung wird die Endung des Vorschlags angehängt
  /// (".rpn" für Sessions, ".rpnlib" für Funktionen).
  String? _dateiname(String vorschlag) {
    stdout.write("Dateiname [$vorschlag]: ");
    String? name = stdin.readLineSync(encoding: utf8);
    if (name == null) return null;
    name = name.trim().isEmpty ? vorschlag : name.trim();
    return name.contains(".") ? name : "$name${vorschlag.substring(vorschlag.lastIndexOf("."))}";
  }

  /// Speichert die Session als RPN-Skript oder die eigenen Funktionen als Bibliothek (doc/api.md 9.1).
  /// Funktionen aus geladenen mitgelieferten Bibliotheken lässt „Funktionen speichern“ aus.
  void speichern({bool nurFunktionen = false}) {
    String? name = _dateiname(nurFunktionen ? "funktionen.rpnlib" : "session.rpn");
    if (name == null) return;
    final ohne = api.geladeneBibliotheksFunktionen;
    final bibliothek = File(name).uri.pathSegments.last.replaceFirst(RegExp(r"\.rpnlib$"), "");
    Export ex = nurFunktionen ? api.exportiereBibliothek(bibliothek, ohne: ohne) : api.exportieren();
    final ausgelassen = [
      if (nurFunktionen)
        for (Speicher s in api.zustand().speicher)
          if (s.art == SpeicherArt.funktion && ohne.contains(s.name)) s.name,
    ];
    try {
      File(name).writeAsStringSync("${ex.text}\n", encoding: utf8);
      print("Gespeichert in $name");
      if (ausgelassen.isNotEmpty) print("Aus Bibliotheken, nicht gespeichert: ${ausgelassen.join(", ")}");
      for (String w in ex.warnungen) {
        print("Hinweis: $w");
      }
    } on FileSystemException catch (e) {
      print("Fehler beim Speichern: ${e.message}");
    }
  }

  /// Lädt eine Session; sie ersetzt den ganzen Rechner, die geladenen Bibliotheken sind damit vergessen.
  void laden() {
    String? name = _dateiname("session.rpn");
    if (name == null) return;
    _laden(File(name), ersetzen: true);
  }

  /// Lädt eine Bibliothek aus dem Menü „Bibliotheken“ und ergänzt damit die eigenen Funktionen: eine
  /// mitgelieferte aus dem Rechner, eine selbst gespeicherte wird vorher beim Rechner angemeldet (doc/api.md 9.1).
  void ladeBibliothek(Bibliothek b) {
    String? fehler;
    final datei = b.datei;
    if (datei != null) {
      try {
        fehler = api.bibliothekHinzufuegen(b.titel, datei.readAsStringSync(encoding: utf8));
      } on FileSystemException catch (e) {
        fehler = e.message;
      }
    }
    fehler ??= api.ladeBibliothek(b.titel);
    print(fehler == null ? "Geladen: ${b.titel}" : "Fehler beim Laden: $fehler");
    for (final h in api.hinweise()) {
      print("Hinweis: $h");
    }
    print(Anzeige.uebersicht(api.zustand()));
  }

  /// Liefert true, wenn die Datei ohne Fehler geladen wurde.
  bool _laden(File datei, {required bool ersetzen}) {
    final name = datei.path;
    try {
      String? fehler = api.importieren(datei.readAsStringSync(encoding: utf8), ersetzen: ersetzen);
      print(fehler == null ? "Geladen aus $name" : "Fehler beim Laden: $fehler");
      print(Anzeige.uebersicht(api.zustand()));
      return fehler == null;
    } on FileSystemException catch (e) {
      print("Fehler beim Laden: ${e.message}");
      return false;
    }
  }
}
